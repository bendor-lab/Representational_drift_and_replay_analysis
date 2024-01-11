% THETA ANALYSIS PIPELINE
% MH 2020
% Pipeline that uses spike phases to create bins

%%%%%%% PHASE PRECESSION %%%%%%%

%half_laps_times = extract_running_laps;

TPP = phase_precession_absolute_location;
control_plots_phase_precession(track)

%%%%%%% THETA SEQUENCES %%%%%%%%

% EXTRACT DIRECTIONAL PLACE FIELDS
disp('extracting new clusters')
extract_directional_clusters;

disp('calculating directional clusters')
parameters = list_of_parameters;
calculate_directional_place_fields(parameters.x_bins_width); %2cm
calculate_directional_place_fields(parameters.x_bins_width_bayesian); %10cm
%extract_unidirectional_place_cells; 

% Plot place fields for each direction 
plot_place_fields(directional_place_fields(1).place_fields)
plot_place_fields(directional_place_fields(2).place_fields)

% EXTRACT THETA CYCLES
disp('extracting theta windows')
extract_theta_peak_trough(2);

% EXTRACT THETA CYCLES AND DECODE
disp('extracting theta windows')
theta_sequences_detection_decoding([]);

% QUANTIFICATION METHODS
disp('Apply quantification methods')
phase_theta_sequence_quantification([],1,1,'Y');
spike_train_correlation_phase([],'Y',[]); %non-bayesian quantification
plot_averaged_concat_theta_sequences([],[],'N');
theta_sequences_decoding_error_phase([],1); 
plot_theta_sequences_decoding_error(1);  

% SHUFFLES
num_shuffles = 1000;
% Shuffles on individual sequences: (USING THIS)
thetaseq_phase_PRE_spike_circ_shuffle([],[],num_shuffles,0,'Y');
plot_PREspike_train_phase_shuffle;
thetaseq_circular_phase_shuffle([],1000,1,'Y')
plot_phase_bin_phase_shuffle;
thetaseq_circular_position_shuffle([],num_shuffles,1,'Y');
plot_position_shuffle;
% Shuffles on averaged theta sequences
average_thetaseq_circular_phase_shuffle(num_shuffles);
average_theta_sequences_timebins_phase_shuffle(num_shuffles,1);
plot_time_bin_phase_shuffle;
% Shuffles on laps
lap_thetaseq_shuffles;
plot_lap_thetaseq_shuffles;

% SIGNIFICANCE 
average_thetaseq_significance = session_average_thetaseq_significance_scoring(computer);
centered_averaged_thetaSeq = average_thetaseq_significance_scoring;

% PLOTTING
plot_raster_theta_seq(track);