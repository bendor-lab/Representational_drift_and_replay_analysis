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

function rate_replay = plot_replay_rate(data_type,epoch,bayesian_control)


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
bin_width = 1; % 60 = 1 min
time_chunk_size = 1800; % 1800 = 30min

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

%% PLOT evolution over time bins for visualisation purposes - line plot

f01 = figure('units','normalized','Color','w','Name',['Rate replay per SEC evolution over time -' num2str(time_chunk_size/60) 'bins - ' epoch]);
tiledlayout('flow')

for per = 1 : length(periods) %for each time period (pre, post1, post2)    
    for p = 1 : length(protocols) %for each protocol
        nexttile
        cols = [PP.T1; PP.T2(p,:)];
        for t = 1 : num_tracks %for each track
            % Calculate mean based on number of observtions (i.e. rats with replay events) per time bin
            rate_matrix = reshape([T(t).P(p).(sprintf('%s',periods{per},'_',epoch)).Rat_replay_rate{:}],...
                [size(T(t).P(p).(sprintf('%s',periods{per},'_',epoch)).Rat_replay_rate,1),size(T(t).P(p).(sprintf('%s',periods{per},'_',epoch)).Rat_replay_rate,2)]); % changed from cell format
            rats_active_per_bin = sum(1-cellfun(@isempty,T(t).P(p).(sprintf('%s',periods{per},'_',epoch)).Rat_chunk_duration)); % # rats (observations) that have replay in each bin (column)
            rate_matrix(isinf(rate_matrix)) = NaN;
            rate_sum= sum(rate_matrix,1,'omitnan'); %sum all values within column
            normalised_mean_rate = rate_sum./rats_active_per_bin; %normalise the rate of replay by the number of rats contributing in each bin
            % Calculate STD based on number of observations
            std_rate = sqrt(((sum(((rate_matrix-normalised_mean_rate).^2),1,'omitnan'))./(rats_active_per_bin-1)));
            std_rate(isnan(std_rate) | isinf(std_rate)) = 0; % replace NaNs from STDs coming from one only value, for zero
            hold on
            %plot(normalised_mean_rate,'o-','Color',cols(t,:),'LineWidth',3,'MarkerEdgeColor',cols(t,:),'MarkerFaceColor',cols(t,:))
            plot(normalised_mean_rate,'-','Color',cols(t,:),'LineWidth',3)
            % add STD in shading
            x = 1 : length(normalised_mean_rate); 
            shade1 = normalised_mean_rate + std_rate;
            shade2 = normalised_mean_rate - std_rate;
            x2 = [x,fliplr(x)];
            inBetween = [shade1,fliplr(shade2)];
            h=fill(x2,inBetween,cols(t,:));
            set(h,'facealpha',0.2,'LineStyle','none')
        end
        box off
        set(gca,'ylim',[-0.01 .05],'ytick',[0 .05],'TickDir','out','TickLength',[0.03 0.05],'FontSize',12) %rate per sec
%        set(gca,'ylim',[-0.5 4],'ytick',[0:4],'TickDir','out','TickLength',[0.03 0.05],'FontSize',12)  % rate per min
        %set(gca,'xlim',[0.5 length(normalised_mean_rate)],'xtick',[1:length(normalised_mean_rate)],'xticklabels',[1:length(normalised_mean_rate)]*(time_chunk_size/60))
        % FOR 10min: 
        % set(gca,'ylim',[-0.5 5],'ytick',[0:5],'TickDir','out','TickLength',[0.03 0.05],'FontSize',12)%rate per min
        set(gca,'ylim',[-0.015 .1],'ytick',[0 .05 .1],'TickDir','out','TickLength',[0.03 0.05],'FontSize',12) %rate per sec
         set(gca,'xlim',[0 length(normalised_mean_rate)],'xtick',[0:2:length(normalised_mean_rate)],'xticklabels',[0:2:length(normalised_mean_rate)]*(time_chunk_size/60))
        ylabel('Mean replay rate (event/sec)')
        xlabel({['Time bins (' num2str(time_chunk_size/60) ' min)']}) 
        if per == 1
            title(['Protocol 16x' num2str(protocols(p))])
        end
    end
end

%% PLOT 1. Plot replay rate T1 vs T2 for first 30 min for all experiments
% together (& T3 vs T4 for FINAL sleep)
%         Protocols color coded

