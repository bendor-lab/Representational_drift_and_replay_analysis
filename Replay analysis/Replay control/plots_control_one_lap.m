function plots_control_one_lap

cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Short_exposures_control_ONE_lap')
load extracted_replay_plotting_info_MultiEvents.mat
control_data = track_replay_events;
clear track_replay_events

cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis')
load extracted_replay_plotting_info_MultiEvents.mat

PP = plotting_parameters;

% Find indices for each type of protocol
t2 = [];
for s = 1 : length(control_data)
    name = cell2mat(control_data(s).session(1));
    if strfind(name,'Ctrl')
        t2 = [t2 str2num(name(end-1:end))];
    else
        if length(name) == 20
            t2 = [t2 str2num(name(end-1:end))];
        else
            t2 = [t2 str2num(name(end))];
        end
    end
end
protocols = unique(t2,'stable');

% EXTRACT REAL DATA 
prot_idxs = 17:20; % indices for 1 lap protocols
REAL_T1_T2_INTER_sleep_events = [];
REAL_T1_T2_INTER_awake_events = [];
REAL_T1_T2_ALL_INTER_events = [];
for s = 1 : length(prot_idxs)
    % Number of INTER sleep events for T1 and T2
    REAL_T1_T2_INTER_sleep_events = [REAL_T1_T2_INTER_sleep_events; length(track_replay_events(prot_idxs(s)).T1.INTER_post_sleep_times)...
        length(track_replay_events(prot_idxs(s)).T2.INTER_post_sleep_times)];
    % Number of INTER awake events for T1 and T2
    REAL_T1_T2_INTER_awake_events = [REAL_T1_T2_INTER_awake_events; length(track_replay_events(prot_idxs(s)).T1.INTER_post_awake_times)...
        length(track_replay_events(prot_idxs(s)).T2.INTER_post_awake_times)];
end

% Number of INTER sleep + awake events for T1 and T2
REAL_T1_T2_ALL_INTER_events = [REAL_T1_T2_ALL_INTER_events; REAL_T1_T2_INTER_sleep_events(:,1)+REAL_T1_T2_INTER_awake_events(:,1)...
    REAL_T1_T2_INTER_sleep_events(:,2)+REAL_T1_T2_INTER_awake_events(:,2)];
% Calculate mean
REAL_mean_INTER_sleep(1,:) = mean(REAL_T1_T2_INTER_sleep_events,1);
REAL_mean_INTER_awake(1,:) = mean(REAL_T1_T2_INTER_awake_events,1);
REAL_mean_INTER_ALL(1,:) = mean(REAL_T1_T2_ALL_INTER_events,1);
REAL_std_INTER_sleep(1,:) = std(REAL_T1_T2_INTER_sleep_events,[],1);
REAL_std_INTER_awake(1,:) = std(REAL_T1_T2_INTER_awake_events,[],1);
REAL_std_INTER_ALL(1,:) = std(REAL_T1_T2_ALL_INTER_events,[],1);

f2 = figure;
f2.Name = 'Cntrl  vs Real - Number of INTER events per rat and protocol-SLEEP';

f3 = figure;
f3.Name = 'Cntrl  vs Real - Number of INTER events per rat and protocol-AWAKE';

f4 = figure;
f4.Name = 'Cntrl  vs Real - Number of INTER events per rat and protocol-ALL';
c=1;
c4=1;
c3=1;

