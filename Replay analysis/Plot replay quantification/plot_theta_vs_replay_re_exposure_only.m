function plot_theta_vs_replay_re_exposure_only(bayesian_control,rest_option,time_chunk_size,time_window)

% Code for quantifying and plotting the relationship between theta sequence
% and awake replay and sleep replay

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
    
    if strcmp(rest_option,'sleep')
        if time_chunk_size == 1800
            load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only re-exposure\rate_per_second_sleep_replay_30min_excl.mat']); %info of sleep in time bins
            
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


%% Plot POST replay rate per track, all protocols together
% [p,tbl,stats] = kruskalwallis([awake_rate_replay_T1' awake_rate_replay_T2' awake_rate_replay_RT1' awake_rate_replay_RT2'],[],'off')
%
% if p < .05
%     c = multcompare(stats);
% end
%


f11 = figure('Color','w','Name','POST replay rates');
f11.Position = [450 180 1020 720];
f11.Name = [sprintf('POST replay rate(%s)',rest_option)];

nexttile
grp = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
tst=[INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events]';

% xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'corral_style','rand');
xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'overlay_style','sd','corral_style','rand');

yticks([0:0.02:0.06])
xticks([1:4])
xticklabels({'POST1 T1','POST1 T2','POST2 T1','POST2 T2'})
ylabel('Replay rate (events/sec)')
set(gca,'FontSize',14)
ylim([0 0.07])
hold on

tst=[INTER_T1_rate_events; INTER_T2_rate_events; FINAL_RT1_rate_events; FINAL_RT2_rate_events]';

xbe = reshape(xbe,size(tst,1),size(tst,2));
for i = 1:size(tst,1)
    plot(xbe(i,[1 2]),tst(i,[1 2]),'Color',[0,0,0,0.2])
    plot(xbe(i,[3 4]),tst(i,[3 4]),'Color',[0,0,0,0.2])
end

