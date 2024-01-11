function plot_sleep_replay_temporal_effect_log2_backup(bayesian_control,rest_option,time_chunk_size,time_window)

if ~isempty(bayesian_control)
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
        

        for time = 1:6
            INTER_T1_rate_events_temporal(s,time) = rate_replay(1).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,time};
            INTER_T2_rate_events_temporal(s,time) = rate_replay(2).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,time};
            
            FINAL_RT1_rate_events_temporal(s,time) = rate_replay(1).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_replay_rate{cnt,time};
            FINAL_RT2_rate_events_temporal(s,time) = rate_replay(2).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_replay_rate{cnt,time};
        end
        
        load([folders{s},'\extracted_replay_events.mat'])
        load([folders{s},'\significant_replay_events_wcorr.mat'])
        load([folders{s},'\extracted_position.mat'])
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

%% Theta number, awake replay number and rate VS Sleep replay rate OVER THE COURSE OF SLEEP

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

sleep = [INTER_T1_rate_events_temporal(:,1:3); INTER_T2_rate_events_temporal(:,1:3); FINAL_RT1_rate_events_temporal(:,1:3); FINAL_RT2_rate_events_temporal(:,1:3)];
sleep(sleep==0) = min(sleep(sleep~=0));
% sleep(sleep==0) = 1;
sleep = log2(sleep);


awake_rate_boot = [];
awake_number_boot = [];
awake_theta_boot = [];
sleep_boot = [];

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
        awake_local_replay_T2(seed2)...
        awake_local_replay_RT1(seed3)...
        awake_local_replay_RT2(seed4)];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_number_boot(:,n) = log2(tempt);
    
    tempt = [awake_rate_replay_T1(seed1)...
        awake_rate_replay_T2(seed2)...
        awake_rate_replay_RT1(seed3)...
        awake_rate_replay_RT2(seed4)];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_rate_boot(:,n) = log2(tempt);
    
    tempt = [total_num_thetaseq(seed1,1)'...
        total_num_thetaseq(seed2,2)'...
        total_num_thetaseq(seed3,3)'...
        total_num_thetaseq(seed4,4)'];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_theta_boot(:,n) = log2(tempt);
    
    for time = 1:3
        s1 = RandStream('mcg16807','Seed',n);
        s2 = RandStream('mcg16807','Seed',1000+n);
        s3 = RandStream('mcg16807','Seed',2000+n);
        s4 = RandStream('mcg16807','Seed',3000+n);
        
        tempt = [INTER_T1_rate_events_temporal(seed1,time)',...
            INTER_T1_rate_events_temporal(seed2,time)',...
            FINAL_RT1_rate_events_temporal(seed3,time)',...
            FINAL_RT2_rate_events_temporal(seed4,time)'];
        
        tempt = [datasample(s1,INTER_T1_rate_events_temporal(:,time)',length(INTER_T1_rate_events_temporal))...
            datasample(s2,INTER_T2_rate_events_temporal(:,time)',length(INTER_T1_rate_events_temporal))...
            datasample(s3,FINAL_RT1_rate_events_temporal(:,time)',length(FINAL_RT1_rate_events_temporal))...
            datasample(s4,FINAL_RT2_rate_events_temporal(:,time)',length(FINAL_RT2_rate_events_temporal))]';
        
        tempt(tempt==0) = min(tempt(tempt~=0));
        % sleep(sleep==0) = 1;
        sleep_boot(:,time,n) = log2(tempt);
    end
end


new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];

nfig = figure('Color','w','Name','awake replay rate vs POST replay over time')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')
time_epoch = {'0-10 min','10-20 min','20-30 min'}
% Rate
for time = 1:3
    nexttile
    hold on
    arrayfun(@(x) scatter(awake_rate(x),sleep(x,time),86,new_cls(x,:),'filled','o'),1:length(awake_rate))
    
    mdl = fitlm(awake_rate',sleep(:,time)');
    [pval,F_stat,~] = coefTest(mdl);
    R2 = mdl.Rsquared.Adjusted;
    x =[min(awake_rate) max(awake_rate)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    plot(x,y_est,':','Color','k','LineWidth',3)
    xlabel('Rate of awake replay (log2)')
    ylabel('Rate of POST replay (log2)')
    set(gca,'FontSize',14)
    title(sprintf('Rate of awake replay (%s) %s',rest_option,time_epoch{time}));
    f=get(gca,'Children');
    % Mind that order is reversed
    % legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
    text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,R2),'Units','Normalized','FontName','Arial');
    axis square
    
    parfor n = 1:1000
%         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
        mdl = fitlm(awake_rate_boot(:,n)',sleep_boot(:,time,n)');
        [pval,awake_rate_F_stat(time,n),~] = coefTest(mdl);
        awake_rate_R2(time,n) = mdl.Rsquared.Adjusted;
    end
end

nexttile
clear b
x = [mean(awake_rate_R2(1,:)) mean(awake_rate_R2(2,:)) mean(awake_rate_R2(3,:))];
x_CI = [prctile(awake_rate_R2(1,:),[2.5 97.5]); prctile(awake_rate_R2(2,:),[2.5 97.5]); prctile(awake_rate_R2(3,:),[2.5 97.5])];

for k = 1:3
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3])
xticklabels(time_epoch)
ylabel('R2')
title(sprintf('R2 of awake replay rate effect over time(%s)',rest_option));


nfig = figure('Color','w','Name','awake replay number vs POST replay over time')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')
time_epoch = {'0-10 min','10-20 min','20-30 min'}
for time = 1:3
    nexttile
    hold on
    arrayfun(@(x) scatter(awake_number(x),sleep(x,time),86,new_cls(x,:),'filled','o'),1:length(awake_number))
    
    mdl = fitlm(awake_number',sleep(:,time)');
    [pval,F_stat,~] = coefTest(mdl);
    R2 = mdl.Rsquared.Adjusted;
    x =[min(awake_number) max(awake_number)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    plot(x,y_est,':','Color','k','LineWidth',3)
    xlabel('Number of awake replay (log2)')
    ylabel('Rate of POST replay (log2)')
    set(gca,'FontSize',14)
    title(sprintf('Number of awake replay (%s) %s',rest_option,time_epoch{time}));
    f=get(gca,'Children');
    % Mind that order is reversed
    % legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
    text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,R2),'Units','Normalized','FontName','Arial');
    axis square
    
    parfor n = 1:1000
%         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
        mdl = fitlm(awake_number_boot(:,n)',sleep_boot(:,time,n)');
        [pval,awake_number_F_stat(time,n),~] = coefTest(mdl);
        awake_number_R2(time,n) = mdl.Rsquared.Adjusted;
    end
end

nexttile
clear b
x = [mean(awake_number_R2(1,:)) mean(awake_number_R2(2,:)) mean(awake_number_R2(3,:))];
x_CI = [prctile(awake_number_R2(1,:),[2.5 97.5]); prctile(awake_number_R2(2,:),[2.5 97.5]); prctile(awake_number_R2(3,:),[2.5 97.5])];

for k = 1:3
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3])
xticklabels(time_epoch)
ylabel('R2')
title(sprintf('R2 of awake replay number effect over time(%s)',rest_option));



