% RATE REPLAY AWAKE (LOCAL AND REMOTE) IN TRACK - events/sec
% MH 2020
% Plots rate ot awake replay in track in line plot and bar plot. Third plot is for multievents data.
% INPUT: multievents - 1 for selection. If multievents, loads data with multi track events not excluded, thus simulating the existance of only 2
                      % tracks instead of 4.
       % data_type - data loaded. Can be 'main','speed','ctrl'
       % lap_option -  'complete' or 'half'. To compare complete or half-laps.
% OUTPUT: PROTOCOL structure- Each subfield is the period analysed (T1 to T4). Each row within a subfield, is the replay events decoded during the track period for each track.
       % E.g. Period T1 has 4 rows, corresponding to replay events detected in that period that decoded for T1 (1st row - local replay), T2 to T4 (2nd to 4th row - remote replay).
       % Within each row (track), there are 4 more rows corresponding to each rat, with multiple columns corresponding to lap by lap information.
       % General structure --> Protocol.Period(track).data(rat,chunk)
    
function protocol = extract_track_awake_replay_rate(data_type,multievents,lap_option)


% Parameters
% Load extracted time periods
if strcmp(data_type,'main')
    cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis')
    if multievents == 1
        load('extracted_replay_plotting_info_MultiEvents.mat')
    else
        load('extracted_replay_plotting_info.mat')
    end
    load('extracted_time_periods_replay.mat')
elseif strcmp(data_type,'speed')
    cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Speed')
    load('extracted_time_periods_replay.mat')
    load('extracted_replay_plotting_info.mat')
elseif strcmp(data_type,'ctrl')
    folder_name = strsplit(computer,'\');
    cd(strcat('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Controls\',folder_name{end}))
    load('extracted_time_periods_replay.mat')
    load('extracted_replay_plotting_info.mat')
end

PP =  plotting_parameters;
bin_width = 1; %1 sec
data_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\';
% Set periods to be analysed
if isfield(track_replay_events,'T3')
    periods = [{'T1'},{'T2'},{'T3'},{'T4'}];
else  % 2 tracks only
    periods = [{'T1'},{'T2'}];
end

% Find indices for each type of protocol
t2 = [];
for s = 1 : length(track_replay_events)
    name = cell2mat(track_replay_events(s).session(1));
    if strfind(name,'Ctrl')
        t2 = [t2 str2num(name(end-1:end))];
    else
        t2 = [t2 str2num(name(end))];
    end
end
protocols = unique(t2,'stable');

% Find number of tracks in the session
if isfield(track_replay_events,'T4')
    num_tracks = 4;
else
    num_tracks = 2;
end

protocol = struct;

% For each protocol (8,4,3,2 or 1)
for i = 1 : length(protocols)
    
    protocol(i).ID = protocols(i);
    this_protocol_idxs = find(t2 == protocols(i)); %find indices of sessions from the current protocol
    
    
    for s = 1 : length(this_protocol_idxs) %for each session/rat in this protocol
        curr_folder = strsplit(track_replay_events(this_protocol_idxs(s)).session{1},'_');
        rat = curr_folder{1};
        % Load extracted lap times for this session
        load([data_path rat '\' track_replay_events(this_protocol_idxs(s)).session{1} '\extracted_laps.mat'])
        
        for track = 1 : num_tracks %for each track
            
            lap_chunks = [lap_times(track).(sprintf('%s',lap_option,'Laps_start'))' lap_times(track).(sprintf('%s',lap_option,'Laps_stop'))'];
            
            % Divide current period in chunks of laps or half_laps
            for tc = 1 : size(lap_chunks,1) % for each time chunk within this period, find replay events per minute (replay rate)
                
                this_chunk_bin_edges = lap_chunks(tc,1) : bin_width : lap_chunks(tc,2);
                
                for p = 1 : length(periods) % In each track, find replay events decoding for every track
                    
                    %Find indices of replay within the chunk
                    replay_indcs = find(track_replay_events(this_protocol_idxs(s)).(sprintf('%s','T',num2str(p))).(sprintf('%s','T',num2str(track),'_times')) > lap_chunks(tc,1) & track_replay_events(this_protocol_idxs(s)).(sprintf('%s','T',num2str(p))).(sprintf('%s','T',num2str(track),'_times')) <= lap_chunks(tc,2));
                    replay_struct_idx = track_replay_events(this_protocol_idxs(s)).(sprintf('%s','T',num2str(p))).(sprintf('%s','T',num2str(track),'_index'))(replay_indcs); % find index ID in the structure to find score
                    replay_scores = track_replay_events(this_protocol_idxs(s)).(sprintf('%s','T',num2str(p))).score_all_sig_events(replay_struct_idx);
                    
                    % Save in structure Protocol.Period(track).data(rat,chunk)
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_num_events(s,tc) = length(replay_indcs); %number of events per chink
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_replay_rate(s,tc) = length(replay_indcs)/(length(this_chunk_bin_edges)-1); % replay per sec (rate) in each chunk
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_time_chunks{s,tc} =  lap_chunks(tc,:) ; % start & end timestamp for each chunk
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_chunk_duration(s,tc) = lap_chunks(tc,2)-lap_chunks(tc,1); % duration of each chunk
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_replay_score(s,tc) = mean(replay_scores); % mean replay scores on that lap
                    
                end
            end
        end
    end
end

% PLOT 1. LOCAL REPLAY PER PROTOCOL AND TRACK - LINE PLOT
% Each subplot is a track, where x axis are laps and y axis is replay rate per protocol
f1 = figure('units','normalized','outerposition',[0 0 1 1]);
f1.Name = ['Local awake replay in track per protocol_LINEPLOT_' lap_option ' laps'];

for t = 1 : num_tracks
    
    ax(t) = subplot(num_tracks,1,t);
    
    if t == 1 || t == 3
        all_prots = [];
        for p = 1 : length(protocols)
            all_prots = [all_prots; protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:16)];
        end
        mean_T1 = mean(all_prots,1);
        
        plot(mean_T1,'LineWidth',PP.Linewidth{t},'Color',PP.T1,'LineStyle',PP.Linestyle{t})
        hold on
        x = 1 : length(mean_T1);
        shade1 = mean_T1 + std(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:16),[],1);
        shade2 = mean_T1 - std(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:16),[],1);
        x2 = [x,fliplr(x)];
        inBetween = [shade1,fliplr(shade2)];
        h=fill(x2,inBetween,PP.T1);
        set(h,'facealpha',0.2,'LineStyle','none')
    else
        for p = 1 : length(protocols)
            if t == 2
                lap_end = protocol(p).ID;
            else
                lap_end = 16;
            end
            track_mean = mean(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:lap_end),1);
            track_std = std(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:lap_end),[],1);
            plot(track_mean,'LineWidth',PP.Linewidth{t},'Color',PP.T2(p,:),'LineStyle',PP.Linestyle{t})
            hold on
            x = 1 : length(track_mean);
            shade1 = track_mean + track_std;
            shade2 = track_mean - track_std;
            x2 = [x,fliplr(x)];
            inBetween = [shade1,fliplr(shade2)];
            h=fill(x2,inBetween,PP.T2(p,:));
            set(h,'facealpha',0.2,'LineStyle','none')
        end
    end
    
    box off
    xlabel('Lap number')
    ylabel({'Replay rate';'(event/sec)'})
    title(['Track ' num2str(t)])
    ax(t).XLim = [1 max(xlim)];
    ax(t).FontSize = 16;
