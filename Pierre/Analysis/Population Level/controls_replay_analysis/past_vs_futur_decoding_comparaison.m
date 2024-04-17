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
decMeth = [];
nbT1 = [];
nbT2 = [];
nbT3 = [];
nbT4 = [];

corMatDec = zeros(4, 4);

% For each session

for fID = 1:length(sessions)

    file = sessions{fID};
    disp(fID);

    % Parse the name to get infos
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    animalOI = string(animalOI);
    conditionOI = string(conditionOI);

    % We load all the put. rep. ev EXP vs. REEXP

    temp = load(file + "\balanced_analysis\Replay_T1_vs_T3\significant_replay_events_wcorr");
    significant_replay_eventsT1 = temp.significant_replay_events;

    temp = load(file + "\balanced_analysis\Replay_T2_vs_T4\significant_replay_events_wcorr");
    significant_replay_eventsT2 = temp.significant_replay_events;

    temp = load(file + "\Replay\RUN1_decoding\significant_replay_events_wcorr");
    significant_replay_events = temp.significant_replay_events;

    % Load sleep data
    temp = load(file + "\extracted_sleep_state");
    sleep_state = temp.sleep_state;

    % We get the start / end of POST1
    startTime = sleep_state.state_time.INTER_post_start;
    endTime = sleep_state.state_time.INTER_post_end;

    for decMethOI = 1:2

        switch decMethOI
            case 1

                % We get all the sleep replay events during POST1
                [sleepSWRID, ~] = getAllSleepReplay(1, startTime, endTime, significant_replay_events, sleep_state);
                current_nbT1 = numel(sleepSWRID);

                % We get all the sleep replay events during POST1
                [sleepSWRID, ~] = getAllSleepReplay(2, startTime, endTime, significant_replay_events, sleep_state);
                current_nbT2 = numel(sleepSWRID);

                current_nbT3 = NaN;
                current_nbT4 = NaN;

            case 2

                % We get all the sleep replay events during POST1
                [sleepSWRID, ~] = getAllSleepReplay(1, startTime, endTime, significant_replay_eventsT1, sleep_state);
                current_nbT1 = numel(sleepSWRID);

                % We get all the sleep replay events during POST1
                [sleepSWRID, ~] = getAllSleepReplay(1, startTime, endTime, significant_replay_eventsT2, sleep_state);
                current_nbT2 = numel(sleepSWRID);

                % We get all the sleep replay events during POST1
                [sleepSWRID, ~] = getAllSleepReplay(2, startTime, endTime, significant_replay_eventsT1, sleep_state);
                current_nbT3 = numel(sleepSWRID);

                % We get all the sleep replay events during POST1
                [sleepSWRID, ~] = getAllSleepReplay(2, startTime, endTime, significant_replay_eventsT2, sleep_state);
                current_nbT4 = numel(sleepSWRID);
        end

        sessionID = [sessionID; fID];
        animal = [animal; animalOI];
        condition = [condition; conditionOI];
        decMeth = [decMeth; decMethOI];
        nbT1 = [nbT1; current_nbT1];
        nbT2 = [nbT2; current_nbT2];
        nbT3 = [nbT3; current_nbT3];
        nbT4 = [nbT4; current_nbT4];

    end

end

data = table(sessionID, animal, condition, decMeth, nbT1, nbT2, nbT3, nbT4);

%% 
subplot(2, 2, 1)
gscatter(data.nbT1(data.decMeth == 1), data.nbT1(data.decMeth == 2), data.condition(data.decMeth == 2))

hold on;
plot(0:100, 0:100, "r")
xlabel("Number of sleep RE - T1 vs. T2")
ylabel("Number of sleep RE - Exp vs. Re-exp")
xlim([0 100])
ylim([0 100])
title("T1 decoded RE")
legend off

subplot(2, 2, 2)
gscatter(data.nbT2(data.decMeth == 1), data.nbT2(data.decMeth == 2), data.condition(data.decMeth == 2))

hold on;
plot(0:100, 0:100, "r")
xlabel("Number of sleep RE - T1 vs. T2")
ylabel("Number of sleep RE - Exp vs. Re-exp")
xlim([0 100])
ylim([0 100])
title("T2 decoded RE")
legend off

subplot(2, 2, 3)
gscatter(data.nbT1(data.decMeth == 2), data.nbT3(data.decMeth == 2), data.condition(data.decMeth == 2))

hold on;
xlabel("Number of PAST replay")
ylabel("Number of FUTUR replay")
xlim([0 100])
ylim([0 70])
title("T1 decoded RE - Exp vs. Re-exp")
legend off

subplot(2, 2, 4)
gscatter(data.nbT2(data.decMeth == 2), data.nbT4(data.decMeth == 2), data.condition(data.decMeth == 2))
L = legend;
L.AutoUpdate = 'off'; 

hold on;
xlabel("Number of PAST replay")
ylabel("Number of FUTUR replay")
xlim([0 100])
ylim([0 70])
title("T2 decoded RE - Exp vs. Re-exp")