nfig = figure('Color','w','Name','theta sequence vs POST replay over time')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')
time_epoch = {'0-10 min','10-20 min','20-30 min'}
for time = 1:3
    nexttile
    hold on
    arrayfun(@(x) scatter(awake_theta(x),sleep(x,time),86,new_cls(x,:),'filled','o'),1:length(awake_theta))
    
    mdl = fitlm(awake_theta',sleep(:,time)');
    [pval,F_stat,~] = coefTest(mdl);
    R2 = mdl.Rsquared.Adjusted;
    x =[min(awake_theta) max(awake_theta)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    plot(x,y_est,':','Color','k','LineWidth',3)
    xlabel('Number of theta sequence (log2)')
    ylabel('Rate of POST replay (log2)')
    set(gca,'FontSize',14)
    title(sprintf('Number of theta sequence (%s) %s',rest_option,time_epoch{time}));
    f=get(gca,'Children');
    % Mind that order is reversed
    % legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
    text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,R2),'Units','Normalized','FontName','Arial');
    axis square
    
    parfor n = 1:1000
%         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
        mdl = fitlm(awake_theta_boot(:,n)',sleep_boot(:,time,n)');
        [pval,awake_theta_F_stat(time,n),~] = coefTest(mdl);
        awake_theta_R2(time,n) = mdl.Rsquared.Adjusted;
    end
end

nexttile
clear b
x = [mean(awake_theta_R2(1,:)) mean(awake_theta_R2(2,:)) mean(awake_theta_R2(3,:))];
x_CI = [prctile(awake_theta_R2(1,:),[2.5 97.5]); prctile(awake_theta_R2(2,:),[2.5 97.5]); prctile(awake_theta_R2(3,:),[2.5 97.5])];

