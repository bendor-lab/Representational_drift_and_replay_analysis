
function compare_run_sleep_replay(bayesian_control)
% MH 2022
% Runs correlations and linear regression comparing awake replay on track with the subsequent sleep session. Compares it usimg both absolute number
% of events and rate of events. Comparisons are run within track (e.g. awake replay on T1 vs POST1 T1 sleep replay) and using track differences
% (e.g. awake replay T1-T2 vs POST1 sleep replay T1-T2).
% Plots scatter with regression p-value

if ~isempty(bayesian_control)
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only first exposure';
    path2 = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only re-exposure';
    track_replay_events_F = load([path '\extracted_replay_plotting_info_excl.mat']);
    track_replay_events_R = load([path2 '\extracted_replay_plotting_info_excl.mat']);
    % AWAKE REPLAY
    load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\\extracted_awake_replay_track_completelap_excl.mat']);
    % SLEEP REPLAY
    load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_merged_replay_30min_excl.mat']); %info of sleep in time bins
    num_sess = length(track_replay_events_R.track_replay_events);

else
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
    load([path '\extracted_replay_plotting_info_excl.mat'])
    load([path '\rate_merged_replay.mat']) %info of sleep in time bins
    load([path '\extracted_awake_replay_track_completelap_excl.mat'])
    num_sess = length(track_replay_events);

end


cnt = 1;
ses = 1;
%% for each session
for s = 1 : num_sess

    if isempty(bayesian_control)
        awake_local_replay_RT1(s) = length(track_replay_events(s).T3.T3_times); % RT1 events during RT1
        awake_local_replay_RT2(s) = length(track_replay_events(s).T4.T4_times); % RT2 events during RT2
        FINAL_RT1_events(s) = rate_replay(3).P(ses).FINAL_post_merged.Rat_num_events{cnt,1}; % POST2 RT1 events within first 30min of sleep
        FINAL_RT2_events(s) = rate_replay(4).P(ses).FINAL_post_merged.Rat_num_events{cnt,1}; % POST2 RT1 events within first 30min of sleep
        %FINAL_RT1_events(s) = length(track_replay_events(s).T3.FINAL_post_merged_cumulative_times); % POST2 RT1 events within first 30min of sleep
        %FINAL_RT2_events(s) = length(track_replay_events(s).T4.FINAL_post_merged_cumulative_times); % POST2 RT1 events within first 30min of sleep
    else
        % POST 1 - ABSOLUTE NUMBER OF EVENTS
        awake_local_replay_T1(s) = length(track_replay_events_F.track_replay_events(s).T1.T1_times); % T1 events during T1
        awake_local_replay_T2(s) = length(track_replay_events_F.track_replay_events(s).T2.T2_times); % T2 events during T2
        INTER_T1_events(s) = rate_replay(1).P(ses).INTER_post_merged.Rat_num_events{cnt,1}; % POST1 T1 events within first 30min of sleep
        INTER_T2_events(s) = rate_replay(2).P(ses).INTER_post_merged.Rat_num_events{cnt,1}; % POST1 T1 events within first 30min of sleep
        
        % POST 1 - RATE EVENTS (local)
        awake_rate_replay_T1(s) = protocol(ses).T1(1).Rat_average_LOCAL_replay_rate(1,cnt); % T1 rate events during T1
        awake_rate_replay_T2(s) = protocol(ses).T2(1).Rat_average_LOCAL_replay_rate(1,cnt); % T2 rate events during T2
        INTER_T1_rate_events(s) = rate_replay(1).P(ses).INTER_post_merged.Rat_replay_rate{cnt,1}; % POST1 T1 rate events within first 30min of sleep
        INTER_T2_rate_events(s) = rate_replay(2).P(ses).INTER_post_merged.Rat_replay_rate{cnt,1}; % POST1 T1 rate events within first 30min of sleep

        % POST 2 - ABSOLUTE NUMBER OF EVENTS
        awake_local_replay_RT1(s) = length(track_replay_events_R.track_replay_events(s).T1.T3_times); % RT1 events during RT1
        awake_local_replay_RT2(s) = length(track_replay_events_R.track_replay_events(s).T2.T4_times); % RT2 events during RT2
        FINAL_RT1_events(s) = rate_replay(1).P(ses).FINAL_post_merged.Rat_num_events{cnt,1}; % POST2 RT1 events within first 30min of sleep
        FINAL_RT2_events(s) = rate_replay(2).P(ses).FINAL_post_merged.Rat_num_events{cnt,1}; % POST2 RT1 events within first 30min of sleep
        %FINAL_RT1_events(s) = length(track_replay_events(s).T1.FINAL_post_merged_cumulative_times); % POST2 RT1 events within first 30min of sleep
        %FINAL_RT2_events(s) = length(track_replay_events(s).T2.FINAL_post_merged_cumulative_times); % POST2 RT1 events within first 30min of sleep

        % POST 2 - RATE EVENTS (local)
        awake_rate_replay_RT1(s) = protocol(ses).T3(1).Rat_average_LOCAL_replay_rate(1,cnt); % RT1 rate events during RT1
        awake_rate_replay_RT2(s) = protocol(ses).T4(1).Rat_average_LOCAL_replay_rate(1,cnt); % RT2 rate events during RT2
        FINAL_RT1_rate_events(s) = rate_replay(1).P(ses).FINAL_post_merged.Rat_replay_rate{cnt,1}; % POST2 RT1 rate events within first 30min of sleep
        FINAL_RT2_rate_events(s) = rate_replay(2).P(ses).FINAL_post_merged.Rat_replay_rate{cnt,1}; % POST2 RT1 rate events within first 30min of sleep


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

