% Is the replay shifting from Track 1 to Track 3 - 2 / 4 over POST1 sleep ?

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

globalNumMin = 30; % Number of cumulative sleep replay to find events

% Initiate the final files

replayT1 = NaN(length(sessions), globalNumMin);
replayT2 = NaN(length(sessions), globalNumMin);
replayT3 = NaN(length(sessions), globalNumMin);
replayT4 = NaN(length(sessions), globalNumMin);

conditionVec = [];

% For each session
for fID = 1:length(sessions)

    numMin = globalNumMin;

    file = sessions{fID};
    disp(fID);

    % Parse the name to get infos
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    animalOI = string(animalOI);
    conditionOI = string(conditionOI);

    % Load the replay data for T1 - T3
    temp = load(file + "\Replay_T1_vs_T3\significant_replay_events_wcorr");
    sreT1 = temp.significant_replay_events;
    % Load the replay data for T2 - T4
    temp = load(file + "\Replay_T2_vs_T4\significant_replay_events_wcorr");
    sreT2 = temp.significant_replay_events;
    % Load sleep data
    temp = load(file + "\extracted_sleep_state");
    sleep_state = temp.sleep_state;
    clear temp

    % We get the sleeping state each minute and the time
    timeVec = sleep_state.time;
    stateVec = sleep_state.state_binned;

    % We get the start / end of POST1, and compute the amount of time slept
    sleepStop = sleep_state.state_time.INTER_post_end;
    sleepStart = sleep_state.state_time.INTER_post_start;

    stateVec = stateVec(timeVec <= sleepStop & timeVec >= sleepStart);
    stateVec(stateVec == -1) = 0; % We convert to a logical
    stateVec = logical(stateVec);
    timeVec = timeVec(timeVec <= sleepStop & timeVec >= sleepStart);

    allTimesSleeping = timeVec(stateVec);

    % We check if we have enough sleep time
    if length(allTimesSleeping) < numMin
        numMin = length(allTimesSleeping);
    end

    % Now we count the number of replay that fall in every minute of
    % timeVec

    allTimesReplay = sreT1.track(1).event_times;
    binnedReplay = histcounts(allTimesReplay, [timeVec timeVec(end) + 60]);
    binnedReplay = binnedReplay(stateVec);
    replayT1(fID, 1:numMin) = binnedReplay(1:numMin);

    allTimesReplay = sreT1.track(2).event_times;
    binnedReplay = histcounts(allTimesReplay, [timeVec timeVec(end) + 60]);
    binnedReplay = binnedReplay(stateVec);
    replayT3(fID, 1:numMin) = binnedReplay(1:numMin);

    allTimesReplay = sreT2.track(1).event_times;
    binnedReplay = histcounts(allTimesReplay, [timeVec timeVec(end) + 60]);
    binnedReplay = binnedReplay(stateVec);
    replayT2(fID, 1:numMin) = binnedReplay(1:numMin);

    allTimesReplay = sreT2.track(2).event_times;
    binnedReplay = histcounts(allTimesReplay, [timeVec timeVec(end) + 60]);
    binnedReplay = binnedReplay(stateVec);
    replayT4(fID, 1:numMin) = binnedReplay(1:numMin);

    conditionVec = [conditionVec conditionOI];

end

%% Figure 1

figure;

% Generate the plot
allConditions = unique(conditionVec);

for cID = 1:length(allConditions)
    current_condition = allConditions(cID);

    subplot(length(allConditions), 2, 2*cID - 1)
    bar(mean(replayT1(conditionVec == current_condition, :), 'omitnan'));
    hold on;
    bar(-mean(replayT3(conditionVec == current_condition, :), 'omitnan'))

    title(current_condition + " - Track 1 vs. Track 3")
    ylim([-2, 6]);
    hold off;

    subplot(length(allConditions), 2, 2*cID)
    bar(mean(replayT2(conditionVec == current_condition, :), 'omitnan'));
    hold on;
    bar(-mean(replayT4(conditionVec == current_condition, :), 'omitnan'))
    title(current_condition + " - Track 2 vs. Track 4")
    ylim([-2, 6]);
    hold off;

end

subplot(length(allConditions), 2, 1)
ylabel("Mean number of replay events")
xlabel("Cumulative sleep time (min)")

%% Figure 2

figure;

subplot(1, 2, 1)
cumsumReplayT1 = cumsum(replayT1, 2, 'omitnan');
normCumT1 = normalize(cumsumReplayT1, 2, "range");
plot(normCumT1', "k");
hold on;

cumsumReplayT3 = cumsum(replayT3, 2, 'omitnan');
normCumT3 = normalize(cumsumReplayT3, 2, "range");
plot(normCumT3', "r");

cumsumDiff = normCumT1 - normCumT3;
plot(cumsumDiff');
hold off;

subplot(1, 2, 2)
plot(cumsum(mean(replayT2, 'omitnan')))
hold on;
plot(-cumsum(mean(replayT4, 'omitnan')))
hold off;

legend({"Past track replay", "Futur track replay"})

%%

figure;

% Generate the plot
allConditions = unique(conditionVec);

for cID = 1:length(allConditions)
    current_condition = allConditions(cID);

    subplot(length(allConditions), 2, 2*cID - 1)
    bar(mean(replayT1(conditionVec == current_condition, :), 'omitnan'));
    hold on;
    bar(-mean(replayT3(conditionVec == current_condition, :), 'omitnan'))

    title(current_condition + " - Track 1 vs. Track 3")
    ylim([-2, 6]);
    hold off;

    subplot(length(allConditions), 2, 2*cID)
    bar(mean(replayT2(conditionVec == current_condition, :), 'omitnan'));
    hold on;
    bar(-mean(replayT4(conditionVec == current_condition, :), 'omitnan'))
    title(current_condition + " - Track 2 vs. Track 4")
    ylim([-2, 6]);
    hold off;

end

