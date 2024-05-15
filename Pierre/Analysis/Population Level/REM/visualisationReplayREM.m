clear

sessions = data_folders_excl;
file = sessions{14};

trackOI = 1;
exposure = trackOI;
% exposure = 1;
foldToLoad = "/Replay_T" + trackOI + "_vs_T" + (trackOI + 2);

%% Loading data
load(file + "/Replay/RUN1_Decoding/significant_replay_events_wcorr");
% load(file + foldToLoad + "/significant_replay_events_wcorr");
load(file + "/extracted_sleep_stages");
load(file + "/Replay/RUN1_Decoding/decoded_replay_events");

%% Finding all the significant replay times
startPOST1 = sleep_state.state_time.INTER_post_start;
endPOST1 = sleep_state.state_time.INTER_post_end;

[goodReplayID, c] = getAllSleepReplay(exposure, startPOST1, endPOST1, significant_replay_events, sleep_state, 120);

allReplayTimes = significant_replay_events.track(exposure).event_times(goodReplayID);

all_times = sleep_state.sleep_stages.t_sec;
isPOST1 = all_times >= startPOST1 & all_times <= endPOST1;

all_times = all_times(isPOST1);
rem = sleep_state.sleep_stages.rem(isPOST1);
sws = sleep_state.sleep_stages.sws(isPOST1);
awake = sleep_state.sleep_stages.quiet_wake(isPOST1);

%% Plotting

figure;
bar(all_times, rem, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
hold on;
bar(all_times, sws, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
bar(all_times, awake, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
xlim([all_times(1), all_times(end)])

xline(allReplayTimes, 'k');

% Look at old classification
figure;
bar(sleep_state.time, sleep_state.REM_idx, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
hold on;
bar(sleep_state.time, sleep_state.NREM_idx, 'EdgeColor', 'none', 'FaceAlpha', 0.3);
bar(sleep_state.time, sleep_state.Quiet_wake_idx);
xlim([all_times(1), all_times(end)])

xline(allReplayTimes, 'k');

legend({"REM", "SWS", "Quiet rest"});

number_fig = numel(allReplayTimes);
% 
% for fID = 1:1 %number_fig
%     f = figure;
%     current_time = allReplayTimes(fID);
%     subset_time = all_times >= current_time - 30 & all_times <= current_time + 30;
%     area(all_times, rem, 'EdgeColor', 'none');
%     hold on;
%     area(all_times, sws, 'EdgeColor', 'none');
%     area(all_times, awake, 'EdgeColor', 'none');
%     legend({"REM", "SWS", "Other"});
% 
% end