for k = 1:3
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3])
xticklabels(time_epoch)
ylabel('R2')
title(sprintf('R2 of theta sequence effect over time(%s)',rest_option));




%% Theta number, awake replay number and rate VS Sleep replay rate OVER THE COURSE OF SLEEP
%% POST1 Temporal effect

awake_rate = [awake_rate_replay_T1 awake_rate_replay_T2]';
% index = find(awake_rate==0);
% awake_rate = 
awake_rate(awake_rate==0) = min(awake_rate(awake_rate~=0));
awake_rate = log2(awake_rate);

awake_number = [awake_local_replay_T1 awake_local_replay_T2]';
awake_number(awake_number==0) = min(awake_number(awake_number~=0));
% awake_number(awake_number==0) = 1;
awake_number = log2(awake_number);

awake_theta = [total_num_thetaseq(:,1)' total_num_thetaseq(:,2)'];
awake_theta(awake_theta==0) = min(awake_theta(awake_theta~=0));
awake_theta = log2(awake_theta);

sleep = [INTER_T1_rate_events_temporal; INTER_T2_rate_events_temporal];
sleep(sleep==0) = min(sleep(sleep~=0));
% sleep(sleep==0) = 1;
sleep = log2(sleep);


awake_rate_boot = [];
awake_number_boot = [];
awake_theta_boot = [];
sleep_boot = [];

parfor n = 1:1000
    s1 = RandStream('mcg16807','Seed',n);
    s2 = RandStream('mcg16807','Seed',1000+n);
    s3 = RandStream('mcg16807','Seed',2000+n);
    s4 = RandStream('mcg16807','Seed',3000+n);
    
    seed1 = randi(s1,[1 size(awake_local_replay_T1,2)],1,size(awake_local_replay_T1,2));
    seed2 = randi(s2,[1 size(awake_local_replay_T2,2)],1,size(awake_local_replay_T2,2));
%     seed3 = randi(s3,[1 size(awake_local_replay_RT1,2)],1,size(awake_local_replay_RT1,2));
%     seed4 = randi(s4,[1 size(awake_local_replay_RT2,2)],1,size(awake_local_replay_RT2,2));
    
    tempt = [awake_local_replay_T1(seed1)...
        awake_local_replay_T2(seed2)];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_number_boot(:,n) = log2(tempt);
    
    tempt = [awake_rate_replay_T1(seed1)...
        awake_rate_replay_T2(seed2)];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_rate_boot(:,n) = log2(tempt);
    
    tempt = [total_num_thetaseq(seed1,1)'...
        total_num_thetaseq(seed2,2)'];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_theta_boot(:,n) = log2(tempt);
    
    for time = 1:3
        s1 = RandStream('mcg16807','Seed',n);
        s2 = RandStream('mcg16807','Seed',1000+n);
%         s3 = RandStream('mcg16807','Seed',2000+n);
%         s4 = RandStream('mcg16807','Seed',3000+n);
        
        tempt = [datasample(s1,INTER_T1_rate_events_temporal(:,time)',length(INTER_T1_rate_events_temporal))...
            datasample(s2,INTER_T2_rate_events_temporal(:,time)',length(INTER_T1_rate_events_temporal))]';
        
        tempt(tempt==0) = min(tempt(tempt~=0));
        % sleep(sleep==0) = 1;
        sleep_boot(:,time,n) = log2(tempt);
    end
end


new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];

nfig = figure('Color','w','Name','awake replay rate vs POST replay over time')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')
time_epoch = {'0-10 min','10-20 min','20-30 min'}
% Rate
for time = 1:3
    nexttile
    hold on
    arrayfun(@(x) scatter(awake_rate(x),sleep(x,time),86,new_cls(x,:),'filled','o'),1:length(awake_rate))
    
    mdl = fitlm(awake_rate',sleep(:,time)');
    [pval,F_stat,~] = coefTest(mdl);
    R2 = mdl.Rsquared.Adjusted;
    x =[min(awake_rate) max(awake_rate)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    plot(x,y_est,':','Color','k','LineWidth',3)
    xlabel('Rate of awake replay (log2)')
    ylabel('Rate of POST replay (log2)')
    set(gca,'FontSize',14)
    title(sprintf('Rate of awake replay (%s) %s',rest_option,time_epoch{time}));
    f=get(gca,'Children');
    % Mind that order is reversed
    % legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
    text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,R2),'Units','Normalized','FontName','Arial');
    axis square
    
    parfor n = 1:1000
%         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
        mdl = fitlm(awake_rate_boot(:,n)',sleep_boot(:,time,n)');
        [pval,awake_rate_F_stat(time,n),~] = coefTest(mdl);
        awake_rate_R2(time,n) = mdl.Rsquared.Adjusted;
    end
end

nexttile
clear b
x = [mean(awake_rate_R2(1,:)) mean(awake_rate_R2(2,:)) mean(awake_rate_R2(3,:))];
x_CI = [prctile(awake_rate_R2(1,:),[2.5 97.5]); prctile(awake_rate_R2(2,:),[2.5 97.5]); prctile(awake_rate_R2(3,:),[2.5 97.5])];

for k = 1:3
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3])
xticklabels(time_epoch)
ylabel('R2')
title(sprintf('R2 of awake replay rate effect over time(%s)',rest_option));


