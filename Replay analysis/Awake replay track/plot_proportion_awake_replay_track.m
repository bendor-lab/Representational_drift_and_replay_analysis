% PROPORTION OF LOCAL AND REMOTE AWAKE REPLAY EVENTS IN TRACKS PER PROTOCOL
% MH 2020
% Plots a figure per protocol. Each subplot is a rat. Within subplot, all tracks plotted with bar plot, each bar indicating proportion of replay events
% decoded during that track, for each possible track decoded. Proportion is calculated as the total number of significant events divided by the total
% number of candidate replay events for that period.
% candidate replay events are calculated in code - calculate_period_candidate_events.mat
% INPUT: mutlievent. 1 to select. If selection, then loads multieventsdata and plots only 2 bars for T1 and T2. Meaning it does not take into account events
% for re-exposure during T1 and T2.

function plot_proportion_awake_replay_track(multievents,data_type)

if strcmp(data_type,'main')
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
    load([path '\period_candidate_events.mat'])
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\behavioural_data.mat')
elseif strcmp(data_type,'speed')
    path ='X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Speed';
    load([path '\period_candidate_events.mat'])
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\Speed Control\behavioural_data.mat')
end

% Parameters
if multievents == 1
    load([path '\extracted_replay_plotting_info_MultiEvents.mat'])
    multievents_data = track_replay_events;
    clear track_replay_events
    load([path '\extracted_replay_plotting_info.mat'])
    alltracks_data = track_replay_events;
    if isfield(track_replay_events,'T4')
        num_tracks = 4;
    else
        num_tracks = 2;
    end
    num_sessions = length(track_replay_events);
    num_events_in_track = nan(1,num_tracks*num_tracks);
    event_times_in_track = nan(155,num_tracks*num_tracks,length(track_replay_events));
    clear track_replay_events
else
    load([path '\extracted_replay_plotting_info.mat'])
    if isfield(track_replay_events,'T4')
        num_tracks = 4;
    else
        num_tracks = 2;
    end
    num_sessions = length(track_replay_events);
    num_events_in_track = nan(1,num_tracks*num_tracks);
    event_times_in_track = nan(155,num_tracks*num_tracks,length(track_replay_events));
end
load([path '\extracted_time_periods_replay.mat'])
PP =  plotting_parameters;

for s = 1 : num_sessions
    c = 1;
    % Find time spent immobile in each track
    imm_times = time_immobile(s,:);
    % For each track, find replay events occurring during the track
    for t = 1 : num_tracks
        if multievents == 1 %if using multievents, for T1 and T2 use multievent (to not take into account the re-exposures)
            if t < 3
                track_replay_events = multievents_data;
            else
                track_replay_events = alltracks_data;
            end
        end
        for  track = 1 : num_tracks
            % Each row a session. Columns e.g.T1 = col 1:4, with 1 being T1 events during T1, 2 - T2 events during T1, 3 are T3 events
            % during T1 & 4 are T4 events during T1. Next 4 columns (5:9)would be events during T2, etc
            num_events_in_track(s,c) = length(track_replay_events(s).(strcat('T',num2str(track))).(strcat('T',num2str(t),'_index')))/not_binned_period_candidate_events.awake(s).(strcat('T',num2str(track)));
            norm_num_events_in_track(s,c) = num_events_in_track(s,c)/imm_times(t);
            event_times_in_track(1:length(track_replay_events(s).(strcat('T',num2str(track))).(strcat('T',num2str(t),'_times'))),c,s) = ...
                track_replay_events(s).(strcat('T',num2str(track))).(strcat('T',num2str(t),'_times'));
            c = c+1;
        end
    end
end

