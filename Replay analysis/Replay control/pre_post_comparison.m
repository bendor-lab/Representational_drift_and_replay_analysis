% COMPARES SIGNIFICANT EVENTS BETWEEN PRE AND POST
% INPUT:
    % State: 'sleep' for only sleep replay, or 'ALL' for both sleep and awake replay


function pre_post_comparison(state,method)

% Load replay information
if strcmp(method,'wcorr')
    cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis')
    load extracted_time_periods_replay.mat
    load extracted_replay_plotting_info_MultiEvents.mat
elseif strcmp(method,'spearman')
    cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Spearman')
    load extracted_time_periods_replay.mat
    load extracted_replay_plotting_info.mat
end

PP = plotting_parameters;

for s = 1 : length(track_replay_events)
    
    %%%%%% Extract number of PRE events per track and divide by cumulative slept and awake time
    if isempty(period_time(s).PRE.sleep_cumulative_time)
        time_slept = 1; %if no sleep divide by 1, because 0/0=NAN
    else
        time_slept = period_time(s).PRE.sleep_cumulative_time(end)/60;
    end
    if isempty(period_time(s).PRE.awake_cumulative_time)
        time_awake= 1;
    else
        time_awake = period_time(s).PRE.awake_cumulative_time(end)/60;
    end
    
    if strcmp(state,'sleep')
        
        PRE_events(s,1) = (length(track_replay_events(s).T1.PRE_sleep_times)/time_slept);
        PRE_events(s,2) = (length(track_replay_events(s).T2.PRE_sleep_times)/time_slept);
        PRE_events(s,3) = (length(track_replay_events(s).T3.PRE_sleep_times)/time_slept);
        PRE_events(s,4) = (length(track_replay_events(s).T4.PRE_sleep_times)/time_slept);
        
    elseif strcmp(state,'ALL')
        PRE_events(s,1) = (length(track_replay_events(s).T1.PRE_sleep_times)/time_slept) + (length(track_replay_events(s).T1.PRE_awake_times)/time_awake);
        PRE_events(s,2) = (length(track_replay_events(s).T2.PRE_sleep_times)/time_slept) + (length(track_replay_events(s).T2.PRE_awake_times)/time_awake);
        PRE_events(s,3) = (length(track_replay_events(s).T3.PRE_sleep_times)/time_slept) + (length(track_replay_events(s).T3.PRE_awake_times)/time_awake);
        PRE_events(s,4) = (length(track_replay_events(s).T4.PRE_sleep_times)/time_slept) + (length(track_replay_events(s).T4.PRE_awake_times)/time_awake);
        
        if strcmp(method,'wcorr')
            % Extract score of PRE events per track
            PRE_bayesianBias{s,1} = [track_replay_events(s).T1.bayesian_bias_all_sig_events(track_replay_events(s).T1.PRE_sleep_index) track_replay_events(s).T1.bayesian_bias_all_sig_events(track_replay_events(s).T1.PRE_awake_index)];
            PRE_bayesianBias{s,2} = [track_replay_events(s).T2.bayesian_bias_all_sig_events(track_replay_events(s).T2.PRE_sleep_index) track_replay_events(s).T2.bayesian_bias_all_sig_events(track_replay_events(s).T2.PRE_awake_index)];
            PRE_bayesianBias{s,3} = [track_replay_events(s).T3.bayesian_bias_all_sig_events(track_replay_events(s).T3.PRE_sleep_index) track_replay_events(s).T3.bayesian_bias_all_sig_events(track_replay_events(s).T3.PRE_awake_index)];
            PRE_bayesianBias{s,4} = [track_replay_events(s).T4.bayesian_bias_all_sig_events(track_replay_events(s).T4.PRE_sleep_index) track_replay_events(s).T4.bayesian_bias_all_sig_events(track_replay_events(s).T4.PRE_awake_index)];
        end
    end
    
    %%%%%%%%% Extract number of INTER POST events per track
    if isempty(period_time(s).INTER_post.sleep_cumulative_time)
        time_slept = 1;
    else
        time_slept = period_time(s).INTER_post.sleep_cumulative_time(end)/60;
    end
    if isempty(period_time(s).INTER_post.awake_cumulative_time)
        time_awake= 1;
    else
        time_awake = period_time(s).INTER_post.awake_cumulative_time(end);
    end
    
    if strcmp(state,'sleep')
        
        INTER_events(s,1) = (length(track_replay_events(s).T1.INTER_post_sleep_times) /time_slept);
        INTER_events(s,2) = (length(track_replay_events(s).T2.INTER_post_sleep_times) /time_slept);
        INTER_events(s,3) = (length(track_replay_events(s).T3.INTER_post_sleep_times) /time_slept);
        INTER_events(s,4) = (length(track_replay_events(s).T4.INTER_post_sleep_times) /time_slept);
        
    elseif strcmp(state,'ALL')
        
        INTER_events(s,1) = (length(track_replay_events(s).T1.INTER_post_sleep_times) /time_slept) + (length(track_replay_events(s).T1.INTER_post_awake_times)/time_awake);
        INTER_events(s,2) = (length(track_replay_events(s).T2.INTER_post_sleep_times) /time_slept) + (length(track_replay_events(s).T2.INTER_post_awake_times)/time_awake);
        INTER_events(s,3) = (length(track_replay_events(s).T3.INTER_post_sleep_times) /time_slept) + (length(track_replay_events(s).T3.INTER_post_awake_times)/time_awake);
        INTER_events(s,4) = (length(track_replay_events(s).T4.INTER_post_sleep_times) /time_slept) + (length(track_replay_events(s).T4.INTER_post_awake_times)/time_awake);
        
        if strcmp(method,'wcorr')
            % Extract score of POST events per track
            INTER_POST_bayesianBias{s,1} = [track_replay_events(s).T1.bayesian_bias_all_sig_events(track_replay_events(s).T1.INTER_post_sleep_index) track_replay_events(s).T1.bayesian_bias_all_sig_events(track_replay_events(s).T1.INTER_post_awake_index)];
            INTER_POST_bayesianBias{s,2} = [track_replay_events(s).T2.bayesian_bias_all_sig_events(track_replay_events(s).T2.INTER_post_sleep_index) track_replay_events(s).T2.bayesian_bias_all_sig_events(track_replay_events(s).T2.INTER_post_awake_index)];
            INTER_POST_bayesianBias{s,3} = [track_replay_events(s).T3.bayesian_bias_all_sig_events(track_replay_events(s).T3.INTER_post_sleep_index) track_replay_events(s).T3.bayesian_bias_all_sig_events(track_replay_events(s).T3.INTER_post_awake_index)];
            INTER_POST_bayesianBias{s,4} = [track_replay_events(s).T4.bayesian_bias_all_sig_events(track_replay_events(s).T4.INTER_post_sleep_index) track_replay_events(s).T4.bayesian_bias_all_sig_events(track_replay_events(s).T4.INTER_post_awake_index)];
        end
    end
    %%%%%%%%% Extract number of FINAL POST events per track
    if isempty(period_time(s).FINAL_post.sleep_cumulative_time)
        time_slept = 1;
    else
        time_slept = period_time(s).FINAL_post.sleep_cumulative_time(end)/60;
    end
    if isempty(period_time(s).FINAL_post.awake_cumulative_time)
        time_awake= 1;
    else
        time_awake = period_time(s).FINAL_post.awake_cumulative_time(end);
    end
    
    if strcmp(state,'sleep')
        
        FINAL_events(s,1) = (length(track_replay_events(s).T1.FINAL_post_sleep_times) /time_slept);
        FINAL_events(s,2) = (length(track_replay_events(s).T2.FINAL_post_sleep_times) /time_slept);
        FINAL_events(s,3) = (length(track_replay_events(s).T3.FINAL_post_sleep_times) /time_slept);
        FINAL_events(s,4) = (length(track_replay_events(s).T4.FINAL_post_sleep_times) /time_slept);
        
    elseif strcmp(state,'ALL')
        
        FINAL_events(s,1) = (length(track_replay_events(s).T1.FINAL_post_sleep_times) /time_slept) + (length(track_replay_events(s).T1.FINAL_post_awake_times)/time_awake);
        FINAL_events(s,2) = (length(track_replay_events(s).T2.FINAL_post_sleep_times) /time_slept) + (length(track_replay_events(s).T2.FINAL_post_awake_times)/time_awake);
        FINAL_events(s,3) = (length(track_replay_events(s).T3.FINAL_post_sleep_times) /time_slept) + (length(track_replay_events(s).T3.FINAL_post_awake_times)/time_awake);
        FINAL_events(s,4) = (length(track_replay_events(s).T4.FINAL_post_sleep_times) /time_slept) + (length(track_replay_events(s).T4.FINAL_post_awake_times)/time_awake);
        
        if strcmp(method,'wcorr')
            % Extract score of POST events per track
            FINAL_POST_bayesianBias{s,1} = [track_replay_events(s).T1.bayesian_bias_all_sig_events(track_replay_events(s).T1.FINAL_post_sleep_index) track_replay_events(s).T1.bayesian_bias_all_sig_events(track_replay_events(s).T1.FINAL_post_awake_index)];
            FINAL_POST_bayesianBias{s,2} = [track_replay_events(s).T2.bayesian_bias_all_sig_events(track_replay_events(s).T2.FINAL_post_sleep_index) track_replay_events(s).T2.bayesian_bias_all_sig_events(track_replay_events(s).T2.FINAL_post_awake_index)];
            FINAL_POST_bayesianBias{s,3} = [track_replay_events(s).T3.bayesian_bias_all_sig_events(track_replay_events(s).T3.FINAL_post_sleep_index) track_replay_events(s).T3.bayesian_bias_all_sig_events(track_replay_events(s).T3.FINAL_post_awake_index)];
            FINAL_POST_bayesianBias{s,4} = [track_replay_events(s).T4.bayesian_bias_all_sig_events(track_replay_events(s).T4.FINAL_post_sleep_index) track_replay_events(s).T4.bayesian_bias_all_sig_events(track_replay_events(s).T4.FINAL_post_awake_index)];
        end
    end
    
