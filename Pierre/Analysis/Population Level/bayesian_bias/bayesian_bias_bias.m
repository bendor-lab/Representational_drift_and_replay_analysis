% Bayesian Bias analysis

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

mode = 2; % 1 - All events ; 2 - Significant RE ; 3 - NS RE
% Replay events are poled from exp vs. re-exp

% Initiate the final files

sessionID = [];
animal = [];
condition = [];
track = [];
replay_id = [];
replay_time = [];
bayesian_bias = [];

% For each session

for fID = 1:length(sessions)

    file = sessions{fID};
    disp(fID);

    % Parse the name to get infos
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    animalOI = string(animalOI);
    conditionOI = string(conditionOI);
    disp(conditionOI);

    % We load all the put. rep. ev EXP vs. REEXP

    temp = load(file + "\balanced_analysis\Replay_T1_vs_T3\decoded_replay_events");
    decoded_replay_eventsT1 = temp.decoded_replay_events;

    temp = load(file + "\balanced_analysis\Replay_T2_vs_T4\decoded_replay_events");
    decoded_replay_eventsT2 = temp.decoded_replay_events;

    % Load sleep data
    temp = load(file + "\extracted_sleep_state");
    sleep_state = temp.sleep_state;

    % We get the start / end of POST1
    startTime = sleep_state.state_time.INTER_post_start;
    endTime = sleep_state.state_time.INTER_post_end;

    % We get all the sleep replay events during POST1
    [sleepSWRID, timeSWR] = getAllSleepReplay(1, startTime, endTime, decoded_replay_eventsT1, sleep_state);
    sleepID = sleepSWRID;
    timeRep = timeSWR;

    for trackOI = 1:2

        if trackOI == 1
            decoded_replay_events = decoded_replay_eventsT1;
        else
            decoded_replay_events = decoded_replay_eventsT2;
        end

        % If mode ~= 1, we filter this ID list
        if mode == 2

            % We find all the significant replay events
            % path2get = [file, '\Replay_T', num2str(trackOI), '_vs_T', num2str(trackOI + 2)];
            path2get = [file, '\Replay\RUN1_Decoding'];
            path2get2 = [file, '\Replay\RUN2_Decoding'];

            temp = load(path2get + "\significant_replay_events_wcorr");
            significant_replay_eventsExp = temp.significant_replay_events;

            temp = load(path2get2 + "\significant_replay_events_wcorr");
            significant_replay_eventsReexp = temp.significant_replay_events;

            good_ids = union(significant_replay_eventsExp.track(trackOI).ref_index, ...
                             significant_replay_eventsReexp.track(trackOI).ref_index);

            sleepID = intersect(sleepSWRID, good_ids);
            timeRep = timeSWR(ismember(sleepSWRID, sleepID));

        elseif mode == 3

            % We find all the significant replay events
            path2get = [file, '\Replay\RUN1_Decoding'];
            path2get2 = [file, '\Replay\RUN2_Decoding'];

            temp = load(path2get + "\significant_replay_events_wcorr");
            significant_replay_eventsExp = temp.significant_replay_events;

            temp = load(path2get2 + "\significant_replay_events_wcorr");
            significant_replay_eventsReexp = temp.significant_replay_events;

            good_ids = union(significant_replay_eventsExp.track(trackOI).ref_index, ...
                             significant_replay_eventsReexp.track(trackOI).ref_index);

            sleepID = setdiff(sleepSWRID, good_ids);
            timeRep = timeSWR(ismember(sleepSWRID, sleepID));

        end

        current_nbReplay = numel(sleepID);

        % We iterate through each replay event
        for rID = 1:current_nbReplay

            replayID = sleepID(rID);
            current_time = timeRep(rID);

            decodedPosExp = decoded_replay_events(1).replay_events(replayID).decoded_position;
            decodedPosReexp = decoded_replay_events(2).replay_events(replayID).decoded_position;

            bb = log10(sum(sum(decodedPosReexp))/sum(sum(decodedPosExp)));

            sessionID = [sessionID; fID];
            animal = [animal; animalOI];
            condition = [condition; conditionOI];
            track = [track; trackOI];
            replay_id = [replay_id; rID/current_nbReplay];
            replay_time = [replay_time; current_time];
            bayesian_bias = [bayesian_bias; bb];
        end

    end