f1 = figure('units','normalized','Color','w');
f1.Name = ['Replay - Replay rate during first ' num2str(time_chunk_size/60) 'min on the periods of: ' epoch];

for p = 1 : length(periods) %for each time period (sleep or run) within the protocol
    
    ax(p) = subplot(1,length(periods),p);
    
    if p == 1 || p == 2 | ~isempty(bayesian_control)
        tracks = [1 2];
    elseif p == 3 & isempty(bayesian_control)
        tracks = [3 4];
    end
        
    for i = 1 : length(protocols)
        s = scatter([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}],[T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}],50,PP.T2(i,:),'filled');
        hold on
    end
    xlabel(strcat('T',num2str(tracks(1)),'- Replay Rate (events/min)'))
    ylabel(strcat('T',num2str(tracks(2)),'- Replay Rate (events/min)'))
    title({['Rate replay - First ' num2str(time_chunk_size/60) 'min of :'];[periods{p} '-' epoch]})
       if max(xlim) > max(ylim)
        axis([0 max(xlim) 0 max(xlim)])
    elseif max(ylim) > max(xlim)
        axis([0 max(ylim) 0 max(ylim)])
    end

end
linkaxes([ax(:)],'xy')
for k = 1 : length(ax)
    axes(ax(k));
    line([0 max(ylim)],[0 max(xlim)],'LineStyle','--','Color','k')
end
% run_format_settings(gcf)
        
%% %%%%%%%%%%%%%%%        

f11 = figure('units','normalized','Color','w');
f11.Name = ['Replay - Replay rate during first ' num2str(time_chunk_size/60) 'min on the periods of: ' epoch];
tiledlayout('flow')

for p = 1 : length(periods) %for each time period (sleep or run) within the protocol
        
    if p == 1 || p == 2 | ~isempty(bayesian_control)
        tracks = [1 2];
    elseif p == 3 & isempty(bayesian_control)
        tracks = [3 4];
    end

    col = [PP.T2(1,:);PP.T2(2,:);PP.T2(3,:);PP.T2(4,:);PP.T2(5,:)];
    x_labels = {'16x8','16x4','16x3','16x2','16x1'}; %set labels for X axis
    
    % struct: each column a protocol, each row a rat
    track_rates_t1 = NaN(4,length(protocols));
    track_rates_t2 = NaN(4,length(protocols));
    for i = 1 : length(protocols)
        track_rates_t1(1:length([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]),i) = [T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}];
        track_rates_t2(1:length([T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]),i) = [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}];
    end
    
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
        h= plot(ii,track_rates_t1(:,ii),'o','MarkerEdgeColor',PP.T2(ii,:),'MarkerFaceColor',PP.T2(ii,:));
        set(h,{'Marker'},{'o'},{'Markersize'},{5},'MarkerFaceColor','w','LineWidth',1.5); %,{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6}
    end
    xlabel('Protocols')
    ylabel(strcat(periods{p},'Replay Rate (events/sec)'))
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
        h= plot(ii,track_rates_t2(:,ii),'o','MarkerEdgeColor',PP.T2(ii,:),'MarkerFaceColor',PP.T2(ii,:));
        set(h,{'Marker'},{'o'},{'Markersize'},{5},'MarkerFaceColor','w','LineWidth',1.5); %,{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6}
    end    
    xlabel('Protocols')
    ylabel(strcat(periods{p},'Replay Rate (events/sec)'))
    title({'T2 Replay';['Rate replay first ' num2str(time_chunk_size/60) 'min of : '];[periods{p} '-' epoch]})

end
% run_format_settings(f11,'match_ax')
allax = findobj(gcf,'Type','axes');
ytickformat(allax,'%.3f')      
%set(ax,'ylim',[0 2.5])
%set(ax,'ytick',[0:1:2])
set(allax,'ylim',[0 .05],'ytick',[0 .025 .05])
       
%% PLOT 2. Plot difference in replay rate T1 vs T2 for first 30 min for all
% experiments together (& T3 vs T4 for FINAL sleep)
%         Protocols color coded and rats shaped coded
%         Positive value will be bias towards T1, negative values will be bias towards T2

f2 = figure('units','normalized','Color','w');
f2.Name = ['Replay - Difference in replay rate during first ' num2str(time_chunk_size/60) 'min on periods of : ' epoch];
tiledlayout('flow')

