% Compare real to control data and quantify number of replay events in T1 and T2

function comparison_to_control_replay(control_type)
%control_type: 'Short_exposures' or 'Stability'

cd(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\' control_type '_control_FIRST_laps\'])
load extracted_replay_plotting_info_MultiEvents.mat
control_data_FIRST_laps = track_replay_events;
clear track_replay_events
cd(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\' control_type '_control_LAST_laps\'])
load extracted_replay_plotting_info_MultiEvents.mat
control_data_last_laps = track_replay_events;
clear track_replay_events
cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis')
load extracted_replay_plotting_info_MultiEvents.mat

PP = plotting_parameters;

% Find indices for each type of protocol
t2 = [];
for s = 1 : length(track_replay_events)
    name = cell2mat(track_replay_events(s).session(1));
    if strfind(name,'Ctrl')
        t2 = [t2 str2num(name(end-1:end))];
    else
        t2 = [t2 str2num(name(end))];
    end
end
protocols = unique(t2,'stable');

f1 = figure;
f1.Name = 'Cntrl  vs Real - Number of INTER events per rat and protocol';
c = 1;
for p = 1 : length(protocols)
    prot_idxs = find(t2 == protocols(p));
    REAL_T1_T2_INTER_sleep_events = [];     CONTROL_FIRST_T1_T2_INTER_sleep_events = [];   CONTROL_LAST_T1_T2_INTER_sleep_events = [];
    REAL_T1_T2_INTER_awake_events = [];     CONTROL_FIRST_T1_T2_INTER_awake_events = [];   CONTROL_LAST_T1_T2_INTER_awake_events = [];
    REAL_T1_T2_ALL_INTER_events = [];       CONTROL_FIRST_T1_T2_ALL_INTER_events = [];     CONTROL_LAST_T1_T2_ALL_INTER_events = [];
    for s = 1 : length(prot_idxs)
        % Number of INTER sleep events for T1 and T2
        REAL_T1_T2_INTER_sleep_events = [REAL_T1_T2_INTER_sleep_events; length(track_replay_events(prot_idxs(s)).T1.INTER_post_sleep_times)...
            length(track_replay_events(prot_idxs(s)).T2.INTER_post_sleep_times)];
        % Number of INTER awake events for T1 and T2
        REAL_T1_T2_INTER_awake_events = [REAL_T1_T2_INTER_awake_events; length(track_replay_events(prot_idxs(s)).T1.INTER_post_awake_times)...
            length(track_replay_events(prot_idxs(s)).T2.INTER_post_awake_times)];        

        % Number of INTER sleep & awake events for T1 and T2 CONTROL FIRST LAPS
        CONTROL_FIRST_T1_T2_INTER_sleep_events = [CONTROL_FIRST_T1_T2_INTER_sleep_events; length(control_data_FIRST_laps(prot_idxs(s)).T1.INTER_post_sleep_times)...
            length(control_data_FIRST_laps(prot_idxs(s)).T2.INTER_post_sleep_times)];
        CONTROL_FIRST_T1_T2_INTER_awake_events = [CONTROL_FIRST_T1_T2_INTER_awake_events; length(control_data_FIRST_laps(prot_idxs(s)).T1.INTER_post_awake_times)...
            length(control_data_FIRST_laps(prot_idxs(s)).T2.INTER_post_awake_times)];   
        
        % Number of INTER sleep & awake events for T1 and T2 CONTROL LAST LAPS
        CONTROL_LAST_T1_T2_INTER_sleep_events = [CONTROL_LAST_T1_T2_INTER_sleep_events; length(control_data_last_laps(prot_idxs(s)).T1.INTER_post_sleep_times)...
            length(control_data_last_laps(prot_idxs(s)).T2.INTER_post_sleep_times)];
        CONTROL_LAST_T1_T2_INTER_awake_events = [CONTROL_LAST_T1_T2_INTER_awake_events; length(control_data_last_laps(prot_idxs(s)).T1.INTER_post_awake_times)...
            length(control_data_last_laps(prot_idxs(s)).T2.INTER_post_awake_times)]; 
    end
    
    % Number of INTER sleep + awake events for T1 and T2
    REAL_T1_T2_ALL_INTER_events = [REAL_T1_T2_ALL_INTER_events; REAL_T1_T2_INTER_sleep_events(:,1)+REAL_T1_T2_INTER_awake_events(:,1)...
        REAL_T1_T2_INTER_sleep_events(:,2)+REAL_T1_T2_INTER_awake_events(:,2)];
    % Number of INTER sleep + awake events for T1 and T2 CONTROL FIRST LAPS
    CONTROL_FIRST_T1_T2_ALL_INTER_events = [CONTROL_FIRST_T1_T2_ALL_INTER_events; CONTROL_FIRST_T1_T2_INTER_sleep_events(:,1)+CONTROL_FIRST_T1_T2_INTER_awake_events(:,1)...
        CONTROL_FIRST_T1_T2_INTER_sleep_events(:,2)+CONTROL_FIRST_T1_T2_INTER_awake_events(:,2)];
   % Number of INTER sleep + awake events for T1 and T2 CONTROL LAST LAPS
    CONTROL_LAST_T1_T2_ALL_INTER_events = [CONTROL_LAST_T1_T2_ALL_INTER_events; CONTROL_LAST_T1_T2_INTER_sleep_events(:,1)+CONTROL_LAST_T1_T2_INTER_awake_events(:,1)...
        CONTROL_LAST_T1_T2_INTER_sleep_events(:,2)+CONTROL_LAST_T1_T2_INTER_awake_events(:,2)];
    
    col = copper(3);
    subplot(5,3,c)
    for i = 1 : 4
        hold on
        b = bar([i-0.66,i-0.33,i],[REAL_T1_T2_INTER_sleep_events(i,:); CONTROL_FIRST_T1_T2_INTER_sleep_events(i,:); CONTROL_LAST_T1_T2_INTER_sleep_events(i,:)],'stacked');
        b(1).FaceColor = 'flat';
        b(1).EdgeColor = 'flat';
        b(1).CData = [PP.T1; [0.3 0.3 0.3]; col(1,:)];
        b(2).FaceColor = 'flat';
        b(2).EdgeColor = 'flat';
        b(2).CData = [PP.T2(p,:); [0.6 0.6 0.6]; col(2,:)];
    end
    ylabel('# replay events','FontSize',12)
    set(gca, 'XTick',0.33:0.33:4)
    set(gca, 'XTickLabel', {'MBLU','MBLU-Ctrl-first','MBLU-Ctrl-last','NBLU','NBLU-Ctrl-first','NBLU-Ctrl-last',...
        'PORA','PORA-Ctrl-first','PORA-Ctrl-last','QBLU','QBLU-Ctrl-first','QBLU-Ctrl-last'})
    xtickangle(45)
    title(strcat('16x',num2str(protocols(p)),'- INTER sleep replay events'),'FontSize',12)
    a = gca;
    a.FontSize = 12;
    c = c+1;
    
    subplot(5,3,c)
    for i = 1 : 4
        hold on
        b = bar([i-0.66,i-0.33,i],[REAL_T1_T2_INTER_awake_events(i,:); CONTROL_FIRST_T1_T2_INTER_awake_events(i,:); CONTROL_LAST_T1_T2_INTER_awake_events(i,:)],'stacked');
        b(1).FaceColor = 'flat';
        b(1).EdgeColor = 'flat';
        b(1).CData = [PP.T1; [0.3 0.3 0.3];col(1,:)];
        b(2).FaceColor = 'flat';
        b(2).EdgeColor = 'flat';
        b(2).CData = [PP.T2(p,:); [0.6 0.6 0.6]; col(2,:)];
    end
    ylabel('# replay events','FontSize',12)
    set(gca, 'XTick',0.33:0.33:4)
    set(gca, 'XTickLabel', {'MBLU','MBLU-Ctrl-first','MBLU-Ctrl-last','NBLU','NBLU-Ctrl-first','NBLU-Ctrl-last',...
        'PORA','PORA-Ctrl-first','PORA-Ctrl-last','QBLU','QBLU-Ctrl-first','QBLU-Ctrl-last'})
    xtickangle(45)
    title(strcat('16x',num2str(protocols(p)),'- INTER awake replay events'),'FontSize',12)
    a = gca;
    a.FontSize = 12;
    c = c+1;
    
    subplot(5,3,c)
    for i = 1 : 4
        hold on
        b = bar([i-0.66,i-0.33,i],[REAL_T1_T2_ALL_INTER_events(i,:); CONTROL_FIRST_T1_T2_ALL_INTER_events(i,:); CONTROL_LAST_T1_T2_ALL_INTER_events(i,:)],'stacked');
        b(1).FaceColor = 'flat';
        b(1).EdgeColor = 'flat';
        b(1).CData = [PP.T1; [0.3 0.3 0.3]; col(1,:)];
        b(2).FaceColor = 'flat';
        b(2).EdgeColor = 'flat';
        b(2).CData = [PP.T2(p,:); [0.6 0.6 0.6]; col(2,:)];
    end
    ylabel('# replay events','FontSize',12)
    set(gca, 'XTick',0.33:0.33:4)
    set(gca, 'XTickLabel', {'MBLU','MBLU-Ctrl-first','MBLU-Ctrl-last','NBLU','NBLU-Ctrl-first','NBLU-Ctrl-last',...
        'PORA','PORA-Ctrl-first','PORA-Ctrl-last','QBLU','QBLU-Ctrl-first','QBLU-Ctrl-last'})
    xtickangle(45)
    legend({'T1','T2'}, 'Location','bestoutside','FontSize',12);
    title(strcat('16x',num2str(protocols(p)),'- All INTER events'),'FontSize',12)
    a = gca;
    a.FontSize = 12;
    c = c+1;
    
    
    % Calculate mean
    REAL_mean_INTER_sleep(p,:) = mean(REAL_T1_T2_INTER_sleep_events,1);
    REAL_mean_INTER_awake(p,:) = mean(REAL_T1_T2_INTER_awake_events,1);
    REAL_mean_INTER_ALL(p,:) = mean(REAL_T1_T2_ALL_INTER_events,1);
    
    CONTROL_FIRST_mean_INTER_sleep(p,:) = mean(CONTROL_FIRST_T1_T2_INTER_sleep_events,1);
    CONTROL_FIRST_mean_INTER_awake(p,:) = mean(CONTROL_FIRST_T1_T2_INTER_awake_events,1);
    CONTROL_FIRST_mean_INTER_ALL(p,:) = mean(CONTROL_FIRST_T1_T2_ALL_INTER_events,1);
    
    CONTROL_LAST_mean_INTER_sleep(p,:) = mean(CONTROL_LAST_T1_T2_INTER_sleep_events,1);
    CONTROL_LAST_mean_INTER_awake(p,:) = mean(CONTROL_LAST_T1_T2_INTER_awake_events,1);
    CONTROL_LAST_mean_INTER_ALL(p,:) = mean(CONTROL_LAST_T1_T2_ALL_INTER_events,1);
    
end


f2 = figure;
f2.Name = 'Cntrl  vs Real - Mean number of INTER events per protocol';

subplot(3,1,1)
for i = 1 : length(REAL_mean_INTER_ALL)
    hold on
    b = bar([i-0.66,i-0.33,i],[REAL_mean_INTER_sleep(i,:); CONTROL_FIRST_mean_INTER_sleep(i,:);CONTROL_LAST_mean_INTER_sleep(i,:)],'stacked');
    b(1).FaceColor = 'flat';
    b(1).EdgeColor = 'flat';
    b(1).CData = [PP.T1; [0.3 0.3 0.3]; col(1,:)];
    b(2).FaceColor = 'flat';
    b(2).EdgeColor = 'flat';
    b(2).CData = [PP.T2(i,:); [0.6 0.6 0.6]; col(2,:)];
end
ylabel('Mean # replay events','FontSize',13)
set(gca, 'XTick',0.33:0.33:5)
set(gca, 'XTickLabel', {'16x8','16x8-Ctrl-first','16x8-Ctrl-last','16x4','16x4-Ctrl-first','16x4-Ctrl-last','16x3','16x3-Ctrl-first','16x3-Ctrl-last',...
    '16x2','16x2-Ctrl-first','16x2-Ctrl-last','16x1','16x1-Ctrl-first','16x1-Ctrl-last'})
xtickangle(45)
legend({'T1','T2','T1','T2','T1','T2','T1','T2','T1','T2',}, 'Location','bestoutside','FontSize',11);
title('INTER sleep replay events','FontSize',13)
a = gca;
a.FontSize = 13;

subplot(3,1,2)
for i = 1 : length(REAL_mean_INTER_ALL)
    hold on
    b = bar([i-0.66,i-0.33,i],[REAL_mean_INTER_awake(i,:); CONTROL_FIRST_mean_INTER_awake(i,:);CONTROL_LAST_mean_INTER_awake(i,:)],'stacked');
    b(1).FaceColor = 'flat';
    b(1).EdgeColor = 'flat';
    b(1).CData = [PP.T1; [0.3 0.3 0.3]; col(1,:)];
    b(2).FaceColor = 'flat';
    b(2).EdgeColor = 'flat';
    b(2).CData = [PP.T2(i,:); [0.6 0.6 0.6]; col(2,:)];
end
ylabel('Mean # replay events','FontSize',13)
set(gca, 'XTick',0.33:0.33:5)
set(gca, 'XTickLabel', {'16x8','16x8-Ctrl-first','16x8-Ctrl-last','16x4','16x4-Ctrl-first','16x4-Ctrl-last','16x3','16x3-Ctrl-first','16x3-Ctrl-last',...
    '16x2','16x2-Ctrl-first','16x2-Ctrl-last','16x1','16x1-Ctrl-first','16x1-Ctrl-last'})
xtickangle(45)
title('INTER awake replay events','FontSize',13)
a = gca;
a.FontSize = 13;

subplot(3,1,3)
for i = 1 : length(REAL_mean_INTER_ALL)
    hold on
    b = bar([i-0.66,i-0.33,i],[REAL_mean_INTER_ALL(i,:); CONTROL_FIRST_mean_INTER_ALL(i,:);CONTROL_LAST_mean_INTER_ALL(i,:)],'stacked');
    b(1).FaceColor = 'flat';
    b(1).EdgeColor = 'flat';
    b(1).CData = [PP.T1; [0.3 0.3 0.3]; col(1,:)];
    b(2).FaceColor = 'flat';
    b(2).EdgeColor = 'flat';
    b(2).CData = [PP.T2(i,:); [0.6 0.6 0.6]; col(2,:)];
end
ylabel('Mean # replay events','FontSize',13)
set(gca, 'XTick',0.33:0.33:5)
set(gca, 'XTickLabel', {'16x8','16x8-Ctrl-first','16x8-Ctrl-last','16x4','16x4-Ctrl-first','16x4-Ctrl-last','16x3','16x3-Ctrl-first','16x3-Ctrl-last',...
    '16x2','16x2-Ctrl-first','16x2-Ctrl-last','16x1','16x1-Ctrl-first','16x1-Ctrl-last'})
xtickangle(45)
title('All INTER replay events','FontSize',13)
a = gca;
a.FontSize = 13;




end