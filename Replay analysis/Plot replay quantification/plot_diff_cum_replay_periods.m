function plot_diff_cum_replay_periods(epoch,bayesian_control)
% Plots difference in number of cumulative replay events between trackd over sleep periods for each protocol.
% Histogram is calculated as the sum of cumulative replay event times across tracks & each experiment (always within a protcol),
% and averaged (divided) by number of active sessions. The difference is calculated by substracting one track vs the other.
% Plots sum and cumulative sum
% INPUT:
% epoch: 'sleep' for only sleep replay,'awake' for only awake replay,'merged' for both
% 'sleep' assumes that rats are always awake during track periods, and therefore excludes those periods when plotting
% bayesian_control: 'Only first exposure','Only re-exposure', to select for data folders from bayesian controls

% Parameters
if isempty(bayesian_control)
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
    load([path '\extracted_replay_plotting_info_excl.mat'])
    load([path '\extracted_time_periods_replay_excl.mat'])
elseif strcmp(bayesian_control,'all') % take both bayesian at the same time
    path = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only first exposure'];
    path2 = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only re-exposure'];
    track_replay_events_F = load([path '\extracted_replay_plotting_info_excl.mat']);
    track_replay_events = track_replay_events_F.track_replay_events;
    track_replay_events_R = load([path2 '\extracted_replay_plotting_info_excl.mat']);
    load([path '\extracted_time_periods_replay_excl.mat'])
    path = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls']
elseif strcmp(bayesian_control,'RUN1 final lap') 
    path ='X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
    load([path,'\Bayesian Controls\replay_control_final_lap\extracted_replay_plotting_info_final_lap.mat']);
    
    % SLEEP REPLAY
    load([path,'\Bayesian Controls\replay_control_final_lap\rate_per_second_sleep_replay_30min_excl_final_lap.mat']);
    load([path '\extracted_time_periods_replay_excl.mat'])
else
    path = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\' bayesian_control];
    load([path '\extracted_replay_plotting_info_excl.mat'])
    load([path '\extracted_time_periods_replay_excl.mat'])
end

%path = pwd;

% load([path '\extracted_replay_plotting_info.mat'])
% load([path '\extracted_time_periods_replay.mat'])

PP =  plotting_parameters;
bin_width = 60; %1 min

% Set periods to be analysed
if ~isempty(bayesian_control) 
        periods = [{'PRE'},{'sleep_pot1'},{'INTER_post'},{'sleep_pot2'},{'FINAL_post'}];
elseif isfield(track_replay_events,'T3') & ~isempty(track_replay_events(1).T3) 
    periods = [{'PRE'},{'sleep_pot1'},{'INTER_post'},{'sleep_pot2'},{'FINAL_post'}];
else  % 2 tracks only
    periods = [{'PRE'},{'sleep_pot1'},{'FINAL_post'}];
end

% Set comparison types
if isfield(track_replay_events,'T3') & ~isempty(track_replay_events(1).T3)
    comparisons = {[1,2],[3,4],[1,3,2,4],[1,3],[2,4]}; %types of comparisons to analysed (value = track num)
else
    comparisons = {[1,2]}; %types of comparisons to analysed (value = track num)
end

% Find indices for each type of protocol
t2 = [];
for s = 1 : length(track_replay_events)
    name = cell2mat(track_replay_events(s).session(1));
    if any(strfind(name,'Ctrl'))  
        t2 = [t2 str2num(name(end-1:end))];
    elseif any(strfind(name,'RateRemap'))
        t2 = [t2 1515];
    else
        t2 = [t2 str2num(name(end))];
    end
end
protocols = unique(t2,'stable');


