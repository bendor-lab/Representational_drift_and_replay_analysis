% PLOT AWAKE REPLAY PROPERTIES ON TRACK 
% MH 2021
% Extracts and plots information about each awake replay event on track - duration,
% bayesian bias (loaded)
% Protocol structure loaded is as follows: each row is a protocol (e.g. protocol(x)) and each column contains information about replay events on
% each track (e.g. protocol(x).TX). Within each track information (e.g. protocol(1).T1), each row contains the replay events active on that track
% and decoding for each of the tracks (that is, local and remote replay - e.g. protocol(1).T1(2) = replay events decoding T2 that happened during
% T1). Within each row, there is the information for all the rats (e.g. protocol(1).T1(1).Rat_replay_REF_idx(X) - where X is a row for each rat)

function plot_awake_replay_properties(data_type,multievents)


if strcmp(data_type,'main')
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
elseif strcmp(data_type,'speed')
    path ='X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Speed';
end
load([path '\awake_replay_bayesian_bias.mat'])  %obtained from function replay_bias
if multievents == 1
    load([path '\extracted_awake_replay_track_completelap_MultiEvents.mat'])
else
    load([path '\extracted_awake_replay_track_completelap.mat'])
end
PP = plotting_parameters;

num_tracks = length(cell2mat(strfind(fieldnames(protocol),'T')));

c = 1;
for p = 1 : length(protocol) % protocols
    num_rats = size(protocol(p).T1(1).Rat_chunk_duration,1);

    for r = 1 : num_rats % for each rat

        for t = 1 : num_tracks %for each track
            
            %bayesian_bias.(strcat(['T',num2str(t)])) = nan(length(prot),size(protocol(p).(strcat(['T',num2str(t)]))(t).Rat_replay_REF_idx,2));

            for lap = 1 : size(protocol(p).(strcat(['T',num2str(t)]))(t).Rat_replay_REF_idx,2)

                idcs = protocol(p).(strcat(['T',num2str(t)]))(t).Rat_replay_REF_idx{r,lap};

                if ~isempty(prot(p).rat(r).(strcat(['T',num2str(t)])).replay_ref_idx_T1) | ~isempty(prot(p).rat(r).(strcat(['T',num2str(t)])).replay_ref_idx_T2)

                    [~,idx] = intersect([prot(p).rat(r).(strcat(['T',num2str(t)])).bayesian_bias(:,2)],idcs);
                    [~,idx2] = intersect([prot(p).rat(r).(strcat(['T',num2str(t)])).duration(:,2)],idcs);
                    if t == 1 | t == 3
                        bayesian_bias.(strcat(['T',num2str(t)])){c,lap} = prot(p).rat(r).(strcat(['T',num2str(t)])).bayesian_bias(idx,3);
                    else
                        bayesian_bias.(strcat(['T',num2str(t)])){c,lap} = prot(p).rat(r).(strcat(['T',num2str(t)])).bayesian_bias(idx,4);
                    end
                    replay_duration.(strcat(['T',num2str(t)])){c,lap} = prot(p).rat(r).(strcat(['T',num2str(t)])).duration(idx2,3);
                end
            end
        end

        c = c+1;
    end
end