%%%% FIGURES FOR MAIN DATA
if strcmp(data_type,'main')

    figure;
    grp = [ones(20,1);ones(20,1)*2;ones(20,1)*3;ones(20,1)*4];
    tst=[num_events_in_track(:,1);num_events_in_track(:,6);num_events_in_track(:,11);num_events_in_track(:,16)];
    beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.T1;[0.6 0.6 0.6];PP.T1;[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci','corral_style','rand');
    [p,~,stats] = kruskalwallis([num_events_in_track(:,1),num_events_in_track(:,6),num_events_in_track(:,11),num_events_in_track(:,16)]);
    c = multcompare(stats);

    figure
    grp2 = [ones(4,1);ones(4,1)*2;ones(4,1)*3;ones(4,1)*4;ones(4,1)*5;ones(20,1)*6];
    tst2=[norm_num_events_in_track(17:20,6);norm_num_events_in_track(13:16,6);norm_num_events_in_track(9:12,6);norm_num_events_in_track(5:8,6);norm_num_events_in_track(1:4,6);norm_num_events_in_track(:,1)];
    tst1=[num_events_in_track(17:20,6);num_events_in_track(13:16,6);num_events_in_track(9:12,6);num_events_in_track(5:8,6);num_events_in_track(1:4,6);num_events_in_track(:,1)];
    beeswarm(grp2,tst1,'sort_style','nosort','colormap',[flipud(PP.T2);PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
    yticks([0,50,100,150])
    xticks([1:6])
    xticklabels({'1','2','3','4','8','16'})
    xlabel('Number of laps')
    ylabel('Number awake replay events')
    set(gca,'FontSize',14)
    set(gcf,'Color','w')
    ylim([-0.5 160])
    [p1,~]=ranksum([num_events_in_track(17:20,6);nan(16,1)]',num_events_in_track(:,1)');
    [p2,~]=ranksum([num_events_in_track(13:16,6);nan(16,1)]',num_events_in_track(:,1)');
    [p3,~]=ranksum([num_events_in_track(9:12,6);nan(16,1)]',num_events_in_track(:,1)');
    [p4,~]=ranksum([num_events_in_track(5:8,6);nan(16,1)]',num_events_in_track(:,1)');
    [p5,~]=ranksum([num_events_in_track(1:4,6);nan(16,1)]',num_events_in_track(:,1)');

    % BAR PLOT - NUMBER OF REPLAY EVENTS PER TRACK IN EACH TRACK - PER EACH SESSION
    protocols = [8,4,3,2,1];
    count = 1;
    for p = 1 : length(protocols)

        cols = repmat([PP.P(p).colorT(1,:); PP.P(p).colorT(2,:);PP.P(p).colorT(3,:) ;PP.P(p).colorT(4,:)],[4,1]);
        f(p) = figure('units','normalized','outerposition',[0 0 1 1]);
        if multievents == 1
            f(p).Name = ['Number of awake replay events per track_per rat_MultiEvents_Protocol 16x' num2str(protocols(p))];
        else
            f(p).Name = ['Number of awake replay events per track_per rat_Protocol 16x' num2str(protocols(p))];
        end
        if multievents == 1
            x = [1:2,4:5,7:10,12:15];
            jj =[1:2,5:6,9:16];
        else
            x = [1:4,6:9,11:14,16:19];
        end
        for c =  1 : 4
            ax(c) = subplot(4,1,c);
            for ii = 1 : length(x)
                hold on
                if multievents == 1
                    b(ii) = bar(x(ii), num_events_in_track(count,jj(ii)),0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
                else
                    b(ii) = bar(x(ii), num_events_in_track(count,ii),0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
                end
            end
            box off
            ylabel('Mean number of cells','Fontsize',18)
            xticks([2.5,7.5,12.5,17.5]); xticklabels({'T1','T2','R-T1','R-T2'});
            legend([b(1),b(2),b(3),b(4)],{'T1','T2','T3','T4'},'Location','northeastoutside');
            ylabel('# replay events')
            ax(c).FontSize = 16;
            count = count+1;
        end
    end

    % BAR PLOT - NUMBER OF REPLAY EVENTS PER TRACK IN EACH TRACK - PER EACH SESSION
    protocols = [8,4,3,2,1];
    val = [1,6,11,16];
    count = 1;
    f(p) = figure('units','normalized','outerposition',[0 0 1 1]);
    if multievents == 1
        f(p).Name = ['Number of awake replay events per track_MultiEvents_ALL_Protocol'];
    else
        f(p).Name = ['Number of awake replay events per track__ALL_Protocol'];
    end

    for p = 1 : length(protocols)

        cols = repmat([PP.P(p).colorT(1,:); PP.P(p).colorT(2,:);PP.P(p).colorT(3,:) ;PP.P(p).colorT(4,:)],[4,1]);
        ax(p) = subplot(5,1,p);

        if multievents == 1
            x = [1:2,4:5,7:10,12:15];
            jj =[1:2,5:6,9:16];
        else
            x = [1:4];
        end
        t(1) = mean(num_events_in_track(count:count+3,1));
        t(2) = mean(num_events_in_track(count:count+3,6));
        t(3) = mean(num_events_in_track(count:count+3,11));
        t(4) = mean(num_events_in_track(count:count+3,16));
        [pv(p).t12,~]=ranksum([num_events_in_track(count:count+3,1)],[num_events_in_track(count:count+3,6)]);
        [pv(p).t34,~]=ranksum([num_events_in_track(count:count+3,11)],[num_events_in_track(count:count+3,16)]);
        for ii = 1 : length(x)
            hold on
            if multievents == 1
                b(ii) = bar(x(ii), num_events_in_track(count,jj(ii)),0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
            else
                b(ii) = bar(x(ii),t(ii) ,0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
                hold on
                plot(ones(1,4)*ii,num_events_in_track(count:count+3,val(ii)),'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',cols(ii,:))
            end
        end
        box off
        ylabel('Mean number of cells','Fontsize',18)
        xticks([2.5,7.5,12.5,17.5]); xticklabels({'T1','T2','R-T1','R-T2'});
        legend([b(1),b(2),b(3),b(4)],{'T1','T2','T3','T4'},'Location','northeastoutside');
        ylabel('# replay events')
        ax(p).FontSize = 16;
        count = count+4;
    end

    % BAR PLOT - NORMALISED NUMBER OF LOCAL REPLAY EVENTS (BY TIME IMMOBILE) PER TRACK IN EACH TRACK - PER EACH SESSION
    protocols = [8,4,3,2,1];
    val = [1,6,11,16];
    count = 1;
    f(p) = figure('units','normalized','outerposition',[0 0 1 1]);
    if multievents == 1
        f(p).Name = ['Norm number of awake replay events per track_MultiEvents_ALL_Protocol'];
    else
        f(p).Name = ['Norm number of awake replay events per track__ALL_Protocol'];
    end

    for p = 1 : length(protocols)

        cols = repmat([PP.P(p).colorT(1,:); PP.P(p).colorT(2,:);PP.P(p).colorT(3,:) ;PP.P(p).colorT(4,:)],[4,1]);
        ax(p) = subplot(5,1,p);

        if multievents == 1
            x = [1:2,4:5,7:10,12:15];
            jj =[1:2,5:6,9:16];
        else
            x = [1:4];
        end
        t(1) = mean(norm_num_events_in_track(count:count+3,1));
        t(2) = mean(norm_num_events_in_track(count:count+3,6));
        t(3) = mean(norm_num_events_in_track(count:count+3,11));
        t(4) = mean(norm_num_events_in_track(count:count+3,16));
        [pv(p).t12_prop,~]=ranksum([norm_num_events_in_track(count:count+3,1)],[norm_num_events_in_track(count:count+3,6)]);
        [pv(p).t34_prop,~]=ranksum([norm_num_events_in_track(count:count+3,11)],[norm_num_events_in_track(count:count+3,16)]);
        for ii = 1 : length(x)
            hold on
            if multievents == 1
                b(ii) = bar(x(ii), norm_num_events_in_track(count,jj(ii)),0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
            else
                b(ii) = bar(x(ii),t(ii) ,0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
                hold on
                %plot(ones(1,4)*ii,norm_num_events_in_track(count:count+3,val(ii)),'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',cols(ii,:))
                plot(ii,norm_num_events_in_track(count,val(ii)),'Marker',PP.rat_markers{1},'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',cols(ii,:))
                plot(ii,norm_num_events_in_track(count+1,val(ii)),'Marker',PP.rat_markers{2},'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',cols(ii,:))
                plot(ii,norm_num_events_in_track(count+2,val(ii)),'Marker',PP.rat_markers{3},'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',cols(ii,:))
                plot(ii,norm_num_events_in_track(count+3,val(ii)),'Marker',PP.rat_markers{4},'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',cols(ii,:))

            end
        end
        box off
        xticks([2.5,7.5,12.5,17.5]); xticklabels({'T1','T2','R-T1','R-T2'});
        legend([b(1),b(2),b(3),b(4)],{'T1','T2','T3','T4'},'Location','northeastoutside');
        ylabel('norm. # replay events','Fontsize',18)
        ax(p).FontSize = 16;
        count = count+4;
    end


elseif strcmp(data_type,'speed') %%%% FIGURES FOR SPEED DATA

    % Get sessions ID to find select corresponding color
    sessions_ID  = arrayfun(@(x) (track_replay_events(x).session{1,1}(strfind(track_replay_events(x).session{1,1},'x')+1:end)),1:length(track_replay_events),'UniformOutput',0);
    color_idx = cell2mat(arrayfun(@(x) find(strcmp(fieldnames(PP),strcat('L', sessions_ID{x}))),1:length(sessions_ID),'UniformOutput',0));
    cols = cell2mat(arrayfun(@(x) PP.(subsref(fieldnames(PP),substruct('{}',{x}))),color_idx,'UniformOutput',0)');

    % Number local awake replay on track per session
    f1 = figure('Color','w');
    if multievents  == 1
        f1.Name =  'Local candidate awake replay on track_Multievents';
    else
        f1.Name =  'Local candidate awake replay on track';
    end
    for j = 1 : length(sessions_ID)
        subplot(length(sessions_ID),1,j)
        grp = [ones(1,1);ones(1,1)*2;ones(1,1)*3;ones(1,1)*4];
        tst=[num_events_in_track(j,1);num_events_in_track(j,6);num_events_in_track(j,11);num_events_in_track(j,16)];
        beeswarm(grp,tst,'sort_style','nosort','colormap',[cols(j,:);[0.6 0.6 0.6];cols(j,:);[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci','corral_style','rand');
        title(['Session ' sessions_ID{j} 'x'  sessions_ID{j}])
        ylabel('# proportion candidate Local awake replay'); xticks([1,2,3,4]);xticklabels({'T1','T2','R-T1','R-T2'})
        set(gca,'FontSize',14)
    end

    % Normalised number of local awake replay on track per session
    f2 = figure('Color','w');
    if multievents == 1
        f2.Name =  'Normalised candidate number local awake replay on track_Multievents';
    else
        f2.Name =  'Normalised candidate number local awake replay on track';
    end 
    for j = 1 : length(sessions_ID)
        subplot(length(sessions_ID),1,j)
        grp = [ones(1,1);ones(1,1)*2;ones(1,1)*3;ones(1,1)*4];
        tst=[norm_num_events_in_track(j,1);norm_num_events_in_track(j,6);norm_num_events_in_track(j,11);norm_num_events_in_track(j,16)];
        beeswarm(grp,tst,'sort_style','nosort','colormap',[cols(j,:);[0.6 0.6 0.6];cols(j,:);[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci','corral_style','rand');
        title(['Session ' sessions_ID{j} 'x'  sessions_ID{j}])
        ylabel('Norm # proportion candidate Local awake replay'); xticks([1,2,3,4]);xticklabels({'T1','T2','R-T1','R-T2'})
        set(gca,'FontSize',14)
    end

    % Normalised number of local and remote awake replay on track per session
    f3 = figure('Color','w');
    if multievents == 1
        f3.Name =  'Normalised number candidate local and remote awake replay on track_Multievents';
    else
        f3.Name =  'Normalised number candidate local and remote awake replay on track';
    end
    for j = 1 : length(sessions_ID)
        col_test = repmat([cols(j,:);cols(j,:);[0.6 0.6 0.6];[0.6 0.6 0.6]],4,1);
        subplot(length(sessions_ID),1,j)
        grp = [ones(4,1);ones(4,1)*2;ones(4,1)*3;ones(4,1)*4];
        tst2=[norm_num_events_in_track(j,1:4)';norm_num_events_in_track(j,5:8)';norm_num_events_in_track(j,9:12)';norm_num_events_in_track(j,13:16)'];
        beeswarm(grp,tst2,'sort_style','nosort','colormap',[cols(j,:);[0.6 0.6 0.6];cols(j,:);[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci',...
            'corral_style','rand','MarkerFaceColor',col_test);
        title(['Session ' sessions_ID{j} 'x'  sessions_ID{j}])
        ylabel('# proportion candidate awake replay'); xticks([1,2,3,4]);xticklabels({'T1','T2','R-T1','R-T2'})
        set(gca,'FontSize',14)
    end

    % Number of local and remote awake replay on track per session
    f4 = figure('Color','w');
    if multievents == 1
        f4.Name =  'Number candidate local and remote awake replay on track_Multievents';
    else
        f4.Name =  'Number candidate local and remote awake replay on track';
    end 
    for j = 1 : length(sessions_ID)
        col_test = repmat([cols(j,:);cols(j,:);[0.6 0.6 0.6];[0.6 0.6 0.6]],4,1);
        subplot(length(sessions_ID),1,j)
        grp = [ones(4,1);ones(4,1)*2;ones(4,1)*3;ones(4,1)*4];
        tst2=[num_events_in_track(j,1:4)';num_events_in_track(j,5:8)';num_events_in_track(j,9:12)';num_events_in_track(j,13:16)'];
        beeswarm(grp,tst2,'sort_style','nosort','colormap',[cols(j,:);[0.6 0.6 0.6];cols(j,:);[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci',...
            'corral_style','rand','MarkerFaceColor',col_test);
        title(['Session ' sessions_ID{j} 'x'  sessions_ID{j}])
        ylabel('# proportion candidate awake replay'); xticks([1,2,3,4]);xticklabels({'T1','T2','R-T1','R-T2'})
        set(gca,'FontSize',14)
    end



    save_all_figures(path,[])




end