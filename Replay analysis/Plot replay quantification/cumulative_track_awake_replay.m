% REPLAY AWAKE (LOCAL AND REMOTE) IN TRACK - CUMULATIVE SUM
% MH 2020
% Plots cumulative sum of awake replay in track, divided by protocols
% (subplots), and plotting both local (decodes current track) and remote (decodes other tracks) awake replay.
% INPUT: multievents. 1 for selection. If multievents, loads data with multi track events not excluded, thus simulating the existance of only 2
    % tracks instead of 4.
% OUTPUT: PROTOCOL structure- each cell is a protocol. Within a cell find count of awake replay events, active bins and time bin edges. Each of these
    % subfields are 4x4, where each row is a track, and each column is the events found in that track while running, that decode for each of the
    % tracks (1 to 4)

function cumulative_track_awake_replay(multievents)


% Parameters
if multievents == 1
    load('extracted_replay_plotting_info_MultiEvents.mat')
    multievents_data = track_replay_events;
    clear track_replay_events
    load('extracted_replay_plotting_info.mat')
    alltracks_data = track_replay_events;
else
    load('extracted_replay_plotting_info.mat')
end
load('extracted_time_periods_replay.mat')

PP =  plotting_parameters;
bin_width = 2; %2 sec

% Find number of tracks in the session
if isfield(track_replay_events,'T4')
    num_tracks = 4;
else
    num_tracks = 2;
end

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

if multievents == 1
        clear track_replay_events
end
    
% For each protocol (8,4,3,2 or 1)
for i = 1 : length(protocols)

    this_protocol_idx = find(t2 == protocols(i)); %find indices of sessions from the current protocol
   
    for track = 1 : num_tracks
        
        if multievents == 1 %if using multievents, for T1 and T2 use multievent (to not take into account the re-exposures)
            if track < 3
                track_replay_events = multievents_data;
            else
                track_replay_events = alltracks_data;
            end
        end
        
        N = [];
        % find the longest period between these protocol sessions
        mt = [];
        for ii = 1 : length(this_protocol_idx)
            mt = [mt; period_time(this_protocol_idx(ii)).(sprintf('%s','T',num2str(track))).length]; %find the longest run in track
        end
        longest_period_time = max(mt);
        if longest_period_time > 0 && longest_period_time < bin_width %if this period only has 1 bin, that is smaller than 2sec
            bin_edges = 0:longest_period_time:longest_period_time;
            disp(strcat('Time bin for :', periods{p},' is smaller than 1 min'))
        else
            bin_edges = 0:bin_width:longest_period_time; %bin the time based on the longest period
        end

        % Find awake replay events for each track while animal runs in track
        for p = 1 : length(periods)

            % For these protocol sessions, find number of events for each time bin (for this period)
            for ii = 1 : length (this_protocol_idx)
                [N(ii,:),~] = histcounts([track_replay_events(this_protocol_idx(ii)).(sprintf('%s',periods{p})).(sprintf('%s','T',num2str(track),'_awake_cumulative_times'))],bin_edges); %events track 1
            end
            event_count(track).(strcat(periods{p},'_std')) = std(N);
            if size(N,1) > 1
                N = sum(N,1);
            end

            % Normalize event count based on the length of longest time period,by looking how many sessions contribute to each time bin
            bins_with_active_period = ones(1,length(bin_edges))*length(this_protocol_idx); % Set the count as if all periods had the same length
            for t = 1 : length(this_protocol_idx)
                if period_time(this_protocol_idx(t)).(sprintf('%s','T',num2str(track))).cumulative_times(2) < longest_period_time % if this session is shorter than the longest period
                    [~,idx] = min(abs(bin_edges - period_time(this_protocol_idx(t)).(sprintf('%s','T',num2str(track))).cumulative_times(2))); %find bin indx where session is not active anymore
                    bins_with_active_period(idx+1:end) = bins_with_active_period(idx+1:end) - 1;
                end
            end

            % Sum events of all sessions of this protocol & divide events of each bin by number of active periods in that bin
            event_count(track).(strcat(periods{p})) = smooth(N./bins_with_active_period(1:end-1),5);
            event_count(track).(strcat(periods{p},'_cumsum')) = cumsum(N./bins_with_active_period(1:end-1));
            time_bin_edges(track).(strcat(periods{p})) = bin_edges;  %time bin edges per period
            active_bins(track).(strcat(periods{p})) = bins_with_active_period; %number of sessions with info for each time bin
        end
    end
    
    % Save for later plotting
    protocol{i}.event_count = event_count;
    protocol{i}.protocol_num = protocols(i);
    protocol{i}.time_bin_edges = time_bin_edges; 
    protocol{i}.active_bins = active_bins;
    
    clear event_count time_bin_edges active_bins
end


 %PLOT
f1 = figure('units','normalized','outerposition',[0 0 1 1]);
if multievents == 1
    f1.Name = ['Cumulative awake replay in track_MultiEvents_' num2str(bin_width) 'sec bins'];
