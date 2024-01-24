
clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

load(PATH.SCRIPT + "/../../Data/population_vector_laps.mat");

allAnimals = unique(string({population_vector_laps.animal}));
allConditions = unique(string({population_vector_laps.condition}));

deltaVector = [];
replayEventsVector = [];
condition = [];
animal = [];
day = [];

for sessionId = 1:2:length(population_vector_laps) % 2 lines per session so 2 by 2
    
    if sessionId == 9 % For now, we need to exclude N-BLU, 16x4 because no data
        continue;
    end
    
    disp(sessionId);
    
    conditionOI = string(population_vector_laps(sessionId).condition);
    animalOI = string(population_vector_laps(sessionId).animal);
    dayOI = string(population_vector_laps(sessionId).day);
    
    corrLEndRun1 = median(population_vector_laps(sessionId).allLaps(end).pvCorrelationNorm, 'omitnan');
    corrL1Run2 = median(population_vector_laps(sessionId + 1).allLaps(1).pvCorrelationNorm, 'omitnan');
    delta = corrL1Run2 - corrLEndRun1;
    
    sessions = data_folders_excl; % Use the function to get all the file paths to get the replay data
    
    matchingSession = sessions(contains(sessions, population_vector_laps(sessionId).condition) & ...
                               contains(sessions, population_vector_laps(sessionId).animal));
                    
    matchingSession = matchingSession{1};
    
    load(matchingSession + "\significant_replay_events.mat");
    load(matchingSession + "\extracted_sleep_state.mat");
    
    SleepStart = sleep_state.state_time.INTER_post_start;
    SleepStop = sleep_state.state_time.INTER_post_end;
    
    goodSignReplayData = significant_replay_events.track(1);
    boolMatIsReplayPeriod = goodSignReplayData.event_times <= SleepStop & goodSignReplayData.event_times >= SleepStart;
    nbReplayEvents = length(goodSignReplayData.index(boolMatIsReplayPeriod));
    
    replayEventsVector(end + 1) = nbReplayEvents;
    deltaVector(end + 1) = delta;
    condition(end + 1) = conditionOI;
    animal(end + 1) = animalOI;
    day(end + 1) = dayOI;
    
end

animal = animal';
condition = condition';
day = day';
deltaCorrelation = deltaVector';
nbReplayEvents = replayEventsVector';

data = table(animal, condition, day, deltaCorrelation, nbReplayEvents);

save(PATH.SCRIPT + "\..\..\Data\CLEAN_Files_Inferential\correlation_Change_RUN1LAPEnd_RUN2LAP1_FPF_Replay_POST1.mat", data);

scatter(data.correlation, data.deltaCorrelation);
xlabel("PV correlation with FPF difference")
ylabel("Number of POST1 replay events")

lm = fitlm(data,'deltaCorrelation~nbReplayEvents');
disp(lm);