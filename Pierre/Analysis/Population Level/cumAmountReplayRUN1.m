% Is the replay shifting from Track 1 to Track 3 - 2 / 4 over POST1 sleep ?

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

% Initiate the final files

replayT1 = NaN(length(sessions), 16);
replayT2 = NaN(length(sessions), 16);
replayT3 = NaN(length(sessions), 16);
replayT4 = NaN(length(sessions), 16);

conditionVec = [];

% For each session
for fID = 1:length(sessions)

    file = sessions{fID};
    disp(fID);

    % Parse the name to get infos
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    animalOI = string(animalOI);
    conditionOI = string(conditionOI);

    % Load sleep data
    temp = load(file + "\extracted_laps");
    lap_times = temp.lap_times;
    clear temp

    for track = 1:2

        if track == 1
            % Load the replay data for T1 - T3
            temp = load(file + "\Replay_T1_vs_T3\significant_replay_events_wcorr");
            sre = temp.significant_replay_events;
        else
            % Load the replay data for T2 - T4
            temp = load(file + "\Replay_T2_vs_T4\significant_replay_events_wcorr");
            sre = temp.significant_replay_events;
        end

        goodLapData = lap_times(track);

        amountR1Rep = zeros(1, numel(goodLapData.completeLaps_start));
        amountR2Rep = zeros(1, numel(goodLapData.completeLaps_start));

        if numel(goodLapData.completeLaps_start) < 16
            new_max = length(goodLapData.completeLaps_start);
        else
            new_max = 16;
        end

        for lap = 1:new_max
            startTime = goodLapData.completeLaps_start(lap);
            stopTime = goodLapData.completeLaps_stop(lap);

            % Current track awake replay
            allTimesReplay = sre.track(1).event_times;
            numberRep1 = sum(allTimesReplay <= stopTime & allTimesReplay >= startTime);

            % Futur track wake replay
            allTimesReplay = sre.track(2).event_times;
            numberRep2 = sum(allTimesReplay <= stopTime & allTimesReplay >= startTime);

            if track == 1
                replayT1(fID, lap) = numberRep1;
                replayT3(fID, lap) = numberRep2;
            else
                replayT2(fID, lap) = numberRep1;
                replayT4(fID, lap) = numberRep2;
            end
        end
    end

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
xlabel("Lap number")

%% Figure 2

figure;

subplot(1, 2, 1)
plot(cumsum(mean(replayT1, 'omitnan')))
hold on;
plot(-cumsum(mean(replayT3, 'omitnan')))
hold off;

subplot(1, 2, 2)
plot(cumsum(mean(replayT2, 'omitnan')))
hold on;
plot(-cumsum(mean(replayT4, 'omitnan')))
hold off;

legend({"Past track replay", "Futur track replay"})

