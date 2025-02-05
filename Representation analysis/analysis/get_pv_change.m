% Script to generate a time serie of PV-correlation during each lap with
% final lap (without controls for the total number of laps !)
% PV 2025

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

% sessions = data_folders_excl; % Martha's recordings
sessions = data_folders_deprivation; % Ben's recordings

% Order of the tracks : first line is exposure, second line is re-exposure
% track_list = repelem({[1 2; 3 4]}, 1, numel(sessions)); % For Marta's data

track_list = {[1 2; 3 4], ...
               [1 2; 4 3], ...
               [1 2; 4 3], ...
               [1 2; 3 4], ...
               [1 2; 4 3], ...
               [1 2; 4 3], ...
               [1 2; 4 3], ...
               [1 2; 3 4], ...
               [1 2; 4 3], ...
               [1 2; 4 3], ...
               [1 2; 4 3], ...
               [1 2; 4 3]}; % For Ben's data (manual)
           
 condition_list = ["no_rest", ...
                   "no_rest", ...
                   "no_sleep_15m", ...
                   "sleep_2h", ...
                   "sleep_15m", ...
                   "sleep_30s", ...
                   "pick_up", ...
                   "interval", ...
                   "barrier", ...
                   "pred_error", ...
                   "sleep_10s", ...
                   "barrier"];
               
animal_list = ["R908", "R908", "R908", "R908", ...
               "R913", "R913", "R913", "R913", ...
               "R913", "R913", "R913", "R913"];

% This removes sessions without pipeline ran
has_data = [1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0];
has_data = logical(has_data);

sessions = sessions(has_data);
track_list = track_list(has_data);
condition_list = condition_list(has_data);
animal_list = animal_list(has_data);

% Arrays to hold all the data
sessionID = [];
animal = [];
condition = [];
track_order = {};
track = [];
exposure = [];
lap = [];
pvCorr = [];
speed = [];

%% Extraction & computation

for fileID = 1:length(sessions)

    disp("Current session : " + fileID);
    file = sessions{fileID}; % We get the current session
    
%     % For MARTHA's data : fetch animal name + condition :
%     [animalOI, conditionOI] = parseNameFile(file);
%     animalOI = string(animalOI);
%     conditionOI = string(conditionOI); % We convert everything to string
%     cur_track_order = track_list{fileID};

    % For BEN's data : manual naming and condition
    animalOI = string(animal_list{fileID});
    conditionOI = string(condition_list{fileID});
    cur_track_order = track_list{fileID};
    
    % Load the needed variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;
    
    temp = load(file + "\extracted_position");
    position = temp.position;
    
    temp = load(file + "\extracted_laps");
    lap_times = temp.lap_times;

    % Iterate over each track
    
    for trackOI = 1:2
        
        % Get the index of the other track (1 -> 2, 2 -> 1)
        other_track = mod(trackOI + 1, 2) + 2*mod(trackOI, 2);

        % Good cells : Cells that where good place cells during RUN1 and RUN2
        % (no appearing / disappearing cells).
        goodCells = intersect(place_fields.track(trackOI).good_cells, ...
                              place_fields.track(trackOI + 2).good_cells);
                
        if numel(goodCells) < 10
            disp("Excluding (< 10 cells) : " + fileID);
            continue;
        end
        
        % We compute the final place field : 
        % For Marta's data : mean of the 6 laps following the
        % 16th lap of RUN2 (commented out)
        % For Ben's data : last lap of RUN2
        
        RUN1LapPFData = lap_place_fields(trackOI).Complete_Lap;
        RUN2LapPFData = lap_place_fields(trackOI + 2).Complete_Lap;
        numberLapsRUN2 = length(RUN2LapPFData);
        finalPlaceField = {};

%         For each cell, we create the final place field
%         for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
%             temp = [];
% 
%             for clap = 1:6
%                 temp = [temp; RUN2LapPFData{16 + clap}.smooth{cellID}];
%             end
% 
%             finalPlaceField(end + 1) = {mean(temp, 'omitnan')};
%         end
%         
%         If working with less laps (new data), just take the last
%         lap
        
        for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
            finalPlaceField(end + 1) = {RUN2LapPFData{end}.smooth{cellID}};
        end
        
        % Iterate over exposures (RUN1, RUN2)
        
        for exposureOI = 1:2
            
            % Get the "virtual track" (1, 2, 3, 4)
            vTrack = trackOI + 2*(exposureOI - 1); 
        
            current_numberLaps = numel(lap_place_fields(vTrack).Complete_Lap);

            if current_numberLaps > 16 % Crop the number of laps to 16
                current_numberLaps = 16;
            end
            
            % Iterate over laps
            for lapOI = 1:current_numberLaps
                
                % Find starting / end time to get the mean speed during
                % the trial ----
                lap_start = lap_times(vTrack).completeLaps_start(lapOI);
                lap_end = lap_times(vTrack).completeLaps_stop(lapOI);
                
                all_speed = position.v(position.t <= lap_end & position.t >= lap_start);
                all_speed(all_speed < 5) = [];
                mean_speed = mean(all_speed, 'omitnan');
                
                % Get the PV correlation between current lap and FPF
                % (make sure the folder "util" is in your PATH)
                
                current_lap_data = lap_place_fields(vTrack).Complete_Lap{lapOI};
                current_place_fields = current_lap_data.smooth;
                current_pvCorr = getPVCor(goodCells, current_place_fields, finalPlaceField, "pvCorrelation");                
                current_pvCorr = median(current_pvCorr, 'omitnan');
                                
                % Save the data
                
                sessionID = [sessionID; fileID];
                animal = [animal; animalOI];
                condition = [condition; conditionOI];
                track_order = [track_order; {cur_track_order}];
                track = [track; trackOI];
                exposure = [exposure; exposureOI];
                lap = [lap; lapOI];
                pvCorr = [pvCorr; current_pvCorr];
                speed = [speed; mean_speed];


            end
        end
    end
end

data = table(sessionID, animal, condition, track_order, track, exposure, lap, speed, pvCorr);

% save("../data/time_serie_main.mat", "data")

save("../data/time_serie_control.mat", "data")