for c = 1 : length(comparisons) % For each type of comparison
    track = [];
    for j = 1 : length(cell2mat(comparisons(c))) %find how many tracks are being compared
        comp = cell2mat(comparisons(c));
        track(j) =comp(j);
    end
    
    % PLOT
    f(c) = figure('units','normalized','outerposition',[0 0 1 1],'Color','w');
    f(c).Name = strcat('Cumulative replay events diff between tracks -',num2str(cell2mat(comparisons(c))),'during all sleep periods - ',epoch);
    
    % For each protocol (8,4,3,2 or 1)
    for i = 1 : length(protocols)
        
        this_protocol_idx = find(t2 == protocols(i)); %find indices of sessions from the current protocol

        for p = 1 : length(periods) %for each time period (sleep or run) within the protocol
            
            if strcmp(bayesian_control,'all') % take both bayesian at the same time
                if p <= 3 % for PRE and INTER
                    track_replay_events = track_replay_events_F.track_replay_events;
                else % for FINAL
                    track_replay_events = track_replay_events_R.track_replay_events;
                end
            end
            %if ~isempty(period_time(this_protocol_idx).(strcat(periods{p})).(strcat(epoch,'_cumulative_time'))) %if this period exists
                
                N = [];
                % find the longest period between these protocol sessions
                mt = [];
                for ii = 1 : length (this_protocol_idx)
                    if strcmp(epoch,'merged')
                            mt = [mt; period_time(this_protocol_idx(ii)).(strcat(periods{p})).length];
                    else
                        if ~isempty(period_time(this_protocol_idx(ii)).(strcat(periods{p})).(strcat(epoch,'_cumulative_time')))
                            mt = [mt; max(period_time(this_protocol_idx(ii)).(strcat(periods{p})).(strcat(epoch,'_cumulative_time')),[],'all')];
                        end
                    end
                end
                longest_period_time = max(mt);
                if isempty(longest_period_time)
                    continue
                end
                if longest_period_time > 0 && longest_period_time < bin_width %if this period only has 1 bin, that is smaller than 60 sec
                    bin_edges = 0:longest_period_time:longest_period_time;
                    disp(strcat('Time bin for :', periods{p},' is smaller than 1 min'))
                else
                    bin_edges = 0:bin_width:longest_period_time; %bin the time based on the longest period
                end
                
                this_period_events = [];
                total_num_events = [];
                % For these protocol sessions, find number of events for each time bin (for this period), and substract from the other track to which is being compared to
                for idx = 1 : length(this_protocol_idx)
                    if length(comparisons{c}) == 2
                        [N1,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(1)))).(strcat(periods{p},'_',epoch,'_cumulative_times'))],bin_edges); %events track 1
                        [N2,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(2)))).(strcat(periods{p},'_',epoch,'_cumulative_times'))],bin_edges); %events track 2
                        this_period_events = [this_period_events; N1-N2]; % substracts T1 from T2
                        total_num_events = [total_num_events; N1+N2]; 
                    else % if comparing 4 tracks
                        [N1,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(1)))).(strcat(periods{p},'_',epoch,'_cumulative_times'))],bin_edges);
                        [N2,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(2)))).(strcat(periods{p},'_',epoch,'_cumulative_times'))],bin_edges);
                        [N3,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(3)))).(strcat(periods{p},'_',epoch,'_cumulative_times'))],bin_edges);
                        [N4,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(4)))).(strcat(periods{p},'_',epoch,'_cumulative_times'))],bin_edges);
                        this_period_events = [this_period_events; (N1+N2)-(N3+N4)];
                        total_num_events = [total_num_events; (N1+N2+N3+N4)]; 
                    end
                end
                clear N1 N2 N3 N4
                % Normalize event count based on the length of longest time period,by looking how many sessions contribute to each time bin
                bins_with_active_period = ones(1,length(bin_edges))*length(this_protocol_idx); % Set the count as if all periods had the same length
                for t = 1 : length(this_protocol_idx)
                    if strcmp(epoch,'merged') & period_time(this_protocol_idx(t)).(strcat(periods{p})).length < longest_period_time % if this sessions is shorter than the longest period
                        [~,idx] = min(abs(bin_edges - period_time(this_protocol_idx(t)).(strcat(periods{p})).length)); %find bin indx where session is not active anymore
                        bins_with_active_period(idx+1:end) = bins_with_active_period(idx+1:end) - 1;
                    elseif ~strcmp(epoch,'merged') & max(period_time(this_protocol_idx(t)).(strcat(periods{p})).(strcat(epoch,'_cumulative_time')),[],'all') < longest_period_time % if this sessions is shorter than the longest period
                        [~,idx] = min(abs(bin_edges - max(period_time(this_protocol_idx(t)).(strcat(periods{p})).(strcat(epoch,'_cumulative_time')),[],'all'))); %find bin indx where session is not active anymore
                        bins_with_active_period(idx+1:end) = bins_with_active_period(idx+1:end) - 1;
                    end
                end
                
                % Sum events of all sessions of this protocol & divide events of each bin by number of active periods in that bin
                if size(this_period_events,1) > 1
                    N = sum(this_period_events);
                    sum_total_events = sum(total_num_events);
                else
                    N = this_period_events;
                    sum_total_events = total_num_events;
                end
                
                event_count(i).(strcat(periods{p},'_total_events')) = total_num_events;
                event_count(i).(strcat(periods{p},'_mean_total_events')) = sum_total_events./bins_with_active_period(1:end-1);
                event_count(i).(strcat(periods{p},'_std')) = std(this_period_events);
                event_count(i).(strcat(periods{p})) = smooth(N./bins_with_active_period(1:end-1),5); % sum mean
                event_count(i).(strcat(periods{p},'_cumsum')) = cumsum(N./bins_with_active_period(1:end-1)); % cumsum mean
                time_bin_edges(i).(strcat(periods{p})) = bin_edges;  %time bin edges per period
                active_bins(i).(strcat(periods{p})) = bins_with_active_period; %number of sessions with info for each time bin
            %end
        end
        
        % Save for later plotting
        T(c).event_count{i} = event_count(i);
        T(c).protocol_num{i} = protocols(i);
        T(c).time_bin_edges{i} = time_bin_edges(i); 
        T(c).active_bins{i} = active_bins(i);
        
    end
    
    
    % PLOT
    f10(c) = figure('units','normalized','outerposition',[0 0 1 1],'Color','w');
    if length(periods) == 3 % 2 tracks only
        f10(c).Name = strcat('Cumulative replay events difference between tracks -',num2str(cell2mat(comparisons(c))),' during FINAL sleep - ',epoch);
        subplot_idx = 1;
        sub_ix = [0 1 0 2];
    else
        f10(c).Name = strcat('Cumulative replay events difference between tracks -',num2str(cell2mat(comparisons(c))),' during INTER and FINAL sleep - ',epoch);
        subplot_idx = 2;
        sub_ix = [1 2 3 4];
    end
    f10(c).Position = [0.3 0 0.58 0.9];
    
    if length(periods) > 3 % more than 2 tracks
        subplot(subplot_idx,2,sub_ix(1))    
            for ii = 1 : length(T(c).event_count)
                % Find at which time bin starts being information only for half of the rats
                half_rats_thresh = find(cumsum(abs(diff(T(c).active_bins{1,ii}.INTER_post))) >= floor(max(T(c).active_bins{1,ii}.INTER_post)/2),1);
                plot(1:half_rats_thresh,T(c).event_count{1,ii}.INTER_post(1:half_rats_thresh),'Color',PP.T2(ii,:),'LineWidth',2)
                hold on
                plot(half_rats_thresh:length(T(c).event_count{1,ii}.INTER_post),T(c).event_count{1,ii}.INTER_post(half_rats_thresh:end),'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
            end
            line([min(xlim) max(xlim)],[0 0],'Color','k','LineWidth',1,'LineStyle','--')  % to separate between tracks
            box off
            xlabel('Binned time (min)','FontSize',16); ylabel('Sum replay bias','FontSize',16)
            title(strcat('SUM - Post first exposure sleep'),'FontSize',16)
            a = gca;
            a.FontSize = 16;
            
        ax2 = subplot(subplot_idx,2,sub_ix(3));
            for ii = 1 : length(T(c).event_count)
                % Add standard deviation as shade
                x = 1:numel(T(c).event_count{1,ii}.INTER_post_cumsum);
                shade1 = T(c).event_count{1,ii}.INTER_post_cumsum + T(c).event_count{1,ii}.INTER_post_std;
                shade2 = T(c).event_count{1,ii}.INTER_post_cumsum - T(c).event_count{1,ii}.INTER_post_std;
                x2 = [x,fliplr(x)];
                inBetween = [shade1,fliplr(shade2)];
                h=fill(ax2,x2,inBetween,PP.T2(ii,:));
                set(h,'facealpha',0.2,'LineStyle','none')
                hold on
                % Find at which time bin starts being information only for half of the rats
                half_rats_thresh = find(cumsum(abs(diff(T(c).active_bins{1,ii}.INTER_post))) >= floor(max(T(c).active_bins{1,ii}.INTER_post)/2),1);
                plot(ax2,1:half_rats_thresh,T(c).event_count{1,ii}.INTER_post_cumsum(1:half_rats_thresh),'Color',PP.T2(ii,:),'LineWidth',2)
                T(c).event_count{1,ii}.INTER_post_cumsum_ALLRATS = T(c).event_count{1,ii}.INTER_post_cumsum(1:half_rats_thresh);
                T(c).event_count{1,ii}.INTER_post_ALLRATS = T(c).event_count{1,ii}.INTER_post(1:half_rats_thresh);
                T(c).event_count{1,ii}.INTER_post_mean_total_events_ALLRATS = T(c).event_count{1,ii}.INTER_post_total_events(1:half_rats_thresh);
                hold on
                plot(ax2,half_rats_thresh:length(T(c).event_count{1,ii}.INTER_post_cumsum),T(c).event_count{1,ii}.INTER_post_cumsum(half_rats_thresh:end),'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
            end
            line(ax2,[min(xlim) max(xlim)],[0 0],'Color','k','LineWidth',1,'LineStyle','--')  % to separate between tracks
            box off
            xlabel('Binned time (min)','FontSize',16); ylabel('Cumulative replay bias','FontSize',16)
            title(strcat('CUMSUM - Post first exposure sleep'),'FontSize',16)
            a = gca;
            a.FontSize = 16;
    end

            subplot(subplot_idx,2,sub_ix(2))
    for ii = 1 : length(T(c).event_count)
        % Find at which time bin starts being information only for half of the rats
        half_rats_thresh = find(cumsum(abs(diff(T(c).active_bins{1,ii}.FINAL_post))) >= floor(max(T(c).active_bins{1,ii}.FINAL_post)/2),1);
        if ~isempty(half_rats_thresh)
            pl(ii) = plot(1:half_rats_thresh,T(c).event_count{1,ii}.FINAL_post(1:half_rats_thresh),'Color',PP.T2(ii,:),'LineWidth',2);
            hold on
            plot(half_rats_thresh:length(T(c).event_count{1,ii}.FINAL_post),T(c).event_count{1,ii}.FINAL_post(half_rats_thresh:end),'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
        else
            plot(1:length(T(c).event_count{1,ii}.FINAL_post),T(c).event_count{1,ii}.FINAL_post,'Color',PP.T2(ii,:),'LineWidth',2)
            
        end
        line([min(xlim) max(xlim)],[0 0],'Color','k','LineWidth',1,'LineStyle','--')  % to separate between tracks
    end

    box off
    xlabel('Binned time (min)','FontSize',16); ylabel('Sum replay bias','FontSize',16)
    title('SUM - Post re-exposure sleep','FontSize',16)
    a = gca;
    a.FontSize = 16;
    
    ax3=   subplot(subplot_idx,2,sub_ix(4));
    for ii = 1 : length(T(c).event_count)
        % Add standard deviation as shade
        x = 1:numel(T(c).event_count{1,ii}.FINAL_post_cumsum);
        shade1 = T(c).event_count{1,ii}.FINAL_post_cumsum + T(c).event_count{1,ii}.FINAL_post_std;
        shade2 = T(c).event_count{1,ii}.FINAL_post_cumsum - T(c).event_count{1,ii}.FINAL_post_std;
        x2 = [x,fliplr(x)];
        inBetween = [shade1,fliplr(shade2)];
        h=fill(ax3,x2,inBetween,PP.T2(ii,:));
        set(h,'facealpha',0.2,'LineStyle','none')
        hold on
        % Find at which time bin starts being information only for half of the rats
        half_rats_thresh = find(cumsum(abs(diff(T(c).active_bins{1,ii}.FINAL_post))) >= floor(max(T(c).active_bins{1,ii}.FINAL_post)/2),1);
        if ~isempty(half_rats_thresh)
            plot(ax3,1:half_rats_thresh,T(c).event_count{1,ii}.FINAL_post_cumsum(1:half_rats_thresh),'Color',PP.T2(ii,:),'LineWidth',2);
            T(c).event_count{1,ii}.FINAL_post_cumsum_ALLRATS = T(c).event_count{1,ii}.FINAL_post_cumsum(1:half_rats_thresh);
            T(c).event_count{1,ii}.FINAL_post_ALLRATS = T(c).event_count{1,ii}.FINAL_post(1:half_rats_thresh);
            T(c).event_count{1,ii}.FINAL_post_mean_total_events_ALLRATS = T(c).event_count{1,ii}.FINAL_post_total_events(1:half_rats_thresh);
            hold on
            plot(ax3,half_rats_thresh:length(T(c).event_count{1,ii}.FINAL_post_cumsum),T(c).event_count{1,ii}.FINAL_post_cumsum(half_rats_thresh:end),'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
        else
            T(c).event_count{1,ii}.FINAL_post_cumsum_ALLRATS = T(c).event_count{1,ii}.FINAL_post_cumsum;
            T(c).event_count{1,ii}.FINAL_post_ALLRATS = T(c).event_count{1,ii}.FINAL_post;
            T(c).event_count{1,ii}.FINAL_post_mean_total_events_ALLRATS = T(c).event_count{1,ii}.FINAL_post_total_events;
            plot(ax3,1:length(T(c).event_count{1,ii}.FINAL_post_cumsum),T(c).event_count{1,ii}.FINAL_post_cumsum,'Color',PP.T2(ii,:),'LineWidth',2)
            hold on
        end
        line([min(xlim) max(xlim)],[0 0],'Color','k','LineWidth',1,'LineStyle','--')  % to separate between tracks
    end
    box off
    xlabel('Binned time (min)','FontSize',16); ylabel('Cumulative replay bias','FontSize',16)
    title('CUMSUM - Post re-exposure sleep','FontSize',16)
    a = gca;
    a.FontSize = 16;
    
    annotation('textbox',[0.45,0.9,0.05,0.1],'String',strcat('Comparison tracks ', num2str(track) ,'-', epoch,' replay'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
    if ii == 5
        legend([pl(1) pl(2) pl(3) pl(4) pl(5)],{'16x8 Laps', '16x4 Laps', '16x3 Laps', '16x2 Laps', '16x1 Lap'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
    elseif ii == 2
        legend([pl(1) pl(2)],{'16 x 16+Blocks','1 x 1+Blocks'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
    end
    
    %PLOT ALL PERIODS CUMSUM EVENTS TOGETHER
    figure(f(c))
    t_end = 1;
    all_ends = [];
    for p = 1 : length(periods)
        period_duration = [];
        for ii = 1 : length(T(c).event_count)
            if isfield(T(c).time_bin_edges{1,ii},(strcat(periods{p})))
                period_duration = [period_duration length(T(c).time_bin_edges{1,ii}.(strcat(periods{p})))];
            end
        end
        if isempty(period_duration)
            continue
        end
        if p == 1
            t_start = t_end;
        else
            t_start = t_end + 2; % to leave a space between periods for plotting purposes
        end
        t_end = t_start + max(period_duration);
        all_ends = [all_ends t_end];
        
        for ii = 1 : length(T(c).event_count)
            if isfield(T(c).time_bin_edges{1,ii},(strcat(periods{p})))
                % Find at which time bin starts being information only for half of the rats
                half_rats_thresh = find(cumsum(abs(diff(T(c).active_bins{1,ii}.(strcat(periods{p}))))) >= floor(max(T(c).active_bins{1,ii}.(strcat(periods{p})))/2),1);
                if ~isempty(T(c).event_count{1,ii}.(strcat(periods{p},'_cumsum')))
                    if ~isempty(half_rats_thresh)
                        % Add standard deviation as shade
                        x = t_start:t_start+numel((T(c).event_count{1,ii}.(strcat(periods{p},'_cumsum'))))-1;
                        shade1 = T(c).event_count{1,ii}.(strcat(periods{p},'_cumsum')) + T(c).event_count{1,ii}.(strcat(periods{p},'_std'));
                        shade2 = T(c).event_count{1,ii}.(strcat(periods{p},'_cumsum')) - T(c).event_count{1,ii}.(strcat(periods{p},'_std'));
                        x2 = [x,fliplr(x)];
                        inBetween = [shade1,fliplr(shade2)];
                        h=fill(x2,inBetween,PP.T2(ii,:));
                        set(h,'facealpha',0.2,'LineStyle','none')
                        hold on
                        
                        pl(ii) = plot(t_start:t_start+half_rats_thresh-1, T(c).event_count{1,ii}.(strcat(periods{p},'_cumsum'))(1:half_rats_thresh),'Color',PP.T2(ii,:),'LineWidth',2);
                        hold on
                        plot(t_start+half_rats_thresh-1:(t_start -1 + length(T(c).event_count{1,ii}.(strcat(periods{p},'_cumsum')))),...
                            T(c).event_count{1,ii}.(strcat(periods{p},'_cumsum'))(half_rats_thresh:end),'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
                    else
                        % Add standard deviation as shade
                        x = t_start:t_start+numel((T(c).event_count{1,ii}.(strcat(periods{p},'_cumsum'))))-1;
                        shade1 = T(c).event_count{1,ii}.(strcat(periods{p},'_cumsum')) + T(c).event_count{1,ii}.(strcat(periods{p},'_std'));
                        shade2 = T(c).event_count{1,ii}.(strcat(periods{p},'_cumsum')) - T(c).event_count{1,ii}.(strcat(periods{p},'_std'));
                        x2 = [x,fliplr(x)];
                        inBetween = [shade1,fliplr(shade2)];
                        h=fill(x2,inBetween,PP.T2(ii,:));
                        set(h,'facealpha',0.2,'LineStyle','none')
                        hold on
                        pl(ii) = plot(t_start:(t_start -1 + length(T(c).event_count{1,ii}.(strcat(periods{p},'_cumsum')))),...
                            T(c).event_count{1,ii}.(strcat(periods{p},'_cumsum')),'Color',PP.T2(ii,:),'LineWidth',2);
                    end
                end
            end
        end
        
    end
    for jj = 1 : length(all_ends)-1
        line([all_ends(jj)+1 all_ends(jj)+1],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % to separate between tracks
    end
    box off
    line([min(xlim) max(xlim)],[0 0],'Color','k','LineWidth',1,'LineStyle','--')  % to separate between tracks
    xlabel('Binned time (min)','FontSize',16); ylabel('Cumulative replay bias','FontSize',16)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    
    if length(periods) == 3
        annotation('textbox',[0.45,0.9,0.05,0.1],'String',strcat('Comparison tracks ',num2str(track),'-', epoch,' replay'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
        annotation('textbox',[0.2,0.85,0.05,0.1],'String',strcat('PRE'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
        annotation('textbox',[0.26,0.85,0.05,0.1],'String',strcat('Sleep pot1'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
        annotation('textbox',[0.77,0.85,0.05,0.1],'String',strcat('FINAL post'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
        
        annotation('textbox',[0.08,0.8,0.05,0.1],'String',strcat('Track ', num2str(track(1))),'FitBoxToText','on','EdgeColor','none','FontSize',20);
        annotation('textbox',[0.08,0.1,0.05,0.1],'String',strcat('Track ',num2str(track(2))),'FitBoxToText','on','EdgeColor','none','FontSize',20);
    else
        
        annotation('textbox',[0.45,0.9,0.05,0.1],'String',strcat('Comparison tracks ',num2str(track),'-', epoch,' replay'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
        annotation('textbox',[0.2,0.85,0.05,0.1],'String',strcat('PRE'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
        annotation('textbox',[0.26,0.85,0.05,0.1],'String',strcat('Sleep pot1'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
        annotation('textbox',[0.43,0.85,0.05,0.1],'String',strcat('INTER post'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
        annotation('textbox',[0.68,0.85,0.05,0.1],'String',strcat('Sleep pot2'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
        annotation('textbox',[0.77,0.85,0.05,0.1],'String',strcat('FINAL post'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
        
        annotation('textbox',[0.08,0.8,0.05,0.1],'String',strcat('Track ', num2str(track(1))),'FitBoxToText','on','EdgeColor','none','FontSize',20);
        annotation('textbox',[0.08,0.1,0.05,0.1],'String',strcat('Track ',num2str(track(2))),'FitBoxToText','on','EdgeColor','none','FontSize',20);
    end
    
    if ii == 5
        legend([pl(1) pl(2) pl(3) pl(4) pl(5)],{'16x8 Laps', '16x4 Laps', '16x3 Laps', '16x2 Laps', '16x1 Lap'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
    elseif ii == 2
        legend([pl(1) pl(2)],{'16 x 16+Blocks','1 x 1+Blocks'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
    end        
    
end
   
if strcmp(epoch,'awake')
    epoch = 'rest';
end

if strcmp(bayesian_control,'all')
    if ~exist([path '\all_' epoch '_diff_cum_replay_' num2str(bin_width) '_excl.mat'])
        save([path '\all_' epoch '_diff_cum_replay_' num2str(bin_width) '_excl.mat'],'T')
    end
else
    if ~exist([path '\' epoch '_diff_cum_replay_' num2str(bin_width) '_excl.mat'])
        save([path '\' epoch '_diff_cum_replay_' num2str(bin_width) '_excl.mat'],'T')
    end
end

end