

function prot = replay_bias(data_type, state)

% Load replay information
if strcmp(data_type,'main')
    path ='X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
    sessions = data_folders;
    session_names = fieldnames(sessions);
elseif strcmp(data_type,'speed')
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Speed';
    sessions = speed_data_folders;
    session_names = fieldnames(sessions);
end
load([path '\extracted_time_periods_replay.mat'])
load([path '\extracted_replay_plotting_info.mat'])

if strcmp(state,'sleep')
    periods = {'PRE','INTER_post','FINAL_post'};
elseif strcmp(state,'awake')
    periods = {'T1','T2','T3','T4'};
end
ses =1;
for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        load('significant_replay_events_wcorr.mat')
        load('decoded_replay_events.mat')
        load('decoded_replay_events_segments.mat')
        
        for per = 1 : length(periods) % for each sleep period
            %find indices of significant events for T1 and T2 in PRE and INTER sleeep
            if per == 1 || per == 2
                if strcmp(state,'awake')
                    T1_idx = [track_replay_events(ses).T1.(sprintf('%s',periods{per},'_REAL_index'))];
                    T2_idx = [track_replay_events(ses).T2.(sprintf('%s',periods{per},'_REAL_index'))];                   
                else
                    T1_idx = [track_replay_events(ses).T1.(sprintf('%s',periods{per},'_awake_REAL_index')) track_replay_events(ses).T1.(sprintf('%s',periods{per},'_sleep_REAL_index'))];
                    T2_idx = [track_replay_events(ses).T2.(sprintf('%s',periods{per},'_awake_REAL_index')) track_replay_events(ses).T2.(sprintf('%s',periods{per},'_sleep_REAL_index'))];
                end
                ts = [1,2];
            else
                if strcmp(state,'awake')
                    T1_idx = [track_replay_events(ses).T3.(sprintf('%s',periods{per},'_REAL_index'))];
                    T2_idx = [track_replay_events(ses).T4.(sprintf('%s',periods{per},'_REAL_index'))];
                else
                    T1_idx = [track_replay_events(ses).T3.(sprintf('%s',periods{per},'_awake_REAL_index')) track_replay_events(ses).T3.(sprintf('%s',periods{per},'_sleep_REAL_index'))];
                    T2_idx = [track_replay_events(ses).T4.(sprintf('%s',periods{per},'_awake_REAL_index')) track_replay_events(ses).T4.(sprintf('%s',periods{per},'_sleep_REAL_index'))];
                end
                ts = [3,4];
            end
            merge_idcs = unique([T1_idx T2_idx]);
            prot(p).rat(s).(sprintf('%s',periods{per})).replay_ref_idx_T1 = T1_idx;
            prot(p).rat(s).(sprintf('%s',periods{per})).replay_ref_idx_T2 = T2_idx;
            
            % Find if each sig event is entire or segment, and then get
            for jj = 1 : length(merge_idcs)
                if any(ismember(T1_idx,merge_idcs(jj))) %if it's a T1 significant event
                    idx= find(significant_replay_events.track(ts(1)).index == merge_idcs(jj));
                    idx2 = significant_replay_events.track(ts(1)).ref_index(idx);
                    
                    if significant_replay_events.track(ts(1)).event_segment_best_score(idx) == 1 %if it's an entire replay
                        % re-normalize
                        for sz = 1 : size(decoded_replay_events(ts(1)).replay_events(idx2).decoded_position,2)
                            total(sz) = sum([decoded_replay_events(ts(1)).replay_events(idx2).decoded_position(:,sz); decoded_replay_events(ts(2)).replay_events(idx2).decoded_position(:,sz)]);
                        end
                        new_t1 = decoded_replay_events(ts(1)).replay_events(idx2).decoded_position./total;
                        new_t2 = decoded_replay_events(ts(2)).replay_events(idx2).decoded_position./total;
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,1) = 1; % event sig for T1
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,2) = merge_idcs(jj); % ref idx of event
                        prot(p).rat(s).(sprintf('%s',periods{per})).duration(jj,1:3) = [1 merge_idcs(jj) significant_replay_events.track(ts(1)).event_duration(idx)];
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,3) = sum(sum(new_t1))/(sum(sum(new_t1))+sum(sum(new_t2))); %bayesian bias for T1 event
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,4) = sum(sum(new_t2))/(sum(sum(new_t1))+sum(sum(new_t2)));%bayesian bias for T2 event                  
                        clear total new_t1 new_t2
                     
                    elseif significant_replay_events.track(ts(1)).event_segment_best_score(idx) == 2 %if first segment
                         % re-normalize
                        for sz = 1 : size(decoded_replay_events1(ts(1)).replay_events(idx2).decoded_position,2)
                            total(sz) = sum([decoded_replay_events1(ts(1)).replay_events(idx2).decoded_position(:,sz); decoded_replay_events1(ts(2)).replay_events(idx2).decoded_position(:,sz)]);
                        end
                        new_t1 = decoded_replay_events1(ts(1)).replay_events(idx2).decoded_position./total;
                        new_t2 = decoded_replay_events1(ts(2)).replay_events(idx2).decoded_position./total;
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,1) = 1; % event sig for T1
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,2) = merge_idcs(jj); % ref idx of event
                        prot(p).rat(s).(sprintf('%s',periods{per})).duration(jj,1:3) = [1 merge_idcs(jj) significant_replay_events.track(ts(1)).event_duration(idx)];
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,3) = sum(sum(new_t1))/(sum(sum(new_t1))+sum(sum(new_t2)));%bayesian bias for T1 event
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,4) = sum(sum(new_t2))/(sum(sum(new_t1))+sum(sum(new_t2)));%bayesian bias for T2 event
                        clear total new_t1 new_t2              
                        
                    elseif significant_replay_events.track(ts(1)).event_segment_best_score(idx) == 3 % if second segment
                        % re-normalize
                        for sz = 1 : size(decoded_replay_events2(ts(1)).replay_events(idx2).decoded_position,2)
                            total(sz) = sum([decoded_replay_events2(ts(1)).replay_events(idx2).decoded_position(:,sz); decoded_replay_events2(ts(2)).replay_events(idx2).decoded_position(:,sz)]);
                        end
                        new_t1 = decoded_replay_events2(ts(1)).replay_events(idx2).decoded_position./total;
                        new_t2 = decoded_replay_events2(ts(2)).replay_events(idx2).decoded_position./total;
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,1) = 1; % event sig for T1
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,2) = merge_idcs(jj); % ref idx of event
                        prot(p).rat(s).(sprintf('%s',periods{per})).duration(jj,1:3) = [1 merge_idcs(jj) significant_replay_events.track(ts(1)).event_duration(idx)];
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,3) = sum(sum(new_t1))/(sum(sum(new_t1))+sum(sum(new_t2))); %bayesian bias for T1 event
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,4) = sum(sum(new_t2))/(sum(sum(new_t1))+sum(sum(new_t2)));%bayesian bias for T2 event
                        clear total new_t1 new_t2
                    end
                    
                elseif any(ismember(T2_idx,merge_idcs(jj))) %if it's a T2 significant event
                    idx= find(significant_replay_events.track(ts(2)).index == merge_idcs(jj));
                    idx2 = significant_replay_events.track(ts(2)).ref_index(idx);

                    if significant_replay_events.track(ts(2)).event_segment_best_score(idx) == 1 %if it's an entire replay
                         % re-normalize
                        for sz = 1 : size(decoded_replay_events(ts(2)).replay_events(idx2).decoded_position,2)
                            total(sz) = sum([decoded_replay_events(ts(1)).replay_events(idx2).decoded_position(:,sz); decoded_replay_events(ts(2)).replay_events(idx2).decoded_position(:,sz)]);
                        end
                        new_t1 = decoded_replay_events(ts(1)).replay_events(idx2).decoded_position./total;
                        new_t2 = decoded_replay_events(ts(2)).replay_events(idx2).decoded_position./total;
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,1) = 2; % event sig for T1
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,2) = merge_idcs(jj); % ref idx of event
                        prot(p).rat(s).(sprintf('%s',periods{per})).duration(jj,1:3) = [2 merge_idcs(jj) significant_replay_events.track(ts(2)).event_duration(idx)];
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,3) = sum(sum(new_t1))/(sum(sum(new_t1))+sum(sum(new_t2)));%bayesian bias for T1 event
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,4) = sum(sum(new_t2))/(sum(sum(new_t1))+sum(sum(new_t2)));%bayesian bias for T2 event
                        clear total new_t1 new_t2
                    
                    elseif significant_replay_events.track(ts(2)).event_segment_best_score(idx) == 2 %if first segment
                        % re-normalize
                        for sz = 1 : size(decoded_replay_events1(ts(2)).replay_events(idx2).decoded_position,2)
                            total(sz) = sum([decoded_replay_events1(ts(1)).replay_events(idx2).decoded_position(:,sz); decoded_replay_events1(ts(2)).replay_events(idx2).decoded_position(:,sz)]);
                        end
                        new_t1 = decoded_replay_events1(ts(1)).replay_events(idx2).decoded_position./total;
                        new_t2 = decoded_replay_events1(ts(2)).replay_events(idx2).decoded_position./total;
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,1) = 2; % event sig for T1
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,2) = merge_idcs(jj); % ref idx of event
                        prot(p).rat(s).(sprintf('%s',periods{per})).duration(jj,1:3) = [2 merge_idcs(jj) significant_replay_events.track(ts(2)).event_duration(idx)];
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,3) = sum(sum(new_t1))/(sum(sum(new_t1))+sum(sum(new_t2)));%bayesian bias for T1 event
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,4) = sum(sum(new_t2))/(sum(sum(new_t1))+sum(sum(new_t2))); %bayesian bias for T2 event
                        clear total new_t1 new_t2

                    elseif significant_replay_events.track(ts(2)).event_segment_best_score(idx) == 3 % if second segment
                        % re-normalize
                        for sz = 1 : size(decoded_replay_events2(ts(2)).replay_events(idx2).decoded_position,2)
                            total(sz) = sum([decoded_replay_events2(ts(1)).replay_events(idx2).decoded_position(:,sz); decoded_replay_events2(ts(2)).replay_events(idx2).decoded_position(:,sz)]);
                        end
                        new_t1 = decoded_replay_events2(ts(1)).replay_events(idx2).decoded_position./total;
                        new_t2 = decoded_replay_events2(ts(2)).replay_events(idx2).decoded_position./total;
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,1) = 2; % event sig for T1
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,2) = merge_idcs(jj); % ref idx of event
                        prot(p).rat(s).(sprintf('%s',periods{per})).duration(jj,1:3) = [2 merge_idcs(jj) significant_replay_events.track(ts(2)).event_duration(idx)];
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,3) = sum(sum(new_t1))/(sum(sum(new_t1))+sum(sum(new_t2)));%bayesian bias for T1 event
                        prot(p).rat(s).(sprintf('%s',periods{per})).bayesian_bias(jj,4) = sum(sum(new_t2))/(sum(sum(new_t1))+sum(sum(new_t2)));%bayesian bias for T2 event
                        clear total new_t1 new_t2
                    end
                end
            end
        end
        ses = ses+1;
    end
    
    if strcmp(state,'sleep')
        % Mean across all rats and SD
        all_PRE_T1_bias = [];
        all_PRE_T2_bias = [];
        all_INTER_T1_bias = [];
        all_INTER_T2_bias = [];
        all_FINAL_T1_bias = [];
        all_FINAL_T2_bias = [];
        for rat  = 1 : size(prot(p),1)
            if ~isempty(prot(p).rat(rat).PRE)
                all_PRE_T1_bias = [all_PRE_T1_bias; prot(p).rat(rat).PRE.bayesian_bias(prot(p).rat(rat).PRE.bayesian_bias(:,1) == 1,3)];
                all_PRE_T2_bias = [all_PRE_T2_bias; prot(p).rat(rat).PRE.bayesian_bias(prot(p).rat(rat).PRE.bayesian_bias(:,1) == 2,4)];
            end
            all_INTER_T1_bias = [all_INTER_T1_bias; prot(p).rat(rat).INTER_post.bayesian_bias(prot(p).rat(rat).INTER_post.bayesian_bias(:,1) == 1,3)];
            all_INTER_T2_bias = [all_INTER_T2_bias; prot(p).rat(rat).INTER_post.bayesian_bias(prot(p).rat(rat).INTER_post.bayesian_bias(:,1) == 2,4)];
            all_FINAL_T1_bias = [all_FINAL_T1_bias; prot(p).rat(rat).FINAL_post.bayesian_bias(prot(p).rat(rat).FINAL_post.bayesian_bias(:,1) == 1,3)];
            all_FINAL_T2_bias = [all_FINAL_T2_bias; prot(p).rat(rat).FINAL_post.bayesian_bias(prot(p).rat(rat).FINAL_post.bayesian_bias(:,1) == 2,4)];
            
        end
        
        prot(p).all_PRE_T1_bias = all_PRE_T1_bias;
        prot(p).mean_PRE_T1_bias = mean(all_PRE_T1_bias);
        prot(p).std_PRE_T1_bias = std(all_PRE_T1_bias);
        prot(p).all_PRE_T2_bias = all_PRE_T2_bias;
        prot(p).mean_PRE_T2_bias = mean(all_PRE_T2_bias);
        prot(p).std_PRE_T2_bias = std(all_PRE_T2_bias);
        
        prot(p).all_INTER_T1_bias = all_INTER_T1_bias;
        prot(p).mean_INTER_T1_bias = mean(all_INTER_T1_bias);
        prot(p).std_INTER_T1_bias = std(all_INTER_T1_bias);
        prot(p).all_INTER_T2_bias = all_INTER_T2_bias;
        prot(p).mean_INTER_T2_bias = mean(all_INTER_T2_bias);
        prot(p).std_INTER_T2_bias = std(all_INTER_T2_bias);
        
        prot(p).all_FINAL_T1_bias = all_FINAL_T1_bias;
        prot(p).mean_FINAL_T1_bias = mean(all_FINAL_T1_bias);
        prot(p).std_FINAL_T1_bias = std(all_FINAL_T1_bias);
        prot(p).all_FINAL_T2_bias = all_FINAL_T2_bias;
        prot(p).mean_FINAL_T2_bias = mean(all_FINAL_T2_bias);
        prot(p).std_FINAL_T2_bias = std(all_FINAL_T2_bias);
    else %for awake
        
        all_T1_bias = [];
        all_T2_bias = [];
        all_T3_bias = [];
        all_T4_bias = [];
        all_T1_duration = [];
        all_T2_duration = [];
        all_T3_duration = [];
        all_T4_duration = [];
        
        for rat  = 1 : size(prot(p),1)

            all_T1_bias = [all_T1_bias; prot(p).rat(rat).T1.bayesian_bias(prot(p).rat(rat).T1.bayesian_bias(:,1) == 1,3)];
            if ~isempty(prot(p).rat(rat).T2.replay_ref_idx_T1)
                all_T2_bias = [all_T2_bias; prot(p).rat(rat).T2.bayesian_bias(prot(p).rat(rat).T2.bayesian_bias(:,1) == 2,4)];
            end
            all_T3_bias = [all_T3_bias; prot(p).rat(rat).T3.bayesian_bias(prot(p).rat(rat).T3.bayesian_bias(:,1) == 1,3)];
            all_T4_bias = [all_T4_bias; prot(p).rat(rat).T4.bayesian_bias(prot(p).rat(rat).T4.bayesian_bias(:,1) == 2,4)];

            all_T1_duration = [all_T1_duration; prot(p).rat(rat).T1.duration(prot(p).rat(rat).T1.duration(:,1) == 1,2)];
            if ~isempty(prot(p).rat(rat).T2.replay_ref_idx_T1)
                all_T2_duration = [all_T2_duration; prot(p).rat(rat).T2.duration(prot(p).rat(rat).T2.duration(:,1) == 2,2)];
            end
            all_T3_duration = [all_T3_duration; prot(p).rat(rat).T3.duration(prot(p).rat(rat).T3.duration(:,1) == 1,2)];
            all_T4_duration = [all_T4_duration; prot(p).rat(rat).T4.duration(prot(p).rat(rat).T4.duration(:,1) == 2,2)];
        end
        
        prot(p).all_T1_bias = all_T1_bias;
        prot(p).mean_T1_bias = mean(all_T1_bias);
        prot(p).std_T1_bias = std(all_T1_bias);
        prot(p).all_T2_bias = all_T2_bias;
        prot(p).mean_T2_bias = mean(all_T2_bias);
        prot(p).std_T3_bias = std(all_T2_bias);
        prot(p).all_T3_bias = all_T3_bias;
        prot(p).mean_T3_bias = mean(all_T3_bias);
        prot(p).std_T3_bias = std(all_T3_bias);
        prot(p).all_T4_bias = all_T4_bias;
        prot(p).mean_T4_bias = mean(all_T4_bias);
        prot(p).std_T4_bias = std(all_T4_bias);
        
        prot(p).all_T1_duration = all_T1_duration;
        prot(p).mean_T1_duration = mean(all_T1_duration);
        prot(p).std_T1_duration = std(all_T1_duration);
        prot(p).all_T2_duration = all_T2_duration;
        prot(p).mean_T2_duration = mean(all_T2_duration);
        prot(p).std_T3_duration = std(all_T2_duration);
        prot(p).all_T3_duration = all_T3_duration;
        prot(p).mean_T3_duration = mean(all_T3_duration);
        prot(p).std_T3_duration = std(all_T3_duration);
        prot(p).all_T4_duration = all_T4_duration;
        prot(p).mean_T4_duration = mean(all_T4_duration);
        prot(p).std_T4_duration = std(all_T4_duration);
    end
    
