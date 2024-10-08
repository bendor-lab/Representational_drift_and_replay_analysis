% File to generate the fluctuations of stabilisation
% over laps, and the time during laps vs. number of awake replay
% vs. number of SWR PER CELL

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths
sessions_legacy = data_folders_excl_legacy;

% Arrays to hold all the data

sessionID = [];
animal = [];
condition = [];
cell = [];
track = [];
exposure = [];
lap = [];
direction = []; % Direction of current (half) lap

deltaFR = []; % Difference in the max FR with the FPF
deltaCM = []; % Difference in the CM with the FPF

spikesIdle = []; % Number of spikes during the idle period
spikesRUN = []; % Number of spikes during running
idleSWR = []; % Number of participations in SWR after the lap
thetaCycles = []; % Number of theta cycles during lap
idleReplay = []; % Number of participation in replay after the lap
ReplayDir = []; % Mean direction of replay

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
    
    temp = load(file + "\extracted_position");
    position = temp.position;
    
    temp = load(file + "\Replay\RUN1_Decoding\decoded_replay_events");
    decoded_replay_events_R1 = temp.decoded_replay_events;
    
    temp = load(file + "\Replay\RUN2_Decoding\decoded_replay_events");
    decoded_replay_events_R2 = temp.decoded_replay_events;
    
    temp = load(file + "\Replay\RUN1_Decoding\significant_replay_events_wcorr");
    significant_replay_events_R1 = temp.significant_replay_events;
    
    temp = load(file + "\Replay\RUN2_Decoding\significant_replay_events_wcorr");
    significant_replay_events_R2 = temp.significant_replay_events;
    
    temp = load(file + "\extracted_clusters");
    clusters = temp.clusters;
    
    temp = load(file_legacy + "/extracted_directional_place_fields_BAYESIAN");
    directional_place_fields_BAYESIAN = temp.directional_place_fields_BAYESIAN;
    
    temp = load(file + "/extracted_replay_events");
    replay = temp.replay;
    
    
    % Track loop
    
    for trackOI = 1:2
        
        other_track = mod(trackOI + 1, 2) + 2*mod(trackOI, 2);
        
        % Control : Cells that where good place cells during RUN1 and RUN2
        % (no appearing / disappearing cells).
        goodCells = intersect(place_fields.track(trackOI).good_cells, ...
            place_fields.track(trackOI + 2).good_cells);
        
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
        
        % We get the metrics for the FPF
        CMD1 = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), finalPlaceFieldD1);
        CMD2 = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), finalPlaceFieldD2);
        
        maxFRD1 = cellfun(@max, finalPlaceFieldD1);
        maxFRD2 = cellfun(@max, finalPlaceFieldD2);
        
        maxFRD1(isnan(CMD1)) = NaN;
        maxFRD2(isnan(CMD2)) = NaN; % We NaN the FR if the cell is gonna go silent
        
        % Main loop across exposures
        for exposureOI = 1:2
            
            if exposureOI == 1
                replay_file = significant_replay_events_R1;
                decoded_replay = decoded_replay_events_R1(trackOI).replay_events;
                current_directions = directionRUN1;
            else
                replay_file = significant_replay_events_R2;
                decoded_replay = decoded_replay_events_R2(trackOI).replay_events;
                current_directions = directionRUN2;
            end
            
            vTrack = trackOI + mod(exposureOI + 1, 2)*2;
            current_numberLaps = numel(lap_place_fields(vTrack).half_Lap);
            
            % We find all the end zones
            end_zones = get_matching_endzones(lap_times, vTrack);
            
            swr_timebins = cellfun(@(x) x(1), {decoded_replay.timebins_edges});
            swr_spikes = {decoded_replay.spikes};
            replay_timebins = replay_file.track(trackOI).event_times;
            replay_spikes = replay_file.track(trackOI).spikes;
            
            if current_numberLaps > 32
                current_numberLaps = 32;
            end
            
            % Iterate through half laps
            for lapOI = 1:current_numberLaps
                
                if current_directions(lapOI) == -1
                    fpfN = finalPlaceFieldD1;
                    fpfCM = CMD1;
                    fpfFR = maxFRD1;
                else
                    fpfN = finalPlaceFieldD2;
                    fpfCM = CMD2;
                    fpfFR = maxFRD2;
                end
                
                % Stability metrics
                
                place_fields_N = lap_place_fields(vTrack).half_Lap{lapOI}.smooth;
                
                current_CM = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), place_fields_N);
                current_maxFR = cellfun(@max, place_fields_N);
                
                current_deltaCM = abs(current_CM - fpfCM);
                current_deltaFR = abs(current_maxFR - fpfFR)./...
                    abs(current_maxFR + fpfFR);
                
                % We filter to get only the good cells
                current_deltaCM = current_deltaCM(goodCells);
                current_deltaFR = current_deltaFR(goodCells);
                
                % We find the amount of awake replay / SWR / time between
                % the two laps
                
                % We get the end zone for l and l+1
                
                startIdle = end_zones.startIdle(lapOI);
                endIdle = end_zones.stopIdle(lapOI);
                
                % Now that we have the start and end of the idle, we can
                % look for SWR and awake replay events in that window
                
                % SWR ---
                SWR_count = zeros(1, numel(goodCells));
                valid_events = (swr_timebins >= startIdle) & ...
                    (swr_timebins <= endIdle);
                SWR_good_spikes = swr_spikes(valid_events);
                
                for ev = 1:numel(SWR_good_spikes)
                    all_participating_cells = unique(SWR_good_spikes{ev}(:, 1));
                    matching_cells = ismember(goodCells, all_participating_cells);
                    SWR_count = SWR_count + matching_cells;
                end
                
                % Replay ---
                
                replay_count = zeros(1, numel(goodCells));
                mean_replay_direction = zeros(1, numel(goodCells));
                
                [all_replay_idle, valid_events] = get_replay_lap(file, vTrack, ...
                    trackOI, exposureOI, lapOI, end_zones, ...
                    directional_place_fields_BAYESIAN, ...
                    replay, lap_times, clusters, replay_file);
                
                replay_good_spikes = replay_spikes(ismember(...
                    replay_file.track(trackOI).ref_index, ...
                    valid_events));
                
                for ev = 1:numel(replay_good_spikes)
                    all_participating_cells = unique(replay_good_spikes{ev}(:, 1));
                    matching_cells = ismember(goodCells, all_participating_cells);
                    
                    replay_count = replay_count + matching_cells;
                    mean_replay_direction = mean_replay_direction + ...
                                        matching_cells*all_replay_idle(ev);
                end
                
                mean_replay_direction = mean_replay_direction./replay_count;
                
                % Number of spikes during running and during idle
                
                start_lap = lap_times(vTrack).halfLaps_start(lapOI);
                stop_lap = lap_times(vTrack).halfLaps_stop(lapOI);
                
                allTimes = position.t((position.t >= start_lap) & ...
                    (position.t <= stop_lap));
                
                allSpeed = position.v_cm((position.t >= start_lap) & ...
                    (position.t <= stop_lap));
                
                running_count = zeros(1, numel(goodCells));
                
                for cID = 1:numel(goodCells)
                    subset_times = clusters.spike_times(clusters.spike_id == goodCells(cID));
                    binned_spikes = histcounts(subset_times, [allTimes allTimes(end) + 0.04]);
                    binned_spikes(allSpeed <= 5) = 0; % Need to run
                    running_count(cID) = sum(binned_spikes);
                end
                
                allTimesIdle = position.t((position.t >= startIdle) & ...
                    (position.t <= endIdle));
                
                allSpeedIdle = position.v_cm((position.t >= startIdle) & ...
                    (position.t <= endIdle));
                
                idle_count = zeros(1, numel(goodCells));
                
                for cID = 1:numel(goodCells)
                    subset_times = clusters.spike_times(clusters.spike_id == goodCells(cID));
                    binned_spikes = histcounts(subset_times, [allTimesIdle allTimesIdle(end) + 0.04]);
                    binned_spikes(allSpeedIdle > 5) = 0; % Need to be idle
                    idle_count(cID) = sum(binned_spikes);
                end
                
                nbCells = numel(goodCells);
                
                % Save the data
                
                sessionID = [sessionID; repelem(fileID, nbCells)'];
                animal = [animal; repelem(animalOI, nbCells)'];
                condition = [condition; repelem(conditionOI, nbCells)'];
                cell = [cell; goodCells'];
                track = [track; repelem(trackOI, nbCells)'];
                exposure = [exposure; repelem(exposureOI, nbCells)'];
                lap = [lap; repelem(lapOI, nbCells)'];
                direction = [direction; repelem(current_directions(lapOI), nbCells)'];
                
                deltaFR = [deltaFR; current_deltaFR'];
                deltaCM = [deltaCM; current_deltaCM'];
                
                spikesIdle = [spikesIdle; idle_count'];
                spikesRUN = [spikesRUN; running_count'];
                idleSWR = [idleSWR; SWR_count'];
                
                idleReplay = [idleReplay; replay_count'];
                ReplayDir = [ReplayDir; mean_replay_direction'];
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

data = table(sessionID, animal, condition, cell, exposure, lap, direction, ...
    deltaFR, deltaCM, spikesIdle, spikesRUN, idleSWR, idleReplay, ...
    ReplayDir);

save("stabilisation_fluc.mat", "data")