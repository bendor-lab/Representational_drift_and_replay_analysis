function plot_awake_vs_post_replay_backup(bayesian_control)
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
    
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\population_vector_data_excl.mat')
    popvec = protocol;
    % AWAKE REPLAY
    load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\extracted_awake_replay_track_completelap_excl.mat']);
    % SLEEP REPLAY
%     load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_merged_replay_30min_excl.mat']); %info of sleep in time bins
    load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_merged_replay_60min_excl.mat']); %info of sleep in time bins    
%     load(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\rate_per_second_sleep_replay_30min_excl.mat']); %info of sleep in time bins 
    
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
%         awake_rate_replay_T1(s) = protocol(ses).T1(1).Rat_average_LOCAL_replay_rate(1,cnt); % T1 rate events during T1
%         awake_rate_replay_T2(s) = protocol(ses).T2(1).Rat_average_LOCAL_replay_rate(1,cnt); % T2 rate events during T2
        awake_rate_replay_T1(s) = awake_local_replay_T1(s)/(60*time_immobile(old_sess_index,1)); % T1 rate events during T1
        awake_rate_replay_T2(s) = awake_local_replay_T2(s)/(60*time_immobile(old_sess_index,2)); % T2 rate events during T2
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
        awake_rate_replay_RT1(s) = awake_local_replay_RT1(s)/(60*time_immobile(old_sess_index,3)); % RT1 rate events during RT1 (by time immobile)
        awake_rate_replay_RT2(s) = awake_local_replay_RT2(s)/(60*time_immobile(old_sess_index,4)); % RT2 rate events during RT2 (by time immobile)
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

PP =  plotting_parameters;
PP1.T1 = PP.T1;
PP1.T2 = PP.T2;

for n = 1:size(PP.T2,1)
    PP1.T2(6-n,:) = PP.T2(n,:);
end



%% Plot awake replay rate per track, all protocols together
[p,tbl,stats] = kruskalwallis([awake_rate_replay_T1' awake_rate_replay_T2' awake_rate_replay_RT1' awake_rate_replay_RT2'],[],'off')

if p < .05
    c = multcompare(stats);
end

[p2,~] = ranksum(awake_rate_replay_RT1, awake_rate_replay_RT2)

f11 = figure('Color','w','Name','Awake replay rates');
f11.Position = [450 180 800 660];

nexttile
grp = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
tst=[awake_rate_replay_T1 awake_rate_replay_T2 awake_rate_replay_RT1 awake_rate_replay_RT2]';

beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.T1;[0.6 0.6 0.6];PP.T1;[0.6 0.6 0.6]],'dot_size',2,'overlay_style','sd','corral_style','rand');
yticks([0:0.04:0.28])
xticks([1:4])
xticklabels({'T1','T2','RT1','RT2'})
ylabel('Rate of awake replay')
set(gca,'FontSize',14)
ylim([-0.02 0.28])
hold on
axis square
title('Awake replay rate (All sessions)')

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
set(gca,'FontSize',14)
ylim([-0.02 0.28])
axis square
title('Rate awake replay first exposure')

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
set(gca,'FontSize',14)
ylim([-0.02 0.28])
axis square
title('Rate awake replay re-exposure')

