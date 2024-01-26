
clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

load(PATH.SCRIPT + "/../../Data/population_vector_laps.mat");

sessions = data_folders_excl; % Use the function to get all the file paths

allAnimals = unique(string({population_vector_laps.animal}));
allConditions = unique(string({population_vector_laps.condition}));

deltaVector = [];
replayEventsVector = [];
condition = [];
animal = [];
day = [];
track = [];

for cFile = sessions
    
    disp(cFile);
    
    file = cFile{1};
    
    [animalOI, conditionOI, dayOI] = parseNameFile(file); % We get the informations about the current data
    
    if animalOI == "N-BLU" && conditionOI == "16x4" % For now, we need to exclude N-BLU, 16x4 because no data
        continue;
    end
    
    matchingLineDataBool = string({population_vector_laps.animal}) == animalOI & string({population_vector_laps.condition}) == conditionOI;
    
    matchingLinesData = population_vector_laps(matchingLineDataBool);
    mLDR1T1 = matchingLinesData([matchingLinesData.track] == 1);
    mLDR2T1 = matchingLinesData([matchingLinesData.track] == 3);
    mLDR1T2 = matchingLinesData([matchingLinesData.track] == 2);
    mLDR2T2 = matchingLinesData([matchingLinesData.track] == 4);
    
    corrLEndRun1T1 = median(mLDR1T1.allLaps(end).pvCorrelationNorm, 'omitnan');
    corrL1Run2T1 = median(mLDR2T1.allLaps(1).pvCorrelationNorm, 'omitnan');
    deltaT1 = corrL1Run2T1 - corrLEndRun1T1;
    
    corrLEndRun1T2 = median(mLDR1T2.allLaps(end).pvCorrelationNorm, 'omitnan');
    corrL1Run2T2 = median(mLDR2T2.allLaps(1).pvCorrelationNorm, 'omitnan');
    deltaT2 = corrLEndRun1T2 - corrL1Run2T2;
        
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
    
    replayEventsVector = [replayEventsVector nbReplayEventsT1 nbReplayEventsT2];
    deltaVector = [deltaVector deltaT1 deltaT2];
    condition = [condition string(conditionOI) string(conditionOI)];
    animal = [animal string(animalOI) string(animalOI)];
    day = [day string(dayOI) string(dayOI)];
    track = [track 1 2];
    
end

animal = animal';
condition = condition';
day = day';
deltaCorrelation = deltaVector';
nbReplayEvents = replayEventsVector';
track = track';

data = table(animal, condition, day, track, deltaCorrelation, nbReplayEvents);

save(PATH.SCRIPT + "\..\..\Data\CLEAN_Files_Inferential\correlation_Change_RUN1LAPEnd_RUN2LAP1_FPF_Replay_POST1.mat", "data");

splot = scatter(data.deltaCorrelation, data.nbReplayEvents, [], data.track);

legend
xlabel("corr(Lap1RUN2 & FPF) - corr(LapEndRUN1 & FPF)")
ylabel("Number of POST1 replay events")

lm = fitlm(data,'deltaCorrelation~nbReplayEvents');
disp(lm);