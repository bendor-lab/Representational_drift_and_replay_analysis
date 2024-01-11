function plot_replay_theta_mixed_effect_model(bayesian_control,rest_option,time_chunk_size,time_window)

% Code for quantifying and plotting the relationship between theta sequence
% and awake replay and sleep replay using mixed effect model

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

%% for each session gather and calculate replay info

folders = data_folders_excl;
for s = 1 : num_sess
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
%         
%         for time = 1:3
%             if strcmp(rest_option,'sleep')
%                 if SWR_counts_POST2_sleep(s,time) == 0
%                     FINAL_RT1_rate_events_temporal(s,time) = nan;
%                     FINAL_RT2_rate_events_temporal(s,time) = nan;
%                 end
%             elseif strcmp(rest_option,'awake')
%                 if SWR_counts_POST2_awake(s,time) == 0
%                     FINAL_RT1_rate_events_temporal(s,time) = nan;
%                     FINAL_RT2_rate_events_temporal(s,time) = nan;
%                 end
%             end
%         end
%         
%         for time = 1:6
%             if strcmp(rest_option,'sleep')
%                 if SWR_counts_POST1_sleep(s,time) == 0
%                     INTER_T1_rate_events_temporal(s,time) = nan;
%                     INTER_T2_rate_events_temporal(s,time) = nan;
%                 end
%             elseif strcmp(rest_option,'awake')
%                 if SWR_counts_POST1_awake(s,time) == 0
%                     INTER_T1_rate_events_temporal(s,time) = nan;
%                     INTER_T2_rate_events_temporal(s,time) = nan;
%                 end
%             end
%         end
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


%% Theta info
folders_to_process = 1:1:20;
folders_to_process(5) = [];% Exclude one 16x4 session
track_info = [];
% ALLOCATION
count = 1
for  ses = folders_to_process
    for t = 1 : length(lap_WeightedCorr(1).track)
        track_info(t).thetaseq_WC_scores(ses,:) = nan(1,52);
        track_info(t).thetaseq_QR_scores(ses,:) = nan(1,52);
        track_info(t).num_thetaseq(ses,:) = nan(1,52);
        track_info(t).norm_num_thetaseq(ses,:) = nan(1,52);
    end
    count = count + 1;
end

protocols = [8,4,3,2,1];
c = 1;
for p = 1 : length(protocols) %for each protocol
    tempt = protocol(p).(sprintf('%s','T',num2str(t)))(1).Rat_replay_rate;
    for r = 1 : size(tempt,1) %for each rat
        for t = 1 : length(lap_WeightedCorr(1).track) %for each track
            track_info(t).lap_num_replay(c,:) = nan(1,52);
            track_info(t).lap_replay_rates(c,:) = nan(1,52);
            track_info(t).norm_lap_num_replay(c,:) = nan(1,52);
        end
        c = c +1;
    end
end

% EXTRACT THETA INFO
count = 1;
for ses = folders_to_process
    for t = 1 : length(lap_WeightedCorr(1).track) %for each track (T1 T2 T3 T4)
        track_info(t).thetaseq_WC_scores(count,1:length(lap_WeightedCorr(ses).track(t).score)) = lap_WeightedCorr(ses).track(t).score;
        track_info(t).thetaseq_QR_scores(count,1:length(lap_QuadrantRatio(ses).track(t).score)) = lap_QuadrantRatio(ses).track(t).score;
        track_info(t).num_thetaseq(count,1:length(lap_WeightedCorr(ses).track(t).score)) = lap_WeightedCorr(ses).track(t).num_thetaseq;
        track_info(t).norm_num_thetaseq(count,1:length(lap_WeightedCorr(ses).track(t).score)) = lap_WeightedCorr(ses).track(t).num_thetaseq./...
            quantification_scores(1).num_thetaseq(t,ses);
        track_info(t).total_num_thetaseq(count) = quantification_scores(2).num_thetaseq(t,ses);
        total_num_thetaseq(count,t) = quantification_scores(2).num_thetaseq(t,ses);
        wcorr_score(count,t) = quantification_scores(2).num_thetaseq(t,ses);
        theta_pval (count,t) = max(cell2mat(quantification_scores(2).pvals(t,ses)));
        
        immobility(count,t) = time_immobile(ses,t);
        mobility(count,t) = time_moving(ses,t);
        running_speed(count,t) = moving_speed(ses,t);
    end
    count = count + 1;
end

folders = data_folders_excl;
for f = 1:length(folders)
    load([folders{f},'\Theta\theta_time_window.mat'])
    
    for track = 1:4
        total_theta_windows(f,track) = size(theta_windows.track(track).theta_windows,1);
    end
end

%% Creating table for first and re exposure

prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];

