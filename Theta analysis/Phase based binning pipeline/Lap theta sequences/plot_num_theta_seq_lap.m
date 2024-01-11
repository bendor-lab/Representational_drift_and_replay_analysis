function norm_theta_seq = plot_num_theta_seq_lap(data_type)
% MH 2021
% Plots both number of theta sequences per laps and normalised number of sequences in lap by the time spent moving in each lap
% Also calculates the difference in the number of theta sequences lap by lap

if strcmp(data_type,'main')
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\thetaseq_scores_individual_laps.mat')
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\behavioural_data.mat')
elseif strcmp(data_type,'speed')
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Speed\Theta sequence scores\thetaseq_scores_individual_laps.mat')
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\Speed Control\behavioural_data.mat')
end
PP =plotting_parameters;

t1 =  nan(20,16);
t3 =  nan(20,16);
t4 =  nan(20,16);
t2 =  nan(20,8);
t1_norm =  nan(20,16);
t3_norm =  nan(20,16);
t4_norm =  nan(20,16);
t2_norm =  nan(20,8);

for s = 1 : length(lap_WeightedCorr) %for each session
    if length(lap_WeightedCorr(s).track(1).num_thetaseq) >= 16
        ep = 16;
    else
        ep = length(lap_WeightedCorr(s).track(1).num_thetaseq);
    end
    % Creates matrix per track, where each row is a session and each column is the number of theta sequences per lap. 
    t1(s,1:length(lap_WeightedCorr(s).track(1).num_thetaseq(1:ep))) = lap_WeightedCorr(s).track(1).num_thetaseq(1:ep);
    if length(lap_WeightedCorr(s).track(1).num_thetaseq(1:ep)) > length(lap_behaviour(1).time_moving(s,1:ep))
        ep = length(cell2mat(lap_behaviour(1).time_moving(s,1:ep)));
    end
    t1_norm(s,1:length(lap_WeightedCorr(s).track(1).num_thetaseq(1:ep))) = lap_WeightedCorr(s).track(1).num_thetaseq(1:ep)./(lap_behaviour(1).time_moving(s,1:ep));
    t1norm_diff(s,1:length(diff(t1_norm(s,:)))) = diff(t1_norm(s,:)); % positive values, more theta seq in next lap
    t2(s,1:length(lap_WeightedCorr(s).track(2).num_thetaseq)) = lap_WeightedCorr(s).track(2).num_thetaseq;
    t2_norm(s,1:length(lap_WeightedCorr(s).track(2).num_thetaseq)) = lap_WeightedCorr(s).track(2).num_thetaseq./(lap_behaviour(2).time_moving(s,1:length(lap_WeightedCorr(s).track(2).num_thetaseq)));
    t2norm_diff(s,1:length(diff(t2_norm(s,:)))) = diff(t2_norm(s,:)); 
    if length(lap_WeightedCorr(s).track(3).num_thetaseq) >= 16
        ep = 16;
    else
        ep = length(lap_WeightedCorr(s).track(3).num_thetaseq);
    end
    t3(s,1:length(lap_WeightedCorr(s).track(3).num_thetaseq(1:ep))) = lap_WeightedCorr(s).track(3).num_thetaseq(1:ep);
    t3_norm(s,1:length(lap_WeightedCorr(s).track(3).num_thetaseq(1:ep))) = lap_WeightedCorr(s).track(3).num_thetaseq(1:ep)./(lap_behaviour(3).time_moving(s,1:ep));
    t4(s,1:length(lap_WeightedCorr(s).track(4).num_thetaseq(1:16))) = lap_WeightedCorr(s).track(4).num_thetaseq(1:16);
    t4_norm(s,1:length(lap_WeightedCorr(s).track(4).num_thetaseq(1:16))) = lap_WeightedCorr(s).track(4).num_thetaseq(1:16)./(lap_behaviour(4).time_moving(s,1:16));
    t3norm_diff(s,1:length(diff(t3_norm(s,:)))) = diff(t3_norm(s,:)); 
    t4norm_diff(s,1:length(diff(t4_norm(s,:)))) = diff(t4_norm(s,:)); 

end

