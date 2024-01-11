% PLOT AVERAGE THETA SEQUENCE SCORES PER PROTOCOL FOR SPEED DATA
% MH 2020
% Loads theta sequence scores per track and session ('quantification_scores.mat', from extract_sessions_thetaseq_scores.mat). 
% First plot - For each quantification method (quadrant ratio, weighted corr, line fitting scores and slope), 
    % calculates the mean theta sequence per track and protocol (1,2,3,4,8,16 laps and re-exposures). Plots as a line plot with errorbars and sig values.
% Second plot - correlation heat map between 

function plot_protocol_thetaseq_scores_SPEED

PP = plotting_parameters;

path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Speed\Theta sequence scores\';
protocols = [1,16];
num_rats = 1;
load([path 'session_thetaseq_scores.mat'])
num_tracks = size(quantification_scores(1).scores,1);

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
f1.Name = 'Thetaseq scores all protocols';
measure = {'scores','pvals'};

% Creates structure where each line is a quantification method (QR, WR, LFscores,LF slopes) and each column is the mean theta seq score for a
% protocol (1,2,3,4,8,16,R-T1 and R-T2).
idx_limits = [];
count = 1;
for m = 1 : length(measure)
    for s = 1 : length(quantification_scores) % for each quantification method
        if strcmp(measure{m},'pvals')
            all_scores = nan(1*3,size(quantification_scores(1).scores,2)*4);
        else
            all_scores = nan(1,size(quantification_scores(1).scores,2)*4);
            non_sig_tracks = nan(1,size(quantification_scores(1).scores,2)*4);
        end
        c=1;
        t = 1; %track
        % Start with T2, separating by protocols (num laps)
        for p = 1 : length(protocols)
            if strcmp(measure{m},'pvals')
                first_exp_scores(s,t:t+num_tracks-1) = mean(cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(:,c:c+num_rats-1)),2);
                first_exp_STD(s,t:t+num_tracks-1) =  std(cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(:,c:c+num_rats-1)),[],2);
                all_scores(1:3*num_rats,t:t+num_tracks-1) = cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(:,c:c+num_rats-1))';
            else
                first_exp_scores(s,t:t+num_tracks-1) = mean(quantification_scores(s).(sprintf('%s',measure{m}))(:,c:c+num_rats-1),2);
                first_exp_STD(s,t:t+num_tracks-1) =  std(quantification_scores(s).(sprintf('%s',measure{m}))(:,c:c+num_rats-1),2);
                all_scores(1:length(quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_rats-1)),t:t+num_tracks-1) = quantification_scores(s).(sprintf('%s',measure{m}))(:,c:c+num_rats-1);
                non_sig_tracks(1:length(quantification_scores(s).theta_sig(:,c:c+num_rats-1)),p) = quantification_scores(s).theta_sig(:,c:c+num_rats-1);
            end
            c = c+num_rats;
            t = t+num_tracks;
        end


        % ONE WAY ANOVA to find differences between groups
        %     [pv,~,stats] =anova1(all_scores,[],'off');
        %     if pv <0.05
        %         [sig_gr,~,~,~] = multcompare(stats,[],'off');
        %         sig_idx =  find(sig_gr(:,6) < 0.05);
        %         idx_limits = [sig_gr(sig_idx,1) sig_gr(sig_idx,2)];
        %     end


        % Get color for protocols
        sessions_ID  = sprintfc('%d',protocols);
        color_idx = cell2mat(arrayfun(@(x) find(strcmp(fieldnames(PP),strcat('L', sessions_ID{x}))),1:length(sessions_ID),'UniformOutput',0));
        prot_colors = cell2mat(arrayfun(@(x) PP.(subsref(fieldnames(PP),substruct('{}',{x}))),color_idx,'UniformOutput',0)');
        cols = cell2mat(arrayfun(@(x) [prot_colors(x,:); prot_colors(x,:); [.3 .3 .3]; [.3 .3 .3]],1:size(prot_colors,1),'UniformOutput',0));
        cols = reshape(cols,length(protocols)*num_tracks,3);

        ax(count) = subplot(2,2,count);
        hold on
        xlabels = repmat({'T1', 'T2','RT1','RT2'},1,length(protocols));
        boxplot(all_scores,'PlotStyle','traditional','Colors',cols,'LabelOrientation','horizontal','Widths',0.2);
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        tt = get(a,'tag');   % List the names of all the objects
        idx = find(strcmpi(tt,'box')==1);  % Find Box objects
        boxes = a(idx);  % Get the children you need (boxes for first exposure)
        set(a,'LineWidth',3); % Set width
        set(boxes(1),'LineStyle',':')
        set(boxes(2),'LineStyle',':')
        box off
        hold on
        for ii = 1 : size(all_scores,2)
            if strcmp(measure{m},'pvals')
                if any(all_scores(:,ii) > 0.05)
                    not_sig = find(all_scores(:,ii)  > 0.05);
                    sig = find(all_scores(:,ii) < 0.05);
                    h = plot(ii,all_scores(sig,ii),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[1 1 1],'MarkerSize',6);
                    h = plot(ii,all_scores(not_sig,ii),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[0.3 0.3 0.3],'MarkerSize',6);
                else
                    h = plot(ii,all_scores(:,ii),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[1 1 1],'MarkerSize',6);
                end
            else
                if any(non_sig_tracks(:,ii) == 0)
                    not_sig = find(non_sig_tracks(:,ii) == 0);
                    sig = find(non_sig_tracks(:,ii) ==1);
                    h = plot(ii,all_scores(sig,ii),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[1 1 1],'MarkerSize',6);
                    h = plot(ii,all_scores(not_sig,ii),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[0.3 0.3 0.3],'MarkerSize',6);
                else
                    h = plot(ii,all_scores(:,ii),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[1 1 1],'MarkerSize',6);
                end
            end
        end
        plot(first_exp_scores(s,:),'LineWidth',2,'color','k')
        %errorbar(1:length(first_exp_scores(s,:)),first_exp_scores(s,:),first_exp_STD(s,:),'Color','k','CapSize',3,'LineWidth',1.5)
        if ~isempty(idx_limits)
            heights = 0;
            for i = 1 : size(idx_limits,1)
                errorbar1_height = first_exp_STD(s,idx_limits(i,1))+first_exp_scores(s,idx_limits(i,1));
                errorbar2_height = first_exp_STD(s,idx_limits(i,2))+first_exp_scores(s,idx_limits(i,2));
                max_height = max(errorbar1_height,errorbar2_height);
                if any(max_height == heights)
                    max_height = max(heights) + 0.03;
                    heights(i) = max_height;
                else
                    heights(i) = max_height;
                end
                star_pos = (idx_limits(i,2) - idx_limits(i,1))/2;
                plot([idx_limits(i,1) idx_limits(i,2)],[max_height+0.01 max_height+0.01],'Color','k','LineWidth',1)
                plot([idx_limits(i,1)+star_pos idx_limits(i,1)+star_pos],[max_height+0.02 max_height+0.02],'*','Color','k','MarkerSize',4)
            end
        end
        xlim([0.5 length(first_exp_scores(s,:))+0.5])
        xticklabels({'1', '2', '3', '4', '8', '16','RT1','RT2'})
        title(quantification_scores(s).method)
        xlabel('Laps')
        if strcmp(measure{m},'pvals')
            ylabel('P-values')
        else
            ylabel('Scores')
        end
        box off
        ax(count).FontSize = 15;

        count = count+1;
        clear first_exp_STD first_exp_scores
    end
end




%%%% TEMP CODE FOR TWO SESSIONS PRELIMINARY ANALYSIS
ax(count) = subplot(2,2,count);
scatter(1:length(all_scores),abs(all_scores),40,cols)
ax=gca;
ax.Children
ax.Children.MarkerFaceColor = 'flat';
ax.XTick = [1:8];
ax.XTickLabel = xlabels;
hold on
plot([4.5 4.5], [min(ylim) max(ylim)],'k')
scatter(1:length(all_scores),abs(all_scores),80,cols)

% for pval
boxplot(all_scores,'PlotStyle','traditional','Colors',cols,'LabelOrientation','horizontal','Widths',0.2);
 a = get(get(gca,'children'),'children');   % Get the handles of all the objects
 tt = get(a,'tag');   % List the names of all the objects
 idx = find(strcmpi(tt,'box')==1);  % Find Box objects
 boxes = a(idx);  % Get the children you need (boxes for first exposure)
 set(a,'LineWidth',3); % Set width
 set(boxes(1),'LineStyle',':')
 set(boxes(2),'LineStyle',':')
 box off
 hold on
 for ii = 1 : size(all_scores,2)
     if any(all_scores(:,ii) > 0.05)
         not_sig = find(all_scores(:,ii)  > 0.05);
         sig = find(all_scores(:,ii) < 0.05);
         if ~isempty(sig)
            h = plot(ii,all_scores(sig,ii),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[1 1 1],'MarkerSize',6);
         end
         h = plot(ii,all_scores(not_sig,ii),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[0.3 0.3 0.3],'MarkerSize',6);
     else
         h = plot(ii,all_scores(:,ii),'o','MarkerEdgeColor',[0.3 0.3 0.3],'MarkerFaceColor',[1 1 1],'MarkerSize',6);
     end

 end

% % HEATMAP OF SCORES CORRELATION
% correlation= corrcoef([first_exp_scores(1,:)' first_exp_scores(2,:)' first_exp_scores(3,:)' first_exp_scores(4,:)']); %in order QR,WR,LF scores and LF slopes
% f2 = figure;
% f2.Name = 'Heatmap theta seq scores correlation';
% axx1 = subplot(1,2,1);
% imagesc(correlation)
% colormap(jet)
% col =colorbar;
% col.Limits = [-1 1];
% xticks([1,2,3,4]); xticklabels({'QR','WR','LF-score','LF-slope'})
% yticks([1,2,3,4]); yticklabels({'QR','WR','LF-score','LF-slope'})
% title('Raw scores correlation')
% axx1.FontSize = 14;
%
% axx2 = subplot(1,2,2);
% imagesc(abs(correlation))
% colormap(jet)
% col =colorbar;
% col.Limits = [0 1];
% xticks([1,2,3,4]); xticklabels({'QR','WR','LF-score','LF-slope'})
% yticks([1,2,3,4]); yticklabels({'QR','WR','LF-score','LF-slope'})
% title('Abs scores correlation')
% axx2.FontSize = 14;




% Save figures
save_all_figures(path,[])

end