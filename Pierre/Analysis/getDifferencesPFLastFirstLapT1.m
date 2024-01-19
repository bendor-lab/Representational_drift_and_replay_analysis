% Script to see the difference in firing rate and position between PF in
% the first and the last lap of the run
% Currently only for 16 laps

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

% Data stored in a table with : 
% Animal - Condition - Day - Cell - Participation RUN1 Lap 1 -
% Participation RUN1 Lap End - Participation RUN2 Lap 1 -
% Participation RUN2 Lap End - 
% - Participation Replay Events RUN1 - Participation Replay Events RUN2 - 
% Participation Replay Events POST1 - Participation Replay Events POST2
% Max Firing Rate PF RUN1 Lap1 - Max Firing Rate PF RUN1 Lap End
% Max Firing Rate PF RUN2 Lap1 - Max Firing Rate PF RUN2 Lap End
% Position PF RUN1 Lap1 - Position PF RUN1 Lap End
% Position PF RUN2 Lap1 - Position PF RUN2 Lap End

actMat1stLast = struct("animal", {}, "condition", {}, "day", {}, ...
                                  "cell", {}, "part_RUN1Lap1", {}, "part_RUN1LapEnd", {}, ... 
                                  "part_RUN2Lap1", {}, "part_RUN2LapEnd", {}, "part_ReplayRUN1", {}, ...
                                  "part_ReplayRUN2", {}, "part_ReplayPOST1", {}, "part_ReplayPOST2", {}, ...
                                  "IsGoodPC_RUN1Lap1", {}, "IsGoodPC_RUN1LapEnd", {}, ...
                                  "IsGoodPC_RUN2Lap1", {}, "IsGoodPC_RUN2LapEnd", {}, ...
                                  "IsGoodPC_RUN1ALL", {}, "IsGoodPC_RUN2ALL", {}, ...
                                  "PF_MaxFRateRUN1Lap1", {}, "PF_MaxFRateRUN1LapEnd", {}, ...
                                  "PF_MaxFRateRUN2Lap1", {}, "PF_MaxFRateRUN2LapEnd", {}, ...
                                  "PF_PositionRUN1Lap1", {}, "PF_PositionRUN1LapEnd", {}, ...
                                  "PF_PositionRUN2Lap1", {}, "PF_PositionRUN2LapEnd", {});

                              
