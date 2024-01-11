function plot_theta_vs_replay_backup(bayesian_control,rest_option,time_chunk_size)
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
    
    % Load theta info
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


cnt = 1;
ses = 1;

%% for each session gather and calculate replay info
for s = 1 : num_sess
    if s < 5
        old_sess_index = s;
    else
        old_sess_index = s+1; % Skip session N-BLU_Day2_16x4
    end
    if isempty(bayesian_control)
        awake_local_replay_RT1(s) = length(track_replay_events(s).T3.T3_times); % RT1 events during RT1
        awake_local_replay_RT2(s) = length(track_replay_events(s).T4.T4_times); % RT2 events during RT2
        FINAL_RT1_events(s) = rate_replay(3).P(ses).sprintf('FINAL_post_%s',rest_option).Rat_num_events{cnt,1}; % POST2 RT1 events within first 30min of sleep
        FINAL_RT2_events(s) = rate_replay(4).P(ses).sprintf('FINAL_post_%s',rest_option).Rat_num_events{cnt,1}; % POST2 RT1 events within first 30min of sleep
        %FINAL_RT1_events(s) = length(track_replay_events(s).T3.FINAL_post_merged_cumulative_times); % POST2 RT1 events within first 30min of sleep
        %FINAL_RT2_events(s) = length(track_replay_events(s).T4.FINAL_post_merged_cumulative_times); % POST2 RT1 events within first 30min of sleep
    else
        % POST 1 - ABSOLUTE NUMBER OF EVENTS
        awake_local_replay_T1(s) = length(track_replay_events_F.track_replay_events(s).T1.T1_times); % T1 events during T1
        awake_local_replay_T2(s) = length(track_replay_events_F.track_replay_events(s).T2.T2_times); % T2 events during T2
        INTER_T1_events(s) = rate_replay(1).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_num_events{cnt,1}; % POST1 T1 events within first 30min of sleep
        INTER_T2_events(s) = rate_replay(2).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_num_events{cnt,1}; % POST1 T1 events within first 30min of sleep
        
        % POST 1 - RATE EVENTS (local)
%         awake_rate_replay_T1(s) = protocol(ses).T1(1).Rat_average_LOCAL_replay_rate(1,cnt); % T1 rate events during T1
%         awake_rate_replay_T2(s) = protocol(ses).T2(1).Rat_average_LOCAL_replay_rate(1,cnt); % T2 rate events during T2
        awake_rate_replay_T1(s) = awake_local_replay_T1(s)/(60*time_immobile(old_sess_index,1)); % T1 rate events during T1
        awake_rate_replay_T2(s) = awake_local_replay_T2(s)/(60*time_immobile(old_sess_index,2)); % T2 rate events during T2
        INTER_T1_rate_events(s) = rate_replay(1).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,1}; % POST1 T1 rate events within first 30min of sleep
        INTER_T2_rate_events(s) = rate_replay(2).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,1}; % POST1 T1 rate events within first 30min of sleep

        % POST 2 - ABSOLUTE NUMBER OF EVENTS
        awake_local_replay_RT1(s) = length(track_replay_events_R.track_replay_events(s).T1.T3_times); % RT1 events during RT1
        awake_local_replay_RT2(s) = length(track_replay_events_R.track_replay_events(s).T2.T4_times); % RT2 events during RT2
        FINAL_RT1_events(s) = rate_replay(1).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_num_events{cnt,1}; % POST2 RT1 events within first 30min of sleep
        FINAL_RT2_events(s) = rate_replay(2).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_num_events{cnt,1}; % POST2 RT1 events within first 30min of sleep
        %FINAL_RT1_events(s) = length(track_replay_events(s).T1.FINAL_post_merged_cumulative_times); % POST2 RT1 events within first 30min of sleep
        %FINAL_RT2_events(s) = length(track_replay_events(s).T2.FINAL_post_merged_cumulative_times); % POST2 RT1 events within first 30min of sleep

        % POST 2 - RATE EVENTS (local)
        awake_rate_replay_RT1(s) = awake_local_replay_RT1(s)/(60*time_immobile(old_sess_index,3)); % RT1 rate events during RT1 (by time immobile)
        awake_rate_replay_RT2(s) = awake_local_replay_RT2(s)/(60*time_immobile(old_sess_index,4)); % RT2 rate events during RT2 (by time immobile)
        FINAL_RT1_rate_events(s) = rate_replay(1).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_replay_rate{cnt,1}; % POST2 RT1 rate events within first 30min of sleep
        FINAL_RT2_rate_events(s) = rate_replay(2).P(ses).(sprintf('FINAL_post_%s',rest_option)).Rat_replay_rate{cnt,1}; % POST2 RT1 rate events within first 30min of sleep


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




