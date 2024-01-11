function plot_place_cell_SWR_firing(bayesian_control,rest_option,time_chunk_size,time_window)

% Code for quantifying and plotting the place cell firing and participation
% during SWR and theta sequences

% Input: 
% bayesian_control - Use 'all' for analysing first exposure data using first
% exposure template and re-exposure data using re-exposure template. 
% Use 'Only re-exposure' or 'Only first exposure'
% for analying all data using first exposure template or re-exposure template
% rest_option - 'sleep' or 'awake' or 'merged'
% time_chunk_size - 900 or 1800 or 3600 for quantifying replay based on 15 mins time bin or 30 mins
% time bin or 60 mins time bin
% time_window - Defualt is 1 for first time bin (usually first cumulative 30 mins time bin). Can use other time bins if needed
% By Marta Huelin Gorriz and Masahiro Takigawa 2023

if ~isempty(bayesian_control)
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\extracted_time_periods_replay_excl.mat')
    
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only first exposure';
    path2 = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only re-exposure';
    
    if strcmp(bayesian_control,'all')
        track_replay_events_F = load([path '\extracted_replay_plotting_info_excl.mat']);
        track_replay_events_R = load([path2 '\extracted_replay_plotting_info_excl.mat']);
    elseif strcmp(bayesian_control,'Only re-exposure')
        track_replay_events_F = load([path2 '\extracted_replay_plotting_info_excl.mat']);
        track_replay_events_R = load([path2 '\extracted_replay_plotting_info_excl.mat']);
    elseif strcmp(bayesian_control,'Only first exposure')
        track_replay_events_F = load([path '\extracted_replay_plotting_info_excl.mat']);
        track_replay_events_R = load([path '\extracted_replay_plotting_info_excl.mat']);
    end
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\population_vector_data_excl.mat')
    popvec = protocol;
    % AWAKE REPLAY
    load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\extracted_awake_replay_track_completelap_excl.mat']);
    % SLEEP REPLAY
    
    if strcmp(rest_option,'merged')
        if time_chunk_size == 900
            load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_merged_replay_15min_excl.mat']); %info of sleep in time bins
            %         load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_merged_replay_60min_excl.mat']); %info of sleep in time bins
        elseif time_chunk_size == 1800
            load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_merged_replay_30min_excl.mat']); %info of sleep in time bins
        elseif time_chunk_size == 3600
            load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_merged_replay_60min_excl.mat']); %info of sleep in time bins
        end
    elseif strcmp(rest_option,'awake')
        if time_chunk_size == 900
            load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_awake_replay_15min_excl.mat']); %info of sleep in time bins
            %         load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_merged_replay_60min_excl.mat']); %info of sleep in time bins
        elseif time_chunk_size == 1800
            load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_awake_replay_30min_excl.mat']); %info of sleep in time bins
        end
    elseif strcmp(rest_option,'sleep')
        if time_chunk_size == 900
            load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_sleep_replay_15min_excl.mat']); %info of sleep in time bins
            %         load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_merged_replay_60min_excl.mat']); %info of sleep in time bins
        elseif time_chunk_size == 1800
            load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_sleep_replay_30min_excl.mat']); %info of sleep in time bins
            
        end
    end
    num_sess = length(track_replay_events_R.track_replay_events);
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\thetaseq_scores_individual_laps.mat')
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\session_thetaseq_scores.mat')
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\behavioural_data.mat')
    
else
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
    load([path '\extracted_replay_plotting_info_excl.mat'])
    load([path '\rate_merged_replay.mat']) %info of sleep in time bins
    load([path '\extracted_awake_replay_track_completelap_excl.mat'])
    num_sess = length(track_replay_events);
    
end

if nargin < 4
    time_window = 1;
end

cnt = 1;
ses = 1;

 sleep_time_POST1= [];
 sleep_time_POST2 = [];

% for each session gather and calculate replay info
folders = data_folders_excl;
for s = 1 : num_sess

    sleep_time_POST1{s} = period_time(s).INTER_post.sleep - period_time(s).INTER_post.time_limits(1);
    sleep_time_POST2{s} = period_time(s).FINAL_post.sleep - period_time(s).FINAL_post.time_limits(1);
    
    if s < 5
        old_sess_index = s;
    else
        old_sess_index = s+1; % Skip session N-BLU_Day2_16x4
    end
    if isempty(bayesian_control)
        awake_local_replay_RT1(s) = length(track_replay_events(s).T3.T3_times); % RT1 events during RT1
        awake_local_replay_RT2(s) = length(track_replay_events(s).T4.T4_times); % RT2 events during RT2
        FINAL_RT1_events(s) = rate_replay(3).P(ses).sprintf('FINAL_post_%s',rest_option).Rat_num_events{cnt,time_window}; % POST2 RT1 events within first 30min of sleep
        FINAL_RT2_events(s) = rate_replay(4).P(ses).sprintf('FINAL_post_%s',rest_option).Rat_num_events{cnt,time_window}; % POST2 RT1 events within first 30min of sleep
        %FINAL_RT1_events(s) = length(track_replay_events(s).T3.FINAL_post_merged_cumulative_times); % POST2 RT1 events within first 30min of sleep
        %FINAL_RT2_events(s) = length(track_replay_events(s).T4.FINAL_post_merged_cumulative_times); % POST2 RT1 events within first 30min of sleep
    else
        % POST 1 - ABSOLUTE NUMBER OF EVENTS
        awake_local_replay_T1(s) = length(track_replay_events_F.track_replay_events(s).T1.T1_times); % T1 events during T1
        awake_local_replay_T2(s) = length(track_replay_events_F.track_replay_events(s).T2.T2_times); % T2 events during T2
        INTER_T1_events(s) = rate_replay(1).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_num_events{cnt,time_window}; % POST1 T1 events within first 30min of sleep
        INTER_T2_events(s) = rate_replay(2).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_num_events{cnt,time_window}; % POST1 T1 events within first 30min of sleep
        
        % POST 1 - RATE EVENTS (local)
%         awake_rate_replay_T1(s) = protocol(ses).T1(1).Rat_average_LOCAL_replay_rate(1,cnt); % T1 rate events during T1
%         awake_rate_replay_T2(s) = protocol(ses).T2(1).Rat_average_LOCAL_replay_rate(1,cnt); % T2 rate events during T2
        awake_rate_replay_T1(s) = awake_local_replay_T1(s)/(60*time_immobile(old_sess_index,1)); % T1 rate events during T1
        awake_rate_replay_T2(s) = awake_local_replay_T2(s)/(60*time_immobile(old_sess_index,2)); % T2 rate events during T2
        INTER_T1_rate_events(s) = rate_replay(1).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,time_window}; % POST1 T1 rate events within first 30min of sleep
        INTER_T2_rate_events(s) = rate_replay(2).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,time_window}; % POST1 T1 rate events within first 30min of sleep
        
        % POST 2 - ABSOLUTE NUMBER OF EVENTS
        awake_local_replay_RT1(s) = length(track_replay_events_R.track_replay_events(s).T1.T3_times); % RT1 events during RT1
        awake_local_replay_RT2(s) = length(track_replay_events_R.track_replay_events(s).T2.T4_times); % RT2 events during RT2
        FINAL_RT1_events(s) = rate_replay(1).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_num_events{cnt,time_window}; % POST2 RT1 events within first 30min of sleep
        FINAL_RT2_events(s) = rate_replay(2).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_num_events{cnt,time_window}; % POST2 RT1 events within first 30min of sleep
        %FINAL_RT1_events(s) = length(track_replay_events(s).T1.FINAL_post_merged_cumulative_times); % POST2 RT1 events within first 30min of sleep
        %FINAL_RT2_events(s) = length(track_replay_events(s).T2.FINAL_post_merged_cumulative_times); % POST2 RT1 events within first 30min of sleep
        
        % POST 2 - RATE EVENTS (local)
        awake_rate_replay_RT1(s) = awake_local_replay_RT1(s)/(60*time_immobile(old_sess_index,3)); % RT1 rate events during RT1 (by time immobile)
        awake_rate_replay_RT2(s) = awake_local_replay_RT2(s)/(60*time_immobile(old_sess_index,4)); % RT2 rate events during RT2 (by time immobile)
        FINAL_RT1_rate_events(s) = rate_replay(1).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_replay_rate{cnt,time_window}; % POST2 RT1 rate events within first 30min of sleep
        FINAL_RT2_rate_events(s) = rate_replay(2).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_replay_rate{cnt,time_window}; % POST2 RT1 rate events within first 30min of sleep
        
%         for time = 1:3
%             FINAL_RT1_rate_events_temporal(s,time) = rate_replay(1).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_replay_rate{cnt,time};
%             FINAL_RT2_rate_events_temporal(s,time) = rate_replay(2).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_replay_rate{cnt,time};
%         end
%         
%         for time = 1:6
%             INTER_T1_rate_events_temporal(s,time) = rate_replay(1).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,time};
%             INTER_T2_rate_events_temporal(s,time) = rate_replay(2).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,time};
%         end
        load([folders{s},'\extracted_position.mat'])
        %         load([folders{s},'\extracted_replay_events.mat'])
        load([folders{s},'\significant_replay_events_wcorr.mat'])
        load([folders{s},'\decoded_replay_events.mat'])
        load([folders{s},'\extracted_sleep_state.mat'])
        load([folders{s},'\extracted_laps.mat'])
      

        T1_SWR_event_index = [];
        T2_SWR_event_index = [];
        T3_SWR_event_index = [];
        T4_SWR_event_index = [];
        for event = 1:length(significant_replay_events.pre_ripple_threshold_index)
            if significant_replay_events.all_event_times(event) > position.linear(1).timestamps(1)...
                    & significant_replay_events.all_event_times(event) < position.linear(1).timestamps(end)
                T1_SWR_event_index = [T1_SWR_event_index significant_replay_events.pre_ripple_threshold_index(event)];
                
            elseif significant_replay_events.all_event_times(event) > position.linear(2).timestamps(1)...
                    & significant_replay_events.all_event_times(event) < position.linear(2).timestamps(end)
                T2_SWR_event_index = [T2_SWR_event_index significant_replay_events.pre_ripple_threshold_index(event)];
                
            elseif significant_replay_events.all_event_times(event) > position.linear(3).timestamps(1)...
                    & significant_replay_events.all_event_times(event) < position.linear(3).timestamps(end)
                T3_SWR_event_index = [T3_SWR_event_index significant_replay_events.pre_ripple_threshold_index(event)];
                
            elseif significant_replay_events.all_event_times(event) > position.linear(4).timestamps(1)...
                    & significant_replay_events.all_event_times(event) < position.linear(4).timestamps(end)
                T4_SWR_event_index = [T4_SWR_event_index significant_replay_events.pre_ripple_threshold_index(event)];
                
            end
            SWR_event_number(s,1) = length(T1_SWR_event_index); % Number of SWR events
            SWR_event_number(s,2) = length(T2_SWR_event_index);
            SWR_event_number(s,3) = length(T3_SWR_event_index);
            SWR_event_number(s,4) = length(T4_SWR_event_index);
            SWR_event_rate(s,1) = length(T1_SWR_event_index)/(60*time_immobile(old_sess_index,1)); % Rate of SWR events
            SWR_event_rate(s,2) = length(T2_SWR_event_index)/(60*time_immobile(old_sess_index,2));
            SWR_event_rate(s,3) = length(T3_SWR_event_index)/(60*time_immobile(old_sess_index,3));
            SWR_event_rate(s,4) = length(T4_SWR_event_index)/(60*time_immobile(old_sess_index,4));
        end
        
        
        SWR_event_time{s} = [];
        SWR_event_time{s} = significant_replay_events.all_event_times;
        for event = 1:length(SWR_event_time{s}) % SRW zscore 3
            if SWR_event_time{s}(event) < sleep_state.state_time.INTER_post_end & SWR_event_time{s}(event) > sleep_state.state_time.INTER_post_start
                SWR_event_normalised_time{s}(event) = SWR_event_time{s}(event) - sleep_state.state_time.INTER_post_start;
                SWR_event_normalised_time_awake{s}(event) = SWR_event_time{s}(event) - sleep_state.state_time.INTER_post_start;
                SWR_event_normalised_time_sleep{s}(event) = SWR_event_time{s}(event) - sleep_state.state_time.INTER_post_start;
                SWR_event_state_POST1{s}(event) = 0;
                
                for time = 1:size(period_time(s).INTER_post.sleep,1)
                    if SWR_event_time{s}(event) < period_time(s).INTER_post.sleep(time,2) & SWR_event_time{s}(event) > period_time(s).INTER_post.sleep(time,1)
                        SWR_event_state_POST1{s}(event) = 2;
                        SWR_event_normalised_time{s}(event) = SWR_event_time{s}(event)- period_time(s).INTER_post.sleep(time,1) + period_time(s).INTER_post.sleep_cumulative_time(time,1);
                    end
                end
                
                for time = 1:size(period_time(s).INTER_post.awake,1)
                    if SWR_event_time{s}(event) < period_time(s).INTER_post.awake(time,2) & SWR_event_time{s}(event) > period_time(s).INTER_post.awake(time,1)
                        SWR_event_state_POST1{s}(event) = 1;
                        SWR_event_normalised_time{s}(event) = SWR_event_time{s}(event) - period_time(s).INTER_post.awake(time,1) + period_time(s).INTER_post.awake_cumulative_time(time,1);
                    end
                end
                
            elseif SWR_event_time{s}(event) < sleep_state.state_time.FINAL_post_end & SWR_event_time{s}(event) > sleep_state.state_time.FINAL_post_start
                SWR_event_normalised_time{s}(event) = SWR_event_time{s}(event) - sleep_state.state_time.FINAL_post_start;
                SWR_event_state_POST2{s}(event) = 0;
                
                for time = 1:size(period_time(s).FINAL_post.sleep,1)
                    if SWR_event_time{s}(event) < period_time(s).FINAL_post.sleep(time,2) & SWR_event_time{s}(event) > period_time(s).FINAL_post.sleep(time,1)
                        SWR_event_state_POST2{s}(event) = 2;
                        SWR_event_normalised_time{s}(event) = SWR_event_time{s}(event) - period_time(s).FINAL_post.sleep(time,1) + period_time(s).FINAL_post.sleep_cumulative_time(time,1);
                    end
                end
                
                for time = 1:size(period_time(s).FINAL_post.awake,1)
                    if SWR_event_time{s}(event) < period_time(s).FINAL_post.awake(time,2) & SWR_event_time{s}(event) > period_time(s).FINAL_post.awake(time,1)
                        SWR_event_state_POST2{s}(event) = 1;
                        SWR_event_normalised_time{s}(event) = SWR_event_time{s}(event) - period_time(s).FINAL_post.awake(time,1) + period_time(s).FINAL_post.awake_cumulative_time(time,1);
                    end
                end
            else
                SWR_event_state_POST1{s}(event) = nan;
                SWR_event_state_POST2{s}(event) = nan;
                SWR_event_normalised_time{s}(event) = nan;
            end
        end
        
        event_time = SWR_event_normalised_time{s}(find(SWR_event_state_POST1{s}==1));
        event_time_edges = 0:time_chunk_size:3600;
        [SWR_counts_POST1_awake(s,:),edges] = histcounts(event_time,event_time_edges);
        
        event_time = SWR_event_normalised_time{s}(find(SWR_event_state_POST1{s}==2));
        event_time_edges = 0:time_chunk_size:3600;
        [SWR_counts_POST1_sleep(s,:),edges] = histcounts(event_time,event_time_edges);
        
        event_time = SWR_event_normalised_time{s}(find(SWR_event_state_POST2{s}==1));
        event_time_edges = 0:time_chunk_size:3600;
        [SWR_counts_POST2_awake(s,:),edges] = histcounts(event_time,event_time_edges);
        
        event_time = SWR_event_normalised_time{s}(find(SWR_event_state_POST2{s}==2));
        event_time_edges = 0:time_chunk_size:3600;
        [SWR_counts_POST2_sleep(s,:),edges] = histcounts(event_time,event_time_edges);

    end
    
    if cnt == 3 & ses == 2 % if last protocol session and ses = 2 (16x4)
        ses = ses+1;
        cnt = 1;
    elseif cnt == 4 % if last protocol session
        ses = ses+1;
        cnt = 1;
    else
        cnt = cnt + 1;
    end