nfig = figure('Color','w','Name','awake replay number vs POST replay over time')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')
time_epoch = {'0-10 min','10-20 min','20-30 min'}
for time = 1:3
    nexttile
    hold on
    arrayfun(@(x) scatter(awake_number(x),sleep(x,time),86,new_cls(x,:),'filled','o'),1:length(awake_number))
    
    mdl = fitlm(awake_number',sleep(:,time)');
    [pval,F_stat,~] = coefTest(mdl);
    R2 = mdl.Rsquared.Adjusted;
    x =[min(awake_number) max(awake_number)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    plot(x,y_est,':','Color','k','LineWidth',3)
    xlabel('Number of awake replay (log2)')
    ylabel('Rate of POST replay (log2)')
    set(gca,'FontSize',14)
    title(sprintf('Number of awake replay (%s) %s',rest_option,time_epoch{time}));
    f=get(gca,'Children');
    % Mind that order is reversed
    % legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
    text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,R2),'Units','Normalized','FontName','Arial');
    axis square
    
    parfor n = 1:1000
%         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
        mdl = fitlm(awake_number_boot(:,n)',sleep_boot(:,time,n)');
        [pval,awake_number_F_stat(time,n),~] = coefTest(mdl);
        awake_number_R2(time,n) = mdl.Rsquared.Adjusted;
    end
end

nexttile
clear b
x = [mean(awake_number_R2(1,:)) mean(awake_number_R2(2,:)) mean(awake_number_R2(3,:))];
x_CI = [prctile(awake_number_R2(1,:),[2.5 97.5]); prctile(awake_number_R2(2,:),[2.5 97.5]); prctile(awake_number_R2(3,:),[2.5 97.5])];

for k = 1:3
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3])
xticklabels(time_epoch)
ylabel('R2')
title(sprintf('R2 of awake replay number effect over time(%s)',rest_option));



nfig = figure('Color','w','Name','theta sequence vs POST replay over time')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')
time_epoch = {'0-10 min','10-20 min','20-30 min'}
for time = 1:3
    nexttile
    hold on
    arrayfun(@(x) scatter(awake_theta(x),sleep(x,time),86,new_cls(x,:),'filled','o'),1:length(awake_theta))
    
    mdl = fitlm(awake_theta',sleep(:,time)');
    [pval,F_stat,~] = coefTest(mdl);
    R2 = mdl.Rsquared.Adjusted;
    x =[min(awake_theta) max(awake_theta)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    plot(x,y_est,':','Color','k','LineWidth',3)
    xlabel('Number of theta sequence (log2)')
    ylabel('Rate of POST replay (log2)')
    set(gca,'FontSize',14)
    title(sprintf('Number of theta sequence (%s) %s',rest_option,time_epoch{time}));
    f=get(gca,'Children');
    % Mind that order is reversed
    % legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
    text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,R2),'Units','Normalized','FontName','Arial');
    axis square
    
    parfor n = 1:1000
%         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
        mdl = fitlm(awake_theta_boot(:,n)',sleep_boot(:,time,n)');
        [pval,awake_theta_F_stat(time,n),~] = coefTest(mdl);
        awake_theta_R2(time,n) = mdl.Rsquared.Adjusted;
    end
end