%% Number
% f11 = figure('Color','w','Name','Awake replay rates');
% grp = [ones(num_sess,1);ones(num_sess,1)*2;ones(num_sess,1)*3;ones(num_sess,1)*4];
% tst=[awake_rate_replay_T1 awake_rate_replay_T2 awake_rate_replay_RT1 awake_rate_replay_RT2]';
% 
% beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.T1;[0.6 0.6 0.6];PP.T1;[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci','corral_style','rand');
% yticks([0,0.04,0.08,0.12])
% xticks([1:4])
% xticklabels({'T1','T2','RT1','RT2'})
% ylabel('Rate of awake replay')
% set(gca,'FontSize',14)
% ylim([-0.02 0.14])
% 
% [p,tbl,stats] = kruskalwallis([awake_rate_replay_T1' awake_rate_replay_T2' awake_rate_replay_RT1' awake_rate_replay_RT2'],[],'off')
% 
% figure
% if p < .05
%     c = multcompare(stats);
% end
% 
% [p2,~] = ranksum(num_events_in_track(:,5),num_events_in_track(:,8))

%% Sleep vs awake replay

PP = plotting_parameters;
%mrks = repmat(PP.rat_markers,[1,5]);
cls = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[3,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];
mrks_size = repmat([100,86,86,96],[1,5]);

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

% %% Awake Rate vs Number
% 
% nfig = figure('Color','w')
% nfig.Position = [940 130 920 820];
% 
% % Awake replay rate vs sleep replay rate (all)
% awake_rate = [awake_rate_replay_T1 awake_rate_replay_T2 awake_rate_replay_RT1 awake_rate_replay_RT2];
% awake_number = [awake_local_replay_T1 awake_local_replay_T2 awake_local_replay_RT1 awake_local_replay_RT2];
% sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
% session_index = [[1:1:19];[20:1:38];[39:1:57];[58:1:76]];
% p_val_awake_sleep = [];
% R2 = [];
% for track = 1:4
%     new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
%     arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
% 
%     mdl = fitlm([awake_rate(session_index(track,:))' awake_number(session_index(track,:))'],sleep(session_index(track,:))');
%     [pval,~,~] = coefTest(mdl);
%     p_val_awake_sleep(track,1) = pval;
%     R2(track,1) = mdl.Rsquared.Adjusted;
%     
%     mdl_rate = fitlm(awake_rate(session_index(track,:))',sleep(session_index(track,:))');
%     [pval_rate,~,~] = coefTest(mdl_rate);
%     p_val_awake_sleep(track,2) = pval_rate;
%     R2(track,2) = mdl_rate.Rsquared.Adjusted;
%     
%     mdl_number = fitlm(awake_number(session_index(track,:))',sleep(session_index(track,:))');
%     [pval_number,~,~] = coefTest(mdl_number);
%     p_val_awake_sleep(track,3) = pval_number;
%     R2(track,3) = mdl_number.Rsquared.Adjusted;
% end
% 
% % Awake replay rate vs sleep replay rate (All)
% awake_rate = [awake_rate_replay_T1 awake_rate_replay_T2 awake_rate_replay_RT1 awake_rate_replay_RT2];
% awake_number = [awake_local_replay_T1 awake_local_replay_T2 awake_local_replay_RT1 awake_local_replay_RT2];
% sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
% % new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
% % arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
% hold on
% mdl = fitlm([awake_rate' awake_number'],sleep');
% [pval,~,~] = coefTest(mdl);
% pval
% mdl.Rsquared.Adjusted
% 
% mdl_rate = fitlm(awake_rate',sleep');
% [pval_rate,~,~] = coefTest(mdl_rate);
% pval_rate
% mdl_rate.Rsquared.Adjusted
% 
% mdl_number = fitlm(awake_number',sleep');
% [pval_number,~,~] = coefTest(mdl_number);
% pval_number
% mdl_number.Rsquared.Adjusted
% 


%% Awake replay rate vs Sleep replay rate
nfig = figure('Color','w')
nfig.Position = [940 130 920 820];

% Awake replay rate vs sleep replay rate (all)
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
xlabel('Awake replay rate')
ylabel('Sleep replay rate')
set(gca,'FontSize',14)
title('Awake vs Sleep replay')
ylim([0 0.06])
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
f=get(gca,'Children');
legend([f(3),f(22),f(41),f(60)],'First exposure Track 1','First exposure Track 2','Re-exposure Track 1','Re-exposure Track 2')

% Awake Track rate difference vs sleep track rate difference (all)
nexttile
hold on
awake = [diff_INTER_run_replay_RATE diff_FINAL_run_replay_RATE];
sleep = [diff_INTER_sleep_replay_RATE diff_FINAL_sleep_replay_RATE];
new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1)];
arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on
mdl = fitlm(awake',sleep');
[pval,~,~] = coefTest(mdl);
x =[min(awake) max(awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Awake replay rate difference')
ylabel('Sleep replay rate difference')
set(gca,'FontSize',14)
title('Awake vs Sleep replay')
% ylim([0 0.06])
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
f=get(gca,'Children');
legend([f(3),f(22)],'First exposure','Re-exposure')

nexttile


%% Awake replay rate vs sleep replay rate (First and Re-exposure separated)
% Awake replay rate vs sleep replay rate (First exposure)
nfig = figure('Color','w')
nfig.Position = [940 130 920 820];

nexttile
hold on
awake = [awake_rate_replay_T1 awake_rate_replay_T2];
sleep = [INTER_T1_rate_events INTER_T2_rate_events];
new_cls = [repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on
mdl = fitlm(awake',sleep');
[pval,~,~] = coefTest(mdl);
x =[min(awake) max(awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Awake replay rate')
ylabel('Sleep replay rate')
set(gca,'FontSize',14)
ylim([0 0.06])
title('Awake vs Sleep replay (First exposure)')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


nexttile
hold on
awake = [diff_INTER_run_replay_RATE];
sleep = [diff_INTER_sleep_replay_RATE];
new_cls = [repmat([PP.T1],19,1)];
arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on
mdl = fitlm(awake',sleep');
[pval,~,~] = coefTest(mdl);
x =[min(awake) max(awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Awake replay rate difference')
ylabel('Sleep replay rate difference')
set(gca,'FontSize',14)
title('Awake vs Sleep replay (First exposure)')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

% Second exposure
nexttile
hold on
awake = [awake_rate_replay_RT1 awake_rate_replay_RT2];
sleep = [FINAL_RT1_rate_events FINAL_RT2_rate_events];
new_cls = [repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on
mdl = fitlm(awake',sleep');
[pval,~,~] = coefTest(mdl);
x =[min(awake) max(awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Awake replay rate')
ylabel('Sleep replay rate')
set(gca,'FontSize',14)
ylim([0 0.06])
title('Awake vs Sleep replay (Re-exposure)')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
awake = [diff_FINAL_run_replay_RATE];
sleep = [diff_FINAL_sleep_replay_RATE];
new_cls = [repmat([0.4 0.4 0.4],19,1)];
arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on
mdl = fitlm(awake',sleep');
[pval,~,~] = coefTest(mdl);
x =[min(awake) max(awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Awake replay rate difference')
ylabel('Sleep replay rate difference')
set(gca,'FontSize',14)
title('Awake vs Sleep replay (Re-exposure)')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


%% PLOT individual correlations - RATE (POST1 T1 vs RUN1 T1, POST1 T2 vs RUN1 T2,POST2 T1 vs RUN2 T1,POST2 T2 vs RUN1 T2)
nfig = figure('Color','w')
nfig.Position = [940 130 920 820];

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
xlabel('Awake replay rate')
ylabel('Sleep replay rate')
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
xlabel('Awake replay rate')
ylabel('Sleep replay rate')
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
xlabel('Awake replay rate')
ylabel('Sleep replay rate')
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
xlabel('Awake replay rate')
ylabel('Sleep replay rate')
set(gca,'FontSize',14)
title('RT2-POST2')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


% POST1 vs POST2 
nfig = figure('Color','w')
nfig.Position = [940 130 920 820];

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
xlabel('POST1 Sleep replay rate')
ylabel('POST2 Sleep replay rate')
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
xlabel('POST1 Sleep replay rate')
ylabel('POST2 Sleep replay rate')
set(gca,'FontSize',14)
title('T2 across sleep sessions')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');




%% Awake replay number vs Sleep replay rate
nfig = figure('Color','w')
nfig.Position = [940 130 920 820];

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
xlabel('Number of awake replay')
ylabel('Rate of sleep replay')
set(gca,'FontSize',14)
title('Awake vs Sleep replay')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


% Awake replay track difference vs sleep replay track difference (all)
nexttile
hold on
awake = [diff_INTER_run_replay diff_FINAL_run_replay];
sleep = [diff_INTER_sleep_replay diff_FINAL_sleep_replay];
new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1)];
arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on
mdl = fitlm(awake',sleep');
[pval,~,~] = coefTest(mdl);
x =[min(awake) max(awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Awake replay number difference')
ylabel('Sleep replay number difference')
set(gca,'FontSize',14)
title('Awake vs Sleep replay')
% ylim([0 0.06])
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile

%% Awake replay number vs sleep replay rate
nfig = figure('Color','w')
nfig.Position = [940 130 920 820];

% first exposure
nexttile
hold on
awake = [awake_local_replay_T1 awake_local_replay_T2];
sleep = [INTER_T1_rate_events INTER_T2_rate_events];
new_cls = [repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on
mdl = fitlm(awake',sleep');
[pval,~,~] = coefTest(mdl);
x =[min(awake) max(awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Number of awake replay')
ylabel('Sleep replay rate')
set(gca,'FontSize',14)
title('Awake vs Sleep replay (First exposure)')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
awake = [diff_INTER_run_replay];
sleep = [diff_INTER_sleep_replay_RATE];
new_cls = [repmat([PP.T1],19,1)];
arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on
mdl = fitlm(awake',sleep');
[pval,~,~] = coefTest(mdl);
x =[min(awake) max(awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Awake replay difference')
ylabel('Sleep replay rate difference')
set(gca,'FontSize',14)
title('Awake vs Sleep replay (First exposure)')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


% Second exposure
nexttile
hold on
awake = [awake_local_replay_RT1 awake_local_replay_RT2];
sleep = [FINAL_RT1_rate_events FINAL_RT2_rate_events];
new_cls = [repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on
mdl = fitlm(awake',sleep');
[pval,~,~] = coefTest(mdl);
x =[min(awake) max(awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Number of replay')
ylabel('Sleep replay rate')
set(gca,'FontSize',14)
title('Awake vs Sleep replay (Re-exposure)')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


nexttile
hold on
awake = [diff_FINAL_run_replay];
sleep = [diff_FINAL_sleep_replay_RATE];
new_cls = [repmat([0.4 0.4 0.4],19,1)];
arrayfun(@(x) scatter(awake(x),sleep(x),86,new_cls(x,:),'filled','o'),1:length(sleep))
hold on
mdl = fitlm(awake',sleep');
[pval,~,~] = coefTest(mdl);
x =[min(awake) max(awake)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Awake replay difference')
ylabel('Sleep replay rate difference')
set(gca,'FontSize',14)
title('Awake vs Sleep replay (Re-exposure)')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');



%% PLOT individual regression (POST1 T1 vs RUN1 T1, POST1 T2 vs RUN1 T2,POST2 T1 vs RUN2 T1,POST2 T2 vs RUN1 T2)
fig2 = figure('Color','w','Name','Track correlations sleep-awake - Absolute numbers and Rate');
fig2.Position = [940 130 920 820];
tiledlayout('flow')

nexttile
hold on
arrayfun(@(x) scatter(awake_local_replay_T1(x),INTER_T1_rate_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(INTER_T1_rate_events))
hold on
mdl = fitlm(awake_local_replay_T1',INTER_T1_rate_events');
[pval,~,~] = coefTest(mdl);
x =[min(awake_local_replay_T1) max(awake_local_replay_T1)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Number of awake replay')
ylabel('Sleep replay rate')
set(gca,'FontSize',14)
title('T1-POST1')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(awake_local_replay_T2(x),INTER_T2_rate_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(INTER_T2_rate_events))
hold on
mdl = fitlm(awake_local_replay_T2',INTER_T2_rate_events');
[pval,~,~] = coefTest(mdl);
x =[min(awake_local_replay_T2) max(awake_local_replay_T2)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Number of awake replay')
ylabel('Sleep replay rate')
set(gca,'FontSize',14)
title('T2-POST1')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(awake_local_replay_RT1(x),FINAL_RT1_rate_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(FINAL_RT1_rate_events))
hold on
mdl = fitlm(awake_local_replay_RT1',FINAL_RT1_rate_events');
[pval,~,~] = coefTest(mdl);
x =[min(awake_local_replay_RT1) max(awake_local_replay_RT1)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Number of awake replay')
ylabel('Sleep replay rate')
set(gca,'FontSize',14)
title('RT1-POST2')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

nexttile
hold on
arrayfun(@(x) scatter(awake_local_replay_RT2(x),FINAL_RT2_rate_events(x),mrks_size(x),cls(x,:),'filled','o'),1:length(FINAL_RT2_rate_events))
hold on
mdl = fitlm(awake_local_replay_RT2',FINAL_RT2_rate_events');
[pval,~,~] = coefTest(mdl);
x =[min(awake_local_replay_RT2) max(awake_local_replay_RT2)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlabel('Number of awake replay')
ylabel('Sleep replay rate')
set(gca,'FontSize',14)
title('RT2-POST2')
text(gca,.7,0.1,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');


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

figure('Color','w')
nexttile
hold on
% sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
% new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
new_cls = [repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
arrayfun(@(x) scatter(pv_corr(x),awake(x),86,new_cls(x,:),'filled','o'),1:length(awake))
hold on

mdl = fitlm(pv_corr',awake');
[pval,~,~] = coefTest(mdl);
x =[min(pv_corr) max(pv_corr)];
b = mdl.Coefficients.Estimate';
y_est = polyval(fliplr(b),x);
plot(x,y_est,'k:')
xlim([0 1])
xlabel('PV correlation between exposures')
ylabel('RUN2 awake replay rate')
set(gca,'FontSize',14)
title('PV between exposures vs awake replay')
text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');

% s

%% Looking at place cell participation in replay
% place cells with place fields on both tracks and asked whether the
% difference in the number of awake replay events a given cell participated
% in predict the observed difference in sleep replay rates for that cell

num_sess = length(track_replay_events_F.track_replay_events);
folders = data_folders_excl;
cell_replay_RUN2 = [];
cell_replay_RUN2 = [];
cell_replay_POST1 = [];
cell_replay_POST2 = [];
track_difference_cell_RUN1 = [];
track_difference_cell_RUN2 = [];
track_difference_cell_POST1 = [];
track_difference_cell_POST2 = [];
time_chunk = 3600;%60 mins
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
        for event = find(track_replay_events(s).(sprintf('T%i',track)).INTER_post_merged_cumulative_times <=time_chunk)
            event_id = track_replay_events(s).(sprintf('T%i',track)).INTER_post_merged_index(event);
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
    track_difference_cell_POST1{s}(2,:) = (cell_replay_POST1{s}{1}(2,:) - cell_replay_POST1{s}{2}(2,:))./...
        (cell_replay_POST1{s}{1}(2,:) + cell_replay_POST1{s}{2}(2,:));
    
    track_difference_cell_RUN1{s}(1,:) = cell_replay_RUN1{s}{1}(1,:);
    track_difference_cell_RUN1{s}(2,:) = cell_replay_RUN1{s}{1}(2,:) - cell_replay_RUN1{s}{2}(2,:);
       
%     load([folders{s},'\Bayesian controls\Only re-exposure\extracted_place_fields_BAYESIAN.mat'])
    load([folders{s},'\Bayesian controls\Only first exposure\significant_replay_events_wcorr.mat']);
    load([folders{s},'\Bayesian controls\Only first exposure\extracted_place_fields_BAYESIAN.mat']);
    % Only use cells that have place fields on both tracks
    common_good_cells = intersect(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
    
    % Re-exposure
    for track = 1:2
        cell_id = [];
        % For each event find the cells that are active
        for event = find(track_replay_events(s).(sprintf('T%i',track)).FINAL_post_merged_cumulative_times <=time_chunk)
            event_id = track_replay_events(s).(sprintf('T%i',track)).FINAL_post_merged_index(event);
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
    track_difference_cell_POST2{s}(2,:) = (cell_replay_POST2{s}{1}(2,:) - cell_replay_POST2{s}{2}(2,:))./...
        (cell_replay_POST2{s}{1}(2,:) + cell_replay_POST2{s}{2}(2,:));
    
    track_difference_cell_RUN2{s}(1,:) = cell_replay_RUN2{s}{1}(1,:);
    track_difference_cell_RUN2{s}(2,:) = cell_replay_RUN2{s}{1}(2,:) - cell_replay_RUN2{s}{2}(2,:);
end



fig = figure('Color','w','Name','Awake replay vs Replay participation track difference (All)');
fig.Position = [720 260 860 700];
sgtitle('Awake replay vs Replay participation track difference (All)')
for s = 1 : num_sess
    nexttile
    hold on
    % sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    % new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
    awake = [track_difference_cell_RUN1{s}(2,:) track_difference_cell_RUN2{s}(2,:)]; % awake number difference
    sleep = [track_difference_cell_POST1{s}(2,:) track_difference_cell_POST2{s}(2,:)]; % sleep rate difference
    new_cls = cls(s,:);
    arrayfun(@(x) scatter(awake(x),sleep(x),20,new_cls,'filled','o'),1:length(awake))
    hold on
    
    mdl = fitlm(awake',sleep');
    [pval,~,~] = coefTest(mdl);
    x =[min(awake) max(awake)];
    b = mdl.Coefficients.Estimate';
    y_est = polyval(fliplr(b),x);
    
    plot(x,y_est,'k:')
    xlim([-150 150])
    xlabel('Replay track difference')
    ylabel('Awake replay rate')
    %     set(gca,'FontSize',14)
    title(sprintf('Session %i',s))
    %     text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial');
end



fig = figure('Color','w','Name','Awake replay vs Replay participation track difference (First exposure)');
fig.Position = [720 260 860 700];
for s = 1 : num_sess
    nexttile
    hold on
    % sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    % new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
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
    
    plot(x,y_est,'k:')
%     xlim([-100 100])
    xlabel('Replay track difference')
    ylabel('Sleep replay rate')
    %     set(gca,'FontSize',14)
    title(sprintf('Session %i',s))
    %     text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial');
end
sgtitle('Awake replay vs Replay participation track difference (First exposure)')



fig = figure('Color','w','Name','Awake replay vs Replay participation track difference (Re-exposure)');
fig.Position = [720 260 860 700];
sgtitle('Awake replay vs Replay participation track difference (All)')
for s = 1 : num_sess
    nexttile
    hold on
    % sleep = [INTER_T1_rate_events INTER_T2_rate_events FINAL_RT1_rate_events FINAL_RT2_rate_events];
    % new_cls = [repmat([PP.T1],19,1);repmat([0.4 0.4 0.4],19,1);repmat([.8 .4 1],19,1);repmat([.8 .8 .8],19,1)];
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
    
    plot(x,y_est,'k:')
%     xlim([-100 100])
    xlabel('Replay track difference')
    ylabel('Sleep replay rate')
    %     set(gca,'FontSize',14)
    title(sprintf('Session %i',s))
    %     text(gca,.7,0.5,['p = ' num2str(pval,2)],'Units','Normalized','FontSize',12,'FontName','Arial');
    text(gca,0.5,0.2,['p = ' num2str(pval,2)],'Units','Normalized','FontName','Arial');
end
sgtitle('Awake replay vs Replay participation track difference (Re-exposure)')

end