% EXTRACT CONTROL DATA
for p = 1 : length(protocols)
    prot_idxs = find(t2 == protocols(p));
    prot_idxs(3) = [];
    CONTROL_T1_T2_ALL_INTER_events.(sprintf('%s','LAP_',num2str(protocols(p)))) = [];
    for s = 1 : length(prot_idxs)
        
        % Number of INTER sleep & awake events for T1 and T2 CONTROL 
        CONTROL_T1_T2_INTER_sleep.(sprintf('%s','LAP_',num2str(protocols(p))))(s,1:2) = [length(control_data(prot_idxs(s)).T1.INTER_post_sleep_times)...
            length(control_data(prot_idxs(s)).T2.INTER_post_sleep_times)];
        CONTROL_T1_T2_INTER_awake.(sprintf('%s','LAP_',num2str(protocols(p))))(s,1:2) = [length(control_data(prot_idxs(s)).T1.INTER_post_awake_times)...
            length(control_data(prot_idxs(s)).T2.INTER_post_awake_times)];   
    end
    
    % Number of INTER sleep + awake events for T1 and T2 CONTROL FIRST LAPS
    CONTROL_T1_T2_ALL_INTER_events.(sprintf('%s','LAP_',num2str(protocols(p)))) = [CONTROL_T1_T2_ALL_INTER_events.(sprintf('%s','LAP_',num2str(protocols(p)))) ; CONTROL_T1_T2_INTER_sleep.(sprintf('%s','LAP_',num2str(protocols(p))))(:,1)+CONTROL_T1_T2_INTER_awake.(sprintf('%s','LAP_',num2str(protocols(p))))(:,1)...
        CONTROL_T1_T2_INTER_sleep.(sprintf('%s','LAP_',num2str(protocols(p))))(:,2)+CONTROL_T1_T2_INTER_awake.(sprintf('%s','LAP_',num2str(protocols(p))))(:,2)];
    
    % Calculate mean
    CONTROL_mean_INTER_sleep(p,:) = mean(CONTROL_T1_T2_INTER_sleep.(sprintf('%s','LAP_',num2str(protocols(p)))),1);
    CONTROL_std_INTER_sleep(p,:) = std(CONTROL_T1_T2_INTER_sleep.(sprintf('%s','LAP_',num2str(protocols(p)))),[],1);
    CONTROL_mean_INTER_awake(p,:) = mean(CONTROL_T1_T2_INTER_awake.(sprintf('%s','LAP_',num2str(protocols(p)))),1);
    CONTROL_std_INTER_awake(p,:) = std(CONTROL_T1_T2_INTER_awake.(sprintf('%s','LAP_',num2str(protocols(p)))),[],1);
    CONTROL_mean_INTER_ALL(p,:) = mean(CONTROL_T1_T2_ALL_INTER_events.(sprintf('%s','LAP_',num2str(protocols(p)))),1);
    CONTROL_std_INTER_ALL(p,:) = std(CONTROL_T1_T2_ALL_INTER_events.(sprintf('%s','LAP_',num2str(protocols(p)))),[],1);
end


f1 = figure;
f1.Name = 'Cntrl  vs Real - Mean number of INTER events per protocol';

subplot(3,2,1)
mat = []; mat2 = [];
mat2 = [REAL_std_INTER_sleep; nan(size(REAL_mean_INTER_sleep))];
mat = [REAL_mean_INTER_sleep; nan(size(REAL_mean_INTER_sleep))];
for i = 1 : length(CONTROL_mean_INTER_sleep)
    mat = [mat;CONTROL_mean_INTER_sleep(i,:)];
    mat2 =[mat2;CONTROL_std_INTER_sleep(i,:)];
end
trans = mat./sum(mat,2);

b = bar(trans,'stacked');
hold on
for i = 1 : length(b(1).XData)
    b(1).CData = PP.T1;
    b(1).FaceColor = 'flat';
    b(1).EdgeColor = 'flat';
    b(2).CData = PP.T2(5,:);
    b(2).FaceColor = 'flat';
    b(2).EdgeColor = 'flat';
end
ylabel('Proportion replay events','FontSize',13)
set(gca, 'XTick',1:18)
set(gca, 'XTickLabel', {'Raw','','1','2','3','4','5','6','7',...
    '8','9','10','11','12','13','14','15','16'})
title('INTER sleep replay events','FontSize',13)
xlabel('Lap number')
plot([2 2],[min(ylim) max(ylim)],':','LineWidth',2,'Color',[0.3 0.3 0.3])
a = gca;
a.FontSize = 13;



subplot(3,2,2)
hold on
plot(mat(3:end,1),'LineWidth',3,'Color',PP.T1)
plot(mat(3:end,1),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1)
er = errorbar(mat(3:end,1), mat2(3:end,1));
er.Color = PP.T1;
plot(mat(3:end,2),'LineWidth',3,'Color',PP.T2(5,:))
plot(mat(3:end,2),'o','MarkerFaceColor',PP.T2(5,:),'MarkerEdgeColor',PP.T2(5,:))
er = errorbar(mat(3:end,2), mat2(3:end,2));
er.Color = PP.T2(5,:);
plot([0 16],[mat(1,2) mat(1,2)],'LineStyle','--','LineWidth',1.5,'Color',PP.T2(5,:))
plot([0 16],[mat(1,1) mat(1,1)],'LineStyle','--','LineWidth',1.5,'Color',PP.T1)
title('INTER sleep replay events','FontSize',13)
xlabel('Lap number')
ylabel('# Replay events','FontSize',13)


subplot(3,2,3)
mat = []; mat2 = [];
mat2 = [REAL_std_INTER_awake; nan(size(REAL_mean_INTER_awake))];
mat = [REAL_mean_INTER_awake; nan(size(REAL_mean_INTER_awake))];
for i = 1 : length(CONTROL_mean_INTER_sleep)
    mat = [mat;CONTROL_mean_INTER_awake(i,:)];
    mat2 =[mat2;CONTROL_std_INTER_awake(i,:)];
end
trans = mat./sum(mat,2);

hold on
b1 = bar(trans,'stacked');
for i = 1 : length(b1(1).XData)
    b1(1).CData = PP.T1;
    b1(1).FaceColor = 'flat';
    b1(1).EdgeColor = 'flat';
    b1(2).CData = PP.T2(5,:);
    b1(2).FaceColor = 'flat';
    b1(2).EdgeColor = 'flat';
