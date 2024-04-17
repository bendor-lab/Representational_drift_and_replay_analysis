% Look at the overlapping between 1 vs 2 / 3 vs 4

% Comparaison in termof detected events between RUN1 decoding and RUN2
% decoding

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

% Initiate the final files

sessionID = [];
animal = [];
condition = [];
nbT1 = [];
nbT2 = [];
nbT3 = [];
nbT4 = [];

% For each session

for fID = 1:length(sessions)

    file = sessions{fID};
    disp(fID);

    % Parse the name to get infos
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    animalOI = string(animalOI);
    conditionOI = string(conditionOI);

    % We load all the put. rep. ev EXP vs. REEXP

    temp = load(file + "\Replay\RUN1_Decoding\significant_replay_events_wcorr");
    significant_replay_eventsRUN1 = temp.significant_replay_events;

    temp = load(file + "\Replay\RUN2_Decoding\significant_replay_events_wcorr");
    significant_replay_eventsRUN2 = temp.significant_replay_events;

    % Load sleep data
    temp = load(file + "\extracted_sleep_state");
    sleep_state = temp.sleep_state;

    % We get the start / end of POST1
    startTime = sleep_state.state_time.INTER_post_start;
    endTime = sleep_state.state_time.INTER_post_end;

    % We get all the sleep replay events during POST1
    [sleepSWRID, ~] = getAllSleepReplay(1, startTime, endTime, significant_replay_eventsRUN1, sleep_state);
    current_nbT1 = numel(sleepSWRID);

    % We get all the sleep replay events during POST1
    [sleepSWRID, ~] = getAllSleepReplay(2, startTime, endTime, significant_replay_eventsRUN1, sleep_state);
    current_nbT2 = numel(sleepSWRID);

    % We get all the sleep replay events during POST1
    [sleepSWRID, ~] = getAllSleepReplay(1, startTime, endTime, significant_replay_eventsRUN2, sleep_state);
    current_nbT3 = numel(sleepSWRID);

    % We get all the sleep replay events during POST1
    [sleepSWRID, ~] = getAllSleepReplay(2, startTime, endTime, significant_replay_eventsRUN2, sleep_state);
    current_nbT4 = numel(sleepSWRID);

    sessionID = [sessionID; fID];
    animal = [animal; animalOI];
    condition = [condition; conditionOI];
    nbT1 = [nbT1; current_nbT1];
    nbT2 = [nbT2; current_nbT2];
    nbT3 = [nbT3; current_nbT3];
    nbT4 = [nbT4; current_nbT4];


end

data = table(sessionID, animal, condition, nbT1, nbT2, nbT3, nbT4);

%%
subplot(1, 2, 1)
gscatter(data.nbT1, data.nbT3, data.condition)

hold on;
plot(0:100, 0:100, "r")
xlabel("Number of sleep RE - Track 1")
ylabel("Number of sleep RE - Track 3")
xlim([0 100])
ylim([0 100])
title("T1 decoded RE")
legend off

subplot(1, 2, 2)
gscatter(data.nbT2, data.nbT4, data.condition)
L = legend;
L.AutoUpdate = "off";
hold on;
plot(0:100, 0:100, "r")
xlabel("Number of sleep RE - Track 2")
ylabel("Number of sleep RE - Track 4")
xlim([0 100])
ylim([0 100])
title("T2 decoded RE")