else
    f1.Name = ['Cumulative awake replay in track_' num2str(bin_width) 'sec bins'];
end
c = 1;
 for prot = 1 : length(protocols) % a subplot per protocol with the 4 tracks in it
     
     %ax(prot) = subplot(length(protocols),1,prot);
     t_end = 1;
     period_duration = cellfun(@length,{protocol{1,prot}.time_bin_edges(:).T1});
     
     for t = 1 : num_tracks
         ax(c) = subplot(length(protocols),4,c);
         if t == 1
             t_start = t_end;
         else
             t_start = t_end + 50; % to leave a space between periods for plotting purposes
         end
         t_end = sum([t_start period_duration(t)]);
         if multievents == 1
             if t <3
                num_periods = 2;
             else
                num_periods = 4;
             end
         end
         for p = 1 : num_periods
             % Find at which time bin starts being information only for half of the rats
             half_rats_thresh = find(cumsum(abs(diff(protocol{1,prot}.active_bins(t).(strcat(periods{p}))))) >= floor(max(protocol{1,prot}.active_bins(t).(strcat(periods{p})))/2),1);
             if ~isempty(protocol{1,prot}.event_count(t).(strcat(periods{p},'_cumsum')))
                 if ~isempty(half_rats_thresh)
                     % Add standard deviation as shade
                     x = t_start:t_start+numel((protocol{1,prot}.event_count(t).(strcat(periods{p},'_cumsum'))))-1;
                     shade1 = protocol{1,prot}.event_count(t).(strcat(periods{p},'_cumsum')) + protocol{1,prot}.event_count(t).(strcat(periods{p},'_std'));
                     shade2 = protocol{1,prot}.event_count(t).(strcat(periods{p},'_cumsum')) - protocol{1,prot}.event_count(t).(strcat(periods{p},'_std'));
                     x2 = [x,fliplr(x)];
                     inBetween = [shade1,fliplr(shade2)];
                     h=fill(x2,inBetween,PP.P(prot).colorT(p,:));
                     set(h,'facealpha',0.2,'LineStyle','none')
                     hold on
                     
                     pl(c) = plot(t_start:t_start+half_rats_thresh-1, protocol{1,prot}.event_count(t).(strcat(periods{p},'_cumsum'))(1:half_rats_thresh),...
                         'Color',PP.P(prot).colorT(p,:),'LineWidth',2,'LineStyle',PP.Linestyle{p});
                     hold on
                     plot(t_start+half_rats_thresh-1:(t_start -1 + length(protocol{1,prot}.event_count(t).(strcat(periods{p},'_cumsum')))),...
                         protocol{1,prot}.event_count(t).(strcat(periods{p},'_cumsum'))(half_rats_thresh:end),'Color',PP.P(prot).colorT(p,:),'LineWidth',1.5,'LineStyle',':')
                 else
                     % Add standard deviation as shade
                     x = t_start:t_start+numel((protocol{1,prot}.event_count(t).(strcat(periods{p},'_cumsum'))))-1;
                     shade1 = protocol{1,prot}.event_count(t).(strcat(periods{p},'_cumsum')) + protocol{1,prot}.event_count(t).(strcat(periods{p},'_std'));
                     shade2 = protocol{1,prot}.event_count(t).(strcat(periods{p},'_cumsum')) - protocol{1,prot}.event_count(t).(strcat(periods{p},'_std'));
                     x2 = [x,fliplr(x)];
                     inBetween = [shade1,fliplr(shade2)];
                     h=fill(x2,inBetween,PP.P(prot).colorT(p,:));
                     set(h,'facealpha',0.2,'LineStyle','none')
                     hold on
                     pl(c) = plot(t_start:(t_start -1 + length(protocol{1,prot}.event_count(t).(strcat(periods{p},'_cumsum')))),...
                         protocol{1,prot}.event_count(t).(strcat(periods{p},'_cumsum')),'Color',PP.P(prot).colorT(p,:),'LineWidth',2,'LineStyle',PP.Linestyle{p});
                 end
             end
              box off
              if c <5
                  title(['Track ' num2str(t)])
              end
              if c == 1 || c == 5 || c == 9 || c == 13 || c == 17
                  ylabel({'# awake';'replay events'})
              end
              if c == 17 || c == 18 || c == 19 || c == 13 || c == 20
                  xlabel(['Time bins(' num2str(bin_width) 'sec)'])
              end
%               if c == 4 || c == 8 || c == 12 || c == 16 || c == 20
%                   legend([pl(c-3) pl(c-2) pl(c-1) pl(c)],{'T1', 'T2', 'R-T1', 'R-T2'},'Location','northeastoutside','FontSize',14);
%               end
              ax(c).FontSize = 14;
         end
         c = c+1;

     end
 end

 save_all_figures(pwd,[])
 
end