end


cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Controls comparion')
axes = Pre_vs_Post_events_makeFigure;
protocols = [8,4,3,2,1];
c = 1;
for p = 1 : length(protocols)
   
    col = [PP.P(p).colorT(1,:);PP.P(p).colorT(2,:);PP.P(p).colorT(3,:);PP.P(p).colorT(4,:);PP.P(p).colorT(1,:);PP.P(p).colorT(2,:);PP.P(p).colorT(3,:);PP.P(p).colorT(4,:);...
        PP.P(p).colorT(1,:);PP.P(p).colorT(2,:);PP.P(p).colorT(3,:);PP.P(p).colorT(4,:)];
    x_labels = {'T1','T2','R-T1','R-T2','T1','T2','R-T1','R-T2','T1','T2','R-T1','R-T2'}; %set labels for X axis
    boxplot(axes(p),[PRE_events(c:c+3,1:4) INTER_events(c:c+3,1:4) FINAL_events(c:c+3,1:4)],'PlotStyle','traditional','Colors',col,'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
    a = get(get(axes(p),'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([3,4,7,8,11,12]));  % Get the children you need (boxes for first exposure)
    boxes2 = a(idx([1,2,5,6,9,10])); % Get the children you need (boxes for second exposure)
    set(boxes,'LineWidth',2); % Set width
    set(boxes2,'LineStyle',':'); % Set line style for re-exposure plots
    set(boxes2,'LineWidth',2); % Set width
    box(axes(p),'off')
    ylabel(axes(p),'norm # events')
    title(axes(p),'')
    %title(strcat('PRE events - Protocol 16x',num2str(protocols(p))));
    hold on
    for ii = 1 : 4
        hh = plot(axes(p),ii,PRE_events(c:c+3,ii),'o','MarkerEdgeColor',PP.P(p).colorT(ii,:),'MarkerFaceColor',PP.P(p).colorT(ii,:));
        set(hh,{'Marker'},{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6},'MarkerFaceColor','w','LineWidth',1.5);
        h = plot(axes(p),ii+4,INTER_events(c:c+3,ii),'o','MarkerEdgeColor',PP.P(p).colorT(ii,:),'MarkerFaceColor',PP.P(p).colorT(ii,:));
        set(h,{'Marker'},{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6},'MarkerFaceColor','w','LineWidth',1.5);
        h2 = plot(axes(p),ii+8,FINAL_events(c:c+3,ii),'o','MarkerEdgeColor',PP.P(p).colorT(ii,:),'MarkerFaceColor',PP.P(p).colorT(ii,:));
        set(h2,{'Marker'},{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6},'MarkerFaceColor','w','LineWidth',1.5);

    end

    
    %%%% EVALUATE SIGNIFICANCE 
    % First test whether pre,inter and final are different with Friedman's test. It is a non-arametric repeated measures ANOVA.
    % If it's significant, then use Wilcoxon rank test to compare pairs.
    % Correct multiple comparisons using the Holm-Bonferroni correction:
    % ranks pvalues from lower to higher and then divide by n-i+1 (where i is the order of pvalues ranked from small to high)

     [pvalue,~,stats] = friedman([PRE_events(c:c+3,1:4) INTER_events(c:c+3,1:4) FINAL_events(c:c+3,1:4)],1,'off');
    
    if pvalue < 0.05
        for i = 1 : 4 % for each track
            %[~,pval(comp,i)] = ttest(PRE_events(c:c+3,i),INTER_events(c:c+3,i)); % Dependent t-test
            [pval(1,i),~,~] = signrank(PRE_events(c:c+3,i),INTER_events(c:c+3,i),'tail','right'); % wilcoxon
            [pval(2,i),~,~] = signrank(PRE_events(c:c+3,i),FINAL_events(c:c+3,i),'tail','right');% wilcoxon
            [pval(3,i),~,~] = signrank(INTER_events(c:c+3,i),FINAL_events(c:c+3,i),'tail','right'); % wilcoxon
        end
        % Rank p-vals in each track (each column) and apply Holm-Bonferroni correction
        [sorted_pval,idx] = sort(pval,1);
        sig_diff = [];
        for i = 1 : 4 % for each track
            if sorted_pval(1,i)< 0.05/length(pval(:,1)) %if the smallest pval is sig, save and continue
                sig_diff(i) = idx(1);
                if sorted_pval(2,i)< 0.05/(length(pval(:,1))-1) %if the next pval is sig, save and continue
                    sig_diff(i,2) = idx(2);
                    if sorted_pval(3,i)< 0.05/(length(pval(:,1))-2) %if the next pval is sig, save and continue
                        sig_diff(i,3) = idx(3);
                    end
                end
            end
        end
    
    end
    
    

    % Dependent t-test
    for i = 1 : 4
        %[~,pval(i)] = ttest(PRE_events(c:c+3,i),INTER_events(c:c+3,i));
        [pval(i),~] = signrank(PRE_events(c:c+3,i),INTER_events(c:c+3,i),'tail','right');
    end
    sig_diff_05_idx = find(pval < 0.05 & pval > 0.01);
    sig_diff_01_idx = find(pval < 0.01 & pval > 0.001);
    sig_diff_001_idx = find(pval < 0.001);

    if ~isempty([sig_diff_05_idx sig_diff_01_idx sig_diff_001_idx])
        maxy = max(ylim(axes(p)));
        miny = min(ylim(axes(p)));
        ylim((axes(p)),[miny , maxy+(length([sig_diff_05_idx sig_diff_01_idx sig_diff_001_idx])*0.04)])
        
        % Add sig bars
        cc = 1;
        for ii = 1 : length([sig_diff_05_idx sig_diff_01_idx sig_diff_001_idx])
            all_idx = [sig_diff_05_idx sig_diff_01_idx sig_diff_001_idx];
            idx = all_idx(ii);
            dist = maxy+0.01 + (0.01*(cc-1));
            dist_s = dist + 0.03;
            hold on
            plot(axes(p),[idx idx+4], [dist dist], '-k', 'LineWidth',0.7)
            x = (idx+idx+4)/2;
            if any(sig_diff_05_idx == idx)              
                plot(axes(p),[x x], [dist_s dist_s], '*k','MarkerSize',3.5)
                cc = cc+1;
            elseif any(sig_diff_01_idx == idx)
                hold on
                plot(axes(p),x:0.1:x+0.1, ones(2,1)*dist_s, '*k','MarkerSize',3.5)
                cc = cc+1;
            elseif any(sig_diff_001_idx == idx)
                hold on
                plot(axes(p),x:0.1:x+0.2, ones(3,1)*dist_s, '*k','MarkerSize',3.5)
                cc = cc+1;
            end
        end
    end
    
    c = c + 4;     
end

linkaxes(axes)
for i = 1 : length(axes)
    plot(axes(i),[4.5 4.5],[min(ylim(axes(p))) max(ylim(axes(p)))],'Color',[0.7 0.7 0.7],'LineWidth',1)
    plot(axes(i),[8.5 8.5],[min(ylim(axes(p))) max(ylim(axes(p)))],'Color',[0.7 0.7 0.7],'LineWidth',1)
    
end

f1 = gcf;
f1.Name = ['Pre_vs_Post_events_',method];


%%% PLOT SCORES
% c = 1;
% for p = 1 : length(protocols)
%    
%     reshape_POST = nan(500,4);
%     for s = 1 : 4
%         reshape_POST(1:length([POST_bayesianBias{c:c+3,s}]),s) = [POST_bayesianBias{c:c+3,s}]';
%     end
%     reshape_PRE = nan(500,4);
%     for s = 1 : 4
%         reshape_PRE(1:length([PRE_bayesianBias{c:c+3,s}]),s) = [PRE_bayesianBias{c:c+3,s}]';
%     end
% 
%     figure
%     ax1 = subplot(1,2,1);
%     col = [PP.P(p).colorT(1,:);PP.P(p).colorT(2,:);PP.P(p).colorT(3,:);PP.P(p).colorT(4,:)];
%     x_labels = {'T1','T2','R-T1','R-T2'}; %set labels for X axis
%     boxplot(reshape_PRE,'PlotStyle','traditional','Colors',col,'labels',x_labels, 'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
%     a = get(get(gca,'children'),'children');   % Get the handles of all the objects
%     tt = get(a,'tag');   % List the names of all the objects
%     idx = find(strcmpi(tt,'box')==1);  % Find Box objects
%     boxes = a(idx([3,4]));  % Get the children you need (boxes for first exposure)
%     boxes2 = a(idx([1,2])); % Get the children you need (boxes for second exposure)
%     set(boxes,'LineWidth',2); % Set width
%     set(boxes2,'LineStyle',':'); % Set line style for re-exposure plots
%     set(boxes2,'LineWidth',2); % Set width
%     box off
%     ylabel('# replay cells')
%     title(strcat('PRE bayesian bias - Protocol 16x',num2str(protocols(p))));
%     hold on
%     for ii = 1 : 4
%         plot(ii,reshape_PRE(:,ii),'o','MarkerEdgeColor',PP.P(p).colorT(ii,:),'MarkerFaceColor',PP.P(p).colorT(ii,:))
%     end
%     
%     ax2 = subplot(1,2,2);
%     col = [PP.P(p).colorT(1,:);PP.P(p).colorT(2,:);PP.P(p).colorT(3,:);PP.P(p).colorT(4,:)];
%     x_labels = {'T1','T2','R-T1','R-T2'}; %set labels for X axis
%     boxplot(reshape_POST,'PlotStyle','traditional','Colors',col,'labels',x_labels,...
%         'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
%     a = get(get(gca,'children'),'children');   % Get the handles of all the objects
%     tt = get(a,'tag');   % List the names of all the objects
%     idx = find(strcmpi(tt,'box')==1);  % Find Box objects
%     boxes = a(idx([3,4]));  % Get the children you need (boxes for first exposure)
%     boxes2 = a(idx([1,2])); % Get the children you need (boxes for second exposure)
%     set(boxes,'LineWidth',2); % Set width
%     set(boxes2,'LineStyle',':'); % Set line style for re-exposure plots
%     set(boxes2,'LineWidth',2); % Set width
%     box off
%     ylabel('# replay cells')
%     title(strcat('POST bayesian bias - Protocol 16x',num2str(protocols(p))));
%     hold on
%     for ii = 1 : 4
%         plot(ii,reshape_POST(:,ii),'o','MarkerEdgeColor',PP.P(p).colorT(ii,:),'MarkerFaceColor',PP.P(p).colorT(ii,:))
%     end
%     
%     linkaxes([ax2 ax1],'y')
%      
%     
%     c = c + 4;
%     
%    
% end

end
