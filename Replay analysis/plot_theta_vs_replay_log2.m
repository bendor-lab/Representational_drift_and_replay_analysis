function plot_theta_vs_replay_log2(bayesian_control,rest_option,time_chunk_size,time_window)

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

%% Stat for theta sequence and replay difference across tracks
[awake_rate_p(1),~] = signrank(awake_rate_replay_T1, awake_rate_replay_T2);
[awake_rate_p(2),~] = signrank(awake_rate_replay_RT1, awake_rate_replay_RT2);

[awake_number_p(1),~] = signrank(awake_local_replay_T1, awake_local_replay_T2);
[awake_number_p(2),~] = signrank(awake_local_replay_RT1, awake_local_replay_RT2);

[awake_theta_p(1),~] = signrank(total_num_thetaseq(:,1), total_num_thetaseq(:,2));
[awake_theta_p(2),~] = signrank(total_num_thetaseq(:,3), total_num_thetaseq(:,4));

mean(FINAL_RT2_rate_events)
std(FINAL_RT2_rate_events)/sqrt(length(FINAL_RT2_rate_events))

[POST_replay_p(1),~] = signrank(INTER_T1_rate_events, INTER_T2_rate_events);
[POST_replay_p(2),~] = signrank(FINAL_RT1_rate_events, FINAL_RT2_rate_events);


%% POST Replay rate (Track combined)
f11 = figure('units','normalized','Color','w');
% f11.Position = [450 180 930 660];
f11.Position = [0.4 0.2 0.2 0.7]
tiledlayout('flow')
f11.Name = [sprintf('POST replay rate per track(%s)',rest_option)];

