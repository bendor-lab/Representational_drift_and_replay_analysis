% Calculates rate of replay (events/min) for each track during sleep periods. To do so divides periods in 30min chunks. Plots rates for each
% 30min chunk and compares it between tracks.
% INPUT:
    % data_type: 'main' for using data from main HIPP replay project; 'speed' for using speed protocol data; and 'ctrl' for control data
    % epoch: 'sleep' or 'awake', for sleep or awake/rest replay, or 'merged' for both
    % bayesian_control: 'Only first exposure' or 'Only re-exposure'
% OUTPUT: T 'struct', where each row is a track (T(track)). Inside, each column is a time_period (e.g. PRE sleep), and each row a Protocol (e.g.
% 16x8). Within each Period x Protocol cell there is information for each session (i.e. rat) about num of replay events, rate replay, and information about time bins used to
% calculate it. Inside of each of these cells there are as many columns as time chunks are being analysed (e.g. first column is events during first
% 30 min, 2nd column events during next 30 min)
% E.g. T(1).P(1).PRE_merged.Rat_num_events = [26,27,11,8; [],23,5,0] --> Track 1, Protocol 16x8, during PRE sleep period analysing together (merged) awake
% and sleep events, how many detected events (num) per each of the 4 rats at each time bin.

% Marta Huelin, 2020

function rate_replay = plot_replay_rate_simple(data_type,epoch,bayesian_control,time_chunk_size,save_option)

% Parameters
% Load extracted time periods
if strcmp(data_type,'main') & ~isempty(bayesian_control)
    if strcmp(bayesian_control,'all') % take both bayesian at the same time
        path = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only first exposure'];
        path2 = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only re-exposure'];
        track_replay_events_F = load([path '\extracted_replay_plotting_info_excl.mat']);
        track_replay_events = track_replay_events_F.track_replay_events;   
        track_replay_events_R = load([path2 '\extracted_replay_plotting_info_excl.mat']);
    else
        path = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\' bayesian_control];
        load([path '\extracted_replay_plotting_info_excl.mat'])
    end
    load([path '\extracted_time_periods_replay_excl.mat'])
elseif strcmp(data_type,'main')
    cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis')
    load('extracted_time_periods_replay.mat')
    load('extracted_replay_plotting_info.mat')
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
PP1.T1 = PP.T1;
PP1.T2 = PP.T2;

for n = 1:size(PP.T2,1)
    PP1.T2(6-n,:) = PP.T2(n,:);
end


bin_width = 1; % 60 = 1 min
% time_chunk_size = 1800; % 1800 = 30min

% Set periods to be analysed
if isfield(track_replay_events,'T3') | ~isempty(bayesian_control)
    periods = [{'PRE'},{'INTER_post'},{'FINAL_post'}];
else  % 2 tracks only
    periods = [{'PRE'},{'FINAL_post'}];
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

