% PLOT AVERAGE PHASE PRECESSION SCORES PER PROTOCOL
% MH 2020
% Loads phase precession scores per track and session ('extracted_phase_precession_absolute_location.mat'). 
% First plot - calculates the mean phase precession scor per track and protocol (1,2,3,4,8,16 laps and re-exposures). Plots as a line plot with errorbars and sig values.

function plot_protocol_thetaseq_scores

PP = plotting_parameters;

% Load name of data folders
sessions = data_folders;
session_names = fieldnames(sessions);

c=1;

for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        
        load('extracted_phase_precession_absolute_location.mat')
        
        for t =1 : length(TPP)
            phase_prec(c).(strcat(['all_PP_mean_T' num2str(t)])) = mean([TPP(t).circ_lin_corr_dir1 TPP(t).circ_lin_corr_dir2],'omitnan');
            sig_PP = [TPP(t).circ_lin_corr_dir1(TPP(t).circ_lin_PVAL_dir1 <0.05) TPP(t).circ_lin_corr_dir2(TPP(t).circ_lin_PVAL_dir2 <0.05)];
            phase_prec(c).(strcat(['sig_PP_mean_T' num2str(t)])) = mean(sig_PP,'omitnan');
            NON_sig_PP = [TPP(t).circ_lin_corr_dir1(TPP(t).circ_lin_PVAL_dir1 >0.05) TPP(t).circ_lin_corr_dir2(TPP(t).circ_lin_PVAL_dir2 >0.05)];
            phase_prec(c).(strcat(['NONsig_PP_mean_T' num2str(t)])) = mean(NON_sig_PP,'omitnan');
            phase_prec(c).(strcat(['all_PPpval_mean_T' num2str(t)])) = mean([TPP(t).circ_lin_PVAL_dir1 TPP(t).circ_lin_PVAL_dir2],'omitnan');
            phase_prec(c).(strcat(['sig_PPpval_mean_T' num2str(t)])) = mean([TPP(t).circ_lin_PVAL_dir1(TPP(t).circ_lin_PVAL_dir1 <0.05) TPP(t).circ_lin_PVAL_dir2(TPP(t).circ_lin_PVAL_dir2 <0.05)],'omitnan');
            
        end
        c=c+1;
        
    end
end

protocols = [1,2,3,4,8];
all_scores = nan(20,13);
all_scores(:,6) = [phase_prec(:).sig_PP_mean_T1]; 
all_scores(:,13) = [phase_prec(:).sig_PP_mean_T3]; 

c=20;
for pr = 1 : length(protocols)
    all_scores(1:4,pr) = [phase_prec(c-3:c).sig_PP_mean_T2];
    all_scores(1:4,pr+7) = [phase_prec(c-3:c).sig_PP_mean_T4];
    c=c-4;
end
     
all_pval = nan(20,13);
all_pval(:,6) = [phase_prec(:).sig_PPpval_mean_T1]; 
all_pval(:,13) = [phase_prec(:).sig_PPpval_mean_T3]; 

c=20;
for pr = 1 : length(protocols)
    all_pval(1:4,pr) = [phase_prec(c-3:c).sig_PPpval_mean_T2];
    all_pval(1:4,pr+7) = [phase_prec(c-3:c).sig_PPpval_mean_T4];
    c=c-4;
end

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
f1.Name = 'Phase precession all protocols';

ax(1) = subplot(2,1,1);
hold on
%cols = repmat([0.3 0.3 0.3],8,1);
cols = [flipud(PP.T2);PP.T1;flipud(PP.T2);PP.T1];
boxplot(all_scores,'PlotStyle','traditional','Colors',cols,'LabelOrientation','horizontal','Widths',0.2);
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes = a(idx);  % Get the children you need (boxes for first exposure)
set(a,'LineWidth',2); % Set width
box off
hold on
for xx = 1: size(all_scores,2)
    plot(xx,all_scores(:,xx),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[1 1 1],'MarkerSize',4);
end

ax(2) = subplot(2,1,2);
hold on
boxplot(all_pval,'PlotStyle','traditional','Colors',cols,'LabelOrientation','horizontal','Widths',0.2);
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes = a(idx);  % Get the children you need (boxes for first exposure)
set(a,'LineWidth',2); % Set width
box off
hold on
for xx = 1: size(all_pval,2)
    plot(xx,all_pval(:,xx),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[1 1 1],'MarkerSize',4);
end

