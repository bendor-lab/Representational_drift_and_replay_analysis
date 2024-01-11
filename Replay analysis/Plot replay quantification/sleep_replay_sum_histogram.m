function sleep_replay_sum_histogram(epoch)
% Plots distribution of replay events over post sleep 2 & 3 for each track and protocol. 
% Histogram is calculated as the sum of replay events for each track & for each experiment (always within a protcol), 
% and averaged (divided) by number of active sessions at each time bin.
% INPUT: 
    %epoch: 'sleep' for only sleep replay,'awake' for only awake replay, or 'ALL' for plotting both together. 
          % 'sleep' assumes that rats are always awake during track periods, and therefore excludes those periods when plotting 


% Parameters
load('extracted_replay_plotting_info.mat')
load('extracted_time_periods_replay.mat')

PP =  plotting_parameters;
bin_width = 60; %1 min
periods = [{'INTER_post'},{'FINAL_post'}];

% Find indices for each type of protocol
t2 = [];
for s = 1 : length(track_replay_events)
    name = cell2mat(track_replay_events(s).session(1));
    t2 = [t2 str2num(name(end))];
end
protocols = unique(t2,'stable');

for track = 1 : 4
    
    % For each protocol (8,4,3,2 or 1)
    for i = 1 : length(protocols)
        
        this_protocol_idx = find(t2 == protocols(i)); %find indices of sessions from the current protocol
        
        for p = 1 : length(periods) %for each time period (sleep or run) within the protocol
            N = [];
            % find the longest period between these protocol sessions
            mt = [];
            for ii = 1 : length (this_protocol_idx)
                mt = [mt; period_time(this_protocol_idx(ii)).(strcat(periods{p})).length];
                longest_period_time = max(mt);
            end
            bin_edges = 0:bin_width:longest_period_time; %bin the time based on the longest period
            
            % For these protocol sessions, find number of events for each time bin (for this period)
            for ii = 1 : length (this_protocol_idx)
             [N(ii,:),~] = histcounts([track_replay_events(this_protocol_idx(ii)).(sprintf('%s','T',num2str(track),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges); %events track 1
            end 
            N = sum(N,1);
            
            % Normalize event count based on the length of longest time period,by looking how many sessions contribute to each time bin
            bins_with_active_period = ones(1,length(bin_edges))*length(this_protocol_idx); % Set the count as if all periods had the same length
            for t = 1 : length(this_protocol_idx)
                if period_time(this_protocol_idx(t)).(strcat(periods{p})).length < longest_period_time % if this sessions is shorter than the longest period
                    [~,idx] = min(abs(bin_edges -period_time(this_protocol_idx(t)).(strcat(periods{p})).length)); %find bin indx where session is not active anymore
                    bins_with_active_period(idx+1:end) = bins_with_active_period(idx+1:end) - 1;
                end
            end
            
            % Sum events of all sessions of this protocol & divide events of each bin by number of active periods in that bin
            event_count(i).(strcat(cell2mat(periods(p)))) = N./bins_with_active_period(1:end-1);
            active_bins(i).(strcat(periods{p})) = bins_with_active_period; %number of sessions with info for each time bin
        end
        
        % Save for later plotting
        T(track).event_count{i} = event_count(i);
        T(track).protocol_num{i} = protocols(i);
        T(track).active_bins{i} = active_bins(i);
    end

    % PLOT
    if track == 1 % for plotting purposes
        tname = ' Track 1';
    elseif track == 2
        tname = 'Track 2';
    elseif track == 3
        tname = 'Re-Track 1';
    else
        tname = 'Re-Track 2';
    end
    
    f(track) = figure('units','normalized','outerposition',[0 0 1 1]);        
    f(track).Name = strcat('Cumsum - Normalized replay events across post sleep 2 & 3 - ',tname,'-',epoch);
    subplot(1,2,1)
    for ii = 1 : length(T(track).event_count)
        % Find at which time bin starts being information only for half of the rats
        half_rats_thresh = find(cumsum(abs(diff(T(track).active_bins{1,ii}.INTER_post))) >= floor(max(T(track).active_bins{1,ii}.INTER_post)/2),1);
        cum_times = cumsum(T(track).event_count{1,ii}.INTER_post);
        plot(1:half_rats_thresh,cum_times(1:half_rats_thresh),'Color',PP.T2(ii,:),'LineWidth',2)
        hold on
        plot(half_rats_thresh:length(cum_times),cum_times(half_rats_thresh:end),'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
    end
    box off
    xlabel('Binned time (min)'); ylabel('# replay events')
    title('Post first exposure sleep','FontSize',15)
    
    subplot(1,2,2)
    for ii = 1 : length(T(track).event_count)
        % Find at which time bin starts being information only for half of the rats
        half_rats_thresh = find(cumsum(abs(diff(T(track).active_bins{1,ii}.FINAL_post))) >= floor(max(T(track).active_bins{1,ii}.FINAL_post)/2),1);
        cum_times = cumsum(T(track).event_count{1,ii}.FINAL_post);
        pl(ii) = plot(1:half_rats_thresh,cum_times(1:half_rats_thresh),'Color',PP.T2(ii,:),'LineWidth',2);
        hold on
        plot(half_rats_thresh:length(cum_times),cum_times(half_rats_thresh:end),'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
    end
    box off
    xlabel('Binned time (min)'); ylabel( '# replay events')
    title('Post second exposure sleep','FontSize',15)

    legend([pl(1) pl(2) pl(3) pl(4) pl(5)],{'8 Laps', '4 Laps', '3 Laps', '2 Laps', '1 Lap'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
    annotation('textbox',[0.5,0.9,0.05,0.1],'String',tname,'FitBoxToText','on','EdgeColor','none','FontSize',20);

end

end