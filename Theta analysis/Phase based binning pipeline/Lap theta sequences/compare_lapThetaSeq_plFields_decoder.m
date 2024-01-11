% COMPARES THE SCORES FROM LAP THETA SEQUENCES WHEN USING PLACE FIELDS FROM
% THE WHOLE SESSION TO DECODE, OR (SMOOTH) PLACE FIELDS FROM EACH INDIVIDUAL LAP
% Also finds whether there is a significant difference of scores between
% early and late laps

function compare_lapThetaSeq_plFields_decoder(method)

load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\thetaseq_scores_individual_laps.mat')
load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Lap theta sequences\lap_thetaseq.mat')

PP = plotting_parameters;

if method == 1
    data = lap_WeightedCorr;
    quant = 'Weighted Correlation';
else
    data = lap_QuadrantRatio;
    quant = 'Quadrant Ratio';
end

% PREPARE DATA USING PLACE FIELDS FROM LAP
for t = 1 :4
    scores_lap{t} = [];
    for ii = 1 : length(data)
        scores_lap{t} = [scores_lap{t} data(ii).track(t).score];
    end
end

% PREPARE DATA USING WHOLE SESSION PLACE FIELDS
t1_idx = find([lap_thetaseq(:).track] == 1 & [lap_thetaseq(:).dir] == 3); % track 1 unidirectional
t3_idx = find([lap_thetaseq(:).track] == 3 & [lap_thetaseq(:).dir] == 3); % track 3 unidirectional

%Separate T2 in protocols (num laps)
protocols = [8,4,3,2,1];
for p = 1 : length(protocols)
    t4_idx{p} = find([lap_thetaseq(:).protocol] == protocols(p) & [lap_thetaseq(:).track] == 4 & [lap_thetaseq(:).dir] == 3); % track 4 unidirectional
    t2_idx{p} = find([lap_thetaseq(:).protocol] == protocols(p) & [lap_thetaseq(:).track] == 2 & [lap_thetaseq(:).dir] == 3); % track 2 unidirectional
end
indices = [{t1_idx},t2_idx,{t3_idx},t4_idx];
idx2 = [{t1_idx},{[t2_idx{:}]},{t3_idx},{[t4_idx{:}]}];

%concatenate sessions
 for t = 1 : 4
    idx = idx2{t};
    track_struct = lap_thetaseq(idx);
    scores_session{t} = [];
    for tt = 1 : length(track_struct)
        for lap = 1 : length(fieldnames(track_struct(tt)))-4
            if ~isempty(track_struct(tt).(strcat('Lap_',num2str(lap))))
                scores_session{t}  = [scores_session{t} track_struct(tt).(strcat('Lap_',num2str(lap))).weighted_corr];
            end
        end
    end
 end
 
 %%%% WILCOXON RANK SUM COMPARISON
 for t = 1 : 4
     if length(scores_lap{t}) < length(scores_session{t})
         diff_L = length(scores_session{t})-length(scores_lap{t});
         [pv{t},tbl{t},stats{t}] = ranksum(scores_lap{t}',scores_session{t}(1:end-diff_L)')
     elseif length(scores_lap{t}) > length(scores_session{t})
         diff_L = length(scores_lap{t})-length(scores_session{t});
         [pv{t},tbl{t},stats{t}] = ranksum(scores_lap{t}(1:end-diff_L)',scores_session{t}')
     else
         [pv{t},tbl{t},stats{t}] = ranksum(scores_lap{t}',scores_session{t}')
     end
 end

 %%%% Test if late vs early laps scores are sig different
    
 % Get all track scores