% Look at relationship between 1st Exposure Awake replay and POST 1 replay
% difference between tracks
diff_INTER_run_replay = (awake_local_replay_T1 - awake_local_replay_T2)./(awake_local_replay_T1 + awake_local_replay_T2);
diff_INTER_sleep_replay = (INTER_T1_events - INTER_T2_events)./(INTER_T1_events + INTER_T2_events);
[POST1_corr,POST1_p] = corr(diff_INTER_run_replay',diff_INTER_sleep_replay');
POST1_mdl = fitlm(diff_INTER_run_replay',diff_INTER_sleep_replay');
[POST1_pval,POST1_F,~] = coefTest(POST1_mdl);
x1 =[min(diff_INTER_run_replay) max(diff_INTER_run_replay)];
b1 = POST1_mdl.Coefficients.Estimate';
y_est1 = polyval(fliplr(b1),x1);
slope(1) = b1(2);
intercept(1) = b1(1);

% Look at relationship between Re-Exposure Awake replay and POST 2 replay
% difference between tracks
diff_FINAL_run_replay = (awake_local_replay_RT1 - awake_local_replay_RT2)./(awake_local_replay_RT1 + awake_local_replay_RT2);
diff_FINAL_sleep_replay = (FINAL_RT1_events - FINAL_RT2_events)./(FINAL_RT1_events + FINAL_RT2_events);
[POST2_corr,POST2_p] = corr(diff_FINAL_run_replay',diff_FINAL_sleep_replay');
POST2_mdl = fitlm(diff_FINAL_run_replay',diff_FINAL_sleep_replay');
[POST2_pval,POST2_F,~] = coefTest(POST2_mdl);
x2 =[min(diff_FINAL_run_replay) max(diff_FINAL_run_replay)];
b2 = POST2_mdl.Coefficients.Estimate';
y_est2 = polyval(fliplr(b2),x2);
slope(2) = b2(2);
intercept(2) = b2(1);