end
ylabel('Proportion replay events','FontSize',13)
set(gca, 'XTick',1:18)
set(gca, 'XTickLabel', {'Raw','','1','2','3','4','5','6','7',...
    '8','9','10','11','12','13','14','15','16'})
title('INTER awake replay events','FontSize',13)
xlabel('Lap number')
plot([2 2],[min(ylim) max(ylim)],':','LineWidth',2,'Color',[0.3 0.3 0.3])
a = gca;
a.FontSize = 13;

subplot(3,2,4)
hold on
plot(mat(3:end,1),'LineWidth',3,'Color',PP.T1)
plot(mat(3:end,1),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1)
er = errorbar(mat(3:end,1), mat2(3:end,1));
er.Color = PP.T1;
plot(mat(3:end,2),'LineWidth',3,'Color',PP.T2(5,:))
plot(mat(3:end,2),'o','MarkerFaceColor',PP.T2(5,:),'MarkerEdgeColor',PP.T2(5,:))
er = errorbar(mat(3:end,2), mat2(3:end,2));
er.Color = PP.T2(5,:);
plot([0 16],[mat(1,2) mat(1,2)],'LineStyle','--','LineWidth',1.5,'Color',PP.T2(5,:))
plot([0 16],[mat(1,1) mat(1,1)],'LineStyle','--','LineWidth',1.5,'Color',PP.T1)
title('INTER awake replay events','FontSize',13)
xlabel('Lap number')
ylabel('# Replay events','FontSize',13)

subplot(3,2,5)
mat = []; mat2 = [];
mat2 = [REAL_std_INTER_ALL; nan(size(REAL_mean_INTER_ALL))];
mat = [REAL_mean_INTER_ALL; nan(size(REAL_mean_INTER_ALL))];
for i = 1 : length(CONTROL_mean_INTER_ALL)
    mat = [mat;CONTROL_mean_INTER_ALL(i,:)];
    mat2 =[mat2;CONTROL_std_INTER_ALL(i,:)];
end
trans = mat./sum(mat,2);

b2 = bar(trans,'stacked');
hold on
for i = 1 : length(b2(1).XData)
    b2(1).CData = PP.T1;
    b2(1).FaceColor = 'flat';
    b2(1).EdgeColor = 'flat';
    b2(2).CData = PP.T2(5,:);
    b2(2).FaceColor = 'flat';
    b2(2).EdgeColor = 'flat';
end
ylabel('Proportion replay events','FontSize',13)
set(gca, 'XTick',1:18)
set(gca, 'XTickLabel', {'Raw','','1','2','3','4','5','6','7',...
    '8','9','10','11','12','13','14','15','16'})
title('INTER replay events','FontSize',13)
xlabel('Lap number')
plot([2 2],[min(ylim) max(ylim)],':','LineWidth',1,'Color',[0.3 0.3 0.3])
box off
a = gca;
a.FontSize = 13;

subplot(3,2,6)
hold on
plot(mat(3:end,1),'LineWidth',3,'Color',PP.T1)
plot(mat(3:end,1),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1)
er = errorbar(mat(3:end,1), mat2(3:end,1));
er.Color = PP.T1;
plot(mat(3:end,2),'LineWidth',3,'Color',PP.T2(5,:))
plot(mat(3:end,2),'o','MarkerFaceColor',PP.T2(5,:),'MarkerEdgeColor',PP.T2(5,:))
er = errorbar(mat(3:end,2), mat2(3:end,2));
er.Color = PP.T2(5,:);
plot([0 16],[mat(1,2) mat(1,2)],'LineStyle','--','LineWidth',1.5,'Color',PP.T2(5,:))
plot([0 16],[mat(1,1) mat(1,1)],'LineStyle','--','LineWidth',1.5,'Color',PP.T1)
title('INTER awake replay events','FontSize',13)
xlabel('Lap number')
ylabel('# Replay events','FontSize',13)
ylim([0 125])


tsts = [];
for i=  1 : 16
    tst1 =[];
    for j = 1 : size(CONTROL_T1_T2_ALL_INTER_events.(strcat('LAP_',num2str(i))),2)
        tst1 = [tst1; CONTROL_T1_T2_ALL_INTER_events.(strcat('LAP_',num2str(i)))(:,j)];
    end
    if i == 16
        tst1=[];
        for j = 1 : size(CONTROL_T1_T2_ALL_INTER_events.(strcat('LAP_',num2str(i))),2)
            tst1 = [tst1; CONTROL_T1_T2_ALL_INTER_events.(strcat('LAP_',num2str(i)))(:,j);NaN];
        end
    end
    tsts = [tsts tst1];
end

[p,~,stat] = kruskalwallis([tsts(:,1) tsts(:,14:15)]);

p = ranksum(tsts(:,1),mean(tsts(:,8:16),2,'omitnan'));

end