%%%%%% PLOTTING FOR MAIN DATA SET
if strcmp(data_type,'main')

    % BAYESIAN BIAS
    mean_lap_BB = nan(16,4);
    all = [];
    gr = [];
    for t = 1 : num_tracks  %for each track
        if t == 2
            sz = size(bayesian_bias.(strcat(['T',num2str(t)])),2);
        else
            sz = 16;
        end
        for lap = 1 : sz
            mean_lap_BB(lap,t) = mean(cat(1,bayesian_bias.(strcat(['T',num2str(t)])){:,lap}));
            std_lap_BB(lap,t) = std(cat(1,bayesian_bias.(strcat(['T',num2str(t)])){:,lap}));
            all = [all; cat(1,bayesian_bias.(strcat(['T',num2str(t)])){:,lap})];
            gr = [gr; ones(length(cat(1,bayesian_bias.(strcat(['T',num2str(t)])){:,lap})),1)*lap];
        end
        if t == 4
            c =1;
            for j = 1 : 5
                for lap = 1 : sz
                    BB_T4(lap,j) = mean(cat(1,bayesian_bias.(strcat(['T',num2str(t)])){c:c+3,lap}));
                end
                c = c+4;
            end
        end
    end

    figure;
    plot(mean_lap_BB(:,1),'Color',PP.T1,'LineWidth',3)
    hold on
    plot(mean_lap_BB(:,1),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',3)
    x = 1 : length((mean_lap_BB(:,1)));
    shade1 = (mean_lap_BB(:,1) + std_lap_BB(:,1));
    shade2 = (mean_lap_BB(:,1) - std_lap_BB(:,1));
    x2 = [x,fliplr(x)]';
    inBetween = [shade1',fliplr(shade2')];
    h=fill(x2,inBetween,PP.T1);
    set(h,'facealpha',0.2,'LineStyle','none')

    plot(mean_lap_BB(:,4),'Color',[0.6 0.6 0.6],'LineWidth',3)
    hold on
    plot(mean_lap_BB(:,4),'o','MarkerFaceColor',[0.6 0.6 0.6],'MarkerEdgeColor',[0.6 0.6 0.6],'MarkerSize',3)
    x = 1 : length((mean_lap_BB(:,4)));
    shade1 = (mean_lap_BB(:,4) + std_lap_BB(:,4));
    shade2 = (mean_lap_BB(:,4) - std_lap_BB(:,4));
    x2 = [x,fliplr(x)];
    inBetween = [shade1',fliplr(shade2')];
    h=fill(x2,inBetween,[0.6 0.6 0.6]);
    set(h,'facealpha',0.2,'LineStyle','none')

    ylim([0.72 .92])
    xticks([2:2:16])
    box off
    xlabel('Laps')
    ylabel('Bayesian bias score')



    for t = 1 : num_tracks

        ax(t) = subplot(2,2,t);

        if t == 1 || t == 3
            all_prots = [];
            for p = 1 : length(protocols)
                all_prots = [all_prots; protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:16)];
            end

            boxplot(all,gr,'PlotStyle','traditional','Colors',[.6 .6 .6],'LabelOrientation','horizontal','Widths',0.5);
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
            for ii = 1 : 16
                h = plot(ii,all(gr==ii),'o','MarkerEdgeColor',[.6 .6 .6],'MarkerFaceColor',[.6 .6 .6],'MarkerSize',2);
            end

            hold on
            plot(mean_lap_BB(:,1),'Color',PP.T1,'LineWidth',2)
            ylim([0.2 1])
            xticks([2:2:16])
            box off
            xlabel('Laps')
            ylabel('Bayesian bias score')


        else
            if t == 2
                num_laps = 1 : protocol(1).ID;
                alltog = nan(20,8);
                lgn = [5,4,3,2,1,1,1,1];
                for lap = 1 : length(num_laps)
                    all_prots = [];
                    for p = 1 : lgn(lap)
                        all_prots = [all_prots, protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,lap)'];
                    end
                    alltog(1:length(all_prots),lap) = all_prots;
                end
            else
                num_laps = 1 : 16;
                xlabels = [];
                for ii = 1 : length(num_laps)
                end
                alltog = [];
                for p = 1 : length(protocols)
                    alltog = [alltog; protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:16)];
                end

            end


            boxplot(alltog,'PlotStyle','traditional','Colors',[.6 .6 .6],'LabelOrientation','horizontal','Widths',0.5);
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
            allmarkers = {'h';'diamond';'o';'square'};
            all_marker_sizes = {6;5;5;6};
            for ii = 1 : size(alltog,2)
                h = plot(ii,alltog(:,ii),'o','MarkerEdgeColor',[.6 .6 .6],'MarkerFaceColor',[.6 .6 .6],'MarkerSize',2);
                % set(h,{'Marker'},allmarkers,{'Markersize'},all_marker_sizes,'MarkerFaceColor','w','LineWidth',1.5)
            end

            hold on
            track_mean = mean(alltog,1,'omitnan');
            plot(track_mean,'LineWidth',3,'Color',[.2 .2 .2])

        end

        box off
        xlabel('Lap number')
        ylabel({'Replay rate';'(event/sec)'})
        title(['Track ' num2str(t)])
        ax(t).FontSize = 16;
        set(ax(t),'TickLength',[0 0]);

    end

    tst = mean_lap_BB(:,1);
    tst = [tst; mean_lap_BB(:,4)];
    grp = ones(length(mean_lap_BB(:,1)),1);
    grp = [grp; ones(length(mean_lap_BB(:,4)),1)*2];
    figure;beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.T1;[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci','corral_style','rand');


    [p,~,stats] = kruskalwallis(all,gr);
    c = multcompare(stats);

    [p,~,stats] = kruskalwallis(BB_T4(1:10,:));
    c = multcompare(stats);
    [p,h,s] = ranksum(mean_lap_BB(:,3),mean_lap_BB(:,4));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DURATION
    mean_lap_duration = nan(16,4);
    all = [];
    gr = [];
    for t = 1 : num_tracks %for each track
        if t == 2 
            sz = size(replay_duration.(strcat(['T',num2str(t)])),2);
        else t ~= 2 
            sz = 16;
        end
        for lap = 1 : sz
            mean_lap_duration(lap,t) = mean(cat(1,replay_duration.(strcat(['T',num2str(t)])){:,lap}));
            std_lap_duration(lap,t) = std(cat(1,replay_duration.(strcat(['T',num2str(t)])){:,lap}));
            all = [all; cat(1,replay_duration.(strcat(['T',num2str(t)])){:,lap})];
            gr = [gr; ones(length(cat(1,replay_duration.(strcat(['T',num2str(t)])){:,lap})),1)*lap];
        end
        if t == 4
            c =1;
            for j = 1 : 5
                for lap = 1 : sz
                    dur_T4(lap,j) = mean(cat(1,replay_duration.(strcat(['T',num2str(t)])){c:c+3,lap}));
                end
                c = c+4;
            end
        end
    end

    [p,~,stats] = kruskalwallis(dur_T4);
    c = multcompare(stats);
    [p,h,s] = ranksum(mean_lap_duration(:,3),mean_lap_duration(:,4));
    [p,h,s] = ranksum(mean_lap_duration(1:6,1),mean_lap_duration(1:6,2));

    [p,h,s] = ranksum(mean_lap_duration(:,3),dur_T4(:,1))
    [p,h,s] = ranksum(dur_T4(:,1),dur_T4(:,2))
    [p,h,s] = ranksum(dur_T4(:,1),dur_T4(:,3))
    [p,h,s] = ranksum(dur_T4(:,1),dur_T4(:,4))
    [p,h,s] = ranksum(dur_T4(:,1),dur_T4(:,5))


    figure;
    plot(mean_lap_duration(:,1),'Color',PP.T1,'LineWidth',4)
    hold on
    plot(mean_lap_duration(:,1),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',3)
    x = 1 : length((mean_lap_BB(:,1)));
    shade1 = (mean_lap_duration(:,1) + std_lap_duration(:,1));
    shade2 = (mean_lap_duration(:,1) - std_lap_duration(:,1));
    x2 = [x,fliplr(x)]';
    inBetween = [shade1',fliplr(shade2')];
    h=fill(x2,inBetween,PP.T1);
    set(h,'facealpha',0.2,'LineStyle','none')

    plot(mean_lap_duration(:,3),'Color',[0.3 0.3 0.3],'LineWidth',4)
    hold on
    plot(mean_lap_duration(:,3),'o','MarkerFaceColor',[0.3 0.3 0.3],'MarkerEdgeColor',[0.3 0.3 0.3],'MarkerSize',3)
    x = 1 : length((mean_lap_BB(:,3)));
    shade1 = (mean_lap_duration(:,3) + std_lap_duration(:,3));
    shade2 = (mean_lap_duration(:,3) - std_lap_duration(:,3));
    x2 = [x,fliplr(x)]';
    inBetween = [shade1',fliplr(shade2')];
    h=fill(x2,inBetween,[0.4 0.4 0.4]);
    set(h,'facealpha',0.2,'LineStyle','none')

    plot(mean_lap_duration(:,4),'Color',[0.6 0.6 0.6],'LineWidth',4)
    hold on
    plot(mean_lap_duration(:,4),'o','MarkerFaceColor',[0.6 0.6 0.6],'MarkerEdgeColor',[0.6 0.6 0.6],'MarkerSize',3)
    x = 1 : length((mean_lap_duration(:,4)));
    shade1 = (mean_lap_duration(:,4) + std_lap_duration(:,4));
    shade2 = (mean_lap_duration(:,4) - std_lap_duration(:,4));
    x2 = [x,fliplr(x)];
    inBetween = [shade1',fliplr(shade2')];
    h=fill(x2,inBetween,[0.7 0.7 0.7]);
    set(h,'facealpha',0.2,'LineStyle','none')

    ylim([-0.01 .4])
    xticks([2:2:16])
    box off
    xlabel('Laps')
    ylabel('Replay event duration (s)')

    tst = mean_lap_duration(:,1);
    tst = [tst; mean_lap_duration(:,3)];
    tst = [tst; mean_lap_duration(:,4)];
    grp = ones(length(mean_lap_duration(:,1)),1);
    grp = [grp; ones(length(mean_lap_duration(:,3)),1)*2];
    grp = [grp; ones(length(mean_lap_duration(:,4)),1)*3];
    figure;beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.T1;[0.3 0.3 0.3];[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci','corral_style','rand');

    ylim([0.12 0.25])
    xticks([])
    box off
    ylabel('Replay event duration (s)')


    tst2 = mean_lap_duration(:,3);
    tst2 = [tst2;reshape(dur_T4,[size(dur_T4,1)*size(dur_T4,2),1])];
    grp2 = ones(length(mean_lap_duration(:,3)),1);
    for jj = 1 : size(dur_T4,2)
        grp2 = [grp2; ones(length(dur_T4(:,jj)),1)*jj+1];
    end
    figure;beeswarm(grp2,tst2,'sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci','corral_style','rand');

    tmp2 = [flip(dur_T4,2) mean_lap_duration(:,3) ];
    cols = [flip(PP.T2,1);PP.T1];

    figure;boxplot(tmp2,'PlotStyle','traditional','Color',cols)
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idxs = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = flipud(a(idxs));
    set(boxes,'LineWidth',.01); % Set width
    idx1 = find(strcmp(tt,'Outliers'));
    delete(a(idx1))
    idx2 = [find(strcmp(tt,'Upper Whisker')) find(strcmp(tt,'Lower Whisker'))];
    set(a(idx2),'LineStyle','-'); % Set width
    set(a(idx2),'LineWidth',1); % Set width
    idx3 = [find(strcmp(tt,'Upper Adjacent Value')) find(strcmp(tt,'Lower Adjacent Value'))];
    set(a(idx3),'LineWidth',0.5); % Set width

    hold on
    for ii = 1 : size(tmp2,2)
        patch(get(boxes(ii),'XData'),get(boxes(ii),'YData'),cols(ii,:),'FaceAlpha',.5)
        plot(ii,tmp2(:,ii),'o','MarkerFaceColor','w','MarkerEdgeColor',cols(ii,:),...
            'MarkerSize',6);
    end
    box off;   set(gcf,'Color','w');
    set(gca,'FontSize',14)
    xticklabels({'1','2','3','4','8','16'})
    ylabel('Replay event duration (s)')


    for t = 1 : num_tracks

        ax(t) = subplot(2,2,t);

        if t == 1 || t == 3
            all_prots = [];
            for p = 1 : length(protocols)
                all_prots = [all_prots; protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:16)];
            end

            boxplot(all,gr,'PlotStyle','traditional','Colors',[.6 .6 .6],'LabelOrientation','horizontal','Widths',0.5);
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
            for ii = 1 : 16
                h = plot(ii,all(gr==ii),'o','MarkerEdgeColor',[.6 .6 .6],'MarkerFaceColor',[.6 .6 .6],'MarkerSize',2);
            end

            hold on
            plot(mean_lap_duration(:,1),'Color',PP.T1,'LineWidth',2)
            ylim([0 0.45])
            xticks([2:2:16])
            box off
            xlabel('Laps')
            ylabel('Replay event duration (s)')


        else
            if t == 2
                num_laps = 1 : protocol(1).ID;
                alltog = nan(20,8);
                lgn = [5,4,3,2,1,1,1,1];
                for lap = 1 : length(num_laps)
                    all_prots = [];
                    for p = 1 : lgn(lap)
                        all_prots = [all_prots, protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,lap)'];
                    end
                    alltog(1:length(all_prots),lap) = all_prots;
                end
            else
                num_laps = 1 : 16;
                xlabels = [];
                for ii = 1 : length(num_laps)
                end
                alltog = [];
                for p = 1 : length(protocols)
                    alltog = [alltog; protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:16)];
                end

            end


            boxplot(alltog,'PlotStyle','traditional','Colors',[.6 .6 .6],'LabelOrientation','horizontal','Widths',0.5);
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
            allmarkers = {'h';'diamond';'o';'square'};
            all_marker_sizes = {6;5;5;6};
            for ii = 1 : size(alltog,2)
                h = plot(ii,alltog(:,ii),'o','MarkerEdgeColor',[.6 .6 .6],'MarkerFaceColor',[.6 .6 .6],'MarkerSize',2);
                % set(h,{'Marker'},allmarkers,{'Markersize'},all_marker_sizes,'MarkerFaceColor','w','LineWidth',1.5)
            end

            hold on
            track_mean = mean(alltog,1,'omitnan');
            plot(track_mean,'LineWidth',3,'Color',[.2 .2 .2])

        end

        box off
        xlabel('Lap number')
        ylabel({'Replay rate';'(event/sec)'})
        title(['Track ' num2str(t)])
        ax(t).FontSize = 16;
        set(ax(t),'TickLength',[0 0]);

    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure

    ax1 = subplot(2,1,1);
    hold on
    plot([mean(mean_lap_BB(1:8,1:2),2); mean_lap_BB(9:end,1)],'Color',[0.3 0.3 0.3],'LineWidth',2)
    plot(mean(mean_lap_BB(:,3:4),2),'Color',[0.6 0.6 0.6],'LineWidth',2)
    exp1 = [mean(mean_lap_BB(1:8,1:2),2); mean_lap_BB(9:end,1)];% T1+T2
    exp2 = mean(mean_lap_BB(:,3:4),2); % T3+T4
    [p,h,s] = ranksum(exp1(1:5),exp2(1:5));
    ylabel('Bayesian bias score')
    xlabel('Laps')
    legend({'T1 + T2';'R-T1 + R-T2'})
    ax1.FontSize = 16;

    ax2 = subplot(2,1,2);
    hold on
    exp3 =[mean(mean_lap_duration(1:8,1:2),2); mean_lap_duration(9:end,1)];% T1+T2
    plot(exp3,'Color',[0.3 0.3 0.3],'LineWidth',2)
    plot(mean_lap_duration(:,3),'Color',PP.T1,'LineWidth',2)
    plot(mean_lap_duration(:,4),'Color',[0.6 0.6 0.6],'LineWidth',2)
    ylabel('Replay event duration')
    xlabel('Laps')
    legend({'T1 + T2';'R-T1';'R-T2'})
    ax2.FontSize = 16;

    [p,~,stats] = kruskalwallis([exp3 mean_lap_duration(:,3:4)]);
    cc = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons

    [p,~,stats] = kruskalwallis([exp3(1:6) mean_lap_duration((1:6),3:4)]);
    cc = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons

    [p,h,s] = ranksum(mean_lap_duration(1:5,3),mean_lap_duration(1:5,4));
    [p,h,s] = ranksum(exp3(1:6),mean_lap_duration(1:6,4));

