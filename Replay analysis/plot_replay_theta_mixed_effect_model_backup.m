function plot_replay_theta_mixed_effect_model_backup(bayesian_control,rest_option,time_chunk_size,time_window)

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
    zscore(theta_number),zscore(time_mobile),zscore(time_immobile),zscore(speed),track_label,exposure_label,animal_label,time_total,...
    'VariableNames',{'no_of_laps','POST_replay_rate','awake_replay_rate','awake_replay_number',...
    'theta_number','time_mobile','time_immobile','running_speed','track_label','exposure_label','animal_label','time_total'});
writetable(both_exposures_data,'both exposures data for regression.csv')

no_of_laps = [ones(num_sess,1)*16;ones(length(prot_sess{5}),1)*8;ones(length(prot_sess{4}),1)*4;...
    ones(length(prot_sess{3}),1)*3;ones(length(prot_sess{2}),1)*2;ones(length(prot_sess{1}),1)*1;...
    ones(num_sess,1)*16;ones(num_sess,1)*16];
POST_replay_rate=[INTER_T1_rate_events, INTER_T2_rate_events, FINAL_RT1_rate_events, FINAL_RT2_rate_events]';
awake_SWR_rate = reshape(SWR_event_rate,prod(size(SWR_event_rate)),1);
awake_SWR_number = reshape(SWR_event_number,prod(size(SWR_event_number)),1);
theta_cycle = reshape(total_theta_windows,prod(size(total_theta_windows)),1);
time_mobile = reshape(mobility,prod(size(mobility)),1);
time_immobile = reshape(immobility,prod(size(immobility)),1);
speed = reshape(running_speed,prod(size(running_speed)),1);
track_label = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
exposure_label = [ones(num_sess*2,1);ones(num_sess*2,1)*2];
animal_label = repmat([1 2 3 4],1,5);
animal_label(5) = [];
animal_label = repmat(animal_label,1,4)';


both_exposures_data_SWR = table(no_of_laps,zscore(POST_replay_rate),zscore(awake_SWR_rate),zscore(awake_SWR_number),...
    zscore(theta_cycle),zscore(time_mobile),zscore(time_immobile),zscore(speed),track_label,exposure_label,animal_label,...
    'VariableNames',{'no_of_laps','POST_replay_rate','awake_SWR_rate','awake_SWR_number',...
    'theta_cycle','time_mobile','time_immobile','running_speed','track_label','exposure_label','animal_label'});
writetable(both_exposures_data_SWR,'both exposures data for regression SWR.csv')


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
%% Mobility and Immobility multiple regression
    
% First exposure
fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
formula = 'POST_replay_rate~ time_immobile';
first_exposure_mdl = fitlm(first_exposure_data,formula)
h = plot(first_exposure_mdl)
subplot(2,2,2)
formula = 'POST_replay_rate~ time_mobile';
first_exposure_mdl = fitlm(first_exposure_data,formula)
h = plot(first_exposure_mdl)
sgtitle('First exposure behaviour')

