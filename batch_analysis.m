% BATCH ANALYSIS PIPELIN

function batch_analysis(option,varargin)
% option: 1- spikes & video ; 2 - position & laps ; 3 - sleep ; 4 - CSC & PSD ;
        % 5 - Place cells, bayesian & replay decoding ; 6 - replay section(scores, shuffles) ; 7 - see replay
% varargin: [] or 'all'

if any(ismember(option,1)) || strcmp(varargin,'all')
    % EXTRACT SPIKES, WAVEFORMS AND DROPPED SAMPLES
    extract_spikes_phy; % for clusters extracted from PHY
    extract_events;
    extract_dropped_samples;
    process_clusters;
    getWaveformsFromSamples();
    
    % EXTRACT VIDEO
    extract_video;
    frame_grab;
end

if any(ismember(option,2)) || strcmp(varargin,'all')
    % EXTRACT POSITIONS
    disp('processing position data')
    process_positions_PRE;
    process_positions_POST([1,3;2,4]);
    plot_cleaning_steps;
    extract_laps([]);
    plot_extracted_laps;
end

if any(ismember(option,3)) || strcmp(varargin,'all')
    % EXTRACT SLEEPk#
    load('extracted_sleep_state.mat')
    disp(sleep_state.MUA_THRESHOLD)
    disp(sleep_state.SPEED_THRESHOLD)
    sleep_stager('manual');
    %classify_sleep_2; %gets sleep periods using LFP theta, theta/delta
    %sleep_detection_comparion; % compares sleep periods obtained from each method
end

if any(ismember(option,4)) || strcmp(varargin,'all')
    % EXTRACT CSC
    disp('processing CSC data')
    p = gcp; % Starting new parallel pool
    if ~isempty(p)
        parallel_extract_PSD('sleep');
        
    else
        disp('parallel processing not possible');
        extract_PSD([],'sleep');
    end
    % plot_PSDs;
    best_channels = determine_best_channel('hpc');
    extract_CSC('hpc');
end

if any(ismember(option,5)) || strcmp(varargin,'all')
    
    % EXTRACT PLACE FIELDS
    disp('processing place_field data')
    parameters=list_of_parameters;
    calculate_place_fields(parameters.x_bins_width); %fine resolution
    calculate_place_fields(parameters.x_bins_width_bayesian); % for bayesian
    extract_place_field_lap(0); %fine resolution
    extract_place_field_lap(1); % for bayesian
    plot_place_fields;
end

if any(ismember(option,6)) || strcmp(varargin,'all')
    
    % EXTRACT REPLAY EVENTS and BAYESIAN DECODING
    disp('running bayesiand decoding and processing replay events')
    spike_count([],[],[],'Y');
    bayesian_decoding([],[],[],'Y');
    
    extract_replay_events; %finds onset and offset of replay events    
    replay_decoding(); %extract and decodes replay events

end

