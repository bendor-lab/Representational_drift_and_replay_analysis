% CHAPTER 2 PIPELINE
% Marta Huelin

% REPLAY TIMES AND QUANTIFICATION
extract_replay_time_periods(computer,data_folders,data_type,[]);
extract_replay_plotting(computer,data_type,replay_control);
merge_sleep_rest_replay(multievents,bayesian_controls);

% Raster plot with replay event times
raster_replay_times('awake');
save_all_figures(pwd,[]);

% Plot replay events distribution
histogram_replay_events('sum','sleep'); % distribution of sum of events per track
histogram_difference_replay_events('sum','sleep');  % plots difference of number of replay events between tracks

%not used so much
sleep_replay_diff_histogram(epoch); % plots difference of number of events between tracks for INTER & FINAL sleep
sleep_replay_sum_histogram(epoch); % plots distribution of sum of events per track for INTER & FINAL sleep
extract_replay_rate; %in progress - finds coefficients of exponential equations from cumulative replay sum 

% REPLAY QUANTIFICATION
plot_cum_replay_periods('sleep'); % plots distribution of sum of cumulative replay event times across sleep periods
plot_diff_cum_replay_periods('awake'); % plots difference in number of cumulative replay event times across sleep period
diff_cumulative_replay_stats('sleep'); % stats on replay bias using random walk
plot_diff_proportion_cum_replay_periods(epoch,multievents,bayesian_control); % based on proportion of sig events compared to all candidate events
plot_proportion_cum_replay_periods;

% REPLAY BAYESIAN BIAS
extract_replay_bias(computer,epoch); %in progress - plots replay scores

% CALCULATES RATE REPLAY (events/min) and PLOT
plot_replay_rate(data_type,epoch);
plot_replay_bias_correlation; % plots correlation between INTER and FINAL sleep replay bias

% PROPORTION OF SIG EVENTS
proportion_of_sig_events(computer);
plot_corr_decodingError_sigEvents;

% EXTRACT REPLAY EVENTS WITH UNIQUE CELLS PER TRACK AND COMMON CELLS BETWEEN 1st AND 2nd EXPOSURE
extract_replay_indices_per_cell;
[protocol_events_histogram,cells_in_replay_events] = extract_replay_unique_and_common_cells(computer,data_type);
% Plot
plot_replay_unique_common_cells(plot_option);

% SLEEP REPLAY DYNAMICS
replay_transitions;
sleep_replay_dynamics(plot_option)

% AWAKE vs SLEEP REPLAY
compare_run_sleep_replay(1);

% Generalized Linear Model
GLM_INTERsleep_replay;
GLM_INTERrest_replay;
GLM_FINALsleep_replay;
[ripple_power,theta_power] = extract_track_theta_ripple_power;

%Controls
plot_corr_decodingError_sigEvents;
pre_post_comparison(state);
find_candidate_period_events(computer, state);
diff_proportion_sig_events(computer,state,method);
replay_bias;
calculate_period_candidate_events;

%Replay control for short exposures
replay_control_short_exposures;
comparison_to_control_replay;
proportion_of_sig_events(computer)
replay_control_1LAP; % control for Track 2 - 1 Lap
plots_control_one_lap;

% AWAKE REPLAY DURING INTER SLEEP
extract_initial_AwakeReplay_InterSleep(MultiEvents_option); % extracts awake replay prior to falling asleep in INTER sleep and 30min after
extract_initial_Difference_AwakeReplay_InterSleep(MultiEvents_option); % same than above but difference between tracks
extract_initial_Difference_Awake_Sleep_Replay_InterSleep(MultiEvents_option); % same than above but difference between tracks both in awake and sleep replay

% AWAKE REPLAY IN TRACK
extract_track_awake_replay_rate(data_type,multievents,lap_option); % extracts & plot local and remote awake replay
cumulative_track_awake_replay(multievents);
plot_proportion_awake_replay_track(multievents); % plot number of candidate local&remote awake replay (based on candidate replay events, not only sig)
plot_awake_replay_track(multievents); % plot number of local&remote awake replay
plot_awake_replay_properties; % duration, bayesian bias
measure_quality_awake_replay; %pval and scores from weighted corr
proportion_sig_awake_replay_track;