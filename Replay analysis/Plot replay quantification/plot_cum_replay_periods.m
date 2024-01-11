function plot_cum_replay_periods(epoch,bayesian_control)
% Plots distribution of replay events over sleep periods for each track and protocol. 
% Histogram is calculated as the sum of cummulative replay event times across tracks & each experiment (always within a protcol), 
% and averaged (divided) by number of active sessions. 
% Plots sum and cummulative sum
% INPUT: 
    % epoch: 'sleep' for only sleep replay,'awake' for only awake replay, or 'merged' for plotting both together. 
          % 'sleep' assumes that rats are always awake during track periods, and therefore excludes those periods when plotting
    % multievents: 1 or [].To select replay events that were sig for both exposures
    % first and second exposure
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
else
    path = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\' bayesian_control];
    load([path '\extracted_replay_plotting_info_excl.mat'])
    load([path '\extracted_time_periods_replay_excl.mat'])
end

PP =  plotting_parameters;
bin_width = 60; %1 min

% Set periods to be analysed
if ~isempty(bayesian_control) 
        periods = [{'PRE'},{'sleep_pot1'},{'INTER_post'},{'sleep_pot2'},{'FINAL_post'}];
elseif isfield(track_replay_events,'T3')
    periods = [{'PRE'},{'sleep_pot1'},{'INTER_post'},{'sleep_pot2'},{'FINAL_post'}];
else  % 2 tracks only
    periods = [{'PRE'},{'sleep_pot1'},{'FINAL_post'}];
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

% PLOT
f2 = figure('units','normalized','outerposition',[0 0 1 1]);
f2.Name = strcat('Cumulative replay events during all sleep periods - ',epoch);
%f3 = figure('units','normalized','outerposition',[0 0 1 1],'Color','w');
%f3.Name = strcat('Cumulative replay events during Post-Sleep 1 ',epoch);
%f4 = figure('units','normalized','outerposition',[0 0 1 1],'Color','w');
%f4.Name = strcat('Cumulative replay events during Post-Sleep 2 ',epoch);