% col = [PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2];
col = [PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2;PP.RUN2T2];
% x_labels = {'RUN1 T1','RUN1 T2','RUN2 T1','RUN2 T2'};
x_labels = {'RUN1 T1','RUN1 T2','RUN2 T1','RUN2 T2',''};
nexttile
% grp = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
% tst=[INTER_T1_rate_events; INTER_T2_rate_events; FINAL_RT1_rate_events; FINAL_RT2_rate_events]';
tst=[INTER_T1_rate_events; INTER_T2_rate_events; FINAL_RT1_rate_events; FINAL_RT2_rate_events;NaN(1,19)]';
hold on
boxplot(tst,'PlotStyle','traditional','Colors',col,'labels',x_labels,...
    'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes = a(idx([1,2,3,4,5]));  % Get the children you need (boxes for first exposure)
set(boxes,'LineWidth',2); % Set width
whisk = a([find(strcmpi(tt,'Lower Whisker')==1) find(strcmpi(tt,'Upper Whisker')==1)...
    find(strcmpi(tt,'Upper Adjacent Value')==1)  find(strcmpi(tt,'Lower Adjacent Value')==1) ]);  % Find whiskers objects
set(whisk,'LineWidth',1.5,'LineStyle','-')
med = a(find(strcmpi(tt,'Median')==1));  % Find median objects
set(med,'LineWidth',1.5)

box off
hold on
for i = 1:size(tst,2)
    h= plot(i,tst(:,i),'o','MarkerEdgeColor',col(i,:),'MarkerFaceColor',col(i,:));
    set(h,{'Marker'},{'o'},{'Markersize'},{5},'MarkerFaceColor','w','LineWidth',1.5); %,{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6}
end
allax = findobj(gcf,'Type','axes');
ytickformat(allax,'%.3f')      
%set(ax,'ylim',[0 2.5])
%set(ax,'ytick',[0:1:2])
set(allax,'ylim',[0 .07],'ytick',[0 .02 0.04 0.06])
ylabel('Rate of POST replay')
xlabel('Exposures')
% set(gca,'FontSize',14)

title({'POST replay rate';['first ' num2str(time_chunk_size/60) 'min of : '];rest_option})
nexttile
nexttile
nexttile
nexttile


%% Plot awake replay rate per track, all protocols together
% [p,tbl,stats] = kruskalwallis([awake_rate_replay_T1' awake_rate_replay_T2' awake_rate_replay_RT1' awake_rate_replay_RT2'],[],'off')
%
% if p < .05
%     c = multcompare(stats);
% end
%


f11 = figure('Color','w','Name','Awake replay rates');
f11.Position = [450 180 930 660];
f11.Name = [sprintf('Awake replay rate per track(%s)',rest_option)];

nexttile
grp = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
tst=[awake_rate_replay_T1 awake_rate_replay_T2 awake_rate_replay_RT1 awake_rate_replay_RT2]';

beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'overlay_style','sd','corral_style','rand');
yticks([0:0.04:0.28])
xticks([1:4])
xticklabels({'RUN1 T1','RUN1 T2','RUN2 T1','RUN2 T2'})
ylabel('Rate of awake replay')
% set(gca,'FontSize',14)
ylim([-0.02 0.28])
hold on
axis square
title(sprintf('Awake replay rate for both exposures (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp1 = 3*[ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1]-1;% Only three session with 16-4 laps
tst1=[awake_rate_replay_T1(prot_sess{1}) awake_rate_replay_T1(prot_sess{2})...
    awake_rate_replay_T1(prot_sess{3}) awake_rate_replay_T1(prot_sess{4}) awake_rate_replay_T1(prot_sess{5})]';
grp2 = 3*[ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst2=[awake_rate_replay_T2(prot_sess{1}) awake_rate_replay_T2(prot_sess{2})...
    awake_rate_replay_T2(prot_sess{3}) awake_rate_replay_T2(prot_sess{4}) awake_rate_replay_T2(prot_sess{5})]';

beeswarm([grp1;grp2],[tst1;tst2],'sort_style','nosort','colormap',...
    [PP.T1;PP1.T2(1,:);...
    PP.T1;PP1.T2(2,:);...
    PP.T1;PP1.T2(3,:);...
    PP.T1;PP1.T2(4,:);...
    PP.T1;PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');

yticks([0:0.04:0.28])
xticks([2.5:3:15])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Rate of awake replay')
% set(gca,'FontSize',14)
ylim([-0.02 0.28])
axis square
title(sprintf('Awake replay rate first exposure (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp1 = 3*[ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1]-1;% Only three session with 16-4 laps
tst1=[awake_rate_replay_RT1(prot_sess{1}) awake_rate_replay_RT1(prot_sess{2})...
    awake_rate_replay_RT1(prot_sess{3}) awake_rate_replay_RT1(prot_sess{4}) awake_rate_replay_RT1(prot_sess{5})]';
grp2 = 3*[ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst2=[awake_rate_replay_RT2(prot_sess{1}) awake_rate_replay_RT2(prot_sess{2})...
    awake_rate_replay_RT2(prot_sess{3}) awake_rate_replay_RT2(prot_sess{4}) awake_rate_replay_RT2(prot_sess{5})]';

beeswarm([grp1;grp2],[tst1;tst2],'sort_style','nosort','colormap',...
    [PP.T1;PP1.T2(1,:);...
    PP.T1;PP1.T2(2,:);...
    PP.T1;PP1.T2(3,:);...
    PP.T1;PP1.T2(4,:);...
    PP.T1;PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');

yticks([0:0.04:0.28])
xticks([2.5:3:15])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Rate of awake replay')
% set(gca,'FontSize',14)
ylim([-0.02 0.28])
axis square
title(sprintf('Awake replay rate re-exposure (%s)',rest_option));



%% Plot awake replay number per track, all protocols together
% [p,tbl,stats] = kruskalwallis([awake_rate_replay_T1' awake_rate_replay_T2' awake_rate_replay_RT1' awake_rate_replay_RT2'],[],'off')
%
% if p < .05
%     c = multcompare(stats);
% end
%
% [p2,~] = ranksum(awake_rate_replay_RT1, awake_rate_replay_RT2)

f12 = figure('Color','w','Name','Awake replay rates');
f12.Position = [450 180 930 660];
f12.Name = [sprintf('Awake replay number per track(%s)',rest_option)];

nexttile
grp = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
tst=[awake_local_replay_T1 awake_local_replay_T2 awake_local_replay_RT1 awake_local_replay_RT2]';

beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'overlay_style','sd','corral_style','rand');
yticks([0:20:180])
xticks([1:4])
xticklabels({'RUN1 T1','RUN1 T2','RUN2 T1','RUN2 T2'})
ylabel('Number of awake replay')
% set(gca,'FontSize',14)
ylim([-0.02 180])
hold on
axis square
title(sprintf('Awake replay number for both exposures (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp1 = 3*[ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1]-1;% Only three session with 16-4 laps
tst1=[awake_local_replay_T1(prot_sess{1}) awake_local_replay_T1(prot_sess{2})...
    awake_local_replay_T1(prot_sess{3}) awake_local_replay_T1(prot_sess{4}) awake_local_replay_T1(prot_sess{5})]';
grp2 = 3*[ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst2=[awake_local_replay_T2(prot_sess{1}) awake_local_replay_T2(prot_sess{2})...
    awake_local_replay_T2(prot_sess{3}) awake_local_replay_T2(prot_sess{4}) awake_local_replay_T2(prot_sess{5})]';

beeswarm([grp1;grp2],[tst1;tst2],'sort_style','nosort','colormap',...
    [PP.T1;PP1.T2(1,:);...
    PP.T1;PP1.T2(2,:);...
    PP.T1;PP1.T2(3,:);...
    PP.T1;PP1.T2(4,:);...
    PP.T1;PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');

yticks([0:20:180])
xticks([2.5:3:15])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Number of awake replay')
% set(gca,'FontSize',14)
ylim([-0.02 180])
axis square
title(sprintf('Awake replay number first exposure (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp1 = 3*[ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1]-1;% Only three session with 16-4 laps
tst1=[awake_local_replay_RT1(prot_sess{1}) awake_local_replay_RT1(prot_sess{2})...
    awake_local_replay_RT1(prot_sess{3}) awake_local_replay_RT1(prot_sess{4}) awake_local_replay_RT1(prot_sess{5})]';
grp2 = 3*[ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst2=[awake_local_replay_RT2(prot_sess{1}) awake_local_replay_RT2(prot_sess{2})...
    awake_local_replay_RT2(prot_sess{3}) awake_local_replay_RT2(prot_sess{4}) awake_local_replay_RT2(prot_sess{5})]';

beeswarm([grp1;grp2],[tst1;tst2],'sort_style','nosort','colormap',...
    [PP.T1;PP1.T2(1,:);...
    PP.T1;PP1.T2(2,:);...
    PP.T1;PP1.T2(3,:);...
    PP.T1;PP1.T2(4,:);...
    PP.T1;PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');

yticks([0:20:180])
xticks([2.5:3:15])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Number of awake replay')
% set(gca,'FontSize',14)
ylim([-0.02 180])
axis square
title(sprintf('Awake replay number re-exposure (%s)',rest_option));



%% Plot theta sequence number per track, all protocols together
% [p,tbl,stats] = kruskalwallis([awake_rate_replay_T1' awake_rate_replay_T2' awake_rate_replay_RT1' awake_rate_replay_RT2'],[],'off')
%
% if p < .05
%     c = multcompare(stats);
% end
%
% [p2,~] = ranksum(awake_rate_replay_RT1, awake_rate_replay_RT2)

f12 = figure('Color','w','Name','Theta sequence number per track');
f12.Position = [450 180 930 660];
f12.Name = [sprintf('Theta sequence number per track(%s)',rest_option)];

nexttile
grp = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
tst = [total_num_thetaseq(:,1)' total_num_thetaseq(:,2)' total_num_thetaseq(:,3)' total_num_thetaseq(:,4)']';

beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'overlay_style','sd','corral_style','rand');
yticks([0:500:3100])
xticks([1:4])
xticklabels({'RUN1 T1','RUN1 T2','RUN2 T1','RUN2 T2'})
ylabel('Number of theta sequence')
% set(gca,'FontSize',14)
ylim([-0.02 3100])
hold on
axis square
title(sprintf('Theta sequence number for both exposures (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp1 = 3*[ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1]-1;% Only three session with 16-4 laps
tst1 = [total_num_thetaseq(prot_sess{1},1)' total_num_thetaseq(prot_sess{2},1)'...
    total_num_thetaseq(prot_sess{3},1)' total_num_thetaseq(prot_sess{4},1)' total_num_thetaseq(prot_sess{5},1)']';

grp2 = 3*[ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst2 = [total_num_thetaseq(prot_sess{1},2)' total_num_thetaseq(prot_sess{2},2)'...
    total_num_thetaseq(prot_sess{3},2)' total_num_thetaseq(prot_sess{4},2)' total_num_thetaseq(prot_sess{5},2)']';

beeswarm([grp1;grp2],[tst1;tst2],'sort_style','nosort','colormap',...
    [PP.T1;PP1.T2(1,:);...
    PP.T1;PP1.T2(2,:);...
    PP.T1;PP1.T2(3,:);...
    PP.T1;PP1.T2(4,:);...
    PP.T1;PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');

yticks([0:500:3100])
xticks([2.5:3:15])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Number of theta sequence')
% set(gca,'FontSize',14)
ylim([-0.02 3100])
axis square
title(sprintf('Theta sequence number first exposure (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp1 = 3*[ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1]-1;% Only three session with 16-4 laps
tst1 = [total_num_thetaseq(prot_sess{1},3)' total_num_thetaseq(prot_sess{2},3)'...
    total_num_thetaseq(prot_sess{3},3)' total_num_thetaseq(prot_sess{4},3)' total_num_thetaseq(prot_sess{5},3)']';

grp2 = 3*[ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst2 = [total_num_thetaseq(prot_sess{1},4)' total_num_thetaseq(prot_sess{2},4)'...
    total_num_thetaseq(prot_sess{3},4)' total_num_thetaseq(prot_sess{4},4)' total_num_thetaseq(prot_sess{5},4)']';

beeswarm([grp1;grp2],[tst1;tst2],'sort_style','nosort','colormap',...
    [PP.T1;PP1.T2(1,:);...
    PP.T1;PP1.T2(2,:);...
    PP.T1;PP1.T2(3,:);...
    PP.T1;PP1.T2(4,:);...
    PP.T1;PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');

yticks([0:500:3100])
xticks([2.5:3:15])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Number of theta sequence')
% set(gca,'FontSize',14)
ylim([-0.02 3100])
axis square
title(sprintf('Theta sequence number re-exposure (%s)',rest_option));


%% Theta sequence wcorr and p value against number of laps
nfig = figure('Color','w','Name','Theta sequence wcorr and p value against number of laps')
nfig.Position = [940 130 920 820];
orient(nfig,'landscape')

col = [PP.L1; PP.L2; PP.L3; PP.L4; PP.L8; PP.L16; [0.4 0.4 0.4]; [0.8 0.8 0.8]];
x_labels = {'1','2','3','4','8','16','RT1','RT2'}; %set labels for X axis
%     [p1,~,stats1]=kruskalwallis(track_rates_t1,[],'off');
%     [p2,~,stats2]=kruskalwallis(track_rates_t2,[],'off');
%     if p1 < .05
%         disp(p)
%         disp(1)
%         c1 = multcompare(stats1,'dunn-sidak','off');
%     end
%     if p2 < .05
%         disp(2)
%         disp(1)
%         c2 = multcompare(stats2,'dunn-sidak','off');
%     end
%
%


% wcorr score
theta = [[wcorr_score(16:19,2); nan(15,1)],[wcorr_score(12:15,2); nan(15,1)],[wcorr_score(8:11,2); nan(15,1)],[wcorr_score(5:7,2); nan(16,1)],...
    [wcorr_score(1:4,2); nan(15,1)],wcorr_score(:,1),wcorr_score(:,3),wcorr_score(:,4)];% Fill nan
nexttile
hold on
boxplot(theta,'PlotStyle','traditional','Colors',col,'labels',x_labels,...
    'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes = a(idx([1,2,3,4,5,6,7,8]));  % Get the children you need (boxes for first exposure)
set(boxes,'LineWidth',2); % Set width
whisk = a([find(strcmpi(tt,'Lower Whisker')==1) find(strcmpi(tt,'Upper Whisker')==1)...
    find(strcmpi(tt,'Upper Adjacent Value')==1)  find(strcmpi(tt,'Lower Adjacent Value')==1) ]);  % Find whiskers objects
set(whisk,'LineWidth',1.5,'LineStyle','-')
med = a(find(strcmpi(tt,'Median')==1));  % Find median objects
set(med,'LineWidth',1.5)

box off
hold on
for i = 1:size(theta,2)
    h= plot(i,theta(:,i),'o','MarkerEdgeColor',col(i,:),'MarkerFaceColor',col(i,:));
    set(h,{'Marker'},{'o'},{'Markersize'},{5},'MarkerFaceColor','w','LineWidth',1.5); %,{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6}
end
xlabel('Protocols')
ylabel('Socres')
title('Weight Correlation Socres')


% P value
theta = [[theta_pval(16:19,2); nan(15,1)],[theta_pval(12:15,2); nan(15,1)],[theta_pval(8:11,2); nan(15,1)],[theta_pval(5:7,2); nan(16,1)],...
    [theta_pval(1:4,2); nan(15,1)],theta_pval(:,1),theta_pval(:,3),theta_pval(:,4)];% Fill nan
nexttile

hold on
boxplot(theta,'PlotStyle','traditional','Colors',col,'labels',x_labels,...
    'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes = a(idx([1,2,3,4,5,6,7,8]));  % Get the children you need (boxes for first exposure)
set(boxes,'LineWidth',2); % Set width
whisk = a([find(strcmpi(tt,'Lower Whisker')==1) find(strcmpi(tt,'Upper Whisker')==1)...
    find(strcmpi(tt,'Upper Adjacent Value')==1)  find(strcmpi(tt,'Lower Adjacent Value')==1) ]);  % Find whiskers objects
set(whisk,'LineWidth',1.5,'LineStyle','-')
med = a(find(strcmpi(tt,'Median')==1));  % Find median objects
set(med,'LineWidth',1.5)

box off
hold on
for i = 1:size(theta,2)
    h= plot(i,theta(:,i),'o','MarkerEdgeColor',col(i,:),'MarkerFaceColor',col(i,:));
    set(h,{'Marker'},{'o'},{'Markersize'},{5},'MarkerFaceColor','w','LineWidth',1.5); %,{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6}
end
xlabel('Protocols')
ylabel('P value')
title('Weight Correlation P value')
nexttile

%% Colinearlity between theta number, awake replay number and rate
nfig = figure('Color','w','Name','Collinearity between theta sequence and awake replay')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

awake_rate = [awake_rate_replay_T1 awake_rate_replay_T2 awake_rate_replay_RT1 awake_rate_replay_RT2]';
% index = find(awake_rate==0);
% awake_rate =
awake_rate(awake_rate==0) = min(awake_rate(awake_rate~=0));
awake_rate = log2(awake_rate);

awake_number = [awake_local_replay_T1 awake_local_replay_T2 awake_local_replay_RT1 awake_local_replay_RT2]';
awake_number(awake_number==0) = min(awake_number(awake_number~=0));
% awake_number(awake_number==0) = 1;
awake_number = log2(awake_number);

awake_theta = [total_num_thetaseq(:,1)' total_num_thetaseq(:,2)' total_num_thetaseq(:,3)' total_num_thetaseq(:,4)'];
awake_theta(awake_theta==0) = min(awake_theta(awake_theta~=0));
awake_theta = log2(awake_theta);

sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
sleep(sleep==0) = min(sleep(sleep~=0));
% sleep(sleep==0) = 1;
sleep = log2(sleep);


new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];

nexttile
hold on
arrayfun(@(x) scatter(awake_rate(x),awake_number(x),86,new_cls(x,:),'filled','o'),1:length(awake_number))

mdl = fitlm(awake_rate',awake_number');
[pval,F_stat,~] = coefTest(mdl);
awake_rate_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_rate) max(awake_rate)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Rate of awake replay rate (log2)')
ylabel('Number of awake replay number (log2)')
% set(gca,'FontSize',14)
title(sprintf('Rate vs Number of awake replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_rate_R2),'Units','Normalized','FontName','Arial');
axis square

nexttile
hold on
arrayfun(@(x) scatter(awake_rate(x),awake_number(x),86,sleep(x),'filled','o'),1:length(awake_number))
colormap(hot)
colorbar

mdl = fitlm(awake_rate',awake_number');
[pval,F_stat,~] = coefTest(mdl);
awake_rate_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_rate) max(awake_rate)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Rate of awake replay rate (log2)')
ylabel('Number of awake replay number (log2)')
% set(gca,'FontSize',14)
title(sprintf('Rate vs Number of awake replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_rate_R2),'Units','Normalized','FontName','Arial');
axis square



nexttile
hold on
arrayfun(@(x) scatter(awake_rate(x),awake_theta(x),86,new_cls(x,:),'filled','o'),1:length(awake_theta))


mdl = fitlm(awake_rate',awake_theta');
[pval,F_stat,~] = coefTest(mdl);
awake_rate_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_rate) max(awake_rate)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Rate of awake replay rate (log2)')
ylabel('Number of theta sequecne (log2)')
% set(gca,'FontSize',14)
title(sprintf('Replay rate vs theta sequence number (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_rate_R2),'Units','Normalized','FontName','Arial');
axis square


nexttile
hold on
arrayfun(@(x) scatter(awake_rate(x),awake_theta(x),86,sleep(x),'filled','o'),1:length(awake_theta))
colormap(hot)
colorbar

mdl = fitlm(awake_rate',awake_theta');
[pval,F_stat,~] = coefTest(mdl);
awake_rate_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_rate) max(awake_rate)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Rate of awake replay rate (log2)')
ylabel('Number of theta sequecne (log2)')
% set(gca,'FontSize',14)
title(sprintf('Replay rate vs theta sequence number (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_rate_R2),'Units','Normalized','FontName','Arial');
axis square


nexttile
hold on
arrayfun(@(x) scatter(awake_number(x),awake_theta(x),86,new_cls(x,:),'filled','o'),1:length(awake_theta))

mdl = fitlm(awake_number',awake_theta');
[pval,F_stat,~] = coefTest(mdl);
awake_rate_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_number) max(awake_number)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Number of awake replay (log2)')
ylabel('Number of theta sequence (log2)')
% set(gca,'FontSize',14)
title(sprintf('Replay number vs theta sequence number (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_rate_R2),'Units','Normalized','FontName','Arial');
axis square


nexttile
hold on
arrayfun(@(x) scatter(awake_number(x),awake_theta(x),86,sleep(x),'filled','o'),1:length(awake_theta))
colormap(hot)
colorbar

mdl = fitlm(awake_number',awake_theta');
[pval,F_stat,~] = coefTest(mdl);
awake_rate_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_number) max(awake_number)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Number of awake replay (log2)')
ylabel('Number of theta sequence (log2)')
% set(gca,'FontSize',14)
title(sprintf('Replay number vs theta sequence number (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_rate_R2),'Units','Normalized','FontName','Arial');
axis square


%% Theta number, awake replay number and rate VS Sleep replay rate
nfig = figure('Color','w','Name','Theta sequence vs awake replay')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

awake_rate = [awake_rate_replay_T1 awake_rate_replay_T2 awake_rate_replay_RT1 awake_rate_replay_RT2]';
% index = find(awake_rate==0);
% awake_rate =
awake_rate(awake_rate==0) = min(awake_rate(awake_rate~=0));
awake_rate = log2(awake_rate);

awake_number = [awake_local_replay_T1 awake_local_replay_T2 awake_local_replay_RT1 awake_local_replay_RT2]';
awake_number(awake_number==0) = min(awake_number(awake_number~=0));
% awake_number(awake_number==0) = 1;
awake_number = log2(awake_number);

awake_theta = [total_num_thetaseq(:,1)' total_num_thetaseq(:,2)' total_num_thetaseq(:,3)' total_num_thetaseq(:,4)'];
awake_theta(awake_theta==0) = min(awake_theta(awake_theta~=0));
awake_theta = log2(awake_theta);

sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
sleep(sleep==0) = min(sleep(sleep~=0));
% sleep(sleep==0) = 1;
sleep = log2(sleep);

new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];

nexttile
hold on
arrayfun(@(x) scatter(awake_rate(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(awake_rate))

mdl = fitlm(awake_rate',sleep');
[pval,F_stat,~] = coefTest(mdl);
awake_rate_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_rate) max(awake_rate)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Rate of awake replay (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Rate of awake replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_rate_R2),'Units','Normalized','FontName','Arial');
axis square


nexttile
hold on
arrayfun(@(x) scatter(awake_number(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(awake_number))

mdl = fitlm(awake_number',sleep');
[pval,F_stat,~] = coefTest(mdl);
awake_number_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_number) max(awake_number)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Number of awake replay (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Number of awake replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_number_R2),'Units','Normalized','FontName','Arial');
axis square


nexttile
hold on
arrayfun(@(x) scatter(awake_number(x),sleep(x),86,awake_theta(x),'filled','o'),1:length(awake_number))
colormap(hot)
colorbar
caxis([min(awake_theta) max(awake_theta)+0.5])


mdl = fitlm(awake_number',sleep');
[pval,F_stat,~] = coefTest(mdl);
awake_number_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_number) max(awake_number)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Number of awake replay (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Number of awake replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_number_R2),'Units','Normalized','FontName','Arial');
axis square


nexttile
hold on
arrayfun(@(x) scatter(awake_theta(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(awake_theta))

mdl = fitlm(awake_theta',sleep');
[pval,F_stat,~] = coefTest(mdl);
awake_theta_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_theta) max(awake_theta)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Number of theta sequence (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Number of theta sequence (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_theta_R2),'Units','Normalized','FontName','Arial');
axis square


nexttile
hold on
arrayfun(@(x) scatter(awake_theta(x),sleep(x),86,awake_number(x),'filled','o'),1:length(awake_theta))
colormap(hot)
colorbar
caxis([min(awake_number) max(awake_number)+0.5])

mdl = fitlm(awake_theta',sleep');
[pval,F_stat,~] = coefTest(mdl);
awake_theta_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_theta) max(awake_theta)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Number of theta sequence (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Number of theta sequence (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_theta_R2),'Units','Normalized','FontName','Arial');
axis square

%% Awake replay number and rate VS Sleep replay rate (RUN1 and RUN2 separated)


% First exposure
new_cls_RUN1 = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1)];
new_cls_RUN2 = [repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
awake_replay_number_RUN1 = [awake_local_replay_T1 awake_local_replay_T2];
awake_replay_number_RUN1(awake_replay_number_RUN1==0) = min(awake_replay_number_RUN1(awake_replay_number_RUN1~=0));
awake_replay_number_RUN1 = log2(awake_replay_number_RUN1);

awake_replay_number_RUN2 = [awake_local_replay_RT1 awake_local_replay_RT2];
awake_replay_number_RUN2(awake_replay_number_RUN2==0) = min(awake_replay_number_RUN2(awake_replay_number_RUN2~=0));
awake_replay_number_RUN2 = log2(awake_replay_number_RUN2);

sleep_POST1 = [INTER_T1_rate_events INTER_T2_rate_events];
sleep_POST1(sleep_POST1==0) = min(sleep_POST1(sleep_POST1~=0));
% sleep(sleep==0) = 1;
sleep_POST1 = log2(sleep_POST1);

sleep_POST2 = [FINAL_RT1_rate_events FINAL_RT2_rate_events];
sleep_POST2(sleep_POST2==0) = min(sleep_POST2(sleep_POST2~=0));
% sleep(sleep==0) = 1;
sleep_POST2 = log2(sleep_POST2);


awake_replay_number_RUN1_boot = [];
awake_replay_number_RUN2_boot = [];
sleep_POST1_boot = [];
sleep_POST2_boot = [];
parfor n = 1:1000
    s1 = RandStream('mcg16807','Seed',n);
    s2 = RandStream('mcg16807','Seed',1000+n);
    s3 = RandStream('mcg16807','Seed',2000+n);
    s4 = RandStream('mcg16807','Seed',3000+n);
    seed1 = randi(s1,[1 size(awake_local_replay_T1,2)],1,size(awake_local_replay_T1,2));
    seed2 = randi(s2,[1 size(awake_local_replay_T2,2)],1,size(awake_local_replay_T2,2));
    seed3 = randi(s3,[1 size(awake_local_replay_RT1,2)],1,size(awake_local_replay_RT1,2));
    seed4 = randi(s4,[1 size(awake_local_replay_RT2,2)],1,size(awake_local_replay_RT2,2));
    
    tempt = [awake_local_replay_T1(seed1)...
        awake_local_replay_T2(seed2)];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_number_RUN1_boot(:,n) = log2(tempt);
    
    tempt = [awake_local_replay_RT1(seed3)...
        awake_local_replay_RT2(seed4)];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_number_RUN2_boot(:,n) = log2(tempt);
    
    
    tempt = [awake_rate_replay_T1(seed1)...
        awake_rate_replay_T2(seed2)];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_rate_RUN1_boot(:,n) = log2(tempt);
    
    tempt = [awake_rate_replay_RT1(seed3)...
        awake_rate_replay_RT2(seed4)];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_rate_RUN2_boot(:,n) = log2(tempt);
    
    
    tempt = [total_num_thetaseq(seed1,1)' total_num_thetaseq(seed2,2)'];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_theta_RUN1_boot(:,n) = log2(tempt);
    
    
    tempt = [total_num_thetaseq(seed3,3)' total_num_thetaseq(seed4,4)'];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_theta_RUN2_boot(:,n) = log2(tempt);
    
    tempt = [INTER_T1_rate_events(seed1)...
        INTER_T2_rate_events(seed2)];
    tempt(tempt==0) = min(tempt(tempt~=0));
    sleep_POST1_boot(:,n) = log2(tempt);
    
    tempt =   [FINAL_RT1_rate_events(seed3)...
        FINAL_RT2_rate_events(seed4)];
    tempt(tempt==0) = min(tempt(tempt~=0));
    sleep_POST2_boot(:,n) = log2(tempt);
    
end


nfig = figure('Color','w','Name','Awake replay vs POST replay (RUN1 and RUN2)')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

nexttile
hold on
new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1)];
awake_rate = [awake_rate_replay_T1 awake_rate_replay_T2]';
% index = find(awake_rate==0);
% awake_rate =
awake_rate(awake_rate==0) = min(awake_rate(awake_rate~=0));
awake_rate = log2(awake_rate);

sleep = [INTER_T1_rate_events INTER_T2_rate_events];
sleep(sleep==0) = min(sleep(sleep~=0));
% sleep(sleep==0) = 1;
sleep = log2(sleep);

arrayfun(@(x) scatter(awake_rate(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(awake_rate))

mdl = fitlm(awake_rate',sleep');
[pval,F_stat,~] = coefTest(mdl);
awake_rate_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_rate) max(awake_rate)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Rate of awake replay (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Rate of awake replay (RUN1) (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19)],'RUN 1 Track 1','RUN 1 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_rate_R2),'Units','Normalized','FontName','Arial');
axis square

awake_rate_RUN1_R2_boot = [];
parfor n = 1:1000
    %         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
    mdl = fitlm(awake_rate_RUN1_boot(:,n)',sleep_POST1_boot(:,n)');
    [pval,awake_rate_F_stat(n),~] = coefTest(mdl);
    awake_rate_RUN1_R2_boot(n) = mdl.Rsquared.Adjusted;
end


nexttile
hold on
new_cls = [repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
awake_rate = [awake_rate_replay_RT1 awake_rate_replay_RT2]';
awake_rate(awake_rate==0) = min(awake_rate(awake_rate~=0));
awake_rate = log2(awake_rate);

sleep = [FINAL_RT1_rate_events FINAL_RT2_rate_events];
sleep(sleep==0) = min(sleep(sleep~=0));
% sleep(sleep==0) = 1;
sleep = log2(sleep);

arrayfun(@(x) scatter(awake_rate(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(awake_rate))

mdl = fitlm(awake_rate',sleep');
[pval,F_stat,~] = coefTest(mdl);
awake_rate_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_rate) max(awake_rate)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Rate of awake replay (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Rate of awake replay (RUN2)(%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19)],'RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_rate_R2),'Units','Normalized','FontName','Arial');
axis square

awake_rate_RUN2_R2_boot = [];
parfor n = 1:1000
    %         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
    mdl = fitlm(awake_rate_RUN2_boot(:,n)',sleep_POST2_boot(:,n)');
    [pval,awake_rate_F_stat(n),~] = coefTest(mdl);
    awake_rate_RUN2_R2_boot(n) = mdl.Rsquared.Adjusted;
end

nexttile
new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1)];
awake_number = [awake_local_replay_T1 awake_local_replay_T2]';
awake_number(awake_number==0) = min(awake_number(awake_number~=0));
awake_number = log2(awake_number);

sleep = [INTER_T1_rate_events INTER_T2_rate_events];
sleep(sleep==0) = min(sleep(sleep~=0));
% sleep(sleep==0) = 1;
sleep = log2(sleep);

hold on
arrayfun(@(x) scatter(awake_number(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(awake_number))

mdl = fitlm(awake_number',sleep');
[pval,F_stat,~] = coefTest(mdl);
awake_number_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_number) max(awake_number)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Number of awake replay (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Number of awake replay (RUN1) (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_number_R2),'Units','Normalized','FontName','Arial');
axis square

awake_number_RUN1_R2_boot = [];
parfor n = 1:1000
    %         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
    mdl = fitlm(awake_number_RUN1_boot(:,n)',sleep_POST1_boot(:,n)');
    [pval,awake_rate_F_stat(n),~] = coefTest(mdl);
    awake_number_RUN1_R2_boot(n) = mdl.Rsquared.Adjusted;
end



nexttile
new_cls = [repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
awake_number = [awake_local_replay_RT1 awake_local_replay_RT2]';
awake_number(awake_number==0) = min(awake_number(awake_number~=0));
% awake_number(awake_number==0) = 1;
awake_number = log2(awake_number);
sleep = [FINAL_RT1_rate_events FINAL_RT2_rate_events];
sleep(sleep==0) = min(sleep(sleep~=0));
% sleep(sleep==0) = 1;
sleep = log2(sleep);

hold on
arrayfun(@(x) scatter(awake_number(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(awake_number))

mdl = fitlm(awake_number',sleep');
[pval,F_stat,~] = coefTest(mdl);
awake_number_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_number) max(awake_number)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Number of awake replay (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Number of awake replay (RUN2) (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_number_R2),'Units','Normalized','FontName','Arial');
axis square

awake_number_RUN2_R2_boot = [];
parfor n = 1:1000
    %         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
    mdl = fitlm(awake_number_RUN2_boot(:,n)',sleep_POST2_boot(:,n)');
    [pval,awake_rate_F_stat(n),~] = coefTest(mdl);
    awake_number_RUN2_R2_boot(n) = mdl.Rsquared.Adjusted;
end



%% Awake replay number vs sleep replay (between exposures prediction)')
% 
% % First exposure
% new_cls_RUN1 = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1)];
% new_cls_RUN2 = [repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
% awake_replay_number_RUN1 = [awake_local_replay_T1 awake_local_replay_T2];
% awake_replay_number_RUN1(awake_replay_number_RUN1==0) = min(awake_replay_number_RUN1(awake_replay_number_RUN1~=0));
% awake_replay_number_RUN1 = log2(awake_replay_number_RUN1);
% 
% awake_replay_number_RUN2 = [awake_local_replay_RT1 awake_local_replay_RT2];
% awake_replay_number_RUN2(awake_replay_number_RUN2==0) = min(awake_replay_number_RUN2(awake_replay_number_RUN2~=0));
% awake_replay_number_RUN2 = log2(awake_replay_number_RUN2);
% 
% sleep_POST1 = [INTER_T1_rate_events INTER_T2_rate_events];
% sleep_POST1(sleep_POST1==0) = min(sleep_POST1(sleep_POST1~=0));
% % sleep(sleep==0) = 1;
% sleep_POST1 = log2(sleep_POST1);
% 
% sleep_POST2 = [FINAL_RT1_rate_events FINAL_RT2_rate_events];
% sleep_POST2(sleep_POST2==0) = min(sleep_POST2(sleep_POST2~=0));
% % sleep(sleep==0) = 1;
% sleep_POST2 = log2(sleep_POST2);
% 
% 
% awake_replay_number_RUN1_boot = [];
% awake_replay_number_RUN2_boot = [];
% sleep_POST1_boot = [];
% sleep_POST2_boot = [];
% parfor n = 1:1000
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%     seed1 = randi(s1,[1 size(awake_local_replay_T1,2)],1,size(awake_local_replay_T1,2));
%     seed2 = randi(s2,[1 size(awake_local_replay_T2,2)],1,size(awake_local_replay_T2,2));
%     seed3 = randi(s3,[1 size(awake_local_replay_RT1,2)],1,size(awake_local_replay_RT1,2));
%     seed4 = randi(s4,[1 size(awake_local_replay_RT2,2)],1,size(awake_local_replay_RT2,2));
%     
%     tempt = [awake_local_replay_T1(seed1)...
%         awake_local_replay_T2(seed2)];
%     tempt(tempt==0) = min(tempt(tempt~=0));
%     awake_replay_number_RUN1_boot(:,n) = log2(tempt);
%     
%     tempt = [awake_local_replay_RT1(seed3)...
%         awake_local_replay_RT2(seed4)];
%     tempt(tempt==0) = min(tempt(tempt~=0));
%     awake_replay_number_RUN2_boot(:,n) = log2(tempt);
%     
%     
%     tempt = [INTER_T1_rate_events(seed1)...
%         INTER_T2_rate_events(seed2)];
%     tempt(tempt==0) = min(tempt(tempt~=0));
%     sleep_POST1_boot(:,n) = log2(tempt);
%     
%     tempt =   [FINAL_RT1_rate_events(seed3)...
%         FINAL_RT2_rate_events(seed4)];
%     tempt(tempt==0) = min(tempt(tempt~=0));
%     sleep_POST2_boot(:,n) = log2(tempt);
%     
% end


nexttile
hold on
arrayfun(@(x) scatter(awake_replay_number_RUN1(x),sleep_POST1(x),86,new_cls_RUN1(x,:),'filled','o'),1:length(awake_replay_number_RUN1))

mdl = fitlm(awake_replay_number_RUN2',sleep_POST2');
[pval,F_stat,~] = coefTest(mdl);
% awake_theta_R2 = mdl.Rsquared.Adjusted;
x =awake_replay_number_RUN1;
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

SSE =sum((sleep_POST1-y_est).^2);
SST =sum((sleep_POST1-mean(sleep_POST1)).^2);
awake_number_R2   = 1 - (SSE/SST);

plot([min(x) max(x)],[min(y_est) max(y_est)],':','Color','k','LineWidth',3)
xlabel('Number of awake replay (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Number of awake replay (RUN1 predicted by RUN2)(%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19)],'RUN 1 Track 1','RUN 1 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('R2 = %.3f',awake_number_R2),'Units','Normalized','FontName','Arial');
axis square
% 
% awake_number_R2_boot = [];
% parfor n = 1:1000
%     mdl = fitlm(awake_replay_number_RUN2_boot(:,n)',sleep_POST2_boot(:,n)');
%     [pval,F_stat,~] = coefTest(mdl);
%     % awake_theta_R2 = mdl.Rsquared.Adjusted;
%     x =awake_replay_number_RUN1_boot(:,n)';
%     b = mdl.Coefficients.Estimate';
%     y_est = polyval(fliplr(b),x);
%     
%     SSE =sum((sleep_POST1_boot(:,n)-y_est').^2);
%     SST =sum((sleep_POST1_boot(:,n)-mean(sleep_POST1_boot(:,n))).^2);
%     awake_number_R2_boot(1,n)   = 1 - (SSE/SST);
% end


% Second exposure
nexttile
hold on
arrayfun(@(x) scatter(awake_replay_number_RUN2(x),sleep_POST2(x),86,new_cls_RUN2(x,:),'filled','o'),1:length(awake_replay_number_RUN2))

mdl = fitlm(awake_replay_number_RUN1',sleep_POST1');
[pval,F_stat,~] = coefTest(mdl);
% awake_theta_R2 = mdl.Rsquared.Adjusted;
x =awake_replay_number_RUN2;
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

SSE =sum((sleep_POST2-y_est).^2);
SST =sum((sleep_POST2-mean(sleep_POST2)).^2);
awake_theta_R2   = 1 - (SSE/SST);

plot([min(x) max(x)],[min(y_est) max(y_est)],':','Color','k','LineWidth',3)
xlabel('Number of awake replay(log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Number of awake replay (RUN2 predicted by RUN1)(%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19)],'RUN 1 Track 1','RUN 1 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('R2 = %.3f',awake_theta_R2),'Units','Normalized','FontName','Arial');
axis square
% 
% parfor n = 1:1000
%     mdl = fitlm(awake_replay_number_RUN1_boot(:,n)',sleep_POST1_boot(:,n)');
%     [pval,F_stat,~] = coefTest(mdl);
%     % awake_theta_R2 = mdl.Rsquared.Adjusted;
%     x =awake_replay_number_RUN2_boot(:,n)';
%     b = mdl.Coefficients.Estimate';
%     y_est = polyval(fliplr(b),x);
%     
%     SSE =sum((sleep_POST2_boot(:,n)-y_est').^2);
%     SST =sum((sleep_POST2_boot(:,n)-mean(sleep_POST2_boot(:,n))).^2);
%     awake_number_R2_boot(2,n)   = 1 - (SSE/SST);
% end
% 

% nexttile
% clear b
% x = [mean(awake_number_R2_boot(1,:)) mean(awake_number_R2_boot(2,:))]
% x_CI = [prctile(awake_number_R2_boot(1,:),[2.5 97.5]); prctile(awake_number_R2_boot(2,:),[2.5 97.5])]
% 
% x_location = [1 1.5];
% x_condition = {'RUN1','RUN2'}
% 
% col = [repmat(PP1.T2(5,:),2,1)];
% alpha = [0.3 0.6];
% 
% for k = 1:2
%     hold on
%     b(k) = bar(x_location(k),x(k),0.3,'FaceAlpha',alpha(k))
%     b(k).FaceColor  = col(k,:);
%     %     b(k).ShowBaseLine = 'off';
%     e(k) = errorbar(x_location(k),x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
%     e(k).Color = col(k,:);
% end
% xticks(x_location)
% xticklabels(x_condition)
% ylabel('R2')
% box off
% ylim([-0.05 1])
% title(sprintf('R2 awkae replay number(%s)',rest_option));

nexttile
clear b
x = [mean(awake_rate_RUN1_R2_boot) mean(awake_rate_RUN2_R2_boot) mean(awake_number_RUN1_R2_boot) mean(awake_number_RUN2_R2_boot)];
x_CI = [prctile(awake_rate_RUN1_R2_boot,[2.5 97.5]); prctile(awake_rate_RUN2_R2_boot,[2.5 97.5])...
    ; prctile(awake_number_RUN1_R2_boot,[2.5 97.5]); prctile(awake_number_RUN2_R2_boot,[2.5 97.5])];

for k = 1:4
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3 4])
xticklabels({'RUN1 awake replay rate','RUN2 awake replay rate','RUN1 awake replay number','RUN2 awake replay number'})
ylabel('R2')
title(sprintf('R2 of awake replay (RUN1 and RUN2)(%s)',rest_option));



%% Theta vs sleep replay (First and second separated)
nfig = figure('Color','w','Name','Theta sequence vs sleep replay (RUN1 and RUN2)')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

% First exposure
new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1)];

nexttile
hold on
awake_theta = [total_num_thetaseq(:,1)' total_num_thetaseq(:,2)'];
awake_theta(awake_theta==0) = min(awake_theta(awake_theta~=0));
awake_theta = log2(awake_theta);

sleep = [INTER_T1_rate_events INTER_T2_rate_events];
sleep(sleep==0) = min(sleep(sleep~=0));
% sleep(sleep==0) = 1;
sleep = log2(sleep);


arrayfun(@(x) scatter(awake_theta(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(awake_theta))

mdl = fitlm(awake_theta',sleep');
[pval,F_stat,~] = coefTest(mdl);
awake_theta_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_theta) max(awake_theta)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Number of theta sequence (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Number of theta sequence (RUN1)(%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19)],'RUN 1 Track 1','RUN 1 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_theta_R2),'Units','Normalized','FontName','Arial');
axis square


awake_theta_RUN1_R2_boot = [];
parfor n = 1:1000
    %         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
    mdl = fitlm(awake_theta_RUN1_boot(:,n)',sleep_POST1_boot(:,n)');
    [pval,awake_theta_F_stat(n),~] = coefTest(mdl);
    awake_theta_RUN1_R2_boot(n) = mdl.Rsquared.Adjusted;
end


% Second exposure
new_cls = [repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];

nexttile
hold on
awake_theta = [total_num_thetaseq(:,3)' total_num_thetaseq(:,4)'];
awake_theta(awake_theta==0) = min(awake_theta(awake_theta~=0));
awake_theta = log2(awake_theta);

sleep = [FINAL_RT1_rate_events FINAL_RT2_rate_events];
sleep(sleep==0) = min(sleep(sleep~=0));
% sleep(sleep==0) = 1;
sleep = log2(sleep);

arrayfun(@(x) scatter(awake_theta(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(awake_theta))

mdl = fitlm(awake_theta',sleep');
[pval,F_stat,~] = coefTest(mdl);
awake_theta_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_theta) max(awake_theta)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Number of theta sequence (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Number of theta sequence (RUN2)(%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19)],'RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_theta_R2),'Units','Normalized','FontName','Arial');
axis square

awake_theta_RUN2_R2_boot = [];
parfor n = 1:1000
    %         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
    mdl = fitlm(awake_theta_RUN2_boot(:,n)',sleep_POST2_boot(:,n)');
    [pval,awake_theta_F_stat(n),~] = coefTest(mdl);
    awake_theta_RUN2_R2_boot(n) = mdl.Rsquared.Adjusted;
end


%% Theta sequence vs sleep replay (between exposures prediction)')

% First exposure
new_cls_RUN1 = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1)];
new_cls_RUN2 = [repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
awake_theta_RUN1 = [total_num_thetaseq(:,1)' total_num_thetaseq(:,2)'];
awake_theta_RUN1(awake_theta_RUN1==0) = min(awake_theta_RUN1(awake_theta_RUN1~=0));
awake_theta_RUN1 = log2(awake_theta_RUN1);

awake_theta_RUN2 = [total_num_thetaseq(:,3)' total_num_thetaseq(:,4)'];
awake_theta_RUN2(awake_theta_RUN2==0) = min(awake_theta_RUN2(awake_theta_RUN2~=0));
awake_theta_RUN2 = log2(awake_theta_RUN2);

sleep_POST1 = [INTER_T1_rate_events INTER_T2_rate_events];
sleep_POST1(sleep_POST1==0) = min(sleep_POST1(sleep_POST1~=0));
% sleep(sleep==0) = 1;
sleep_POST1 = log2(sleep_POST1);

sleep_POST2 = [FINAL_RT1_rate_events FINAL_RT2_rate_events];
sleep_POST2(sleep_POST2==0) = min(sleep_POST2(sleep_POST2~=0));
% sleep(sleep==0) = 1;
sleep_POST2 = log2(sleep_POST2);

% 
% awake_theta_RUN1_boot = [];
% awake_theta_RUN2_boot = [];
% sleep_POST1_boot = [];
% sleep_POST2_boot = [];
% parfor n = 1:1000
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%     seed1 = randi(s1,[1 size(total_num_thetaseq,1)],1,size(total_num_thetaseq,1));
%     seed2 = randi(s2,[1 size(total_num_thetaseq,1)],1,size(total_num_thetaseq,1));
%     seed3 = randi(s3,[1 size(total_num_thetaseq,1)],1,size(total_num_thetaseq,1));
%     seed4 = randi(s4,[1 size(total_num_thetaseq,1)],1,size(total_num_thetaseq,1));
%     
%     tempt = [total_num_thetaseq(seed1,1)'...
%         total_num_thetaseq(seed2,2)'];
%     tempt(tempt==0) = min(tempt(tempt~=0));
%     awake_theta_RUN1_boot(:,n) = log2(tempt);
%     
%     tempt = [total_num_thetaseq(seed3,3)'...
%         total_num_thetaseq(seed4,4)'];
%     tempt(tempt==0) = min(tempt(tempt~=0));
%     awake_theta_RUN2_boot(:,n) = log2(tempt);
%     
%     
%     tempt = [INTER_T1_rate_events(seed1)...
%         INTER_T2_rate_events(seed2)];
%     tempt(tempt==0) = min(tempt(tempt~=0));
%     sleep_POST1_boot(:,n) = log2(tempt);
%     
%     tempt =   [FINAL_RT1_rate_events(seed3)...
%         FINAL_RT2_rate_events(seed4)];
%     tempt(tempt==0) = min(tempt(tempt~=0));
%     sleep_POST2_boot(:,n) = log2(tempt);
%     
% end


nexttile
hold on
arrayfun(@(x) scatter(awake_theta_RUN1(x),sleep_POST1(x),86,new_cls_RUN1(x,:),'filled','o'),1:length(awake_theta_RUN1))

mdl = fitlm(awake_theta_RUN2',sleep_POST2');
[pval,F_stat,~] = coefTest(mdl);
% awake_theta_R2 = mdl.Rsquared.Adjusted;
x =awake_theta_RUN1;
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

SSE =sum((sleep_POST1-y_est).^2);
SST =sum((sleep_POST1-mean(sleep_POST1)).^2);
awake_theta_R2   = 1 - (SSE/SST);

plot([min(x) max(x)],[min(y_est) max(y_est)],':','Color','k','LineWidth',3)
xlabel('Number of theta sequence (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Number of theta sequence (RUN1 predicted by RUN2)(%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19)],'RUN 1 Track 1','RUN 1 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('R2 = %.3f',awake_theta_R2),'Units','Normalized','FontName','Arial');
axis square
% 
% awake_theta_R2_boot = [];
% parfor n = 1:1000
%     mdl = fitlm(awake_theta_RUN2_boot(:,n)',sleep_POST2_boot(:,n)');
%     [pval,F_stat,~] = coefTest(mdl);
%     % awake_theta_R2 = mdl.Rsquared.Adjusted;
%     x =awake_theta_RUN1_boot(:,n)';
%     b = mdl.Coefficients.Estimate';
%     y_est = polyval(fliplr(b),x);
%     
%     SSE =sum((sleep_POST1_boot(:,n)-y_est').^2);
%     SST =sum((sleep_POST1_boot(:,n)-mean(sleep_POST1_boot(:,n))).^2);
%     awake_theta_R2_boot(1,n)   = 1 - (SSE/SST);
% end


% Second exposure
nexttile
hold on
arrayfun(@(x) scatter(awake_theta_RUN2(x),sleep_POST2(x),86,new_cls_RUN2(x,:),'filled','o'),1:length(awake_theta_RUN2))

mdl = fitlm(awake_theta_RUN1',sleep_POST1');
[pval,F_stat,~] = coefTest(mdl);
% awake_theta_R2 = mdl.Rsquared.Adjusted;
x =awake_theta_RUN2;
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);

SSE =sum((sleep_POST2-y_est).^2);
SST =sum((sleep_POST2-mean(sleep_POST2)).^2);
awake_theta_R2   = 1 - (SSE/SST);

plot([min(x) max(x)],[min(y_est) max(y_est)],':','Color','k','LineWidth',3)
xlabel('Number of theta sequence (log2)')
ylabel('Rate of POST replay (log2)')
% set(gca,'FontSize',14)
title(sprintf('Number of theta sequence (RUN2 predicted by RUN1)(%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19)],'RUN 1 Track 1','RUN 1 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('R2 = %.3f',awake_theta_R2),'Units','Normalized','FontName','Arial');
axis square
% 
% parfor n = 1:1000
%     mdl = fitlm(awake_theta_RUN1_boot(:,n)',sleep_POST1_boot(:,n)');
%     [pval,F_stat,~] = coefTest(mdl);
%     % awake_theta_R2 = mdl.Rsquared.Adjusted;
%     x =awake_theta_RUN2_boot(:,n)';
%     b = mdl.Coefficients.Estimate';
%     y_est = polyval(fliplr(b),x);
%     
%     SSE =sum((sleep_POST2_boot(:,n)-y_est').^2);
%     SST =sum((sleep_POST2_boot(:,n)-mean(sleep_POST2_boot(:,n))).^2);
%     awake_theta_R2_boot(2,n)   = 1 - (SSE/SST);
% end
% 

% 
% 
% nexttile
% clear b
% x = [mean(awake_theta_R2_boot(1,:)) mean(awake_theta_R2_boot(2,:))]
% x_CI = [prctile(awake_theta_R2_boot(1,:),[2.5 97.5]); prctile(awake_theta_R2_boot(2,:),[2.5 97.5])]
% 
% x_location = [1 1.5 2.5 3 4 4.5];
% x_condition = {'RUN1 predicted by RUN2','RUN2 predicted by RUN1'}
% 
% col = [repmat(PP1.T2(5,:),2,1)];
% alpha = [0.3 0.6];
% 
% for k = 1:2
%     hold on
%     b(k) = bar(x_location(k),x(k),0.3,'FaceAlpha',alpha(k))
%     b(k).FaceColor  = col(k,:);
%     %     b(k).ShowBaseLine = 'off';
%     e(k) = errorbar(x_location(k),x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
%     e(k).Color = col(k,:);
% end
% xticks(x_location)
% xticklabels(x_condition)
% ylabel('R2')
% box off
% ylim([-0.05 1])
% title(sprintf('R2 Theta sequence predicted by another exposure(%s)',rest_option));
% 


nexttile
clear b
x = [mean(awake_theta_RUN1_R2_boot) mean(awake_theta_RUN2_R2_boot)];
x_CI = [prctile(awake_theta_RUN1_R2_boot,[2.5 97.5]); prctile(awake_theta_RUN2_R2_boot,[2.5 97.5])];

for k = 1:2
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2])
xticklabels({'RUN1 theta sequence','RUN2 theta sequence'})
ylabel('R2')
title(sprintf('R2 of awake theta sequence (RUN1 and RUN2)(%s)',rest_option));



%% Track awake replay rate vs PV between exposures
% load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\population_vector_data_excl.mat')

% protocol(1).T3(1).Rat_LOCAL_replay_rate;

% For each protocol, T1 vs RT1 is 1st coloumn nd T2 vs RT2 is 2nd coloumn
n = 1;
for p = 1:length(popvec)
    for session = 1:length(popvec(p).session)
        T1_popvec(n) = nanmean(popvec(p).session(session).population_vector(:,1));
        T2_popvec(n) = nanmean(popvec(p).session(session).population_vector(:,2));
        %         T1_sec_popvec(n) = nanmean(popvec(p).session(session).section_population_vector(:,1));
        %         T2_sec_popvec(n) = nanmean(popvec(p).session(session).section_population_vector(:,2));
        n = n + 1;
    end
end

pv_corr = [T1_popvec T2_popvec];
awake = [awake_rate_replay_RT1 awake_rate_replay_RT2];
RUN1_x = zeros(1,38);
RUN1_y = [awake_rate_replay_T1 awake_rate_replay_T2];


nfig = figure('Color','w','Name','PV between exposures vs awake replay')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

nexttile
hold on
% sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
% new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
new_cls = [repmat([PP.RUN2T1],19,1);repmat([PP.RUN2T2],19,1)];
arrayfun(@(x) scatter(pv_corr(x),awake(x),86,new_cls(x,:),'filled','o'),1:length(awake))
hold on
new_cls = [repmat([PP.RUN1T1],19,1);repmat([PP.RUN1T2],19,1)];
arrayfun(@(x) scatter(RUN1_x(x),RUN1_y(x),30,new_cls(x,:),'filled','o'),1:length(RUN1_x))

mdl = fitlm(pv_corr',awake');
[pval,~,~] = coefTest(mdl);
x =[min(pv_corr) max(pv_corr)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlim([0 1])
xlabel('PV correlation between exposures')
ylabel('RUN awake replay rate')
% set(gca,'FontSize',14)
title(sprintf('PV between exposures vs awake replay(%s)',rest_option));
text(gca,0.02,0.15,sprintf('p = %.2d & R2 = %.3f',pval,mdl.Rsquared.Adjusted),'Units','Normalized','FontSize',12,'FontName','Arial');
f=get(gca,'Children');
legend([f(end),f(end-19)],'Track 1','Track 2','Location','northeast') %because f(1) and f(2) are lines
nexttile
nexttile

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
track_difference_cell_RUN1 = [];
track_difference_cell_RUN2 = [];
track_difference_cell_POST1 = [];
track_difference_cell_POST2 = [];
time_chunk = time_chunk_size;%1800 = 30 mins and 3600 = 60 mins

for s = 1 : num_sess
    cd(folders{s})
    load([folders{s},'\Bayesian controls\Only first exposure\significant_replay_events_wcorr.mat']);
    load([folders{s},'\Bayesian controls\Only first exposure\extracted_place_fields_BAYESIAN.mat']);
    % Only use cells that have place fields on both tracks
    common_good_cells = intersect(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
    track_replay_events = track_replay_events_F.track_replay_events;
    
    % First exposure
    for track = 1:2
        
        % POST1
        cell_id = [];
        
        % For each event find the cells that are active
        for event = find(track_replay_events(s).(sprintf('T%i',track)).(sprintf('INTER_post_%s_cumulative_times',rest_option)) <=time_chunk)
            event_id = track_replay_events(s).(sprintf('T%i',track)).(sprintf('INTER_post_%s_index',rest_option))(event);
            cell_id = [unique(significant_replay_events.track(track).spikes{event_id}(:,1))' cell_id];
        end
        
        % Only include common good cells
        common_good_cell_id = cell_id(ismember(cell_id,common_good_cells));
        
        active_cell_id = 1:1:max(common_good_cells);
        [event_counts,ss] = histcounts(common_good_cell_id,[0.5:1:max(common_good_cells)+0.5]);
        
        cell_replay_POST1{s}{track}(1,:) = active_cell_id(common_good_cells);
        cell_replay_POST1{s}{track}(2,:) = event_counts(common_good_cells)/time_chunk;
        
        % RUN1
        cell_id = [];
        % For each event find the cells that are active
        for event = 1:length(track_replay_events(s).(sprintf('T%i',track)).(sprintf('T%i_index',track)))
            event_id = track_replay_events(s).(sprintf('T%i',track)).(sprintf('T%i_index',track))(event);
            cell_id = [unique(significant_replay_events.track(track).spikes{event_id}(:,1))' cell_id];
        end
        % Only include common good cells
        common_good_cell_id = cell_id(ismember(cell_id,common_good_cells));
        
        active_cell_id = 1:1:max(common_good_cells);
        [event_counts,~] = histcounts(common_good_cell_id,[0.5:1:max(common_good_cells)+0.5]);
        
        cell_replay_RUN1{s}{track}(1,:) = active_cell_id(common_good_cells);
        cell_replay_RUN1{s}{track}(2,:) = event_counts(common_good_cells);
        
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
        cell_id = [];
        % For each event find the cells that are active
        for event = find(track_replay_events(s).(sprintf('T%i',track)).(sprintf('FINAL_post_%s_cumulative_times',rest_option)) <=time_chunk)
            event_id = track_replay_events(s).(sprintf('T%i',track)).(sprintf('FINAL_post_%s_index',rest_option))(event);
            cell_id = [unique(significant_replay_events.track(track).spikes{event_id}(:,1))' cell_id];
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


%
% nfig = figure('Color','w','Name','Awake replay number vs Replay participation track difference')
% nfig.Position = [940 100 920 900];
% orient(nfig,'landscape')
% for s = 1 : num_sess
%     nexttile
%     hold on
%     % sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
%     % new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     awake = [track_difference_cell_RUN1{s}(2,:) track_difference_cell_RUN2{s}(2,:)]; % awake number difference
%     sleep = [track_difference_cell_POST1{s}(2,:) track_difference_cell_POST2{s}(2,:)]; % sleep rate difference
%     new_cls = cls(s,:);
%     arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
%     hold on
%
%     mdl = fitlm(awake',sleep');
%     [pval,~,~] = coefTest(mdl);
%     x =[min(awake) max(awake)];
%     b = mdl.Coefficients.Estimate';
%     y_est = polyval(fliplr(b),x);
%
%     xlim([-150 150])
%
%     if pval <= 0.05
%         plot(x,y_est,'r:')
%         %     xlim([-100 100])
%
%         title(sprintf('Session %i',s),'Color','red')
%         %     text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%         text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
%     else
%         plot(x,y_est,'k:')
%         %     xlim([-100 100])
%         title(sprintf('Session %i',s))
%         %     text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%         text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
%     end
% end
% xlabel('Awake replay track difference (number)')
% ylabel('POST replay track difference (rate)')
% sgtitle(sprintf('Awake replay number vs Replay participation track difference(%s)',rest_option));


nfig = figure('Color','w','Name','Awake replay vs Replay participation track difference (First exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    hold on
    sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
    awake = [track_difference_cell_RUN1{s}(2,:)]; % awake number difference
    sleep = [track_difference_cell_POST1{s}(2,:)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-0.01 0.01])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
        xlim([-30 120])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
        xlim([-30 120])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
xlabel('Awake replay track difference (number)')
ylabel('POST replay track difference (rate)')
sgtitle(sprintf('Awake replay vs Replay participation track difference first exposure(%s)',rest_option));


nfig = figure('Color','w','Name','Awake replay vs Replay participation track difference (Re-exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    hold on
    sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
    awake = [track_difference_cell_RUN2{s}(2,:)]; % awake number difference
    sleep = [track_difference_cell_POST2{s}(2,:)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-0.01 0.01])
    
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
        xlim([-50 50])
        
        title(sprintf('Session %i',s),'Color','red')
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
        xlim([-50 50])
        title(sprintf('Session %i',s))
        %         text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
    xline(0,'--')
    yline(0,'--')
end
xlabel('Awake replay track difference (number)')
ylabel('POST replay track difference (rate)')

sgtitle(sprintf('Awake replay vs Replay participation track difference re-exposure(%s)',rest_option));



%% Looking at place cell participation in replay (RATE)
% place cells with place fields on both tracks and asked whether the
% difference in the number of awake replay events a given cell participated
% in predict the observed difference in sleep replay rates for that cell

num_sess = length(track_replay_events_F.track_replay_events);
folders = data_folders_excl;
cell_replay_rate_RUN1 = [];
cell_replay_rate_RUN2 = [];
track_difference_rate_cell_RUN1 = [];
track_difference_rate_cell_RUN2 = [];
time_chunk = time_chunk_size;%1800 = 30 mins and 3600 = 60 mins

for s = 1 : num_sess
    cd(folders{s})
    load([folders{s},'\Bayesian controls\Only first exposure\significant_replay_events_wcorr.mat']);
    load([folders{s},'\Bayesian controls\Only first exposure\extracted_place_fields_BAYESIAN.mat']);
    % Only use cells that have place fields on both tracks
    common_good_cells = intersect(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
    track_replay_events = track_replay_events_F.track_replay_events;
    
    if s < 5
        old_s_index = s;
    else
        old_s_index = s + 1;
    end
    
    % First exposure
    for track = 1:2
        % RUN1
        cell_id = [];
        % For each event find the cells that are active
        for event = 1:length(track_replay_events(s).(sprintf('T%i',track)).(sprintf('T%i_index',track)))
            event_id = track_replay_events(s).(sprintf('T%i',track)).(sprintf('T%i_index',track))(event);
            cell_id = [unique(significant_replay_events.track(track).spikes{event_id}(:,1))' cell_id];
        end
        % Only include common good cells
        common_good_cell_id = cell_id(ismember(cell_id,common_good_cells));
        
        active_cell_id = 1:1:max(common_good_cells);
        [event_counts,~] = histcounts(common_good_cell_id,[0.5:1:max(common_good_cells)+0.5]);
        
        cell_replay_rate_RUN1{s}{track}(1,:) = active_cell_id(common_good_cells);
        cell_replay_rate_RUN1{s}{track}(2,:) = event_counts(common_good_cells)/time_immobile(old_s_index,track);
        
    end
    
    track_difference_rate_cell_RUN1{s}(1,:) = cell_replay_rate_RUN1{s}{1}(1,:);
    track_difference_rate_cell_RUN1{s}(2,:) = (cell_replay_rate_RUN1{s}{1}(2,:) - cell_replay_rate_RUN1{s}{2}(2,:));
    
    %     load([folders{s},'\Bayesian controls\Only re-exposure\extracted_place_fields_BAYESIAN.mat'])
    load([folders{s},'\Bayesian controls\Only re-exposure\significant_replay_events_wcorr.mat']);
    load([folders{s},'\Bayesian controls\Only re-exposure\extracted_place_fields_BAYESIAN.mat']);
    % Only use cells that have place fields on both tracks
    common_good_cells = intersect(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
    track_replay_events = track_replay_events_R.track_replay_events;
    
    % Re-exposure
    for track = 1:2
        % RUN2
        cell_id = [];
        % For each event find the cells that are active
        for event = 1:length(track_replay_events(s).(sprintf('T%i',track)).(sprintf('T%i_index',track+2)))
            event_id = track_replay_events(s).(sprintf('T%i',track)).(sprintf('T%i_index',track+2))(event);
            cell_id = [unique(significant_replay_events.track(track).spikes{event_id}(:,1))' cell_id];
        end
        % Only include common good cells
        common_good_cell_id = cell_id(ismember(cell_id,common_good_cells));
        
        active_cell_id = 1:1:max(common_good_cells);
        [event_counts,ss] = histcounts(common_good_cell_id,[0.5:1:max(common_good_cells)+0.5]);
        
        cell_replay_rate_RUN2{s}{track}(1,:) = active_cell_id(common_good_cells);
        cell_replay_rate_RUN2{s}{track}(2,:) = event_counts(common_good_cells)/time_immobile(old_s_index,track+2);
    end
    
    track_difference_rate_cell_RUN2{s}(1,:) = cell_replay_rate_RUN2{s}{1}(1,:);
    track_difference_rate_cell_RUN2{s}(2,:) = (cell_replay_rate_RUN2{s}{1}(2,:) - cell_replay_rate_RUN2{s}{2}(2,:));
end



%
% nfig = figure('Color','w','Name','Awake replay number vs Replay participation track difference')
% nfig.Position = [940 100 920 900];
% orient(nfig,'landscape')
% for s = 1 : num_sess
%     nexttile
%     hold on
%     % sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
%     % new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     awake = [track_difference_rate_cell_RUN1{s}(2,:) track_difference_rate_cell_RUN2{s}(2,:)]; % awake number difference
%     sleep = [track_difference_cell_POST1{s}(2,:) track_difference_cell_POST2{s}(2,:)]; % sleep rate difference
%     new_cls = cls(s,:);
%     arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
%     hold on
%
%     mdl = fitlm(awake',sleep');
%     [pval,~,~] = coefTest(mdl);
%     x =[min(awake) max(awake)];
%     b = mdl.Coefficients.Estimate';
%     y_est = polyval(fliplr(b),x);
%
%     %     set(gca,'FontSize',14)
%     if pval <= 0.05
%         plot(x,y_est,'r:')
%         %     xlim([-100 100])
%
%         title(sprintf('Session %i',s),'Color','red')
%         %     text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%         text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
%     else
%         plot(x,y_est,'k:')
%         %     xlim([-100 100])
%         title(sprintf('Session %i',s))
%         %     text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
%         text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
%     end
% end
% xlabel('Awake replay track difference (rate)')
% ylabel('POST replay track difference (rate)')
% sgtitle(sprintf('Awake replay rate vs Replay participation track difference(%s)',rest_option));


nfig = figure('Color','w','Name','Awake replay vs Replay participation track rate difference (First exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')
for s = 1 : num_sess
    nexttile
    hold on
    % sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    % new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
    awake = [track_difference_rate_cell_RUN1{s}(2,:) track_difference_rate_cell_RUN2{s}(2,:)]; % awake number difference
    sleep = [track_difference_cell_POST1{s}(2,:) track_difference_cell_POST2{s}(2,:)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-0.01 0.01])
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
        %     xlim([-100 100])
        
        title(sprintf('Session %i',s),'Color','red')
        %     text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
        %     xlim([-100 100])
        title(sprintf('Session %i',s))
        %     text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
end
xlabel('Awake replay track difference (rate)')
ylabel('POST replay track difference (rate)')
sgtitle(sprintf('Awake replay rate vs Replay participation track difference (First exposure)(%s)',rest_option));


nfig = figure('Color','w','Name','Awake replay vs Replay participation track rate difference (Re-exposure)');
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')

for s = 1 : num_sess
    nexttile
    hold on
    % sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    % new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
    awake = [track_difference_rate_cell_RUN2{s}(2,:)]; % awake number difference
    sleep = [track_difference_cell_POST2{s}(2,:)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    ylim([-0.01 0.01])
    
    %     set(gca,'FontSize',14)
    if pval <= 0.05
        plot(x,y_est,'r:')
        %     xlim([-100 100])
        
        title(sprintf('Session %i',s),'Color','red')
        %     text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','red');
    else
        plot(x,y_est,'k:')
        %     xlim([-100 100])
        title(sprintf('Session %i',s))
        %     text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
        text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial','Color','black');
    end
end
xlabel('Awake replay track difference (rate)')
ylabel('POST replay track difference (rate)')
sgtitle(sprintf('Awake replay vs Replay participation track rate difference re-exposure(%s)',rest_option));

%
% %% Multiple linear regression (replay vs theta sequence)
% % awake_number = [];
% % awake_rate = [];
% % awake_theta = [];
% % sleep = [];
% for n = 1:1000
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%
%     tempt = [datasample(s1,awake_rate_replay_T1,length(awake_rate_replay_T1))...
%         datasample(s2,awake_rate_replay_T2,length(awake_rate_replay_T2))...
%         datasample(s3,awake_rate_replay_RT1,length(awake_rate_replay_RT1))...
%         datasample(s4,awake_rate_replay_RT2,length(awake_rate_replay_RT2))]';
%     tempt(tempt==0) = min(tempt(tempt~=0));
%     awake_rate_boot(:,n) = zscore(log2(tempt));
%
%
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%
%     tempt = [datasample(s1,awake_local_replay_T1,length(awake_local_replay_T1))...
%         datasample(s2,awake_local_replay_T2,length(awake_local_replay_T2))...
%         datasample(s3,awake_local_replay_RT1,length(awake_local_replay_RT1))...
%         datasample(s4,awake_local_replay_RT2,length(awake_local_replay_RT2))]';
%
%     tempt(tempt==0) = min(tempt(tempt~=0));
%     awake_number_boot(:,n) = zscore(log2(tempt));
%
%
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%
%     tempt = [datasample(s1,total_num_thetaseq(:,1)',length(total_num_thetaseq(:,1)'))...
%         datasample(s2,total_num_thetaseq(:,2)',length(total_num_thetaseq(:,2)'))...
%         datasample(s3,total_num_thetaseq(:,3)',length(total_num_thetaseq(:,3)'))...
%         datasample(s4,total_num_thetaseq(:,4)',length(total_num_thetaseq(:,4)'))]';
%
%     tempt(tempt==0) = min(tempt(tempt~=0));
%     awake_theta_boot(:,n) = zscore(log2(tempt));
%
%
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%
%     tempt = [datasample(s1,INTER_T1_rate_events,length(INTER_T1_rate_events))...
%         datasample(s2,INTER_T2_rate_events,length(INTER_T2_rate_events))...
%         datasample(s3,FINAL_RT1_rate_events,length(FINAL_RT1_rate_events))...
%         datasample(s4,FINAL_RT2_rate_events,length(FINAL_RT2_rate_events))]';
%
%     tempt(tempt==0) = min(tempt(tempt~=0));
%     sleep_boot(:,n) = zscore(log2(tempt));
%
% end
%
% new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
%
% % Multiple linear (all three)
% parfor n = 1:1000
%     awake = [awake_rate_boot(:,n), awake_number_boot(:,n), awake_theta_boot(:,n)];
%     mdl = fitlm(awake,sleep_boot(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     awake_R2(n) = mdl.Rsquared.Adjusted;
%     awake_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% % Remove theta sequence number
% parfor n = 1:1000
%     awake = [awake_rate_boot(:,n), awake_number_boot(:,n)];
%     mdl = fitlm(awake,sleep_boot(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     theta_removed_R2(n) = mdl.Rsquared.Adjusted;
%     theta_removed_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% % Remove awake replay rate
% for n = 1:1000
%     awake = [awake_theta_boot(:,n), awake_number_boot(:,n)];
%     mdl = fitlm(awake,sleep_boot(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     awake_rate_removed_R2(n) = mdl.Rsquared.Adjusted;
%     awake_rate_removed_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% % Remove awake replay number
% parfor n = 1:1000
%     awake = [awake_theta_boot(:,n), awake_rate_boot(:,n)];
%     mdl = fitlm(awake,sleep_boot(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     awake_number_removed_R2(n) = mdl.Rsquared.Adjusted;
%     awake_number_removed_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% clear b
% nfig = figure('Color','w','Name','Multiple linear regression theta vs awake replay')
% nfig.Position = [940 100 920 900];
% orient(nfig,'landscape')
%
% nexttile
% hold on
% x = [mean(awake_R2) mean(theta_removed_R2) mean(awake_rate_removed_R2) mean(awake_number_removed_R2)];
% x_CI = [prctile(awake_R2,[2.5 97.5]); prctile(theta_removed_R2,[2.5 97.5]); prctile(awake_rate_removed_R2,[2.5 97.5]); prctile(awake_number_removed_R2,[2.5 97.5])];
%
% for k = 1:4
%     hold on
%     b(k) = bar(k,x(k),'FaceAlpha',0.5)
%     b(k).FaceColor  = PP1.T2(k,:);
%     e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
%     e(k).Color = PP1.T2(k,:);
% end
% xticks([1 2 3 4])
% xticklabels({'All three','Theta number removed','Awake replay rate removed','Awake replay number removed'})
% ylim([0 1])
% ylabel('The amount of variance explained (R2)')
%
%
% %% Multiple linear regression just theta number and replay
% new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
%
% clear b
%
% hold on
% % Multiple linear (theta vs replay rate)
% awake_rate_theta_R2 = awake_number_removed_R2;
% awake_number_theta_R2 = awake_rate_removed_R2;
% awake_number_rate_R2 = theta_removed_R2;
% awake_rate_R2 = [];
% awake_theta_R2 = [];
% awake_number_R2 = [];
%
% % awake replay rate
% for n = 1:1000
%     awake = [awake_rate_boot(:,n)];
%     mdl = fitlm(awake,sleep_boot(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     awake_rate_R2(n) = mdl.Rsquared.Adjusted;
%     awake_rate_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% % awake theta number
% for n = 1:1000
%     awake = [awake_theta_boot(:,n)];
%     mdl = fitlm(awake,sleep_boot(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     awake_theta_R2(n) = mdl.Rsquared.Adjusted;
%     awake_theta_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% % awake replay number
% for n = 1:1000
%     awake = [awake_number_boot(:,n)];
%     mdl = fitlm(awake,sleep_boot(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     awake_number_R2(n) = mdl.Rsquared.Adjusted;
%     awake_number_b(n,:) = mdl.Coefficients.Estimate';
% end
%
%
% nexttile
% hold on
% x = [mean(awake_number_rate_R2) mean(awake_rate_R2) mean(awake_number_R2)];
% x_CI = [prctile(awake_number_rate_R2,[2.5 97.5]); prctile(awake_rate_R2,[2.5 97.5]); prctile(awake_number_R2,[2.5 97.5])];
%
% for k = 1:3
%     hold on
%     b(k) = bar(k,x(k),'FaceAlpha',0.5)
%     b(k).FaceColor  = PP1.T2(k,:);
%     e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
%     e(k).Color = PP1.T2(k,:);
% end
% xticks([1 2 3 4])
% xticklabels({'Replay Rate + Number','Awake replay number removed','Awake replay rate removed'})
% ylim([0 1])
% ylabel('The amount of variance explained (R2)')
%
% nexttile
% hold on
% x = [mean(awake_rate_theta_R2) mean(awake_theta_R2) mean(awake_rate_R2)];
% x_CI = [prctile(awake_rate_theta_R2,[2.5 97.5]); prctile(awake_theta_R2,[2.5 97.5]); prctile(awake_rate_R2,[2.5 97.5])];
%
% for k = 1:3
%     hold on
%     b(k) = bar(k,x(k),'FaceAlpha',0.5)
%     b(k).FaceColor  = PP1.T2(k,:);
%     e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
%     e(k).Color = PP1.T2(k,:);
% end
% xticks([1 2 3 4])
% xticklabels({'Replay + Theta','Awake replay rate removed','Theta number removed'})
% ylim([0 1])
% ylabel('The amount of variance explained (R2)')
%
%
% nexttile
% hold on
% x = [mean(awake_number_theta_R2) mean(awake_theta_R2) mean(awake_number_R2)];
% x_CI = [prctile(awake_number_theta_R2,[2.5 97.5]); prctile(awake_theta_R2,[2.5 97.5]); prctile(awake_number_R2,[2.5 97.5])];
%
% for k = 1:3
%     hold on
%     b(k) = bar(k,x(k),'FaceAlpha',0.5)
%     b(k).FaceColor  = PP1.T2(k,:);
%     e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
%     e(k).Color = PP1.T2(k,:);
% end
% xticks([1 2 3 4])
% xticklabels({'Replay + Theta','Awake replay number removed','Theta number removed'})
% ylim([0 1])
% ylabel('The amount of variance explained (R2)')
%
%
% %% Multiple linear regression (SWR vs theta cycles)
% awake_number = [];
% awake_rate = [];
% awake_theta = [];
% sleep = [];
% for n = 1:1000
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%
%     awake_rate(:,n) = zscore([datasample(s1,SWR_event_rate(:,1)',length(SWR_event_rate(:,1)'))...
%         datasample(s2,SWR_event_rate(:,2)',length(SWR_event_rate(:,2)'))...
%         datasample(s3,SWR_event_rate(:,3)',length(SWR_event_rate(:,3)'))...
%         datasample(s4,SWR_event_rate(:,4)',length(SWR_event_rate(:,4)'))]');
%
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%
%     awake_number(:,n) = zscore([datasample(s1,SWR_event_number(:,1)',length(SWR_event_number(:,1)'))...
%         datasample(s2,SWR_event_number(:,2)',length(SWR_event_number(:,2)'))...
%         datasample(s3,SWR_event_number(:,3)',length(SWR_event_number(:,3)'))...
%         datasample(s4,SWR_event_number(:,4)',length(SWR_event_number(:,4)'))]');
%
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%
%     awake_theta(:,n) = zscore([datasample(s1,total_num_thetaseq(:,1)',length(total_num_thetaseq(:,1)'))...
%         datasample(s2,total_num_thetaseq(:,2)',length(total_num_thetaseq(:,2)'))...
%         datasample(s3,total_num_thetaseq(:,3)',length(total_num_thetaseq(:,3)'))...
%         datasample(s4,total_num_thetaseq(:,4)',length(total_num_thetaseq(:,4)'))]');
%
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%
%     sleep(:,n) = zscore([datasample(s1,INTER_T1_rate_events,length(INTER_T1_rate_events))...
%         datasample(s2,INTER_T2_rate_events,length(INTER_T2_rate_events))...
%         datasample(s3,FINAL_RT1_rate_events,length(FINAL_RT1_rate_events))...
%         datasample(s4,FINAL_RT2_rate_events,length(FINAL_RT2_rate_events))]');
% end
%
% new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
%
% % Multiple linear (all three)
% parfor n = 1:1000
%     awake = [awake_rate(:,n), awake_number(:,n), awake_theta(:,n)];
%     mdl = fitlm(awake,sleep(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     awake_R2(n) = mdl.Rsquared.Adjusted;
%     awake_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% % Remove theta cycles number
% parfor n = 1:1000
%     awake = [awake_rate(:,n), awake_number(:,n)];
%     mdl = fitlm(awake,sleep(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     theta_removed_R2(n) = mdl.Rsquared.Adjusted;
%     theta_removed_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% % Remove awake SWR rate
% for n = 1:1000
%     awake = [awake_theta(:,n), awake_number(:,n)];
%     mdl = fitlm(awake,sleep(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     awake_rate_removed_R2(n) = mdl.Rsquared.Adjusted;
%     awake_rate_removed_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% % Remove awake SWR number
% parfor n = 1:1000
%     awake = [awake_theta(:,n), awake_rate(:,n)];
%     mdl = fitlm(awake,sleep(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     awake_number_removed_R2(n) = mdl.Rsquared.Adjusted;
%     awake_number_removed_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% clear b
% nfig = figure('Color','w','Name','Multiple linear regression theta cycle vs SWR')
% nfig.Position = [940 100 920 900];
% orient(nfig,'landscape')
%
% nexttile
% hold on
% x = [mean(awake_R2) mean(theta_removed_R2) mean(awake_rate_removed_R2) mean(awake_number_removed_R2)];
% x_CI = [prctile(awake_R2,[2.5 97.5]); prctile(theta_removed_R2,[2.5 97.5]); prctile(awake_rate_removed_R2,[2.5 97.5]); prctile(awake_number_removed_R2,[2.5 97.5])];
%
% for k = 1:4
%     hold on
%     b(k) = bar(k,x(k),'FaceAlpha',0.5)
%     b(k).FaceColor  = PP1.T2(k,:);
%     e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
%     e(k).Color = PP1.T2(k,:);
% end
% xticks([1 2 3 4])
% xticklabels({'All three','Theta cycle removed','SWR rate removed','SWR number removed'})
% ylim([0 1])
% ylabel('The amount of variance explained (R2)')
%
%
% %% Multiple linear regression just theta cycles and SWR
% new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
%
% clear b
% % nfig = figure('Color','w')
% % nfig.Position = [940 100 920 900];
%
% % Multiple linear (theta vs replay rate)
% awake_rate_theta_R2 = awake_number_removed_R2;
% awake_number_theta_R2 = awake_rate_removed_R2;
% awake_SWR_R2 = theta_removed_R2;
%
% % awake replay rate
% for n = 1:1000
%     awake = [awake_rate(:,n)];
%     mdl = fitlm(awake,sleep(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     awake_rate_R2(n) = mdl.Rsquared.Adjusted;
%     awake_rate_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% % awake theta number
% for n = 1:1000
%     awake = [awake_theta(:,n)];
%     mdl = fitlm(awake,sleep(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     awake_theta_R2(n) = mdl.Rsquared.Adjusted;
%     awake_theta_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% % awake replay number
% for n = 1:1000
%     awake = [awake_number(:,n)];
%     mdl = fitlm(awake,sleep(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     awake_number_R2(n) = mdl.Rsquared.Adjusted;
%     awake_number_b(n,:) = mdl.Coefficients.Estimate';
% end
%
%
% nexttile
% hold on
% x = [mean(awake_SWR_R2) mean(awake_number_R2) mean(awake_rate_R2)];
% x_CI = [prctile(awake_SWR_R2,[2.5 97.5]); prctile(awake_number_R2,[2.5 97.5]); prctile(awake_rate_R2,[2.5 97.5])];
%
% for k = 1:3
%     hold on
%     b(k) = bar(k,x(k),'FaceAlpha',0.5)
%     b(k).FaceColor  = PP1.T2(k,:);
%     e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
%     e(k).Color = PP1.T2(k,:);
% end
% xticks([1 2 3 4])
% xticklabels({'SWR rate + SWR number','SWR rate removed','SWR number removed'})
% ylim([-0.1 1])
% ylabel('The amount of variance explained (R2)')
%
%
% nexttile
% hold on
% x = [mean(awake_rate_theta_R2) mean(awake_theta_R2) mean(awake_rate_R2)];
% x_CI = [prctile(awake_rate_theta_R2,[2.5 97.5]); prctile(awake_theta_R2,[2.5 97.5]); prctile(awake_rate_R2,[2.5 97.5])];
%
% for k = 1:3
%     hold on
%     b(k) = bar(k,x(k),'FaceAlpha',0.5)
%     b(k).FaceColor  = PP1.T2(k,:);
%     e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
%     e(k).Color = PP1.T2(k,:);
% end
% xticks([1 2 3 4])
% xticklabels({'SWR + Theta','SWR rate removed','Theta number removed'})
% ylim([-0.1 1])
% ylabel('The amount of variance explained (R2)')
%
%
% nexttile
% hold on
% x = [mean(awake_number_theta_R2) mean(awake_theta_R2) mean(awake_number_R2)];
% x_CI = [prctile(awake_number_theta_R2,[2.5 97.5]); prctile(awake_theta_R2,[2.5 97.5]); prctile(awake_number_R2,[2.5 97.5])];
%
% for k = 1:3
%     hold on
%     b(k) = bar(k,x(k),'FaceAlpha',0.5)
%     b(k).FaceColor  = PP1.T2(k,:);
%     e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
%     e(k).Color = PP1.T2(k,:);
% end
% xticks([1 2 3 4])
% xticklabels({'SWR + Theta','SWR number removed','Theta number removed'})
% ylim([0 1])
% ylabel('The amount of variance explained (R2)')
%
%
%
%
% %% Multiple linear regression (Time immobile vs Time mobile)
%
% immobile_time = [];
% mobile_time = [];
% speed = [];
% sleep = [];
% for n = 1:1000
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%
%     immobile_time(:,n) = zscore([datasample(s1,immobility(:,1)',length(immobility(:,1)'))...
%         datasample(s2,immobility(:,2)',length(immobility(:,2)'))...
%         datasample(s3,immobility(:,3)',length(immobility(:,3)'))...
%         datasample(s4,immobility(:,4)',length(immobility(:,4)'))]');
%
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%
%     mobile_time(:,n) = zscore([datasample(s1,mobility(:,1)',length(mobility(:,1)'))...
%         datasample(s2,mobility(:,2)',length(mobility(:,2)'))...
%         datasample(s3,mobility(:,3)',length(mobility(:,3)'))...
%         datasample(s4,mobility(:,4)',length(mobility(:,4)'))]');
%
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%
%     speed(:,n) = zscore([datasample(s1,running_speed(:,1)',length(running_speed(:,1)'))...
%         datasample(s2,running_speed(:,2)',length(running_speed(:,2)'))...
%         datasample(s3,running_speed(:,3)',length(running_speed(:,3)'))...
%         datasample(s4,running_speed(:,4)',length(running_speed(:,4)'))]');
%
%     s1 = RandStream('mcg16807','Seed',n);
%     s2 = RandStream('mcg16807','Seed',1000+n);
%     s3 = RandStream('mcg16807','Seed',2000+n);
%     s4 = RandStream('mcg16807','Seed',3000+n);
%
%     sleep(:,n) = zscore([datasample(s1,INTER_T1_rate_events,length(INTER_T1_rate_events))...
%         datasample(s2,INTER_T2_rate_events,length(INTER_T2_rate_events))...
%         datasample(s3,FINAL_RT1_rate_events,length(FINAL_RT1_rate_events))...
%         datasample(s4,FINAL_RT2_rate_events,length(FINAL_RT2_rate_events))]');
% end
%
% new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
%
% clear b
% nfig = figure('Color','w','Name','Multiple linear regression mobility vs immobility')
% nfig.Position = [940 100 920 900];
% orient(nfig,'landscape')
%
%
% % Mobile + immobile time
% for n = 1:1000
%     awake = [immobile_time(:,n) mobile_time(:,n)];
%     mdl = fitlm(awake,sleep(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     immobile_mobile_R2(n) = mdl.Rsquared.Adjusted;
%     immobile_mobile_R2_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% % immobile removed
% for n = 1:1000
%     awake = [mobile_time(:,n)];
%     mdl = fitlm(awake,sleep(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     immobile_removed_R2(n) = mdl.Rsquared.Adjusted;
%     immobile_removed_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% % immobile removed
% for n = 1:1000
%     awake = [immobile_time(:,n)];
%     mdl = fitlm(awake,sleep(:,n));
%     [pval,F_stat,~] = coefTest(mdl);
%     mobile_removed_R2(n) = mdl.Rsquared.Adjusted;
%     mobile_removed_b(n,:) = mdl.Coefficients.Estimate';
% end
%
% nexttile
% hold on
% x = [mean(immobile_mobile_R2) mean(immobile_removed_R2) mean(mobile_removed_R2)];
% x_CI = [prctile(immobile_mobile_R2,[2.5 97.5]); prctile(immobile_removed_R2,[2.5 97.5]); prctile(mobile_removed_R2,[2.5 97.5])];
%
% for k = 1:11
%     hold on
%     b(k) = bar(k,x(k),'FaceAlpha',0.5)
%     b(k).FaceColor  = PP1.T2(k,:);
%     e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
%     e(k).Color = PP1.T2(k,:);
% end
% xticks([1 2 3 4])
% xticklabels({'Mobility + Immobility','Immobility removed','Mobility removed'})
% ylim([0 1])
% ylabel('The amount of variance explained (R2)')