no_of_laps = [ones(num_sess,1)*16;ones(length(prot_sess{5}),1)*8;ones(length(prot_sess{4}),1)*4;...
    ones(length(prot_sess{3}),1)*3;ones(length(prot_sess{2}),1)*2;ones(length(prot_sess{1}),1)*1;...
    ones(num_sess,1)*16;ones(num_sess,1)*16];
POST_replay_rate=[INTER_T1_rate_events, INTER_T2_rate_events, FINAL_RT1_rate_events, FINAL_RT2_rate_events]';

awake_replay_rate = [awake_rate_replay_T1,awake_rate_replay_T2,awake_rate_replay_RT1,awake_rate_replay_RT2]';
awake_replay_number = [awake_local_replay_T1,awake_local_replay_T2,awake_local_replay_RT1,awake_local_replay_RT2]';
theta_number = reshape(total_num_thetaseq,prod(size(total_num_thetaseq)),1);
awake_SWR_rate = reshape(SWR_event_rate,prod(size(SWR_event_rate)),1);
awake_SWR_number = reshape(SWR_event_number,prod(size(SWR_event_number)),1);
theta_cycle = reshape(total_theta_windows,prod(size(total_theta_windows)),1);

time_mobile = reshape(mobility,prod(size(mobility)),1);
time_immobile = reshape(immobility,prod(size(immobility)),1);
time_total = [time_mobile + time_immobile];
speed = reshape(running_speed,prod(size(running_speed)),1);
track_label = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
exposure_label = [ones(num_sess*2,1);ones(num_sess*2,1)*2];
animal_label = repmat([1 2 3 4],1,5);
animal_label(5) = [];
animal_label = repmat(animal_label,1,4)';

both_exposures_data = table(no_of_laps,zscore(POST_replay_rate),zscore(awake_replay_rate),zscore(awake_replay_number),...
    zscore(theta_number),zscore(time_mobile),zscore(time_immobile),zscore(speed),track_label,exposure_label,animal_label,zscore(time_total),...
    zscore(awake_SWR_rate),zscore(awake_SWR_number),zscore(theta_cycle),...
    'VariableNames',{'no_of_laps','POST_replay_rate','awake_replay_rate','awake_replay_number',...
    'theta_number','time_mobile','time_immobile','running_speed','track_label','exposure_label','animal_label','time_total',...
    'awake_SWR_rate','awake_SWR_number','theta_cycle'});
% writetable(both_exposures_data,'both exposures data for regression.csv')


% T1 and T2 first exposure
no_of_laps = [ones(num_sess,1)*16;ones(num_sess,1)*16];
POST_replay_rate = [INTER_T1_rate_events, INTER_T2_rate_events]';
awake_replay_rate = [awake_rate_replay_T1,awake_rate_replay_T2]';
awake_replay_number = [awake_local_replay_T1,awake_local_replay_T2]';
theta_number = [total_num_thetaseq(:,1);total_num_thetaseq(:,2)]
time_mobile = [mobility(:,1);mobility(:,2)];
time_immobile = [immobility(:,1);immobility(:,2)];
speed = [running_speed(:,1);running_speed(:,2)];
track_label = [ones(num_sess,1);ones(num_sess,1)*2];
animal_label = repmat([1 2 3 4],1,5);
animal_label(5) = [];
animal_label = repmat(animal_label,1,2)';

first_exposure_data = table(zscore(no_of_laps),zscore(POST_replay_rate),zscore(awake_replay_rate),zscore(awake_replay_number),...
    zscore(theta_number),zscore(time_mobile),zscore(time_immobile),zscore(speed),track_label,animal_label,...
    'VariableNames',{'no_of_laps','POST_replay_rate','awake_replay_rate','awake_replay_number',...
    'theta_number','time_mobile','time_immobile','running_speed','track_label','animal_label'});
% writetable(first_exposure_data,'first exposure data for regression.csv')


% formula = 'POST_replay_rate~ awake_replay_number + theta_number + ';
% mdl = fitlme(data,formula)
% T1 and T2 re exposure
POST_replay_rate = [FINAL_RT1_rate_events, FINAL_RT2_rate_events]';
awake_replay_rate = [awake_rate_replay_RT1,awake_rate_replay_RT2]';
awake_replay_number = [awake_local_replay_RT1,awake_local_replay_RT2]';
theta_number = [total_num_thetaseq(:,3);total_num_thetaseq(:,4)]
time_mobile = [mobility(:,3);mobility(:,4)];
time_immobile = [immobility(:,3);immobility(:,4)];
speed = [running_speed(:,3);running_speed(:,4)];
animal_label = repmat([1 2 3 4],1,5);
animal_label(5) = [];
animal_label = repmat(animal_label,1,2)';

track_label = [ones(num_sess,1);ones(num_sess,1)*2];