end

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);
condition = str2double(condition);

data = table(sessionID, animal, condition, replay_id, replay_time, bayesian_bias);

%% Plot - scatter all points
figure;
scatter(data.replay_time, data.bayesian_bias);
grid on;
%% Plot - take the mean each 1 minutes

data.timeDisc = discretize(data.replay_time, 0:60:1800)*3 - 3;
boxchart(data.timeDisc, data.bayesian_bias);
grid on;

%% Plot separate for each animal
allAnimals = unique(animal);
allConditions = [1, 2, 3, 4, 8, 16];

for anID = 1:numel(allAnimals)
    figure;
    tiledlayout(3, 2)

    for cID = 1:numel(allConditions)
        current_data = data(data.animal == allAnimals(anID) ...
            & data.condition == allConditions(cID), :);

        nexttile;
        if allConditions(cID) == 16
            allSessions = unique(current_data.sessionID);
            for sID = 1:numel(allSessions)
                plot(current_data(current_data.sessionID == allSessions(sID), :).replay_time, ...
                     current_data(current_data.sessionID == allSessions(sID), :).bayesian_bias);
                hold on;
            end
            hold off;

        else
            plot(current_data.replay_time, current_data.bayesian_bias);
        end

        title("Condition : " + num2str(allConditions(cID)) + " laps")
        ylim([-1, 1])
        xlim([0, 1800])
    end

end

%%
figure;
tiledlayout(1, 2)
nexttile;
scatter(data.replay_time(data.condition ~= 16), data.bayesian_bias(data.condition ~= 16))
hold on;

mdl = fitlm(data.replay_time(data.condition ~= 16), data.bayesian_bias(data.condition ~= 16));
intercept = mdl.Coefficients.Estimate(1);
slope     = mdl.Coefficients.Estimate(2);
plot(data.replay_time(data.condition ~= 16), data.replay_time(data.condition ~= 16)*slope + intercept, "r")
hold off;

title("< 16 laps conditions")
grid on;

nexttile;
scatter(data.replay_time(data.condition == 16), data.bayesian_bias(data.condition == 16))
hold on;

mdl = fitlm(data.replay_time(data.condition == 16), data.bayesian_bias(data.condition == 16));
intercept = mdl.Coefficients.Estimate(1);
slope     = mdl.Coefficients.Estimate(2);
plot(data.replay_time(data.condition == 16), data.replay_time(data.condition == 16)*slope + intercept, "r")
hold off;
title("16 laps condition")
grid on;

linkaxes

%% First half vs. second half of sleep

g = groupsummary(data, ["sessionID", "animal", "condition"]);

mean_bb_first = [];
mean_bb_second = [];

for l = 1:numel(g(:, 1))
    sessionOI = g{l, 1};
    conditionOI = g{l, 3};
    allMatching = data(data.sessionID == sessionOI & data.condition == conditionOI, :);
    currentBbFirst = mean(allMatching.bayesian_bias(allMatching.replay_time < 900), 'omitnan');
    currentBbSecond = mean(allMatching.bayesian_bias(allMatching.replay_time >= 900), 'omitnan');

    mean_bb_first(end + 1) = currentBbFirst;
    mean_bb_second(end + 1) = currentBbSecond;
end

g.mean_bb_first = mean_bb_first';
g.mean_bb_second = mean_bb_second';

figure;
gscatter(g.mean_bb_first, g.mean_bb_second, g.condition)
xlabel("Mean BB - first 15 minutes")
ylabel("Mean BB - rest of sleep")
L = legend;
grid on;
hold on;

plot(-0.3:0.01:0.1, -0.3:0.01:0.1, "--r", "LineWidth", 1.5)
L.String{end} = "y=x";