nexttile
clear b
x = [mean(awake_theta_R2(1,:)) mean(awake_theta_R2(2,:)) mean(awake_theta_R2(3,:))];
x_CI = [prctile(awake_theta_R2(1,:),[2.5 97.5]); prctile(awake_theta_R2(2,:),[2.5 97.5]); prctile(awake_theta_R2(3,:),[2.5 97.5])];

for k = 1:3
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3])
xticklabels(time_epoch)
ylabel('R2')
title(sprintf('R2 of theta sequence effect over time(%s)',rest_option));

%% Theta number, awake replay number and rate VS Sleep replay rate OVER THE COURSE OF SLEEP
%% POST2 Temporal effect

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

sleep = [INTER_T1_rate_events_temporal; INTER_T2_rate_events_temporal; FINAL_RT1_rate_events_temporal(:,1:3); FINAL_RT2_rate_events_temporal(:,1:3)];
sleep(sleep==0) = min(sleep(sleep~=0));
% sleep(sleep==0) = 1;
sleep = log2(sleep);


awake_rate_boot = [];
awake_number_boot = [];
awake_theta_boot = [];
sleep_boot = [];

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
        awake_local_replay_T2(seed2)...
        awake_local_replay_RT1(seed3)...
        awake_local_replay_RT2(seed4)];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_number_boot(:,n) = log2(tempt);
    
    tempt = [awake_rate_replay_T1(seed1)...
        awake_rate_replay_T2(seed2)...
        awake_rate_replay_RT1(seed3)...
        awake_rate_replay_RT2(seed4)];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_rate_boot(:,n) = log2(tempt);
    
    tempt = [total_num_thetaseq(seed1,1)'...
        total_num_thetaseq(seed2,2)'...
        total_num_thetaseq(seed3,3)'...
        total_num_thetaseq(seed4,4)'];
    tempt(tempt==0) = min(tempt(tempt~=0));
    awake_theta_boot(:,n) = log2(tempt);
    
    for time = 1:3
        s1 = RandStream('mcg16807','Seed',n);
        s2 = RandStream('mcg16807','Seed',1000+n);
        s3 = RandStream('mcg16807','Seed',2000+n);
        s4 = RandStream('mcg16807','Seed',3000+n);
        
        tempt = [datasample(s1,INTER_T1_rate_events_temporal(:,time)',length(INTER_T1_rate_events_temporal))...
            datasample(s2,INTER_T2_rate_events_temporal(:,time)',length(INTER_T1_rate_events_temporal))...
            datasample(s3,FINAL_RT1_rate_events_temporal(:,time)',length(FINAL_RT1_rate_events_temporal))...
            datasample(s4,FINAL_RT2_rate_events_temporal(:,time)',length(FINAL_RT2_rate_events_temporal))]';
        
        tempt(tempt==0) = min(tempt(tempt~=0));
        % sleep(sleep==0) = 1;
        sleep_boot(:,time,n) = log2(tempt);
    end
end


new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];

nfig = figure('Color','w','Name','awake replay rate vs POST replay over time')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')
time_epoch = {'0-10 min','10-20 min','20-30 min'}
% Rate
for time = 1:3
    nexttile
    hold on
    arrayfun(@(x) scatter(awake_rate(x),sleep(x,time),86,new_cls(x,:),'filled','o'),1:length(awake_rate))
    
    mdl = fitlm(awake_rate',sleep(:,time)');
    [pval,F_stat,~] = coefTest(mdl);
    R2 = mdl.Rsquared.Adjusted;
    x =[min(awake_rate) max(awake_rate)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    plot(x,y_est,':','Color','k','LineWidth',3)
    xlabel('Rate of awake replay (log2)')
    ylabel('Rate of POST replay (log2)')
    set(gca,'FontSize',14)
    title(sprintf('Rate of awake replay (%s) %s',rest_option,time_epoch{time}));
    f=get(gca,'Children');
    % Mind that order is reversed
    % legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
    text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,R2),'Units','Normalized','FontName','Arial');
    axis square
    
    parfor n = 1:1000
%         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
        mdl = fitlm(awake_rate_boot(:,n)',sleep_boot(:,time,n)');
        [pval,awake_rate_F_stat(time,n),~] = coefTest(mdl);
        awake_rate_R2(time,n) = mdl.Rsquared.Adjusted;
    end
end

nexttile
clear b
x = [mean(awake_rate_R2(1,:)) mean(awake_rate_R2(2,:)) mean(awake_rate_R2(3,:))];
x_CI = [prctile(awake_rate_R2(1,:),[2.5 97.5]); prctile(awake_rate_R2(2,:),[2.5 97.5]); prctile(awake_rate_R2(3,:),[2.5 97.5])];

for k = 1:3
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3])
xticklabels(time_epoch)
ylabel('R2')
title(sprintf('R2 of awake replay rate effect over time(%s)',rest_option));


nfig = figure('Color','w','Name','awake replay number vs POST replay over time')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')
time_epoch = {'0-10 min','10-20 min','20-30 min'}
for time = 1:3
    nexttile
    hold on
    arrayfun(@(x) scatter(awake_number(x),sleep(x,time),86,new_cls(x,:),'filled','o'),1:length(awake_number))
    
    mdl = fitlm(awake_number',sleep(:,time)');
    [pval,F_stat,~] = coefTest(mdl);
    R2 = mdl.Rsquared.Adjusted;
    x =[min(awake_number) max(awake_number)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    plot(x,y_est,':','Color','k','LineWidth',3)
    xlabel('Number of awake replay (log2)')
    ylabel('Rate of POST replay (log2)')
    set(gca,'FontSize',14)
    title(sprintf('Number of awake replay (%s) %s',rest_option,time_epoch{time}));
    f=get(gca,'Children');
    % Mind that order is reversed
    % legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
    text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,R2),'Units','Normalized','FontName','Arial');
    axis square
    
    parfor n = 1:1000
%         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
        mdl = fitlm(awake_number_boot(:,n)',sleep_boot(:,time,n)');
        [pval,awake_number_F_stat(time,n),~] = coefTest(mdl);
        awake_number_R2(time,n) = mdl.Rsquared.Adjusted;
    end
end

nexttile
clear b
x = [mean(awake_number_R2(1,:)) mean(awake_number_R2(2,:)) mean(awake_number_R2(3,:))];
x_CI = [prctile(awake_number_R2(1,:),[2.5 97.5]); prctile(awake_number_R2(2,:),[2.5 97.5]); prctile(awake_number_R2(3,:),[2.5 97.5])];

for k = 1:3
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3])
xticklabels(time_epoch)
ylabel('R2')
title(sprintf('R2 of awake replay number effect over time(%s)',rest_option));