re_exposure_data = table(zscore(no_of_laps),zscore(POST_replay_rate),zscore(awake_replay_rate),zscore(awake_replay_number),...
    zscore(theta_number),zscore(time_mobile),zscore(time_immobile),zscore(speed),track_label,animal_label,...
    'VariableNames',{'no_of_laps','POST_replay_rate','awake_replay_rate','awake_replay_number',...
    'theta_number','time_mobile','time_immobile','running_speed','track_label','animal_label'});
% writetable(re_exposure_data,'re exposure data for regression.csv')


%% neural mechanism vs behaviour

% data = [both_exposures_data both_exposures_data_SWR(:,3:5)];
data = both_exposures_data;
opt = statset('LinearMixedModel');
opt.UseParallel = false;

% x1 = [];
% x2 = [];
% 
% parfor n = 1:1000
%     s1 = RandStream('mcg16807','Seed',n);
%     boot_data{n} = data(datasample(s1,1:size(data,1),size(data,1)),:);
%     
%     % formula1 = 'POST_replay_rate~  awake_replay_rate + awake_replay_number + theta_number  + (1|animal_label)';
%     formula1 = 'POST_replay_rate~  time_total + awake_replay_rate + awake_replay_number + theta_number  + (1|animal_label) + (1|track_label)';
%     % formula1 = 'POST_replay_rate~  awake_replay_rate + awake_replay_number + theta_number + time_immobile + time_mobile + (1|animal_label)  ';
%     mdl1 = fitlme(boot_data{n},formula1);
%     
%     % formula2 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle + time_immobile + time_mobile + (1|animal_label) + (1|track_label)';
%     formula2 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle + time_total  + (1|animal_label) + (1|track_label)';
%     mdl2 = fitlme(boot_data{n},formula2);
%     
%     x1(n,:) = [double(mdl1.Coefficients(5,2)) double(mdl1.Coefficients(4,2)) double(mdl1.Coefficients(2,2)) double(mdl1.Coefficients(3,2))];
%     x2(n,:) = [double(mdl2.Coefficients(2,2)) double(mdl2.Coefficients(5,2)) double(mdl2.Coefficients(3,2)) double(mdl2.Coefficients(4,2))];
% end

% formula1 = 'POST_replay_rate~  awake_replay_rate + awake_replay_number + theta_number  + (1|animal_label)';
formula1 = 'POST_replay_rate~  time_total + awake_replay_rate + awake_replay_number + theta_number  + (1|animal_label) + (1|track_label)';
% formula1 = 'POST_replay_rate~  awake_replay_rate + awake_replay_number + theta_number + time_immobile + time_mobile + (1|animal_label)  ';
mdl1 = fitlme(data,formula1);

% formula2 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle + time_immobile + time_mobile + (1|animal_label) + (1|track_label)';
formula2 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle + time_total  + (1|animal_label) + (1|track_label)';
mdl2 = fitlme(data,formula2);

x = [double(mdl2.Coefficients(2,2)) double(mdl2.Coefficients(5,2)) double(mdl2.Coefficients(3,2)) double(mdl2.Coefficients(4,2))];
x_CI = [double(mdl2.Coefficients(2,7:8));double(mdl2.Coefficients(5,7:8));  double(mdl2.Coefficients(3,7:8));  double(mdl2.Coefficients(4,7:8))];

nfig = figure('Color','w','Name','Mixed effect model comparisions')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')
clear b

nexttile
hold on
% x = [mean(theta_SWR_b(:,2)) mean(theta_SWR_b(:,3)) mean(theta_SWR_b(:,4))];
% x_CI = [prctile(theta_SWR_b(:,2),[2.5 97.5]); prctile(theta_SWR_b(:,3),[2.5 97.5]); prctile(theta_SWR_b(:,4),[2.5 97.5])];

for k = 1:4
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3 4])
xticklabels({'Total time on track','Theta cycles','Awake SWR rate','Awake SWR number'})
ylim([-1 1.2])
ylabel('Beta coefficient')
set(gca,'FontSize',14)


nexttile
hold on
x = [double(mdl1.Coefficients(5,2)) double(mdl1.Coefficients(4,2)) double(mdl1.Coefficients(2,2)) double(mdl1.Coefficients(3,2))];
x_CI = [double(mdl1.Coefficients(5,7:8)); double(mdl1.Coefficients(4,7:8)); double(mdl1.Coefficients(2,7:8));double(mdl1.Coefficients(3,7:8))];
% 
% x = [mean(theta_replay_b(:,2)) mean(theta_replay_b(:,3)) mean(theta_replay_b(:,4))];
% x_CI = [prctile(theta_replay_b(:,2),[2.5 97.5]); prctile(theta_replay_b(:,3),[2.5 97.5]); prctile(theta_replay_b(:,4),[2.5 97.5])];

for k = 1:4
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3 4])
xticklabels({'Total time on track','Theta sequence','Awake replay rate','Awake replay number'})
ylim([-1 1.2])
ylabel('Beta coefficient')
set(gca,'FontSize',14)
nexttile
nexttile


