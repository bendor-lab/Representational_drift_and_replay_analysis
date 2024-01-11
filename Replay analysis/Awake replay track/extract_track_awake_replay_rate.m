% RATE REPLAY AWAKE (LOCAL AND REMOTE) IN TRACK - events/sec
% MH 2020
% Plots rate of awake replay in track in line plot and bar plot. Third plot is for multievents data.
% INPUT: multievents - 1 for selection. If multievents, loads data with multi track events not excluded, thus simulating the existance of only 2
                      % tracks instead of 4.
       % data_type - data loaded. Can be 'main','speed','ctrl'
       % lap_option -  'complete' or 'half'. To compare complete or half-laps.
% OUTPUT: PROTOCOL structure- Each subfield is the period analysed (T1 to T4). Each row within a subfield, is the replay events decoded during the track period for each track.
       % E.g. Period T1 has 4 rows, corresponding to replay events detected in that period that decoded for T1 (1st row - local replay), T2 to T4 (2nd to 4th row - remote replay).
       % Within each row (track), there are 4 more rows corresponding to each rat, with multiple columns corresponding to lap by lap information.
       % General structure --> Protocol.Period(track).data(rat,chunk)
    
function protocol = extract_track_awake_replay_rate(data_type,multievents,lap_option,bayesian_control)


