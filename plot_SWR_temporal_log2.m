function plot_SWR_temporal_log2(bayesian_control,rest_option,time_chunk_size,time_window)

if ~isempty(bayesian_control)
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\extracted_time_periods_replay_excl.mat')
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only first exposure';
    path2 = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only re-exposure';
    track_replay_events_F = load([path '\extracted_replay_plotting_info_excl.mat']);
    track_replay_events_R = load([path2 '\extracted_replay_plotting_info_excl.mat']);
    
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
        elseif time_chunk_size == 600
            load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_awake_replay_10min_excl.mat']); %info of sleep in time bins
            
        elseif time_chunk_size == 1800
            load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_awake_replay_30min_excl.mat']); %info of sleep in time bins           
        end
    elseif strcmp(rest_option,'sleep')
        if time_chunk_size == 900
            load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_sleep_replay_15min_excl.mat']); %info of sleep in time bins
            %         load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_merged_replay_60min_excl.mat']); %info of sleep in time bins
   elseif time_chunk_size == 600
            load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_sleep_replay_10min_excl.mat']); %info of sleep in time bins
            
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
        
        INTER_T1_rate_events_diff(s) = rate_replay(1).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,2}...
            - rate_replay(1).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,1}; % POST1 T1 rate events within first 30min of sleep
        INTER_T2_rate_events_diff(s) = rate_replay(2).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,2}...
            - rate_replay(2).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,1}; % POST1 T1 rate events within first 30min of sleep

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
        
        
        FINAL_RT1_rate_events_diff(s) = rate_replay(1).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_replay_rate{cnt,2}...
            - rate_replay(1).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,1}; % POST1 T1 rate events within first 30min of sleep
        FINAL_RT2_rate_events_diff(s) = rate_replay(2).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_replay_rate{cnt,2}...
            - rate_replay(2).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,1}; % POST1 T1 rate events within first 30min of sleep
  
        load([folders{s},'\extracted_replay_events.mat'])
        load([folders{s},'\significant_replay_events_wcorr.mat'])
        load([folders{s},'\decoded_replay_events.mat'])
        load([folders{s},'\extracted_sleep_state.mat'])

        SWR_event_time{s} = [];
        SWR_event_time{s} = significant_replay_events.all_event_times;
        for event = 1:length(SWR_event_time{s}) % SRW zscore 3
            if SWR_event_time{s}(event) < sleep_state.state_time.PRE_end
                SWR_event_normalised_time{s}(event) = SWR_event_time{s}(event) - sleep_state.state_time.PRE_start;
                SWR_event_state_PRE{s}(event) = 0;
                
                for time = 1:size(period_time(s).PRE.sleep,1)
                    if SWR_event_time{s}(event) < period_time(s).PRE.sleep(time,2) & SWR_event_time{s}(event) > period_time(s).PRE.sleep(time,1)
                        SWR_event_state_PRE{s}(event) = 2;
                        SWR_event_normalised_time{s}(event) = SWR_event_time{s}(event) - period_time(s).PRE.sleep(time,1) + period_time(s).PRE.sleep_cumulative_time(time,1);
                    end
                end
                
                for time = 1:size(period_time(s).PRE.awake,1)
                    if SWR_event_time{s}(event) < period_time(s).PRE.awake(time,2) & SWR_event_time{s}(event) > period_time(s).PRE.awake(time,1)
                        SWR_event_state_PRE{s}(event) = 1;
                        SWR_event_normalised_time{s}(event) = SWR_event_time{s}(event) - period_time(s).PRE.awake(time,1) + period_time(s).PRE.awake_cumulative_time(time,1);
                    end
                end
                
                
                
            elseif SWR_event_time{s}(event) < sleep_state.state_time.INTER_post_end & SWR_event_time{s}(event) > sleep_state.state_time.INTER_post_start
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
                SWR_event_state_PRE{s}(event) = nan;
                SWR_event_state_POST1{s}(event) = nan;
                SWR_event_state_POST2{s}(event) = nan;
                SWR_event_normalised_time{s}(event) = nan;
            end
        end
        
        
%             SWR_event_number(s,1) = length(T4_SWR_event_time); % Number of SWR events
%             SWR_event_number(s,2) = length(T2_SWR_event_index);
%             SWR_event_number(s,3) = length(T3_SWR_event_index);
%             SWR_event_number(s,4) = length(T4_SWR_event_index);
%             SWR_event_rate(s,1) = length(T1_SWR_event_index)/(60*time_immobile(old_sess_index,1)); % Rate of SWR events
%             SWR_event_rate(s,2) = length(T2_SWR_event_index)/(60*time_immobile(old_sess_index,2)); 
%             SWR_event_rate(s,3) = length(T3_SWR_event_index)/(60*time_immobile(old_sess_index,3));
%             SWR_event_rate(s,4) = length(T4_SWR_event_index)/(60*time_immobile(old_sess_index,4));
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

fig = figure(1)
fig.Position = [700 110 1100 870]
for s = 1:19
    nexttile
    event_time = SWR_event_normalised_time{s}(find(SWR_event_state_POST1{s}==1));
    event_time_edges = 0:600:3600;
    [event_counts_POST1_awake(s,:),edges] = histcounts(event_time,event_time_edges);
    histogram(event_time,event_time_edges)
    title(sprintf('session %i',s))
end
sgtitle('awake POST1 SWR events')


fig = figure(2)
fig.Position = [700 110 1100 870]
for s = 1:19
    nexttile
    event_time = SWR_event_normalised_time{s}(find(SWR_event_state_POST1{s}==2));
    event_time_edges = 0:600:3600;
    [event_counts_POST1_sleep(s,:),edges] = histcounts(event_time,event_time_edges);
    histogram(event_time,event_time_edges)
    title(sprintf('session %i',s))
end
sgtitle('sleep POST1 SWR events')


fig = figure(3)
fig.Position = [700 110 1100 870]
for s = 1:19
    nexttile
    event_time = SWR_event_normalised_time{s}(find(SWR_event_state_POST2{s}==1));
    event_time_edges = 0:600:3600;
    [event_counts_POST2_awake(s,:),edges] = histcounts(event_time,event_time_edges);
    histogram(event_time,event_time_edges)
    title(sprintf('session %i',s))
end
sgtitle('awake POST2 SWR events')


fig = figure(4)
fig.Position = [700 110 1100 870]
for s = 1:19
    nexttile
    event_time = SWR_event_normalised_time{s}(find(SWR_event_state_POST2{s}==2));
    event_time_edges = 0:600:3600;
    [event_counts_POST2_sleep(s,:),edges] = histcounts(event_time,event_time_edges);
    histogram(event_time,event_time_edges)
    title(sprintf('session %i',s))
end
sgtitle('sleep POST2 SWR events')





PP =  plotting_parameters;
PP1.T1 = PP.T1;
PP1.T2 = PP.T2;

for n = 1:size(PP.T2,1)
    PP1.T2(6-n,:) = PP.T2(n,:);
end