end

cd(path)
if strcmp(state,'awake')
    save([path '\awake_replay_bayesian_bias.mat'],'prot','-v7.3')
else
   save([path '\sleep_replay_bayesian_bias.mat'],'prot','-v7.3')
end


figure
PP = plotting_parameters;
boxplot([[prot(:).mean_PRE_T1_bias]' [prot(:).mean_PRE_T2_bias]' [prot(:).mean_INTER_T1_bias]' [prot(:).mean_INTER_T2_bias]' [prot(:).mean_FINAL_T1_bias]' ...
    [prot(:).mean_FINAL_T2_bias]'],'BoxStyle','outline','Colors',[0.3 0.3 0.3; 0.6 0.6 0.6;0.3 0.3 0.3; 0.6 0.6 0.6;0.3 0.3 0.3; 0.6 0.6 0.6],'Labels',...
    {'PRE-T1','PRE-T2','POST1-T1','POST1-T2','POST2-T1','POST2-T2'});
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
t = get(a,'tag');   % List the names of all the objects
idx=strcmpi(t,'box');  % Find Box objects
boxes=a(idx);          % Get the children you need
set(boxes,'linewidth',3); % Set width
box off
ylabel('Mean bayesian bias','FontSize',16)
ax=gca;
ax.FontSize = 16;
hold on
for j = 1 : 5
    plot(1,prot(j).mean_PRE_T1_bias,'o','MarkerFaceColor', PP.T2(j,:),'MarkerEdgeColor', PP.T2(j,:))
end
for j = 1 : 5
    plot(2,prot(j).mean_PRE_T2_bias,'o','MarkerFaceColor', PP.T2(j,:),'MarkerEdgeColor', PP.T2(j,:))
end
for j = 1 : 5
    plot(3,prot(j).mean_INTER_T1_bias,'o','MarkerFaceColor', PP.T2(j,:),'MarkerEdgeColor', PP.T2(j,:))
end
for j = 1 : 5
    plot(4,prot(j).mean_INTER_T2_bias,'o','MarkerFaceColor', PP.T2(j,:),'MarkerEdgeColor', PP.T2(j,:))
end
for j = 1 : 5
    plot(5,prot(j).mean_FINAL_T1_bias,'o','MarkerFaceColor', PP.T2(j,:),'MarkerEdgeColor', PP.T2(j,:))
end
for j = 1 : 5
    plot(6,prot(j).mean_FINAL_T2_bias,'o','MarkerFaceColor', PP.T2(j,:),'MarkerEdgeColor', PP.T2(j,:))
end

%%% PLOTTING
mat1 = [];
mat = [];
mat2= [];
for j = 1 : 5
    mat = [mat; prot(j).all_INTER_T2_bias; prot(j).all_INTER_T1_bias];
    mat1 = [mat1; prot(j).all_PRE_T2_bias; prot(j).all_PRE_T1_bias];
    mat2 = [mat2; prot(j).all_FINAL_T1_bias; prot(j).all_FINAL_T2_bias];
end
PP = plotting_parameters;


figure;
for j =1 : 5
    ax(j) =subplot(1,5,j);
    h1 = raincloud_plot(mat1, 'box_on', 1, 'color', [0.6 0.6 0.6], 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .2, 'dot_dodge_amount', .2,...
        'box_col_match', 0);
    hold on
    h2= raincloud_plot(prot(j).all_INTER_T1_bias, 'box_on', 1, 'color', PP.T1, 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .45,...
        'dot_dodge_amount', .45, 'box_col_match', 0);
    h3= raincloud_plot(prot(j).all_INTER_T2_bias, 'box_on', 1, 'color', PP.T2(j,:), 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .7,...
        'dot_dodge_amount', .7, 'box_col_match', 0);
    h3{1,1}.EdgeColor ='None';
    h2{1,1}.EdgeColor ='None';
    h1{1,1}.EdgeColor ='None';
    h3{1,2}.SizeData = 5;
    h2{1,2}.SizeData = 5;
    h1{1,2}.SizeData = 5;

    set(gca,'YLim',[-3.5 3])
    box off
    view([-90 90])
    if j > 1
        ax(j).XAxis.Visible = 'off';
    end
end

figure;
for j =1 : 5
    ax(j) =subplot(1,5,j);
    h1 = raincloud_plot(mat1, 'box_on', 1, 'color', [0.6 0.6 0.6], 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .2, 'dot_dodge_amount', .2,...
        'box_col_match', 0);
    hold on
    h2= raincloud_plot(prot(j).all_INTER_T1_bias, 'box_on', 1, 'color', PP.T1, 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .45,...
        'dot_dodge_amount', .45, 'box_col_match', 0);
    h3= raincloud_plot(prot(j).all_INTER_T2_bias, 'box_on', 1, 'color', PP.T2(j,:), 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .7,...
        'dot_dodge_amount', .7, 'box_col_match', 0);
    h3{1,1}.EdgeColor ='None';
    h2{1,1}.EdgeColor ='None';
    h1{1,1}.EdgeColor ='None';
    h3{1,2}.SizeData = 5;
    h2{1,2}.SizeData = 5;
    h1{1,2}.SizeData = 5;

    set(gca,'YLim',[-3.5 3])
    box off
    view([-90 90])
    if j > 1
        ax(j).XAxis.Visible = 'off';
    end
end


figure;
for j =1 : 5
    ax(j) =subplot(1,5,j);
    h1 = raincloud_plot(mat1, 'box_on', 1, 'color', [0.6 0.6 0.6], 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .2, 'dot_dodge_amount', .2,...
        'box_col_match', 0);
    hold on
    h2= raincloud_plot(prot(j).all_FINAL_T1_bias, 'box_on', 1, 'color', PP.T1, 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .45,...
        'dot_dodge_amount', .45, 'box_col_match', 0);
    h3= raincloud_plot(prot(j).all_FINAL_T2_bias, 'box_on', 1, 'color', PP.T2(j,:), 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .7,...
        'dot_dodge_amount', .7, 'box_col_match', 0);
    h3{1,1}.EdgeColor ='None';
    h2{1,1}.EdgeColor ='None';
    h1{1,1}.EdgeColor ='None';
    h3{1,2}.SizeData = 5;
    h2{1,2}.SizeData = 5;
    h1{1,2}.SizeData = 5;

    set(gca,'YLim',[-3.5 3])
    box off
    view([-90 90])
    if j > 1
        ax(j).XAxis.Visible = 'off';
    end
end

figure;
for j =1 : 5
    ax(j) =subplot(1,5,j);
    h1 = raincloud_plot(mat1, 'box_on', 1, 'color', [0.6 0.6 0.6], 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .15, 'dot_dodge_amount', .35,...
        'box_col_match', 1);
    hold on
    h2= raincloud_plot(prot(j).all_FINAL_T1_bias, 'box_on', 1, 'color', PP.T1, 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .55,...
        'dot_dodge_amount', .75, 'box_col_match', 1);
    h3= raincloud_plot(prot(j).all_F_T2_bias, 'box_on', 1, 'color', PP.T2(j,:), 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .95,...
        'dot_dodge_amount', 1.15, 'box_col_match', 1);
    h3{1,1}.EdgeColor ='None';
    h2{1,1}.EdgeColor ='None';
    h1{1,1}.EdgeColor ='None';

    set(gca,'YLim',[-3.5 3])
    box off
    view([-90 90])
    if j > 1
        ax(j).XAxis.Visible = 'off';
    end
end

figure;
for j =1 : 5
    ax(j) =subplot(1,5,j);
    h1 = raincloud_plot(mat1, 'box_on', 1, 'color', [0.6 0.6 0.6], 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .15, 'dot_dodge_amount', .35,...
        'box_col_match', 1);
    hold on
    h2= raincloud_plot(prot(j).all_FINAL_T1_bias, 'box_on', 1, 'color', PP.T1, 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .55,...
        'dot_dodge_amount', .75, 'box_col_match', 1);
    h3= raincloud_plot(prot(j).all_FINAL_T2_bias, 'box_on', 1, 'color', PP.T2(j,:), 'alpha', 0.5,'box_dodge', 1, 'box_dodge_amount', .95,...
        'dot_dodge_amount', 1.15, 'box_col_match', 1);
    h3{1,1}.EdgeColor ='None';
    h2{1,1}.EdgeColor ='None';
    h1{1,1}.EdgeColor ='None';

    set(gca,'YLim',[-3.5 3])
    box off
    view([-90 90])
    if j > 1
        ax(j).XAxis.Visible = 'off';
    end
end


 %%%% STATS
 
 
%  for j = 1 : 5
%      [h,p,ks2stat] = kstest2([prot(j).all_FINAL_T2_bias; prot(j).all_FINAL_T1_bias],[prot(j).all_PRE_T2_bias; prot(j).all_PRE_T1_bias])
%  end

for j = 1 : 5
    [p,h,stats] = ranksum([prot(j).all_INTER_T2_bias; prot(j).all_INTER_T1_bias],[prot(j).all_PRE_T2_bias; prot(j).all_PRE_T1_bias])
end

for j = 1 : 5
    %[p,h,stats] = ranksum([prot(j).all_INTER_T2_bias],[prot(j).all_PRE_T2_bias; prot(j).all_PRE_T1_bias])
     tst = nan(1000,3);
     tst(1:length([prot(j).all_PRE_T2_bias; prot(j).all_PRE_T1_bias]),1) = [prot(j).all_PRE_T2_bias; prot(j).all_PRE_T1_bias];
     tst(1:length([prot(j).all_INTER_T1_bias]),2) = [prot(j).all_INTER_T1_bias];
     tst(1:length([prot(j).all_INTER_T2_bias]),3) = [prot(j).all_INTER_T2_bias];
     [p1,tbl,stats] = kruskalwallis(tst);
     c1{j} = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
end
for j = 1 : 5
    %[p,h,stats] = ranksum([prot(j).all_INTER_T2_bias],[prot(j).all_PRE_T2_bias; prot(j).all_PRE_T1_bias])
     tst = nan(1000,3);
     tst(1:length([prot(j).all_PRE_T2_bias; prot(j).all_PRE_T1_bias]),1) = [prot(j).all_PRE_T2_bias; prot(j).all_PRE_T1_bias];
     tst(1:length([prot(j).all_FINAL_T1_bias]),2) = [prot(j).all_FINAL_T1_bias];
     tst(1:length([prot(j).all_FINAL_T2_bias]),3) = [prot(j).all_FINAL_T2_bias];
     [p1,tbl,stats] = kruskalwallis(tst);
     c{j} = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
end

for j = 1 : 5
    [p,h,stats] = ranksum([prot(j).all_FINAL_T2_bias; prot(j).all_FINAL_T1_bias],[prot(j).all_PRE_T2_bias; prot(j).all_PRE_T1_bias])
end
for j = 1 : 5
    [p,h,stats] = ranksum([prot(j).all_FINAL_T2_bias; prot(j).all_FINAL_T1_bias],[prot(j).all_INTER_T2_bias; prot(j).all_INTER_T1_bias])
end




% First have found type of distribution with 'fitmethis' function
f1 =figure;
f1.Name = 'Bayesian Bias distributions';
subplot(3,1,1)
h = histfit(mat1,[],'kernel');
h(1).FaceColor = [0.9 0.9 0.9];
h(1).EdgeColor = [1 1 1];
h(2).Color = [0.6 0.8 1];
ylabel('Number of replay events')
xlabel('Bayesian bias')

title('Histogram of bayesian bias for PRE, INTER & FINAL sleep')

subplot(3,1,2)
hh = histfit(mat,[],'beta');
hh(1).FaceColor = [0.9 0.9 0.9];
hh(1).EdgeColor = [1 1 1];
hh(2).Color = [0.6 0.8 0.8];
ylabel('Number of replay events')
xlabel('Bayesian bias')


subplot(3,1,3)
hh = histfit(mat2,[],'beta');
hh(1).FaceColor = [0.9 0.9 0.9];
hh(1).EdgeColor = [1 1 1];
hh(2).Color = [0.6 0.8 0.8];
ylabel('Number of replay events')
xlabel('Bayesian bias')

f2 =figure;
f2.Name = 'Bayesian Bias distributions for 1 Lap';
subplot(3,1,1)
h = histfit([prot(5).all_PRE_T2_bias; prot(5).all_PRE_T1_bias],[],'kernel');
h(1).FaceColor = [0.9 0.9 0.9];
h(1).EdgeColor = [1 1 1];
h(2).Color = [0.6 0.8 1];
ylabel('Number of replay events')
xlabel('Bayesian bias')

title('Histogram of bayesian bias for PRE, INTER & FINAL sleep')

subplot(3,1,2)
hh = histfit([prot(5).all_INTER_T2_bias; prot(5).all_INTER_T1_bias],[],'gev');
hh(1).FaceColor = [0.9 0.9 0.9];
hh(1).EdgeColor = [1 1 1];
hh(2).Color = [0.6 0.8 0.8];
ylabel('Number of replay events')
xlabel('Bayesian bias')


figure;
subplot(3,1,1)
hh = histfit(mat1,[],'kernel');
hh(1).FaceColor = [0.9 0.9 0.9];
hh(1).EdgeColor = [1 1 1];
hh(2).Color = [0 0 0];
ylabel('Number of replay events')
xlabel('Bayesian bias')
for j = 1 : 5
    a  = fitmethis([prot(j).all_PRE_T2_bias; prot(j).all_PRE_T1_bias],'figure','off','pdata','on','pdist',4);
    hold on
    hh = histfit([prot(j).all_PRE_T2_bias; prot(j).all_PRE_T1_bias],[],a(1).name);
    delete(hh(1))
    hh(2).Color = PP.T2(j,:);
    ylabel('Number of replay events')
    xlabel('Bayesian bias')
end

subplot(3,1,2)
hh = histfit(mat,[],'beta');
hh(1).FaceColor = [0.9 0.9 0.9];
hh(1).EdgeColor = [1 1 1];
hh(2).Color = [0 0 0];
ylabel('Number of replay events')
xlabel('Bayesian bias')
PP = plotting_parameters;
for j = 1 : 5
    a  = fitmethis([prot(j).all_INTER_T2_bias; prot(j).all_INTER_T1_bias],'figure','off','pdata','on','pdist',4);
    hold on
    hh = histfit([prot(j).all_INTER_T2_bias; prot(j).all_INTER_T1_bias],[],a(1).name);
    delete(hh(1))
    hh(2).Color = PP.T2(j,:);
    ylabel('Number of replay events')
    xlabel('Bayesian bias')
end

subplot(3,1,3)
hh = histfit(mat2,[],'beta');
hh(1).FaceColor = [0.9 0.9 0.9];
hh(1).EdgeColor = [1 1 1];
hh(2).Color = [0 0 0];
ylabel('Number of replay events')
xlabel('Bayesian bias')
PP = plotting_parameters;
for j = 1 : 5
    a  = fitmethis([prot(j).all_FINAL_T2_bias; prot(j).all_FINAL_T1_bias],'figure','off','pdata','on','pdist',4);
    hold on
    hh = histfit([prot(j).all_FINAL_T2_bias; prot(j).all_FINAL_T1_bias],[],a(1).name);
    delete(hh(1))
    hh(2).Color = PP.T2(j,:);
    ylabel('Number of replay events')
    xlabel('Bayesian bias')
end





end