end


PP =  plotting_parameters;
PP1.T1 = PP.T1;
PP1.T2 = PP.T2;

for n = 1:size(PP.T2,1)
    PP1.T2(6-n,:) = PP.T2(n,:);
end

cls = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[3,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];

%% Sleep distribution

nfig = figure('Color','w','Name',sprintf('Sleep distribution (%s)',rest_option));
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    sleepVector = false(1, round(diff(period_time(s).INTER_post.time_limits)));
    for i = 1:size(sleep_time_POST1{s}, 1)
        startIdx = sleep_time_POST1{s}(i, 1);
        endIdx = sleep_time_POST1{s}(i, 2);
        sleepVector(startIdx:endIdx) = true;
    end
    subplot(2,2,1)
    hold on
    plot(1:length(sleepVector),cumsum(sleepVector),'Color',cls(s,:))
    yline(1800,'r')
    xlabel('Binned time (s)')
    %     ylim([-0.5 1.5]);
    ylabel('Cumulative sleep (s)')
    set(gca,'FontSize',14)
    title('POST1')
    
    sleepVector = false(1, round(diff(period_time(s).FINAL_post.time_limits)));
    for i = 1:size(sleep_time_POST2{s}, 1)
        startIdx = sleep_time_POST2{s}(i, 1);
        endIdx = sleep_time_POST2{s}(i, 2);
        sleepVector(startIdx:endIdx) = true;
    end
    subplot(2,2,2)
    hold on
    plot(1:length(sleepVector),cumsum(sleepVector),'Color',cls(s,:))
    yline(1800,'r')
    xlabel('Binned time (s)')
    %     ylim([-0.5 1.5]);
    ylabel('Cumulative sleep (s)')
    set(gca,'FontSize',14)
    title('POST2')
end


%% Relationship between place cell firing during PRE SWR vs during POST SWR (demonstrate that the effect is experience-dependent due to consistent, inherent differences )

cls = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[3,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];

num_sess = length(track_replay_events_F.track_replay_events);
folders = data_folders_excl;
time_chunk = time_chunk_size;%1800 = 30 mins and 3600 = 60 mins
T1_cells = [];
T2_cells = [];
good_cells = [];
common_good_cells = [];
total_place_cell_RUN1 = [];
total_place_cell_RUN2 = [];
total_common_good_cells = [];

for s = 1 : num_sess
    cd(folders{s})
    load([folders{s},'\Bayesian controls\Only first exposure\extracted_place_fields_BAYESIAN.mat']);
    % all place cells with place field on one or both tracks
%     good_cells{1}{s} = place_fields_BAYESIAN.good_place_cells;
    total_place_cell_RUN1(1,s) =  length(place_fields_BAYESIAN.track(1).good_cells);
    total_place_cell_RUN1(2,s) =  length(place_fields_BAYESIAN.track(2).good_cells);
    % all place cells with place field only on one track