formula = 'POST_replay_rate~ time_immobile + time_mobile';
first_exposure_mdl = fitlm(first_exposure_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
h = plotAdded(first_exposure_mdl)

for n = 2:length(first_exposure_mdl.CoefficientNames)
    subplot(2,2,n)
    h = plotAdded(first_exposure_mdl,n); % modified to use global variables to output confidence interval
    hold on
    global xconf
    global yfit
    global lower
    global upper
    CI(1) = yline(max(lower),'b--')
    CI(1) = yline(min(upper),'b--')
%     legend([])
%     
%     text(gca,.7,0.1,...
%         sprintf('p = %.2d & R2 = %.3f',pval,awake_rate_R2),...
%         'Units','Normalized','FontName','Arial');
    linspace_x(n,:) = xconf;
    adjusted_y(n,:) = yfit;
    lower_CI(n,:) = lower;
    upper_CI(n,:) = upper;
    clear global
end
sgtitle('First exposure behaviour')


% Re exposure
fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
formula = 'POST_replay_rate~ time_immobile';
re_exposure_mdl = fitlm(re_exposure_data,formula)
h = plot(re_exposure_mdl)
subplot(2,2,2)
formula = 'POST_replay_rate~ time_mobile';
re_exposure_mdl = fitlm(re_exposure_data,formula)
h = plot(re_exposure_mdl)
sgtitle('Re-exposure behaviour')

formula = 'POST_replay_rate~ time_immobile + time_mobile';
re_exposure_mdl = fitlm(re_exposure_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
h = plotAdded(re_exposure_mdl)

for n = 2:length(re_exposure_mdl.CoefficientNames)
    subplot(2,2,n)
    h = plotAdded(re_exposure_mdl,n); % modified to use global variables to output confidence interval
    hold on
    global xconf
    global yfit
    global lower
    global upper
    CI(1) = yline(max(lower),'b--')
    CI(1) = yline(min(upper),'b--')
%     legend([])
%     
%     text(gca,.7,0.1,...
%         sprintf('p = %.2d & R2 = %.3f',pval,awake_rate_R2),...
%         'Units','Normalized','FontName','Arial');
    linspace_x(n,:) = xconf;
    adjusted_y(n,:) = yfit;
    lower_CI(n,:) = lower;
    upper_CI(n,:) = upper;
    clear global
end
sgtitle('Re-exposure behaviour')

%% replay and theta VS Behaviour

% First exposure
fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
formula = 'POST_replay_rate~ theta_number';
first_exposure_mdl = fitlm(first_exposure_data,formula)
h = plotAdded(first_exposure_mdl)
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')

subplot(2,2,2)
formula = 'POST_replay_rate~ awake_replay_rate';
first_exposure_mdl = fitlm(first_exposure_data,formula)
h = plotAdded(first_exposure_mdl)
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')

subplot(2,2,3)
formula = 'POST_replay_rate~ awake_replay_number';
first_exposure_mdl = fitlm(first_exposure_data,formula)
h = plotAdded(first_exposure_mdl)
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')
sgtitle('First exposure')

% Re exposure
fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
formula = 'POST_replay_rate~ theta_number';
re_exposure_mdl = fitlm(re_exposure_data,formula)
h = plotAdded(re_exposure_mdl)
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')

subplot(2,2,2)
formula = 'POST_replay_rate~ awake_replay_rate';
re_exposure_mdl = fitlm(re_exposure_data,formula)
h = plotAdded(re_exposure_mdl)
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')

subplot(2,2,3)
formula = 'POST_replay_rate~ awake_replay_number';
re_exposure_mdl = fitlm(re_exposure_data,formula)
h = plotAdded(re_exposure_mdl)
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')

sgtitle('Re-exposure')


% neural mechanism vs behaviour First exposure
formula = 'POST_replay_rate~ awake_replay_rate + time_immobile + time_mobile';
first_exposure_mdl = fitlm(first_exposure_data,formula)
% first_exposure_mdl = fitglm(first_exposure_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
h = plotAdded(first_exposure_mdl)
subplot(2,2,2)
h = plotAdded(first_exposure_mdl,first_exposure_mdl.CoefficientNames{2})
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')
sgtitle('First exposure')

formula = 'POST_replay_rate~ theta_number + time_immobile + time_mobile';
first_exposure_mdl = fitlm(first_exposure_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
h = plotAdded(first_exposure_mdl)
subplot(2,2,2)
h = plotAdded(first_exposure_mdl,first_exposure_mdl.CoefficientNames{2})
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')
sgtitle('First exposure')

formula = 'POST_replay_rate~ awake_replay_number + time_immobile + time_mobile';
first_exposure_mdl = fitlm(first_exposure_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
h = plotAdded(first_exposure_mdl)
subplot(2,2,2)
h = plotAdded(first_exposure_mdl,first_exposure_mdl.CoefficientNames{2})
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')
sgtitle('First exposure')



% neural mechanism vs behaviour Re exposure
formula = 'POST_replay_rate~ awake_replay_rate + time_immobile + time_mobile + (1|animal_label) + (1|track_label)';
% formula = 'POST_replay_rate~ awake_replay_rate + awake_replay_number + (1|animal_label)';
re_exposure_mdl = fitlme(both_exposures_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
h = plotAdded(re_exposure_mdl)
subplot(2,2,2)
h = plotAdded(re_exposure_mdl,re_exposure_mdl.CoefficientNames{2})
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')
sgtitle('Both exposures')

formula = 'POST_replay_rate~ theta_number + time_mobile + time_immobile + (1|animal_label) ';
re_exposure_mdl = fitlme(both_exposures_data,formula)


fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
h = plotAdded(re_exposure_mdl)
subplot(2,2,2)
h = plotAdded(re_exposure_mdl,re_exposure_mdl.CoefficientNames{2})
sgtitle('Both exposures')
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')

formula = 'POST_replay_rate~ awake_replay_number + time_immobile + time_mobile + (1|animal_label) + (1|track_label) ';
re_exposure_mdl = fitlme(both_exposures_data,formula)


fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
h = plotAdded(re_exposure_mdl)
subplot(2,2,2)
h = plotAdded(re_exposure_mdl,re_exposure_mdl.CoefficientNames{2})
sgtitle('Both exposures')
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')

%%



%% neural mechanism vs behaviour
% formula = 'POST_replay_rate~ awake_replay_number + theta_number';
% formula = 'POST_replay_rate~ awake_replay_number + awake_replay_rate';
% formula = 'POST_replay_rate~ awake_replay_number + theta_number + time_immobile + time_mobile';
% formula = 'POST_replay_rate~  awake_replay_rate + awake_replay_number + time_immobile + time_mobile';
% data = first_exposure_data;
% data = re_exposure_data;
% data = both_exposures_data;
% data_SWR = both_exposures_data_SWR;
data = [both_exposures_data both_exposures_data_SWR(:,3:5)];

for n = 1:1000
    s1 = RandStream('mcg16807','Seed',n);
    x{n} = data(datasample(s1,1:size(data,1),size(data,1)),:);
end
opt = statset('LinearMixedModel');
opt.UseParallel = true;

formula0 = 'POST_replay_rate~  time_immobile + time_mobile';
% formula0 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle ';
mdl0 = fitlme(data,formula0)
% fitglm(data,formula)

formula01 = 'POST_replay_rate~  time_immobile + time_mobile + (1|animal_label)';
% formula0 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle ';
mdl01 = fitlme(data,formula01)
results = compare(mdl0,mdl01,'nsim',1000,'Options',opt);

parfor n = 1:1000
    mdl01 = fitlme(x{n},formula01)
%     [pval,F_stat,~] = coefTest(mdl01);
    behaviour_R2(n) = mdl01.Rsquared.Adjusted;
    behaviour_b(n,:) = mdl01.Coefficients.Estimate';
end

% fitglm(data,formula)

formula1 = 'POST_replay_rate~  awake_replay_rate + awake_replay_number + theta_number  + (1|animal_label)';
formula1 = 'POST_replay_rate~  awake_replay_rate + awake_replay_number + theta_number + time_total  + (1|animal_label)';
% formula1 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle + time_immobile + time_mobile ';
mdl1 = fitlme(data,formula1)
% adding random effects such animal effect and track effect
results = compare(mdl0,mdl1,'nsim',1000,'Options',opt);

parfor n = 1:1000
    mdl1 = fitlme(x{n},formula1)
%     [pval,F_stat,~] = coefTest(mdl01);
    theta_replay_R2(n) = mdl1.Rsquared.Adjusted;
    theta_replay_b(n,:) = mdl1.Coefficients.Estimate';
end

formula2 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle + (1|animal_label)';
formula2 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle + time_total  + (1|animal_label)+ (1|track_label)';
mdl2 = fitlme(data,formula2)
% adding interaction not significantly better than multiple regression
results = compare(mdl0,mdl2,'nsim',1000,'Options',opt);
% fixedEffects(mdl2)
% [ypred,ypredCI,DF] = predict(mdl2,data)

parfor n = 1:1000
    mdl2 = fitlme(x{n},formula2)
%     [pval,F_stat,~] = coefTest(mdl01);
    theta_SWR_R2(n) = mdl2.Rsquared.Adjusted;
    theta_SWR_b(n,:) = mdl2.Coefficients.Estimate';
end


formula11 = 'POST_replay_rate~  awake_replay_rate + awake_replay_number + theta_number  + time_immobile + time_mobile + (1|animal_label)';
% formula2 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle + (1|animal_label)';
mdl11 = fitlme(data,formula11)
% adding interaction not significantly better than multiple regression
results = compare(mdl1,mdl11,'nsim',1000,'Options',opt);

formula21 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle  + time_immobile + time_mobile + (1|animal_label)';
% formula2 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle + (1|animal_label)';
mdl21 = fitlme(data,formula21)
% adding interaction not significantly better than multiple regression
results = compare(mdl2,mdl21,'nsim',1000,'Options',opt);

formula3 = 'POST_replay_rate~  awake_SWR_rate + awake_SWR_number + theta_cycle  + awake_replay_rate + awake_replay_number + theta_number + (1|animal_label)';
mdl3 = fitlme(data,formula3)
% adding interaction not significantly better than multiple regression
results = compare(mdl1,mdl3,'nsim',1000,'Options',opt);
results = compare(mdl2,mdl3,'nsim',1000,'Options',opt);


% Pairwise testing
behaviour_vs_replay_theta = compare(mdl01,mdl1,'nsim',1000,'Options',opt,'Alpha',0.05/3);
behaviour_vs_SWR_theta = compare(mdl01,mdl2,'nsim',1000,'Options',opt,'Alpha',0.05/3);
SWR_vs_replay_theta = compare(mdl2,mdl1,'nsim',1000,'Options',opt,'Alpha',0.05/3);


% Testing models
[B,Bnames,stats] = fixedEffects(mdl1);
[B,Bnames,stats] = randomEffects(mdl1);
[pVal,F,DF1,DF2] = coefTest(mdl1);
% results = compare(mdl1,mdl2)

results = compare(mdl0,mdl1,'nsim',100,'Options',opt);


nfig = figure('Color','w','Name','Mixed effect model comparisions')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')
clear b

nexttile
hold on
% x = [mean(theta_SWR_b(:,2)) mean(theta_SWR_b(:,3)) mean(theta_SWR_b(:,4))];
% x_CI = [prctile(theta_SWR_b(:,2),[2.5 97.5]); prctile(theta_SWR_b(:,3),[2.5 97.5]); prctile(theta_SWR_b(:,4),[2.5 97.5])];
x = [double(mdl2.Coefficients(2,2)) double(mdl2.Coefficients(3,2)) double(mdl2.Coefficients(4,2)) double(mdl2.Coefficients(5,2))];
x_CI = [double(mdl2.Coefficients(2,7:8)); double(mdl2.Coefficients(3,7:8)); double(mdl2.Coefficients(4,7:8)); double(mdl2.Coefficients(5,7:8))];

for k = 1:4
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3 4])
xticklabels({'Total time on track','Awake SWR rate','Awake SWR number','Theta cycles'})
ylim([-0.1 1])
ylabel('Beta coefficient')



nexttile
hold on
x = [double(mdl1.Coefficients(2,2)) double(mdl1.Coefficients(3,2)) double(mdl1.Coefficients(4,2)) double(mdl1.Coefficients(5,2))];
x_CI = [double(mdl1.Coefficients(2,7:8)); double(mdl1.Coefficients(3,7:8)); double(mdl1.Coefficients(4,7:8));double(mdl1.Coefficients(5,7:8))];
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
xticklabels({'Total time on track','Awake replay rate','Awake replay number','Theta sequence'})
ylim([-0.1 1])
ylabel('Beta coefficient')
nexttile
nexttile
nexttile

%% Theta vs Replay rate vs Replay number
% neural mechanism vs behaviour First exposure
formula = 'POST_replay_rate~ awake_replay_number + theta_number';
formula = 'POST_replay_rate~ awake_replay_number + awake_replay_rate';
formula = 'POST_replay_rate~ awake_replay_number + theta_number + time_immobile + time_mobile';
% formula = 'POST_replay_rate~  awake_replay_rate + awake_replay_number + time_immobile + time_mobile';
first_exposure_mdl = fitlm(first_exposure_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,3,1)
h = plotAdded(first_exposure_mdl)
for n = 2:length(first_exposure_mdl.CoefficientNames)
    subplot(2,3,n)
    h = plotAdded(first_exposure_mdl,first_exposure_mdl.CoefficientNames{n})
    global lower
    global upper
    hold on
    CI(1) = yline(max(lower),'b--')
    CI(1) = yline(min(upper),'b--')
end
sgtitle('First exposure')

formula = 'POST_replay_rate~ awake_replay_number + awake_replay_rate+ time_immobile + time_mobile ';
first_exposure_mdl = fitlm(first_exposure_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,3,1)
subplot(2,3,1)
h = plotAdded(first_exposure_mdl)
for n = 2:length(first_exposure_mdl.CoefficientNames)
    subplot(2,3,n)
    h = plotAdded(first_exposure_mdl,first_exposure_mdl.CoefficientNames{n})
    global lower
    global upper
    hold on
    CI(1) = yline(max(lower),'b--')
    CI(1) = yline(min(upper),'b--')
end
sgtitle('First exposure')

% neural mechanism vs behaviour Re exposure
formula = 'POST_replay_rate~ awake_replay_rate + theta_number + awake_replay_number';
formula = 'POST_replay_rate~  theta_number + awake_replay_number + time_immobile + time_mobile';
% formula = 'POST_replay_rate~  awake_replay_rate + awake_replay_number + time_immobile + time_mobile';
re_exposure_mdl = fitlm(re_exposure_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,3,1)
h = plotAdded(re_exposure_mdl)
for n = 2:length(re_exposure_mdl.CoefficientNames)
    subplot(2,3,n)
    h = plotAdded(re_exposure_mdl,re_exposure_mdl.CoefficientNames{n})
    global lower
    global upper
    hold on
    CI(1) = yline(max(lower),'b--')
    CI(1) = yline(min(upper),'b--')
end
sgtitle('Re exposure')

formula = 'POST_replay_rate~  awake_replay_rate + awake_replay_number + time_immobile + time_mobile';
re_exposure_mdl = fitlm(re_exposure_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,3,1)
h = plotAdded(re_exposure_mdl)
for n = 2:length(re_exposure_mdl.CoefficientNames)
    subplot(2,3,n)
    h = plotAdded(re_exposure_mdl,re_exposure_mdl.CoefficientNames{n})
    global lower
    global upper
    hold on
    CI(1) = yline(max(lower),'b--')
    CI(1) = yline(min(upper),'b--')
end
sgtitle('Re exposure')

%% Theta vs Replay rate vs Replay number (behaviour accounted)

% neural mechanism vs behaviour First exposure
formula = 'POST_replay_rate~ awake_replay_rate + theta_number + awake_replay_number + time_immobile + time_mobile';
first_exposure_mdl = fitlm(first_exposure_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
h = plotAdded(first_exposure_mdl)
for n = 2:4
    subplot(2,2,n)
    h = plotAdded(first_exposure_mdl,first_exposure_mdl.CoefficientNames{n})
end
sgtitle('First exposure')

% neural mechanism vs behaviour Re exposure
formula = 'POST_replay_rate~ awake_replay_rate + theta_number + awake_replay_number + time_immobile + time_mobile';
re_exposure_mdl = fitlm(re_exposure_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,2,1)
h = plotAdded(re_exposure_mdl)
for n = 2:4
    subplot(2,2,n)
    h = plotAdded(re_exposure_mdl,re_exposure_mdl.CoefficientNames{n})
end
sgtitle('Re exposure')

%% T1 T2 difference

% T1 T2 difference 1st exposure
POST_replay_rate_difference = zscore(INTER_T1_rate_events- INTER_T2_rate_events)';
awake_replay_number_difference = zscore(awake_local_replay_T1-awake_local_replay_T2)';
theta_number_difference = zscore(total_num_thetaseq(:,1)-total_num_thetaseq(:,2));
awake_replay_rate_difference = zscore(awake_rate_replay_T1-awake_rate_replay_T2)';
time_mobile_difference = zscore(mobility(:,1)-mobility(:,2));
time_immobile_difference = zscore(immobility(:,1)-immobility(:,2));
speed_difference = zscore(running_speed(:,1)-running_speed(:,2)); 
difference_data_1st = table(POST_replay_rate_difference,awake_replay_rate_difference,...
    awake_replay_number_difference,theta_number_difference,time_mobile_difference,...
    time_immobile_difference,speed_difference,'VariableNames',...
    {'POST_replay_rate_difference','awake_replay_rate_difference',...
    'awake_replay_number_difference','theta_number_difference',...
    'time_mobile_difference','time_immobile_difference','speed_difference'});

% T1 T2 Difference 2nd exposure
POST_replay_rate_difference = zscore(FINAL_RT1_rate_events-FINAL_RT2_rate_events)';
awake_replay_number_difference = zscore(awake_local_replay_RT1-awake_local_replay_RT2)';
theta_number_difference = zscore(total_num_thetaseq(:,3)-total_num_thetaseq(:,4));
awake_replay_rate_difference = zscore(awake_rate_replay_RT1-awake_rate_replay_RT2)';
time_mobile_difference = zscore(mobility(:,3)-mobility(:,4));
time_immobile_difference = zscore(immobility(:,3)-immobility(:,4));
speed_difference = zscore(running_speed(:,3)-running_speed(:,4)); 

difference_data_2nd = table(POST_replay_rate_difference,awake_replay_rate_difference,...
    awake_replay_number_difference,theta_number_difference,time_mobile_difference,...
    time_immobile_difference,speed_difference,'VariableNames',...
    {'POST_replay_rate_difference','awake_replay_rate_difference',...
    'awake_replay_number_difference','theta_number_difference',...
    'time_mobile_difference','time_immobile_difference','speed_difference'});

difference_data = [difference_data_1st; difference_data_2nd];

% formula = 'POST_replay_rate_difference~  awake_replay_number_difference + theta_number_difference';
formula = 'POST_replay_rate_difference~ awake_replay_rate_difference + awake_replay_number_difference';

formula = 'POST_replay_rate_difference~  awake_replay_number_difference + theta_number_difference + time_mobile_difference + time_immobile_difference';
% formula = 'POST_replay_rate_difference~  awake_replay_rate_difference + awake_replay_number_difference + theta_number_difference + time_mobile_difference + time_immobile_difference';
formula = 'POST_replay_rate_difference~  awake_replay_number_difference +time_immobile_difference';
% formula = 'POST_replay_rate_difference~  theta_number_difference + time_mobile_difference';
formula = 'POST_replay_rate_difference~  awake_replay_rate_difference + time_immobile_difference';
first_exposure_mdl = fitlm(difference_data_1st,formula)
% first_exposure_mdl = fitlm(difference_data,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,3,1)
h = plotAdded(first_exposure_mdl)
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')
for n = 2:length(first_exposure_mdl.CoefficientNames)
    subplot(2,3,n)
    h = plotAdded(first_exposure_mdl,first_exposure_mdl.CoefficientNames{n})
    global lower
    global upper
    hold on
    CI(1) = yline(max(lower),'b--')
    CI(1) = yline(min(upper),'b--')
end
sgtitle('first exposure')


% formula = 'POST_replay_rate_difference~ awake_replay_number_difference + theta_number_difference';
formula = 'POST_replay_rate_difference~ awake_replay_number_difference + theta_number_difference';
formula = 'POST_replay_rate_difference~ awake_replay_rate_difference + awake_replay_number_difference';

formula = 'POST_replay_rate_difference~  awake_replay_number_difference + theta_number_difference + time_mobile_difference + time_immobile_difference';
formula = 'POST_replay_rate_difference~  awake_replay_number_difference + time_immobile_difference';
% formula = 'POST_replay_rate_difference~  theta_number_difference + time_mobile_difference';
formula = 'POST_replay_rate_difference~  awake_replay_rate_difference + time_immobile_difference';
re_exposure_mdl = fitlm(difference_data_2nd,formula)
fig = figure
fig.Position = [5 175 960 800];
subplot(2,3,1)
h = plotAdded(re_exposure_mdl)
global lower
global upper
hold on
CI(1) = yline(max(lower),'b--')
CI(1) = yline(min(upper),'b--')
for n = 2:length(re_exposure_mdl.CoefficientNames)
    subplot(2,3,n)
    h = plotAdded(re_exposure_mdl,re_exposure_mdl.CoefficientNames{n})
    global lower
    global upper
    hold on
    CI(1) = yline(max(lower),'b--')
    CI(1) = yline(min(upper),'b--')
end
sgtitle('Re exposure')