end

% PLOT 2. LOCAL REPLAY PER PROTOCOL AND TRACK - BOX PLOT
% Each subplot is a track, where x axis are laps and y axis is replay rate per protocol
f2 = figure('units','normalized','outerposition',[0 0 1 1]);
f2.Name = ['Local awake replay in track per protocol_BOXPLOT_' lap_option ' laps'];

for t = 1 : num_tracks
    
    ax(t) = subplot(num_tracks,1,t);
    
    if t == 1 || t == 3
        all_prots = [];
        for p = 1 : length(protocols)
            all_prots = [all_prots; protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:16)];
        end
        
        boxplot(all_prots,'PlotStyle','traditional','Colors',PP.T1,'LabelOrientation','horizontal','Widths',0.5);
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        tt = get(a,'tag');   % List the names of all the objects
        idx = find(strcmpi(tt,'box')==1);  % Find Box objects
        boxes = a(idx);  % Get the children you need (boxes for first exposure)
        set(a,'LineWidth',2); % Set width
        box off
        
        hold on
        allmarkers = repmat({'h';'diamond';'o';'square'},[5,1]);
        all_marker_sizes = repmat({6;5;5;6},[5,1]);
        for ii = 1 : size(all_prots,2)
            h = plot(ii,all_prots(:,ii),'o','MarkerEdgeColor',PP.T1,'MarkerFaceColor',PP.T1,'MarkerSize',5);
            set(h,{'Marker'},allmarkers,{'Markersize'},all_marker_sizes,'MarkerFaceColor','w','LineWidth',1.5)
        end
        
        
    else
        if t == 2
            num_laps = 1 : protocol(1).ID;
            gaps = [5,10,14,17,19,21,23];
            cols = [PP.T2;[1,1,1]; PP.T2(1:4,:);[1,1,1];PP.T2(1:3,:);[1,1,1];PP.T2(1:2,:);[1,1,1];PP.T2(1,:);[1,1,1];PP.T2(1,:);[1,1,1];PP.T2(1,:);[1,1,1];PP.T2(1,:)];
            xlabels = {'.','.','1','.','.','.','.','.','2','.','.','.','3','.','.','4','.','.','5','.','6','.','7','.','8'};
        else
            num_laps = 1 : 16;
            gaps = 5:6:(6*16);
            cols = repmat([PP.T2;[1,1,1]],[16,1]);
            xlabels = [];
            for ii = 1 : length(num_laps)
                xlabels = [xlabels {'.','.',num2str(ii),'.','.','.'}];
            end
            
        end
        all_prots = [];
        for lap = 1 : length(num_laps)
            for p = 1 : length(protocols)
                if size(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate,2) >= lap
                    all_prots = [all_prots protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,lap)];
                end
                if any(ismember(gaps,size(all_prots,2)))
                    all_prots = [all_prots nan(4,1)];
                end
            end
        end
        
        boxplot(all_prots,'PlotStyle','traditional','Colors',cols,'Labels',xlabels,'LabelOrientation','horizontal','Widths',0.5);
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        tt = get(a,'tag');   % List the names of all the objects
        idx = find(strcmpi(tt,'box')==1);  % Find Box objects
        boxes = a(idx);  % Get the children you need (boxes for first exposure)
        set(a,'LineWidth',2); % Set width
        box off
        
        hold on
        allmarkers = {'h';'diamond';'o';'square'};
        all_marker_sizes = {6;5;5;6};
        for ii = 1 : size(all_prots,2)
            h = plot(ii,all_prots(:,ii),'o','MarkerEdgeColor',cols(ii,:),'MarkerFaceColor',cols(ii,:),'MarkerSize',5);
            set(h,{'Marker'},allmarkers,{'Markersize'},all_marker_sizes,'MarkerFaceColor','w','LineWidth',1.5)
        end
    end
    
    box off
    xlabel('Lap number')
    ylabel({'Replay rate';'(event/sec)'})
    title(['Track ' num2str(t)])
    ax(t).FontSize = 16;
    set(ax(t),'TickLength',[0 0]);
    