axis square
title(sprintf('POST replay rate for both exposures (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[INTER_T1_rate_events(prot_sess{1}) INTER_T1_rate_events(prot_sess{2})...
    INTER_T1_rate_events(prot_sess{3}) INTER_T1_rate_events(prot_sess{4}) INTER_T1_rate_events(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.02:0.06])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay rate (events/sec)')
set(gca,'FontSize',14)
ylim([0 0.07])
axis square
title(sprintf('POST1 T1 replay (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[INTER_T2_rate_events(prot_sess{1}) INTER_T2_rate_events(prot_sess{2})...
    INTER_T2_rate_events(prot_sess{3}) INTER_T2_rate_events(prot_sess{4}) INTER_T2_rate_events(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.02:0.06])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay rate (events/sec)')
set(gca,'FontSize',14)
ylim([0 0.07])
axis square
title(sprintf('POST1 T2 replay (%s)',rest_option));


nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[FINAL_RT1_rate_events(prot_sess{1}) FINAL_RT1_rate_events(prot_sess{2})...
    FINAL_RT1_rate_events(prot_sess{3}) FINAL_RT1_rate_events(prot_sess{4}) FINAL_RT1_rate_events(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.02:0.06])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay rate (events/sec)')
set(gca,'FontSize',14)
ylim([0 0.07])
axis square
title(sprintf('POST2 T1 replay (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[FINAL_RT2_rate_events(prot_sess{1}) FINAL_RT2_rate_events(prot_sess{2})...
    FINAL_RT2_rate_events(prot_sess{3}) FINAL_RT2_rate_events(prot_sess{4}) FINAL_RT2_rate_events(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.02:0.06])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay rate (events/sec)')
set(gca,'FontSize',14)
ylim([0 0.07])
axis square
title(sprintf('POST2 T2 replay (%s)',rest_option));

%% Plot awake replay rate per track, all protocols together
% [p,tbl,stats] = kruskalwallis([awake_rate_replay_T1' awake_rate_replay_T2' awake_rate_replay_RT1' awake_rate_replay_RT2'],[],'off')
%
% if p < .05
%     c = multcompare(stats);
% end
%


f12 = figure('Color','w','Name','Awake replay rates');
f12.Position = [450 180 1020 720];
f12.Name = [sprintf('Awake replay rate(%s)',rest_option)];

nexttile
grp = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
tst=[awake_rate_replay_T1 awake_rate_replay_T2 awake_rate_replay_RT1 awake_rate_replay_RT2]';

% xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'corral_style','rand');
xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'overlay_style','sd','corral_style','rand');

yticks([0:0.05:0.25])
xticks([1:4])
xticklabels({'RUN1 T1','RUN1 T2','RUN2 T1','RUN2 T2'})
ylabel('Rate of awake replay (events/sec)')
set(gca,'FontSize',14)
ylim([0 0.26])
hold on

tst=[awake_rate_replay_T1; awake_rate_replay_T2; awake_rate_replay_RT1; awake_rate_replay_RT2]';
xbe = reshape(xbe,size(tst,1),size(tst,2));
for i = 1:size(tst,1)
    plot(xbe(i,[1 2]),tst(i,[1 2]),'Color',[0,0,0,0.2])
    plot(xbe(i,[3 4]),tst(i,[3 4]),'Color',[0,0,0,0.2])
end

axis square
title(sprintf('Awake replay rate for both exposures (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[awake_rate_replay_T1(prot_sess{1}) awake_rate_replay_T1(prot_sess{2})...
    awake_rate_replay_T1(prot_sess{3}) awake_rate_replay_T1(prot_sess{4}) awake_rate_replay_T1(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.05:0.25])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Rate of awake replay (events/sec)')
set(gca,'FontSize',14)
ylim([0 0.26])
axis square
title(sprintf('RUN1 T1 awake replay rate (%s)',rest_option));


nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[awake_rate_replay_T2(prot_sess{1}) awake_rate_replay_T2(prot_sess{2})...
    awake_rate_replay_T2(prot_sess{3}) awake_rate_replay_T2(prot_sess{4}) awake_rate_replay_T2(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

ylim([0 0.26])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Rate of awake replay (events/sec)')
set(gca,'FontSize',14)
axis square
title(sprintf('RUN1 T2 awake replay rate (%s)',rest_option));


nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[awake_rate_replay_RT1(prot_sess{1}) awake_rate_replay_RT1(prot_sess{2})...
    awake_rate_replay_RT1(prot_sess{3}) awake_rate_replay_RT1(prot_sess{4}) awake_rate_replay_RT1(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

ylim([0 0.26])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Rate of awake replay (events/sec)')
set(gca,'FontSize',14)
axis square
title(sprintf('RUN2 T1 awake replay rate (%s)',rest_option));


nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[awake_rate_replay_RT2(prot_sess{1}) awake_rate_replay_RT2(prot_sess{2})...
    awake_rate_replay_RT2(prot_sess{3}) awake_rate_replay_RT2(prot_sess{4}) awake_rate_replay_RT2(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

ylim([0 0.26])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Rate of awake replay (events/sec)')
set(gca,'FontSize',14)
axis square
title(sprintf('RUN2 T2 awake replay rate (%s)',rest_option));


%% Plot awake replay number per track, all protocols together
% [p,tbl,stats] = kruskalwallis([awake_rate_replay_T1' awake_rate_replay_T2' awake_rate_replay_RT1' awake_rate_replay_RT2'],[],'off')
%
% if p < .05
%     c = multcompare(stats);
% end
%
% [p2,~] = ranksum(awake_rate_replay_RT1, awake_rate_replay_RT2)

f13 = figure('Color','w','Name','Awake replay rates');
f13.Position = [450 180 1020 720];
f13.Name = [sprintf('Awake replay number(%s)',rest_option)];

nexttile
grp = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
tst=[awake_local_replay_T1 awake_local_replay_T2 awake_local_replay_RT1 awake_local_replay_RT2]';

% xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'corral_style','rand');
xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'overlay_style','sd','corral_style','rand');

yticks([0:50:150])
xticks([1:4])
xticklabels({'RUN1 T1','RUN1 T2','RUN2 T1','RUN2 T2'})
ylabel('Number of awake replay')
set(gca,'FontSize',14)
ylim([0 170])
hold on

tst=[awake_local_replay_T1; awake_local_replay_T2; awake_local_replay_RT1; awake_local_replay_RT2]';

xbe = reshape(xbe,size(tst,1),size(tst,2));
for i = 1:size(tst,1)
    plot(xbe(i,[1 2]),tst(i,[1 2]),'Color',[0,0,0,0.2])
    plot(xbe(i,[3 4]),tst(i,[3 4]),'Color',[0,0,0,0.2])
end

axis square
title(sprintf('Awake replay number for both exposures (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[awake_local_replay_T1(prot_sess{1}) awake_local_replay_T1(prot_sess{2})...
    awake_local_replay_T1(prot_sess{3}) awake_local_replay_T1(prot_sess{4}) awake_local_replay_T1(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:50:150])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Number of awake replay')
set(gca,'FontSize',14)
ylim([0 170])
axis square
title(sprintf('RUN1 T1 awake replay number (%s)',rest_option));


nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[awake_local_replay_T2(prot_sess{1}) awake_local_replay_T2(prot_sess{2})...
    awake_local_replay_T2(prot_sess{3}) awake_local_replay_T2(prot_sess{4}) awake_local_replay_T2(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:50:150])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Number of awake replay')
set(gca,'FontSize',14)
ylim([0 170])
axis square
title(sprintf('RUN1 T2 awake replay number (%s)',rest_option));


nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[awake_local_replay_RT1(prot_sess{1}) awake_local_replay_RT1(prot_sess{2})...
    awake_local_replay_RT1(prot_sess{3}) awake_local_replay_RT1(prot_sess{4}) awake_local_replay_RT1(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:50:150])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Number of awake replay')
set(gca,'FontSize',14)
ylim([0 170])
axis square
title(sprintf('RUN2 T1 awake replay number (%s)',rest_option));



nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[awake_local_replay_RT2(prot_sess{1}) awake_local_replay_RT2(prot_sess{2})...
    awake_local_replay_RT2(prot_sess{3}) awake_local_replay_RT2(prot_sess{4}) awake_local_replay_RT2(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:50:150])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Number of awake replay')
set(gca,'FontSize',14)
ylim([0 170])
axis square
title(sprintf('RUN2 T2 awake replay number (%s)',rest_option));




%% Plot theta sequence number per track, all protocols together
% [p,tbl,stats] = kruskalwallis([awake_rate_replay_T1' awake_rate_replay_T2' awake_rate_replay_RT1' awake_rate_replay_RT2'],[],'off')
%
% if p < .05
%     c = multcompare(stats);
% end
%
% [p2,~] = ranksum(awake_rate_replay_RT1, awake_rate_replay_RT2)

f14 = figure('Color','w','Name','Theta sequence number per track');
f14.Position = [450 180 1020 720];
f14.Name = [sprintf('Theta sequence number per track(%s)',rest_option)];

nexttile
grp = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
tst = [total_num_thetaseq(:,1)' total_num_thetaseq(:,2)' total_num_thetaseq(:,3)' total_num_thetaseq(:,4)']';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'overlay_style','sd','corral_style','rand');

hold on
tst = [total_num_thetaseq(:,1)'; total_num_thetaseq(:,2)'; total_num_thetaseq(:,3)'; total_num_thetaseq(:,4)']';
xbe = reshape(xbe,size(tst,1),size(tst,2));
for i = 1:size(tst,1)
    plot(xbe(i,[1 2]),tst(i,[1 2]),'Color',[0,0,0,0.2])
    plot(xbe(i,[3 4]),tst(i,[3 4]),'Color',[0,0,0,0.2])
end

yticks([0:500:3100])
xticks([1:4])
xticklabels({'RUN1 T1','RUN1 T2','RUN2 T1','RUN2 T2'})
ylabel('Number of theta sequence')
set(gca,'FontSize',14)
ylim([-0.02 3100])
hold on
axis square
title(sprintf('Theta sequence number for both exposures (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst = [total_num_thetaseq(prot_sess{1},1)' total_num_thetaseq(prot_sess{2},1)'...
    total_num_thetaseq(prot_sess{3},1)' total_num_thetaseq(prot_sess{4},1)' total_num_thetaseq(prot_sess{5},1)']';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:500:3100])
xticks(1:5)
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Number of theta sequence')
set(gca,'FontSize',14)
ylim([-0.02 3100])
axis square
title(sprintf('RUN1 T1 Theta sequence number for both exposures (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst = [total_num_thetaseq(prot_sess{1},2)' total_num_thetaseq(prot_sess{2},2)'...
    total_num_thetaseq(prot_sess{3},2)' total_num_thetaseq(prot_sess{4},2)' total_num_thetaseq(prot_sess{5},2)']';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:500:3100])
xticks(1:5)
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Number of theta sequence')
set(gca,'FontSize',14)
ylim([-0.02 3100])
axis square
title(sprintf('RUN1 T2 Theta sequence number for both exposures (%s)',rest_option));


nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst = [total_num_thetaseq(prot_sess{1},3)' total_num_thetaseq(prot_sess{2},3)'...
    total_num_thetaseq(prot_sess{3},3)' total_num_thetaseq(prot_sess{4},3)' total_num_thetaseq(prot_sess{5},3)']';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:500:3100])
xticks(1:5)
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Number of theta sequence')
set(gca,'FontSize',14)
ylim([-0.02 3100])
axis square
title(sprintf('RUN2 T1 Theta sequence number for both exposures (%s)',rest_option));



nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst = [total_num_thetaseq(prot_sess{1},4)' total_num_thetaseq(prot_sess{2},4)'...
    total_num_thetaseq(prot_sess{3},4)' total_num_thetaseq(prot_sess{4},4)' total_num_thetaseq(prot_sess{5},4)']';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:500:3100])
xticks(1:5)
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Number of theta sequence')
set(gca,'FontSize',14)
ylim([-0.02 3100])
axis square
title(sprintf('RUN2 T2 Theta sequence number for both exposures (%s)',rest_option));


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

%% Running speed, mobility and immobility
f14 = figure('Color','w','Name','Summary of animal running speed, mobility and immobility');
f14.Position = [450 180 1020 720];

col = [PP.L1; PP.L2; PP.L3; PP.L4; PP.L8; PP.L16; [0.4 0.4 0.4]; [0.8 0.8 0.8]];
x_labels = {'1','2','3','4','8','16','RT1','RT2'}; %set labels for X axis

% Immobility
nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1;...
    ones(19,1)*6;ones(19,1)*7;ones(19,1)*8];% Only three session with 16-4 laps
tst = [immobility(prot_sess{1},2)' immobility(prot_sess{2},2)'...
    immobility(prot_sess{3},2)' immobility(prot_sess{4},2)' immobility(prot_sess{5},2)'...
    immobility(:,1)' immobility(:,3)' immobility(:,4)']';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);PP1.T2(2,:);PP1.T2(3,:);...
    PP1.T2(4,:);PP1.T2(5,:);PP1.T1;...
    PP.RUN2T1;PP.RUN2T2],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

xticks(1:8)
ylim([0 20])
xticklabels({'1','2','3','4','8','16','RT1','RT2'})
ylabel('Time spent immobile (mins)')
set(gca,'FontSize',14)
axis square
title('Time spent immobile')



% Mobility
nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1;...
    ones(19,1)*6;ones(19,1)*7;ones(19,1)*8];% Only three session with 16-4 laps
tst = [mobility(prot_sess{1},2)' mobility(prot_sess{2},2)'...
    mobility(prot_sess{3},2)' mobility(prot_sess{4},2)' mobility(prot_sess{5},2)'...
    mobility(:,1)' mobility(:,3)' mobility(:,4)']';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);PP1.T2(2,:);PP1.T2(3,:);...
    PP1.T2(4,:);PP1.T2(5,:);PP1.T1;...
    PP.RUN2T1;PP.RUN2T2],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on
xticks(1:8)
xticklabels({'1','2','3','4','8','16','RT1','RT2'})
ylim([0 15])
ylabel('Time spent mobile (mins)')
set(gca,'FontSize',14)
axis square
title('Time spent mobile')


% Running speed
% Mobility
nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1;...
    ones(19,1)*6;ones(19,1)*7;ones(19,1)*8];% Only three session with 16-4 laps
