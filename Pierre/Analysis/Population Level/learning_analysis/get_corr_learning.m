%% Script to get the pv-correlation from every lap with the last lap
% of RUN1 vs. the 16th lap of RUN2

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths

% We create identifiers for cells from each session.
% Format is : IDENT-00-XXX
identifiers = 1:numel(sessions);
identifiers = identifiers* 1000;

% Order of the tracks : first line is exposure, second line is re-exposure
% Note : EVEN IF order in control day 1 is T1 - T2 -> T2 - T1, the order 1
% 2 3 4 is the same as for the experimental condition (1 - 3 / 2 - 4 for exposure / re-exposure)

track_order = [1 2; 3 4];

% Arrays to hold all the data

sessionID = [];
animal = [];
condition = [];
track = [];
exposure = [];
lap = [];
pvCorr = [];
speed = [];

%% Extraction & computation

parfor fileID = 1:length(sessions)

    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    
    % Load the variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;
    
    temp = load(file + "\extracted_position");
    position = temp.position;
    
    temp = load(file + "\extracted_laps");
    lap_times = temp.lap_times;

    % Track loop

    for trackOI = 1:2
        
        disp(trackOI);

        other_track = mod(trackOI + 1, 2) + 2*mod(trackOI, 2);
        
        % Control : Cells that where good place cells during RUN1 and RUN2
        % (no appearing / disappearing cells).
        goodCells = intersect(place_fields.track(track_order(1, trackOI)).good_cells, place_fields.track(track_order(2, trackOI)).good_cells);
                                
        for exposureOI = 1:2
            
            vTrack = track_order(exposureOI, trackOI);
                
            % The place fields we are gonna compare to
            if trackOI == 1
                if numel(lap_place_fields(vTrack).Complete_Lap) >= 16
                    comparison = lap_place_fields(vTrack).Complete_Lap{16}.smooth;
                else % If less than 16 laps (e.g. 15, we pass)
                    continue;
                end
            else % if track 2
                if exposureOI == 1
                    comparison = lap_place_fields(vTrack).Complete_Lap{end}.smooth;
                else
                    comparison = lap_place_fields(vTrack).Complete_Lap{16}.smooth;
                end
            end
        
            current_numberLaps = numel(lap_place_fields(vTrack).Complete_Lap);

            if current_numberLaps > 16
                current_numberLaps = 16;
            end
            
            % We remove one lap for the template
            current_numberLaps = current_numberLaps - 1;
            
            if current_numberLaps == 0
                continue;
            end

            for lapOI = 1:current_numberLaps
                
                lap_start = lap_times(vTrack).completeLaps_start(lapOI);
                lap_end = lap_times(vTrack).completeLaps_stop(lapOI);
                
                all_speed = position.v(position.t <= lap_end & position.t >= lap_start);
                all_speed(all_speed < 5) = [];
                mean_speed = mean(all_speed, 'omitnan');
                
                current_lap_data = lap_place_fields(vTrack).Complete_Lap{lapOI};
                current_place_fields = current_lap_data.smooth;

                current_pvCorr = getPVCor(goodCells, current_place_fields, comparison, "pvCorrelation");
                current_pvCorr = median(current_pvCorr, 'omitnan');
                                
                % Save the data
                
                sessionID = [sessionID; fileID];
                animal = [animal; animalOI];
                condition = [condition; conditionOI];
                track = [track; trackOI];
                exposure = [exposure; exposureOI];
                lap = [lap; lapOI];
                pvCorr = [pvCorr; current_pvCorr];
                speed = [speed; mean_speed];


            end
        end
    end
end



% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

data = table(sessionID, animal, condition, exposure, lap, speed, pvCorr);

save("data_learning.mat", "data")