for p = 1 : length(periods) %for each time period (sleep or run) within the protocol
    
    if p == 1 || p == 2 | ~isempty(bayesian_control)
        tracks = [1 2];
    elseif p == 3 & isempty(bayesian_control)
        tracks = [3 4];
    end
    
    nexttile
    
    col = [PP.T2(1,:);PP.T2(2,:);PP.T2(3,:);PP.T2(4,:);PP.T2(5,:)];
    x_labels = {'16x8','16x4','16x3','16x2','16x1'}; %set labels for X axis
    track_rates_diff = NaN(4,length(protocols));
    for i = 1 : length(protocols)
        track_rates_diff(1:length([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]),i) = [T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}] - [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}];
    end
    hold on
    boxplot(track_rates_diff,'PlotStyle','traditional','Colors',col,'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([1,2,3,4,5]));  % Get the children you need (boxes for first exposure)
    set(boxes,'LineWidth',2); % Set width
    box off
    
    hold on
    for ii = 1 : length(protocols)
        h= plot(ii,track_rates_diff(:,ii),'o','MarkerEdgeColor',PP.T2(ii,:),'MarkerFaceColor',PP.T2(ii,:));
        set(h,{'Marker'},{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6},'MarkerFaceColor','w','LineWidth',1.5);
    end
    
    xlabel('Protocols')
    ylabel(strcat('Difference in T',num2str(tracks(1)),'- T',num2str(tracks(2)),'Replay Rate (events/sec)'))
    title({['Replay - Difference rate replay first ' num2str(time_chunk_size/60) 'min of:'];[periods{p} '-' epoch]})
    line([0 max(xlim)],[0 0],'LineStyle','--','Color','k')
    
end
% run_format_settings(gcf)
allax = findobj(gcf,'Type','axes');
linkaxes(allax,'y')
ytickformat(allax,'%.2f')      
set(allax,'ylim',[-.04 .04],'ytick',[-.04 .04])


%% PLOT 3. Plot normalized replay rate T1 vs T2 for first 30 min for all
% experiments together (& T3 vs T4 for FINAL sleep)
%         Protocols color coded and rats shaped coded
%         It's T1-T2/T1+T2 - so how many more times there's more replay for one track than the other

f3 = figure('units','normalized','outerposition',[0 0 1 1],'Color','w');
f3.Name = ['Replay - Normalized replay rate during first' num2str(time_chunk_size/60) 'min on periods of : ' epoch];

for p = 1 : length(periods) %for each time period (sleep or run) within the protocol
    
    if p == 1 || p == 2 | ~isempty(bayesian_control)
        tracks = [1 2];
    elseif p == 3 & isempty(bayesian_control)
        tracks = [3 4];
    end
    
    ax(p) = subplot(1,length(periods),p);
    
    col = [PP.T2(1,:);PP.T2(2,:);PP.T2(3,:);PP.T2(4,:);PP.T2(5,:)];
    x_labels = {'16x8','16x4','16x3','16x2','16x1'}; %set labels for X axis
    track_rates_ratio = NaN(4,length(protocols));
    for i = 1 : length(protocols)
        track_rates_ratio(1:length([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]),i) = ([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}] - [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}])./...
            ([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}] + [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]);
    end
    hold on
    boxplot(track_rates_ratio,'PlotStyle','traditional','Colors',col,'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([1,2,3,4,5]));  % Get the children you need (boxes for first exposure)
    set(boxes,'LineWidth',2); % Set width
    box off
    
    hold on
    for ii = 1 : length(protocols)
        h = plot(ii,track_rates_ratio(:,ii),'o','MarkerEdgeColor',PP.T2(ii,:),'MarkerFaceColor',PP.T2(ii,:),'MarkerSize',5);
        set(h,{'Marker'},{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6},'MarkerFaceColor','w','LineWidth',1.5)

    end
    
    xlabel('Protocols')
    ylabel(strcat('Normalized T',num2str(tracks(1)),'- T',num2str(tracks(2)),'Replay Rate (events/min)'))
    title({['Normalised rate replay first ' num2str(time_chunk_size/60) 'min of : '];[periods{p} '-' epoch]})
    line([0 max(xlim)],[0 0],'LineStyle','--','Color','k')

end
linkaxes([ax(:)],'y')
ylim([-1 max(ylim)])




%% PLOT 4. Plot difference between first and second 30min of sleep for T1 and T2 independently, experiments together
% WITHIN TRACK COMPARISON: Tells how the rate of replay changes between the first and second half hour for each track.
%         Protocols color coded 
%         Quadrant X+ Y+: Rate is higher first half an hour for both tracks
%         Quadrant X+ Y-: Rate is higher first half an hour for T1, but the second for T2
%         Quadrant X- Y+: Rate is higher first half an hour for T2, but the second for T1
%         Quadrant X- Y-: Rate is higher second half an hour for both tracks

f4 = figure('units','normalized','outerposition',[0 0 1 1],'Color','w');
f4.Name = ['Replay - Difference in rate replay within between sleep chunks in INTER : ' epoch];
for p = 2 : length(periods) %for INTER sleep
    
    if p == 1 || p == 2 | ~isempty(bayesian_control)
        tracks = [1 2];
    elseif p == 3 & isempty(bayesian_control)
        tracks = [3 4];
    end
    
    track_rates_diff_1 = NaN(4,length(protocols));
    track_rates_diff_2 = NaN(4,length(protocols));
    
    % Substract rate replay between first and second half an hour for each track
    % Update: normalize to control for decrease in amount of replay - - e.g. (T1.1-T1.2/T1.1+T1.2) 
    for i = 1 : length(protocols)
        track_rates_diff_1(1:length([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]),i) = ...
            ([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}] - [T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,2}])./...
            ([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}] + [T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,2}]);
        track_rates_diff_2(1:length([T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]),i) = ...
            ([T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}] - [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,2}])./...
            ([T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}] + [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,2}]);
        hold on
        s = scatter([track_rates_diff_1(:,i)],[track_rates_diff_2(:,i)],50,PP.T2(i,:),'filled');
        clear normalized_T1 normalized_T2
    end
    
    line([min(xlim) max(xlim)],[0 0],'LineStyle','--','Color',[0.8 0.8 0.8],'LineWidth',1)
    line([0 0],[min(ylim) max(ylim)],'LineStyle','--','Color',[0.8 0.8 0.8],'LineWidth',1)
    
    xlabel(['T' num2str(tracks(1)) '- normalized rate replay change between ' num2str(time_chunk_size/60) 'min chunks'])
    ylabel(['T' num2str(tracks(2)) '- normalized rate replay change between ' num2str(time_chunk_size/60) 'min chunks'])
    title({'Replay -  Difference in rate replay within track between sleep chunks : ';[periods{p} '-' epoch]})
    