if any(ismember(option,7)) || strcmp(varargin,'all')
        
    % SCORING METHODS: TEST SIGNIFICANCE ON REPLAY EVENTS
    disp('scoring replay events')
    scored_replay = replay_scoring([],[0 1 0 1]); % can run line fitting, weighterd corr, pacman & spearman corr (select = 1)
    save('scored_replay.mat','scored_replay','-v7.3')
    
    % RUN SHUFFLES
    tic
    disp('running shuffles')
    % Select parameters
    num_shuffles  = 1000;
    analysis_type = [0 1 0 1];  % can run line fitting, weighterd corr, pacman & spearman corr (select = 1)
    % analysis_type= [0 0 0 0]; % if you want to just save the shuffles, not score them
    
    load decoded_replay_events.mat
    p = gcp; % Starting new parallel pool
    shuffle_choice={'PRE spike_train_circular_shift','PRE place_field_circular_shift', 'POST place bin circular shift'};
    
    if ~isempty(p)
        for shuffle_id=1:length(shuffle_choice)
            [shuffle_type{shuffle_id}.shuffled_track,shuffled_struct{shuffle_id,1}] = parallel_shuffles(shuffle_choice{shuffle_id},analysis_type,num_shuffles,decoded_replay_events);
        end
    else
        disp('parallel processing not possible');
        for shuffle_id=1:length(shuffle_choice)
            [shuffle_type{shuffle_id}.shuffled_track, shuffled_struct{shuffle_id,1}] = run_shuffles(shuffle_choice{shuffle_id},analysis_type,num_shuffles,decoded_replay_events);
        end
    end
    toc
    
    save('shuffle_scores.mat','shuffle_type','-v7.3');
    %save('shuffled_tracks.mat','shuffle_type','-v7.3');
    clear shuffle_type
    
    shuffled_struct(:,2)= shuffle_choice';
    save('shuffled_decoded_events.mat','shuffled_struct','-v7.3');

    shuffle_type= shuffle_scoring(shuffled_struct,[1 1 0 1],'whole');
    save('shuffled_tracks.mat','shuffle_type','-v7.3');
    clear shuffled_struct

    disp('time to run shuffles was...');
    toc
    
    
    % EVALUATE REPLAY SIGNIFICANCE
    load('scored_replay.mat'); %scores for real replay events
    load('shuffle_scores.mat'); %scores for shuffled replay events
    scored_replay  = replay_significance(scored_replay, shuffle_type); %p-value for each event, for each shuffle
     save('scored_replay.mat','scored_replay','-v7.3')

    % SECOND ROUND OF REPLAY ANALYSIS: REPLAY EVENT SEGMENTS
    % Split replay events
    replay_decoding_split_events();
    
    % Score replay segments
    load decoded_replay_events_segments;
    scored_replay1 = replay_scoring(decoded_replay_events1,[1 1 0 1]);
    scored_replay2 = replay_scoring(decoded_replay_events2,[1 1 0 1]);
    save('scored_replay.mat','segments scored_replay1','scored_replay2','-v7.3')
    
    % Run shuffles on both replay segments
    num_shuffles=1000;
    analysis_type=[0 1 0 1];  %just weighted correlation and pacman
    % analysis_type= [0 0 0 0]; % if you want to just save the shuffles, not score them

    load decoded_replay_events_segments;
    p = gcp; % Starting new parallel pool
    if ~isempty(p)
        for shuffle_id=1:length(shuffle_choice)
            [shuffle_type1{shuffle_id}.shuffled_track, shuffled_struct1{shuffle_id,1}] = parallel_shuffles(shuffle_choice{shuffle_id},analysis_type,num_shuffles,decoded_replay_events1);
            [shuffle_type2{shuffle_id}.shuffled_track, shuffled_struct2{shuffle_id,1}] = parallel_shuffles(shuffle_choice{shuffle_id},analysis_type,num_shuffles,decoded_replay_events2);
        end
    else
        disp('parallel processing not possible');
        for shuffle_id=1:length(shuffle_choice)
            [shuffle_type1{shuffle_id}.shuffled_track, shuffled_struct1{shuffle_id,1}] = run_shuffles(shuffle_choice{shuffle_id},analysis_type,num_shuffles,decoded_replay_events1);
            [shuffle_type2{shuffle_id}.shuffled_track, shuffled_struct2{shuffle_id,1}] = run_shuffles(shuffle_choice{shuffle_id},analysis_type,num_shuffles,decoded_replay_events2);
        end
    end
    
    save('shuffle_scores_segments.mat','shuffle_type1','shuffle_type2','-v7.3');
    clear shuffle_type1 shuffle_type2
    
    shuffled_struct1(:,2)= shuffle_choice';
    shuffled_struct2(:,2)= shuffle_choice';
    save('shuffled_decoded_segments.mat','shuffled_struct1','shuffled_struct2','-v7.3');
    
    shuffle_type1= shuffle_scoring(shuffled_struct1,[1 1 0 1],'segments');
    shuffle_type2= shuffle_scoring(shuffled_struct2,[1 1 0 1],'segments');
    %save shuffled_tracks_segments shuffle_type1 shuffle_type2;
    clear shuffle_type1 shuffle_type2
    clear shuffled_struct1 shuffled_struct2
    
    % Test significance
    load scored_replay_segments; load shuffle_scores_segments
    scored_replay1 = replay_significance(scored_replay1, shuffle_type1);
    scored_replay2 = replay_significance(scored_replay2, shuffle_type2);
    save('scored_replay_segments.mat','scored_replay1','scored_replay2','-v7.3');
end
clear scored_replay_segments shuffle_scores_segments shuffle_scores scored_replay

if any(ismember(option,8)) || strcmp(varargin,'all')
    % EVALUATE REPLAY SIGNIFICANCE FOR WHOLE AND SEGMENTED EVENTS
    number_of_significant_replays(0.05,3,'wcorr',1); %second input is to only use replay events passing set threshold for ripple power
    number_of_significant_replays(0.05,3,'spearman',1); 
    number_of_significant_replays(0.05,3,'wcorr',2);
    number_of_significant_replays(0.05,3,'spearman',2); 

end

if any(ismember(option,9)) || strcmp(varargin,'all')
    % OPTIONAL: TOOL TO VIEW REPLAY EVENTS
    see_replay;
end

if any(ismember(option,10)) || strcmp(varargin,'all')
    phase_precession_absolute_location;
end

end 
 