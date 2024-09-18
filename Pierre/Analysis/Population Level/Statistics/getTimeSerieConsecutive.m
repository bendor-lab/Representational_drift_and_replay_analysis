% File to generate the metric data over laps

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths

% We create identifiers for cells from each session.
% Format is : IDENT-00-XXX
identifiers = 1:numel(sessions);
identifiers = identifiers* 1000;

% Arrays to hold all the data

sessionID = [];
animal = [];
condition = [];
track = [];
exposure = [];
lap = [];
pvCorr = [];

% We take the absolute value of the difference over sum to get the relative
% distance with the FPF, independently of the direction
diffSum = @(x1, x2) abs(x1 - x2)/(x1 + x2);

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
    %
    %     temp = load(file + "\extracted_directional_lap_place_fields");
    %     lap_directional_place_fields = temp.lap_directional_place_fields;
    
    temp = load(file + "\extracted_position");
    position = temp.position;
    
    temp = load(file + "\extracted_laps");
    lap_times = temp.lap_times;
    
    % Track loop
    
    for trackOI = 1:2
                
        other_track = mod(trackOI + 1, 2) + 2*mod(trackOI, 2);
        
        % Good cells : Cells that where good place cells during RUN1 or RUN2
        % goodCells = union(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);
        
        % Control : Cells that where good place cells during RUN1 and RUN2
        % (no appearing / disappearing cells).
        goodCells = intersect(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);
        % goodCells = place_fields.interneurons;
        
        % Control : Cells that were good place cells during RUN1 xor RUN2
        % (only appearing / disappearing cells).
        % goodCells = setxor(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);
        
        % goodCells = setdiff(place_fields.track(trackOI + 2).good_cells, ...
        %                     place_fields.track(trackOI).good_cells);
        
        if numel(goodCells) == 1
            continue;
        end
        
        % We get the final place field : mean of the 6 laps following the
        % 16th lap of RUN2
        
        RUN1LapPFData = lap_place_fields(trackOI).Complete_Lap;
        RUN2LapPFData = lap_place_fields(trackOI + 2).Complete_Lap;
        
        numberLapsRUN2 = length(RUN2LapPFData);
        
        for exposureOI = 1:2
            
            vTrack = trackOI + mod(exposureOI + 1, 2)*2;
            
            current_numberLaps = numel(lap_place_fields(vTrack).Complete_Lap);
            
%             if current_numberLaps > 16
%                 current_numberLaps = 16;
%             end
            
            if current_numberLaps == 1
                continue;
            end
            
            for lapOI = 2:current_numberLaps
                
                lap_start = lap_times(vTrack).completeLaps_start(lapOI);
                lap_end = lap_times(vTrack).completeLaps_stop(lapOI);
                                
                current_lap_data = lap_place_fields(vTrack).Complete_Lap{lapOI};
                current_place_fields = current_lap_data.smooth;
                
                previous_place_fields = lap_place_fields(vTrack).Complete_Lap{lapOI-1}.smooth;
                                
                current_pvCorr = getPVCor(goodCells, current_place_fields, ...
                                          previous_place_fields, "pvCorrelation");
                
                current_pvCorr = median(current_pvCorr, 'omitnan');
                
                % Save the data
                
                sessionID = [sessionID; fileID];
                animal = [animal; animalOI];
                condition = [condition; conditionOI];
                track = [track; trackOI];
                exposure = [exposure; exposureOI];
                lap = [lap; lapOI];
                pvCorr = [pvCorr; current_pvCorr];
                
                
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

data = table(sessionID, animal, condition, exposure, lap, pvCorr);

save("consecutive_analysis/timeSeries_consecutive", "data")