end



%% PLOT 5. Plot difference between first and second 30min of sleep for T1 and T2 independently, all experiments together (& T3 vs T4 for FINAL sleep)
% BETWEEN TRACK COMPARISON: Tells if replay rate is higher for T1 or for T2 in each half an hour
%         Protocols color coded 
%         Quadrant X+ Y+: Rate is higher for T1 during first and second half an hour
%         Quadrant X+ Y-: Rate is higher for T1 in 30min, but higher for T2 in second 30min
%         Quadrant X- Y+: Rate is higher for T2 in 30min, but higher for T1 in second 30min
%         Quadrant X- Y-: Rate is higher for T2 during first and second half an hour

f5 = figure('units','normalized','outerposition',[0 0 1 1],'Color','w');
f5.Name = ['Replay -  Difference in T1-T2 bias between sleep chunks during INTER : ' epoch];
for p = 2 : length(periods) %for INTER sleep
    
    if p == 1 || p == 2 | ~isempty(bayesian_control)
        tracks = [1 2];
    elseif p == 3 & isempty(bayesian_control)
        tracks = [3 4];
    end
    
    track_rates_diff_1 = NaN(4,length(protocols));
    track_rates_diff_2 = NaN(4,length(protocols));
    
    % Substract rate replay between both tracks for the first 30min and second 30 min
    % Update: normalize to control for decrease in amount of replay - (T1-T2/T1+T2) 
    for i = 1 : length(protocols)
        % T1 - T2 in first 30 min
        track_rates_diff_1(1:length([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]),i) = ([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}] - [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}])./...
           ([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}] + [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]);
        % T1 - T2 in second 30min
        track_rates_diff_2(1:length([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,2}]),i) = ([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,2}] - [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,2}])./...
            ([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,2}] + [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,2}]);
        hold on
        s = scatter([track_rates_diff_1(:,i)],[track_rates_diff_2(:,i)],50,PP.T2(i,:),'filled');
    end
    

    line([min(ylim) max(xlim)],[min(ylim) max(xlim)],'Color',[0.6 0.6 0.6])
    line([min(xlim) max(xlim)],[0 0],'LineStyle','--','Color',[0.8 0.8 0.8],'LineWidth',1)
    line([0 0],[min(ylim) max(ylim)],'LineStyle','--','Color',[0.8 0.8 0.8],'LineWidth',1)
    

    xlabel(['T' num2str(tracks(1)) '- T' num2str(tracks(2)) 'normalized bias during first ' num2str(time_chunk_size/60) 'min'])
    ylabel(['T' num2str(tracks(2)) '- T' num2str(tracks(2)) 'normalized bias during first ' num2str(time_chunk_size/60) 'min'])
    title({'Replay -  Difference in T1-T2 bias between sleep chunks : ';[periods{p} '-' epoch]})
    
