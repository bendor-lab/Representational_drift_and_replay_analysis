% Main code for replay quantification, analysis and visualisation
% By Marta Huelin Gorriz and Masahiro Takigawa 2023

computer = [];
data_type = 'main';
replay_control = [];
multievents = [];

%% REPLAY TIMES AND QUANTIFICATION
extract_replay_time_periods(computer,[],data_type,[]);

extract_replay_plotting(computer,data_type,'Only first exposure',multievents);
cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only first exposure')
merge_sleep_rest_replay(multievents,[]);

extract_replay_plotting(computer,data_type,'Only re-exposure',multievents);
cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only re-exposure')
merge_sleep_rest_replay(multievents,[]);

%% Raster plot with replay event times
% cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis')
% raster_replay_times('ALL');

cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis')
raster_plot_replay_times('ALL');
save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V3\';
save_all_figures(save_dir,[])

% % Plot replay events distribution
% histogram_replay_events('sum','sleep',0,'','Only first exposure'); % distribution of sum of events per track
% histogram_difference_replay_events('sum','sleep');  % plots difference of number of replay events between tracks
% 
% %not used so much
% sleep_replay_diff_histogram(epoch); % plots difference of number of events between tracks for INTER & FINAL sleep
% sleep_replay_sum_histogram(epoch); % plots distribution of sum of events per track for INTER & FINAL sleep
% extract_replay_rate; %in progress - finds coefficients of exponential equations from cumulative replay sum 

%% decoding quality

% Modified from plot_track_decodingError_between_exposures
plot_decoding_error_between_exposures([])
save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V3\Decoding error';
save_all_figures(save_dir,[])

plot_track_decoding_error_across_laps([])
save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V3\Decoding error';
save_all_figures(save_dir,[])

%% Figure 3A CALCULATES RATE REPLAY (events/s) and 3D-E
% cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only re-exposure')
% plot_replay_rate(data_type,epoch,'Only re-exposure');
cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls')
plot_replay_rate('main','merged','all');
plot_replay_rate('main','sleep','all');
plot_replay_rate('main','awake','all');
% 
% save_option = 0;
% time_chunk_size = 1800;% 900 = 15mins, 1800 = 30 mins, 3600 = 60 mins
% % plot_replay_rate_simple('main','merged','all',time_chunk_size,save_option)
% plot_replay_rate_simple('main','sleep','all',time_chunk_size,save_option)
% plot_replay_rate_simple('main','awake','all',time_chunk_size,save_option)
% save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V6';
% save_all_figures(save_dir,[])

% % plot_replay_rate('main','sleep','Only re-exposure',time_chunk_size,save_option)
% save_option = 1;
% plot_replay_rate_simple('main','sleep','Only re-exposure',time_chunk_size,save_option)
% save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V4\POST1 by RUN2';
% save_all_figures(save_dir,[])

%% Cumulative replay bias
% plot_cum_replay_periods('sleep','all'); % plots distribution of sum of cumulative replay event times across sleep periods
plot_track_replay_periods('sleep','all')
save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V6';
save_all_figures(save_dir,[])
% plot_cum_replay_temporal('sleep','all')

% plot_diff_cum_replay_periods('merged','all')
plot_diff_cum_replay_periods('sleep','all')
plot_diff_cum_replay_periods('awake','all')
save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V4';
save_all_figures(save_dir,[])

plot_diff_cum_replay_periods('sleep','Only re-exposure')
save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V5\POST1 by RUN2';
save_all_figures(save_dir,[])


%% Theta sequence vs awake replay
% time_chunk_size = 1800;
% rest_option = 'sleep';
% plot_theta_vs_replay('all',rest_option,time_chunk_size);
% save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V2\Theta vs replay';
% save_all_figures(save_dir,[])

time_chunk_size = 1800;
rest_option = 'sleep';
%  rest_option = 'awake';
time_window = 1;
% plot_theta_vs_replay_log2('all',rest_option,time_chunk_size,time_window);
plot_theta_vs_replay('all',rest_option,time_chunk_size,time_window);
plot_replay_theta_mixed_effect_model('all',rest_option,time_chunk_size,time_window);
% plot_theta_vs_replay_log2_sorted('all',rest_option,time_chunk_size,time_window);
save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V6\theta sequence vs awake replay';
save_all_figures(save_dir,[])

plot_theta_vs_replay_re_exposure_only('Only re-exposure',rest_option,time_chunk_size,time_window);
save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V6\POST1 by RUN2';
save_all_figures(save_dir,[])

% time_window = 2;
% save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V3\theta sequence vs awake replay\30-60min';
% plot_theta_vs_replay('all',rest_option,time_chunk_size,time_window);
% save_all_figures(save_dir,[])

time_chunk_size = 1800;
rest_option = 'awake';
time_window = 1;
save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V6\theta sequence vs awake replay\awake';
plot_replay_theta_mixed_effect_model('all',rest_option,time_chunk_size,time_window);
plot_theta_vs_replay('all',rest_option,time_chunk_size,time_window);
% plot_theta_vs_replay_log2('all',rest_option,time_chunk_size,time_window);
% plot_theta_vs_replay_log2_sorted('all',rest_option,time_chunk_size,time_window);
% plot_theta_cycles_vs_SWR_log2('all',rest_option,time_chunk_size,time_window);
save_all_figures(save_dir,[])


time_chunk_size = 1800;
rest_option = 'sleep';
time_window = 1;
% plot_theta_vs_replay_log2_re_exposure_only('Only re-exposure',rest_option,time_chunk_size,time_window);
plot_theta_vs_replay('Only re-exposure',rest_option,time_chunk_size,time_window);
save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure V6\POST1 by RUN2';
save_all_figures(save_dir,[])
% plot_SWR_temporal_log2('all',rest_option,time_chunk_size,time_window)


bayesian_control = 'all';
time_chunk_size = 1800;
rest_option = 'sleep';
time_window = 1;
plot_place_cell_SWR_firing(bayesian_control,rest_option,time_chunk_size,time_window)
save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure revision';
save_all_figures(save_dir,[])

% final lap decoding (for first  exposure)
final_lap_POST1_replay_analysis



