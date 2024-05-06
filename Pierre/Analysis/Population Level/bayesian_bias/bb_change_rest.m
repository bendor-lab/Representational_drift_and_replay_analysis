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
state = []; % 0 : awake, 1 : NREM sleep, 2 : REM
replay_time = [];
bayesian_bias = [];
t_dur_rem = [];

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

            % We get the REM / NREM label of the replay
            allReplayTimes = cellfun(@(a) a(1),...
                             {decoded_replay_events(1).replay_events.timebins_edges});

            allReplayTimes = allReplayTimes(sleepID);

            bigTimes = sleep_state.time;
            sleep_type = [];
            time_during_rem = [];
            
            isSleeping = sleep_state.state_binned;
            isSleeping(isSleeping == -1) = 0;
            isSleeping = logical(isSleeping);
    
            for reID = 1:numel(allReplayTimes)
                histReplay = histcounts(allReplayTimes(reID), [bigTimes bigTimes(end) + 60]);
                isRem = sleep_state.REM_idx;
                % isRem = circshift(isRem, 1);

                histReplay(~isRem) = 0;
                histReplay(~isSleeping) = 0;
                histReplaySleep = histReplay(sleep_state.time <= endTime & ...
                                        sleep_state.time >= startTime);

                if any(histReplaySleep)
                    % We're looking at the position of the spike during the
                    % REM
                    current_minut = find(histReplay);
                    [left, right] = getZoneAround(isRem, current_minut);
                    time_start_REM = bigTimes(left);
                    time_stop_REM = bigTimes(right) + 60;
                    curr_time_during_REM = (allReplayTimes(reID) - time_start_REM)/...
                                      (time_stop_REM - time_start_REM);
                    
                    time_during_rem(end + 1) = curr_time_during_REM;

                    sleep_type(end + 1) = 2;
                else
                    sleep_type(end + 1) = 1;
                    time_during_rem(end + 1) = NaN;
                end
            end
    

            awakeSleepID = intersect(awakeSWRID, good_ids);
            awakeTimeRep = timeAwakeSWR(ismember(awakeSWRID, awakeSleepID));

        end

        % Now we merge the sleep and awake replay events
        globalID = [sleepID; awakeSleepID];
        globalTimeRep = [timeRep; awakeTimeRep];
        sleep_states = [sleep_type'; zeros(numel(awakeSleepID), 1)];
        time_during_rem = [time_during_rem'; NaN(numel(awakeSleepID), 1)];

        current_nbReplay = numel(globalID);

        % We iterate through each replay event
        for rID = 1:current_nbReplay

            replayID = globalID(rID);
            current_time = globalTimeRep(rID);
            current_state = sleep_states(rID);
            current_time_d_rem = time_during_rem(rID);

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
            t_dur_rem = [t_dur_rem; current_time_d_rem];
        end

    end
end

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);
condition = str2double(condition);

data = table(sessionID, animal, condition, state, replay_time, t_dur_rem, bayesian_bias);

%% Analysis 1. Difference in bayesian bias between sleep and awake events ?
% figure;
% tiledlayout(2, 2);
% 
% n1 = nexttile;
% bar([1, 2, 3], [sum(data.state == 0) sum(data.state == 1) sum(data.state == 2)])
% xticklabels(["Awake replay", "NREM replay", "REM replay"])
% ylabel('Count')
% xlabel('State')
% grid on;
% 
% n2 = nexttile;
% histogram(data.bayesian_bias(data.state == 0), 100)
% hold on;
% histogram(data.bayesian_bias(data.state == 1), 100)
% hold on;
% histogram(data.bayesian_bias(data.state == 2), 100)
% xlabel('Bayesian Bias')
% ylabel('Count')
% legend({'Awake', 'NREM', 'REM'})
% grid on;
% 
% % We look at the increase in bayesian bias during rest for the two types
% 
% g = groupsummary(data, ["sessionID", "animal", "condition", "state"]);
% 
% mean_bb_first = [];
% mean_bb_second = [];
% 
% for l = 1:numel(g(:, 1))
%     sessionOI = g{l, 1};
%     conditionOI = g{l, 3};
%     stateOI = g{l, 4};
%     allMatching = data(data.sessionID == sessionOI & data.condition == conditionOI ...
%                        & data.state == stateOI, :);
% 
%     currentBbFirst = mean(allMatching.bayesian_bias(allMatching.replay_time < 900), 'omitnan');
%     currentBbSecond = mean(allMatching.bayesian_bias(allMatching.replay_time >= 900), 'omitnan');
% 
%     mean_bb_first(end + 1) = currentBbFirst;
%     mean_bb_second(end + 1) = currentBbSecond;
% end
% 
% g.mean_bb_first = mean_bb_first';
% g.mean_bb_second = mean_bb_second';
% 
% n3 = nexttile;
% gscatter(g.mean_bb_first(g.state == 0), g.mean_bb_second(g.state == 0), g.condition(g.state == 0))
% xlabel("Mean BB - first 15 minutes")
% ylabel("Mean BB - rest of sleep")
% title("Awake replay")
% grid on;
% hold on;
% legend off;
% plot(-0.3:0.01:0.1, -0.3:0.01:0.1, "--r", "LineWidth", 1.5)
% 
% n4 = nexttile;
% gscatter(g.mean_bb_first(g.state == 1), g.mean_bb_second(g.state == 1), g.condition(g.state == 1))
% xlabel("Mean BB - first 15 minutes")
% ylabel("Mean BB - rest of sleep")
% title("Sleep replay")
% L = legend;
% grid on;
% hold on;
% 
% plot(-0.3:0.01:0.1, -0.3:0.01:0.1, "--r", "LineWidth", 1.5)
% L.String{end} = "y=x";
% 
% linkaxes([n3 n4])

%%

g = groupsummary(data, ["sessionID", "animal", "condition", "state"], "mean", "bayesian_bias");

g(g.state == 0, :) = [];
g.state(g.state == 1) = -0.5;
g.state(g.state == 2) = 0.5;

beeswarm(g.state(g.condition ~= 16), g.mean_bayesian_bias(g.condition ~= 16))

datac = data;
datac.stateC = datac.state - 1.5;
datac(datac.stateC == -1.5, :) = [];
datac.logCondC = log2(datac.condition) - mean(log2(datac.condition));

lme = fitlme(datac, "bayesian_bias ~ stateC * logCondC + (1|animal) + (1|sessionID:animal)");
disp(lme)

lme = fitlme(g, "mean_bayesian_bias ~ state*condition + (1|animal) + (1|sessionID:animal)");
disp(lme)

%%
figure;
histogram(t_dur_rem, 20);
xlabel("Relative spiking time during REM")
ylabel("Count")

%%

allIDREM = globalID(sleep_states == 2);
allIDNREM = globalID(sleep_states == 1);


for i = 1:numel(allIDNREM)
    current_replay = decoded_replay_events(1).replay_events(allIDNREM(i)).decoded_position;
    figure;
    imagesc(current_replay);
end
