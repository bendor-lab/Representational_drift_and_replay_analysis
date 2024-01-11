% PROPORTION OF SIG EVENTS FOR EACH TRACK - PRE VS POST
% From all candidate events, finds proportion of sig events for each track and calculates difference
% between sleep periods PRE and POST (INTER and FINAL) 


function diff_proportion_sig_events(computer,state,method)

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
    
    if strcmp(state,'ALL')
        PRE_events(s,1) = (length(track_replay_events(s).T1.PRE_sleep_times) + length(track_replay_events(s).T1.PRE_awake_times))/candidate_pre_events(s);
        PRE_events(s,2) = (length(track_replay_events(s).T2.PRE_sleep_times) + length(track_replay_events(s).T2.PRE_awake_times))/candidate_pre_events(s);
        PRE_events(s,3) = (length(track_replay_events(s).T3.PRE_sleep_times) + length(track_replay_events(s).T3.PRE_awake_times))/candidate_pre_events(s);
        PRE_events(s,4) = (length(track_replay_events(s).T4.PRE_sleep_times) + length(track_replay_events(s).T4.PRE_awake_times))/candidate_pre_events(s);
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
    elseif strcmp(state,'sleep')
        INTER_events(s,1) = length(track_replay_events(s).T1.INTER_post_sleep_times) /candidate_inter_events(s);
        INTER_events(s,2) = length(track_replay_events(s).T2.INTER_post_sleep_times) /candidate_inter_events(s);
        INTER_events(s,3) = length(track_replay_events(s).T3.INTER_post_sleep_times) /candidate_inter_events(s);
        INTER_events(s,4) = length(track_replay_events(s).T4.INTER_post_sleep_times) /candidate_inter_events(s);
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
        FINAL_events(s,1) = (length(track_replay_events(s).T1.FINAL_post_sleep_times) + length(track_replay_events(s).T1.FINAL_post_awake_times))/candidate_inter_events(s);
        FINAL_events(s,2) = (length(track_replay_events(s).T2.FINAL_post_sleep_times) + length(track_replay_events(s).T2.FINAL_post_awake_times))/candidate_inter_events(s);
        FINAL_events(s,3) = (length(track_replay_events(s).T3.FINAL_post_sleep_times) + length(track_replay_events(s).T3.FINAL_post_awake_times))/candidate_inter_events(s);
        FINAL_events(s,4) = (length(track_replay_events(s).T4.FINAL_post_sleep_times) + length(track_replay_events(s).T4.FINAL_post_awake_times))/candidate_inter_events(s);
    elseif strcmp(state,'sleep')
        FINAL_events(s,1) = length(track_replay_events(s).T1.FINAL_post_sleep_times) /candidate_inter_events(s);
        FINAL_events(s,2) = length(track_replay_events(s).T2.FINAL_post_sleep_times) /candidate_inter_events(s);
        FINAL_events(s,3) = length(track_replay_events(s).T3.FINAL_post_sleep_times) /candidate_inter_events(s);
        FINAL_events(s,4) = length(track_replay_events(s).T4.FINAL_post_sleep_times) /candidate_inter_events(s);
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
    
    diff_PRE_INTER = PRE_events(c:c+3,1:4) - INTER_events(c:c+3,1:4);
    diff_PRE_FINAL = PRE_events(c:c+3,1:4) - FINAL_events(c:c+3,1:4);
    diff_INTER_FINAL = INTER_events(c:c+3,1:4) - FINAL_events(c:c+3,1:4);
    
    boxplot(axes(p),[diff_PRE_INTER diff_PRE_FINAL diff_INTER_FINAL],'PlotStyle','traditional','Colors',col,'labels',x_labels,...
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
    ylabel(axes(p),'diff proportion sig events')
    title(axes(p),'')
    
    hold on
    for ii = 1 : 4
        hh = plot(axes(p),ii,diff_PRE_INTER(:,ii),'o','MarkerEdgeColor',PP.P(p).colorT(ii,:),'MarkerFaceColor',PP.P(p).colorT(ii,:));
        set(hh,{'Marker'},{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6},'MarkerFaceColor','w','LineWidth',1.5);
        h = plot(axes(p),ii+4,diff_PRE_FINAL(:,ii),'o','MarkerEdgeColor',PP.P(p).colorT(ii,:),'MarkerFaceColor',PP.P(p).colorT(ii,:));
        set(h,{'Marker'},{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6},'MarkerFaceColor','w','LineWidth',1.5);
        h2 = plot(axes(p),ii+8,diff_INTER_FINAL(:,ii),'o','MarkerEdgeColor',PP.P(p).colorT(ii,:),'MarkerFaceColor',PP.P(p).colorT(ii,:));
        set(h2,{'Marker'},{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6},'MarkerFaceColor','w','LineWidth',1.5);
    end


    %%%%%% EVALUATE SIGNIFICANCE
    
    % Tests if difference between groups is different two zero
    for i = 1 : 4 % for each track
        [~,pval(1,i)] = ttest(diff_PRE_INTER(:,ii)); % Dependent t-test
        [~,pval(2,i)] = ttest(diff_PRE_FINAL(:,ii)); % Dependent t-test
        [~,pval(3,i)] = ttest(diff_INTER_FINAL(:,ii)); % Dependent t-test
    end
    
    % Rank p-vals in each track (each column) and apply Holm-Bonferroni multipple comparisons correction
    [sorted_pval,idx] = sort(pval,1);
    sig_diff = [];
    for i = 1 : 4 % for each track
        if sorted_pval(1,i)< 0.05/length(pval(:,1)) %if the smallest pval is sig, save and continue
            sig_diff(idx(1,i),i) = 1;
            if sorted_pval(2,i)< 0.05/(length(pval(:,1))-1) %if the next pval is sig, save and continue
                sig_diff(idx(2,i),i) = 1;
                if sorted_pval(3,i)< 0.05/(length(pval(:,1))-2) %if the next pval is sig, save and continue
                    sig_diff(idx(3,i),i) = 1; % track is column, comparison is row
                end
            end
        end
    end
    
    if ~isempty(sig_diff)
        sig_idcs = sum(sum(sig_diff));
        maxy = max(ylim(axes(p)));
        miny = min(ylim(axes(p)));
        ylim((axes(p)),[miny , maxy+(length(sig_idcs)*0.04)])
        
        if sum(sig_diff(1,:)) > 0 % If there are sig values in the comparison PRE vs INTER
            sig_idx = find(sig_diff(1,:) == 1);
            % Add sig bars
            cc = 1;
            for ii = 1 : length(sig_idx)
                idx = sig_idx(ii);
                dist = max(diff_PRE_INTER(:,idx)) + 0.03;
                hold on  
                plot(axes(p),[idx idx], [dist dist], '*k','MarkerSize',5)
                cc = cc+1;
            end
        end
        if length(sum(sig_diff,2)) > 1 & sum(sig_diff(2,:)) > 0 % If there are sig values in the comparison PRE vs FINAL
           sig_idx = find(sig_diff(2,:) == 1);
            % Add sig bars
            cc = 1;
            for ii = 1 : length(sig_idx)
                idx = sig_idx(ii);
                dist = max(diff_PRE_FINAL(:,idx)) + 0.03;
                hold on  
                plot(axes(p),[idx+4 idx+4], [dist dist], '*k','MarkerSize',5)
                cc = cc+1;
            end
        end
        if length(sum(sig_diff,2)) > 2 & sum(sig_diff(3,:)) > 0 % If there are sig values in the comparison INTER vs FINAL
            sig_idx = find(sig_diff(3,:) == 1);
            % Add sig bars
            cc = 1;
            for ii = 1 : length(sig_idx)
                idx = sig_idx(ii);
                dist = max(diff_INTER_FINAL(:,idx)) + 0.03;
                hold on  
                plot(axes(p),[idx+8 idx+8], [dist dist], '*k','MarkerSize',5)
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

f1=gcf;
f1.Name = ['Diff_proportion_sig_events_',method];

end