end

        
%% PLOT 6. Plot difference in replay rate T1 vs T2 for first 30 min for all experiments together VS replay T3 vs T4 for FINAL sleep 
% Tells if the bias remains the same between INTER and FINAL sleep, or if a bias for one track in INTER means that there will be a bias for the other
% track in FINAL
%         Protocols color coded
%         Positive value will be bias towards T1, negative values will be bias towards T2, same for T3 and T4

f6 = figure('units','normalized','outerposition',[0 0 1 1],'Color','w');
f6.Name = ['Replay - Difference in replay rate during first ' num2str(time_chunk_size/60) 'min between INTER and FINAL on periods of : ' epoch];

track_rates_diff_1 = NaN(4,length(protocols));
for i = 1 : length(protocols)
    track_rates_diff_1(1:length([T(1).P(i).(strcat('INTER_post_',epoch)).Rat_replay_rate{:,1}]),i) = [T(1).P(i).(strcat('INTER_post_',epoch)).Rat_replay_rate{:,1}] - [T(2).P(i).(strcat('INTER_post_',epoch)).Rat_replay_rate{:,1}];
end

if num_tracks > 2
    track_rates_diff_2 = NaN(4,length(protocols));
    for i = 1 : length(protocols)
        track_rates_diff_2(1:length([T(3).P(i).(strcat('FINAL_post_',epoch)).Rat_replay_rate{:,1}]),i) = [T(3).P(i).(strcat('FINAL_post_',epoch)).Rat_replay_rate{:,1}] - [T(4).P(i).(strcat('FINAL_post_',epoch)).Rat_replay_rate{:,1}];
    end
end

for ii = 1 : length(protocols)
    s = scatter([track_rates_diff_1(:,ii)],[track_rates_diff_2(:,ii)],50,PP.T2(ii,:),'filled');
    hold on
end

% Fit line
a = reshape(track_rates_diff_1,size(track_rates_diff_1,1)*size(track_rates_diff_1,2),1);
b = reshape(track_rates_diff_2,size(track_rates_diff_2,1)*size(track_rates_diff_2,2),1);
lm = fitlm(a,b,'linear');
[pp,~,~] = coefTest(lm);
annotation('textbox',[0.2,0.8,0.05,0.1],'String',strcat('p-val : ',num2str(pp)),'FitBoxToText','on','EdgeColor','none','FontSize',10);
x = [min(a) max(a)];
b = lm.Coefficients.Estimate';
hold on;
plot(x,polyval(fliplr(b),x),'LineStyle','-','LineWidth',2,'Color',[0.6 0.6 0.6])

line([min(xlim) max(xlim)],[0 0],'LineStyle','--','Color',[0.8 0.8 0.8],'LineWidth',1)
line([0 0],[min(ylim) max(ylim)],'LineStyle','--','Color',[0.8 0.8 0.8],'LineWidth',1)
    
xlabel('Difference between T1 & T2 rate replay (events/min)')
ylabel('Difference between R-T1 & R-T2 rate replay (events/min)')
title([epoch ' Replay - Difference rate replay first ' num2str(time_chunk_size/60) 'min INTER vs FINAL sleep'])


