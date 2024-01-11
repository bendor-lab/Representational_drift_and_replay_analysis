function sleep_replay_diff_histogram(epoch)
% Plots the difference of replay events between tracks over post sleep 2 & 3. Tests different types of comparisons, set in the code.
% Histogram is calculated as the difference of replay events between tracks for each experiment (always within a protcol), 
% sum the differences of all experiments and divided by number of active sessions. 
% INPUT: 
    %epoch: 'sleep' for only sleep replay,'awake' for only awake replay, or 'ALL' for plotting both together. 
          % 'sleep' assumes that rats are always awake during track periods, and therefore excludes those periods when plotting 

% Parameters
load('extracted_replay_plotting_info.mat')
load('extracted_time_periods_replay.mat')
PP =  plotting_parameters;
bin_width = 60; %1 min
periods = [{'INTER_post'},{'FINAL_post'}];
comparisons = {[1,2],[3,4],[1,3,2,4],[1,3],[2,4]}; %types of comparisons to analysed (value = track num)

% Find indices for each type of protocol
t2 = [];
for s = 1 : length(track_replay_events)
    name = cell2mat(track_replay_events(s).session(1));
    t2 = [t2 str2num(name(end))];
end
protocols = unique(t2,'stable');

for c = 1 : length(comparisons) % For each type of comparison
    track = [];
    for j = 1 : length(cell2mat(comparisons(c))) %find how many tracks are being compared
        comp = cell2mat(comparisons(c));
        track(j) =comp(j);
    end
    
    % For each protocol (8,4,3,2 or 1)
    for i = 1 : length(protocols)
        
        this_protocol_idx = find(t2 == protocols(i)); %find indices of sessions from the current protocol
        
        for p = 1 : length(periods) %for each time period (sleep or run) within the protocol
            
            % find the longest period between these protocol sessions
            mt = [];
            for ii = 1 : length (this_protocol_idx)
                mt = [mt; period_time(this_protocol_idx(ii)).(strcat(periods{p})).length];
                longest_period_time = max(mt);
            end
            bin_edges = 0:bin_width:longest_period_time; %bin the time based on the longest period
            this_period_events = [];
            
            % For each protocol session, find number of events for each time bin (for this period), and substract from the other track to which is being compared to
            for idx = 1 : length(this_protocol_idx)
                if length(cell2mat(comparisons(c))) == 2
                    [N1,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(1)),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges); %events track 1
                    [N2,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(2)),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges); %events track 2
                    this_period_events = [this_period_events; N1-N2]; % substracts T1 from T2
                else % if comparing 4 tracks
                    [N1,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(1)),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges);
                    [N2,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(2)),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges);
                    [N3,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(3)),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges);
                    [N4,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(4)),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges);
                    this_period_events = [this_period_events; (N1+N2)-(N3+N4)];
                end
            end
            
            % Normalize event count based on the length of longest time period,by looking how many sessions contribute to each time bin
            bins_with_active_period = ones(1,length(bin_edges))*length(this_protocol_idx); % Set the count as if all periods had the same length
            for t = 1 : length(this_protocol_idx)
                if period_time(this_protocol_idx(t)).(strcat(periods{p})).length < longest_period_time % if this sessions is shorter than the longest period
                    [~,idx] = min(abs(bin_edges - period_time(this_protocol_idx(t)).(strcat(periods{p})).length)); %find bin indx where session is not active anymore
                    bins_with_active_period(idx+1:end) = bins_with_active_period(idx+1:end) - 1;
                end
            end
            
            % Sum events of all sessions of this protocol & divide events of each bin by number of active periods in that bin
            N = sum(this_period_events);                
            event_count(i).(strcat(periods{p})) = N./bins_with_active_period(1:end-1);
            active_bins(i).(strcat(periods{p})) = bins_with_active_period; %number of sessions with info for each time bin

        end
        
        % Save for later plotting
        T(c).event_count{i} = event_count(i);
        T(c).protocol_num = protocols(i);
        T(c).active_bins{i} = active_bins(i);
        
    end

    % PLOT
    f(c) = figure('units','normalized','outerposition',[0 0 1 1]);
    f(c).Name = strcat('Cumsum - Replay events difference between tracks - ',num2str(cell2mat(comparisons(c))),' across time - ', epoch);
    subplot(1,2,1)
    for ii = 1 : length(T(c).event_count)
        % Find at which time bin starts being information only for half of the rats
        half_rats_thresh = find(cumsum(abs(diff(T(c).active_bins{1,ii}.INTER_post))) >= floor(max(T(c).active_bins{1,ii}.INTER_post)/2),1);
        cum_times = cumsum(T(c).event_count{1,ii}.INTER_post);
        plot(1:half_rats_thresh,cum_times(1:half_rats_thresh),'Color',PP.T2(ii,:),'LineWidth',2)
        hold on
        plot(half_rats_thresh:length(cum_times),cum_times(half_rats_thresh:end),'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
    end
    line([min(xlim) max(xlim)],[0 0],'Color','k','LineWidth',1,'LineStyle','--')  % to separate between tracks
    box off
    xlabel('Binned time (min)'); ylabel('# Replay events diff')
    title('Post first exposure sleep','FontSize',15)
    
    subplot(1,2,2)
    for ii = 1 : length(T(c).event_count)
        % Find at which time bin starts being information only for half of the rats
        half_rats_thresh = find(cumsum(abs(diff(T(c).active_bins{1,ii}.FINAL_post))) >= floor(max(T(c).active_bins{1,ii}.FINAL_post)/2),1);
        cum_times = cumsum(T(c).event_count{1,ii}.FINAL_post);
        pl(ii) = plot(1:half_rats_thresh,cum_times(1:half_rats_thresh),'Color',PP.T2(ii,:),'LineWidth',2);
        hold on
        plot(half_rats_thresh:length(cum_times),cum_times(half_rats_thresh:end),'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
    end
    line([min(xlim) max(xlim)],[0 0],'Color','k','LineWidth',1,'LineStyle','--')  % to separate between tracks
    box off
    xlabel('Binned time (min)'); ylabel('# Replay events diff')
    title('Post second exposure sleep','FontSize',15)

    legend([pl(1) pl(2) pl(3) pl(4) pl(5)],{'8 Laps', '4 Laps', '3 Laps', '2 Laps', '1 Lap'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
    if length(cell2mat(comparisons(c))) == 2
        annotation('textbox',[0.27 0.82 1 0.1],'String',strcat('Replay T',num2str(track(1))),'EdgeColor', 'none','FontSize',13)
        annotation('textbox',[0.27 0.08 1 0.1],'String',strcat('Replay T',num2str(track(2))),'EdgeColor', 'none','FontSize',13)
        annotation('textbox',[0.71 0.82 1 0.1],'String',strcat('Replay T',num2str(track(1))),'EdgeColor', 'none','FontSize',13)
        annotation('textbox',[0.71 0.08 1 0.1],'String',strcat('Replay T',num2str(track(2))),'EdgeColor', 'none','FontSize',13)
    else
        annotation('textbox',[0.27 0.82 1 0.1],'String',strcat('Replay T',num2str(track(1)),'+ T',num2str(track(2))),'EdgeColor', 'none','FontSize',13)
        annotation('textbox',[0.27 0.08 1 0.1],'String',strcat('Replay T',num2str(track(3)),'+ T',num2str(track(4))),'EdgeColor', 'none','FontSize',13)
        annotation('textbox',[0.71 0.82 1 0.1],'String',strcat('Replay T',num2str(track(1)),'+ T',num2str(track(2))),'EdgeColor', 'none','FontSize',13)
        annotation('textbox',[0.71 0.08 1 0.1],'String',strcat('Replay T',num2str(track(3)),'+ T',num2str(track(4))),'EdgeColor', 'none','FontSize',13)
    end


end

end