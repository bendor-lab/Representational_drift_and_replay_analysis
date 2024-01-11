% PLOT AVERAGE THETA SEQUENCE SCORES PER PROTOCOL
% MH 2020
% Loads theta sequence scores per track and session ('quantification_scores.mat' from extract_sessions_thetaseq_scores.mat). 
% First plot - For each quantification method (quadrant ratio, weighted corr, line fitting scores and slope), 
    % calculates the mean theta sequence per track and protocol (1,2,3,4,8,16 laps and re-exposures). Plots as a line plot with errorbars and sig values.
% Second plot - correlation heat map between 

function plot_protocol_thetaseq_scores(bayesian_control)

PP = plotting_parameters;
if isempty(bayesian_control)
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\session_thetaseq_scores.mat')
else
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\Bayesian controls\session_thetaseq_scores.mat')
end

f1 = figure('units','normalized','Color','w','Name','Thetaseq scores all protocols');
tiledlayout('flow')
protocols = [1,2,3,4,8];
measure = {'scores','pvals'};
% Creates structure where each line is a quantification method (QR, WR, LFscores,LF slopes) and each column is the mean theta seq score for a
% protocol (1,2,3,4,8,16,R-T1 and R-T2).
idx_limits = [];
count = 1;
for m = 1 : length(measure)
    for s = 1 : length(quantification_scores) % for each quantification method
        if strcmp(measure{m},'pvals')
            %all_scores = nan(57,8);
            all_scores = nan(19,8);
        else
            all_scores = nan(19,8);
            non_sig_tracks = nan(19,8);
        end
        c=1;
        % Start with T2, separating by protocols (num laps)
        for p = 1 : length(protocols)
            if p == 2 
                num_sess = 3;
            else
                num_sess = 4;
            end
            if strcmp(measure{m},'pvals')
                 % Using all shuffles pvalues
                %first_exp_scores(s,p) = mean(cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_sess-1)));
                %first_exp_STD(s,p) =  std(cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_sess-1)));
                %all_scores(1:length(cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_sess-1))),p) = cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_sess-1));
                
                 % Using one shuffle (max pval)
                first_exp_scores(s,p) = mean(cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_sess-1))); 
                first_exp_STD(s,p) =  std(cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_sess-1))); 
                all_scores(1:length(cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_sess-1))),p) = cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_sess-1));
            else
                first_exp_scores(s,p) = mean(quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_sess-1));
                first_exp_STD(s,p) =  std(quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_sess-1));
                all_scores(1:length(quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_sess-1)),p) = quantification_scores(s).(sprintf('%s',measure{m}))(2,c:c+num_sess-1);
                non_sig_tracks(1:length(quantification_scores(s).theta_sig(2,c:c+num_sess-1)),p) = quantification_scores(s).theta_sig(2,c:c+num_sess-1);
            end
             c=c+num_sess;
        end
        first_exp_scores(s,1:5) = flip(first_exp_scores(s,1:5)); %reverse order so that it starts by 1 Lap
        first_exp_STD(s,1:5) = flip(first_exp_STD(s,1:5));
        all_scores = fliplr(all_scores(:,1:5));

        if strcmp(measure{m},'pvals')
             % Using all shuffles pvalues
            %first_exp_scores(s,6:8) = [mean(cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(1,:))) mean(cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(3,:))) mean(cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(4,:)))];
            %first_exp_STD(s,6:8) = [std(cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(1,:))) std(cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(3,:)))  std(cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(4,:)))];
            %all_scores(:,6:8) = [cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(1,:))' cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(3,:))'  cell2mat(quantification_scores(s).(sprintf('%s',measure{m}))(4,:))'];

             % Using one shuffle (max pval)
            first_exp_scores(s,6:8) = [mean(cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(1,:))) mean(cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(3,:))) mean(cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(4,:)))];
            first_exp_STD(s,6:8) = [std(cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(1,:))) std(cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(3,:)))  std(cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(4,:)))];
            all_scores(:,6:8) = [cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(1,:))' cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(3,:))'  cellfun(@max,quantification_scores(s).(sprintf('%s',measure{m}))(4,:))'];


        else
            non_sig_tracks = fliplr(non_sig_tracks(:,1:5));
            % Add tracks 1 3 and 4
            first_exp_scores(s,6:8) = [mean(quantification_scores(s).(sprintf('%s',measure{m}))(1,:)) mean(quantification_scores(s).(sprintf('%s',measure{m}))(3,:)) mean(quantification_scores(s).(sprintf('%s',measure{m}))(4,:))];
            first_exp_STD(s,6:8) = [std(quantification_scores(s).(sprintf('%s',measure{m}))(1,:)) std(quantification_scores(s).(sprintf('%s',measure{m}))(3,:))  std(quantification_scores(s).(sprintf('%s',measure{m}))(4,:))];
            all_scores(:,6:8) = [(quantification_scores(s).(sprintf('%s',measure{m}))(1,:))' (quantification_scores(s).(sprintf('%s',measure{m}))(3,:))'  (quantification_scores(s).(sprintf('%s',measure{m}))(4,:))'];
            non_sig_tracks(:,6:8) = [(quantification_scores(s).theta_sig(1,:))' (quantification_scores(s).theta_sig(3,:))'  (quantification_scores(s).theta_sig(4,:))'];
        end
        
        % ONE WAY ANOVA to find differences between groups
        %     [pv,~,stats] =anova1(all_scores,[],'off');
        %     if pv <0.05
        %         [sig_gr,~,~,~] = multcompare(stats,[],'off');
        %         sig_idx =  find(sig_gr(:,6) < 0.05);
        %         idx_limits = [sig_gr(sig_idx,1) sig_gr(sig_idx,2)];
        %     end
        
        %ax(count) = subplot(2,2,count);
        nexttile
        hold on
        %cols = repmat([0.3 0.3 0.3],8,1);
        cols = [PP.T2(5,:);PP.T2(4,:);PP.T2(3,:);PP.T2(2,:);PP.T2(1,:);PP.T1;[0.3 0.3 0.3];[0.6 0.6 0.6]];
        xlabels = {'1', '2', '3', '4', '8', '16','RT1','RT2'};
        boxplot(all_scores,'PlotStyle','traditional','Colors',cols,'Labels',xlabels,'LabelOrientation','horizontal','Widths',0.5);
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        tt = get(a,'tag');   % List the names of all the objects
        idx = find(strcmpi(tt,'box')==1);  % Find Box objects
        boxes = a(idx);  % Get the children you need (boxes for first exposure)
        set(a,'LineWidth',2); % Set width
        %set(boxes(1),'LineStyle',':')
        %set(boxes(2),'LineStyle',':')
        whisk = a([find(strcmpi(tt,'Lower Whisker')==1) find(strcmpi(tt,'Upper Whisker')==1)...
            find(strcmpi(tt,'Upper Adjacent Value')==1)  find(strcmpi(tt,'Lower Adjacent Value')==1) ]);  % Find whiskers objects
        set(whisk,'LineWidth',1.5,'LineStyle','-')
        med = a(find(strcmpi(tt,'Median')==1));  % Find median objects
        set(med,'LineWidth',2)
        box off
        hold on
        for ii = 1 : size(all_scores,2)
            if strcmp(measure{m},'pvals')
                if any(all_scores(:,ii) > 0.05)
                    not_sig = find(all_scores(:,ii)  > 0.05);
                    sig = find(all_scores(:,ii) < 0.05);
                    if ~isempty(sig)
                        h = plot(ii,all_scores(sig,ii),'o','MarkerEdgeColor',cols(ii,:),'MarkerFaceColor',[1 1 1],'MarkerSize',6);
                    end
                    if ~isempty(not_sig)
                        h = plot(ii,all_scores(not_sig,ii),'o','MarkerEdgeColor',cols(ii,:),'MarkerFaceColor',[0.3 0.3 0.3],'MarkerSize',6);
                    end
                else
                    h = plot(ii,all_scores(:,ii),'o','MarkerEdgeColor',cols(ii,:),'MarkerFaceColor',[1 1 1],'MarkerSize',6);
                end
            else
                if any(non_sig_tracks(:,ii) == 0)
                    not_sig = find(non_sig_tracks(:,ii) == 0);
                    sig = find(non_sig_tracks(:,ii) ==1);
                    if ~isempty(sig)
                        h = plot(ii,all_scores(sig,ii),'o','MarkerEdgeColor',cols(ii,:),'MarkerFaceColor',[1 1 1],'MarkerSize',6);
                    end
                    if ~isempty(not_sig)
                        h = plot(ii,all_scores(not_sig,ii),'o','MarkerEdgeColor',cols(ii,:),'MarkerFaceColor',[0.3 0.3 0.3],'MarkerSize',6);
                    end
                else
                    h = plot(ii,all_scores(:,ii),'o','MarkerEdgeColor',cols(ii,:),'MarkerFaceColor',[1 1 1],'MarkerSize',6);
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
        set(gca,'FontSize',15)

        [p13,~]=ranksum([all_scores(:,5)]',all_scores(:,8)');
        [p23,~]=ranksum([all_scores(:,4)]',all_scores(:,8)');
        [p33,~]=ranksum([all_scores(:,3)]',all_scores(:,8)');
        [p43,~]=ranksum([all_scores(:,2)]',all_scores(:,8)');
        [p53,~]=ranksum([all_scores(:,1)]',all_scores(:,8)');

        [p63,~]=ranksum([all_scores(:,7)]',all_scores(:,8)');

    end
end
allAxesInFigure = findall(f1,'type','axes');
set(allAxesInFigure,'TickDir','out','TickLength',[.005 1],'LineWidth',1.5)

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
allax = findobj(gcf,'Type','axes');
set(allax(3:4),'ylim',[-0.1 0.3]);
set(allax(1:2),'ylim',[-0.05 1]);
save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores',[])

end