% PROPORTION OF SIG EVENTS FOR EACH TRACK - PRE VS POST
% From all candidate events, finds proportion of sig events for each track and compare changes between PRE and POST (INTER and FINAL) sleep
% INPUTS:
    % computer: GPU or empty
    % State: ALL, awake or sleep
    % method: wcorr or spearman

function find_candidate_period_events(computer,state,method)

% Load replay information
if strcmp(method,'wcorr')
    cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis')
    load extracted_time_periods_replay.mat
    load extracted_replay_plotting_info.mat
elseif strcmp(method,'spearman')
    cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Spearman')
    load extracted_time_periods_replay.mat
    load extracted_replay_plotting_info.mat
end

% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
elseif isempty(computer) %normal computer
    sessions = data_folders;
    session_names = fieldnames(sessions);
else %if entering a single folder
    folders = {computer};
    session_names = folders;
end

c= 1;
% For each protocol
for p = 1 : length(session_names)
    
    if length(session_names) > 1 %more than one folder
        folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    end
    
    for s = 1 : length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        if strcmp(method,'wcorr')
            if exist(strcat(pwd,'\significant_replay_events_wcorr.mat'),'file')
                load('significant_replay_events_wcorr.mat')
            end
        elseif strcmp(method,'spearman')
            if exist(strcat(pwd,'\significant_replay_events_spearman.mat'),'file')
                load('significant_replay_events_spearman.mat')
            end
        end
    
            candidate_pre_events(c) = length(find(significant_replay_events.all_event_times < period_time(c).PRE.time_limits(2)));
            candidate_inter_events(c) = length(find(significant_replay_events.all_event_times > period_time(c).INTER_post.time_limits(1) & ...
                significant_replay_events.all_event_times < period_time(c).INTER_post.time_limits(2)));
            candidate_final_events(c) = length(find(significant_replay_events.all_event_times > period_time(c).FINAL_post.time_limits(1) & ...
                significant_replay_events.all_event_times < period_time(c).FINAL_post.time_limits(2)));
            c =c+1;
        
    end
    
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
    
    % struct: each row a session, each column events for each track
    if strcmp(state,'ALL')
        PRE_events(s,1) = (length(track_replay_events(s).T1.PRE_sleep_times) + length(track_replay_events(s).T1.PRE_awake_times))/candidate_pre_events(s);
        PRE_events(s,2) = (length(track_replay_events(s).T2.PRE_sleep_times) + length(track_replay_events(s).T2.PRE_awake_times))/candidate_pre_events(s);
        PRE_events(s,3) = (length(track_replay_events(s).T3.PRE_sleep_times) + length(track_replay_events(s).T3.PRE_awake_times))/candidate_pre_events(s);
        PRE_events(s,4) = (length(track_replay_events(s).T4.PRE_sleep_times) + length(track_replay_events(s).T4.PRE_awake_times))/candidate_pre_events(s);

        PRE_rejected_events(s,1) = (candidate_pre_events(s)-(length(track_replay_events(s).T1.PRE_sleep_times) + length(track_replay_events(s).T1.PRE_awake_times)))/candidate_pre_events(s);
        PRE_rejected_events(s,2) = (candidate_pre_events(s)-(length(track_replay_events(s).T2.PRE_sleep_times) + length(track_replay_events(s).T2.PRE_awake_times)))/candidate_pre_events(s);
        PRE_rejected_events(s,3) = (candidate_pre_events(s)-(length(track_replay_events(s).T3.PRE_sleep_times) + length(track_replay_events(s).T3.PRE_awake_times)))/candidate_pre_events(s);
        PRE_rejected_events(s,4) = (candidate_pre_events(s)-(length(track_replay_events(s).T4.PRE_sleep_times) + length(track_replay_events(s).T4.PRE_awake_times)))/candidate_pre_events(s);


    elseif strcmp(state,'sleep')       
        PRE_events(s,1) = length(track_replay_events(s).T1.PRE_sleep_times)/candidate_pre_events(s);
        PRE_events(s,2) = length(track_replay_events(s).T2.PRE_sleep_times)/candidate_pre_events(s);
        PRE_events(s,3) = length(track_replay_events(s).T3.PRE_sleep_times)/candidate_pre_events(s);
        PRE_events(s,4) = length(track_replay_events(s).T4.PRE_sleep_times)/candidate_pre_events(s);
    end
    
    %%%% Extract number of INTER POST events per track
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
    
    if strcmp(state,'ALL')
        INTER_events(s,1) = (length(track_replay_events(s).T1.INTER_post_sleep_times) + length(track_replay_events(s).T1.INTER_post_awake_times))/candidate_inter_events(s);
        INTER_events(s,2) = (length(track_replay_events(s).T2.INTER_post_sleep_times) + length(track_replay_events(s).T2.INTER_post_awake_times))/candidate_inter_events(s);
        INTER_events(s,3) = (length(track_replay_events(s).T3.INTER_post_sleep_times) + length(track_replay_events(s).T3.INTER_post_awake_times))/candidate_inter_events(s);
        INTER_events(s,4) = (length(track_replay_events(s).T4.INTER_post_sleep_times) + length(track_replay_events(s).T4.INTER_post_awake_times))/candidate_inter_events(s);
        
        INTER_rejected_events(s,1) = (candidate_inter_events(s)-(length(track_replay_events(s).T1.INTER_post_sleep_times) + length(track_replay_events(s).T1.INTER_post_awake_times)))/candidate_inter_events(s);
        INTER_rejected_events(s,2) = (candidate_inter_events(s)-(length(track_replay_events(s).T2.INTER_post_sleep_times) + length(track_replay_events(s).T2.INTER_post_awake_times)))/candidate_inter_events(s);
        INTER_rejected_events(s,3) = (candidate_inter_events(s)-(length(track_replay_events(s).T3.INTER_post_sleep_times) + length(track_replay_events(s).T3.INTER_post_awake_times)))/candidate_inter_events(s);
        INTER_rejected_events(s,4) = (candidate_inter_events(s)-(length(track_replay_events(s).T4.INTER_post_sleep_times) + length(track_replay_events(s).T4.INTER_post_awake_times)))/candidate_inter_events(s);

    elseif strcmp(state,'sleep')
        INTER_events(s,1) = length(track_replay_events(s).T1.INTER_post_sleep_times) /candidate_inter_events(s);
        INTER_events(s,2) = length(track_replay_events(s).T2.INTER_post_sleep_times) /candidate_inter_events(s);
        INTER_events(s,3) = length(track_replay_events(s).T3.INTER_post_sleep_times) /candidate_inter_events(s);
        INTER_events(s,4) = length(track_replay_events(s).T4.INTER_post_sleep_times) /candidate_inter_events(s);
    end
    
    %%%% Extract number of FINAL POST events per track
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
    
    if strcmp(state,'ALL')
        FINAL_events(s,1) = (length(track_replay_events(s).T1.FINAL_post_sleep_times) + length(track_replay_events(s).T1.FINAL_post_awake_times))/candidate_final_events(s);
        FINAL_events(s,2) = (length(track_replay_events(s).T2.FINAL_post_sleep_times) + length(track_replay_events(s).T2.FINAL_post_awake_times))/candidate_final_events(s);
        FINAL_events(s,3) = (length(track_replay_events(s).T3.FINAL_post_sleep_times) + length(track_replay_events(s).T3.FINAL_post_awake_times))/candidate_final_events(s);
        FINAL_events(s,4) = (length(track_replay_events(s).T4.FINAL_post_sleep_times) + length(track_replay_events(s).T4.FINAL_post_awake_times))/candidate_final_events(s);
    elseif strcmp(state,'sleep')
        FINAL_events(s,1) = length(track_replay_events(s).T1.FINAL_post_sleep_times) /candidate_final_events(s);
        FINAL_events(s,2) = length(track_replay_events(s).T2.FINAL_post_sleep_times) /candidate_final_events(s);
        FINAL_events(s,3) = length(track_replay_events(s).T3.FINAL_post_sleep_times) /candidate_final_events(s);
        FINAL_events(s,4) = length(track_replay_events(s).T4.FINAL_post_sleep_times) /candidate_final_events(s);
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
    ylabel(axes(p),'proportion sig events')
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


    %%%%%% EVALUATE SIGNIFICANCE
    % First test whether pre,inter and final are different with Friedman's test. It is a non-parametric repeated measures ANOVA.
    % If it's significant, then use Wilcoxon rank test to compare pairs.
    % Correct multiple comparisons using the Holm-Bonferroni correction:
    % ranks pvalues from lower to higher and then divide by n-i+1 (where i is the order of pvalues ranked from small to high)
    
   [pvalue,~,stats] = friedman([PRE_events(c:c+3,1:4) INTER_events(c:c+3,1:4) FINAL_events(c:c+3,1:4)],1,'off');
      
    if pvalue < 0.05
        for i = 1 : 4 % for each track
            [pval(1,i),~,~] = signrank(PRE_events(c:c+3,i),INTER_events(c:c+3,i)); % wilcoxon
            [pval(2,i),~,~] = signrank(PRE_events(c:c+3,i),FINAL_events(c:c+3,i)); % wilcoxon
            [pval(3,i),~,~] = signrank(INTER_events(c:c+3,i),FINAL_events(c:c+3,i)); % wilcoxon
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
    end
    c = c + 4;     
end

linkaxes(axes)
for i = 1 : length(axes)
    plot(axes(i),[4.5 4.5],[min(ylim(axes(p))) max(ylim(axes(p)))],'Color',[0.7 0.7 0.7],'LineWidth',1)
    plot(axes(i),[8.5 8.5],[min(ylim(axes(p))) max(ylim(axes(p)))],'Color',[0.7 0.7 0.7],'LineWidth',1)
    
end

f1=gcf;
f1.Name = ['Proportion_sig_events_',method];

end