end

% PLOT 3. LOCAL & REMOTE REPLAY PER PROTOCOL AND TRACK - LINE PLOT
% Each subplot is a track, where x axis are laps and y axis is replay rate per protocol
if multievents == 1
    f3 = figure('units','normalized','outerposition',[0 0 1 1]);
    f3.Name = ['Local and remote awake replay in track per protocol_LINEPLOT_' lap_option ' laps'];
    c =1;
    for t = 1 : 2
        
        if t == 1
            ax2(c) = subplot(6,1,c);
            lap_end = 16;
            for track = 1 : 2
                all_prots = [];
                for p = 1 : length(protocols)
                    all_prots = [all_prots; protocol(p).(sprintf('%s','T',num2str(t)))(track).Rat_replay_rate(:,1:lap_end)];
                end
                mean_T1 = mean(all_prots,1);
                colors = [PP.T1;[0.6 0.6 0.6];PP.T1;[0.6 0.6 0.6]];
                plot(mean_T1,'LineWidth',PP.Linewidth{track},'Color',colors(track,:),'LineStyle',PP.Linestyle{track})
                hold on
                x = 1 : length(mean_T1);
                shade1 = mean_T1 + std(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:lap_end),[],1);
                shade2 = mean_T1 - std(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:lap_end),[],1);
                x2 = [x,fliplr(x)];
                inBetween = [shade1,fliplr(shade2)];
                h=fill(x2,inBetween,colors(track,:));
                set(h,'facealpha',0.2,'LineStyle','none')
            end
            box off
            xlabel('Lap number')
            ylabel({'Replay rate';'(event/sec)'})
            title(['Track ' num2str(t) '-' num2str(lap_end) ' laps'])
            ax2(c).FontSize = 16;
            c = c+1;
            
        else
            for p = 1 : length(protocols)
                ax2(c) = subplot(6,1,c);
                
                if t == 2
                    lap_end = protocol(p).ID;
                end
                for track = 1 : 2
                    track_mean = mean(protocol(p).(sprintf('%s','T',num2str(t)))(track).Rat_replay_rate(:,1:lap_end),1);
                    track_std = std(protocol(p).(sprintf('%s','T',num2str(t)))(track).Rat_replay_rate(:,1:lap_end),[],1);
                    plot(track_mean,'LineWidth',PP.Linewidth{track},'Color',PP.P(p).colorT(track,:),'LineStyle',PP.Linestyle{track})
                    if c == 6
                        plot(track_mean,'Marker','o','MarkerEdgeColor',PP.P(p).colorT(track,:),'MarkerFaceColor',PP.P(p).colorT(track,:),'MarkerSize',4)
                    end
                    hold on
                    x = 1 : length(track_mean);
                    shade1 = track_mean + track_std;
                    shade2 = track_mean - track_std;
                    x2 = [x,fliplr(x)];
                    inBetween = [shade1,fliplr(shade2)];
                    h=fill(x2,inBetween,PP.P(p).colorT(track,:));
                    set(h,'facealpha',0.2,'LineStyle','none')
                end
                box off
                xlabel('Lap number')
                ylabel({'Replay rate';'(event/sec)'})
                title(['Track ' num2str(t) '-' num2str(lap_end) ' laps'])
                ax2(c).FontSize = 16;
                c = c+1;
            end
        end
        
        if c ==7
            linkaxes([ax2(1) ax2(2) ax2(3) ax2(4) ax2(5) ax2(6)])
        end
    end
    
end

% save
save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
if multievents == 1
    save([save_path '\extracted_awake_replay_track_MultiEvents.mat'],'protocol','-v7.3')
else
    save([save_path '\extracted_awake_replay_track.mat'],'protocol','-v7.3')
end
save_all_figures(pwd,[])
end