% Save data in structures
norm_theta_seq.t1 = t1;
norm_theta_seq.t1_norm = t1_norm;
norm_theta_seq.t1norm_diff = t1norm_diff;
norm_theta_seq.t2 = t2;
norm_theta_seq.t2_norm = t2_norm;
norm_theta_seq.t2norm_diff = t2norm_diff;
norm_theta_seq.t3 = t3;
norm_theta_seq.t3_norm = t3_norm;
norm_theta_seq.t3norm_diff = t3norm_diff;
norm_theta_seq.t4 = t4;
norm_theta_seq.t4_norm = t4_norm;
norm_theta_seq.t4norm_diff = t4norm_diff;

% PLOT Number of theta seq per lap
f2=figure;
f2.Name = 'Number of theta seq per lap and track';
subplot(2,2,1)
col = repmat([0.3 0.3 0.3],[16,1]);
boxplot(t1(:,1:16),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',2); % Set width
box off
ylabel('Num theta seq','FontSize',14)
xlabel('Laps','FontSize',14)
title('T1','FontSize',16);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
hold on
for ii = 1 : 16
    plot(ii,t1(:,ii),'o','MarkerEdgeColor',[0.6 0.6 0.6],'MarkerFaceColor',[0.6 0.6 0.6])
end

[~,~,stats] = kruskalwallis(t1,[],'off');
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons

subplot(2,2,2)
col = repmat([0.3 0.3 0.3],[16,1]);
boxplot(t2(:,1:8),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',2); % Set width
box off
ylabel('scores','FontSize',14)
xlabel('Num theta seq','FontSize',14)
title('T2','FontSize',16);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
hold on
for ii = 1 : 8
    plot(ii,t2(:,ii),'o','MarkerEdgeColor',[0.6 0.6 0.6],'MarkerFaceColor',[0.6 0.6 0.6])
end

[~,~,stats] = kruskalwallis(t2,[],'off');
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons

subplot(2,2,3)
col = repmat([0.3 0.3 0.3],[16,1]);
boxplot(t3(:,1:16),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',2); % Set width
box off
ylabel('scores','FontSize',14)
xlabel('Num theta seq','FontSize',14)
title('T3','FontSize',16);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
hold on
for ii = 1 : 16
    plot(ii,t3(:,ii),'o','MarkerEdgeColor',[0.6 0.6 0.6],'MarkerFaceColor',[0.6 0.6 0.6])
end

[~,~,stats] = kruskalwallis(t3,[],'off');
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons

subplot(2,2,4)
col = repmat([0.3 0.3 0.3],[16,1]);
boxplot(t4(:,1:16),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',2); % Set width
box off
ylabel('scores','FontSize',14)
xlabel('Laps','FontSize',14)
title('T4','FontSize',16);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
hold on
cols = parula(20);
for ii = 1 : 16
    for jj = 1 : length(t4(:,ii))
        plot(ii,t4(jj,ii),'o','MarkerEdgeColor',cols(jj,:),'MarkerFaceColor',cols(jj,:))
    end
end

[~,~,stats] = kruskalwallis(t4,[],'off');
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons

PP = plotting_parameters;

% PLOT NORMALISED NUMBER OF THETA SEQUENCES

f1=figure;
f1.Name = 'Normalized number of theta seq per lap and track';
subplot(2,2,1)
col = repmat([0.3 0.3 0.3],[16,1]);
boxplot(t1_norm(:,1:16),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',2); % Set width
box off
ylabel('Norm num theta seq','FontSize',14)
xlabel('Laps','FontSize',14)
title('T1','FontSize',16);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
hold on
cols = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[4,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];
markers = repmat(PP.rat_markers,[1,5]);
% cols = parula(20);
for ii = 1 : 16
    for jj = 1 : length(t1_norm(:,ii))
        plot(ii,t1_norm(jj,ii),'Marker',markers{jj},'MarkerEdgeColor',cols(jj,:),'MarkerFaceColor',cols(jj,:))
    end
end


subplot(2,2,2)
col = repmat([0.3 0.3 0.3],[16,1]);
boxplot(t2_norm(:,1:8),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',2); % Set width
box off
ylabel('Norm num theta seq','FontSize',14)
xlabel('Laps','FontSize',14)
title('T2','FontSize',16);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
hold on
cols = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[4,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];
% cols = parula(20);
for ii = 1 : 8
    for jj = 1 : length(t2_norm(:,ii))
        plot(ii,t2_norm(jj,ii),'MarkerEdgeColor',cols(jj,:),'MarkerFaceColor',cols(jj,:))%'Marker',markers{jj}
    end
end

subplot(2,2,3)
col = repmat([0.3 0.3 0.3],[16,1]);
boxplot(t3_norm(:,1:16),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',2); % Set width
box off
ylabel('Norm num theta seq','FontSize',14)
xlabel('Laps','FontSize',14)
title('T3','FontSize',16);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
hold on
cols = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[4,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];
% cols = parula(20);
for ii = 1 : 16
    for jj = 1 : length(t3_norm(:,ii))
        plot(ii,t3_norm(jj,ii),'Marker',markers{jj},'MarkerEdgeColor',cols(jj,:),'MarkerFaceColor',cols(jj,:))
    end
end

subplot(2,2,4)
col = repmat([0.3 0.3 0.3],[16,1]);
boxplot(t4_norm(:,1:16),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',2); % Set width
box off
ylabel('Norm num theta seq','FontSize',14)
xlabel('Laps','FontSize',14)
title('T4','FontSize',16);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
hold on
cols = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[4,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];
markers = repmat(PP.rat_markers,[1,5]);
% cols = parula(20);
for ii = 1 : 16
    for jj = 1 : length(t4_norm(:,ii))
        plot(ii,t4_norm(jj,ii),'Marker',markers{jj},'MarkerEdgeColor',cols(jj,:),'MarkerFaceColor',cols(jj,:))
    end
end

% PLOT DIFFERENCE NORMALISED NUMBER OF THETA SEQUENCES

f1=figure;
f1.Name = 'Difference of normalized number of theta seq per lap and track';
subplot(2,2,1)
col = repmat([0.3 0.3 0.3],[15,1]);
boxplot(t1norm_diff(:,1:15),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',2); % Set width
box off
ylabel('Diff norm num theta seq','FontSize',14)
xlabel('Laps','FontSize',14)
title('T1','FontSize',16);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
hold on
cols = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[4,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];
markers = repmat(PP.rat_markers,[1,5]);
% cols = parula(20);
for ii = 1 : 15
    for jj = 1 : length(t1norm_diff(:,ii))
        plot(ii,t1norm_diff(jj,ii),'Marker',markers{jj},'MarkerEdgeColor',cols(jj,:),'MarkerFaceColor',cols(jj,:))
    end
end


subplot(2,2,2)
col = repmat([0.3 0.3 0.3],[16,1]);
boxplot(t2norm_diff(:,1:7),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',2); % Set width
box off
ylabel('Diff norm num theta seq','FontSize',14)
xlabel('Laps','FontSize',14)
title('T2','FontSize',16);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
hold on
cols = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[4,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];
% cols = parula(20);
for ii = 1 : 7
    for jj = 1 : length(t2norm_diff(:,ii))
        plot(ii,t2norm_diff(jj,ii),'MarkerEdgeColor',cols(jj,:),'MarkerFaceColor',cols(jj,:))%'Marker',markers{jj}
    end
end

subplot(2,2,3)
col = repmat([0.3 0.3 0.3],[15,1]);
boxplot(t3norm_diff(:,1:15),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',2); % Set width
box off
ylabel('Diff norm num theta seq','FontSize',14)
xlabel('Laps','FontSize',14)
title('T3','FontSize',16);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
hold on
cols = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[4,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];
% cols = parula(20);
for ii = 1 : 15
    for jj = 1 : length(t3norm_diff(:,ii))
        plot(ii,t3norm_diff(jj,ii),'Marker',markers{jj},'MarkerEdgeColor',cols(jj,:),'MarkerFaceColor',cols(jj,:))
    end
end

subplot(2,2,4)
col = repmat([0.3 0.3 0.3],[15,1]);
boxplot(t4norm_diff(:,1:15),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',2); % Set width
box off
ylabel('Diff norm num theta seq','FontSize',14)
xlabel('Laps','FontSize',14)
title('T4','FontSize',16);
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',14)
hold on
cols = [repmat(PP.T2(1,:),[4,1]);repmat(PP.T2(2,:),[4,1]);repmat(PP.T2(3,:),[4,1]);repmat(PP.T2(4,:),[4,1]);repmat(PP.T2(5,:),[4,1])];
markers = repmat(PP.rat_markers,[1,5]);
% cols = parula(20);
for ii = 1 : 15
    for jj = 1 : length(t4norm_diff(:,ii))
        plot(ii,t4norm_diff(jj,ii),'Marker',markers{jj},'MarkerEdgeColor',cols(jj,:),'MarkerFaceColor',cols(jj,:))
    end
end

%save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Controls',[])

mod_t2 = [t2_norm nan(20,8)];
%joined = [t1_norm;mod_t2];
mod_t1 = [t1_norm;nan(20,16)];
mod_t3 = [t3_norm;nan(20,16)];
mod_t4 = [t4_norm;nan(20,16)];

[pvs,~,statss] = kruskalwallis([mean(t1_norm(:,1:8),1,'omitnan'); mean(mod_t2(:,1:8),1,'omitnan')]);
c = multcompare(statss,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons

for ses = 1 : 20
    [pvs,~,statss] = kruskalwallis([t1_norm(ses,:); mod_t2(ses,:)]);
    c = multcompare(statss,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
    if pvs < 0.05
        disp(ses)
    end
end

for jj = 1 : size(t4,1)
    %[pvs,statss] = kruskalwallis([joined(:,jj) mod_t3(:,jj) mod_t4(:,jj)],[],'off');
    [pvs,~,~] = kruskalwallis([t1_norm(:,jj) mod_t2(:,jj) t3_norm(:,jj) t4_norm(:,jj)],[],'off');
    if pvs < 0.05
        disp(jj)
        %[PV(jj),~,stats] = kruskalwallis([joined(:,jj) mod_t3(:,jj) mod_t4(:,jj)]);
        [PV(jj),~,stats] = kruskalwallis([t1_norm(:,jj) mod_t2(:,jj) t3_norm(:,jj) t4_norm(:,jj)]);
        cc{jj} = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
    end
end
% ONLY LAPS #4,8,9,10,11,12,13,14,15 SIG DIFF BETWEEN TRACKS, with 1st exposure having more
% laps

figure
plot(mean(t1_norm,1,'omitnan'),'Color',PP.T1,'LineWidth',4)
hold on
x = 1:1:16;
shade1 = (mean(t1_norm,1,'omitnan') + std(t1_norm,1,'omitnan'));
shade2 = (mean(t1_norm,1,'omitnan') - std(t1_norm,1,'omitnan'));
x2 = [x,fliplr(x)];
inBetween = [shade1,fliplr(shade2)];
h=fill(x2,inBetween,PP.T1);
set(h,'facealpha',0.2,'LineStyle','none')
hold on

plot(mean(t2_norm,1,'omitnan'),'Color',[0.3 0.3 0.3],'LineWidth',4)
x = 1:1:8;
shade1 = (mean(t2_norm,1,'omitnan') + std(t2_norm,1,'omitnan'));
shade2 = (mean(t2_norm,1,'omitnan') - std(t2_norm,1,'omitnan'));
x2 = [x,fliplr(x)];
inBetween = [shade1,fliplr(shade2)];
h=fill(x2,inBetween,[0.6 0.6 0.6]);
set(h,'facealpha',0.2,'LineStyle','none')

plot(mean(t3_norm,1,'omitnan'),'Color',PP.T1,'LineWidth',4,'LineStyle',':')
x = 1:1:16;
shade1 = (mean(t3_norm,1,'omitnan') + std(t3_norm,1,'omitnan'));
shade2 = (mean(t3_norm,1,'omitnan') - std(t3_norm,1,'omitnan'));
x2 = [x,fliplr(x)];
inBetween = [shade1,fliplr(shade2)];
h=fill(x2,inBetween,PP.T1);
set(h,'facealpha',0.2,'LineStyle','none')

plot(mean(t4_norm,1,'omitnan'),'Color',[0.3 0.3 0.3],'LineWidth',4,'LineStyle',':')
x = 1:1:16;
shade1 = (mean(t4_norm,1,'omitnan') + std(t4_norm,1,'omitnan'));
shade2 = (mean(t4_norm,1,'omitnan') - std(t4_norm,1,'omitnan'));
x2 = [x,fliplr(x)];
inBetween = [shade1,fliplr(shade2)];
h=fill(x2,inBetween,[0.6 0.6 0.6]);
set(h,'facealpha',0.2,'LineStyle','none')

end
