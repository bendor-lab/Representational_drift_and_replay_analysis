% Look at the difference in bayesian bias dynamics between 
% sleep and awake - rest

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

mode = 1; % 1 - All events ; 2 - Significant RE ; 3 - NS RE
% Replay events are poled from exp vs. re-exp

% Initiate the final files

sessionID = [];
animal = [];
condition = [];
track = [];
state = []; % 0 : awake, 1 : SWS, 2 : Quiet rest
replay_time = [];
bayesian_bias = [];
t_dur_sws = [];

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
    temp = load(file + "\extracted_sleep_stages");
    sleep_state = temp.sleep_state;
    % We get the start / end of POST1
    startTime = sleep_state.state_time.INTER_post_start;
    endTime = sleep_state.state_time.INTER_post_end;

    % We get all the sleep replay events during POST1
    [sleepSWRID, timeSWR] = getAllSleepReplay(1, startTime, endTime, decoded_replay_eventsT1, sleep_state, 120);
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

        if mode == 1
            sleep_type = repelem(1, 1, numel(timeRep));
            time_during_sws = NaN(1, numel(timeRep));

        % If mode ~= 1, we filter this ID list
        elseif mode == 2

            % We find all the significant replay events
            path2get = [file, '\Replay\RUN1_Decoding'];
            path2get2 = [file, '\Replay\RUN2_Decoding'];

            temp = load(path2get + "\significant_replay_events_wcorr");
            significant_replay_eventsExp = temp.significant_replay_events;

            temp = load(path2get2 + "\significant_replay_events_wcorr");
            significant_replay_eventsReexp = temp.significant_replay_events;

            good_ids = union(significant_replay_eventsExp.track(trackOI).ref_index, ...
                             significant_replay_eventsReexp.track(trackOI).ref_index);

            % good_ids = significant_replay_eventsExp.track(trackOI).ref_index;

            sleepID = intersect(sleepSWRID, good_ids);
            timeRep = timeSWR(ismember(sleepSWRID, sleepID));

            % We get the REM / NREM label of the replay
            allReplayTimes = cellfun(@(a) a(1),...
                             {decoded_replay_events(1).replay_events(sleepID).timebins_edges});

            bigTimes = sleep_state.sleep_stages.t_sec;
            minutTime = sleep_state.time;
            isSleepingSec = zeros(numel(bigTimes), 1);

            % we get the sleping state for each second
            for m = 1:numel(minutTime)
                isSleepingSec(bigTimes >= minutTime(m)-30 & bigTimes <= minutTime(m)+30) = sleep_state.state_binned(m);
            end
            
            isSleepingSec(isSleepingSec == -1) = 0;
            isSleepingSec = logical(isSleepingSec);

            sleep_type = [];
            time_during_sws = [];
    
            for reID = 1:numel(allReplayTimes)
                current_second = bigTimes <= allReplayTimes(reID) & bigTimes + 1 >= allReplayTimes(reID);
                isSWS = any(current_second & sleep_state.sleep_stages.sws);
                isDuringSleep = any(current_second & isSleepingSec');
                isDuringPOST1 = any(current_second((bigTimes <= endTime & ...
                                                    bigTimes >= startTime)));

                if isSWS & isDuringSleep & isDuringPOST1

                    % We're looking at the position of the spike during the
                    % SWS
                    second_id = find(current_second);
                    [left, right] = getZoneAround(sleep_state.sleep_stages.sws, second_id);
                    time_start_SWS = bigTimes(left);
                    time_stop_SWS = bigTimes(right) + 1;
                    curr_time_during_SWS = (allReplayTimes(reID) - time_start_SWS)/...
                                           (time_stop_SWS - time_start_SWS);
                    
                    time_during_sws(end + 1) = curr_time_during_SWS;

                    sleep_type(end + 1) = 2;
                    
                else

                    sleep_type(end + 1) = 1;
                    time_during_sws(end + 1) = NaN;

                end
            end

            awakeSleepID = intersect(awakeSWRID, good_ids);
            awakeTimeRep = timeAwakeSWR(ismember(awakeSWRID, awakeSleepID));
        end

        % Now we merge the sleep and awake replay events
        globalID = [sleepID; awakeSleepID];
        globalTimeRep = [timeRep; awakeTimeRep];
        sleep_states = [sleep_type'; zeros(numel(awakeSleepID), 1)];
        time_during_sws = [time_during_sws'; NaN(numel(awakeSleepID), 1)];

        current_nbReplay = numel(globalID);

        % We iterate through each replay event
        for rID = 1:current_nbReplay

            replayID = globalID(rID);
            current_time = globalTimeRep(rID);
            current_state = sleep_states(rID);
            current_time_d_sws = time_during_sws(rID);

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
            t_dur_sws = [t_dur_sws; current_time_d_sws];
        end

    end
end

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);
condition = str2double(condition);

data = table(sessionID, animal, condition, state, replay_time, t_dur_sws, bayesian_bias);
data.logCondC = log2(data.condition) - mean(log2(data.condition));

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

%% Do we see an increase in bayesian bias over sleep ? is it related to the condition
% and to sleep / awake replay during POST1

% We mutualize SWS and non-SWS
data.stateC = data.state;
data.stateC(data.stateC ~= 0) = 1;
data.stateC = data.stateC - 0.5;

% We center replay time
data.replay_timeC = data.replay_time - mean(data.replay_time, 'omitnan');

fitlme(data(data.stateC == -0.5, :), "bayesian_bias ~ logCondC * replay_timeC + (1|animal) + (1|sessionID:animal)")
% Small of condition on bayesian bias. Increase of bb over
% sleep (0.1 %). No interaction.
% For awake SWR in general, VERY small effect of time (0.1 % per minut).

fitlme(data(data.stateC == 0.5, :), "bayesian_bias ~ logCondC * replay_timeC + (1|animal) + (1|sessionID:animal)")
% Small effect of condition on bb. Increase in bb over sleep (0.1 %),
% not dependent on the condition.
% For sleep SWR in general, small effect of time (0.1 % per minut).

%%
% sort the data based on spike time
sdata = sortrows(data, "replay_time");

c_session = 15;
c_data = sdata(sdata.sessionID == c_session & sdata.condition == 16, :);

rgb_values = [1, 0.6, 0.6; 0.6, 0.6, 1; 0.1, 0.6, 0.3];

figure;
hold on;
for i = 1:numel(c_data.bayesian_bias) - 1
    plot(c_data.replay_time(i:i+1), c_data.bayesian_bias(i:i+1), 'Color', rgb_values(c_data.state(i) + 1, :));
end

% Legend
h1 = plot(NaN, NaN, 'Color', rgb_values(1, :));
h2 = plot(NaN, NaN, 'Color', rgb_values(2, :));
h3 = plot(NaN, NaN, 'Color', rgb_values(3, :));

legend([h1 h2 h3], {"Awake", "Quiet rest", "SWS"});
hold off;