%     T1_cells{1}{s} = place_fields_BAYESIAN.track(1).unique_cells;
    [~, unique_index] = setdiff(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
    T1_cells{1}{s} = place_fields_BAYESIAN.track(1).good_cells(unique_index);
%     T2_cells{1}{s} = place_fields_BAYESIAN.track(2).unique_cells;
    [~, unique_index] = setdiff(place_fields_BAYESIAN.track(2).good_cells,place_fields_BAYESIAN.track(1).good_cells);
    T2_cells{1}{s} = place_fields_BAYESIAN.track(2).good_cells(unique_index);
    % Place cell with place field on both tracks
    common_good_cells{1}{s} = intersect(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
    total_common_good_cells(1,s) = length(common_good_cells{1}{s});
    
    load([folders{s},'\Bayesian controls\Only re-exposure\extracted_place_fields_BAYESIAN.mat'])
    % all place cells with place field on one or both tracks
%     good_cells{2}{s} = place_fields_BAYESIAN.good_place_cells;
    total_place_cell_RUN2(1,s) =  length(place_fields_BAYESIAN.track(1).good_cells);
    total_place_cell_RUN2(2,s) =  length(place_fields_BAYESIAN.track(2).good_cells);
    % all place cells with place field only on one track
%     T1_cells{1}{s} = place_fields_BAYESIAN.track(1).unique_cells;
    [~, unique_index] = setdiff(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
    T1_cells{2}{s} = place_fields_BAYESIAN.track(1).good_cells(unique_index);
%     T2_cells{1}{s} = place_fields_BAYESIAN.track(2).unique_cells;
    [~, unique_index] = setdiff(place_fields_BAYESIAN.track(2).good_cells,place_fields_BAYESIAN.track(1).good_cells);
    T2_cells{2}{s} = place_fields_BAYESIAN.track(2).good_cells(unique_index);
    % Place cell with place field on both tracks
    common_good_cells{2}{s} = intersect(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
    total_common_good_cells(2,s) = length(common_good_cells{2}{s});
    

    RUN1_T1_SWR_events{s} = [];RUN1_T2_SWR_events{s} = [];RUN2_T1_SWR_events{s} = [];RUN2_T2_SWR_events{s} = [];
    POST1_SWR_event{s} = [];
    POST2_SWR_event{s} = [];
    PRE_SWR_event{s} = [];
    PRE2_SWR_event{s} = [];
    RUN1_T1_spike_id{s} = [];RUN1_T2_spike_id{s} = [];RUN2_T1_spike_id{s} = [];RUN2_T2_spike_id{s} = [];
    PRE_spike_id{s} = [];
    PRE2_spike_id{s} = [];
    POST1_spike_id{s} = [];
    POST2_spike_id{s} = [];
    RUN1_T1_spike_count{s} = [];RUN1_T2_spike_count{s} = [];RUN2_T1_spike_count{s} = [];RUN2_T2_spike_count{s} = [];
    PRE_spike_count{s} = [];
    PRE2_spike_count{s} = [];
    POST1_spike_count{s} = [];
    POST2_spike_count{s} = [];

    
    load([folders{s},'\Bayesian controls\Only re-exposure\decoded_replay_events.mat']);
    decoded_replay_events2 = decoded_replay_events;
    load([folders{s},'\Bayesian controls\Only first exposure\decoded_replay_events.mat']);
    
    load([folders{s},'\Bayesian controls\Only re-exposure\significant_replay_events_wcorr.mat']);
    significant_replay_events2 = significant_replay_events;
    load([folders{s},'\Bayesian controls\Only first exposure\significant_replay_events_wcorr.mat']);
    
    % Find PRE, RUN1 and POST1 event
    for event = significant_replay_events.pre_ripple_threshold_index
        event_time = [decoded_replay_events(1).replay_events(event).timebins_edges(1)...
            decoded_replay_events(1).replay_events(event).timebins_edges(end)];
        
        % RUN1 T1
        if event_time(1) >= period_time(s).T1.time_limits(1) & event_time(2) <= period_time(s).T1.time_limits(2)
            RUN1_T1_SWR_events{s} = [RUN1_T1_SWR_events{s} event];
            RUN1_T1_spike_id{s} = [RUN1_T1_spike_id{s}; decoded_replay_events(1).replay_events(event).spikes(:,1)];
            
            this_event_spike_count = histcounts(decoded_replay_events(1).replay_events(event).spikes(:,1),[0.5:1:length(place_fields_BAYESIAN.track(1).raw)+0.5]);
            RUN1_T1_spike_count{s} = [RUN1_T1_spike_count{s}; this_event_spike_count];
        end
        
        % RUN1 T2
        if event_time(1) >= period_time(s).T2.time_limits(1) & event_time(2) <= period_time(s).T2.time_limits(2)
            RUN1_T2_SWR_events{s} = [RUN1_T2_SWR_events{s} event];
            RUN1_T2_spike_id{s} = [RUN1_T2_spike_id{s}; decoded_replay_events(1).replay_events(event).spikes(:,1)];
            
            this_event_spike_count = histcounts(decoded_replay_events(1).replay_events(event).spikes(:,1),[0.5:1:length(place_fields_BAYESIAN.track(1).raw)+0.5]);
            RUN1_T2_spike_count{s} = [RUN1_T2_spike_count{s}; this_event_spike_count];
        end
        
        % PRE SWR
        for n = 1:size(period_time(s).PRE.sleep,1)
            if event_time(1) >= period_time(s).PRE.sleep(n,1) & event_time(2) <= period_time(s).PRE.sleep(n,2)
                PRE_SWR_event{s} = [PRE_SWR_event{s} event];
                PRE_spike_id{s} = [PRE_spike_id{s}; decoded_replay_events(1).replay_events(event).spikes(:,1) ];
                
                this_event_spike_count = histcounts(decoded_replay_events(1).replay_events(event).spikes(:,1),[0.5:1:length(place_fields_BAYESIAN.track(1).raw)+0.5]);
                PRE_spike_count{s} = [PRE_spike_count{s}; this_event_spike_count];
            end
        end
        
        % POST1 SWR
        for n = 1:size(period_time(s).INTER_post.sleep,1)
            if event_time(1) >= period_time(s).INTER_post.sleep(n,1) & event_time(2) <= period_time(s).INTER_post.sleep(n,2)
                POST1_SWR_event{s} = [POST1_SWR_event{s} event];
                POST1_spike_id{s} = [decoded_replay_events(1).replay_events(event).spikes(:,1); POST1_spike_id{s}];
                
                this_event_spike_count = histcounts(decoded_replay_events(1).replay_events(event).spikes(:,1),[0.5:1:length(place_fields_BAYESIAN.track(1).raw)+0.5]);
                POST1_spike_count{s} = [POST1_spike_count{s}; this_event_spike_count];
            end
        end
    end
    
    % Find PRE (RUN2 template), RUN2 and POST2 event
    for event = significant_replay_events2.pre_ripple_threshold_index
        event_time = [decoded_replay_events2(1).replay_events(event).timebins_edges(1)...
            decoded_replay_events2(1).replay_events(event).timebins_edges(end)];
        
        % RUN2 T1
        if event_time(1) >= period_time(s).T3.time_limits(1) & event_time(2) <= period_time(s).T3.time_limits(2)
            RUN2_T1_SWR_events{s} = [RUN2_T1_SWR_events{s} event];
            RUN2_T1_spike_id{s} = [RUN2_T1_spike_id{s}; decoded_replay_events2(1).replay_events(event).spikes(:,1)];
            
            this_event_spike_count = histcounts(decoded_replay_events2(1).replay_events(event).spikes(:,1),[0.5:1:length(place_fields_BAYESIAN.track(1).raw)+0.5]);
            RUN2_T1_spike_count{s} = [RUN2_T1_spike_count{s}; this_event_spike_count];
        end
        
        % RUN2 T2
        if event_time(1) >= period_time(s).T4.time_limits(1) & event_time(2) <= period_time(s).T4.time_limits(2)
            RUN2_T2_SWR_events{s} = [RUN2_T2_SWR_events{s} event];
            RUN2_T2_spike_id{s} = [RUN2_T2_spike_id{s}; decoded_replay_events2(1).replay_events(event).spikes(:,1)];
            
            this_event_spike_count = histcounts(decoded_replay_events2(1).replay_events(event).spikes(:,1),[0.5:1:length(place_fields_BAYESIAN.track(1).raw)+0.5]);
            RUN2_T2_spike_count{s} = [RUN2_T2_spike_count{s}; this_event_spike_count];
        end
        
        
        
        
        % PRE2 SWR (PRE with RUN2 place cells)
        for n = 1:size(period_time(s).PRE.sleep,1)
            if event_time(1) >= period_time(s).PRE.sleep(n,1) & event_time(2) <= period_time(s).PRE.sleep(n,2)
                PRE2_SWR_event{s} = [PRE2_SWR_event{s} event];
                PRE2_spike_id{s} = [PRE2_spike_id{s}; decoded_replay_events2(1).replay_events(event).spikes(:,1)];
                
                this_event_spike_count = histcounts(decoded_replay_events2(1).replay_events(event).spikes(:,1),[0.5:1:length(place_fields_BAYESIAN.track(1).raw)+0.5]);
                PRE2_spike_count{s} = [PRE2_spike_count{s}; this_event_spike_count];
            end
        end
        
        
        % POST2 SWR
        for n = 1:size(period_time(s).FINAL_post.sleep,1)
            if event_time(1) >= period_time(s).FINAL_post.sleep(n,1) & event_time(2) <= period_time(s).FINAL_post.sleep(n,2)
                POST2_SWR_event{s} = [POST2_SWR_event{s} event];
                POST2_spike_id{s} = [decoded_replay_events2(1).replay_events(event).spikes(:,1); POST2_spike_id{s}];
                
                this_event_spike_count = histcounts(decoded_replay_events2(1).replay_events(event).spikes(:,1),[0.5:1:length(place_fields_BAYESIAN.track(1).raw)+0.5]);
                POST2_spike_count{s} = [POST2_spike_count{s}; this_event_spike_count];
            end
            
        end
    end
end


f11 = figure('Color','w','Name','total place cell number');
f11.Position = [450 180 1020 770];
subplot(2,2,1)
bar(total_place_cell_RUN1(1,:),'r','FaceAlpha',0.5)
hold on
bar(total_common_good_cells(1,:),'k','FaceAlpha',0.5)
bar(-total_place_cell_RUN1(2,:),'b','FaceAlpha',0.5)
bar(-total_common_good_cells(1,:),'k','FaceAlpha',0.5)
xticks(1:1:19)
yticks(-140:20:140)
set(gca,'FontSize',14)
xlabel('Session')
title('RUN1 place cell number')
legend('Track 1 place cell','Track 2 place cell','Common cells')

subplot(2,2,2)
bar(total_place_cell_RUN2(1,:),'r','FaceAlpha',0.5)
hold on
bar(total_common_good_cells(2,:),'k','FaceAlpha',0.5)
bar(-total_place_cell_RUN2(2,:),'b','FaceAlpha',0.5)
bar(-total_common_good_cells(2,:),'k','FaceAlpha',0.5)
xticks(1:1:19)
yticks(-140:20:140)
set(gca,'FontSize',14)
title('RUN2 place cell number')
xlabel('Session')
legend('Track 1 place cell','Track 2 place cell','Common cells')


%% Detecting SWR events based on track selective place cell firing 

for s = 1:length(PRE_spike_count)
    if isempty(PRE_spike_count{s})
        continue
    end
    
    PRE_T1_event{s} = [];
    PRE_T2_event{s} = [];
    
    for event = 1:size(PRE_spike_count{s},1)
        % proportion of track 1 cells active - track 2 cells active
        %         PRE_T1_T2_SWR_difference{s}(event) = abs(sum(PRE_spike_count{s}(event,T1_cells{1}{s}) > 0 )/length(T1_cells{1}{s}) ...
        %             - sum(PRE_spike_count{s}(event,T2_cells{1}{s}) > 0 )/length(T2_cells{1}{s}));
        T1_T2_cell_SWR_difference = sum(PRE_spike_count{s}(event,T1_cells{1}{s}) > 0 )/length(T1_cells{1}{s}) ...
            - sum(PRE_spike_count{s}(event,T2_cells{1}{s}) > 0 )/length(T2_cells{1}{s});
        
        if T1_T2_cell_SWR_difference >= 0.2
            
            PRE_T1_event{s} = [PRE_T1_event{s} event];
            
        elseif T1_T2_cell_SWR_difference <= -0.2
            PRE_T2_event{s} = [PRE_T2_event{s} event];
            
        end
    end
    
    POST1_T1_event{s} = [];
    POST1_T2_event{s} = [];
    for event = 1:size(POST1_spike_count{s},1)
        % proportion of track 1 cells active - track 2 cells active
        T1_T2_cell_SWR_difference = sum(POST1_spike_count{s}(event,T1_cells{1}{s}) > 0 )/length(T1_cells{1}{s}) ...
            - sum(POST1_spike_count{s}(event,T2_cells{1}{s}) > 0 )/length(T2_cells{1}{s});
        
        if T1_T2_cell_SWR_difference >= 0.2
            
            POST1_T1_event{s} = [POST1_T1_event{s} event];
            
        elseif T1_T2_cell_SWR_difference <= -0.2
            POST1_T2_event{s} = [POST1_T2_event{s} event];
            
        end
    end
    
    RUN1_T1_event{s} = [];
    RUN1_T2_event{s} = [];
    for event = 1:size(RUN1_T1_spike_count{s},1)
        % proportion of track 1 cells active - track 2 cells active
        T1_T2_cell_SWR_difference(event) = sum(RUN1_T1_spike_count{s}(event,T1_cells{1}{s}) > 0 )/length(T1_cells{1}{s}) ...
            - sum(RUN1_T1_spike_count{s}(event,T2_cells{1}{s}) > 0 )/length(T2_cells{1}{s});
        
        if T1_T2_cell_SWR_difference(event) >= 0.2
            
            RUN1_T1_event{s} = [RUN1_T1_event{s} event];
            
        end
    end
    
    for event = 1:size(RUN1_T2_spike_count{s},1)
        % proportion of track 1 cells active - track 2 cells active
        T1_T2_cell_SWR_difference = sum(RUN1_T2_spike_count{s}(event,T1_cells{1}{s}) > 0 )/length(T1_cells{1}{s}) ...
            - sum(RUN1_T2_spike_count{s}(event,T2_cells{1}{s}) > 0 )/length(T2_cells{1}{s});
        
        if T1_T2_cell_SWR_difference <= -0.2
            
            RUN1_T2_event{s} = [RUN1_T2_event{s} event];
            
        end
    end
      
    
    PRE2_T1_event{s} = [];
    PRE2_T2_event{s} = [];
    for event = 1:size(PRE2_spike_count{s},1)
        % proportion of track 1 cells active - track 2 cells active
        T1_T2_cell_SWR_difference = sum(PRE2_spike_count{s}(event,T1_cells{2}{s}) > 0 )/length(T1_cells{2}{s}) ...
            - sum(PRE2_spike_count{s}(event,T2_cells{2}{s}) > 0 )/length(T2_cells{2}{s});
        
        if T1_T2_cell_SWR_difference >= 0.2
            
            PRE2_T1_event{s} = [PRE2_T1_event{s} event];
            
        elseif T1_T2_cell_SWR_difference <= -0.2
            PRE2_T2_event{s} = [PRE2_T1_event{s} event];
            
        end
    end
    
    POST2_T1_event{s} = [];
    POST2_T2_event{s} = [];
    for event = 1:size(POST2_spike_count{s},1)
        % proportion of track 1 cells active - track 2 cells active
        T1_T2_cell_SWR_difference = sum(POST2_spike_count{s}(event,T1_cells{2}{s}) > 0 )/length(T1_cells{2}{s}) ...
            - sum(POST2_spike_count{s}(event,T2_cells{2}{s}) > 0 )/length(T2_cells{2}{s});
        
        if T1_T2_cell_SWR_difference >= 0.2
            
            POST2_T1_event{s} = [POST2_T1_event{s} event];
            
        elseif T1_T2_cell_SWR_difference <= -0.2
            POST2_T2_event{s} = [POST2_T2_event{s} event];
            
        end
    end
    
    RUN2_T1_event{s} = [];
    RUN2_T2_event{s} = [];
    for event = 1:size(RUN2_T1_spike_count{s},1)
        % proportion of track 1 cells active - track 2 cells active
        T1_T2_cell_SWR_difference(event) = sum(RUN2_T1_spike_count{s}(event,T1_cells{2}{s}) > 0 )/length(T1_cells{2}{s}) ...
            - sum(RUN2_T1_spike_count{s}(event,T2_cells{2}{s}) > 0 )/length(T2_cells{2}{s});
        
        if T1_T2_cell_SWR_difference(event) >= 0.2
            
            RUN2_T1_event{s} = [RUN2_T1_event{s} event];
%         elseif T1_T2_cell_SWR_difference(event) >= 0.1
%             if sum(RUN2_T1_spike_count{s}(event,T1_cells{2}{s}) > 0 )/length(T1_cells{2}{s}) 
%                 
        end
    end
    
    for event = 1:size(RUN2_T2_spike_count{s},1)
        % proportion of track 1 cells active - track 2 cells active
        T1_T2_cell_SWR_difference = sum(RUN2_T2_spike_count{s}(event,T1_cells{2}{s}) > 0 )/length(T1_cells{2}{s}) ...
            - sum(RUN2_T2_spike_count{s}(event,T2_cells{2}{s}) > 0 )/length(T2_cells{2}{s});
        
        if T1_T2_cell_SWR_difference <= -0.2
            
            RUN2_T2_event{s} = [RUN2_T2_event{s} event];
            
        end
    end
    %     subplot(4,5,s)
    %     histogram(PRE_T1_T2_SWR_difference{s},0:0.05:1,'Normalization','cdf')
    %     hold on
    %     histogram(POST1_T1_T2_SWR_difference{s},0:0.05:1,'Normalization','cdf')
    %     [SWR_difference_hist_PRE,~] = histcounts(PRE_T1_T2_SWR_difference{s},0:0.01:1);
    %     [SWR_difference_hist_POST,~] = histcounts(PRE_T1_T2_SWR_difference{s},0:0.01:1);
    %
    %     [~,p_value(s)] = kstest2(SWR_difference_hist_PRE,SWR_difference_hist_POST)
    % %     histogram(POST2_T1_T2_SWR_difference{s},0:0.1:1,'Normalization','probability')
    %     legend('PRE','POST1','POST2')
end



PP =  plotting_parameters;
PP1.T1 = PP.T1;
PP1.T2 = PP.T2;

for n = 1:size(PP.T2,1)
    PP1.T2(6-n,:) = PP.T2(n,:);
end

cls = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[3,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];


%% PRE RUN1 POST1 common cell participation

RUN1_participation = [];
POST1_participation =[];
PRE_participation = [];
PRE_FR = [];
POST1_FR = [];
RUN1_FR = [];
PRE_FR_difference = [];
POST1_FR_difference = [];
RUN1_FR_difference = [];
RUN1_cell = [];

RUN2_participation = [];
POST2_participation =[];
PRE2_participation = [];
PRE2_FR = [];
POST2_FR = [];
RUN2_FR = [];
PRE2_FR_difference = [];
POST2_FR_difference = [];
RUN2_FR_difference = [];
RUN2_cell = [];

for s = 1 : num_sess
    %     nexttile
    if isempty(PRE_spike_count{s} )
        continue
    end
    if isempty(POST1_spike_count{s} )
        continue
    end
    
    %     for cell = 1:length(T1_cells{1}{s})
    %         RUN1_participation = [RUN1_participation sum(RUN1_T1_spike_count{s}(:,T1_cells{1}{s}(cell)) > 0)];
    %         PRE_participation  = [PRE_participation sum(PRE_spike_count{s}(:,T1_cells{1}{s}(cell)) > 0) ];
    %         POST1_participation  = [POST1_participation sum(POST1_spike_count{s}(:,T1_cells{1}{s}(cell)) > 0) ];
    %         PRE_FR = [PRE_FR sum(PRE_spike_count{s}(:,T1_cells{1}{s}(cell)),1)]; % spike count
    %         POST1_FR = [POST1_FR sum(POST1_spike_count{s}(:,T1_cells{1}{s}(cell)),1)]; % spike count
    %         RUN1_FR = [RUN1_FR sum(RUN1_T1_spike_count{s}(:,T1_cells{1}{s}(cell)))];
    %     end
    
    %     for cell = 1:length(T2_cells{1}{s})
    %         RUN1_participation = [RUN1_participation sum(RUN1_T2_spike_count{s}(:,T2_cells{1}{s}(cell)) > 0)];
    %         PRE_participation  = [PRE_participation sum(PRE_spike_count{s}(:,T2_cells{1}{s}(cell)) > 0) ];
    %         POST1_participation  = [POST1_participation sum(POST1_spike_count{s}(:,T2_cells{1}{s}(cell)) > 0) ];
    %         PRE_FR = [PRE_FR sum(PRE_spike_count{s}(:,T2_cells{1}{s}(cell)),1)]; % spike count
    %         POST1_FR = [POST1_FR sum(POST1_spike_count{s}(:,T2_cells{1}{s}(cell)),1)]; % spike count
    %         RUN1_FR = [RUN1_FR sum(RUN1_T2_spike_count{s}(:,T2_cells{1}{s}(cell)))];
    %     end
    
    for cell = 1:length(common_good_cells{1}{s})
%         temp_participation = sum(RUN1_T1_spike_count{s}(RUN1_T1_event{s},common_good_cells{1}{s}(cell)) > 0)...
%             -sum(RUN1_T2_spike_count{s}(RUN1_T2_event{s},common_good_cells{1}{s}(cell)) > 0);
%         
        RUN1_participation = [RUN1_participation sum(RUN1_T1_spike_count{s}(RUN1_T1_event{s},common_good_cells{1}{s}(cell)) > 0)-...
            sum(RUN1_T2_spike_count{s}(RUN1_T2_event{s},common_good_cells{1}{s}(cell)) > 0)];
        POST1_participation = [POST1_participation sum(POST1_spike_count{s}(POST1_T1_event{s},common_good_cells{1}{s}(cell)) > 0)-...
            sum(POST1_spike_count{s}(POST1_T2_event{s},common_good_cells{1}{s}(cell)) > 0)];
        PRE_participation = [PRE_participation sum(PRE_spike_count{s}(PRE_T1_event{s},common_good_cells{1}{s}(cell)) > 0)-...
            sum(PRE_spike_count{s}(PRE_T2_event{s},common_good_cells{1}{s}(cell)) > 0)];
        
        PRE_FR = [PRE_FR sum(PRE_spike_count{s}(:,common_good_cells{1}{s}(cell)),1)]; % spike count
        POST1_FR = [POST1_FR sum(POST1_spike_count{s}(:,common_good_cells{1}{s}(cell)),1)]; % spike count
        RUN1_FR = [RUN1_FR sum(RUN1_T1_spike_count{s}(:,common_good_cells{1}{s}(cell)))+...
            sum(RUN1_T2_spike_count{s}(:,common_good_cells{1}{s}(cell)))];
        
        
        T1_FR = mean(PRE_spike_count{s}(PRE_T1_event{s},common_good_cells{1}{s}(cell)),1);
        T1_FR(isnan(T1_FR)) = 0;
        T2_FR = mean(PRE_spike_count{s}(PRE_T2_event{s},common_good_cells{1}{s}(cell)),1);
        T2_FR(isnan(T2_FR)) = 0;
        
        PRE_FR_difference = [PRE_FR_difference T1_FR - T2_FR];
        
        T1_FR = mean(POST1_spike_count{s}(POST1_T1_event{s},common_good_cells{1}{s}(cell)),1);
        T1_FR(isnan(T1_FR)) = 0;
        T2_FR = mean(POST1_spike_count{s}(POST1_T2_event{s},common_good_cells{1}{s}(cell)),1);
        T2_FR(isnan(T2_FR)) = 0;
        
        POST1_FR_difference = [POST1_FR_difference T1_FR - T2_FR]; % spike count difference
        
        T1_FR = mean(RUN1_T1_spike_count{s}(RUN1_T1_event{s},common_good_cells{1}{s}(cell)),1);
        T1_FR(isnan(T1_FR)) = 0;
        T2_FR = mean(RUN1_T2_spike_count{s}(RUN1_T2_event{s},common_good_cells{1}{s}(cell)),1);
        T2_FR(isnan(T2_FR)) = 0;
        
        RUN1_FR_difference = [RUN1_FR_difference T1_FR - T2_FR]; % spike count difference
        RUN1_cell = [RUN1_cell s];
    end
    
    
end



for s = 1 : num_sess
    %     nexttile
    if isempty(PRE2_spike_count{s} )
        continue
    end
    if isempty(POST2_spike_count{s} )
        continue
    end
    
    for cell = 1:length(common_good_cells{2}{s})
        RUN2_participation = [RUN2_participation sum(RUN2_T1_spike_count{s}(RUN2_T1_event{s},common_good_cells{2}{s}(cell)) > 0)-...
            sum(RUN2_T2_spike_count{s}(RUN2_T2_event{s},common_good_cells{2}{s}(cell)) > 0)];
        POST2_participation = [POST2_participation sum(POST2_spike_count{s}(POST2_T1_event{s},common_good_cells{2}{s}(cell)) > 0)-...
            sum(POST2_spike_count{s}(POST2_T2_event{s},common_good_cells{2}{s}(cell)) > 0)];
        PRE2_participation = [PRE2_participation sum(PRE2_spike_count{s}(PRE2_T1_event{s},common_good_cells{2}{s}(cell)) > 0)-...
            sum(PRE2_spike_count{s}(PRE2_T2_event{s},common_good_cells{2}{s}(cell)) > 0)];

        
        PRE2_FR = [PRE2_FR sum(PRE2_spike_count{s}(:,common_good_cells{2}{s}(cell)),1)]; % spike count
        POST2_FR = [POST2_FR sum(POST2_spike_count{s}(:,common_good_cells{2}{s}(cell)),1)]; % spike count
        RUN2_FR = [RUN2_FR sum(RUN2_T1_spike_count{s}(:,common_good_cells{2}{s}(cell)))+...
            sum(RUN2_T2_spike_count{s}(:,common_good_cells{2}{s}(cell)))];
        
        
        T1_FR = mean(PRE2_spike_count{s}(PRE2_T1_event{s},common_good_cells{2}{s}(cell)),1);
        T1_FR(isnan(T1_FR)) = 0;
        T2_FR = mean(PRE2_spike_count{s}(PRE2_T2_event{s},common_good_cells{2}{s}(cell)),1);
        T2_FR(isnan(T2_FR)) = 0;
        
        PRE2_FR_difference = [PRE2_FR_difference T1_FR - T2_FR];
        
        T1_FR = mean(POST2_spike_count{s}(POST2_T1_event{s},common_good_cells{2}{s}(cell)),1);
        T1_FR(isnan(T1_FR)) = 0;
        T2_FR = mean(POST2_spike_count{s}(POST2_T2_event{s},common_good_cells{2}{s}(cell)),1);
        T2_FR(isnan(T2_FR)) = 0;
        
        POST2_FR_difference = [POST2_FR_difference T1_FR - T2_FR]; % spike count difference
        
        T1_FR = mean(RUN2_T1_spike_count{s}(RUN2_T1_event{s},common_good_cells{2}{s}(cell)),1);
        T1_FR(isnan(T1_FR)) = 0;
        T2_FR = mean(RUN2_T2_spike_count{s}(RUN2_T2_event{s},common_good_cells{2}{s}(cell)),1);
        T2_FR(isnan(T2_FR)) = 0;
        
        RUN2_FR_difference = [RUN2_FR_difference T1_FR - T2_FR]; % spike count difference
        RUN2_cell = [RUN2_cell s];
    end
end
%     POST2_spike_count{s}(:,T1_cells{s}) - POST2_spike_count{s}(:,T2_cells{s})
%     PRE_spike_count{s}(:,[T1_cells{s} T2_cells{s}])
new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];


nfig = figure('Color','w','Name','PRE VS RUN1 VS POST1 session combined');
nfig.Position = [940 100 1270 950];
orient(nfig,'landscape')


subplot(3,3,1)
new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(RUN1_FR(x),PRE_FR(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(RUN1_FR))
mdl = fitlm(RUN1_FR',PRE_FR');
[pval,~,~] = coefTest(mdl);
x =[min(RUN1_FR) max(RUN1_FR)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('RUN1 total spike count')
ylabel('PRE total spike count')
set(gca,'FontSize',14)
sgtitle(sprintf('RUN1 SWR FR vs PRE SWR FR(%s)',rest_option));



subplot(3,3,2)
new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(RUN1_FR(x),POST1_FR(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(RUN1_FR))
mdl = fitlm(RUN1_FR',POST1_FR');
[pval,~,~] = coefTest(mdl);
x =[min(RUN1_FR) max(RUN1_FR)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('RUN1 total spike count')
ylabel('POST1 total spike count')
set(gca,'FontSize',14)
sgtitle(sprintf('RUN1 SWR FR vs POST1 SWR FR(%s)',rest_option));


subplot(3,3,3)
new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(PRE_FR(x),POST1_FR(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(PRE_FR))
mdl = fitlm(PRE_FR',POST1_FR');
[pval,~,~] = coefTest(mdl);
x =[min(PRE_FR) max(PRE_FR)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('PRE total spike count')
ylabel('POST1 total spike count')
set(gca,'FontSize',14)
sgtitle(sprintf('PRE SWR FR vs POST1 SWR FR(%s)',rest_option));


% 
% % nfig = figure('Color','w','Name','SWR T1 and T2 selective place cell firing');
% % nfig.Position = [940 100 920 900];
% % orient(nfig,'landscape')
% 
% subplot(3,3,4)
% new_cls = cls(1,:);
% hold on
% arrayfun(@(x) scatter(RUN1_participation(x),PRE_participation(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(RUN1_participation))
% 
% mdl = fitlm(RUN1_participation',PRE_participation');
% [pval,~,~] = coefTest(mdl);
% x =[min(RUN1_participation) max(RUN1_participation)];
% b = mdl.Coefficients.Estimate';
% y_est = polyval(fliplr(b),x);
% 
% %     set(gca,'FontSize',14)
% if pval <= 0.05
%     plot(x,y_est,'r:')
%     %         xlim([-30 120])
% 
% %     title(sprintf('Session %i',s),'Color','red')
%     %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%     text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
% else
%     plot(x,y_est,'k:')
%     %         xlim([-30 120])
% %     title(sprintf('Session %i',s))
%     %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%     text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
% end
% xline(0,'--')
% yline(0,'--')
% xlabel('RUN1 replay participation')
% ylabel('PRE replay participation')
% set(gca,'FontSize',14)
% % sgtitle(sprintf('PRE SWR FR vs POST1 SWR FR(%s)',rest_option));
% 
% 
% subplot(3,3,5)
% 
% new_cls = cls(1,:);
% hold on
% arrayfun(@(x) scatter(RUN1_participation(x),POST1_participation(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(RUN1_participation))
% 
% mdl = fitlm(RUN1_participation',POST1_participation');
% [pval,~,~] = coefTest(mdl);
% x =[min(RUN1_participation) max(RUN1_participation)];
% b = mdl.Coefficients.Estimate';
% y_est = polyval(fliplr(b),x);
% 
% %     set(gca,'FontSize',14)
% if pval <= 0.05
%     plot(x,y_est,'r:')
%     %         xlim([-30 120])
% 
% %     title(sprintf('Session %i',s),'Color','red')
%     %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%     text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
% else
%     plot(x,y_est,'k:')
%     %         xlim([-30 120])
% %     title(sprintf('Session %i',s))
%     %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%     text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
% end
% xline(0,'--')
% yline(0,'--')
% xlabel('RUN1 replay participation')
% ylabel('POST1 replay participation')
% set(gca,'FontSize',14)
% % sgtitle(sprintf('PRE SWR FR vs POST1 SWR FR(%s)',rest_option));
% 
% 
% 
% subplot(3,3,6)
% 
% new_cls = cls(1,:);
% hold on
% arrayfun(@(x) scatter(PRE_participation(x),POST1_participation(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(PRE_participation))
% 
% mdl = fitlm(PRE_participation',POST1_participation');
% [pval,~,~] = coefTest(mdl);
% x =[min(PRE_participation) max(PRE_participation)];
% b = mdl.Coefficients.Estimate';
% y_est = polyval(fliplr(b),x);
% 
% %     set(gca,'FontSize',14)
% if pval <= 0.05
%     plot(x,y_est,'r:')
%     %         xlim([-30 120])
% 
% %     title(sprintf('Session %i',s),'Color','red')
%     %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%     text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
% else
%     plot(x,y_est,'k:')
%     %         xlim([-30 120])
% %     title(sprintf('Session %i',s))
%     %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%     text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
% end
% xline(0,'--')
% yline(0,'--')
% xlabel('PRE replay participation')
% ylabel('POST1 replay participation')
% set(gca,'FontSize',14)
% % sgtitle(sprintf('PRE SWR FR vs POST1 SWR FR(%s)',rest_option));
% 


subplot(3,3,4)

new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(RUN1_FR_difference(x),PRE_FR_difference(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(PRE_FR_difference))

mdl = fitlm(RUN1_FR_difference',PRE_FR_difference');
[pval,~,~] = coefTest(mdl);
x =[min(RUN1_FR_difference) max(RUN1_FR_difference)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('RUN1 SWR firing difference')
ylabel('PRE SWR firing difference')
set(gca,'FontSize',14)


subplot(3,3,5)

new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(RUN1_FR_difference(x),POST1_FR_difference(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(POST1_FR_difference))

mdl = fitlm(RUN1_FR_difference',POST1_FR_difference');
[pval,~,~] = coefTest(mdl);
x =[min(RUN1_FR_difference) max(RUN1_FR_difference)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('RUN1 SWR firing difference')
ylabel('POST1 SWR firing difference')
set(gca,'FontSize',14)


subplot(3,3,6)

new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(PRE_FR_difference(x),POST1_FR_difference(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(PRE_FR_difference))

mdl = fitlm(PRE_FR_difference',POST1_FR_difference');
[pval,~,~] = coefTest(mdl);
x =[min(PRE_FR_difference) max(PRE_FR_difference)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('PRE SWR firing difference')
ylabel('POST1 SWR firing difference')
set(gca,'FontSize',14)
% sgtitle(sprintf('PRE SWR FR vs POST1 SWR FR(%s)',rest_option));




subplot(3,3,7)

new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(RUN1_participation(x),PRE_participation(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(PRE_participation))

mdl = fitlm(RUN1_participation',PRE_participation');
[pval,~,~] = coefTest(mdl);
x =[min(RUN1_participation) max(RUN1_participation)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('RUN1 SWR track difference')
ylabel('PRE SWR track difference')
set(gca,'FontSize',14)



subplot(3,3,8)

new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(RUN1_participation(x),POST1_participation(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(POST1_participation))

mdl = fitlm(RUN1_participation',POST1_participation');
[pval,~,~] = coefTest(mdl);
x =[min(RUN1_participation) max(RUN1_participation)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('RUN1 SWR track difference')
ylabel('POST1 SWR track difference')
set(gca,'FontSize',14)



subplot(3,3,9)

new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(PRE_participation(x),POST1_participation(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(POST1_participation))

mdl = fitlm(PRE_participation',POST1_participation');
[pval,~,~] = coefTest(mdl);
x =[min(PRE_participation) max(PRE_participation)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('PRE SWR track difference')
ylabel('POST1 SWR track difference')
set(gca,'FontSize',14)

%% PRE VS RUN1 VS POST1 (Per session)
nfig = figure('Color','w','Name','PRE SWR vs POST1 SWR total FR (First exposure)');
nfig.Position = [940 100 1270 950];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    
    if sum(RUN1_cell == s) == 0
        continue
    end
    
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     if isempty(PRE_FR_difference(RUN1_cell == s))
%         continue
%     end
    awake = [PRE_FR(RUN1_cell == s)]; % awake number difference
    sleep = [POST1_FR(RUN1_cell == s)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
%     ylim([-6 6])
%     xlim([-6 6])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
xlabel('PRE SWR total spike counts')
ylabel('POST1 SWR total spike counts')
sgtitle(sprintf('PRE SWR vs POST1 SWR total Firing (First exposure)(%s)',rest_option));


nfig = figure('Color','w','Name','RUN1 SWR vs PRE SWR FR difference (First exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    
    if sum(RUN1_cell == s) == 0
        continue
    end
    
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     if isempty(PRE_FR_difference(RUN1_cell == s))
%         continue
%     end
    awake = [RUN1_FR_difference(RUN1_cell == s)]; % awake number difference
    sleep = [PRE_FR_difference(RUN1_cell == s)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-6 6])
    xlim([-6 6])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
xlabel('RUN1 SWR FR difference (spikes/event)')
ylabel('PRE SWR FR difference (spikes/event)')
sgtitle(sprintf('RUN1 SWR vs PRE SWR FR difference first exposure(%s)',rest_option));



nfig = figure('Color','w','Name','RUN1 SWR vs POST1 SWR FR difference (First exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    
    if sum(RUN1_cell == s) == 0
        continue
    end
    
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     if isempty(PRE_FR_difference(RUN1_cell == s))
%         continue
%     end
    awake = [RUN1_FR_difference(RUN1_cell == s)]; % awake number difference
    sleep = [POST1_FR_difference(RUN1_cell == s)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-6 6])
    xlim([-6 6])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
xlabel('RUN1 SWR FR difference (spikes/event)')
ylabel('POST1 SWR FR difference (spikes/event)')
sgtitle(sprintf('RUN1 SWR vs POST1 SWR FR difference first exposure(%s)',rest_option));


nfig = figure('Color','w','Name','PRE SWR vs POST1 SWR FR difference (First exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    
    if sum(RUN1_cell == s) == 0
        continue
    end
    
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     if isempty(PRE_FR_difference(RUN1_cell == s))
%         continue
%     end
    awake = [PRE_FR_difference(RUN1_cell == s)]; % awake number difference
    sleep = [POST1_FR_difference(RUN1_cell == s)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-6 6])
    xlim([-6 6])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
xlabel('PRE1 SWR FR difference (spikes/event)')
ylabel('POST1 SWR FR difference (spikes/event)')
sgtitle(sprintf('PRE1 SWR vs POST1 SWR FR difference first exposure(%s)',rest_option));




nfig = figure('Color','w','Name','RUN1 SWR vs PRE SWR track difference (First exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    
    if sum(RUN1_cell == s) == 0
        continue
    end
    
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     if isempty(PRE_FR_difference(RUN1_cell == s))
%         continue
%     end
    awake = [RUN1_participation(RUN1_cell == s)]; % awake number difference
    sleep = [PRE_participation(RUN1_cell == s)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-20 20])
    xlim([-20 20])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
xlabel('RUN1 SWR track difference')
ylabel('PRE SWR track difference')
sgtitle(sprintf('RUN1 SWR vs PRE SWR track difference first exposure(%s)',rest_option));



nfig = figure('Color','w','Name','RUN1 SWR vs POST1 SWR track difference (First exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    
    if sum(RUN1_cell == s) == 0
        continue
    end
    
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     if isempty(PRE_FR_difference(RUN1_cell == s))
%         continue
%     end
    awake = [RUN1_participation(RUN1_cell == s)]; % awake number difference
    sleep = [POST1_participation(RUN1_cell == s)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-20 20])
    xlim([-20 20])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
xlabel('RUN1 SWR track difference ')
ylabel('POST1 SWR track difference')
sgtitle(sprintf('RUN1 SWR vs POST1 SWR track difference first exposure(%s)',rest_option));




nfig = figure('Color','w','Name','PRE SWR vs POST1 SWR track difference (First exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    
    if sum(RUN1_cell == s) == 0
        continue
    end
    
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     if isempty(PRE_FR_difference(RUN1_cell == s))
%         continue
%     end
    awake = [PRE_participation(RUN1_cell == s)]; % awake number difference
    sleep = [POST1_participation(RUN1_cell == s)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-20 20])
    xlim([-20 20])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
xlabel('PRE SWR track difference ')
ylabel('POST1 SWR track difference')
sgtitle(sprintf('PRE SWR vs POST1 SWR track difference first exposure(%s)',rest_option));


%% PRE2 RUN2 POST2
nfig = figure('Color','w','Name','PRE VS RUN2 VS POST2 session combined');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')


subplot(3,3,1)
new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(RUN2_FR(x),PRE2_FR(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(RUN2_FR))
mdl = fitlm(RUN2_FR',PRE2_FR');
[pval,~,~] = coefTest(mdl);
x =[min(RUN2_FR) max(RUN2_FR)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('RUN2 total spike count')
ylabel('PRE total spike count')
set(gca,'FontSize',14)
sgtitle(sprintf('RUN2 SWR FR vs PRE SWR FR(%s)',rest_option));



subplot(3,3,2)
new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(RUN2_FR(x),POST2_FR(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(RUN2_FR))
mdl = fitlm(RUN2_FR',POST2_FR');
[pval,~,~] = coefTest(mdl);
x =[min(RUN2_FR) max(RUN2_FR)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('RUN2 total spike count')
ylabel('POST2 total spike count')
set(gca,'FontSize',14)
sgtitle(sprintf('RUN2 SWR FR vs POST2 SWR FR(%s)',rest_option));


subplot(3,3,3)
new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(PRE2_FR(x),POST2_FR(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(PRE2_FR))
mdl = fitlm(PRE2_FR',POST2_FR');
[pval,~,~] = coefTest(mdl);
x =[min(PRE2_FR) max(PRE2_FR)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('PRE total spike count')
ylabel('POST2 total spike count')
set(gca,'FontSize',14)


% 
% % nfig = figure('Color','w','Name','SWR T1 and T2 selective place cell firing');
% % nfig.Position = [940 100 920 900];
% % orient(nfig,'landscape')
% 
% subplot(3,3,4)
% new_cls = cls(1,:);
% hold on
% arrayfun(@(x) scatter(RUN2_participation(x),PRE2_participation(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(RUN2_participation))
% 
% mdl = fitlm(RUN2_participation',PRE2_participation');
% [pval,~,~] = coefTest(mdl);
% x =[min(RUN2_participation) max(RUN2_participation)];
% b = mdl.Coefficients.Estimate';
% y_est = polyval(fliplr(b),x);
% 
% %     set(gca,'FontSize',14)
% if pval <= 0.05
%     plot(x,y_est,'r:')
%     %         xlim([-30 120])
% 
% %     title(sprintf('Session %i',s),'Color','red')
%     %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%     text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
% else
%     plot(x,y_est,'k:')
%     %         xlim([-30 120])
% %     title(sprintf('Session %i',s))
%     %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%     text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
% end
% xline(0,'--')
% yline(0,'--')
% xlabel('RUN2 replay participation')
% ylabel('PRE replay participation')
% set(gca,'FontSize',14)
% % sgtitle(sprintf('PRE SWR FR vs POST1 SWR FR(%s)',rest_option));
% 
% 
% subplot(3,3,5)
% 
% new_cls = cls(1,:);
% hold on
% arrayfun(@(x) scatter(RUN2_participation(x),POST2_participation(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(RUN2_participation))
% 
% mdl = fitlm(RUN2_participation',POST2_participation');
% [pval,~,~] = coefTest(mdl);
% x =[min(RUN2_participation) max(RUN2_participation)];
% b = mdl.Coefficients.Estimate';
% y_est = polyval(fliplr(b),x);
% 
% %     set(gca,'FontSize',14)
% if pval <= 0.05
%     plot(x,y_est,'r:')
%     %         xlim([-30 120])
% 
% %     title(sprintf('Session %i',s),'Color','red')
%     %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%     text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
% else
%     plot(x,y_est,'k:')
%     %         xlim([-30 120])
% %     title(sprintf('Session %i',s))
%     %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%     text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
% end
% xline(0,'--')
% yline(0,'--')
% xlabel('RUN2 replay participation')
% ylabel('POST2 replay participation')
% set(gca,'FontSize',14)
% % sgtitle(sprintf('PRE SWR FR vs POST1 SWR FR(%s)',rest_option));
% 
% 
% 
% subplot(3,3,6)
% 
% new_cls = cls(1,:);
% hold on
% arrayfun(@(x) scatter(PRE2_participation(x),POST2_participation(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(PRE2_participation))
% 
% mdl = fitlm(PRE2_participation',POST2_participation');
% [pval,~,~] = coefTest(mdl);
% x =[min(PRE2_participation) max(PRE2_participation)];
% b = mdl.Coefficients.Estimate';
% y_est = polyval(fliplr(b),x);
% 
% %     set(gca,'FontSize',14)
% if pval <= 0.05
%     plot(x,y_est,'r:')
%     %         xlim([-30 120])
% 
% %     title(sprintf('Session %i',s),'Color','red')
%     %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%     text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
% else
%     plot(x,y_est,'k:')
%     %         xlim([-30 120])
% %     title(sprintf('Session %i',s))
%     %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%     text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
% end
% xline(0,'--')
% yline(0,'--')
% xlabel('PRE replay participation')
% ylabel('POST2 replay participation')
% set(gca,'FontSize',14)
% % sgtitle(sprintf('PRE SWR FR vs POST1 SWR FR(%s)',rest_option));

subplot(3,3,4)

new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(RUN2_FR_difference(x),PRE2_FR_difference(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(PRE2_FR_difference))

mdl = fitlm(RUN2_FR_difference',PRE2_FR_difference');
[pval,~,~] = coefTest(mdl);
x =[min(RUN2_FR_difference) max(RUN2_FR_difference)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('RUN2 SWR firing difference')
ylabel('PRE SWR firing difference')
set(gca,'FontSize',14)


subplot(3,3,5)

new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(RUN2_FR_difference(x),POST2_FR_difference(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(RUN2_FR_difference))

mdl = fitlm(RUN2_FR_difference',POST2_FR_difference');
[pval,~,~] = coefTest(mdl);
x =[min(RUN2_FR_difference) max(RUN2_FR_difference)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('RUN1 SWR firing difference')
ylabel('POST2 SWR firing difference')
set(gca,'FontSize',14)


subplot(3,3,6)

new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(PRE2_FR_difference(x),POST2_FR_difference(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(PRE2_FR_difference))

mdl = fitlm(PRE2_FR_difference',POST2_FR_difference');
[pval,~,~] = coefTest(mdl);
x =[min(PRE2_FR_difference) max(PRE2_FR_difference)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('PRE SWR firing difference')
ylabel('POST2 SWR firing difference')
set(gca,'FontSize',14)
% sgtitle(sprintf('PRE SWR FR vs POST1 SWR FR(%s)',rest_option));


subplot(3,3,7)

new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(RUN2_participation(x),PRE2_participation(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(PRE2_participation))

mdl = fitlm(RUN2_participation',PRE2_participation');
[pval,~,~] = coefTest(mdl);
x =[min(RUN2_participation) max(RUN2_participation)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('RUN2 SWR track difference')
ylabel('PRE SWR track difference')
set(gca,'FontSize',14)



subplot(3,3,8)

new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(RUN2_participation(x),POST2_participation(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(POST2_participation))

mdl = fitlm(RUN2_participation',POST2_participation');
[pval,~,~] = coefTest(mdl);
x =[min(RUN2_participation) max(RUN2_participation)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('RUN2 SWR track difference')
ylabel('POST2 SWR track difference')
set(gca,'FontSize',14)



subplot(3,3,9)

new_cls = cls(1,:);
hold on
arrayfun(@(x) scatter(PRE2_participation(x),POST2_participation(x),20,new_cls,'filled','o','MarkerFaceAlpha',0.2),1:length(POST2_participation))

mdl = fitlm(PRE2_participation',POST2_participation');
[pval,~,~] = coefTest(mdl);
x =[min(PRE2_participation) max(PRE2_participation)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

%     set(gca,'FontSize',14)
if pval <= 0.05
    plot(x,y_est,'r:')
    %         xlim([-30 120])

%     title(sprintf('Session %i',s),'Color','red')
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
else
    plot(x,y_est,'k:')
    %         xlim([-30 120])
%     title(sprintf('Session %i',s))
    %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
end
xline(0,'--')
yline(0,'--')
xlabel('PRE SWR track difference')
ylabel('POST2 SWR track difference')
set(gca,'FontSize',14)


%% PRE VS RUN2 VS POST2 (Per session)
nfig = figure('Color','w','Name','PRE SWR vs POST2 SWR total FR (re exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    
    if sum(RUN2_cell == s) == 0
        continue
    end
    
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     if isempty(PRE_FR_difference(RUN1_cell == s))
%         continue
%     end
    awake = [PRE2_FR(RUN2_cell == s)]; % awake number difference
    sleep = [POST2_FR(RUN2_cell == s)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
%     ylim([-6 6])
%     xlim([-6 6])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
ylabel('PRE SWR total spike counts')
xlabel('POST2 SWR total spike counts')
sgtitle(sprintf('PRE SWR vs POST2 SWR total Firing (re exposure)(%s)',rest_option));


nfig = figure('Color','w','Name','RUN2 SWR vs PRE SWR FR difference (First exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    
    if sum(RUN2_cell == s) == 0
        continue
    end
    
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     if isempty(PRE_FR_difference(RUN1_cell == s))
%         continue
%     end
    awake = [RUN2_FR_difference(RUN2_cell == s)]; % awake number difference
    sleep = [PRE2_FR_difference(RUN2_cell == s)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-4 4])
    xlim([-4 4])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
ylabel('RUN2 SWR FR difference (spikes/event)')
xlabel('PRE SWR FR difference (spikes/event)')
sgtitle(sprintf('RUN2 SWR vs PRE SWR FR difference re-exposure(%s)',rest_option));



nfig = figure('Color','w','Name','RUN2 SWR vs POST2 SWR FR difference (First exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    
    if sum(RUN2_cell == s) == 0
        continue
    end
    
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     if isempty(PRE_FR_difference(RUN1_cell == s))
%         continue
%     end
    awake = [RUN2_FR_difference(RUN2_cell == s)]; % awake number difference
    sleep = [POST2_FR_difference(RUN2_cell == s)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-4 4])
    xlim([-4 4])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
ylabel('RUN2 SWR FR difference (spikes/event)')
xlabel('POST2 SWR FR difference (spikes/event)')
sgtitle(sprintf('RUN2 SWR vs POST2 SWR FR difference first exposure(%s)',rest_option));


nfig = figure('Color','w','Name','PRE SWR vs POST2 SWR FR difference (First exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    
    if sum(RUN2_cell == s) == 0
        continue
    end
    
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     if isempty(PRE_FR_difference(RUN1_cell == s))
%         continue
%     end
    awake = [PRE2_FR_difference(RUN2_cell == s)]; % awake number difference
    sleep = [POST2_FR_difference(RUN2_cell == s)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-4 4])
    xlim([-4 4])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
ylabel('PRE2 SWR FR difference (spikes/event)')
xlabel('POST2 SWR FR difference (spikes/event)')
sgtitle(sprintf('PRE SWR vs POST2 SWR FR difference first exposure(%s)',rest_option));





%% Looking at place cell participation in replay
% place cells with place fields on both tracks and asked whether the
% difference in the number of awake replay events a given cell participated
% in predict the observed difference in sleep replay rates for that cell
cls = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[3,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];

num_sess = length(track_replay_events_F.track_replay_events);
folders = data_folders_excl;
cell_replay_RUN1 = [];
cell_replay_RUN2 = [];
cell_replay_POST1 = [];
cell_replay_POST2 = [];
cell_replay_PRE = [];
track_difference_cell_RUN1 = [];
track_difference_cell_RUN2 = [];
track_difference_cell_POST1 = [];
track_difference_cell_POST2 = [];
track_difference_cell_PRE = [];
total_place_cell_RUN1 = [];
total_place_cell_RUN2 = [];
common_good_cells = [];

for track = 1:2
    replay_active_proportion_PRE{track} = [];
    replay_active_proportion_POST1{track} = [];
    replay_active_proportion_POST2{track} = [];
    replay_active_proportion_RUN1{track} = [];
    replay_active_proportion_RUN2{track} = [];
end

time_chunk = time_chunk_size;%1800 = 30 mins and 3600 = 60 mins

for s = 1 : num_sess
    cd(folders{s})
    load([folders{s},'\extracted_position.mat'])
    load([folders{s},'\Bayesian controls\Only first exposure\significant_replay_events_wcorr.mat']);
    load([folders{s},'\Bayesian controls\Only first exposure\extracted_place_fields_BAYESIAN.mat']);
    % Only use cells that have place fields on both tracks
    common_good_cells = intersect(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
    track_replay_events = track_replay_events_F.track_replay_events;
    % First exposure
    for track = 1:2
        total_place_cell_RUN1(track,s) =  length(place_fields_BAYESIAN.track(track).good_cells);

        % PRE
        cell_id = [];
        % For each event find the cells that are active
        if ~isempty(track_replay_events(s).(sprintf('T%i',track)).(sprintf('PRE_%s_cumulative_times',rest_option)))
            for event = find(track_replay_events(s).(sprintf('T%i',track)).(sprintf('PRE_%s_cumulative_times',rest_option)) <=time_chunk)
                event_id = track_replay_events(s).(sprintf('T%i',track)).(sprintf('PRE_%s_index',rest_option))(event);
                cell_id = [unique(significant_replay_events.track(track).spikes{event_id}(:,1))' cell_id];
                replay_active_proportion_PRE{track}{s}(event) = length(unique(significant_replay_events.track(track).spikes{event_id}(:,1)))/total_place_cell_RUN1(track,s);
            end

            % Only include common good cells
            common_good_cell_id = cell_id(ismember(cell_id,common_good_cells));

            active_cell_id = 1:1:max(common_good_cells);
            [event_counts,ss] = histcounts(common_good_cell_id,[0.5:1:max(common_good_cells)+0.5]);

            cell_replay_PRE{s}{track}(1,:) = active_cell_id(common_good_cells);
            PRE_time = track_replay_events(s).(sprintf('T%i',track)).(sprintf('PRE_%s_cumulative_times',rest_option));
            if PRE_time(end) < time_chunk
                cell_replay_PRE{s}{track}(2,:) = event_counts(common_good_cells)/PRE_time(end);
            else
                cell_replay_PRE{s}{track}(2,:) = event_counts(common_good_cells)/time_chunk;
            end

        else
            cell_replay_PRE{s}{track} = [];
            track_difference_cell_PRE{s} = [];
        end
        

        % POST1
        cell_id = [];
        replay_active_proportion = [];
        
        % For each event find the cells that are active
        for event = find(track_replay_events(s).(sprintf('T%i',track)).(sprintf('INTER_post_%s_cumulative_times',rest_option)) <=time_chunk)
            event_id = track_replay_events(s).(sprintf('T%i',track)).(sprintf('INTER_post_%s_index',rest_option))(event);
            cell_id = [unique(significant_replay_events.track(track).spikes{event_id}(:,1))' cell_id];
            replay_active_proportion_POST1{track}{s}(event) = length(unique(significant_replay_events.track(track).spikes{event_id}(:,1)))/total_place_cell_RUN1(track,s);
        end
        
        % Only include common good cells
        common_good_cell_id = cell_id(ismember(cell_id,common_good_cells));
        
        active_cell_id = 1:1:max(common_good_cells);
        [event_counts,ss] = histcounts(common_good_cell_id,[0.5:1:max(common_good_cells)+0.5]);
        
        cell_replay_POST1{s}{track}(1,:) = active_cell_id(common_good_cells);
        cell_replay_POST1{s}{track}(2,:) = event_counts(common_good_cells)/time_chunk;
        
        % RUN1
        cell_id = [];
        replay_active_proportion = [];

        % For each event find the cells that are active
        for event = 1:length(track_replay_events(s).(sprintf('T%i',track)).(sprintf('T%i_index',track)))
            event_id = track_replay_events(s).(sprintf('T%i',track)).(sprintf('T%i_index',track))(event);
            cell_id = [unique(significant_replay_events.track(track).spikes{event_id}(:,1))' cell_id];
            replay_active_proportion_RUN1{track}{s}(event) = length(unique(significant_replay_events.track(track).spikes{event_id}(:,1)))/total_place_cell_RUN1(track,s);
        end
        % Only include common good cells
        common_good_cell_id = cell_id(ismember(cell_id,common_good_cells));
        
        active_cell_id = 1:1:max(common_good_cells);
        [event_counts,~] = histcounts(common_good_cell_id,[0.5:1:max(common_good_cells)+0.5]);
        
        cell_replay_RUN1{s}{track}(1,:) = active_cell_id(common_good_cells);
        cell_replay_RUN1{s}{track}(2,:) = event_counts(common_good_cells);
        
    end

    if ~isempty(cell_replay_PRE{s}{1}) & ~isempty(cell_replay_PRE{s}{2})
        track_difference_cell_PRE{s}(1,:) = cell_replay_PRE{s}{1}(1,:);
        track_difference_cell_PRE{s}(2,:) = (cell_replay_PRE{s}{1}(2,:) - cell_replay_PRE{s}{2}(2,:));
    end

    track_difference_cell_POST1{s}(1,:) = cell_replay_POST1{s}{1}(1,:);
    track_difference_cell_POST1{s}(2,:) = (cell_replay_POST1{s}{1}(2,:) - cell_replay_POST1{s}{2}(2,:));
    
    track_difference_cell_RUN1{s}(1,:) = cell_replay_RUN1{s}{1}(1,:);
    track_difference_cell_RUN1{s}(2,:) = (cell_replay_RUN1{s}{1}(2,:) - cell_replay_RUN1{s}{2}(2,:));
    
    %     load([folders{s},'\Bayesian controls\Only re-exposure\extracted_place_fields_BAYESIAN.mat'])
    load([folders{s},'\Bayesian controls\Only re-exposure\significant_replay_events_wcorr.mat']);
    load([folders{s},'\Bayesian controls\Only re-exposure\extracted_place_fields_BAYESIAN.mat']);
    % Only use cells that have place fields on both tracks
    common_good_cells = intersect(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
    track_replay_events = track_replay_events_R.track_replay_events;
    
    
    % Re-exposure
    for track = 1:2
        total_place_cell_RUN2(track,s) =  length(place_fields_BAYESIAN.track(track).good_cells);
        cell_id = [];

%         for event = find(track_replay_events(s).(sprintf('T%i',track)).(sprintf('PRE_%s_cumulative_times',rest_option)) <=time_chunk)
%             event_id = track_replay_events(s).(sprintf('T%i',track)).(sprintf('PRE_%s_index',rest_option))(event);
%             cell_id = [unique(significant_replay_events.track(track).spikes{event_id}(:,1))' cell_id];
%             replay_active_proportion_PRE{track}{s}(event) = length(unique(significant_replay_events.track(track).spikes{event_id}(:,1)))/total_place_cell_RUN1(track,s);
%         end

        % For each event find the cells that are active
        for event = find(track_replay_events(s).(sprintf('T%i',track)).(sprintf('FINAL_post_%s_cumulative_times',rest_option)) <=time_chunk)
            event_id = track_replay_events(s).(sprintf('T%i',track)).(sprintf('FINAL_post_%s_index',rest_option))(event);
            cell_id = [unique(significant_replay_events.track(track).spikes{event_id}(:,1))' cell_id];
            replay_active_proportion_POST2{track}{s}(event) = length(unique(significant_replay_events.track(track).spikes{event_id}(:,1)))/total_place_cell_RUN2(track,s);
        end
        common_good_cell_id = cell_id(ismember(cell_id,common_good_cells));
        
        active_cell_id = 1:1:max(common_good_cells);
        [event_counts,ss] = histcounts(common_good_cell_id,[0.5:1:max(common_good_cells)+0.5]);
        
        cell_replay_POST2{s}{track}(1,:) = active_cell_id(common_good_cells);
        cell_replay_POST2{s}{track}(2,:) = event_counts(common_good_cells)/time_chunk;
        
        
        % RUN2
        cell_id = [];
        % For each event find the cells that are active
        for event = 1:length(track_replay_events(s).(sprintf('T%i',track)).(sprintf('T%i_index',track+2)))
            event_id = track_replay_events(s).(sprintf('T%i',track)).(sprintf('T%i_index',track+2))(event);
            cell_id = [unique(significant_replay_events.track(track).spikes{event_id}(:,1))' cell_id];
            replay_active_proportion_RUN2{track}{s}(event) = length(unique(significant_replay_events.track(track).spikes{event_id}(:,1)))/total_place_cell_RUN2(track,s);
        end
        % Only include common good cells
        common_good_cell_id = cell_id(ismember(cell_id,common_good_cells));
        
        active_cell_id = 1:1:max(common_good_cells);
        [event_counts,ss] = histcounts(common_good_cell_id,[0.5:1:max(common_good_cells)+0.5]);
        
        cell_replay_RUN2{s}{track}(1,:) = active_cell_id(common_good_cells);
        cell_replay_RUN2{s}{track}(2,:) = event_counts(common_good_cells);
    end
    
    track_difference_cell_POST2{s}(1,:) = cell_replay_POST2{s}{1}(1,:);
    track_difference_cell_POST2{s}(2,:) = (cell_replay_POST2{s}{1}(2,:) - cell_replay_POST2{s}{2}(2,:));
    
    track_difference_cell_RUN2{s}(1,:) = cell_replay_RUN2{s}{1}(1,:);
    track_difference_cell_RUN2{s}(2,:) = (cell_replay_RUN2{s}{1}(2,:) - cell_replay_RUN2{s}{2}(2,:));
    
end


nfig = figure('Color','w','Name','PRE replay vs RUN Replay participation track difference (First exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
    if isempty(track_difference_cell_PRE{s})
        continue
    end
    awake = [track_difference_cell_RUN1{s}(2,:)]; % awake number difference
    sleep = [track_difference_cell_PRE{s}(2,:)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-0.02 0.02])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
ylabel('PRE replay track difference (rate)')
xlabel('RUN1 replay track difference (number)')
sgtitle(sprintf('PRE replay vs RUN Replay participation track difference first exposure(%s)',rest_option));





nfig = figure('Color','w','Name','PRE replay vs POST1 Replay participation track difference');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    hold on
%     sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    if isempty(track_difference_cell_PRE{s})
        continue
    end
    pre = [track_difference_cell_PRE{s}(2,:)]; % awake number difference
    sleep = [track_difference_cell_POST1{s}(2,:)]; % sleep rate difference
    
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(pre(x),sleep(x),20,new_cls,'filled','o'),1:length(pre))
    hold on
    
    mdl = fitlm(pre',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(pre) max(pre)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-0.02 0.02])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
%         xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
%         xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
xlabel('PRE replay track difference (rate)')
ylabel('POST replay track difference (rate)')
sgtitle(sprintf('PRE replay vs POST1 Replay participation track difference(%s)',rest_option));

% Proportion of place cell active during replay

figure
subplot(2,2,1)
histogram([replay_active_proportion_RUN1{1}{:}],0:0.05:1,'normalization','probability')
hold on
histogram([replay_active_proportion_RUN1{2}{:}],0:0.05:1,'normalization','probability')

subplot(2,2,2)
histogram([replay_active_proportion_POST1{1}{:}],0:0.05:1,'normalization','probability')
hold on
histogram([replay_active_proportion_POST1{2}{:}],0:0.05:1,'normalization','probability')

subplot(2,2,3)
histogram([replay_active_proportion_RUN2{1}{:}],0:0.1:1,'normalization','probability')
hold on
histogram([replay_active_proportion_RUN2{2}{:}],0:0.1:1,'normalization','probability')

subplot(2,2,4)
histogram([replay_active_proportion_POST2{1}{:}],0:0.1:1,'normalization','probability')
hold on
histogram([replay_active_proportion_POST2{2}{:}],0:0.1:1,'normalization','probability')
xlabel('Proportion of place cell actives')
sgtitle('All session combined place cell replay participation')


RUN_cell_proportion = [];
POST_cell_proportion = [];
PRE_cell_proportion = [];
for s = 1:num_sess

PRE_cell_proportion(1,s) = mean(replay_active_proportion_PRE{1}{s});
PRE_cell_proportion(2,s) = mean(replay_active_proportion_PRE{2}{s});


RUN_cell_proportion(1,s) = mean(replay_active_proportion_RUN1{1}{s});
RUN_cell_proportion(2,s) = mean(replay_active_proportion_RUN1{2}{s});
RUN_cell_proportion(3,s) = mean(replay_active_proportion_RUN2{1}{s});
RUN_cell_proportion(4,s) = mean(replay_active_proportion_RUN2{2}{s});

POST_cell_proportion(1,s) = mean(replay_active_proportion_POST1{1}{s});
POST_cell_proportion(2,s) = mean(replay_active_proportion_POST1{2}{s});
POST_cell_proportion(3,s) = mean(replay_active_proportion_POST2{1}{s});
POST_cell_proportion(4,s) = mean(replay_active_proportion_POST2{2}{s});
end

[PRE_cell_proportion_p,~] = signrank(PRE_cell_proportion(1,:), PRE_cell_proportion(2,:));
[RUN_cell_proportion_p(1),~] = signrank(RUN_cell_proportion(1,:), RUN_cell_proportion(2,:));
[RUN_cell_proportion_p(2),~] = signrank(RUN_cell_proportion(3,:), RUN_cell_proportion(4,:));

[POST_cell_proportion_p(1),~] = signrank(POST_cell_proportion(1,:), POST_cell_proportion(2,:));
[POST_cell_proportion_p(2),~] = signrank(POST_cell_proportion(3,:), POST_cell_proportion(4,:));

% f11 = figure('Color','w','Name','total place cell number');
% f11.Position = [450 180 1020 770];
% subplot(2,2,1)
% bar(total_place_cell_RUN1(1,:),'FaceAlpha',0.5)
% hold on
% bar(-total_place_cell_RUN1(2,:),'FaceAlpha',0.5)
% xticks(1:1:19)
% yticks(-140:20:140)
% set(gca,'FontSize',14)
% xlabel('Session')
% title('RUN1 place cell number')
% 
% 
% subplot(2,2,2)
% bar(total_place_cell_RUN1(1,:),'FaceAlpha',0.5)
% hold on
% bar(-total_place_cell_RUN1(2,:),'FaceAlpha',0.5)
% xticks(1:1:19)
% yticks(-140:20:140)
% set(gca,'FontSize',14)
% title('RUN2 place cell number')
% xlabel('Session')

%%%%%%% 
f11 = figure('Color','w','Name','PRE replay');
f11.Position = [450 180 1020 720];
f11.Name = [sprintf('PRE active place cell proportion during replay(%s)',rest_option)];

nexttile
grp = [ones(num_sess,1);ones(num_sess,1)*2];
tst=[PRE_cell_proportion(1,:) PRE_cell_proportion(2,:)]';

% xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'corral_style','rand');
xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2],'dot_size',2,'overlay_style','sd','corral_style','rand');

xticks([1:2])
xticklabels({'PRE T1','PRE T2'})
ylabel('Replay active place cell proportion')
set(gca,'FontSize',14)
yticks([0:0.1:0.5])
ylim([0 0.55])
hold on

tst=[PRE_cell_proportion(1,:); PRE_cell_proportion(2,:)]';
xbe = reshape(xbe,size(tst,1),size(tst,2));
for i = 1:size(tst,1)
    plot(xbe(i,[1 2]),tst(i,[1 2]),'Color',[0,0,0,0.2])
%     plot(xbe(i,[3 4]),tst(i,[3 4]),'Color',[0,0,0,0.2])
end

axis square
title(sprintf('PRE replay active cell proportion (%s)',rest_option));
nexttile
axis square
nexttile
axis square
nexttile
axis square
nexttile
axis square
nexttile
axis square


%%%%%%% 
f11 = figure('Color','w','Name','POST replay rates');
f11.Position = [450 180 1020 720];
f11.Name = [sprintf('POST active place cell proportion during replay(%s)',rest_option)];

nexttile
grp = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
tst=[POST_cell_proportion(1,:) POST_cell_proportion(2,:) POST_cell_proportion(3,:) POST_cell_proportion(4,:)]';

% xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'corral_style','rand');
xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'overlay_style','sd','corral_style','rand');


xticks([1:4])
xticklabels({'POST1 T1','POST1 T2','POST2 T1','POST2 T2'})
ylabel('Replay active place cell proportion')
set(gca,'FontSize',14)
yticks([0:0.1:0.5])
ylim([0 0.55])
hold on

tst=[POST_cell_proportion(1,:); POST_cell_proportion(2,:); POST_cell_proportion(3,:); POST_cell_proportion(4,:)]';
xbe = reshape(xbe,size(tst,1),size(tst,2));
for i = 1:size(tst,1)
    plot(xbe(i,[1 2]),tst(i,[1 2]),'Color',[0,0,0,0.2])
    plot(xbe(i,[3 4]),tst(i,[3 4]),'Color',[0,0,0,0.2])
end

axis square
title(sprintf('POST replay active cell proportion for both exposures (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[POST_cell_proportion(1,prot_sess{1}) POST_cell_proportion(1,prot_sess{2})...
    POST_cell_proportion(1,prot_sess{3}) POST_cell_proportion(1,prot_sess{4}) POST_cell_proportion(1,prot_sess{5})]';


xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on


xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay active place cell proportion')
set(gca,'FontSize',14)
yticks([0:0.1:0.5])
ylim([0 0.55])
axis square
title(sprintf('POST1 T1 replay (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[POST_cell_proportion(2,prot_sess{1}) POST_cell_proportion(2,prot_sess{2})...
    POST_cell_proportion(2,prot_sess{3}) POST_cell_proportion(2,prot_sess{4}) POST_cell_proportion(2,prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.1:0.5])
ylim([0 0.55])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay active place cell proportion')
set(gca,'FontSize',14)
axis square
title(sprintf('POST1 T2 replay (%s)',rest_option));


nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[POST_cell_proportion(3,prot_sess{1}) POST_cell_proportion(3,prot_sess{2})...
    POST_cell_proportion(3,prot_sess{3}) POST_cell_proportion(3,prot_sess{4}) POST_cell_proportion(3,prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.1:0.5])
ylim([0 0.55])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay active place cell proportion')
set(gca,'FontSize',14)
axis square
title(sprintf('POST2 T1 replay (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[POST_cell_proportion(4,prot_sess{1}) POST_cell_proportion(4,prot_sess{2})...
    POST_cell_proportion(4,prot_sess{3}) POST_cell_proportion(4,prot_sess{4}) POST_cell_proportion(4,prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.1:0.5])
ylim([0 0.55])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay active place cell proportion')
set(gca,'FontSize',14)
axis square
title(sprintf('POST2 T2 replay (%s)',rest_option));





%%%%%%% 
f11 = figure('Color','w','Name','POST replay rates');
f11.Position = [450 180 1020 720];
f11.Name = [sprintf('RUN active place cell proportion during replay(%s)',rest_option)];

nexttile
grp = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
tst=[RUN_cell_proportion(1,:) RUN_cell_proportion(2,:) RUN_cell_proportion(3,:) RUN_cell_proportion(4,:)]';

% xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'corral_style','rand');
xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'overlay_style','sd','corral_style','rand');


xticks([1:4])
xticklabels({'RUN1 T1','RUN1 T2','RUN2 T1','RUN2 T2'})
ylabel('Replay active place cell proportion')
set(gca,'FontSize',14)
yticks([0:0.1:0.5])
ylim([0 0.55])
hold on

tst=[RUN_cell_proportion(1,:); RUN_cell_proportion(2,:); RUN_cell_proportion(3,:); RUN_cell_proportion(4,:)]';
xbe = reshape(xbe,size(tst,1),size(tst,2));
for i = 1:size(tst,1)
    plot(xbe(i,[1 2]),tst(i,[1 2]),'Color',[0,0,0,0.2])
    plot(xbe(i,[3 4]),tst(i,[3 4]),'Color',[0,0,0,0.2])
end

axis square
title(sprintf('RUN replay active cell proportion for both exposures (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[RUN_cell_proportion(1,prot_sess{1}) RUN_cell_proportion(1,prot_sess{2})...
    RUN_cell_proportion(1,prot_sess{3}) RUN_cell_proportion(1,prot_sess{4}) RUN_cell_proportion(1,prot_sess{5})]';


xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on


xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay active place cell proportion')
set(gca,'FontSize',14)
yticks([0:0.1:0.5])
ylim([0 0.55])
axis square
title(sprintf('RUN1 T1 replay (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[RUN_cell_proportion(2,prot_sess{1}) RUN_cell_proportion(2,prot_sess{2})...
    RUN_cell_proportion(2,prot_sess{3}) RUN_cell_proportion(2,prot_sess{4}) RUN_cell_proportion(2,prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.1:0.5])
ylim([0 0.55])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay active place cell proportion')
set(gca,'FontSize',14)
axis square
title(sprintf('RUN1 T2 replay (%s)',rest_option));


nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[RUN_cell_proportion(3,prot_sess{1}) RUN_cell_proportion(3,prot_sess{2})...
    RUN_cell_proportion(3,prot_sess{3}) RUN_cell_proportion(3,prot_sess{4}) RUN_cell_proportion(3,prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.1:0.5])
ylim([0 0.55])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay active place cell proportion')
set(gca,'FontSize',14)
axis square
title(sprintf('RUN2 T1 replay (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[RUN_cell_proportion(4,prot_sess{1}) RUN_cell_proportion(4,prot_sess{2})...
    RUN_cell_proportion(4,prot_sess{3}) RUN_cell_proportion(4,prot_sess{4}) RUN_cell_proportion(4,prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.1:0.5])
ylim([0 0.55])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay active place cell proportion')
set(gca,'FontSize',14)
axis square
title(sprintf('RUN2 T2 replay (%s)',rest_option));

%% Plot awake replay property on the track

cls = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[3,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];

num_sess = length(track_replay_events_F.track_replay_events);
folders = data_folders_excl;

peak_location_RUN1_T1 = [];
peak_location_RUN1_T2 = [];
peak_location_RUN2_T1 = [];
peak_location_RUN2_T2 = [];

occurance_location_RUN1 = [];
occurance_location_RUN2 = [];
for s = 1:num_sess
    for track = 1:2
        peak_location_RUN1_T1{track}{s} = 0;
        peak_location_RUN1_T2{track}{s} = 0;

        peak_location_RUN2_T1{track}{s} = 0;
        peak_location_RUN2_T2{track}{s} = 0;

        occurance_location_RUN1{1}{track}{s} = 0;
        occurance_location_RUN1{2}{track}{s} = 0;
        occurance_location_RUN2{1}{track}{s} = 0;
        occurance_location_RUN2{2}{track}{s} = 0;
    end
end

for s = 1 : num_sess
    cd(folders{s})
    load([folders{s},'\extracted_position.mat']);
    load([folders{s},'\Bayesian controls\Only first exposure\extracted_place_fields_BAYESIAN.mat'])
    load([folders{s},'\Bayesian controls\Only first exposure\significant_replay_events_wcorr.mat']);
    load([folders{s},'\Bayesian controls\Only first exposure\extracted_place_fields_BAYESIAN.mat']);
    track_replays_events = track_replay_events_F.track_replay_events;
    total_place_cell_RUN1(1,s) =  length(place_fields_BAYESIAN.track(1).good_cells);
    total_place_cell_RUN1(2,s) =  length(place_fields_BAYESIAN.track(2).good_cells);

    % First exposure
    for track = 1:2
        % Track 1
        for event = 1:length(track_replay_events(s).(sprintf('T%i',track)).T1_index)
            event_id = track_replay_events(s).(sprintf('T%i',track)).T1_index(event);
            [~,peak_locations_this_event] = max(significant_replay_events.track(track).decoded_position{event_id});
            peak_location_RUN1_T1{track}{s} = [peak_location_RUN1_T1{track}{s} peak_locations_this_event];
%             peak_location_RUN1_T1{track} = [peak_location_RUN1_T1{track} peak_locations_this_event];
            event_time = significant_replay_events.track(track).event_times(event_id);
            [~,tidx] = min(abs(position.t - event_time));
            % Replay on Track 1
            if ~isnan(position.linear(1).linear(tidx))
%                 occurance_location_RUN1{1}{track} = [occurance_location_RUN1{1}{track} position.linear(1).linear(tidx)];
                occurance_location_RUN1{1}{track}{s}(event) = position.linear(1).linear(tidx);
            end

            % Only include common good cells
            common_good_cell_id = cell_id(ismember(cell_id,common_good_cells));
        end

        % Track 2
        for event = 1:length(track_replay_events(s).(sprintf('T%i',track)).T2_index)
            event_id = track_replay_events(s).(sprintf('T%i',track)).T2_index(event);
            [~,peak_locations_this_event] = max(significant_replay_events.track(track).decoded_position{event_id});
            %             peak_location_RUN1_T2{track} = [peak_location_RUN1_T2{track} peak_locations_this_event];
            peak_location_RUN1_T2{track}{s} = [peak_location_RUN1_T2{track}{s} peak_locations_this_event];
            event_time = significant_replay_events.track(track).event_times(event_id);
            [~,tidx] = min(abs(position.t - event_time));
            % Replay on Track 2
            if ~isnan(position.linear(2).linear(tidx))
%                 occurance_location_RUN1{2}{track} = [occurance_location_RUN1{2}{track} position.linear(2).linear(tidx)];
                occurance_location_RUN1{2}{track}{s}(event) = position.linear(2).linear(tidx);
            end

            cell_active = unique(significant_replay_events.track(track).spikes{event_id}(:,1))'/total_place_cell_RUN1(track,s);
        end
    end

    load([folders{s},'\Bayesian controls\Only re-exposure\extracted_place_fields_BAYESIAN.mat']);
    load([folders{s},'\Bayesian controls\Only re-exposure\significant_replay_events_wcorr.mat']);
    load([folders{s},'\Bayesian controls\Only re-exposure\extracted_place_fields_BAYESIAN.mat']);
    % Only use cells that have place fields on both tracks
    common_good_cells = intersect(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
    track_replay_events = track_replay_events_R.track_replay_events;
    total_place_cell_RUN2(1,s) =  length(place_fields_BAYESIAN.track(1).good_cells);
    total_place_cell_RUN2(2,s) =  length(place_fields_BAYESIAN.track(2).good_cells);


    % Re-exposure
    for track = 1:2
        % Track 1
        for event = 1:length(track_replay_events(s).(sprintf('T%i',track)).T3_index)
            event_id = track_replay_events(s).(sprintf('T%i',track)).T3_index(event);
            [~,peak_locations_this_event] = max(significant_replay_events.track(track).decoded_position{event_id});
            %             peak_location_RUN2_T1{track} = [peak_location_RUN2_T1{track} peak_locations_this_event];
            peak_location_RUN2_T1{track}{s} = [peak_location_RUN2_T1{track}{s} peak_locations_this_event];
            event_time = significant_replay_events.track(track).event_times(event_id);
            [~,tidx] = min(abs(position.t - event_time));
            if ~isnan(position.linear(3).linear(tidx))
                %                 occurance_location_RUN2{1}{track} = [occurance_location_RUN2{1}{track} position.linear(3).linear(tidx)];
                occurance_location_RUN2{1}{track}{s}(event) = position.linear(3).linear(tidx);
            end
        end

        % Track 2
        for event = 1:length(track_replay_events(s).(sprintf('T%i',track)).T4_index)
            event_id = track_replay_events(s).(sprintf('T%i',track)).T4_index(event);
            [~,peak_locations_this_event] = max(significant_replay_events.track(track).decoded_position{event_id});
%             peak_location_RUN2_T2{track} = [peak_location_RUN2_T2{track} peak_locations_this_event];
            peak_location_RUN2_T2{track}{s} = [peak_location_RUN2_T2{track}{s} peak_locations_this_event];
            event_time = significant_replay_events.track(track).event_times(event_id);
            [~,tidx] = min(abs(position.t - event_time));
            if ~isnan(position.linear(4).linear(tidx))
                %                 occurance_location_RUN2{2}{track} = [occurance_location_RUN2{2}{track} position.linear(4).linear(tidx)];
                occurance_location_RUN2{2}{track}{s}(event) = position.linear(4).linear(tidx);
            end
        end
    end
end

% Local and Remote Replay occurance
nfig = figure('Color','w','Name','Local and Remote Replay occurance');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

subplot(2,2,1)
histogram([occurance_location_RUN1{1}{1}{:}],1:10:200)
hold on
histogram(occurance_location_RUN1{1}{2},1:10:200)
legend('Local track 1 replay','Remote track 2 replay')
title('RUN1 Track 1 Replay Occurance')
set(gca,'FontSize',14)

subplot(2,2,2)
histogram(occurance_location_RUN2{2}{1},1:10:200)
hold on
histogram(occurance_location_RUN2{2}{2},1:10:200)
legend('Remote track 1 replay','Local track 2 replay')
title('RUN1 Track 2 Replay Occurance')
set(gca,'FontSize',14)

subplot(2,2,3)
histogram(occurance_location_RUN2{1}{1},1:10:200)
hold on
histogram(occurance_location_RUN2{1}{2},1:10:200)
legend('Local track 1 replay','Remote track 2 replay')
title('RUN2 Track 1 Replay Occurance')
set(gca,'FontSize',14)

subplot(2,2,4)
histogram(occurance_location_RUN2{2}{1},1:10:200)
hold on
histogram(occurance_location_RUN2{2}{2},1:10:200)
legend('Remote track 1 replay','Local track 2 replay')
title('RUN2 Track 2 Replay Occurance')
set(gca,'FontSize',14)


% Local and remote replay highest probability location
nfig = figure('Color','w','Name','Local and Remote Replay peak probability location');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

subplot(2,2,1)
histogram(peak_location_RUN1_T1{1},1:1:20,'normalization','probability')
hold on
histogram(peak_location_RUN1_T1{2},1:1:20,'normalization','probability')
xticks(1:1:20)
xticklabels(10:10:200)
legend('Local track 1 replay','Remote track 2 replay')
title('RUN1 Track 1 Replayed location')
set(gca,'FontSize',14)

subplot(2,2,2)
histogram(peak_location_RUN1_T2{1},1:1:20,'normalization','probability')
hold on
histogram(peak_location_RUN1_T2{2},1:1:20,'normalization','probability')
xticks(1:1:20)
xticklabels(10:10:200)
legend('Remote track 1 replay','Local track 2 replay')
title('RUN1 Track 2 Replayed location')
set(gca,'FontSize',14)

subplot(2,2,3)
histogram(peak_location_RUN2_T1{1},1:1:20,'normalization','probability')
hold on
histogram(peak_location_RUN2_T1{2},1:1:20,'normalization','probability')
xticks(1:1:20)
xticklabels(10:10:200)
legend('Local track 1 replay','Remote track 2 replay')
title('RUN2 Track 1 Replayed location')
set(gca,'FontSize',14)

subplot(2,2,4)
histogram(peak_location_RUN2_T2{1},1:1:20,'normalization','probability')
hold on
histogram(peak_location_RUN2_T2{2},1:1:20,'normalization','probability')
xticks(1:1:20)
xticklabels(10:10:200)
xlabel('Replayed locations')
legend('Remote track 1 replay','Local track 2 replay')
title('RUN2 Track 2 Replayed location')

