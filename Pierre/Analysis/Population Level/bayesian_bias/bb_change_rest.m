% Look at the difference in bayesian bias dynamics between 
% sleep and awake - rest

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
state = []; % 0 : awake, 1 : sleep
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

    % We get all the awake rest replay events
    [awakeSWRID, timeAwakeSWR] = getAllAwakeReplay(1, startTime, endTime, decoded_replay_eventsT1, sleep_state);
    awakeSleepID = awakeSWRID;
    awakeTimeRep = timeAwakeSWR;

    for trackOI = 1:2

        if trackOI == 1
            decoded_replay_events = decoded_replay_eventsT1;
        else
            decoded_replay_events = decoded_replay_eventsT2;
        end

        % If mode ~= 1, we filter this ID list
        if mode == 2

            % We find all the significant replay events
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

            awakeSleepID = intersect(awakeSWRID, good_ids);
            awakeTimeRep = timeAwakeSWR(ismember(awakeSWRID, awakeSleepID));

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

            awakeSleepID = setdiff(awakeSWRID, good_ids);
            awakeTimeRep = timeAwakeSWR(ismember(awakeSWRID, awakeSleepID));
        end

        % Now we merge the sleep and awake replay events
        globalID = [sleepID; awakeSleepID];
        globalTimeRep = [timeRep; awakeTimeRep];
        sleep_state = [ones(numel(sleepID), 1); zeros(numel(awakeSleepID), 1)];

        current_nbReplay = numel(globalID);

        % We iterate through each replay event
        for rID = 1:current_nbReplay

            replayID = globalID(rID);
            current_time = globalTimeRep(rID);
            current_state = sleep_state(rID);

            decodedPosExp = decoded_replay_events(1).replay_events(replayID).decoded_position;
            decodedPosReexp = decoded_replay_events(2).replay_events(replayID).decoded_position;

            bb = log10(sum(sum(decodedPosReexp))/sum(sum(decodedPosExp)));

            sessionID = [sessionID; fID];
            animal = [animal; animalOI];
            condition = [condition; conditionOI];
            track = [track; trackOI];
            state = [state; current_state];
            replay_time = [replay_time; current_time];
            bayesian_bias = [bayesian_bias; bb];
        end

    end
end

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);
condition = str2double(condition);

data = table(sessionID, animal, condition, state, replay_time, bayesian_bias);

%% Analysis 1. Difference in bayesian bias between sleep and awake events ?
figure;
tiledlayout(2, 2);

n1 = nexttile;
bar([1, 2], [sum(data.state == 0) sum(data.state == 1)])
xticklabels(["Awake replay", "Sleep replay"])
ylabel('Count')
xlabel('State')
grid on;

n2 = nexttile;
histogram(data.bayesian_bias(data.state == 0), 100)
hold on;
histogram(data.bayesian_bias(data.state == 1), 100)
xlabel('Bayesian Bias')
ylabel('Count')
legend({'Awake', 'Sleep'})
grid on;

% We look at the increase in bayesian bias during rest for the two types

g = groupsummary(data, ["sessionID", "animal", "condition", "state"]);

mean_bb_first = [];
mean_bb_second = [];

for l = 1:numel(g(:, 1))
    sessionOI = g{l, 1};
    conditionOI = g{l, 3};
    stateOI = g{l, 4};
    allMatching = data(data.sessionID == sessionOI & data.condition == conditionOI ...
                       & data.state == stateOI, :);

    currentBbFirst = mean(allMatching.bayesian_bias(allMatching.replay_time < 900), 'omitnan');
    currentBbSecond = mean(allMatching.bayesian_bias(allMatching.replay_time >= 900), 'omitnan');

    mean_bb_first(end + 1) = currentBbFirst;
    mean_bb_second(end + 1) = currentBbSecond;
end

g.mean_bb_first = mean_bb_first';
g.mean_bb_second = mean_bb_second';

n3 = nexttile;
gscatter(g.mean_bb_first(g.state == 0), g.mean_bb_second(g.state == 0), g.condition(g.state == 0))
xlabel("Mean BB - first 15 minutes")
ylabel("Mean BB - rest of sleep")
title("Awake replay")
grid on;
hold on;
legend off;
plot(-0.3:0.01:0.1, -0.3:0.01:0.1, "--r", "LineWidth", 1.5)

n4 = nexttile;
gscatter(g.mean_bb_first(g.state == 1), g.mean_bb_second(g.state == 1), g.condition(g.state == 1))
xlabel("Mean BB - first 15 minutes")
ylabel("Mean BB - rest of sleep")
title("Sleep replay")
L = legend;
grid on;
hold on;

plot(-0.3:0.01:0.1, -0.3:0.01:0.1, "--r", "LineWidth", 1.5)
L.String{end} = "y=x";

linkaxes([n3 n4])