tst = [running_speed(prot_sess{1},2)' running_speed(prot_sess{2},2)'...
    running_speed(prot_sess{3},2)' running_speed(prot_sess{4},2)' running_speed(prot_sess{5},2)'...
    running_speed(:,1)' running_speed(:,3)' running_speed(:,4)']';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);PP1.T2(2,:);PP1.T2(3,:);...
    PP1.T2(4,:);PP1.T2(5,:);PP1.T1;...
    PP.RUN2T1;PP.RUN2T2],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

xticks(1:8)
ylim([0 25])
xticklabels({'1','2','3','4','8','16','RT1','RT2'})
set(gca,'FontSize',14)
axis square
xlabel('Protocols')
ylabel('Moving Speed (cm/sec)')
title('Moving Speed')

%% Three awake neural mechanisms vs sleep replay rate
nfig = figure('Color','w','Name','Theta and awake replay vs POST replay rate')
nfig.Position = [940 130 1100 870];
orient(nfig,'landscape')

nexttile
hold on
awake_theta = [total_num_thetaseq(:,1)' total_num_thetaseq(:,2)' total_num_thetaseq(:,3)' total_num_thetaseq(:,4)'];
sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
arrayfun(@(x) scatter(awake_theta(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on

mdl = fitlm(awake_theta',sleep');
[awake_theta_pval,awake_theta_F,~] = coefTest(mdl);
awake_theta_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_theta) max(awake_theta)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
% set(gca,'FontSize',14)
xlabel('Number of theta sequence')
ylabel('POST replay rate')
set(gca,'FontSize',14)
ylim([0 0.065])
xticks([0 1500 3000])
title(sprintf('Theta sequence number vs sleep replay first exposure (%s)',rest_option));
title(sprintf('Number of theta sequence vs POST replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',awake_theta_pval,awake_theta_R2),'Units','Normalized','FontName','Arial');
axis square


nexttile
hold on
awake_theta = [total_theta_windows(:,1)' total_theta_windows(:,2)' total_theta_windows(:,3)' total_theta_windows(:,4)'];
sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
arrayfun(@(x) scatter(awake_theta(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on

mdl = fitlm(awake_theta',sleep');
[awake_theta_pval,awake_theta_F,~] = coefTest(mdl);
awake_theta_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_theta) max(awake_theta)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
% set(gca,'FontSize',14)
xlabel('Number of theta cycles')
ylabel('POST replay rate')
set(gca,'FontSize',14)
ylim([0 0.065])
xticks([0 2500 5000])
title(sprintf('Theta cycles number vs sleep replay first exposure (%s)',rest_option));
title(sprintf('Number of theta cycles vs POST replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',awake_theta_pval,awake_theta_R2),'Units','Normalized','FontName','Arial');
axis square

nexttile
hold on
awake_rate = [awake_rate_replay_T1 awake_rate_replay_T2 awake_rate_replay_RT1 awake_rate_replay_RT2];
sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
arrayfun(@(x) scatter(awake_rate(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on

mdl = fitlm(awake_rate',sleep');
[awake_rate_pval,awake_rate_F,~] = coefTest(mdl);
awake_rate_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_rate) max(awake_rate)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
% set(gca,'FontSize',14)
xlabel('Rate of awake replay')
ylabel('POST replay rate')
set(gca,'FontSize',14)
ylim([0 0.065])
xticks([0 0.1 0.2])
title(sprintf('Awake replay rate vs POST replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',awake_rate_pval,awake_rate_R2),'Units','Normalized','FontName','Arial');
axis square

nexttile
hold on
awake_rate = [SWR_event_rate(:,1)' SWR_event_rate(:,2)' SWR_event_rate(:,3)' SWR_event_rate(:,4)'];
sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
arrayfun(@(x) scatter(awake_rate(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on

mdl = fitlm(awake_rate',sleep');
[awake_rate_pval,awake_rate_F,~] = coefTest(mdl);
awake_rate_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_rate) max(awake_rate)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
% set(gca,'FontSize',14)
xlabel('Rate of SWR events')
ylabel('POST replay rate')
set(gca,'FontSize',14)
ylim([0 0.065])
xticks([0 0.25 0.5])
title(sprintf('Awake SWR rate vs POST replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',awake_rate_pval,awake_rate_R2),'Units','Normalized','FontName','Arial');
axis square


nexttile
hold on
awake_number = [awake_local_replay_T1 awake_local_replay_T2 awake_local_replay_RT1 awake_local_replay_RT2];
sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
arrayfun(@(x) scatter(awake_number(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on

mdl = fitlm(awake_number',sleep');
[awake_number_pval,awake_number_F,~] = coefTest(mdl);
awake_number_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_number) max(awake_number)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
% set(gca,'FontSize',14)
xlabel('Number of awake replay')
ylabel('POST replay rate')
set(gca,'FontSize',14)
ylim([0 0.065])
xticks([0 75 150])
title(sprintf('Awake replay number vs POST replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',awake_number_pval,awake_number_R2),'Units','Normalized','FontName','Arial');
axis square

nexttile
hold on
awake_number = [SWR_event_number(:,1)' SWR_event_number(:,2)' SWR_event_number(:,3)' SWR_event_number(:,4)'];
sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];
arrayfun(@(x) scatter(awake_number(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on

mdl = fitlm(awake_number',sleep');
[awake_number_pval,awake_number_F,~] = coefTest(mdl);
awake_number_R2 = mdl.Rsquared.Adjusted;
x =[min(awake_number) max(awake_number)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
% set(gca,'FontSize',14)
xlabel('Number of SWR events')
ylabel('POST replay rate')
set(gca,'FontSize',14)
ylim([0 0.065])
xticks([0 150 300])
title(sprintf('Awake SWR number vs POST replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',awake_number_pval,awake_number_R2),'Units','Normalized','FontName','Arial');
axis square


%% mobility and immobility vs POST replay
nfig = figure('Color','w','Name','Behaviour vs POST replay')
nfig.Position = [940 130 1100 870];
orient(nfig,'landscape')

immobile_time = [immobility(:,1)' immobility(:,2)' immobility(:,3)' immobility(:,4)'];
mobile_time = [mobility(:,1)' mobility(:,2)' mobility(:,3)' mobility(:,4)'];
time_total = [immobile_time + mobile_time];
speed = [running_speed(:,1)' running_speed(:,2)' running_speed(:,3)' running_speed(:,4)'];
sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];

new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];

nexttile
hold on
arrayfun(@(x) scatter(time_total(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(time_total))

mdl = fitlm(time_total',sleep');
[pval,F_stat,~] = coefTest(mdl);
R2 = mdl.Rsquared.Adjusted;
x =[min(time_total) max(time_total)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,':','Color','k','LineWidth',3)
xlabel('Total time on track (mins)')
ylabel('POST replay rate')
ylim([0 0.065])
xticks([0 5 10 15 20])
set(gca,'FontSize',14)
title(sprintf('Time spent on track vs POST replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
% legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,R2),'Units','Normalized','FontName','Arial');
axis square


nexttile
nexttile
nexttile
nexttile