% Parameters
% Load extracted time periods
if strcmp(data_type,'main') & isempty(bayesian_control)
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
elseif strcmp(data_type,'speed')
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Speed';
elseif strcmp(data_type,'ctrl')
    folder_name = strsplit(computer,'\');
    path = strcat('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Controls\',folder_name{end});
elseif strcmp(data_type,'main') & ~isempty(bayesian_control)
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only first exposure';
    path2 = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only re-exposure';
end
if multievents == 1
    load([path '\extracted_replay_plotting_info_MultiEvents.mat'])
else
    if ~isempty(bayesian_control)
        track_replay_events_F = load([path '\extracted_replay_plotting_info_excl.mat']);
        track_replay_events_R = load([path2 '\extracted_replay_plotting_info_excl.mat']);
        track_replay_events = track_replay_events_F.track_replay_events;
    else
        load([path '\extracted_replay_plotting_info_excl.mat'])
    end
end
load([path '\extracted_time_periods_replay.mat']) % for bayesian_control any of the paths works

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
    elseif strfind(name,'Speed')
        idx_x =  strfind(name,'x');
        t2 = [t2 str2num(name(idx_x+1:end))];
    else
        t2 = [t2 str2num(name(end))];
    end
end
protocols = unique(t2,'stable');

% Find number of tracks in the session
if isfield(track_replay_events,'T4')  | ~isempty(bayesian_control)
    num_tracks = 4;
else
    num_tracks = 2;
end

protocol = struct;

% For each protocol (e.g. 8,4,3,2 or 1)
for i = 1 : length(protocols)
    
    protocol(i).ID = protocols(i);
    protocol(i).lap_option = lap_option;
    this_protocol_idxs = find(t2 == protocols(i)); %find indices of sessions from the current protocol
    
    
    for s = 1 : length(this_protocol_idxs) %for each session/rat in this protocol
        curr_folder = strsplit(track_replay_events(this_protocol_idxs(s)).session{1},'_');
        rat = curr_folder{1}(1:5);
        % Load extracted lap times for this session
        load([data_path rat '\' track_replay_events(this_protocol_idxs(s)).session{1} '\extracted_laps.mat'])
        
        for track = 1 : num_tracks %for each track

            if ~isempty(bayesian_control) & track > 2
                track_replay_events = track_replay_events_R.track_replay_events;
            elseif  ~isempty(bayesian_control) & track < 2
                track_replay_events = track_replay_events_F.track_replay_events;
            end

            lap_chunks = [lap_times(track).(sprintf('%s',lap_option,'Laps_start'))' lap_times(track).(sprintf('%s',lap_option,'Laps_stop'))'];
            
            % Divide current period in chunks of laps or half_laps
            for tc = 1 : size(lap_chunks,1) % for each time chunk within this period, find replay events per minute (replay rate)

                this_chunk_bin_edges = lap_chunks(tc,1) : bin_width : lap_chunks(tc,2);

                % Calculate rate of all events (local and remote) in that lap_chunk
                if isempty(bayesian_control)
                    all_track_events = [track_replay_events(this_protocol_idxs(s)).T1.(sprintf('%s','T',num2str(track),'_times')) track_replay_events(this_protocol_idxs(s)).T2.(sprintf('%s','T',num2str(track),'_times')) ...
                        track_replay_events(this_protocol_idxs(s)).T3.(sprintf('%s','T',num2str(track),'_times')) track_replay_events(this_protocol_idxs(s)).T4.(sprintf('%s','T',num2str(track),'_times'))];
                else
                    all_track_events = [track_replay_events(this_protocol_idxs(s)).T1.(sprintf('%s','T',num2str(track),'_times')) track_replay_events(this_protocol_idxs(s)).T2.(sprintf('%s','T',num2str(track),'_times'))];
                end
                all_replay_indcs = find(all_track_events > lap_chunks(tc,1) & all_track_events <= lap_chunks(tc,2));
                protocol(i).(sprintf('%s','T',num2str(track)))(1).Rat_ALL_replay_rate(s,tc) = length(all_replay_indcs)/(length(this_chunk_bin_edges)-1); % replay per sec (rate) in each chunk

                % Calculate rate of all local events in that lap_chunk
                if mod(track,2) == 0 &  isempty(bayesian_control)
                    local_track_events = [track_replay_events(this_protocol_idxs(s)).T2.(sprintf('%s','T',num2str(track),'_times')) track_replay_events(this_protocol_idxs(s)).T4.(sprintf('%s','T',num2str(track),'_times'))];
                elseif mod(track,2) == 0 &  ~isempty(bayesian_control)
                    local_track_events = track_replay_events(this_protocol_idxs(s)).T2.(sprintf('%s','T',num2str(track),'_times'));
                elseif mod(track,2) ~= 0 &  isempty(bayesian_control)
                    local_track_events = [track_replay_events(this_protocol_idxs(s)).T1.(sprintf('%s','T',num2str(track),'_times')) track_replay_events(this_protocol_idxs(s)).T3.(sprintf('%s','T',num2str(track),'_times'))];
                else
                    local_track_events = track_replay_events(this_protocol_idxs(s)).T1.(sprintf('%s','T',num2str(track),'_times'));
                end

                all_replay_indcs = find(local_track_events > lap_chunks(tc,1) & local_track_events <= lap_chunks(tc,2));
                protocol(i).(sprintf('%s','T',num2str(track)))(1).Rat_LOCAL_replay_rate(s,tc) = length(all_replay_indcs)/(length(this_chunk_bin_edges)-1); % replay per sec (rate) in each chunk


                for p = 1 : length(periods) % In each track, find replay events decoding for every track - here periods are: T1, T2, T3 and T4

                    %Find indices of replay within the chunk
                    replay_indcs = find(track_replay_events(this_protocol_idxs(s)).(sprintf('%s','T',num2str(p))).(sprintf('%s','T',num2str(track),'_times')) > lap_chunks(tc,1) & track_replay_events(this_protocol_idxs(s)).(sprintf('%s','T',num2str(p))).(sprintf('%s','T',num2str(track),'_times')) <= lap_chunks(tc,2));
                    replay_struct_idx = track_replay_events(this_protocol_idxs(s)).(sprintf('%s','T',num2str(p))).(sprintf('%s','T',num2str(track),'_index'))(replay_indcs); % find index ID in the structure to find score
                    replay_struct_REF_idx = track_replay_events(this_protocol_idxs(s)).(sprintf('%s','T',num2str(p))).(sprintf('%s','T',num2str(track),'_REAL_index'))(replay_indcs); % find index ID in the structure to find score
                    replay_scores = track_replay_events(this_protocol_idxs(s)).(sprintf('%s','T',num2str(p))).score_all_sig_events(replay_struct_idx);
                    replay_pvalues = track_replay_events(this_protocol_idxs(s)).(sprintf('%s','T',num2str(p))).pval_all_sig_events(replay_struct_idx);

                    % Save in structure Protocol(ID).Task_period(track).data(rat,lap)
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_replay_REF_idx{s,tc} = replay_struct_REF_idx; %indices per lap
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_num_events(s,tc) = length(replay_indcs); %number of events per chunk
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_replay_rate(s,tc) = length(replay_indcs)/(length(this_chunk_bin_edges)-1); % replay per sec (rate) in each chunk
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_time_chunks{s,tc} =  lap_chunks(tc,:) ; % start & end timestamp for each chunk
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_chunk_duration(s,tc) = lap_chunks(tc,2)-lap_chunks(tc,1); % duration of each chunk
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_replay_score{s,tc} = replay_scores; % replay scores on that lap
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_mean_replay_score(s,tc) = mean(replay_scores); % mean replay scores on that lap
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_replay_pvalue{s,tc} = replay_pvalues; % replay pvalues on that lap
                    protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_mean_replay_pvalue(s,tc) = mean(replay_pvalues); % mean replay pvalues on that lap
                end
            end

            % Calculate average and std lap replay rate per lap for each period
            for p = 1 : length(periods)
                protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_lap_average_replay_rate = [[mean(protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_replay_rate,2,'omitnan')]';[std(protocol(i).(sprintf('%s','T',num2str(track)))(p).Rat_replay_rate,[],2,'omitnan')]']; %mean (top) and std (bottom)
           end
           % Calculate average and std lap replay rate per track using all local and remote events, and then only local
           protocol(i).(sprintf('%s','T',num2str(track)))(1).Rat_average_ALL_replay_rate = [[mean(protocol(i).(sprintf('%s','T',num2str(track)))(1).Rat_ALL_replay_rate,2,'omitnan')]';[std(protocol(i).(sprintf('%s','T',num2str(track)))(1).Rat_ALL_replay_rate,[],2,'omitnan')]']; %mean (top) and std (bottom)
           protocol(i).(sprintf('%s','T',num2str(track)))(1).Rat_average_LOCAL_replay_rate = [[mean(protocol(i).(sprintf('%s','T',num2str(track)))(1).Rat_LOCAL_replay_rate,2,'omitnan')]';[std(protocol(i).(sprintf('%s','T',num2str(track)))(1).Rat_LOCAL_replay_rate,[],2,'omitnan')]']; %mean (top) and std (bottom)
        end
    end                   
end

% save
if ~isempty(bayesian_control)
    save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls';
else
    save_path = path;
end
if multievents == 1
    save([save_path '\extracted_awake_replay_track_',lap_option,'lap_MultiEvents.mat'],'protocol','-v7.3')
else
    save([save_path '\extracted_awake_replay_track_',lap_option,'lap_excl.mat'],'protocol','-v7.3')
end


% PLOT 1. LOCAL REPLAY PER PROTOCOL AND TRACK - LINE PLOT
% Each subplot is a track, where x axis are laps and y axis is replay rate per protocol
f1 = figure('units','normalized','outerposition',[0 0 1 1]);
f1.Name = ['Local awake replay in track per protocol_LINEPLOT_' lap_option ' laps'];

for t = 1 : num_tracks
    
    %ax(t) = subplot(num_tracks,1,t);
    
    if strcmp(data_type,'main') & t == 1 || t == 3
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
            if t < 3
                lap_end = protocol(p).ID;
            else
                lap_end = 16;
            end
            track_mean = mean(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:lap_end),1);
            track_std = std(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:lap_end),[],1);
            plot(track_mean,'LineWidth',PP.Linewidth{t},'Color',PP.T2(p,:),'LineStyle',PP.Linestyle{t})
            hold on
            plot(track_mean,'o','MarkerFaceColor',PP.T2(p,:),'MarkerEdgeColor',PP.T2(p,:))
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
    
    if strcmp(data_type,'main') &  t == 1 || t == 3
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
        allmarkers(20,:) = [];all_marker_sizes(20,:) = [];
        for ii = 1 : size(all_prots,2)
            h = plot(ii,all_prots(:,ii),'o','MarkerEdgeColor',PP.T1,'MarkerFaceColor',PP.T1,'MarkerSize',5);
            set(h,{'Marker'},allmarkers,{'Markersize'},all_marker_sizes,'MarkerFaceColor','w','LineWidth',1.5)
        end
        
        
    else
        if t < 3
            num_laps = 1 : protocol(1).ID;
            gaps = [5,10,14,17,19,21,23]+1;
            cols = [PP.T2;[1,1,1]; PP.T2(1:4,:);[1,1,1];PP.T2(1:3,:);[1,1,1];PP.T2(1:2,:);[1,1,1];PP.T2(1,:);[1,1,1];PP.T2(1,:);[1,1,1];PP.T2(1,:);[1,1,1];PP.T2(1,:)];
            xlabels = {'.','.','1','.','.','.','.','.','2','.','.','.','3','.','.','4','.','.','5','.','6','.','7','.','8'};
            all_prots = NaN(4,25);
        else
            num_laps = 1 : 16;
            gaps = [5:6:(6*16)]+1;
            cols = repmat([PP.T2;[1,1,1]],[16,1]);
            xlabels = [];
            for ii = 1 : length(num_laps)
                xlabels = [xlabels {'.','.',num2str(ii),'.','.','.'}];
            end
            all_prots = NaN(4,96);
        end
        c = 1;
        for lap = 1 : length(num_laps)
            for p = 1 : length(protocols)
                if size(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate,2) >= lap
                    all_prots(1:length(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,lap)),c) = protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,lap);
                    c = c+1;
                end
                if any(ismember(gaps,c))
                    c = c+1;
                    all_prots(:,c) = nan(4,1);
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

