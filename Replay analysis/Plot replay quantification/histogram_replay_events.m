function histogram_replay_events(plot_type,epoch, merge_exposures,data_type,bayesian_control)
% Plots distribution of replay events over time for each track and protocol. 
% Histogram is calculated as the sum of replay events divided by number of active sessions. 
% INPUT: 
    %plot_type: 'sum' for showing normal histogram; 'cumsum' for showing cumulative sum of events
    %epoch: 'sleep' for only sleep replay,'awake' for only awake replay, or 'ALL' for plotting both together. 
    % 'sleep' assumes that rats are always awake during track periods, and therefore excludes those periods when plotting
    % merge_exposures: option to merge events from first and second exposure
    %bayesian_control: write the name of one of the bayesian controls run 

% Parameters
if strcmp(data_type,'main')
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
elseif ~isempty(bayesian_control)
    path = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\' bayesian_control];
end

load([path '\extracted_replay_plotting_info.mat'])
load([path '\extracted_time_periods_replay.mat'])
bin_width = 60; % min
PP = plotting_parameters;

% Set periods to be analysed
if strcmp(epoch,'ALL') | strcmp(epoch,'awake') & isfield(track_replay_events,'T3') | ~isempty(bayesian_control)
    periods = [{'PRE'},{'T1'},{'sleep_pot1'},{'T2'},{'INTER_post'},{'T3'},{'sleep_pot2'},{'T4'},{'FINAL_post'}];
elseif strcmp(epoch,'sleep')  & isfield(track_replay_events,'T3')
    periods = [{'PRE'},{'sleep_pot1'},{'INTER_post'},{'sleep_pot2'},{'FINAL_post'}];
elseif strcmp(epoch,'ALL') | strcmp(epoch,'awake') & ~isfield(track_replay_events,'T3') % 2 tracks only
    periods = [{'PRE'},{'T1'},{'sleep_pot1'},{'T2'},{'FINAL_post'}];
else
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

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
f2 = figure('units','normalized','outerposition',[0 0 1 1]);

% Find number of tracks in the session
if isfield(track_replay_events,'T4') & merge_exposures ~= 1
    num_tracks = 4;
else
    num_tracks = 2;
end

% Calculate number of events per protocol (e.g. 16x8)
for t = 1 : num_tracks %for each track
    for i = 1 : length(protocols)
        this_protocol_idx = find(t2 == protocols(i)); %find indices of sessions from the current protocol
        for p = 1 : length(periods) %for each time period (sleep or run)
            all_sessions_events = [];
            % For these protocol sessions, find number of events for each time bin
            if strfind(periods{p},'T') == 1  %if it's track period
                for kk = 1 : length(this_protocol_idx)                   
                    %num_events(p,kk) = length([track_replay_events(track).(strcat(cell2mat(periods(p)),'_norm_event_times')){this_protocol_idx(1):this_protocol_idx(end)}]);
                    num_events(p,kk) = length([track_replay_events(this_protocol_idx(kk)).(sprintf('%s','T',num2str(t),'_normalized')).(strcat(periods{p},'_norm_times'))]);
                end            
            else 
                for kk = 1 : length(this_protocol_idx)
                    %num_events(p,kk) = length([track_replay_events(track).session_replay_events(this_protocol_idx(1):this_protocol_idx(end)).(strcat(cell2mat(periods(p)),'_norm_event_times'))]);
                    num_events(p,kk) = length([track_replay_events(this_protocol_idx(kk)).(sprintf('%s','T',num2str(t),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))]);
                end
            end
            all_sessions_events = [all_sessions_events, num_events]; % create matrix with all periods events count per rat/session
        end
         num_events_protocol(i,t) = {sum(all_sessions_events,1)}; % add up all events per session, and save in corresponding protocol and track
    end
end
        