%% Theta sequence wcorr and p value against number of laps
nfig = figure('Color','w')
nfig.Position = [940 130 920 820];

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


%% Theta sequence number vs sleep replay rate
nfig = figure('Color','w')
nfig.Position = [940 130 920 820];

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
ylim([0 0.09])
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
ylim([0 0.09])
title(sprintf('Theta cycles number vs sleep replay first exposure (%s)',rest_option));
title(sprintf('Number of theta cycles vs POST replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',awake_theta_pval,awake_theta_R2),'Units','Normalized','FontName','Arial');
axis square

%% Colinearlity between theta number, awake replay number and rate
nfig = figure('Color','w')
nfig.Position = [940 100 920 900];

awake_rate = [awake_rate_replay_T1 awake_rate_replay_T2 awake_rate_replay_RT1 awake_rate_replay_RT2]';
awake_number = [awake_local_replay_T1 awake_local_replay_T2 awake_local_replay_RT1 awake_local_replay_RT2]';
awake_theta = [total_num_thetaseq(:,1)' total_num_thetaseq(:,2)' total_num_thetaseq(:,3)' total_num_thetaseq(:,4)'];

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
xlabel('Rate of awake replay rate')
ylabel('Number of awake replay number')
set(gca,'FontSize',14)
title(sprintf('Rate vs Number of awake replay (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
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
xlabel('Rate of awake replay rate')
ylabel('Number of theta sequecne')
set(gca,'FontSize',14)
title(sprintf('Replay rate vs theta sequence number (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
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
xlabel('Number of awake replay')
ylabel('Number of theta sequence')
set(gca,'FontSize',14)
title(sprintf('Replay number vs theta sequence number (%s)',rest_option));
f=get(gca,'Children');
% Mind that order is reversed
legend([f(end),f(end-19),f(end-19*2),f(end-19*3)],'RUN 1 Track 1','RUN 1 Track 2','RUN 2 Track 1','RUN 2 Track 2') %because f(1) and f(2) are lines
text(gca,.7,0.1,sprintf('p = %.2d & R2 = %.3f',pval,awake_rate_R2),'Units','Normalized','FontName','Arial');
axis square



%% Multiple linear regression (replay vs theta sequence)
awake_number = [];
awake_rate = [];
awake_theta = [];
sleep = [];
for n = 1:1000
    s = RandStream('mcg16807','Seed',n);
    awake_rate(:,n) = zscore([datasample(s,awake_rate_replay_T1,length(awake_rate_replay_T1))...
        datasample(s,awake_rate_replay_T2,length(awake_rate_replay_T2))...
        datasample(s,awake_rate_replay_RT1,length(awake_rate_replay_RT1))...
        datasample(s,awake_rate_replay_RT2,length(awake_rate_replay_RT2))]');
    
    awake_number(:,n) = zscore([datasample(s,awake_local_replay_T1,length(awake_local_replay_T1))...
        datasample(s,awake_local_replay_T2,length(awake_local_replay_T2))...
        datasample(s,awake_local_replay_RT1,length(awake_local_replay_RT1))...
        datasample(s,awake_local_replay_RT2,length(awake_local_replay_RT2))]');
    
    awake_theta(:,n) = zscore([datasample(s,total_num_thetaseq(:,1)',length(total_num_thetaseq(:,1)'))...
        datasample(s,total_num_thetaseq(:,2)',length(total_num_thetaseq(:,2)'))...
        datasample(s,total_num_thetaseq(:,3)',length(total_num_thetaseq(:,3)'))...
        datasample(s,total_num_thetaseq(:,4)',length(total_num_thetaseq(:,4)'))]');
    
    sleep(:,n) = zscore([datasample(s,INTER_T1_rate_events,length(INTER_T1_rate_events))...
        datasample(s,INTER_T2_rate_events,length(INTER_T2_rate_events))...
        datasample(s,FINAL_RT1_rate_events,length(FINAL_RT1_rate_events))...
        datasample(s,FINAL_RT2_rate_events,length(FINAL_RT2_rate_events))]');
end

new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];

% Multiple linear (all three)
parfor n = 1:1000
    awake = [awake_rate(:,n), awake_number(:,n), awake_theta(:,n)];
    mdl = fitlm(awake,sleep(:,n));
    [pval,F_stat,~] = coefTest(mdl);
    awake_R2(n) = mdl.Rsquared.Adjusted;
    awake_b(n,:) = mdl.Coefficients.Estimate';
end

% Remove theta sequence number
parfor n = 1:1000
    awake = [awake_rate(:,n), awake_number(:,n)];
    mdl = fitlm(awake,sleep(:,n));
    [pval,F_stat,~] = coefTest(mdl);
    theta_removed_R2(n) = mdl.Rsquared.Adjusted;
    theta_removed_b(n,:) = mdl.Coefficients.Estimate';
end

% Remove awake replay rate
for n = 1:1000
    awake = [awake_theta(:,n), awake_number(:,n)];
    mdl = fitlm(awake,sleep(:,n));
    [pval,F_stat,~] = coefTest(mdl);
    awake_rate_removed_R2(n) = mdl.Rsquared.Adjusted;
    awake_rate_removed_b(n,:) = mdl.Coefficients.Estimate';
end

% Remove awake replay number
parfor n = 1:1000
    awake = [awake_theta(:,n), awake_rate(:,n)];
    mdl = fitlm(awake,sleep(:,n));
    [pval,F_stat,~] = coefTest(mdl);
    awake_number_removed_R2(n) = mdl.Rsquared.Adjusted;
    awake_number_removed_b(n,:) = mdl.Coefficients.Estimate';
end

clear b
nfig = figure('Color','w')
nfig.Position = [940 100 920 900];

nexttile
hold on
x = [mean(awake_R2) mean(theta_removed_R2) mean(awake_rate_removed_R2) mean(awake_number_removed_R2)];
x_CI = [prctile(awake_R2,[2.5 97.5]); prctile(theta_removed_R2,[2.5 97.5]); prctile(awake_rate_removed_R2,[2.5 97.5]); prctile(awake_number_removed_R2,[2.5 97.5])];

for k = 1:4
    hold on
    b(k) = bar(k,x(k),'FaceAlpha',0.5)
    b(k).FaceColor  = PP1.T2(k,:);
    e(k) = errorbar(k,x(k),abs(x_CI(k,1)-x(k)),abs(x_CI(k,2)-x(k)),"MarkerSize",10);
    e(k).Color = PP1.T2(k,:);
end
xticks([1 2 3 4])
xticklabels({'All three','Theta number removed','Awake replay rate removed','Awake replay number removed'})
ylim([0 0.5])
ylabel('The amount of variance explained (R2)')

% nexttile
% hold on
% x = [awake_b(2:4)];
% for k = 1:3
%     b(k) = bar(k,x(k))
%     b(k).FaceColor  = PP1.T2(k,:);
% end
% xticks([1 2 3 4])
% xticklabels({'Theta number','Awake replay rate','Awake replay number'})
% % ylim([0 0.8])
% ylabel('The standardised coefficient')

% 
% % Theta sequence number
% awake = [zscore(awake_theta)];
% mdl = fitlm(awake,sleep);
% [pval,F_stat,~] = coefTest(mdl);
% theta_R2 = mdl.Rsquared.Adjusted;
% awake_R2 = mdl.Coefficients.Estimate';
% 
% % Awake replay number
% awake = [zscore(awake_number)];
% mdl = fitlm(awake,sleep);
% [pval,F_stat,~] = coefTest(mdl);
% awake_number_R2 = mdl.Rsquared.Adjusted;
% 
% % Awake replay rate
% awake = [zscore(awake_rate)];
% mdl = fitlm(awake,sleep);
% [pval,F_stat,~] = coefTest(mdl);
% awake_rate_R2 = mdl.Rsquared.Adjusted;
% awake_R2 = mdl.Coefficients.Estimate';
% 
% nexttile
% hold on
% x = [theta_R2 awake_rate_R2 awake_number_R2];
% 
% for k = 1:3
%     b(k) = bar(k,x(k))
%     b(k).FaceColor  = PP1.T2(k,:);
% end
% 
% xticks([1 2 3])
% xticklabels({'Theta number alone','Awake replay rate alone','Awake replay number alone'})
% ylim([0 0.8])
% ylabel('The amount of variance explained (R2)')
% nexttile

%% Multiple linear regression just theta number and replay
new_cls = [repmat(PP.RUN1T1,19,1);repmat(PP.RUN1T2,19,1);repmat(PP.RUN2T1,19,1);repmat(PP.RUN2T2,19,1)];

clear b
% nfig = figure('Color','w')
% nfig.Position = [940 100 920 900];

nexttile
hold on
% Multiple linear (theta vs replay rate)
x = [mean(awake_R2) mean(theta_removed_R2) mean(awake_rate_removed_R2) mean(awake_number_removed_R2)];
awake_rate_theta_R2 = awake_number_removed_R2;

% awake replay rate
for n = 1:1000
    awake = [awake_rate(:,n)];
    mdl = fitlm(awake,sleep(:,n));
    [pval,F_stat,~] = coefTest(mdl);
    awake_rate_R2(n) = mdl.Rsquared.Adjusted;
    awake_rate_b(n,:) = mdl.Coefficients.Estimate';
end

% awake theta number
for n = 1:1000
    awake = [awake_theta(:,n)];
    mdl = fitlm(awake,sleep(:,n));
    [pval,F_stat,~] = coefTest(mdl);
    awake_rate_R2(n) = mdl.Rsquared.Adjusted;
    awake_rate_b(n,:) = mdl.Coefficients.Estimate';
end

% awake theta
awake = [zscore(awake_rate)];
mdl = fitlm(awake,sleep);
[pval,F_stat,~] = coefTest(mdl);
awake_replay_R2 = mdl.Rsquared.Adjusted;


x = [awake_rate_theta_R2 awake_theta_R2 awake_replay_R2];

for k = 1:3
    b(k) = bar(k,x(k))
    b(k).FaceColor  = PP1.T2(k,:);
end
xticks([1 2 3])
xticklabels({'Replay + Theta','Awake replay rate removed','Theta number removed'})
ylim([0 0.8])
ylabel('The amount of variance explained (R2)')



nexttile
hold on
% Multiple linear (theta vs replay number)
awake = [zscore(awake_number),zscore(awake_theta)];
mdl = fitlm(awake,sleep);
[pval,F_stat,~] = coefTest(mdl);
awake_number_theta_R2 = mdl.Rsquared.Adjusted;
awake_b = mdl.Coefficients.Estimate';

% awake replay number
awake = [zscore(awake_number)];
mdl = fitlm(awake,sleep);
[pval,F_stat,~] = coefTest(mdl);
replay_number_R2 = mdl.Rsquared.Adjusted;

x = [awake_number_theta_R2 awake_theta_R2 replay_number_R2];

for k = 1:3
    b(k) = bar(k,x(k))
    b(k).FaceColor  = PP1.T2(k,:);
end
xticks([1 2 3])
xticklabels({'Replay + Theta','Awake replay number removed','Theta number removed'})
ylim([0 0.8])
ylabel('The amount of variance explained (R2)')