%% PLOT 7. Plot difference in replay rate T1+T3 vs T2+T4 for first 30 min for all
% experiments together in PRE and INTER sleep
%         Protocols color coded and rats shaped coded
%         Positive value will be bias towards T1, negative values will be bias towards T2

if isfield(track_replay_events,'T4')% If four tracks (normalised acorss four tracks)
    f7 = figure('units','normalized','outerposition',[0 0 1 1],'Color','w');
    f7.Name = ['Replay - Difference in T1+T3 vs T2+T4 replay rate during first' num2str(time_chunk_size/60) 'min between PRE and INTER on periods of : ' epoch];
    
    for p = 1 : 2 %for onlyPRE and INTER within the protocol
        
        ax(p) = subplot(2,2,p);
        
        col = [PP.T2(1,:);PP.T2(2,:);PP.T2(3,:);PP.T2(4,:);PP.T2(5,:)];
        x_labels = {'16x8','16x4','16x3','16x2','16x1'}; %set labels for X axis
        
        track_rates_diff = NaN(4,length(protocols));
        for i = 1 : length(protocols)
            track_rates_diff(1:length([T(1).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]),i) = ([T(1).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]+[T(3).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}])...
                - ([T(2).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]+[T(4).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]);
        end
        
        hold on
        
        boxplot(track_rates_diff,'PlotStyle','traditional','Colors',col,'labels',x_labels,...
            'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        tt = get(a,'tag');   % List the names of all the objects
        idx = find(strcmpi(tt,'box')==1);  % Find Box objects
        boxes = a(idx([1,2,3,4,5]));  % Get the children you need (boxes for first exposure)
        set(boxes,'LineWidth',2); % Set width
        box off
        
        hold on
        for ii = 1 : length(protocols)
            h= plot(ii,track_rates_diff(:,ii),'o','MarkerEdgeColor',PP.T2(ii,:),'MarkerFaceColor',PP.T2(ii,:));
            set(h,{'Marker'},{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6},'MarkerFaceColor','w','LineWidth',1.5);
        end
        
        xlabel('Protocols')
        ylabel(strcat('Difference in T1+T3 vs T2+T4 Replay Rate (events/min)'))
        title({['Replay - Difference rate replay first ' num2str(time_chunk_size/60) 'min of:'];[periods{p} '-' epoch]})
        line([0 max(xlim)],[0 0],'LineStyle','--','Color','k')
        
        
        ax(p) = subplot(2,2,p+2); % plot normalized version ((T1+T3)-(T2+T4))/(T1+T2+T3+T4)
        
        track_rates_ratio = NaN(4,length(protocols));
        for i = 1 : length(protocols)
            track_rates_diff(1:length([T(1).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]),i) = (([T(1).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]+[T(3).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}])...
                - ([T(2).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]+[T(4).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}])) ./ ([T(1).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]+[T(3).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]...
                +[T(2).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]+[T(4).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]) ;
            
        end
        hold on
        boxplot(track_rates_diff,'PlotStyle','traditional','Colors',col,'labels',x_labels,...
            'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        tt = get(a,'tag');   % List the names of all the objects
        idx = find(strcmpi(tt,'box')==1);  % Find Box objects
        boxes = a(idx([1,2,3,4,5]));  % Get the children you need (boxes for first exposure)
        set(boxes,'LineWidth',2); % Set width
        box off
        
        hold on
        for ii = 1 : length(protocols)
            h = plot(ii,track_rates_diff(:,ii),'o','MarkerEdgeColor',PP.T2(ii,:),'MarkerFaceColor',PP.T2(ii,:),'MarkerSize',5);
            set(h,{'Marker'},{'h';'diamond';'o';'square'},{'Markersize'},{6;5;5;6},'MarkerFaceColor','w','LineWidth',1.5)
            
        end
        
        xlabel('Protocols')
        ylabel(strcat('Difference in T1+T3 vs T2+T4 Normalized Replay Rate (events/min)'))
        title({['Replay - Difference normalized rate replay first ' num2str(time_chunk_size/60) 'min of:'];[periods{p} '-' epoch]})
        line([0 max(xlim)],[0 0],'LineStyle','--','Color','k')
        
    end
    linkaxes([ax(:)],'y')
end
%%
%%%%% FINALL, ALLOCATE VARIABLE

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