% Calculate number of events per period, protocol and track       
for t = 1 : num_tracks %for each track
    f(t*10) = figure('units','normalized','outerposition',[0 0 1 1]);
    
    % For each protocol (8,4,3,2 or 1)
    for i = 1 : length(protocols)
    
    this_protocol_idx = find(t2 == protocols(i)); %find indices of sessions from the current protocol
    protocol_event_count = [];
    event_count = [];
    prop_event_count = []; 
    protocol_prop_event_count = [];
    rat_protocol_prop_event_count = [];
    rat_protocol_event_count =[];
    
    for p = 1 : length(periods) %for each time period (sleep or run)
        sum_sessions_events = [];
        % find the longest period between these protocol sessions
        mt = [];
        for ii = 1 : length (this_protocol_idx)
            mt = [mt; period_time(this_protocol_idx(ii)).(strcat(periods{p})).length];
            longest_period_time = max(mt); 
        end
        if longest_period_time > 0 && longest_period_time < bin_width %if this period only has 1 bin, that is smaller than 60 sec
            bin_edges = 0:longest_period_time:longest_period_time; 
            disp(strcat('Time bin for :', periods{p},' is smaller than 1 min'))
        else
            bin_edges = 0:bin_width:longest_period_time; %bin the time based on the longest period 
        end
        N = []; 
        Nprop = [];
        % For these protocol sessions, find number of events for each time bin
        if strfind(periods{p},'T') == 1 % for track
            for kk = 1 : length(this_protocol_idx)
                if merge_exposures == 1 %merge events from first and second exposure
                    if mod(t,2) == 0 %tracks 2 or 4
                        merged_events = sort([track_replay_events(this_protocol_idx(kk)).T2_normalized.(strcat(periods{p},'_norm_times')) ...
                            track_replay_events(this_protocol_idx(kk)).T4_normalized.(strcat(periods{p},'_norm_times'))]);
                    else %tracks 1 or 3
                        merged_events = sort([track_replay_events(this_protocol_idx(kk)).T1_normalized.(strcat(periods{p},'_norm_times')) ...
                            track_replay_events(this_protocol_idx(kk)).T3_normalized.(strcat(periods{p},'_norm_times'))]);
                    end
                    [N(kk,:),~] = histcounts(merged_events,bin_edges); %number of events per bin
                else
                    [N(kk,:),~] = histcounts([track_replay_events(this_protocol_idx(kk)).(sprintf('%s','T',num2str(t),'_normalized')).(strcat(periods{p},'_norm_times'))],bin_edges); %number of events per bin
                end
                session_events = [];
                for jj = 1 : size(num_events_protocol,2)
                    session_events = [session_events num_events_protocol{i,jj}(kk)];
                    session_sum = sum(session_events); % get number of events for this session of all tracks, from this protocol
                end
                Nprop(kk,:) = N(kk,:)./session_sum; %divide each bin event count by the total number of events
            end
            N_sum = sum(N,1); %sum the event count of all sessions
            %Nprop_sum = N_sum./sum(num_cells_protocol(i,:)); %divide each bin event count by the total number of events
            Nprop_sum = sum(Nprop,1);
            event_count(i).(strcat(periods{p},'_std')) = std(N_sum);
            prop_event_count(i).(strcat(periods{p},'_std')) = std(Nprop_sum);
            rat_event_count(i).(strcat(periods{p})) = N;
            rat_prop_event_count(i).(strcat(periods{p})) = Nprop;

        else % for sleep periods
            for kk = 1 : length(this_protocol_idx) %for each session
                if merge_exposures == 1 %merge events from first and second exposure
                    if mod(t,2) == 0 %tracks 2 or 4
                        merged_events = sort([track_replay_events(this_protocol_idx(kk)).T2_normalized.(strcat(periods{p},'_norm_',epoch,'_times')) ...
                            track_replay_events(this_protocol_idx(kk)).T4_normalized.(strcat(periods{p},'_norm_',epoch,'_times'))]);
                    else %tracks 1 or 3
                        merged_events = sort([track_replay_events(this_protocol_idx(kk)).T1_normalized.(strcat(periods{p},'_norm_',epoch,'_times')) ...
                            track_replay_events(this_protocol_idx(kk)).T3_normalized.(strcat(periods{p},'_norm_',epoch,'_times'))]);
                    end
                    [N(kk,:),~] = histcounts(merged_events,bin_edges); %number of events per bin
                else
                    [N(kk,:),~] = histcounts([track_replay_events(this_protocol_idx(kk)).(sprintf('%s','T',num2str(t),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges);
                end
                session_events = [];
                for jj = 1 : size(num_events_protocol,2)
                    session_events = [session_events num_events_protocol{i,jj}(kk)];
                    session_sum = sum(session_events); % get number of events for this session of all tracks, from this protocol
                end
                Nprop(kk,:) = N(kk,:)./session_sum; %divide each bin event count by the total number of events
            end
            N_sum = sum(N,1);
            %Nprop_sum =  N_sum./sum(num_cells_protocol(i,:));
            Nprop_sum = sum(Nprop,1);
            event_count(i).(strcat(periods{p},'_std')) = std(N_sum);
            prop_event_count(i).(strcat(periods{p},'_std')) = std(Nprop_sum);
            rat_event_count(i).(strcat(periods{p})) = N;
            rat_prop_event_count(i).(strcat(periods{p})) = Nprop;
        end
        
        % Normalize event count based on the length of longest time period,by looking how many sessions contribute to each time bin
        bins_with_active_period = ones(1,length(bin_edges))*length(this_protocol_idx); % Set the count as if all periods had the same length
        
        for ii = 1 : length(this_protocol_idx)
            if period_time(this_protocol_idx(ii)).(strcat(periods{p})).length < longest_period_time % if this sessions is shorter than the longest period
                [~,idx] = min(abs(bin_edges - period_time(this_protocol_idx(ii)).(strcat(periods{p})).length)); %find bin indx where session is not active anymore
                bins_with_active_period(idx+1:end) = bins_with_active_period(idx+1:end) - 1;
            end
        end

        % Divide events of each bin by number of active periods in that bin
        event_count(i).(strcat(periods{p})) = N_sum./bins_with_active_period(1:end-1); %number of events per bin for this period
        protocol_event_count = [protocol_event_count event_count(i).(strcat(periods{p}))];  %concatante number of events for all periods
    
        prop_event_count(i).(strcat(periods{p})) = Nprop_sum; % fraction of events per bin for this period       
        protocol_prop_event_count = [protocol_prop_event_count Nprop_sum]; %concatante fraction of events for all periods   

        % Concatenate for each rat
        rat_protocol_prop_event_count = [rat_protocol_prop_event_count rat_prop_event_count(i).(strcat(periods{p}))];
        rat_protocol_event_count = [rat_protocol_event_count rat_event_count(i).(strcat(periods{p}))];
    end
    
    % Save for later plotting
    T(t).protocol_ID {i}= protocols(i);
    T(t).protocol_event_count{i} = protocol_event_count;
    T(t).event_count{i} = event_count(i);
    T(t).protocol_prop_event_count{i} = protocol_prop_event_count;
    T(t).prop_event_count{i} = prop_event_count(i);
    T(t).rat_event_count{i} = rat_event_count(i);
    T(t).rat_prop_event_count {i} = rat_prop_event_count(i);
    T(t).rat_protocol_prop_event_count{i} = rat_protocol_prop_event_count;
    T(t).rat_protocol_event_count {i} = rat_protocol_event_count;

    % FOR EACH TRACK, PLOT EACH PROTOCOL AS A SUBPLOT
    figure(f(t*10))
    f(t*10).Name = strcat(plot_type,'- Normalized replay events across time - Track',num2str(t) ,'-',epoch);
    ax(i) = subplot(length(protocols),1,i);
    if strcmp(plot_type,'sum')
        % Add standard deviation as shade
        x = 1:numel(protocol_event_count);
        shade1 = protocol_event_count + T(t).event_count{1,i}.INTER_post_std;
        shade2 = protocol_event_count - T(t).event_count{1,i}.INTER_post_std;
        x2 = [x,fliplr(x)];
        inBetween = [shade1,fliplr(shade2)];
        h=fill(x2,inBetween,PP.T2(i,:));
        set(h,'facealpha',0.2,'LineStyle','none')
        hold on
        plot(smooth(protocol_event_count),'LineWidth',2,'Color',PP.T2(i,:)) %sum
        
    elseif strcmp(plot_type,'cumsum')
        plot(cumsum(protocol_event_count),'LineWidth',2,'Color',PP.T2(i,:)) % cumulative sum
    end
    xlabel('Binned time (min)'); ylabel('Mean # events')
    if protocols(i) == 30
        title('Control - 16 Laps x 30 min')
    else
        title(strcat('16x',num2str(protocols(i))),'FontSize',15)
    end
    box off
    hold on 
    
    % Find limits of each period based on the number of bins
    if strcmp(epoch,'sleep')
        pre_n = length(event_count(i).PRE); %adds 1 because histcount substracts 1
        sleeppot1_n = pre_n + length(event_count(i).sleep_pot1);  
        line([pre_n pre_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % PRE limit
        line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % sleep pot 1 end limit
       
        if any(ismember(periods,'T3'))  % if more than 2 tracks
            INTER_n = sleeppot1_n + length(event_count(i).INTER_post);
            sleeppot2_n = INTER_n + length(event_count(i).sleep_pot2);
            line([INTER_n INTER_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % inter post 2 end limit
            line([sleeppot2_n sleeppot2_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % sleep pot 2 end limit
        end

    else
        pre_n = length(event_count(i).PRE); %adds 1 because histcount substracts 1
        T1_n = pre_n + length(event_count(i).T1);
        sleeppot1_n = T1_n + length(event_count(i).sleep_pot1);
        T2_n =  sleeppot1_n + length(event_count(i).T2);
        line([pre_n pre_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % PRE limit
        line([T1_n T1_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % track 1 end limit
        line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % sleep pot 1 end limit
        line([T2_n T2_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % track 2 end limit
        
        if any(ismember(periods,'T3')) % if more than 2 tracks
            INTER_n = T2_n + length(event_count(i).INTER_post);
            T3_n = INTER_n + length(event_count(i).T3);
            sleeppot2_n = T3_n + length(event_count(i).sleep_pot2);
            T4_n = sleeppot2_n + length(event_count(i).T4);
            line([INTER_n INTER_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % inter post 2 end limit
            line([T3_n T3_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % track3 end limit
            line([sleeppot2_n sleeppot2_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % sleep pot 2 end limit
            line([T4_n T4_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % track4 end limit
        end
    end
    
    
    end
    
    figure(f(t*10))
    if i == 5
        linkaxes([ax(1),ax(2),ax(3),ax(4),ax(5)],'x')
    elseif i == 2
        linkaxes([ax(1),ax(2)],'x')
    end
end

%%%%% PLOT PER RAT
for rat = 1 : 4 %for each rat
    f(rat*5) = figure('units','normalized','outerposition',[0 0 1 1],'Color','w','Name',['Rat ' num2str(rat) '- normalised replay events across time for all tracks -' epoch])
    tiledlayout(5,1)
    for j = 1: length(T) % for each track
        for z = 1 : length(T(j).protocol_event_count) %for each protocol
            ax(z) = subplot(length(protocols),1,z);
            hold on
            pl(j) = plot(smooth(T(j).rat_protocol_event_count{1,z}(rat,:)),'LineWidth',PP.Linewidth{j},'Color',PP.P(z).colorT(j,:),'LineStyle',PP.Linestyle{j}); % sum
            box off
            set(gca,'FontSize',15)
            if j == 1
                xlabel('Binned time (min)','FontSize',14); ylabel('Mean # events','FontSize',14)
                if protocols(i) == 30
                    title('Control - 16 Laps x 30 min')
                else
                    title(strcat('16x',num2str(protocols(z))),'FontSize',15)
                end
                % Find limits of each period based on the number of bins
                if strcmp(epoch,'sleep')
                    pre_n = length(T(j).event_count{z}.PRE); %adds 1 because histcount substracts 1
                    sleeppot1_n = pre_n + length(T(j).event_count{z}.sleep_pot1);
                    line([pre_n pre_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % PRE limit
                    line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % sleep pot 1 end limit

                    if any(ismember(periods,'T3'))  %if more than 2 tracks
                        INTER_n = sleeppot1_n + length(T(j).event_count{z}.INTER_post);
                        sleeppot2_n = INTER_n + length(T(j).event_count{z}.sleep_pot2);
                        line([INTER_n INTER_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % inter post 2 end limit
                        line([sleeppot2_n sleeppot2_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % sleep pot 2 end limit
                    end

                else
                    % Find limits of each period based on the number of bins
                    pre_n = length(T(j).event_count{z}.PRE); %adds 1 because histcount substracts 1
                    T1_n = pre_n + length(T(j).event_count{z}.T1);
                    sleeppot1_n = T1_n + length(T(j).event_count{z}.sleep_pot1);
                    T2_n =  sleeppot1_n + length(T(j).event_count{z}.T2);
                    line([pre_n pre_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % PRE limit
                    line([T1_n T1_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % track 1 end limit
                    line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % sleep pot 1 end limit
                    line([T2_n T2_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % track 2 end limit

                    if any(ismember(periods,'T3'))  %if more than 2 tracks
                        INTER_n = T2_n + length(T(j).event_count{z}.INTER_post);
                        T3_n = INTER_n + length(T(j).event_count{z}.T3);
                        sleeppot2_n = T3_n + length(T(j).event_count{z}.sleep_pot2);
                        T4_n = sleeppot2_n + length(T(j).event_count{z}.T4);
                        line([INTER_n INTER_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % inter post 2 end limit
                        line([T3_n T3_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % track3 end limit
                        line([sleeppot2_n sleeppot2_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % sleep pot 2 end limit
                        line([T4_n T4_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % track4 end limit
                    end
                end
            end
        end
    end
end

% PLOT EACH PROTOCOL AS A SUBPLOT WITH ALL THE TRACKS OVERLAPPED
figure(f1)
f1.Name = strcat(plot_type,'-Normalized replay events across time for all tracks -',epoch);

for j = 1: length(T) % for each track
    for z = 1 : length(T(j).protocol_event_count) %for each protocol
        ax(z) = subplot(length(protocols),1,z);
        hold on
        if strcmp(plot_type,'sum')
%             % Add standard deviation as shade
%             x = 1:numel(cell2mat(T(j).protocol_event_count(z)));
%             shade1 = cell2mat(T(j).protocol_event_count(z)) + T(j).event_count{1,z}.INTER_post_std;
%             shade2 = cell2mat(T(j).protocol_event_count(z)) - T(j).event_count{1,z}.INTER_post_std;
%             x2 = [x,fliplr(x)];
%             inBetween = [shade1,fliplr(shade2)];
%             h=fill(x2,inBetween,PP.T2(i,:));
%             set(h,'facealpha',0.2,'LineStyle','none')
%             hold on
            pl(j) = plot(smooth(cell2mat(T(j).protocol_event_count(z))),'LineWidth',PP.Linewidth{j},'Color',PP.P(z).colorT(j,:),'LineStyle',PP.Linestyle{j}); % sum
        elseif strcmp(plot_type,'cumsum')
            pl(j) = plot(cumsum(cell2mat(T(j).protocol_event_count(z))),'LineWidth',PP.Linewidth{j},'Color',PP.P(z).colorT(j,:),'LineStyle',PP.Linestyle{j}); % cumulative sum
        end
        hold on
        box off
        a = gca;
        a.FontSize = 15;
        
        if j == 1
            xlabel('Binned time (min)','FontSize',14); ylabel('Mean # events','FontSize',14)
            if protocols(i) == 30
                title('Control - 16 Laps x 30 min')
            else
                title(strcat('16x',num2str(protocols(z))),'FontSize',15)
            end
            % Find limits of each period based on the number of bins
            if strcmp(epoch,'sleep')
                pre_n = length(T(j).event_count{z}.PRE); %adds 1 because histcount substracts 1
                sleeppot1_n = pre_n + length(T(j).event_count{z}.sleep_pot1);
                line([pre_n pre_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % PRE limit
                line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % sleep pot 1 end limit
                
                if any(ismember(periods,'T3'))  %if more than 2 tracks
                    INTER_n = sleeppot1_n + length(T(j).event_count{z}.INTER_post);
                    sleeppot2_n = INTER_n + length(T(j).event_count{z}.sleep_pot2);
                    line([INTER_n INTER_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % inter post 2 end limit
                    line([sleeppot2_n sleeppot2_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % sleep pot 2 end limit
                end
                
            else
                % Find limits of each period based on the number of bins
                pre_n = length(T(j).event_count{z}.PRE); %adds 1 because histcount substracts 1
                T1_n = pre_n + length(T(j).event_count{z}.T1);
                sleeppot1_n = T1_n + length(T(j).event_count{z}.sleep_pot1);
                T2_n =  sleeppot1_n + length(T(j).event_count{z}.T2);
                line([pre_n pre_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % PRE limit
                line([T1_n T1_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % track 1 end limit
                line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % sleep pot 1 end limit
                line([T2_n T2_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % track 2 end limit
                
                if any(ismember(periods,'T3'))  %if more than 2 tracks
                    INTER_n = T2_n + length(T(j).event_count{z}.INTER_post);
                    T3_n = INTER_n + length(T(j).event_count{z}.T3);
                    sleeppot2_n = T3_n + length(T(j).event_count{z}.sleep_pot2);
                    T4_n = sleeppot2_n + length(T(j).event_count{z}.T4);
                    line([INTER_n INTER_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % inter post 2 end limit
                    line([T3_n T3_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % track3 end limit
                    line([sleeppot2_n sleeppot2_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % sleep pot 2 end limit
                    line([T4_n T4_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % track4 end limit
                end
            end
        end
    end
end
    if z == 5
        linkaxes([ax(1),ax(2),ax(3),ax(4),ax(5)],'x')
    elseif z == 2
        linkaxes([ax(1),ax(2)],'xy')
    end
    if  isfield(track_replay_events,'T3') & merge_exposures ~= 1
        legend([pl(1),pl(2),pl(3),pl(4)],{'Track1','Track2','Track3','Track4'},'Position',[0.91 0.82 0.05 0.1],'FontSize',10)
    else
        legend([pl(1),pl(2)],{'Track1','Track2'},'Position',[0.91 0.82 0.05 0.1],'FontSize',10)
    end
    
        
% PROPORTION OF EVENTS PER TRACK (fraction of total events)
% Plot each protocol as a subplot with all the tracks overlapped

figure(f2)
f2.Name = strcat(plot_type,'-Proportion of normalized replay events across time for all tracks -',epoch);

for j = 1: length(T) % for each track
    for z = 1 : length(T(j).protocol_prop_event_count) %for each protocol
        ax(z) = subplot(length(protocols),1,z);
        hold on
        if strcmp(plot_type,'sum')
            pl(j) = plot(smooth(cell2mat(T(j).protocol_prop_event_count(z))),'LineWidth',PP.Linewidth{j},'Color',PP.P(z).colorT(j,:),'LineStyle',PP.Linestyle{j});  % sum
        elseif strcmp(plot_type,'cumsum')
            pl(j) = plot(cumsum(cell2mat(T(j).protocol_prop_event_count(z))),'LineWidth',PP.Linewidth{j},'Color',PP.P(z).colorT(j,:),'LineStyle',PP.Linestyle{j}); % cumulative sum
        end
        hold on
        box off
        a=gca;
        a.FontSize = 15;

        if j == 1
            xlabel('Binned time (min)','FontSize',15); ylabel('Norm proportion events','FontSize',15)
            if protocols(i) == 30
                title('Control - 16 Laps x 30 min')
            else
                title(strcat('16x',num2str(protocols(z))),'FontSize',15)
            end
            % Find limits of each period based on the number of bins
            if strcmp(epoch,'sleep')
                pre_n = length(T(j).event_count{z}.PRE); %adds 1 because histcount substracts 1
                sleeppot1_n = pre_n + length(T(j).event_count{z}.sleep_pot1);
                line([pre_n pre_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % PRE limit
                line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % sleep pot 1 end limit
                
                if any(ismember(periods,'T3'))  %if more than 2 tracks
                    INTER_n = sleeppot1_n + length(T(j).event_count{z}.INTER_post);
                    sleeppot2_n = INTER_n + length(T(j).event_count{z}.sleep_pot2);
                    line([INTER_n INTER_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3) % inter post 2 end limit
                    line([sleeppot2_n sleeppot2_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % sleep pot 2 end limit
                end
                
            else
                % Find limits of each period based on the number of bins
                pre_n = length(T(j).event_count{z}.PRE); %adds 1 because histcount substracts 1
                T1_n = pre_n + length(T(j).event_count{z}.T1);
                sleeppot1_n = T1_n + length(T(j).event_count{z}.sleep_pot1);
                T2_n =  sleeppot1_n + length(T(j).event_count{z}.T2);
                line([pre_n pre_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % PRE limit
                line([T1_n T1_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % track 1 end limit
                line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % sleep pot 1 end limit
                line([T2_n T2_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % track 2 end limit
                
                if any(ismember(periods,'T3'))  %if more than 2 tracks
                    INTER_n = T2_n + length(T(j).event_count{z}.INTER_post);
                    T3_n = INTER_n + length(T(j).event_count{z}.T3);
                    sleeppot2_n = T3_n + length(T(j).event_count{z}.sleep_pot2);
                    T4_n = sleeppot2_n + length(T(j).event_count{z}.T4);
                    line([INTER_n INTER_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % inter post 2 end limit
                    line([T3_n T3_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3) % track3 end limit
                    line([sleeppot2_n sleeppot2_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % sleep pot 2 end limit
                    line([T4_n T4_n],[min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',3)  % track4 end limit
                end
            end
        end
    end

end
    if z == 5
        linkaxes([ax(1),ax(2),ax(3),ax(4),ax(5)],'xy')

    elseif i == 2
        linkaxes([ax(1),ax(2)],'xy')
    end
    if isfield(track_replay_events,'T3') & merge_exposures ~= 1
        legend([pl(1),pl(2),pl(3),pl(4)],{'Track1','Track2','Track3','Track4'},'Position',[0.91 0.82 0.05 0.1],'FontSize',10)
    else
        legend([pl(1),pl(2)],{'Track1','Track2'},'Position',[0.91 0.82 0.05 0.1],'FontSize',10)
    end


    %%% PROPORTION TO 100% of T1/T3 events and T2/T4 events

    if strcmp(data_type,'main')
    for j = 1: length(T)/2 % for T1 and T2

        f(33*j) = figure;
        set(f(33*j),'Units','normalized','Color','w','Name',['Track ' num2str(j) ' proprotion of exposure events']);
        tiledlayout(5,1)
        f(10*j) = figure;
        set(f(10*j),'Units','normalized','Color','w','Name',['Track ' num2str(j) ' proprotion of exposure events - barplot']);
        tiledlayout('flow')

        for z = 1 : length(T(j).protocol_event_count) %for each protocol
            figure(f(33*j))
            nexttile
            hold on
            y = [smooth(T(j).protocol_event_count{z}./(T(j).protocol_event_count{z}+T(j+2).protocol_event_count{z})),...
                smooth(T(j+2).protocol_event_count{z}./(T(j).protocol_event_count{z}+T(j+2).protocol_event_count{z}))];
            thisax = area(y);
            if j == 1
                [thisax(1:2).FaceColor] = deal(PP.T1);
                [thisax(1:2).EdgeColor] = deal(PP.T1);
                thisax(2).FaceAlpha = .5;
                thisax(2).EdgeAlpha = .5;
            else
                [thisax(1:2).FaceColor] = deal(PP.T2(z,:));
                [thisax(1:2).EdgeColor] = deal(PP.T2(z,:));
                thisax(2).FaceAlpha = .5;
                thisax(2).EdgeAlpha = .5;
            end
            set(gca,'FontSize',15,'box','off','YLim',[0 1],'TickDir','out','TickLength',[.01 0.005],'LineWidth',1.5,'xlim',[0 length(y)])
            ylabel(gca,['Proportion of T' num2str(j) ' and R-T' num2str(j)])
            xlabel(gca,'Binned time (min)')
            title(['Protocol ' num2str(protocols(z))])
            % Find limits of each period based on the number of bins
            if strcmp(epoch,'sleep')
                pre_n = length(T(j).event_count{z}.PRE); %adds 1 because histcount substracts 1
                sleeppot1_n = pre_n + length(T(j).event_count{z}.sleep_pot1);
                line([pre_n pre_n],[min(ylim) max(ylim)],'Color','w','LineWidth',3)  % PRE limit
                line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color','w','LineWidth',3)  % sleep pot 1 end limit

                if any(ismember(periods,'T3')) %if more than 2 tracks
                    INTER_n = sleeppot1_n + length(T(j).event_count{z}.INTER_post);
                    sleeppot2_n = INTER_n + length(T(j).event_count{z}.sleep_pot2);
                    line([INTER_n INTER_n],[min(ylim) max(ylim)],'Color','w','LineWidth',3) % inter post 2 end limit
                    line([sleeppot2_n sleeppot2_n],[min(ylim) max(ylim)],'Color','w','LineWidth',3)  % sleep pot 2 end limit
                end

            else
                % Find limits of each period based on the number of bins
                pre_n = length(T(j).event_count{z}.PRE); %adds 1 because histcount substracts 1
                T1_n = pre_n + length(T(j).event_count{z}.T1);
                sleeppot1_n = T1_n + length(T(j).event_count{z}.sleep_pot1);
                T2_n =  sleeppot1_n + length(T(j).event_count{z}.T2);
                line([pre_n pre_n],[min(ylim) max(ylim)],'Color','w','LineWidth',3)  % PRE limit
                line([T1_n T1_n],[min(ylim) max(ylim)],'Color','w','LineWidth',3)  % track 1 end limit
                line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color','w','LineWidth',3)  % sleep pot 1 end limit
                line([T2_n T2_n],[min(ylim) max(ylim)],'Color','w','LineWidth',3)  % track 2 end limit
                all_time_idx = [pre_n T1_n sleeppot1_n T2_n];
                if any(ismember(periods,'T3'))  %if more than 2 tracks
                    INTER_n = T2_n + length(T(j).event_count{z}.INTER_post);
                    T3_n = INTER_n + length(T(j).event_count{z}.T3);
                    sleeppot2_n = T3_n + length(T(j).event_count{z}.sleep_pot2);
                    T4_n = sleeppot2_n + length(T(j).event_count{z}.T4);
                    line([INTER_n INTER_n],[min(ylim) max(ylim)],'Color','w','LineWidth',3)  % inter post 2 end limit
                    line([T3_n T3_n],[min(ylim) max(ylim)],'Color','w','LineWidth',3) % track3 end limit
                    line([sleeppot2_n sleeppot2_n],[min(ylim) max(ylim)],'Color','w','LineWidth',3)  % sleep pot 2 end limit
                    line([T4_n T4_n],[min(ylim) max(ylim)],'Color','w','LineWidth',3)  % track4 end limit
                    all_time_idx =[all_time_idx INTER_n T3_n sleeppot2_n T4_n];
                end
            end
            
            
            figure(f(10*j))
            nexttile
            all_time_idx = [1 all_time_idx length(y)];
            for per = 2 : length(all_time_idx)
                hold on
                b = bar(per-1,[mean(y(all_time_idx(per-1):all_time_idx(per),1)) mean(y(all_time_idx(per-1):all_time_idx(per),2))]);
                if j == 1
                    set(b,'EdgeColor',PP.T1,'FaceColor',PP.T1)
                    set(b(2),'FaceAlpha',.5,'EdgeAlpha',.5)
                else
                    set(b,'EdgeColor',PP.T2(z,:),'FaceColor',PP.T2(z,:))
                    set(b(2),'FaceAlpha',.5,'EdgeAlpha',.5)
                end
            end
            set(gca,'FontSize',15,'box','off','YLim',[0 1],'TickDir','out','TickLength',[.01 0.005],'LineWidth',1.5)
            ylabel(gca,['Proportion of T' num2str(j) ' and R-T' num2str(j)])
            xticks(1:9)
            xticklabels(gca,{'PRE','T1','R1','T2','POST1','RT1','R2','RT2','POST2'})
            title(['Protocol ' num2str(protocols(z))])
            all_time_idx = [];
        end
    end
    end

end
