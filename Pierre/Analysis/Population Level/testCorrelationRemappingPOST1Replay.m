
clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

load(PATH.SCRIPT + "/../../Data/population_vector_laps.mat");

allAnimals = unique(string({population_vector_laps.animal}));
allConditions = unique(string({population_vector_laps.condition}));

sessions = data_folders_excl; % Use the function to get all the file paths
corrVector = repelem(0, length(sessions));
replayEventsVector = repelem(0, length(sessions));
condition = repelem("", length(sessions));
animal = repelem("", length(sessions));
day = repelem("", length(sessions));

for i = 1:length(sessions)
    
    disp(i);
    
    file = sessions{i};
    
    [animalOI, conditionOI, dayOI] = parseNameFile(file); % We get the informations about the current data
    
    %% We get the PV for LEndRUN1 and L1RUN2
    
    PV_RUN1 = extractPopulationVector(animalOI, conditionOI, 1, "last", "norm");
    
    PV_RUN2 = extractPopulationVector(animalOI, conditionOI, 3, 1, "norm");
    
    % We only keep the cells that are good PC on either RUN1 or RUN2
    % We go look for that information
    
    % We load the good place field files
    load(file + "\extracted_place_fields.mat")
    
    goodCellsRUN1 = place_fields.track(1).good_cells;
    goodCellsRUN2 = place_fields.track(3).good_cells;
    
    % We OR these two lists to have all cells good on one or the other
    goodCells = unique([goodCellsRUN1 goodCellsRUN2]);
    
    % Now we can subsample our PVs
    
    PV_RUN1 = cellfun(@(a) a(goodCells), PV_RUN1, 'UniformOutput', false);
    PV_RUN2 = cellfun(@(a) a(goodCells), PV_RUN2, 'UniformOutput', false);
    
    %% Now we can compute the correlation between the two PVs
    corrPV = cellfun(@(a,b) corrcoef(cell2mat(a), cell2mat(b)), PV_RUN1, PV_RUN2, 'UniformOutput', false);
    corrPV = cellfun(@(a) a(2, 1), corrPV, 'UniformOutput', false);
    
    % We take the median of this vector
    
    corr = median([corrPV{:}], 'omitnan');
    
    %% Now we find the number of POST1 replay events
    
    load(file + "\significant_replay_events.mat");
    load(file + "\extracted_sleep_state.mat");
    
    SleepStart = sleep_state.state_time.INTER_post_start;
    SleepStop = sleep_state.state_time.INTER_post_end;
    
    goodSignReplayData = significant_replay_events.track(1);
    boolMatIsReplayPeriod = goodSignReplayData.event_times <= SleepStop & goodSignReplayData.event_times >= SleepStart;
    nbReplayEvents = length(goodSignReplayData.index(boolMatIsReplayPeriod));
    
    % We append to the vectors
    
    corrVector(i) = corr;
    replayEventsVector(i) = nbReplayEvents;
    condition(i) = conditionOI;
    animal(i) = animalOI;
    day(i) = dayOI;
    
    
    
end

animal = animal';
condition = condition';
day = day';
correlation = corrVector';
nbReplayEvents = replayEventsVector';

data = table(animal, condition, day, correlation, nbReplayEvents);

save(PATH.SCRIPT + "\..\..\Data\CLEAN_Files_Inferential\correlation_RUN1LAPEnd_RUN2LAP1_Replay_POST1.mat", data);

scatter(data.correlation, data.nbReplayEvents);
xlabel("PV correlation")
ylabel("Number of POST1 replay events")

lm = fitlm(data,'correlation~nbReplayEvents');
disp(lm);