% PLOT 2.1. VERSION OF LOCAL REPLAY PER PROTOCOL AND TRACK - BOX PLOT
% Each subplot is a track, where x axis are laps and y axis is replay rate per protocol
f21 = figure('units','normalized','outerposition',[0 0 1 1]);
f21.Name = ['Local awake replay in track per protocol_BOXPLOT_' lap_option ' laps'];

for t = 1 : num_tracks
    
    ax(t) = subplot(2,2,t);
    
    if strcmp(data_type,'main') &  t == 1 || t == 3
        all_prots = [];
        for p = 1 : length(protocols)
            all_prots = [all_prots; protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:16)];
        end
        
        boxplot(all_prots,'PlotStyle','traditional','Colors',[.6 .6 .6],'LabelOrientation','horizontal','Widths',0.5);
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
        allmarkers = repmat({'h';'diamond';'o';'square'},[5,1]);
        all_marker_sizes = repmat({6;5;5;6},[5,1]);
        for ii = 1 : size(all_prots,2)
            h = plot(ii,all_prots(:,ii),'o','MarkerEdgeColor',[.6 .6 .6],'MarkerFaceColor',[.6 .6 .6],'MarkerSize',2);
            %set(h,{'Marker'},allmarkers,{'Markersize'},all_marker_sizes,'MarkerFaceColor','w','LineWidth',1.5)PP.T1
        end
        
        hold on
        all_prots = [];
        for p = 1 : length(protocols)
            all_prots = [all_prots; protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:16)];
        end
        mean_T1 = mean(all_prots,1);
        plot(mean_T1,'LineWidth',3,'Color',PP.T1)
        
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
            if ~isempty(bayesian_control)
                tck = 2;
            else
                tck = 4 ;
            end
            for ii = 1 : length(num_laps)
                alltog = [];
                for p = 1 : length(protocols)
                    alltog = [alltog; protocol(p).(sprintf('%s','T',num2str(t)))(tck).Rat_replay_rate(:,1:16)]; %each row a session from 8 to 1
                end
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