T1_scores = nan(length(data),16);
T2_scores = nan(length(data),8);
T3_scores = nan(length(data),16);
T4_scores = nan(length(data),16);

 for ii = 1 : length(data)
     T1_scores(ii,1:length(data(ii).track(1).score)) = data(ii).track(1).score;
     T2_scores(ii,1:length(data(ii).track(2).score)) = data(ii).track(2).score;
     T3_scores(ii,1:length(data(ii).track(3).score)) = data(ii).track(3).score;
     T4_scores(ii,1:length(data(ii).track(4).score)) = data(ii).track(4).score;
 end   
    
 [p_scores,tbl_scores,stats_scores] = kruskalwallis(T1_scores)
 [c,~,~,gnames] = multcompare(stats_scores);  
 sig_idx = find(c(:,6) < 0.05);
 sig_pairs = [c(sig_idx,1) ,c(sig_idx,2)];
    
 [p_scores2,tbl_scores2,stats_scores2] = kruskalwallis(T2_scores)
 [c2,~,~,gnames2] = multcompare(stats_scores2);  
 sig_idx2 = find(c2(:,6) < 0.05);
 sig_pairs2 = [c2(sig_idx2,1) ,c2(sig_idx2,2)];
 
  [p_scores3,tbl_scores3,stats_scores3] = kruskalwallis(T3_scores)
 [c3,~,~,gnames3] = multcompare(stats_scores3);  
 sig_idx3 = find(c3(:,6) < 0.05);
 sig_pairs3 = [c3(sig_idx3,1) ,c3(sig_idx3,2)];
 
 [p_scores4,tbl_scores4,stats_scores4] = kruskalwallis(T4_scores)
 [c4,~,~,gnames4] = multcompare(stats_scores4);  
 sig_idx4 = find(c4(:,6) < 0.05);
 sig_pairs4 = [c4(sig_idx4,1) ,c4(sig_idx4,2)];
 
 % PLOT SIG RESULTS
 col = repmat([0.3 0.3 0.3],[16,1]);
 figure 
 boxplot(T1_scores(:,1:16),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
 a = get(get(gca,'children'),'children');   % Get the handles of all the objects
 tt = get(a,'tag');   % List the names of all the objects
 idx = find(strcmpi(tt,'box')==1);  % Find Box objects
 boxes =a(idx);
 set(boxes,'LineWidth',2); % Set width
 box off
 ylabel('scores','FontSize',14)
 xlabel('Laps','FontSize',14)
 title('T1','FontSize',16);
 a = get(gca,'XTickLabel');
 set(gca,'XTickLabel',a,'fontsize',14)
 hold on
 for ii = 1 : 16
        plot(ii,T1_scores(:,ii),'o','MarkerEdgeColor',PP.T1,'MarkerFaceColor',PP.T1)
 end 

  col = repmat([0.3 0.3 0.3],[16,1]);
 figure 
 boxplot(T2_scores(:,1:8),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
 a = get(get(gca,'children'),'children');   % Get the handles of all the objects
 tt = get(a,'tag');   % List the names of all the objects
 idx = find(strcmpi(tt,'box')==1);  % Find Box objects
 boxes =a(idx);
 set(boxes,'LineWidth',2); % Set width
 box off
 ylabel('scores','FontSize',14)
 xlabel('Laps','FontSize',14)
 title('T2','FontSize',16);
 a = get(gca,'XTickLabel');
 set(gca,'XTickLabel',a,'fontsize',14)
 hold on
 for ii = 1 : 8
     %plot(ii,T2_scores(:,ii),'o','MarkerEdgeColor',[0.6 0.6 0.6],'MarkerFaceColor',[0.6 0.6 0.6])
     hold on
     plot(ii,T2_scores(1:4,ii),'o','MarkerEdgeColor',PP.T2(1,:),'MarkerFaceColor',PP.T2(1,:))
     plot(ii,T2_scores(5:8,ii),'o','MarkerEdgeColor',PP.T2(2,:),'MarkerFaceColor',PP.T2(2,:))
     plot(ii,T2_scores(9:12,ii),'o','MarkerEdgeColor',PP.T2(3,:),'MarkerFaceColor',PP.T2(3,:))
     plot(ii,T2_scores(13:16,ii),'o','MarkerEdgeColor',PP.T2(4,:),'MarkerFaceColor',PP.T2(4,:))
     plot(ii,T2_scores(17:20,ii),'o','MarkerEdgeColor',PP.T2(5,:),'MarkerFaceColor',PP.T2(5,:))
 end

 
  col = repmat([0.3 0.3 0.3],[16,1]);
 figure 
 boxplot(T3_scores(:,1:16),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
 a = get(get(gca,'children'),'children');   % Get the handles of all the objects
 tt = get(a,'tag');   % List the names of all the objects
 idx = find(strcmpi(tt,'box')==1);  % Find Box objects
 boxes =a(idx);
 set(boxes,'LineWidth',2); % Set width
 box off
 ylabel('scores','FontSize',14)
 xlabel('Laps','FontSize',14)
 title('T3','FontSize',16);
 a = get(gca,'XTickLabel');
 set(gca,'XTickLabel',a,'fontsize',14)
 hold on
 for ii = 1 : 16
        plot(ii,T3_scores(:,ii),'o','MarkerEdgeColor',PP.T1,'MarkerFaceColor',PP.T1)
 end 

  col = repmat([0.3 0.3 0.3],[16,1]);
 figure 
 boxplot(T4_scores(:,1:16),'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
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
 for ii = 1 : 16
     hold on
     plot(ii,T4_scores(1:4,ii),'o','MarkerEdgeColor',PP.T2(1,:),'MarkerFaceColor',PP.T2(1,:))
     plot(ii,T4_scores(5:8,ii),'o','MarkerEdgeColor',PP.T2(2,:),'MarkerFaceColor',PP.T2(2,:))
     plot(ii,T4_scores(9:12,ii),'o','MarkerEdgeColor',PP.T2(3,:),'MarkerFaceColor',PP.T2(3,:))
     plot(ii,T4_scores(13:16,ii),'o','MarkerEdgeColor',PP.T2(4,:),'MarkerFaceColor',PP.T2(4,:))
     plot(ii,T4_scores(17:20,ii),'o','MarkerEdgeColor',PP.T2(5,:),'MarkerFaceColor',PP.T2(5,:))
 end 

 
 temp_mat_5laps = [T1_scores(:,1:5) T2_scores(:,1:5) T3_scores(:,1:5) T4_scores(:,1:5)];
  col = [repmat([0.3 0.3 0.3],[5,1]) ;repmat([0.4 0 0],[5,1]); repmat([0.2 0 0.8],[5,1]); repmat([0 0.4 0.2],[5,1])];
  figure 
 boxplot(temp_mat_5laps,'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
 a = get(get(gca,'children'),'children');   % Get the handles of all the objects
 tt = get(a,'tag');   % List the names of all the objects
 idx = find(strcmpi(tt,'box')==1);  % Find Box objects
 boxes =a(idx);
 set(boxes,'LineWidth',2); % Set width
 box off

 tst2 = [];
 tst1 = [];
 for jj = 1 : 5
     tst2 = [tst2 mean([T3_scores(:,jj) T4_scores(:,jj)],2)];
     tst1 = [tst1 mean([T1_scores(:,jj) T2_scores(:,jj)],2)];
 end
col = [repmat([0.3 0.3 0.3],[5,1]);[1 1 1]; repmat([0.6 0.6 0.6],[5,1])];
 figure 
 boxplot([tst1 nan(20,1) tst2],'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
 a = get(get(gca,'children'),'children');   % Get the handles of all the objects
 tt = get(a,'tag');   % List the names of all the objects
 idx = find(strcmpi(tt,'box')==1);  % Find Box objects
 boxes =a(idx);
 set(boxes,'LineWidth',2); % Set width
 box off
 
 mats=[tst1 nan(20,1) tst2];
 for jj = 1 : 11
     hold on
     if jj > 6
         plot(jj,mats(:,jj),'o','MarkerFaceColor',[0.6 0.6 0.6],'MarkerEdgeColor',[0.6 0.6 0.6])
     else
         plot(jj,mats(:,jj),'o','MarkerFaceColor',[0.3 0.3 0.3],'MarkerEdgeColor',[0.3 0.3 0.3])       
     end
 end
 
  
 [p_5laps,tbl__5laps,stats__5laps] = kruskalwallis([tst1 tst2])
 [c5,~,~,gnames5] = multcompare(stats__5laps);  
 sig_idx5 = find(c5(:,6) < 0.05);
 sig_pairs5 = [c5(sig_idx5,1) ,c5(sig_idx5,2)];
 
 
 
 tst44 = [];
 idxs = [1,2,3,4,8];
 for jj = 1 : length(idxs)
     tst44 = [tst44 mean([T1_scores(:,idxs(jj)) T2_scores(:,idxs(jj))],2)];
 end
 tst44 = [tst44 [T1_scores(:,16)]];
 
col = [repmat([0.3 0.3 0.3],[6,1])];
cols = [flipud(PP.T2);PP.T1]
 figure 
 boxplot(tst44,'PlotStyle','traditional','Color',cols,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
 a = get(get(gca,'children'),'children');   % Get the handles of all the objects
 tt = get(a,'tag');   % List the names of all the objects
 idx = find(strcmpi(tt,'box')==1);  % Find Box objects
 boxes =a(idx);
 set(boxes,'LineWidth',2); % Set width
 box off
 whiskers = [find(strcmpi(tt,'Lower Whisker')); find(strcmpi(tt,'Upper Whisker'))];
 set(a(whiskers),'LineStyle','-','LineWidth',1)
 medians = find(strcmpi(tt,'Median'));
 set(a(medians),'LineWidth',2)

 for jj = 1 : size(tst44,2)
     hold on
     if jj > 6
         plot(jj,tst44(:,jj),'o','MarkerFaceColor','w','MarkerEdgeColor',cols(jj,:))
     else
         plot(jj,tst44(:,jj),'o','MarkerFaceColor','w','MarkerEdgeColor',cols(jj,:),'LineWidth',1.5)       
     end
 end
 
 set(gcf,'Color','w')
 xlabel('Number of laps run')
 ylabel('Theta sequence scores')
 set(gca,'FontSize',14)
 set(gca,'LineWidth',1.5)
 xticklabels({'1','2','3','4','8','16'})
 yticks([0:0.1:0.3])
 
  [p_firstexp1,~] = ranksum(tst44(:,1), tst44(:,6));
  [p_firstexp2,~] = ranksum(tst44(:,2), tst44(:,6));
  [p_firstexp3,~] = ranksum(tst44(:,3), tst44(:,6));
  [p_firstexp4,~] = ranksum(tst44(:,4), tst44(:,6));
  [p_firstexp5,~] = ranksum(tst44(:,5), tst44(:,6));


 %max_val = max([T3_scores(:,1);T1_scores(:,1);T2_scores(1:4,8);T2_scores(5:8,4);T2_scores(9:12,3);T2_scores(13:16,2);T2_scores(17:20,1);T4_scores(:,1)]);
  
 t1diff = 1-((T3_scores(:,1)- T1_scores(:,1))./max([T3_scores(:,1) T1_scores(:,1)],[],2));
 t28diff = [1-((T4_scores(1:4,1)- T2_scores(1:4,8))./max([T4_scores(1:4,1) T2_scores(1:4,8)],[],2)); nan(16,1)];
 t24diff = [1-((T4_scores(5:8,1)- T2_scores(5:8,4))./max([T4_scores(5:8,1) T2_scores(5:8,4)],[],2)); nan(16,1)];
 t23diff = [1-((T4_scores(9:12,1)- T2_scores(9:12,3))./max([T4_scores(9:12,1) T2_scores(9:12,3)],[],2)); nan(16,1)];
 t22diff = [1-((T4_scores(13:16,1) - T2_scores(13:16,2))./max([T4_scores(13:16,1) T2_scores(17:20,1)],[],2)); nan(16,1)];
 t21diff = [1-((T4_scores(17:20,1) - T2_scores(17:20,1))./max([T4_scores(17:20,1) T2_scores(17:20,1)],[],2)); nan(16,1)];
 mat2 = [t1diff,t28diff,t24diff,t23diff,t22diff,t21diff];
%  t1diff = mean(T3_scores(:,1:5),2)- T1_scores(:,1);
%  t28diff = [mean(T4_scores(1:4,1:5),2) - T2_scores(1:4,8); nan(16,1)];
%  t24diff = [mean(T4_scores(5:8,1:5),2)- T2_scores(5:8,4); nan(16,1)];
%  t23diff = [mean(T4_scores(9:12,1:5),2)- T2_scores(9:12,3); nan(16,1)];
%  t22diff = [mean(T4_scores(13:16,1:5),2) - T2_scores(13:16,2); nan(16,1)];
%  t21diff = [mean(T4_scores(17:20,1:5),2) - T2_scores(17:20,1); nan(16,1)];
%  mat2 = [t1diff,t28diff,t24diff,t23diff,t22diff,t21diff];

 %max_diff = max(max(mat));
 %mat2 = mat/max_diff;
 
figure
boxplot(mat2,'Color',[0.6 0.6 0.6])
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes = a(idx);  % Get the children you need (boxes for first exposure)
set(a,'LineWidth',1); % Set width
idx1 = find(strcmp(tt,'Outliers'));
delete(a(idx1))
idx2 = [find(strcmp(tt,'Upper Whisker')) find(strcmp(tt,'Lower Whisker'))];
set(a(idx2),'LineStyle','-'); % Set width
set(a(idx2),'LineWidth',0.5); % Set width
idx3 = [find(strcmp(tt,'Upper Adjacent Value')) find(strcmp(tt,'Lower Adjacent Value'))];
set(a(idx3),'LineWidth',0.5); % Set width
box off
hold on

cols = [PP.T1; PP.T2];
for j = 1 : 6
    plot(j,mat2(:,j),'o','MarkerFaceColor',cols(j,:),'MarkerEdgeColor',cols(j,:),'MarkerSize',6)
end
 
 plot([min(xlim) max(xlim)],[0 0],'--','Color',[.3 .3 .3])
 
end