% RATE - Look at relationship between 1st Exposure Awake replay and POST 1 replay
% difference between tracks
diff_INTER_run_replay_RATE = (awake_rate_replay_T1 - awake_rate_replay_T2)./(awake_rate_replay_T1 + awake_rate_replay_T2);
diff_INTER_sleep_replay_RATE = (INTER_T1_rate_events - INTER_T2_rate_events)./(INTER_T1_rate_events + INTER_T2_rate_events);
[POST1_corrR,POST1_pR] = corr(diff_INTER_run_replay_RATE',diff_INTER_sleep_replay_RATE');
POST1_mdlR = fitlm(diff_INTER_run_replay_RATE',diff_INTER_sleep_replay_RATE');
[POST1_pvalR,POST1_FR,~] = coefTest(POST1_mdlR);
x1R =[min(diff_INTER_run_replay_RATE) max(diff_INTER_run_replay_RATE)];
b1R = POST1_mdlR.Coefficients.Estimate';
y_est1R = polyval(fliplr(b1R),x1R);
slope(3) = b1R(2);
intercept(3) = b1R(1);

% RATE - Look at relationship between Re-Exposure Awake replay and POST 2 replay
% difference between tracks
diff_FINAL_run_replay_RATE = (awake_rate_replay_RT1 - awake_rate_replay_RT2)./(awake_rate_replay_RT1 + awake_rate_replay_RT2);
diff_FINAL_sleep_replay_RATE = (FINAL_RT1_rate_events - FINAL_RT2_rate_events)./(FINAL_RT1_rate_events + FINAL_RT2_rate_events);
[POST2_corrR,POST2_pR] = corr(diff_FINAL_run_replay_RATE',diff_FINAL_sleep_replay_RATE');
POST2_mdlR = fitlm(diff_FINAL_run_replay_RATE',diff_FINAL_sleep_replay_RATE');
[POST2_pvalR,POST2_FR,~] = coefTest(POST2_mdlR);
x2R =[min(diff_FINAL_run_replay_RATE) max(diff_FINAL_run_replay_RATE)];
b2R = POST2_mdlR.Coefficients.Estimate';
y_est2R = polyval(fliplr(b2R),x2R);
slope(4) = b2R(2);
intercept(4) = b2R(1);


%%
PP = plotting_parameters;
%mrks = repmat(PP.rat_markers,[1,5]);
cls = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[3,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];
mrks_size = repmat([100,86,86,96],[1,5]);

figure('Color','w','Name','Correlations replay sleep-awake - Absolute numbers and Rate');
tiledlayout('flow')
nexttile
hold on
arrayfun(@(x) scatter(diff_INTER_run_replay(x),diff_INTER_sleep_replay(x),mrks_size(x),cls(x,:),'filled','o'),1:length(diff_INTER_sleep_replay))
hold on
plot(x1,y_est1,'k:')
xlabel('Diff in T awake replay')
ylabel('Diff in POST1 sleep replay')
set(gca,'FontSize',14)
if isempty(bayesian_control)
    title('Main data set')
else
    title('POST1')