%%%%%%%%

if strcmp(data_type,'main') % RUN THESE FIGURES IF MAIN DATA


% PLOT LOCAL RATE PER TRACK (NOT LAP) & SESSION

T1_replay_rate = cell2mat(arrayfun(@(x) protocol(x).T1(1).Rat_average_LOCAL_replay_rate(1,:),1:length(protocol),'UniformOutput',0));
T2_replay_rate = cell2mat(arrayfun(@(x) protocol(x).T2(1).Rat_average_LOCAL_replay_rate(1,:),1:length(protocol),'UniformOutput',0));
T3_replay_rate = cell2mat(arrayfun(@(x) protocol(x).T3(1).Rat_average_LOCAL_replay_rate(1,:),1:length(protocol),'UniformOutput',0));
T4_replay_rate = cell2mat(arrayfun(@(x) protocol(x).T4(1).Rat_average_LOCAL_replay_rate(1,:),1:length(protocol),'UniformOutput',0));
xs = [repmat(1,[19,1]);repmat(2,[4,1]);repmat(3,[3,1]);repmat(4,[4,1]);repmat(5,[4,1]);repmat(6,[4,1])];
xs2 = [repmat(1,[19,1]);repmat(2,[19,1]);repmat(3,[19,1]);repmat(4,[19,1])];