% We iterate through files
for cfile = sessions
    disp(cfile);
    file = cfile{1};
    
    [animalOI, conditionOI, dayOI] = parseNameFile(file); % We get the informations about the current data
    
    % We load the place fields computed per lap for each animal - lap_place_fields
    load(file + "\extracted_lap_place_fields");
    
    % We're interested in Track 1 / 3 for the moment - only the first and
    % last lap
    
    FirstLapT1 = lap_place_fields(1).Complete_Lap{1};
    LastLapT1 = lap_place_fields(1).Complete_Lap{end};
    nbLapsT1 = length(lap_place_fields(1).Complete_Lap);
    
    FirstLapT3 = lap_place_fields(3).Complete_Lap{1};
    LastLapT3 = lap_place_fields(3).Complete_Lap{end};
    nbLapsT3 = length(lap_place_fields(3).Complete_Lap);
    
    % We get the number of pyramidal cells for this session
    
    pyramCells = FirstLapT1.pyramidal_cells;
    
    % We load the time / spike data we need for the participation
    % conputation
    
    % For online participation
    load(file + "\extracted_laps"); % Import table lap_times
    load(file + "\extracted_clusters"); % Import table clusters
    % For replay
    load(file + "\decoded_replay_events"); % Import decoded_replay_events
    load(file + "\significant_replay_events"); % Import significant_replay_events
    load(file + "\extracted_sleep_state"); % Import sleep_state
   
    %% We get the participation vector for :
    
    % RUN1 - Lap 1
    partVecRUN1Lap1 = getParticipationDuringLap(pyramCells, 1, 1, lap_times, clusters);
    % RUN1 - Lap End
    partVecRUN1LapEnd = getParticipationDuringLap(pyramCells, 1, nbLapsT1, lap_times, clusters);
    % RUN2 - Lap 1
    partVecRUN2Lap1 = getParticipationDuringLap(pyramCells, 3, 1, lap_times, clusters);
    % RUN2 - Lap End
    partVecRUN2LapEnd = getParticipationDuringLap(pyramCells, 3, nbLapsT3, lap_times, clusters);
    
    % Awake Replay - RUN1
    partRepRUN1 = getReplayParticipationDuringTrack(pyramCells, 1, 1, lap_times, ...
                                                    significant_replay_events, decoded_replay_events);
    % Awake Replay - RUN2
    partRepRUN2 = getReplayParticipationDuringTrack(pyramCells, 3, 3, lap_times, ...
                                                    significant_replay_events, decoded_replay_events);
    
    % Sleep Replay - POST1
    partRepPOST1 = getReplayParticipationDuringSleep(pyramCells, "POST1", 1, sleep_state, ...
                                                     significant_replay_events, decoded_replay_events);
    % Sleep Replay - POST2
    partRepPOST2 = getReplayParticipationDuringSleep(pyramCells, "POST2", 3, sleep_state, ...
                                                     significant_replay_events, decoded_replay_events);
                                                 
    %% We get the place fields properties
    
    % RUN1 - Lap 1
    GoodPCData = lap_place_fields(1).Complete_Lap{1};
    % Is Good Cell ?
    IsGoodPC_RUN1Lap1 = repelem(0, length(pyramCells));
    pyramidalGoodCells = GoodPCData.good_cells(ismember(GoodPCData.good_cells, pyramCells));
    [~, goodPCPosition] = ismember(pyramidalGoodCells, pyramCells);
    IsGoodPC_RUN1Lap1(goodPCPosition) = 1; % Mark the cells as good
    % Max Firing Rate
    raw_PF = GoodPCData.raw(pyramCells);
    PF_MaxFRateRUN1Lap1 = cellfun(@max, raw_PF);
    % Location of the maximum
    PF_PositionRUN1Lap1 = cellfun(@(x) find(x == max(x), 1), raw_PF, 'UniformOutput', false);
    
    % RUN1 - Lap End
    GoodPCData = lap_place_fields(1).Complete_Lap{end};
    % Is Good Cell ?
    IsGoodPC_RUN1LapEnd = repelem(0, length(pyramCells));
    pyramidalGoodCells = GoodPCData.good_cells(ismember(GoodPCData.good_cells, pyramCells));
    [~, goodPCPosition] = ismember(pyramidalGoodCells, pyramCells);
    IsGoodPC_RUN1LapEnd(goodPCPosition) = 1; % Mark the cells as good
    % Max Firing Rate
    raw_PF = GoodPCData.raw(pyramCells);
    PF_MaxFRateRUN1LapEnd = cellfun(@max, raw_PF);
    % Location of the maximum
    PF_PositionRUN1LapEnd = cellfun(@(x) find(x == max(x), 1), raw_PF, 'UniformOutput', false);
    
    % RUN2 - Lap 1
    GoodPCData = lap_place_fields(3).Complete_Lap{1};
    % Is Good Cell ?
    IsGoodPC_RUN2Lap1 = repelem(0, length(pyramCells));
    pyramidalGoodCells = GoodPCData.good_cells(ismember(GoodPCData.good_cells, pyramCells));
    [~, goodPCPosition] = ismember(pyramidalGoodCells, pyramCells);
    IsGoodPC_RUN2Lap1(goodPCPosition) = 1; % Mark the cells as good
    % Max Firing Rate
    raw_PF = GoodPCData.raw(pyramCells);
    PF_MaxFRateRUN2Lap1 = cellfun(@max, raw_PF);
    % Location of the maximum
    PF_PositionRUN2Lap1 = cellfun(@(x) find(x == max(x), 1), raw_PF, 'UniformOutput', false);
    
    % RUN2 - Lap End
    GoodPCData = lap_place_fields(1).Complete_Lap{1};
    % Is Good Cell ?
    IsGoodPC_RUN2LapEnd = repelem(0, length(pyramCells));
    pyramidalGoodCells = GoodPCData.good_cells(ismember(GoodPCData.good_cells, pyramCells));
    [~, goodPCPosition] = ismember(pyramidalGoodCells, pyramCells);
    IsGoodPC_RUN2LapEnd(goodPCPosition) = 1; % Mark the cells as good
    % Max Firing Rate
    raw_PF = GoodPCData.raw(pyramCells);
    PF_MaxFRateRUN2LapEnd = cellfun(@max, raw_PF);
    % Location of the maximum
    PF_PositionRUN2LapEnd = cellfun(@(x) find(x == max(x), 1), raw_PF, 'UniformOutput', false);
    
    % Supplementary data : is it a good cell, regarding all laps
    
    load(file + "\extracted_place_fields")
    
    % RUN1
    IsGoodPC_RUN1ALL = repelem(0, length(pyramCells));
    allGoodCells = place_fields.track(1).good_cells;
    pyramidalGoodCells = allGoodCells(ismember(allGoodCells, pyramCells));
    [~, goodPCPosition] = ismember(pyramidalGoodCells, pyramCells);
    IsGoodPC_RUN1ALL(goodPCPosition) = 1; % Mark the cells as good
    
    % RUN2
    IsGoodPC_RUN2ALL = repelem(0, length(pyramCells));
    allGoodCells = place_fields.track(3).good_cells;
    pyramidalGoodCells = allGoodCells(ismember(allGoodCells, pyramCells));
    [~, goodPCPosition] = ismember(pyramidalGoodCells, pyramCells);
    IsGoodPC_RUN2ALL(goodPCPosition) = 1; % Mark the cells as good
    
    
                                                
    %% We populate the table - if it's empty, from index 1, otherwise,
    % from the length of the array
    
    startIndex = ~isempty(actMat1stLast) * length(actMat1stLast);
    qtyToAdd = length(pyramCells);
    
    % We iterate though cells
    for i = 1:qtyToAdd
        
        realIndex = startIndex + i;
        
        % Adding basic information
        actMat1stLast(realIndex).animal = animalOI;
        actMat1stLast(realIndex).condition = conditionOI;
        actMat1stLast(realIndex).day = dayOI;
        actMat1stLast(realIndex).cell = pyramCells(i);
        actMat1stLast(realIndex).part_RUN1Lap1 = partVecRUN1Lap1(i);
        actMat1stLast(realIndex).part_RUN1LapEnd = partVecRUN1LapEnd(i);
        actMat1stLast(realIndex).part_RUN2Lap1 = partVecRUN2Lap1(i);
        actMat1stLast(realIndex).part_RUN2LapEnd = partVecRUN2LapEnd(i);
        actMat1stLast(realIndex).part_ReplayRUN1 = partRepRUN1(i);
        actMat1stLast(realIndex).part_ReplayRUN2 = partRepRUN2(i);
        actMat1stLast(realIndex).part_ReplayPOST1 = partRepPOST1(i);
        actMat1stLast(realIndex).part_ReplayPOST2 = partRepPOST2(i);
        actMat1stLast(realIndex).IsGoodPC_RUN1Lap1 = IsGoodPC_RUN1Lap1(i);
        actMat1stLast(realIndex).IsGoodPC_RUN1LapEnd = IsGoodPC_RUN1LapEnd(i);
        actMat1stLast(realIndex).IsGoodPC_RUN2Lap1 = IsGoodPC_RUN2Lap1(i);
        actMat1stLast(realIndex).IsGoodPC_RUN2LapEnd = IsGoodPC_RUN2LapEnd(i);
        actMat1stLast(realIndex).IsGoodPC_RUN1ALL = IsGoodPC_RUN1ALL(i);
        actMat1stLast(realIndex).IsGoodPC_RUN2ALL = IsGoodPC_RUN2ALL(i);
        actMat1stLast(realIndex).PF_MaxFRateRUN1Lap1 = PF_MaxFRateRUN1Lap1(i);
        actMat1stLast(realIndex).PF_MaxFRateRUN1LapEnd = PF_MaxFRateRUN1LapEnd(i);
        actMat1stLast(realIndex).PF_MaxFRateRUN2Lap1 = PF_MaxFRateRUN2Lap1(i);
        actMat1stLast(realIndex).PF_MaxFRateRUN2LapEnd = PF_MaxFRateRUN2LapEnd(i);
        actMat1stLast(realIndex).PF_PositionRUN1Lap1 = PF_PositionRUN1Lap1{i};
        actMat1stLast(realIndex).PF_PositionRUN1LapEnd = PF_PositionRUN1LapEnd{i};
        actMat1stLast(realIndex).PF_PositionRUN2Lap1 = PF_PositionRUN2Lap1{i};
        actMat1stLast(realIndex).PF_PositionRUN2LapEnd = PF_PositionRUN2LapEnd{i};
        
    end   
end

actMat1stLastT1 = actMat1stLast;

save(PATH.SCRIPT + "\..\Data\actMat1stLast_T1.mat", "actMat1stLastT1");