end
text(gca,.7,0.1,['p = ' num2str(POST1_pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(diff_FINAL_run_replay(x),diff_FINAL_sleep_replay(x),mrks_size(x),cls(x,:),'filled','o'),1:length(diff_FINAL_sleep_replay))
hold on
plot(x2,y_est2,'k:')
xlabel('Diff in RT awake replay')
ylabel('Diff in POST2 sleep replay')
set(gca,'FontSize',14)
title('POST2')
text(gca,.7,0.1,['p = ' num2str(POST2_pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


nexttile
hold on
arrayfun(@(x) scatter(diff_INTER_run_replay_RATE(x),diff_INTER_sleep_replay_RATE(x),mrks_size(x),cls(x,:),'filled','o'),1:length(diff_INTER_sleep_replay_RATE))
hold on
plot(x1R,y_est1R,'k:')
xlabel('Rate diff in T awake replay')
ylabel('Rate diff in POST1 sleep replay')
set(gca,'FontSize',14)
title('POST1')
text(gca,.7,0.1,['p = ' num2str(POST1_pvalR,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


nexttile
hold on
arrayfun(@(x) scatter(diff_FINAL_run_replay_RATE(x),diff_FINAL_sleep_replay_RATE(x),mrks_size(x),cls(x,:),'filled','o'),1:length(diff_FINAL_sleep_replay_RATE))
hold on
plot(x2R,y_est2R,'k:')
xlabel('Rate diff in RT awake replay')
ylabel('Rate diff in POST2 sleep replay')
set(gca,'FontSize',14)
title('POST2')
text(gca,.7,0.1,['p = ' num2str(POST2_pvalR,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


%% PLOT individual correlations
fig2 = figure('Color','w','Name','Track correlations sleep-awake - Absolute numbers and Rate');
tiledlayout('flow')

nexttile
hold on
arrayfun(@(x) scatter(awake_local_replay_T1(x),INTER_T1_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(INTER_T1_events))
hold on
mdl = fitlm(awake_local_replay_T1',INTER_T1_events');
[pval,~,~] = coefTest(mdl);
x =[min(awake_local_replay_T1) max(awake_local_replay_T1)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('T1 awake replay')
ylabel('POST1 T1 sleep replay')
set(gca,'FontSize',14)
title('T1-POST1')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(awake_local_replay_T2(x),INTER_T2_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(INTER_T2_events))
hold on
mdl = fitlm(awake_local_replay_T2',INTER_T2_events');
[pval,~,~] = coefTest(mdl);
x =[min(awake_local_replay_T2) max(awake_local_replay_T2)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('T2 awake replay')
ylabel('POST1 T2 sleep replay')
set(gca,'FontSize',14)
title('T2-POST1')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(awake_local_replay_RT1(x),FINAL_RT1_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(FINAL_RT1_events))
hold on
mdl = fitlm(awake_local_replay_RT1',FINAL_RT1_events');
[pval,~,~] = coefTest(mdl);
x =[min(awake_local_replay_RT1) max(awake_local_replay_RT1)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('RT1 awake replay')
ylabel('POST2 RT1 sleep replay')
set(gca,'FontSize',14)
title('RT1-POST2')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(awake_local_replay_RT2(x),FINAL_RT2_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(FINAL_RT2_events))
hold on
mdl = fitlm(awake_local_replay_RT2',FINAL_RT2_events');
[pval,~,~] = coefTest(mdl);
x =[min(awake_local_replay_RT2) max(awake_local_replay_RT2)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('RT2 awake replay')
ylabel('POST2 RT2 sleep replay')
set(gca,'FontSize',14)
title('RT2-POST2')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


%% PLOT individual correlations - RATE
nexttile
hold on
arrayfun(@(x) scatter(awake_rate_replay_T1(x),INTER_T1_rate_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(INTER_T1_rate_events))
hold on
mdl = fitlm(awake_rate_replay_T1',INTER_T1_rate_events');
[pval,~,~] = coefTest(mdl);
x =[min(awake_rate_replay_T1) max(awake_rate_replay_T1)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('T1 awake rate replay')
ylabel('POST1 T1 sleep rate replay')
set(gca,'FontSize',14)
title('T1-POST1')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(awake_rate_replay_T2(x),INTER_T2_rate_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(INTER_T2_rate_events))
hold on
mdl = fitlm(awake_rate_replay_T2',INTER_T2_rate_events');
[pval,~,~] = coefTest(mdl);
x =[min(awake_rate_replay_T2) max(awake_rate_replay_T2)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('T2 awake rate replay')
ylabel('POST2 T2 sleep rate replay')
set(gca,'FontSize',14)
title('T2-POST1')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(awake_rate_replay_RT1(x),FINAL_RT1_rate_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(FINAL_RT1_rate_events))
hold on
mdl = fitlm(awake_rate_replay_RT1',FINAL_RT1_rate_events');
[pval,~,~] = coefTest(mdl);
x =[min(awake_rate_replay_RT1) max(awake_rate_replay_RT1)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('RT1 awake rate replay')
ylabel('POST2 RT1 sleep rate replay')
set(gca,'FontSize',14)
title('RT1-POST2')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(awake_rate_replay_RT2(x),FINAL_RT2_rate_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(FINAL_RT2_rate_events))
hold on
mdl = fitlm(awake_rate_replay_RT2',FINAL_RT2_rate_events');
[pval,~,~] = coefTest(mdl);
x =[min(awake_rate_replay_RT2) max(awake_rate_replay_RT2)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('RT2 awake rate replay')
ylabel('POST2 RT2 sleep rate replay')
set(gca,'FontSize',14)
title('RT2-POST2')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');




nexttile
hold on
arrayfun(@(x) scatter(INTER_T1_rate_events(x),FINAL_RT1_rate_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(FINAL_RT1_rate_events))
hold on
mdl = fitlm(INTER_T1_rate_events',FINAL_RT1_rate_events');
[pval,~,~] = coefTest(mdl);
x =[min(INTER_T1_rate_events) max(INTER_T1_rate_events)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('POST1 T1 sleep rate replay')
ylabel('POST2 RT1 sleep rate replay')
set(gca,'FontSize',14)
title('T1 across sleep sessions')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


nexttile
hold on
arrayfun(@(x) scatter(INTER_T2_rate_events(x),FINAL_RT2_rate_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(FINAL_RT2_rate_events))
hold on
mdl = fitlm(INTER_T2_rate_events',FINAL_RT2_rate_events');
[pval,~,~] = coefTest(mdl);
x =[min(INTER_T2_rate_events) max(INTER_T2_rate_events)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('POST1 T2 sleep rate replay')
ylabel('POST2 RT2 sleep rate replay')
set(gca,'FontSize',14)
title('T2 across sleep sessions')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


%%
%%% FIGURE CORRELATIONS CONTROLS - POST1 sleep influence in Re-exposure awake replay and POST2 sleep replay
figure('Color','w','Name','Regressions sleep vs awake replay after first exposure')
tiledlayout('flow')
nexttile
hold on
arrayfun(@(x) scatter(INTER_T1_rate_events(x),awake_rate_replay_RT1(x),mrks_size(x),cls(x,:),'filled','o'),1:length(awake_rate_replay_RT1))
hold on
mdl = fitlm(INTER_T1_rate_events',awake_rate_replay_RT1');
[pval,~,~] = coefTest(mdl);
x =[min(INTER_T1_rate_events) max(INTER_T1_rate_events)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('POST1 T1 sleep rate replay')
ylabel('RT1 awake rate replay')
set(gca,'FontSize',14)
title('POST1 T1 vs RT1')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(INTER_T2_rate_events(x),awake_rate_replay_RT2(x),mrks_size(x),cls(x,:),'filled','o'),1:length(awake_rate_replay_RT2))
hold on
mdl = fitlm(INTER_T2_rate_events',awake_rate_replay_RT2');
[pval,~,~] = coefTest(mdl);
x =[min(INTER_T2_rate_events) max(INTER_T2_rate_events)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('POST1 T2 sleep rate replay')
ylabel('RT2 awake rate replay')
set(gca,'FontSize',14)
title('POST1 T2 vs RT2')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


nexttile
hold on
arrayfun(@(x) scatter(diff_INTER_sleep_replay_RATE(x),awake_rate_replay_RT1(x),mrks_size(x),cls(x,:),'filled','o'),1:length(awake_rate_replay_RT1))
hold on
mdl = fitlm(diff_INTER_sleep_replay_RATE',awake_rate_replay_RT1');
[pval,~,~] = coefTest(mdl);
x =[min(diff_INTER_sleep_replay_RATE) max(diff_INTER_sleep_replay_RATE)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('diff POST1 sleep rate replay')
ylabel('RT1 awake rate replay')
set(gca,'FontSize',14)
title('diff POST1 vs RT1')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(diff_INTER_sleep_replay_RATE(x),awake_rate_replay_RT2(x),mrks_size(x),cls(x,:),'filled','o'),1:length(awake_rate_replay_RT2))
hold on
mdl = fitlm(diff_INTER_sleep_replay_RATE',awake_rate_replay_RT2');
[pval,~,~] = coefTest(mdl);
x =[min(diff_INTER_sleep_replay_RATE) max(diff_INTER_sleep_replay_RATE)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('diff POST1 sleep rate replay')
ylabel('RT2 awake rate replay')
set(gca,'FontSize',14)
title('diff POST1 vs RT2')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(diff_INTER_sleep_replay_RATE(x),diff_FINAL_run_replay_RATE(x),mrks_size(x),cls(x,:),'filled','o'),1:length(diff_FINAL_run_replay_RATE))
hold on
mdl = fitlm(diff_INTER_run_replay_RATE',diff_FINAL_run_replay_RATE');
[pval,~,~] = coefTest(mdl);
x =[min(diff_INTER_run_replay_RATE) max(diff_INTER_run_replay_RATE)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('diff POST1 sleep rate replay')
ylabel('diff re-exp awake rate replay')
set(gca,'FontSize',14)
title('diff POST1 vs diff REXP')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


nexttile
hold on
arrayfun(@(x) scatter(diff_INTER_sleep_replay_RATE(x),diff_FINAL_sleep_replay_RATE(x),mrks_size(x),cls(x,:),'filled','o'),1:length(diff_FINAL_sleep_replay_RATE))
hold on
mdl = fitlm(diff_INTER_run_replay_RATE',diff_FINAL_sleep_replay_RATE');
[pval,~,~] = coefTest(mdl);
x =[min(diff_INTER_run_replay_RATE) max(diff_INTER_run_replay_RATE)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('diff POST1 sleep rate replay')
ylabel('diff POST2 sleep rate replay')
set(gca,'FontSize',14)
title('diff POST1 vs diff POST2')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure('Color','w')
nexttile
idx = find(awake_rate_replay_RT1 > 0.01);
idxed_awake = awake_rate_replay_RT1(idx);
idxed_FINAL = FINAL_RT1_rate_events(idx);
idex_cls = cls(idx,:);
hold on
arrayfun(@(x) scatter(idxed_awake(x),idxed_FINAL(x),mrks_size(x),idex_cls(x,:),'filled','o'),1:length(idxed_FINAL))
hold on
mdl = fitlm(idxed_awake',idxed_FINAL');
[pval,~,~] = coefTest(mdl);
x =[min(idxed_awake) max(idxed_awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('RT1 awake rate replay')
ylabel('POST2 RT1 sleep rate replay')
set(gca,'FontSize',14)
title(['RT1-POST2 - Threshold (events/min):' num2str(0.01)])
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

figure
nexttile
hold on
inter = [INTER_T1_rate_events INTER_T2_rate_events];
final = [FINAL_RT1_rate_events FINAL_RT2_rate_events];
new_cls = [repmat([PP.T1],19,1);repmat([.6 .6 .6],19,1)]; 
arrayfun(@(x) scatter(inter(x),final(x),86,new_cls(x,:),'filled','o'),1:length(final))
hold on
mdl = fitlm(inter',final');
[pval,~,~] = coefTest(mdl);
x =[min(inter) max(inter)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('T1&T2 POST1 sleep rate replay')
ylabel('RT1&TR2 POST2 sleep rate replay')
set(gca,'FontSize',14)
title('T2 across sleep sessions')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

figure('Color','w')
nexttile
hold on
awake = [awake_rate_replay_T1 awake_rate_replay_T2 awake_rate_replay_RT1 awake_rate_replay_RT2];
sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on
mdl = fitlm(awake',sleep');
[pval,~,~] = coefTest(mdl);
x =[min(awake) max(awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('awake rate replay')
ylabel('sleep rate replay')
set(gca,'FontSize',14)
title('Awake vs Sleep replay')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');



figure('Color','w')
nexttile
hold on
awake = [awake_local_replay_T1 awake_local_replay_T2 awake_local_replay_RT1 awake_local_replay_RT2];
sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on
mdl = fitlm(awake',sleep');
[pval,~,~] = coefTest(mdl);
x =[min(awake) max(awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('awake number of replay')
ylabel('sleep rate replay')
set(gca,'FontSize',14)
title('Awake vs Sleep replay')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');



end