f14= figure('Name','Local track rate awake replay per track','Color','w');
tiledlayout('flow')
nexttile
beeswarm(xs,[T1_replay_rate T2_replay_rate]','sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci');
nexttile
beeswarm(xs,[T3_replay_rate T4_replay_rate]','sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci');
nexttile
beeswarm(xs2,[T1_replay_rate T2_replay_rate T3_replay_rate T4_replay_rate]','sort_style','nosort','colormap',[PP.T1;[0.3 0.3 0.3];PP.T1;[0.3 0.3 0.3]],'dot_size',2,'overlay_style','ci');
allAxesInFigure = findall(f14,'type','axes');
ylabel(allAxesInFigure,{'Average awake replay';'rate (events/s)'})
set(allAxesInFigure(1),'XTick',[1:4],'XTickLabel',{'T1','T2','R-T1','R-T2'})
set(allAxesInFigure(2:3),'XTick',[1:6],'XTickLabel',[16,8,4,3,2,1])
set(allAxesInFigure,'FontSize',16,'TickDir','out','LineWidth',1.5,'TickLength',[.005 1])

%Stats 
[p,~,stats] = kruskalwallis([T1_replay_rate; T2_replay_rate ;T3_replay_rate ;T4_replay_rate]');
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
[p2,~] = ranksum(T3_replay_rate,T4_replay_rate)
[p3,~,stats] = kruskalwallis([T1_replay_rate;[T2_replay_rate(1:4) NaN(1,15)];[T2_replay_rate(5:7) NaN(1,16)];[T2_replay_rate(8:11) NaN(1,15)];...
    [T2_replay_rate(12:15) NaN(1,15)];[T2_replay_rate(16:19) NaN(1,15)]]');
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
[p4,~,stats] = kruskalwallis([T3_replay_rate;[T4_replay_rate(1:4) NaN(1,15)];[T4_replay_rate(5:7) NaN(1,16)];[T4_replay_rate(8:11) NaN(1,15)];...
    [T4_replay_rate(12:15) NaN(1,15)];[T4_replay_rate(16:19) NaN(1,15)]]');
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons

% PLOT ALL RATE PER TRACK (NOT LAP) & SESSION

T1_replay_rate = cell2mat(arrayfun(@(x) protocol(x).T1(1).Rat_average_ALL_replay_rate(1,:),1:length(protocol),'UniformOutput',0));
T2_replay_rate = cell2mat(arrayfun(@(x) protocol(x).T2(1).Rat_average_ALL_replay_rate(1,:),1:length(protocol),'UniformOutput',0));
T3_replay_rate = cell2mat(arrayfun(@(x) protocol(x).T3(1).Rat_average_ALL_replay_rate(1,:),1:length(protocol),'UniformOutput',0));
T4_replay_rate = cell2mat(arrayfun(@(x) protocol(x).T4(1).Rat_average_ALL_replay_rate(1,:),1:length(protocol),'UniformOutput',0));
xs = [repmat(1,[19,1]);repmat(2,[4,1]);repmat(3,[3,1]);repmat(4,[4,1]);repmat(5,[4,1]);repmat(6,[4,1])];
xs2 = [repmat(1,[19,1]);repmat(2,[19,1]);repmat(3,[19,1]);repmat(4,[19,1])];

f15= figure('Name','Rate local and remote awake replay per track','Color','w');
tiledlayout('flow')
nexttile
beeswarm(xs,[T1_replay_rate T2_replay_rate]','sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci');
nexttile
beeswarm(xs,[T3_replay_rate T4_replay_rate]','sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci');
nexttile
beeswarm(xs2,[T1_replay_rate T2_replay_rate T3_replay_rate T4_replay_rate]','sort_style','nosort','colormap',[PP.T1;[0.3 0.3 0.3];PP.T1;[0.3 0.3 0.3]],'dot_size',2,'overlay_style','ci');
allAxesInFigure = findall(f15,'type','axes');
ylabel(allAxesInFigure,{'Average awake replay';'rate (events/s)'})
set(allAxesInFigure(1),'XTick',[1:4],'XTickLabel',{'T1','T2','R-T1','R-T2'})
set(allAxesInFigure(2:3),'XTick',[1:6],'XTickLabel',[16,8,4,3,2,1])
set(allAxesInFigure,'FontSize',16,'TickDir','out','LineWidth',1.5,'TickLength',[.005 1])

%Stats 
[p,~,stats] = kruskalwallis([T1_replay_rate; T2_replay_rate ;T3_replay_rate ;T4_replay_rate]');
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons

% PLOT LOCAL(only one exposure) RATE PER TRACK (NOT LAP) & SESSION

T1_replay_rate = cell2mat(arrayfun(@(x) protocol(x).T1(1).Rat_lap_average_replay_rate(1,:),1:length(protocol),'UniformOutput',0));
T2_replay_rate = cell2mat(arrayfun(@(x) protocol(x).T2(2).Rat_lap_average_replay_rate(1,:),1:length(protocol),'UniformOutput',0));
T3_replay_rate = cell2mat(arrayfun(@(x) protocol(x).T3(3).Rat_lap_average_replay_rate(1,:),1:length(protocol),'UniformOutput',0));
T4_replay_rate = cell2mat(arrayfun(@(x) protocol(x).T4(4).Rat_lap_average_replay_rate(1,:),1:length(protocol),'UniformOutput',0));
xs = [repmat(1,[20,1]);repmat(2,[4,1]);repmat(3,[4,1]);repmat(4,[4,1]);repmat(5,[4,1]);repmat(6,[4,1])];
xs2 = [repmat(1,[20,1]);repmat(2,[20,1]);repmat(3,[20,1]);repmat(4,[20,1])];

f16= figure('Name','Rate local exposure awake replay per track','Color','w');
tiledlayout('flow')
nexttile
beeswarm(xs,[T1_replay_rate T2_replay_rate]','sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci')
nexttile
beeswarm(xs,[T3_replay_rate T4_replay_rate]','sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci')
nexttile
beeswarm(xs2,[T1_replay_rate T2_replay_rate T3_replay_rate T4_replay_rate]','sort_style','nosort','colormap',[PP.T1;[0.3 0.3 0.3];PP.T1;[0.3 0.3 0.3]],'dot_size',2,'overlay_style','ci')
allAxesInFigure = findall(f16,'type','axes');
ylabel(allAxesInFigure,'Average awake replay rate (events/s)')
set(allAxesInFigure(1),'XTick',[1:4],'XTickLabel',{'T1','T2','R-T1','R-T2'})
set(allAxesInFigure(2:3),'XTick',[1:6],'XTickLabel',[16,8,4,3,2,1])
set(allAxesInFigure,'FontSize',16,'TickDir','out','LineWidth',1.5,'TickLength',[.005 1])

%Stats 
[p,tble,stats] = kruskalwallis([T1_replay_rate; T2_replay_rate ;T3_replay_rate ;T4_replay_rate]');
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
 

%%%%%%%%%%%%%%%%%%%%
cnt = 1;
for p = 1 : 5
    t4_sep(:,p) = mean(alltog(cnt:cnt+3,:),1);
    cnt = cnt+4;
end

mat2 = reshape(t4_sep,[80,1]);
grp2 = [repmat(1,[16,1]);repmat(2,[16,1]);repmat(3,[16,1]);repmat(4,[16,1]);repmat(5,[16,1])];

figure;
beeswarm(grp2,mat2,'sort_style','nosort','colormap',[PP.T2],'dot_size',2,'overlay_style','ci')
xticks([1,2,3,4,5])
ylim([0 0.105])

mat3 = [mean_T1'; mat2];% t3 + t4
grp3 = [repmat(1,[16,1]);repmat(2,[16,1]);repmat(3,[16,1]);repmat(4,[16,1]);repmat(5,[16,1]);repmat(6,[16,1])];

figure;
beeswarm(grp3,mat3,'sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci')
xticks([])
ylim([0 0.105])
ylabel({'Awake replay rate';'events/s'})
ax = gca; ax.FontSize = 16;

[p,~,stats] = kruskalwallis(mat3,grp3);
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons

tst= mean_T1;
grops = ones(length(mean_T1),1);
tst = [tst track_mean];
grops = [grops; ones(length(track_mean),1)*4];
tst = [tst mean_T1];
grops = [grops; ones(length(mean_T1),1)*3]; 

figure;
beeswarm(grops,tst','sort_style','nosort','colormap',[PP.T1;[0.3 0.3 0.3];PP.T1;[0.3 0.3 0.3]],'dot_size',2,'overlay_style','ci')
xticks([1,2,3,4])
ylim([0 0.1])


[p,~,stats] = kruskalwallis(tst,grops);
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
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

%%%%%%%% IF RUNNING SPEED DATA  %%%%%%%

% For each protocol, a figure with 4x4 subplots - plotting local and remote
% replay events in each row, while each column is a track
for p = 1 : length(protocols)
    f(p) = figure;
    f(p).Name = ['Local and remote events spped protocol ' num2str(protocol(p).ID) 'per track ' num2str(t)];
    c = 1;
    for t = 1 : num_tracks
        for tt =  1 : num_tracks
            local_remote_events = nan(1,max([protocol(:).ID]));
            local_remote_events(p,1:protocol(p).ID) = protocol(p).(sprintf('%s','T',num2str(t)))(tt).Rat_replay_rate(:,1:protocol(p).ID);
            subplot(num_tracks, num_tracks, c)
            if protocol(p).ID == 16
                col = PP.T1;
            else
                col = PP.P;
            end
            boxplot(local_remote_events,'PlotStyle','traditional','Colors',col,'LabelOrientation','horizontal','Widths',0.5);

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
            for ii = 1 : size(local_remote_events,2)
                h = plot(ii,local_remote_events(:,ii),'o','MarkerEdgeColor',[.6 .6 .6],'MarkerFaceColor',[.6 .6 .6],'MarkerSize',2);
                % set(h,{'Marker'},allmarkers,{'Markersize'},all_marker_sizes,'MarkerFaceColor','w','LineWidth',1.5)
            end
            c = c+1;
        end
    end
end

f2 = figure;
f2.Name = 'Local replay per protocol';
cols_T2 = [8 4 3 2 1; 1 2 3 4 5];
c = 1;
for p = 1 : length(protocol)
    if protocol(p).ID == 16
        col = PP.T1;
    else
        col = PP.T2(cols_T2(2,protocol(p).ID == cols_T2(1,:)),:);
    end
    % Local replay T1 and T2 (each row a protocol)
    subplot(length(protocol),num_tracks/2,c)
    plot(protocol(p).(sprintf('%s','T',num2str(1)))(1).Rat_replay_rate(:,1:protocol(p).ID),'o','MarkerFaceColor',col,'MarkerEdgeColor',col,...
        'MarkerSize',4);
    hold on
    ax1 = plot(protocol(p).(sprintf('%s','T',num2str(1)))(1).Rat_replay_rate(:,1:protocol(p).ID),'Color',col);
    plot(protocol(p).(sprintf('%s','T',num2str(2)))(2).Rat_replay_rate(:,1:protocol(p).ID),'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',col,...
        'MarkerSize',4);
    hold on
    ax2 = plot(protocol(p).(sprintf('%s','T',num2str(2)))(2).Rat_replay_rate(:,1:protocol(p).ID),'Color',col,'LineStyle',':','LineWidth',2);
    legend([ax1 ax2],{'T1','T2'})
    title('Local replay T1 & T2'); xlabel('Laps');ylabel('Local replay rate (events/s)'); box off
    c = c+1;
    if num_tracks > 2
       % Local replay T3 and T4 (each row a protocol)
        subplot(length(protocol),num_tracks/2,c)
        plot(protocol(p).(sprintf('%s','T',num2str(3)))(3).Rat_replay_rate(:,1:16),'o','MarkerFaceColor',[0.3 0.3 0.3],'MarkerEdgeColor',[0.3 0.3 0.3],...
            'MarkerSize',4);
        hold on
        ax3 = plot(protocol(p).(sprintf('%s','T',num2str(3)))(3).Rat_replay_rate(:,1:16),'Color',[0.3 0.3 0.3]);
        plot(protocol(p).(sprintf('%s','T',num2str(4)))(4).Rat_replay_rate(:,1:16),'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',[0.3 0.3 0.3],...
            'MarkerSize',4);
        hold on
        ax4 = plot(protocol(p).(sprintf('%s','T',num2str(4)))(4).Rat_replay_rate(:,1:16),'Color',[0.3 0.3 0.3],'LineStyle',':','LineWidth',2);
        legend([ax3 ax4],{'R-T1','R-T2'})
        title('Local replay R-T1 & R-T2'); xlabel('Laps');ylabel('Local replay rate (events/s)'); box off
        c = c+1;
    end
end

f3 = figure;
f3.Name = 'Local & remote replay per protocol';
c = 1;
for p = 1 : length(protocol)
    if protocol(p).ID == 16
       col = PP.T1;
    else
       col = PP.T2(cols_T2(2,protocol(p).ID == cols_T2(1,:)),:);
    end
    cols = [col; col;[0.3 0.3 0.3]; [0.3 0.3 0.3]];
    mark_col  = [col; [1 1 1];[0.3 0.3 0.3]; [1 1 1]];
    style = {'-',':','-',':'};

    % Local and remote replay event per track
    for t = 1 : num_tracks
        width = [1,2,1,2];
        mark_size  = [4,4,4,4];
        mark_size(t) =5;
        if mod(t,2) == 0
            width(t) = 3;
        else
            width(t) = 2;
        end
        subplot(length(protocol),num_tracks,c)
        for tt = 1 : num_tracks
            if t < 3
                end_lap = protocol(p).ID;
            else
                end_lap = 16;
            end
            plot(protocol(p).(sprintf('%s','T',num2str(t)))(tt).Rat_replay_rate(:,1:end_lap),'o','MarkerFaceColor',mark_col(tt,:),'MarkerEdgeColor',cols(tt,:),...
                'MarkerSize',4);
            hold on
            ax(tt) = plot(protocol(p).(sprintf('%s','T',num2str(t)))(tt).Rat_replay_rate(:,1:end_lap),'Color',cols(tt,:),'LineStyle',style{tt},'LineWidth',width(tt));        
        end
        legend([ax(1) ax(2) ax(3) ax(4)],{'T1','T2','R-T1','R-T2'})
        title(['Local & Remote replay Track ' num2str(t)]); xlabel('Laps');ylabel('Replay rate (events/s)'); box off
        c = c+1;
    end
end

 %%%%% RATE MAP

for t = 1 : num_tracks
    if t == 1 || t == 3
        figure
        c=1;
        ax(c) = subplot(6,1,c);
        all_prots = [];
        for p = 1 : length(protocols)
            all_prots = [all_prots; protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:16)];
        end
        mean_T1 = mean(all_prots,1);
        imagesc(mean_T1)
        [grad,im] = colorGradient([1 1 1],[PP.T1],16);
        colormap(ax(c),grad(2:end,:))
        hold on
        colorbar(ax(c))
        caxis(ax(c),[0 0.1])
        box off
        c=2;

    else
        for p = 1 : length(protocols)
            ax(c) = subplot(6,1,c);
            if t == 2
                lap_end = protocol(p).ID;
            else
                lap_end = 16;
            end
            track_mean = mean(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:lap_end),1);
            track_std = std(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(:,1:lap_end),[],1);
            imagesc(track_mean)
            [grad,im] = colorGradient([1 1 1],[PP.T2(p,:)],16);
            colormap(ax(c),grad(2:end,:))
            hold on
            ax(c).XLim = [min(xlim(ax(c))) 16.5];
            colorbar(ax(c))
            caxis(ax(c),[0 0.1])
            box off
            c=c+1;
            
        end
    end
    
    box off
    %xlabel('Lap number')
    ylabel({'Replay rate';'(event/sec)'})
    %title(['Track ' num2str(t)])
    %ax(t).XLim = [1 max(xlim)];
    %ax(t).FontSize = 16;
end

% save
save_path = path;
save_all_figures(pwd,[])
end