nfig = figure('Color','w','Name','theta sequence vs POST replay over time')
nfig.Position = [940 100 920 900];
orient(nfig,'landscape')
time_epoch = {'0-10 min','10-20 min','20-30 min'}
for time = 1:3
    nexttile
    hold on
    arrayfun(@(x) scatter(awake_theta(x),sleep(x,time),86,new_cls(x,:),'filled','o'),1:length(awake_theta))
    
    mdl = fitlm(awake_theta',sleep(:,time)');
    [pval,F_stat,~] = coefTest(mdl);
    R2 = mdl.Rsquared.Adjusted;
    x =[min(awake_theta) max(awake_theta)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    plot(x,y_est,':','Color','k','LineWidth',3)
    xlabel('Number of theta sequence (log2)')
    ylabel('Rate of POST replay (log2)')
    set(gca,'FontSize',14)
    title(sprintf('Number of theta sequence (%s) %s',rest_option,time_epoch{time}));
    f=get(gca,'Children');
    % Mind that order is reversed
    % legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
    text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,R2),'Units','Normalized','FontName','Arial');
    axis square
    
    parfor n = 1:1000
%         arrayfun(@(x) scatter(awake_rate_boot(x,n),sleep_boot(x,time,n),86,new_cls(x,:),'filled','o'),1:length(awake_rate_boot(:,n)))
        mdl = fitlm(awake_theta_boot(:,n)',sleep_boot(:,time,n)');
        [pval,awake_theta_F_stat(time,n),~] = coefTest(mdl);
        awake_theta_R2(time,n) = mdl.Rsquared.Adjusted;
    end
end

nexttile
clear b
x = [mean(awake_theta_R2(1,:)) mean(awake_theta_R2(2,:)) mean(awake_theta_R2(3,:))];
x_CI = [prctile(awake_theta_R2(1,:),[2.5 97.5]); prctile(awake_theta_R2(2,:),[2.5 97.5]); prctile(awake_theta_R2(3,:),[2.5 97.5])];

for k = 1:3
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3])
xticklabels(time_epoch)
ylabel('R2')
title(sprintf('R2 of theta sequence effect over time(%s)',rest_option));


end



