
clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

load(PATH.SCRIPT + "/../../Data/population_vector_laps.mat");

allAnimals = unique(string({population_vector_laps.animal}));
allConditions = unique(string({population_vector_laps.condition}));

sessions = data_folders_excl; % Use the function to get all the file paths
corrVector = [];
replayEventsVector = [];
condition = [];
animal = [];
day = [];
track = [];

for i = 1:length(sessions)
    
    disp(i);
    
    file = sessions{i};
    
    [animalOI, conditionOI, dayOI] = parseNameFile(file); % We get the informations about the current data

    if conditionOI == "16x1" % We need at least two laps for this analysis
        continue;
    end
    
    %% We get the PV for LEnd-1RUN1, LEndRUN1 and L1RUN2
    PV_RUN1T1REF = extractPopulationVector(animalOI, conditionOI, 1, "beforeLast", "norm");
    PV_RUN1T2REF = extractPopulationVector(animalOI, conditionOI, 2, "beforeLast", "norm");
    
    PV_RUN1T1 = extractPopulationVector(animalOI, conditionOI, 1, "last", "norm");
    PV_RUN2T1 = extractPopulationVector(animalOI, conditionOI, 3, 3, "norm");
    
    PV_RUN1T2 = extractPopulationVector(animalOI, conditionOI, 2, "last", "norm");
    PV_RUN2T2 = extractPopulationVector(animalOI, conditionOI, 4, 3, "norm");
    
    % We only keep the cells that are good PC on either RUN1 or RUN2
    % We go look for that information
    
    % We load the good place field files
    load(file + "\extracted_place_fields.mat")
    
    goodCellsRUN1T1 = place_fields.track(1).good_cells;
    goodCellsRUN2T1 = place_fields.track(3).good_cells;
    
    goodCellsRUN1T2 = place_fields.track(2).good_cells;
    goodCellsRUN2T2 = place_fields.track(4).good_cells;
    
    % We OR these two lists to have all cells good on one or the other
    goodCellsT1 = unique([goodCellsRUN1T1 goodCellsRUN2T1]);
    goodCellsT2 = unique([goodCellsRUN1T2 goodCellsRUN2T2]);
    
    % Now we can subsample our PVs
    PV_RUN1T1REF = cellfun(@(a) a(goodCellsT1), PV_RUN1T1REF, 'UniformOutput', false);
    PV_RUN1T2REF = cellfun(@(a) a(goodCellsT2), PV_RUN1T2REF, 'UniformOutput', false);
    
    PV_RUN1T1 = cellfun(@(a) a(goodCellsT1), PV_RUN1T1, 'UniformOutput', false);
    PV_RUN2T1 = cellfun(@(a) a(goodCellsT1), PV_RUN2T1, 'UniformOutput', false);
    
    PV_RUN1T2 = cellfun(@(a) a(goodCellsT2), PV_RUN1T2, 'UniformOutput', false);
    PV_RUN2T2 = cellfun(@(a) a(goodCellsT2), PV_RUN2T2, 'UniformOutput', false);
    
    %% Now we can compute the correlation between the two PVs and the reference
    corrRUN1T1REF = cellfun(@(a,b) corrcoef(cell2mat(a), cell2mat(b), "rows", "complete"), PV_RUN1T1, PV_RUN1T1REF, 'UniformOutput', false);
    corrRUN1T1REF = cellfun(@(a) a(2, 1), corrRUN1T1REF, 'UniformOutput', false);
    
    corrRUN2T1REF = cellfun(@(a,b) corrcoef(cell2mat(a), cell2mat(b), "rows", "complete"), PV_RUN2T1, PV_RUN1T1REF, 'UniformOutput', false);
    corrRUN2T1REF = cellfun(@(a) a(2, 1), corrRUN2T1REF, 'UniformOutput', false);
    
    deltaCorrT1 = cell2mat(corrRUN2T1REF) - cell2mat(corrRUN1T1REF);
    
    corrRUN1T2REF = cellfun(@(a,b) corrcoef(cell2mat(a), cell2mat(b), "rows", "complete"), PV_RUN1T2, PV_RUN1T2REF, 'UniformOutput', false);
    corrRUN1T2REF = cellfun(@(a) a(2, 1), corrRUN1T2REF, 'UniformOutput', false);
    
    corrRUN2T2REF = cellfun(@(a,b) corrcoef(cell2mat(a), cell2mat(b), "rows", "complete"), PV_RUN2T2, PV_RUN1T2REF, 'UniformOutput', false);
    corrRUN2T2REF = cellfun(@(a) a(2, 1), corrRUN2T2REF, 'UniformOutput', false);
    
    deltaCorrT2 = cell2mat(corrRUN2T2REF) - cell2mat(corrRUN1T2REF);
    
    % We take the median of this vector
    
    corrT1 = median(deltaCorrT1, 'omitnan');
    corrT2 = median(deltaCorrT2, 'omitnan');
    
    %% Now we find the number of POST1 replay events
    
    load(file + "\significant_replay_events.mat");
    load(file + "\extracted_sleep_state.mat");
    
    SleepStart = sleep_state.state_time.INTER_post_start;
    SleepStop = sleep_state.state_time.INTER_post_end;
    
    goodSignReplayDataT1 = significant_replay_events.track(1);
    boolMatIsReplayPeriod = goodSignReplayDataT1.event_times <= SleepStop & goodSignReplayDataT1.event_times >= SleepStart;
    nbReplayEventsT1 = length(goodSignReplayDataT1.index(boolMatIsReplayPeriod));
    
    goodSignReplayDataT2 = significant_replay_events.track(2);
    boolMatIsReplayPeriod = goodSignReplayDataT2.event_times <= SleepStop & goodSignReplayDataT2.event_times >= SleepStart;
    nbReplayEventsT2 = length(goodSignReplayDataT2.index(boolMatIsReplayPeriod));
    
    % We append to the vectors
    
    corrVector = [corrVector corrT1 corrT2];
    replayEventsVector = [replayEventsVector nbReplayEventsT1 nbReplayEventsT2];
    condition = [condition string(conditionOI) string(conditionOI)];
    animal = [animal string(animalOI) string(animalOI)];
    day = [day string(dayOI) string(dayOI)];
    track = [track 1 2];
    
    
end
animal = animal';
condition = condition';
day = day';
correlation = corrVector';
nbReplayEvents = replayEventsVector';
track = track';

data = table(animal, condition, day, track, correlation, nbReplayEvents);

save(PATH.SCRIPT + "\..\..\Data\CLEAN_Files_Inferential\correlation_RUN1LAPEnd_RUN2LAP1_Replay_POST1.mat", "data");

%% PLOT -------------------------------------------------------------------
load(PATH.SCRIPT + "\..\..\Data\CLEAN_Files_Inferential\correlation_RUN1LAPEnd_RUN2LAP1_Replay_POST1.mat")

dataT1 = data(mod(data.track, 2) == 1, :);
dataT2 = data(mod(data.track, 2) == 0, :);

plotT1 = scatter(dataT1.correlation, dataT1.nbReplayEvents);
hold on;
plotT2 = scatter(dataT2.correlation, dataT2.nbReplayEvents);

legend('Track 1', 'Track 2');
xlabel("corr(Lap1RUN2 & Lap N-1 RUN1) - corr(Lap N RUN1 & Lap N-1 RUN1)")
ylabel("Number of POST1 replay events")

lm = fitlm(dataT1,'correlation~nbReplayEvents');
disp(lm);

lm = fitlm(dataT2,'correlation~nbReplayEvents');
disp(lm);