%%%%%% PLOTTING FOR SPEED CONTROL DATA SET

elseif strcmp(data_type,'speed')

    % Get sessions ID to find select corresponding color
    sessions_ID = sprintfc('%d',[protocol(:).ID]);
    color_idx = cell2mat(arrayfun(@(x) find(strcmp(fieldnames(PP),strcat('L', sessions_ID{x}))),1:length(sessions_ID),'UniformOutput',0));
    cols = cell2mat(arrayfun(@(x) PP.(subsref(fieldnames(PP),substruct('{}',{x}))),color_idx,'UniformOutput',0)');

    % BAYESIAN BIAS
    num_prot = size(protocol,2);
    prot_idx = 1; c=1;
    f1 = figure('Color','w','Name','Awake replay bayesian bias','units','normalized','outerposition',[0 0 1 1]);
    for p = 1 : num_prot
        num_rats = size(protocol(p).T1(1).Rat_chunk_duration,1);
        prot_idx = prot_idx: prot_idx+num_rats-1; % get indices of this protocol in the matrix
        all = []; mean_lap_BB = []; gr = [];
        mean_lap_BB = nan(16,num_tracks);
        std_lap_BB = nan(16,num_tracks);
        for t = 1 : num_tracks  %for each track
            if t < 3
                sz = protocol(p).ID;
            else
                sz = 16;
            end
            for lap = 1 : sz
                mean_lap_BB(lap,t) = mean(cat(1,bayesian_bias.(strcat(['T',num2str(t)])){prot_idx,lap}),'omitnan');
                std_lap_BB(lap,t) = std(cat(1,bayesian_bias.(strcat(['T',num2str(t)])){prot_idx,lap}),[],'omitnan');
                all = [all; cat(1,bayesian_bias.(strcat(['T',num2str(t)])){prot_idx,lap})];
                gr = [gr; ones(length(cat(1,bayesian_bias.(strcat(['T',num2str(t)])){prot_idx,lap})),1)*lap];
            end
        end

    figure(f1)
    ax = subplot(num_prot,3,c);
    hold on
    cols_order = [cols(p,:);cols(p,:);[.3 .3 .3];[.3 .3 .3]];
    face_col = [cols(p,:);[1 1 1];[.3 .3 .3];[1 1 1]];
    line_order = {'-o',':o','-o',':o'};
    lineW_order = [2,3,2,3];
    box off 
    for j =  1 : size(mean_lap_BB,2)
        pt(j) = plot(mean_lap_BB(:,j),line_order{j},'LineWidth',lineW_order(j),'Color',cols_order(j,:));
        ax.Children(1).MarkerSize = 4;
        ax.Children(1).MarkerFaceColor = face_col(j,:);
        hold on
        x = 1 : length((mean_lap_BB(:,j)));
        shade1 = (mean_lap_BB(:,j) + std_lap_BB(:,j));
        shade2 = (mean_lap_BB(:,j) - std_lap_BB(:,j));
        x2 = [x,fliplr(x)]';
        inBetween = [shade1',fliplr(shade2')];
        h=fill(x2,inBetween,cols_order(j,:));
        set(h,'facealpha',0.2,'LineStyle','none')
    end
    ylim([0 1]);  xticks([2:2:16]);
    xlabel('Laps');    ylabel('Bayesian bias score');
    set(ax,'FontSize',14)
    title(['Session ' sessions_ID{p} 'x'  sessions_ID{p}])
    legend([pt(1) pt(2) pt(3) pt(4)],{'T1','T2','R-T1','R-T2'},'Location','southeast')
    c=c+1;

    ax = subplot(num_prot,3,c);
    tst = []; grp = [];
    tst = reshape(mean_lap_BB,[size(mean_lap_BB,1)*size(mean_lap_BB,2),1]);
    grp = cell2mat(arrayfun(@(x) ones(size(mean_lap_BB(:,x),1),1)*x,1:size(mean_lap_BB,2),'UniformOutput',0));
    grp = reshape(grp,[size(grp,1)*size(grp,2),1]);
    beeswarm(grp,tst,'sort_style','nosort','colormap',cols_order,'dot_size',2,'overlay_style','ci','corral_style','none');
    xticks([1:num_tracks]); xticklabels({'T1','T2','R-T1','R-T2'})
    c=c+1;
    
    ax = subplot(num_prot,3,c);
    boxplot(mean_lap_BB,'PlotStyle','traditional','Colors',cols_order,'LabelOrientation','horizontal','Widths',0.5,...
        'Labels',{'T1','T2','R-T1','R-T2'},'symbol', '');
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx);  % Get the children you need (boxes for first exposure)
    set(a,'LineWidth',2); % Set width    set(idx,'LineWidth',2); % Set width
    box off
    c=c+1;

    end


    % REPLAY DURATION
    num_prot = size(protocol,2);
    prot_idx = 1; c=1;
    f2 = figure('Color','w','Name','Awake replay duration','units','normalized','outerposition',[0 0 1 1]);
    for p = 1 : num_prot
        num_rats = size(protocol(p).T1(1).Rat_chunk_duration,1);
        prot_idx = prot_idx: prot_idx+num_rats-1; % get indices of this protocol in the matrix
        all = []; mean_lap_BB = []; gr = [];
        mean_lap_BB = nan(16,num_tracks);
        std_lap_BB = nan(16,num_tracks);
        for t = 1 : num_tracks  %for each track
            if t < 3
                sz = protocol(p).ID;
            else
                sz = 16;
            end
            for lap = 1 : sz
                mean_lap_BB(lap,t) = mean(cat(1,replay_duration.(strcat(['T',num2str(t)])){prot_idx,lap}),'omitnan');
                std_lap_BB(lap,t) = std(cat(1,replay_duration.(strcat(['T',num2str(t)])){prot_idx,lap}),[],'omitnan');
                all = [all; cat(1,replay_duration.(strcat(['T',num2str(t)])){prot_idx,lap})];
                gr = [gr; ones(length(cat(1,replay_duration.(strcat(['T',num2str(t)])){prot_idx,lap})),1)*lap];
            end
        end

    figure(f2)
    ax = subplot(num_prot,3,c);
    hold on
    cols_order = [cols(p,:);cols(p,:);[.3 .3 .3];[.3 .3 .3]];
    face_col = [cols(p,:);[1 1 1];[.3 .3 .3];[1 1 1]];
    line_order = {'-o',':o','-o',':o'};
    lineW_order = [2,3,2,3];
    box off 
    for j =  1 : size(mean_lap_BB,2)
        pt(j) = plot(mean_lap_BB(:,j),line_order{j},'LineWidth',lineW_order(j),'Color',cols_order(j,:));
        ax.Children(1).MarkerSize = 4;
        ax.Children(1).MarkerFaceColor = face_col(j,:);
        hold on
        x = 1 : length((mean_lap_BB(:,j)));
        shade1 = (mean_lap_BB(:,j) + std_lap_BB(:,j));
        shade2 = (mean_lap_BB(:,j) - std_lap_BB(:,j));
        x2 = [x,fliplr(x)]';
        inBetween = [shade1',fliplr(shade2')];
        h=fill(x2,inBetween,cols_order(j,:));
        set(h,'facealpha',0.2,'LineStyle','none')
    end
    ylim([0 1]);  xticks([2:2:16]);
    xlabel('Laps');    ylabel('Bayesian bias score');
    set(ax,'FontSize',14)
    title(['Session ' sessions_ID{p} 'x'  sessions_ID{p}])
    legend([pt(1) pt(2) pt(3) pt(4)],{'T1','T2','R-T1','R-T2'},'Location','best')
    c=c+1;

    ax = subplot(num_prot,3,c);
    tst = []; grp = [];
    tst = reshape(mean_lap_BB,[size(mean_lap_BB,1)*size(mean_lap_BB,2),1]);
    grp = cell2mat(arrayfun(@(x) ones(size(mean_lap_BB(:,x),1),1)*x,1:size(mean_lap_BB,2),'UniformOutput',0));
    grp = reshape(grp,[size(grp,1)*size(grp,2),1]);
    beeswarm(grp,tst,'sort_style','nosort','colormap',cols_order,'dot_size',2,'overlay_style','ci','corral_style','rand');
    xticks([1:num_tracks]); xticklabels({'T1','T2','R-T1','R-T2'})
    c=c+1;
    
    ax = subplot(num_prot,3,c);
    boxplot(mean_lap_BB,'PlotStyle','traditional','Colors',cols_order,'LabelOrientation','horizontal','Widths',0.5,...
        'Labels',{'T1','T2','R-T1','R-T2'},'symbol', '');
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx);  % Get the children you need (boxes for first exposure)
    set(a,'LineWidth',2); % Set width    set(idx,'LineWidth',2); % Set width
    box off
    c=c+1;

    end
end

save_all_figures(path,[])

end