% For each protocol (8,4,3,2 or 1)
for i = 1 : length(protocols)
    
    this_protocol_idxs = find(t2 == protocols(i)); %find indices of sessions from the current protocol
    
    for p = 1 : length(periods) %for each time period (sleep or run) within the protocol

        if strcmp(bayesian_control,'all') % take both bayesian at the same time
            if p < 3 % for PRE and INTER
                track_replay_events = track_replay_events_F.track_replay_events;
            else % for FINAL
                track_replay_events = track_replay_events_R.track_replay_events;
            end
        end

        for s = 1 : length(this_protocol_idxs) %for each session/rat in this protocol
            curr_folder = strsplit(track_replay_events(this_protocol_idxs(s)).session{1},'_');

            % Divide current period in 30min chunks
            if ~isempty(bayesian_control)
                if strcmp(epoch,'merged')
                    if isempty(period_time(this_protocol_idxs(s)).(strcat(periods{p})).length) %if this period exists
                        continue
                    else
                        curr_time = [0, period_time(this_protocol_idxs(s)).(strcat(periods{p})).length];
                    end
                else
                    if isempty(period_time(this_protocol_idxs(s)).(strcat(periods{p})).(strcat(epoch,'_cumulative_time'))) %if this period exists
                        continue
                    else
                        curr_time = period_time(this_protocol_idxs(s)).(strcat(periods{p})).(strcat(epoch,'_cumulative_time'));
                    end
                end
            else
                curr_time = period_time(this_protocol_idxs(s)).(strcat(periods{p})).time_limits  - period_time(this_protocol_idxs(s)).(strcat(periods{p})).time_limits(1);
            end
            time_chunks = curr_time(1,1) : time_chunk_size : curr_time(end,2);
            chunks_duration = ones(1,length(time_chunks)-1)*time_chunk_size;
            if time_chunks(end) ~= curr_time(end,2) %if the duration of last chunk was < or > 30min
                time_chunks = [time_chunks, curr_time(end,2)];
                chunks_duration = [chunks_duration, abs(curr_time(end,2) - time_chunks(end-1))]; %save the actual duration of the last chunk
            end

            for tc = 2: length(time_chunks) % for each time chunk within this period, find replay events per minute (replay rate)

                this_chunk_bin_edges = time_chunks(tc-1) : bin_width : time_chunks(tc);

                for track = 1 : num_tracks % For each track in this time chunk

                    %Find indices of replay within the chunk
                    replay_indcs = find(track_replay_events(this_protocol_idxs(s)).(strcat('T',num2str(track))).(strcat(periods{p},'_',epoch,'_cumulative_times')) > time_chunks(tc-1) & track_replay_events(this_protocol_idxs(s)).(strcat('T',num2str(track))).(strcat(periods{p},'_',epoch,'_cumulative_times')) <= time_chunks(tc)-1);
                    % Save in structure Track.Protocol.Period-epoch.Rat{time_chunk}
                    T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_num_events{s,tc-1} = length(replay_indcs); %number of events per chunk
%                     T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{s,tc-1} = length(replay_indcs)/(length(this_chunk_bin_edges)-1); % replay per minute (rate) in each chunk
                    T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{s,tc-1} = length(replay_indcs)/(length(this_chunk_bin_edges)); % replay per second (rate) in each chunk
                    T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_time_chunks{s,tc-1} = time_chunks(tc-1); % start timestamp for each chunk
                    T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_chunk_duration{s,tc-1} = chunks_duration(tc-1); % duration of each chunk (should be 30min, except if the last one is shorter)
                end
            end
        end
        % Check if there are empty cells on chunk periods (due to shorter time chunks), and zero them
        for track = 1 : num_tracks % For each track
            if length(find(cellfun(@isempty,T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_num_events))) > 0
                T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_num_events(cellfun(@isempty,T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_num_events)) = {0};
                T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate(cellfun(@isempty,T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate)) = {0};
            end
        end
    end
end

        
%% %%%%%%%%%%%%%%%        

f11 = figure('units','normalized','Color','w');
f11.Name = ['Replay - Replay rate during first ' num2str(time_chunk_size/60) 'min on the periods of: ' epoch];
f11.Position = [0.4 0.2 0.2 0.7]
tiledlayout('flow')

for p = 1 : length(periods) %for each time period (sleep or run) within the protocol
        
    if p == 1 || p == 2 | ~isempty(bayesian_control)
        tracks = [1 2];
    elseif p == 3 & isempty(bayesian_control)
        tracks = [3 4];
    end

    % struct: each column a protocol, each row a rat
    track_rates_t1 = NaN(4,length(protocols));
    track_rates_t2 = NaN(4,length(protocols));
    for i = 1 : length(protocols)
        track_rates_t1(1:length([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]),i) = [T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}];
        track_rates_t2(1:length([T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]),i) = [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}];
    end
    
    track_rates_t1 = flip(track_rates_t1,2);
    track_rates_t2 = flip(track_rates_t2,2);
    
