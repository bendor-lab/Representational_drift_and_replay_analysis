% POSTHOC THETA ANALYSIS AFTER PIPELINE

function chapter3_theta_pipeline


%%%% THETA SEQ LAP ANALYSIS

% Extract theta sequences per lap - different methods
extract_place_field_lap(bayesian_option); % extract directional pl fields per lap
extract_lap_thetaseq; % extract theta sequences using whole session place fields
extract_lap_thetaseq_With_lap_plfields; % extract theta sequences using place fields from lap

% Extract information from rat folders
extract_sessions_thetaseq_scores; % extract average theta seq scores from data folders
plot_lap_thetaseq;% uses place fields from whole session
plot_protocol_thetaseq_scores;
plot_protocol_thetaseq_scores_SPEED;
extract_sessions_lap_thetaseq_scores; % extract lap score using place fields from lap
plot_individual_lap_thetaseq_scores(method);

%%%% CONTROLS
compare_lapThetaSeq_plFields_decoder(method);
control_correlations;
plot_theta_correlation_controls;
plot_num_theta_seq_lap;

%Decoding error
theta_sequences_decoding_error_phase([],1);
plot_theta_sequences_decoding_error;
plot_compare_thetaseq_decodingError;

% Shuffles for individual laps
lap_thetaseq_shuffles;
plot_lap_thetaseq_shuffles;

% Shuffles for average laps
method = 'weighted_corr';
plot_average_thetaseq_shuffles(method)

%%%% THETA SEQ vs AWAKE REPLAY
thetaseq_awakereplay_corr;

% Plot phase precession
plot_example_phase_precession;
proportion_phase_precessing_place_cells; 

% Plot raw theta sequences
plot_raster_theta_seq(track);




end