run_format_settings(gcf)
ax(2).XTick = [1:6,8:13];
ax(1).XTick = [1:6,8:13];
ax(1).YLim = [0.1 max(ylim(ax(1)))];
ax(1).YTick = [0.1 :0.1: 0.5];
ax(2).YTick = [0.001 0.005 0.01 0.015 0.02];
ax(2).YLim = [0.001 max(ylim(ax(2)))];
ylabel(ax(1),'Phase Precession Score','FontSize',16)
ylabel(ax(2),'Phase Precession p-Value','FontSize',16)
ax(1).FontSize = 16;
ax(2).FontSize = 16;


% ONE WAY ANOVA to find differences between groups
% First check between T2 re-expsures
[pv,~,stats] =kruskalwallis(all_scores(:,8:12));
if pv <0.05
    [sig_gr,~,~,~] = multcompare(stats,[],'off');
    sig_idx =  find(sig_gr(:,6) < 0.05);
end
[pv,~,stats] =kruskalwallis(all_pval(:,8:12));
if pv <0.05
    [sig_gr,~,~,~] = multcompare(stats,[],'off');
    sig_idx =  find(sig_gr(:,6) < 0.05);
end

% Repeat plot with all T2 re-expo together

protocols = [1,2,3,4,8];
all_scores = nan(20,8);
all_scores(:,6) = [phase_prec(:).sig_PP_mean_T1];
all_scores(:,7) = [phase_prec(:).sig_PP_mean_T3];
all_scores(:,8) = [phase_prec(:).sig_PP_mean_T4]; 

c=20;
for pr = 1 : length(protocols)
    all_scores(1:4,pr) = [phase_prec(c-3:c).sig_PP_mean_T2];
    c=c-4;
end
     
all_pval = nan(20,8);
all_pval(:,6) = [phase_prec(:).sig_PPpval_mean_T1]; 
all_pval(:,7) = [phase_prec(:).sig_PPpval_mean_T3]; 
all_pval(:,8) = [phase_prec(:).sig_PPpval_mean_T3]; 

c=20;
for pr = 1 : length(protocols)
    all_pval(1:4,pr) = [phase_prec(c-3:c).sig_PPpval_mean_T2];
    c=c-4;
end

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
f1.Name = 'Phase precession all protocols';

ax(1) = subplot(2,1,1);
hold on
cols = [flipud(PP.T2);PP.T1;[0.3 .3 .3];[.6 .6 .6]];
xlabels = {'1', '2', '3', '4', '8', '16','RT1','RT2'};
boxplot(all_scores,'PlotStyle','traditional','Colors',cols,'Labels',xlabels,'LabelOrientation','horizontal','Widths',0.2);
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes = a(idx);  % Get the children you need (boxes for first exposure)
set(a,'LineWidth',2); % Set width
box off
hold on
for xx = 1: size(all_scores,2)
    plot(xx,all_scores(:,xx),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[1 1 1],'MarkerSize',4);
end

ax(2) = subplot(2,1,2);
hold on
boxplot(all_pval,'PlotStyle','traditional','Colors',cols,'Labels',xlabels,'LabelOrientation','horizontal','Widths',0.2);
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes = a(idx);  % Get the children you need (boxes for first exposure)
set(a,'LineWidth',2); % Set width
box off
hold on
for xx = 1: size(all_pval,2)
    plot(xx,all_pval(:,xx),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[1 1 1],'MarkerSize',4);
end

run_format_settings(gcf)
ax(2).XTick = [1:8];
ax(1).XTick = [1:8];
ax(1).YLim = [0.1 max(ylim(ax(1)))];
ax(1).YTick = [0.1 :0.1: 0.5];
ax(2).YTick = [0.001 0.005 0.01 0.015 0.02];
ax(2).YLim = [0.001 max(ylim(ax(2)))];
ylabel(ax(1),'Phase Precession Score','FontSize',16)
ylabel(ax(2),'Phase Precession p-Value','FontSize',16)
ax(1).FontSize = 16;
ax(2).FontSize = 16;


% ONE WAY ANOVA to find differences between groups
%Check RT1 vs RT2
pv = signrank(all_scores(:,7),all_scores(:,8)); %NS
pv = signrank(all_pval(:,7),all_scores(:,8)); %NS

% Check first exposure
[pv,~,stats] =kruskalwallis(all_scores(:,1:6));
if pv <0.05
    [sig_gr,~,~,~] = multcompare(stats,[],'off');
    sig_idx =  find(sig_gr(:,6) < 0.05);
end
[pv,~,stats] =kruskalwallis(all_pval(:,1:6));
if pv <0.05
    [sig_gr,~,~,~] = multcompare(stats,[],'off');
    sig_idx =  find(sig_gr(:,6) < 0.05);
end


% Save figures
save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores',[])

end