for track = 1 : num_tracks
    
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
            
            %if ~isempty(period_time(this_protocol_idx).(strcat(periods{p})).(strcat(epoch,'_cumulative_time')))
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
                if longest_period_time > 0 && longest_period_time < bin_width %if this period only has 1 bin, that is smaller than 60 sec
                    bin_edges = 0:longest_period_time:longest_period_time;
                    disp(strcat('Time bin for :', periods{p},' is smaller than 1 min'))
                else
                    bin_edges = 0:bin_width:longest_period_time; %bin the time based on the longest period
                end
                
                
                % For these protocol sessions, find number of events for each time bin (for this period)
                for ii = 1 : length (this_protocol_idx)
                    [N(ii,:),~] = histcounts([track_replay_events(this_protocol_idx(ii)).(sprintf('%s','T',num2str(track))).(strcat(periods{p},'_',epoch,'_cumulative_times'))],bin_edges); %events track 1
                end
                event_count(i).(strcat(periods{p},'_std')) = std(N);
                if size(N,1) > 1
                    N = sum(N,1);
                end
                
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
                event_count(i).(strcat(periods{p})) = smooth(N./bins_with_active_period(1:end-1),5);
                event_count(i).(strcat(periods{p},'_cumsum')) = cumsum(N./bins_with_active_period(1:end-1));
                time_bin_edges(i).(strcat(periods{p})) = bin_edges;  %time bin edges per period
                active_bins(i).(strcat(periods{p})) = bins_with_active_period; %number of sessions with info for each time bin
                
            %end
        end
        
        % Save for later plotting
        T(track).event_count{i} = event_count(i);
        T(track).protocol_num{i} = protocols(i);
        T(track).time_bin_edges{i} = time_bin_edges(i); 
        T(track).active_bins{i} = active_bins(i);
        
    end
    
    
    % PLOT
    f1(track) = figure('units','normalized','outerposition',[0 0 1 1]);
    if length(periods) == 3 % 2 tracks only
        f1(track).Name = strcat('Cumulative replay events during FINAL sleep- Track',num2str(track),'-',epoch);
        subplot_idx = 1;
        sub_ix = [0 1 0 2];
    else
        f1(track).Name = strcat('Cumulative replay events during INTER and FINAL sleep- Track',num2str(track),'-',epoch);
        subplot_idx = 2;
        sub_ix = [1 2 3 4];
    end
    
    if length(periods) > 3 % more than 2 tracks
        subplot(subplot_idx,2,sub_ix(1))
            for ii = 1 : length(T(track).event_count)
                % Find at which time bin starts being information only for half of the rats
                half_rats_thresh = find(cumsum(abs(diff(T(track).active_bins{1,ii}.INTER_post))) >= floor(max(T(track).active_bins{1,ii}.INTER_post)/2),1);
                plot(1:half_rats_thresh,T(track).event_count{1,ii}.INTER_post(1:half_rats_thresh)/bin_width,'Color',PP.T2(ii,:),'LineWidth',2)
                hold on
                plot(half_rats_thresh:length(T(track).event_count{1,ii}.INTER_post),T(track).event_count{1,ii}.INTER_post(half_rats_thresh:end)/bin_width,'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
            end
            box off
            xlabel('Binned time (min)','FontSize',16); ylabel('Rate of replay events (events/sec)','FontSize',16)
            title(strcat('SUM - Post first exposure sleep'),'FontSize',16)
            a = gca;
            a.FontSize = 16;
            
        subplot(subplot_idx,2,sub_ix(3))
            for ii = 1 : length(T(track).event_count)
                % Add standard deviation as shade
                x = 1:numel(T(track).event_count{1,ii}.INTER_post_cumsum);
                shade1 = T(track).event_count{1,ii}.INTER_post_cumsum + T(track).event_count{1,ii}.INTER_post_std;
                shade2 = T(track).event_count{1,ii}.INTER_post_cumsum - T(track).event_count{1,ii}.INTER_post_std;
                x2 = [x,fliplr(x)];
                inBetween = [shade1,fliplr(shade2)];
                h=fill(x2,inBetween,PP.T2(ii,:));
                set(h,'facealpha',0.2,'LineStyle','none')
                hold on
                % Find at which time bin starts being information only for half of the rats
                half_rats_thresh = find(cumsum(abs(diff(T(track).active_bins{1,ii}.INTER_post))) >= floor(max(T(track).active_bins{1,ii}.INTER_post)/2),1);
                plot(1:half_rats_thresh,T(track).event_count{1,ii}.INTER_post_cumsum(1:half_rats_thresh),'Color',PP.T2(ii,:),'LineWidth',2)
                hold on
                plot(half_rats_thresh:length(T(track).event_count{1,ii}.INTER_post_cumsum),T(track).event_count{1,ii}.INTER_post_cumsum(half_rats_thresh:end),'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
            end
            box off
            xlabel('Binned time (min)','FontSize',16); ylabel('# cumulative replay events','FontSize',16)
            title(strcat('CUMSUM - Post first exposure sleep'),'FontSize',16)
            a = gca;
            a.FontSize = 16;
    end
    
       subplot(subplot_idx,2,sub_ix(2))
    for ii = 1 : length(T(track).event_count)
        % Find at which time bin starts being information only for half of the rats
        half_rats_thresh = find(cumsum(abs(diff(T(track).active_bins{1,ii}.FINAL_post))) >= floor(max(T(track).active_bins{1,ii}.FINAL_post)/2),1);
        if ~isempty(half_rats_thresh)
            pl(ii) = plot(1:half_rats_thresh,T(track).event_count{1,ii}.FINAL_post(1:half_rats_thresh)/bin_width,'Color',PP.T2(ii,:),'LineWidth',2);
            hold on
            plot(half_rats_thresh:length(T(track).event_count{1,ii}.FINAL_post),T(track).event_count{1,ii}.FINAL_post(half_rats_thresh:end)/bin_width,'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
        else
            pl(ii) = plot(1:length(T(track).event_count{1,ii}.FINAL_post),T(track).event_count{1,ii}.FINAL_post,'Color',PP.T2(ii,:)/bin_width,'LineWidth',2);
            hold on
        end
    end
    box off
    xlabel('Binned time (min)','FontSize',16); ylabel('# cumulative replay events','FontSize',16)
    title('SUM - Post re-exposure sleep','FontSize',16)
    a = gca;
    a.FontSize = 16;

        subplot(subplot_idx,2,sub_ix(4))
    for ii = 1 : length(T(track).event_count)
        % Add standard deviation as shade
        x = 1:numel(T(track).event_count{1,ii}.FINAL_post_cumsum);
        shade1 = T(track).event_count{1,ii}.FINAL_post_cumsum + T(track).event_count{1,ii}.FINAL_post_std;
        shade2 = T(track).event_count{1,ii}.FINAL_post_cumsum - T(track).event_count{1,ii}.FINAL_post_std;
        x2 = [x,fliplr(x)];
        inBetween = [shade1,fliplr(shade2)];
        h=fill(x2,inBetween,PP.T2(ii,:));
        set(h,'facealpha',0.2,'LineStyle','none')
        hold on
        % Find at which time bin starts being information only for half of the rats
        half_rats_thresh = find(cumsum(abs(diff(T(track).active_bins{1,ii}.FINAL_post))) >= floor(max(T(track).active_bins{1,ii}.FINAL_post)/2),1);
        if ~isempty(half_rats_thresh)
            plot(1:half_rats_thresh,T(track).event_count{1,ii}.FINAL_post_cumsum(1:half_rats_thresh),'Color',PP.T2(ii,:),'LineWidth',2);
            hold on
            plot(half_rats_thresh:length(T(track).event_count{1,ii}.FINAL_post_cumsum),T(track).event_count{1,ii}.FINAL_post_cumsum(half_rats_thresh:end),'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
        else
            plot(1:length(T(track).event_count{1,ii}.FINAL_post_cumsum),T(track).event_count{1,ii}.FINAL_post_cumsum,'Color',PP.T2(ii,:),'LineWidth',2);
            hold on
        end
    end
    box off
    xlabel('Binned time (min)','FontSize',16); ylabel('# cumulative replay events','FontSize',16)
    title('CUMSUM - Post re-exposure sleep','FontSize',16)
    a = gca;
    a.FontSize = 16;
    
    annotation('textbox',[0.5,0.9,0.05,0.1],'String',strcat('Track ', num2str(track) ,'-', epoch,' replay'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
    if ii == 5
        legend([pl(1) pl(2) pl(3) pl(4) pl(5)],{'16x8 Laps', '16x4 Laps', '16x3 Laps', '16x2 Laps', '16x1 Lap'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
    elseif ii == 2
        legend([pl(1) pl(2)],{'16 x 16+Blocks','1 x 1+Blocks'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
    end
%     
%     PLOT
%     figure(f2)
%         ax(track) = subplot(num_tracks,1,track);
%         t_end = 1;
%         all_ends = [];
%         for p = 1 : length(periods)
%             period_duration = [];
%             for ii = 1 : length(T(track).event_count)
%                 if isfield(T(track).time_bin_edges{1,ii},(strcat(periods{p})))
%                     period_duration = [period_duration length(T(track).time_bin_edges{1,ii}.(strcat(periods{p})))];
%                 end
%             end
%             if p == 1
%                 t_start = t_end;
%             else
%                 t_start = t_end + 2; % to leave a space between periods for plotting purposes
%             end
%             t_end = t_start + max(period_duration);
%             all_ends = [all_ends t_end];
%             
%             for ii = 1 : length(T(track).event_count)
%                 if isfield(T(track).time_bin_edges{1,ii},(strcat(periods{p})))
%                     Find at which time bin starts being information only for half of the rats
%                     half_rats_thresh = find(cumsum(abs(diff(T(track).active_bins{1,ii}.(strcat(periods{p}))))) >= floor(max(T(track).active_bins{1,ii}.(strcat(periods{p})))/2),1);
%                     if ~isempty(T(track).event_count{1,ii}.(strcat(periods{p},'_cumsum')))
%                         if ~isempty(half_rats_thresh)
%                             Add standard deviation as shade
%                             x = t_start:t_start+numel((T(track).event_count{1,ii}.(strcat(periods{p},'_cumsum'))))-1;
%                             shade1 = T(track).event_count{1,ii}.(strcat(periods{p},'_cumsum')) + T(track).event_count{1,ii}.(strcat(periods{p},'_std'));
%                             shade2 = T(track).event_count{1,ii}.(strcat(periods{p},'_cumsum')) - T(track).event_count{1,ii}.(strcat(periods{p},'_std'));
%                             x2 = [x,fliplr(x)];
%                             inBetween = [shade1,fliplr(shade2)];
%                             h=fill(x2,inBetween,PP.T2(ii,:));
%                             set(h,'facealpha',0.2,'LineStyle','none')
%                             hold on
%                             
%                             pl(ii) = plot(t_start:t_start+half_rats_thresh-1, T(track).event_count{1,ii}.(strcat(periods{p},'_cumsum'))(1:half_rats_thresh),'Color',PP.T2(ii,:),'LineWidth',2);
%                             hold on
%                             plot(t_start+half_rats_thresh-1:(t_start -1 + length(T(track).event_count{1,ii}.(strcat(periods{p},'_cumsum')))),...
%                                 T(track).event_count{1,ii}.(strcat(periods{p},'_cumsum'))(half_rats_thresh:end),'Color',PP.T2(ii,:),'LineWidth',2,'LineStyle',':')
%                         else
%                             Add standard deviation as shade
%                             x = t_start:t_start+numel((T(track).event_count{1,ii}.(strcat(periods{p},'_cumsum'))))-1;
%                             shade1 = T(track).event_count{1,ii}.(strcat(periods{p},'_cumsum')) + T(track).event_count{1,ii}.(strcat(periods{p},'_std'));
%                             shade2 = T(track).event_count{1,ii}.(strcat(periods{p},'_cumsum')) - T(track).event_count{1,ii}.(strcat(periods{p},'_std'));
%                             x2 = [x,fliplr(x)];
%                             inBetween = [shade1,fliplr(shade2)];
%                             h=fill(x2,inBetween,PP.T2(ii,:));
%                             set(h,'facealpha',0.2,'LineStyle','none')
%                             hold on
%                             pl(ii) = plot(t_start:(t_start -1 + length(T(track).event_count{1,ii}.(strcat(periods{p},'_cumsum')))),...
%                                 T(track).event_count{1,ii}.(strcat(periods{p},'_cumsum')),'Color',PP.T2(ii,:),'LineWidth',2);
%                         end
%                     end
%                 end
%             end
%         end
%         
%         for jj = 1 : length(all_ends)-1
%             line([all_ends(jj)+1 all_ends(jj)+1],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % to separate between tracks
%         end
%         box off
%         xlabel('Binned time (min)','FontSize',16); ylabel('# cum events','FontSize',16)
%         title(strcat('Track ',num2str(track)),'FontSize',16)
%         a = gca;
%         a.FontSize = 16;
% end
%     figure(f2)
%     if length(periods) > 3
%         annotation('textbox',[0.5,0.9,0.05,0.1],'String',strcat(' All tracks -', epoch,' replay'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
%         annotation('textbox',[0.2,0.85,0.05,0.1],'String',strcat('PRE'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
%         annotation('textbox',[0.27,0.85,0.05,0.1],'String',strcat('Rest 1'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
%         annotation('textbox',[0.43,0.85,0.05,0.1],'String',strcat('INTER post'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
%         annotation('textbox',[0.68,0.85,0.05,0.1],'String',strcat('Rest 2'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
%         annotation('textbox',[0.77,0.85,0.05,0.1],'String',strcat('FINAL post'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
% 
%         ylim(ax,[0 max([ax(:).YLim])])
%     else
%         annotation('textbox',[0.5,0.9,0.05,0.1],'String',strcat(' All tracks -', epoch,' replay'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
%         annotation('textbox',[0.2,0.85,0.05,0.1],'String',strcat('PRE'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
%         annotation('textbox',[0.31,0.85,0.05,0.1],'String',strcat('Sleep pot1'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
%         annotation('textbox',[0.77,0.85,0.05,0.1],'String',strcat('FINAL post'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
%         
%         linkaxes([ax(1) ax(2)],'y')
%     end
%     
%     if ii == 5
%         legend([pl(1) pl(2) pl(3) pl(4) pl(5)],{'16x8 Laps', '16x4 Laps', '16x3 Laps', '16x2 Laps', '16x1 Lap'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
%     elseif ii == 2
%         legend([pl(1) pl(2)],{'16 x 16+Blocks','1 x 1+Blocks'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
%     end
%     
   
    

end