%     [p1,~,stats1]=kruskalwallis(track_rates_t1,[],'off');
%     [p2,~,stats2]=kruskalwallis(track_rates_t2,[],'off');
%     if p1 < .05
%         disp(p) 
%         disp(1)
%         c1 = multcompare(stats1,'dunn-sidak','off');
%     end
%     if p2 < .05
%         disp(2) 
%         disp(1)
%         c2 = multcompare(stats2,'dunn-sidak','off');
%     end
%         
%     
    col = PP1.T2;
    x_labels = flip({'16x8','16x4','16x3','16x2','16x1'}); %set labels for X axis
    
    nexttile
    hold on
    boxplot(track_rates_t1,'PlotStyle','traditional','Colors',col,'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([1,2,3,4,5]));  % Get the children you need (boxes for first exposure)
    set(boxes,'LineWidth',2); % Set width
    whisk = a([find(strcmpi(tt,'Lower Whisker')==1) find(strcmpi(tt,'Upper Whisker')==1)...
        find(strcmpi(tt,'Upper Adjacent Value')==1)  find(strcmpi(tt,'Lower Adjacent Value')==1) ]);  % Find whiskers objects
    set(whisk,'LineWidth',1.5,'LineStyle','-')
    med = a(find(strcmpi(tt,'Median')==1));  % Find median objects
    set(med,'LineWidth',1.5)

    box off    
    hold on
    for ii = 1 : length(protocols)
        h= plot(ii,track_rates_t1(:,ii),'o','MarkerEdgeColor',col(ii,:),'MarkerFaceColor',col(ii,:));
        set(h,{'Marker'},{'o'},{'Markersize'},{5},'MarkerFaceColor','w','LineWidth',1.5); %,{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6}
    end
    xlabel('Protocols')
    ylabel('Replay Rate (events/sec)')
    title({'T1 Replay';['Rate replay first ' num2str(time_chunk_size/60) 'min of : '];[periods{p} '-' epoch]})
    
    nexttile
    hold on
    boxplot(track_rates_t2,'PlotStyle','traditional','Colors',col,'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([1,2,3,4,5]));  % Get the children you need (boxes for first exposure)
    set(boxes,'LineWidth',2); % Set width
    whisk = a([find(strcmpi(tt,'Lower Whisker')==1) find(strcmpi(tt,'Upper Whisker')==1)...
        find(strcmpi(tt,'Upper Adjacent Value')==1)  find(strcmpi(tt,'Lower Adjacent Value')==1) ]);  % Find whiskers objects
    set(whisk,'LineWidth',1.5,'LineStyle','-')
    med = a(find(strcmpi(tt,'Median')==1));  % Find median objects
    set(med,'LineWidth',1.5)

    box off
    
    hold on
    for ii = 1 : length(protocols)
        h= plot(ii,track_rates_t2(:,ii),'o','MarkerEdgeColor',col(ii,:),'MarkerFaceColor',col(ii,:));
        set(h,{'Marker'},{'o'},{'Markersize'},{5},'MarkerFaceColor','w','LineWidth',1.5); %,{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6}
    end    
    xlabel('Protocols')
    ylabel('Replay Rate (events/sec)')
    title({'T2 Replay';['Rate replay first ' num2str(time_chunk_size/60) 'min of : '];[periods{p} '-' epoch]})

end
% run_format_settings(f11,'match_ax')
allax = findobj(gcf,'Type','axes');
ytickformat(allax,'%.3f')      
%set(ax,'ylim',[0 2.5])
%set(ax,'ytick',[0:1:2])
set(allax,'ylim',[0 .07],'ytick',[0 .02 0.04 0.06])


%% Save
rate_replay = T;
params.bin_size = bin_width;
params.time_chunk_size = time_chunk_size; % 30min
params.epoch = epoch;

% SAVE
if strcmp(data_type,'main') & ~isempty(bayesian_control)    
    if strcmp(bayesian_control,'all')
        path = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\'];
    else
        path = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\' bayesian_control];
    end
    if bin_width == 1  %add _per_second_ if bin_width is 1 sec
        save([path '\rate_per_second_',epoch,'_replay_' num2str(time_chunk_size/60) 'min_excl.mat'],'rate_replay','params','-v7.3')
    else
        save([path '\rate_',epoch,'_replay_' num2str(time_chunk_size/60) 'min_excl.mat'],'rate_replay','params','-v7.3')
    end
elseif strcmp(data_type,'main')
    cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\')
    save(strcat('rate_',epoch,'_replay'),'rate_replay','params','-v7.3');
elseif strcmp(data_type,'speed')
    cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Speed')
    save(strcat('rate_',epoch,'_replay'),'rate_replay','params','-v7.3');
elseif strcmp(data_type,'ctrl')
    cd(strcat('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Controls\',folder_name{end}))
    save(strcat('rate_',epoch,'_replay'),'rate_replay','params','-v7.3');
end

end