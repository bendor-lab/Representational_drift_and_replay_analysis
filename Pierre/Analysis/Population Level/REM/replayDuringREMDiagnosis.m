% Trying to understand what we're detecting when we detect replay during
% REM

clear

sessions_leg = data_folders_excl_legacy; % Use the function to get all the file paths
session_number = 6;
file_leg = sessions_leg{session_number};
sessions = data_folders_excl;
file = sessions{session_number};

trackOI = 1;


%% Loading data
load(file_leg + "/extracted_CSC");
load(file + "/Replay/RUN1_Decoding/significant_replay_events_wcorr");
load(file + "/extracted_sleep_stages");
load(file + "/Replay/RUN1_Decoding/decoded_replay_events");

LFP_theta = CSC(1).CSCraw;
theta_power = CSC(1).theta_zscore;

LFP_ripple = CSC(2).CSCraw;
swr_power = CSC(2).ripple_zscore;

delta_power = CSC(3).delta_zscore;

LFP_time = CSC(1).CSCtime;

%% Finding all the significant REM replay times

allReplayTimes = significant_replay_events.track(trackOI).event_times;
allRem = sleep_state.sleep_stages.rem;
allNRem = sleep_state.sleep_stages.sws;
allRem_time = sleep_state.sleep_stages.t_sec;

% Getting a vector with every REM - 1000 Hz
allRem_fast = repelem(0, numel(LFP_time));
allNRem_fast = repelem(0, numel(LFP_time));

for second = 1:numel(allRem)
    if allRem(minut) == 1
        REM_times_big = LFP_time >= allRem_time(second) & ...
            LFP_time <= allRem_time(second) + 1;

        allRem_fast(REM_times_big) = 1;

    elseif allNRem(minut) == 1
        REM_times_big = LFP_time >= allRem_time(second) & ...
            LFP_time <= allRem_time(second) + 1;

        allNRem_fast(REM_times_big) = 1;
    end
end

startPOST1 = sleep_state.state_time.INTER_post_start;
endPOST1 = sleep_state.state_time.INTER_post_end;
isPOST1 = allReplayTimes >= startPOST1 & allReplayTimes <= endPOST1;

validRemReplay = [];

for rID = 1:numel(allReplayTimes)
    current_time = allReplayTimes(rID);
    current_minut = allRem_time <= current_time & allRem_time + 1 >= current_time;
    isRem = allRem(current_minut);

    if isRem & isPOST1(rID)
        validRemReplay(end + 1) = current_time;
    end
end

%% Looking at the LFP shape during REM replay
current_replay_time = validRemReplay(1);

% Get the section of LFP we're interested in
slice_LFP = LFP_time >= (current_replay_time - 60) & ...
    LFP_time <= (current_replay_time + 60);

slice_closeup = LFP_time >= (current_replay_time - 0.500) & ...
    LFP_time <= (current_replay_time + 0.500);

snippetLFP = LFP_theta(slice_LFP);
snippetTime = LFP_time(slice_LFP);
snippetREMClass = allRem_fast(slice_LFP);
snippetNREMClass = allNRem_fast(slice_LFP);
snippetAwakeClass = ~(snippetREMClass | snippetNREMClass);

startREM = snippetTime(find(snippetREMClass, 1, 'first'));
stopREM = snippetTime(find(snippetREMClass, 1, 'last'));

f = figure;
f.Position = [680   181   986   697];
tiledlayout(7, 1);
nexttile([2 1]);
plot(snippetTime, snippetLFP);
xlabel("Time (s)");
ylabel("LFP");
title("LFP - 60 seconds before / 60 s after replay")

% REM / NREM indicators
nexttile;
area(snippetTime, snippetREMClass, 'FaceColor', "#EDB120");
hold on;
area(snippetTime, snippetNREMClass, 'FaceColor', "#77AC30");
area(snippetTime, snippetAwakeClass, 'FaceColor', "#0072BD");
axis off
legend({"REM", "NREM", "Awake"}, 'Location','eastoutside')


nexttile([2 1]);
plot(snippetTime, swr_power(slice_LFP));
hold on;
plot(snippetTime, theta_power(slice_LFP));
plot(snippetTime, delta_power(slice_LFP));

xline(current_replay_time, 'm', 'Replay');
hold off;
legend({"SWR", "Theta", "Delta"}, 'Location','eastoutside')
xlabel("Time (s)");
ylabel("Z-scored power");

nexttile([2 1]);
plot(LFP_time(slice_closeup), LFP_theta(slice_closeup));
hold on;
xline(current_replay_time, 'r');
title("LFP during replay - 0.5 s before and after")

xlabel("Time (s)");
ylabel("LFP");
