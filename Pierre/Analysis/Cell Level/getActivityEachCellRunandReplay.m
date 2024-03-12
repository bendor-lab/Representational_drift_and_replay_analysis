% Script to see the difference in firing rate / position of PF and
% other variables lap to lap

% Creates a file extracted_activity_mat_lap.mat

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

% Data stored in a table with : 
% Animal - Condition - Track - allLaps struct - cellsReplayData
% struct
% allLaps struct : lap - cellsData
% cellsData struct :
% cell - spike participation of cell during current track
% - participation to awake replay during current lap
% - is a good PC when classifing with current lap data
% - is a good PC when classifing with all the data
% - relative max firing rate in the smooth PF
% - position of the PF peak
% - center of mass of the PF

% cellsReplayData (separated from lap data to avoid redudancy) :
% cell - participation in PRE - RUN1 - RUN2 - POST1 - POST2
% - Replay events POST1 over time - Replay events POST2 over time

% Note : here, the replay participation is decoded with the current
% track

activity_mat_laps = struct("animal", {}, "condition", {}, ...
                       "track", {}, "allLaps", {}, "cellsReplayData", {});
                   
allLaps = struct("lap", {}, "cellsData", {});

                              
% We iterate through files
parfor cID = 1:numel(sessions)
    disp(cID);
    file = sessions{cID};
    
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    
    % We load the place fields computed per lap for each animal - lap_place_fields
    lap_place_fields = load(file + "\extracted_lap_place_fields");
    lap_place_fields = lap_place_fields.lap_place_fields;

    % And a general PF data to check if good cell on the whole track
    place_fields = load(file + "\extracted_place_fields");
    place_fields = place_fields.place_fields;
    
    % We get the pyramidal cells for this session (same everywhere)
    pyramCells = lap_place_fields(1).Complete_Lap{1}.pyramidal_cells;
    
    % We load the time / spike data we need for the participation
    % conputation
    
    % For online participation
    lap_times = load(file + "\extracted_laps"); % Import table lap_times
    lap_times = lap_times.lap_times;

    clusters = load(file + "\extracted_clusters"); % Import table clusters
    clusters = clusters.clusters;

    % For replay
    % We switch the files we use depending on the track, so we store everything in a struct

    dreRUN1 = load(file + "\Replay\RUN1_Decoding\decoded_replay_events"); % Import decoded_replay_events
    dreRUN1 = dreRUN1.decoded_replay_events;
    dreRUN2 = load(file + "\Replay\RUN2_Decoding\decoded_replay_events"); % Import decoded_replay_events
    dreRUN2 = dreRUN2.decoded_replay_events;
    
    dreStruct = struct("data", {dreRUN1, dreRUN2});

    sreRUN1 = load(file + "\Replay\RUN1_Decoding\significant_replay_events_wcorr"); % Import significant_replay_events
    sreRUN1 = sreRUN1.significant_replay_events;
    sreRUN2 = load(file + "\Replay\RUN2_Decoding\significant_replay_events_wcorr"); % Import significant_replay_events
    sreRUN2 = sreRUN2.significant_replay_events;

    sreStruct = struct("data", {sreRUN1, sreRUN2});

    sleep_state = load(file + "\extracted_sleep_state"); % Import sleep_state
    sleep_state = sleep_state.sleep_state;
    
    % We iterate over tracks
    for track = 1:4
        
        % We find the number of laps
        nbLaps = min([lap_times(track).number_completeLaps, length(lap_place_fields(track).Complete_Lap)]);
        
        % We create the struct to store the data per lap
        
        allLaps = struct("lap", {}, "cellsData", {});
                                
        % Check if the cell is a good PC on the track
        % Do this now to avoid repetition
        GoodPCCurrentTrack = place_fields.track(track).good_cells;
        isGoodPCCurrentTrack = ismember(pyramCells, GoodPCCurrentTrack);
        
        % We determine the good replay data based on track

        runNumber = ((track <= 2) + (track > 2)*2);

        significant_replay_events = sreStruct(runNumber).data;
        decoded_replay_events = dreStruct(runNumber).data;
        
        % We iterate through laps
        for lap = 1:nbLaps
            
            % We get the relevant data regarding place fields
            goodPFData = lap_place_fields(track).Complete_Lap{lap};
            
            placeField = goodPFData.smooth(pyramCells);
            % We get the participation vector for the current lap runned
            partRUN = getParticipationDuringLap(pyramCells, track, lap, lap_times, clusters);
            
            % Get the participation vector for awake replay events during
            % the lap
            
            partReplayCurrentLap = getParticipationReplayDuringLap(pyramCells, track, lap, lap_times, ...
                                                                   significant_replay_events, decoded_replay_events);
            
            % Check if the cells are good place cells in the current lap
 
            isGoodPCCurrentLap = repelem(0, length(pyramCells));
            % Find cells that are good place cells AND pyramidal cells
            pyramidalGoodCells = goodPFData.good_cells(ismember(goodPFData.good_cells, pyramCells));
            % Find the position of those cells in the bigger vector of
            % cells
            [~, goodPCPosition] = ismember(pyramidalGoodCells, pyramCells);
            isGoodPCCurrentLap(goodPCPosition) = 1; % Mark the cells as good
            
            % Get the Max Firing Rate
            smooth_PF = goodPFData.smooth(pyramCells);
            pfMaxFRate = cellfun(@(x) max(x), smooth_PF); % Don't forget to normalise (a - b)/(a + b) when difference
            pfMaxFRate(isnan(pfMaxFRate)) = 0;
            
            % Location of the maximum
            pfPeakPosition = cellfun(@(x, y) find(x == y, 1), smooth_PF, num2cell(pfMaxFRate), 'UniformOutput', false);
            pfPeakPosition(pfMaxFRate == 0) = {NaN};
            pfPeakPosition = cell2mat(pfPeakPosition);
            
            % Center of mass - smoothed
            pfCenterMass = goodPFData.centre_of_mass(pyramCells);

            % Information per spike 
            infoPerSpike = goodPFData.skaggs_info(pyramCells) ./ goodPFData.mean_rate(pyramCells);
            
            % We can add those to our struct
            
            temp = struct("cell", {pyramCells}, "placeField", {placeField}, "partRUN", {partRUN}, "partReplayCurrentLap", {partReplayCurrentLap}, ...
                    "isGoodPCCurrentLap", {isGoodPCCurrentLap}, "isGoodPCCurrentTrack", {isGoodPCCurrentTrack}, "pfMaxFRate", {pfMaxFRate}, ...
                    "pfPeakPosition", {pfPeakPosition}, "pfCenterMass", {pfCenterMass}, "infoPerSpike", {infoPerSpike});
            
            allLaps = [allLaps ; struct("lap", {lap}, "cellsData", {temp})];
            
        end
        
        % Now we can find the involvment of each pyramidal cell in replay
        % events 
        
        % Sleep replay participation - ONLY IN THE FIRST 30 MINUTES !
                      
        partPRE = getReplayParticipationDuringSleep(pyramCells, "PRE", track, sleep_state, ...
                                            significant_replay_events, decoded_replay_events);
                                        
        partPOST1 = getReplayParticipationDuringSleep(pyramCells, "POST1", track, sleep_state, ...
                                            significant_replay_events, decoded_replay_events);
                                        
        partPOST2 = getReplayParticipationDuringSleep(pyramCells, "POST2", track, sleep_state, ...
                                            significant_replay_events, decoded_replay_events);
        
        % Sleep replay participation over time
        % Will take the form of a list of start / end time_bins
        % To put in relation with event_times in significant_replay_events
        
        partPREoTime = getReplayParticipationOverTimeDuringSleep(pyramCells, "PRE", track, sleep_state, ...
                                            significant_replay_events, decoded_replay_events);
        partPOST1oTime = getReplayParticipationOverTimeDuringSleep(pyramCells, "POST1", track, sleep_state, ...
                                            significant_replay_events, decoded_replay_events);
        partPOST2oTime = getReplayParticipationOverTimeDuringSleep(pyramCells, "POST2", track, sleep_state, ...
                                            significant_replay_events, decoded_replay_events);
        
        % Awake replay participation during RUN1 / RUN2 OF CURRENT TRACK !
        
        % DEFINE RUN1 / RUN2 in function of track
        trackRUN1 = (~mod(track, 2))*2 + (mod(track, 2));
        trackRUN2 = trackRUN1 + 2;
        
        partRUN1 = getReplayParticipationDuringTrack(pyramCells, trackRUN1, track, lap_times, ...
            significant_replay_events, decoded_replay_events);
        
        partRUN2 = getReplayParticipationDuringTrack(pyramCells, trackRUN2, track, lap_times, ...
            significant_replay_events, decoded_replay_events);
        
        % We save the data in struct
        
        cellsReplayData = struct("cell", {pyramCells}, "partPRE", {partPRE}, "partRUN1", {partRUN1}, "partRUN2", {partRUN2}, ...
            "partPOST1", {partPOST1}, "partPOST2", {partPOST2}, "partPREoTime", {partPREoTime}, "partPOST1oTime", {partPOST1oTime}, "partPOST2oTime", {partPOST2oTime});
        
        % now we can save everything in our meta-struct
    
        activity_mat_laps = [activity_mat_laps ; struct("animal", {animalOI}, "condition", {conditionOI}, ...
                           "track", {track}, "allLaps", {allLaps}, "cellsReplayData", {cellsReplayData})];
    
    end
end

save(PATH.SCRIPT + "\..\..\Data\extracted_activity_mat_lap.mat", "activity_mat_laps");