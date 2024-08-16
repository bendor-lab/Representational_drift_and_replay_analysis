% File to generate the fluctuations of PV correlation
% over laps, and the time during laps vs. number of awake replay
% vs. number of SWR

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths
sessions_legacy = data_folders_excl_legacy;
% Arrays to hold all the data

sessionID = [];
animal = [];
condition = [];
track = [];
exposure = [];
lap = [];
direction = []; % Direction of current lap
pvCorr = [];
idlePeriod = []; % Time of idle after the lap
idleSWR = []; % Number of SWR after the lap
thetaCycles = []; % Number of theta cycles during lap

idleReplay = []; % Number of replay after the lap
ReplayDir = []; % Mean direction of the replays

totalTime = [];
runningTime = [];


% Extraction & computation

parfor fileID = 1:length(sessions)
    
    disp(fileID);
    file = sessions{fileID}; % We get the current session
    file_legacy = sessions_legacy{fileID};
    
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    
    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    
    % Load the variables
    
    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;
    
    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;
    
    temp = load(file + "\extracted_laps");
    lap_times = temp.lap_times;
    
    temp = load(file + "\Replay\RUN1_Decoding\significant_replay_events_wcorr");
    significant_replay_events_R1 = temp.significant_replay_events;
    
    temp = load(file + "\Replay\RUN1_Decoding\significant_replay_events_wcorr");
    significant_replay_events_R2 = temp.significant_replay_events;
    
    temp = load(file + "\REM\theta_peak_trough");
    theta_peaks = temp.theta_peaks;
    
    temp = load(file + "\extracted_position");
    position = temp.position;
    
    temp = load(file_legacy + "/extracted_directional_place_fields_BAYESIAN");
    directional_place_fields_BAYESIAN = temp.directional_place_fields_BAYESIAN;
    
    temp = load(file + "/extracted_replay_events");
    replay = temp.replay;
        
    temp = load(file + "/extracted_clusters");
    clusters = temp.clusters;
        
    % Track loop
    for trackOI = 1:2
        
        other_track = mod(trackOI + 1, 2) + 2*mod(trackOI, 2);
        
        % Control : Cells that where good place cells during RUN1 and RUN2
        % (no appearing / disappearing cells).
        goodCells = intersect(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);
        
        % We get the final place field : mean of the 6 laps following the
        % 16th lap of RUN2
        
        RUN1LapPFData = lap_place_fields(trackOI).half_Lap;
        RUN2LapPFData = lap_place_fields(trackOI + 2).half_Lap;
        
        numberLapsRUN2 = length(RUN2LapPFData);
        
        % Find the direction during the different laps
        startDirRUN1 = lap_times(trackOI).initial_dir;
        directionRUN1 = (-1).^(1:numel(RUN1LapPFData)) * (-startDirRUN1);
        
        startDirRUN2 = lap_times(trackOI + 2).initial_dir;
        directionRUN2 = (-1).^(1:numel(RUN2LapPFData)) * (-startDirRUN1);
        
        finalPlaceFieldD1 = {};
        finalPlaceFieldD2 = {};
        
        % For each cell, we create the final place field
        for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
            tempD1 = [];
            tempD2 = [];
            
            for clap = 1:11
                index_to_get = 32 + clap;
                if directionRUN2(index_to_get) == -1
                    tempD1 = [tempD1; RUN2LapPFData{index_to_get}.smooth{cellID}];
                else
                    tempD2 = [tempD2; RUN2LapPFData{index_to_get}.smooth{cellID}];
                end
            end
            
            finalPlaceFieldD1(end + 1) = {mean(tempD1, 'omitnan')};
            finalPlaceFieldD2(end + 1) = {mean(tempD2, 'omitnan')};
        end
        
        % Main loop across exposures
        for exposureOI = 1:2
            
            if exposureOI == 1
                replay_file = significant_replay_events_R1;
                current_directions = directionRUN1;
            else
                replay_file = significant_replay_events_R2;
                current_directions = directionRUN2;
            end
            
            vTrack = trackOI + mod(exposureOI + 1, 2)*2;
            current_numberLaps = numel(lap_place_fields(vTrack).half_Lap);
            
            first_lap_time = lap_times(vTrack).halfLaps_start(1);
            
            % We find all the end zones
            end_zones = get_matching_endzones(lap_times, vTrack);
            
            if current_numberLaps > 32
                current_numberLaps = 32;
            end
            
            % Iterate through half laps
            for lapOI = 1:current_numberLaps
                
                if current_directions(lapOI) == -1
                    fpfN = finalPlaceFieldD1;
                else
                    fpfN = finalPlaceFieldD2;
                end
                
                place_fields_N = lap_place_fields(vTrack).half_Lap{lapOI}.smooth;
                
                pvCorr_N = getPVCor(goodCells, place_fields_N, fpfN, "pvCorrelation");
                pvCorr_N = median(pvCorr_N, 'omitnan');
                
                % We find the amount of awake replay / SWR / time between
                % the two laps
                
                % We get the end zone for l and l+1
                
                startIdle = end_zones.startIdle(lapOI);
                endIdle = end_zones.stopIdle(lapOI);
                
                idleDuration = endIdle - startIdle;
                
                % Now that we have the start and end of the idle, we can
                % look for SWR and awake replay events in that window
                
                SWR_times = replay_file.all_event_times;
                replay_times = replay_file.track(trackOI).event_times;
                
                number_idle_SWR = sum(SWR_times >= startIdle & ...
                    SWR_times <= endIdle);
                
                [all_replay_idle, ~] = get_replay_lap(file, vTrack, ...
                                trackOI, exposureOI, lapOI, end_zones, ...
                                directional_place_fields_BAYESIAN, ...
                                replay, lap_times, clusters, replay_file);
                            
                replay_direction_bias = mean(all_replay_idle, "omitnan");
                if isnan(replay_direction_bias) 
                    replay_direction_bias = 0.5; % No bias in any direction
                end
                
                curr_numb_replay = numel(all_replay_idle);
                
                % Number of theta cycles during RUN
                start_lap = lap_times(vTrack).halfLaps_start(lapOI);
                stop_lap = lap_times(vTrack).halfLaps_stop(lapOI);
                
                number_theta_peaks = sum(theta_peaks(:, 4) >= start_lap & ...
                    theta_peaks(:, 4) <= startIdle);
                
                % Total time since start
                
                cur_total_time = endIdle - first_lap_time;
                cur_running_time = sum(position.v_cm(position.t ...
                    <= stop_lap & position.t > start_lap) ...
                    >= 5)*0.04;
                
                % Save the data
                
                sessionID = [sessionID; fileID];
                animal = [animal; animalOI];
                condition = [condition; conditionOI];
                track = [track; trackOI];
                exposure = [exposure; exposureOI];
                lap = [lap; lapOI];
                direction = [direction; current_directions(lapOI)];
                pvCorr = [pvCorr; pvCorr_N];
                idlePeriod = [idlePeriod; idleDuration];
                idleSWR = [idleSWR; number_idle_SWR];
                idleReplay = [idleReplay; curr_numb_replay];
                ReplayDir = [ReplayDir; replay_direction_bias];
                thetaCycles = [thetaCycles; number_theta_peaks];
                totalTime = [totalTime; cur_total_time];
                runningTime = [runningTime; cur_running_time];
                
                
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

data = table(sessionID, animal, condition, exposure, lap, direction, pvCorr, ...
    idlePeriod, idleSWR, idleReplay, ReplayDir, thetaCycles, totalTime, runningTime);

save("pv_correlation_fluc.mat", "data")