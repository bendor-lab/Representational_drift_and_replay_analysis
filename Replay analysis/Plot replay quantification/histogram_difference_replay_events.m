
function histogram_difference_replay_events(plot_type,epoch)
% Plots the difference of replay events between tracks over time. Tests different types of comparisons, set in the code.
% Histogram is calculated as the difference of replay events between tracks for each experiment (always within a protcol), 
    %sum the differences of all experiments and divided by number of active sessions. 
% INPUT: 
    %plot_type: 'sum' for showing normal histogram; 'cumsum' for showing cumulative sum of events
    %epoch: 'sleep' for only sleep replay,'awake' for only awake replay, or 'ALL' for plotting both together. 
          % 'sleep' assumes that rats are always awake during track periods, and therefore excludes those periods when plotting 


% Parameters
load('extracted_replay_plotting_info.mat')
load('extracted_time_periods_replay.mat')

bin_width = 60; %1 min

% Set periods to be analysed
if strcmp(epoch,'ALL') | strcmp(epoch,'awake') & isfield(track_replay_events,'T3')
    periods = [{'PRE'},{'T1'},{'sleep_pot1'},{'T2'},{'INTER_post'},{'T3'},{'sleep_pot2'},{'T4'},{'FINAL_post'}];
elseif strcmp(epoch,'sleep')  & isfield(track_replay_events,'T3')
    periods = [{'PRE'},{'sleep_pot1'},{'INTER_post'},{'sleep_pot2'},{'FINAL_post'}];
elseif strcmp(epoch,'ALL') | strcmp(epoch,'awake') & ~isfield(track_replay_events,'T3') % 2 tracks only
    periods = [{'PRE'},{'T1'},{'sleep_pot1'},{'T2'},{'FINAL_post'}];
else
    periods = [{'PRE'},{'sleep_pot1'},{'FINAL_post'}];
end

% Set comparison types
if isfield(track_replay_events,'T3')
    comparisons = {[1,2],[3,4],[1,3,2,4],[1,3],[2,4]}; %types of comparisons to analysed (value = track num)
else
    comparisons = {[1,2]}; %types of comparisons to analysed (value = track num)
end

PP = plotting_parameters;

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

for c = 1 : length(comparisons) % For each type of comparison
    f(c*10) = figure('units','normalized','outerposition',[0 0 1 1]);
    track = [];
    for j = 1 : length(cell2mat(comparisons(c))) %find how many tracks are being compared
        comp = cell2mat(comparisons(c));
        track(j) =comp(j);
    end
    
    % For each protocol (8,4,3,2 or 1)
    for i = 1 : length(protocols)
    
    this_protocol_idx = find(t2 == protocols(i)); %find indices of sessions from the current protocol
    protocol_event_count = [];
    
    for p = 1 : length(periods) %for each time period (sleep or run) within the protocol
        
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
        
        this_period_events = [];

        % For each protocol session, find number of events for each time bin (for this period), and substract from the other track to which is being compared to
        for idx = 1 : length(this_protocol_idx)
            if length(cell2mat(comparisons(c))) == 2
                if strfind(periods{p},'T') == 1 % for track events
                    [N1,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(1)),'_normalized')).(strcat(periods{p},'_norm_times'))],bin_edges); %events track 1
                    [N2,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(2)),'_normalized')).(strcat(periods{p},'_norm_times'))],bin_edges); %events track 2
                    this_period_events = [this_period_events; N1-N2]; % substract events track2 from track 1
                else % for sleep events
                    [N1,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(1)),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges);
                    [N2,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(2)),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges);
                    this_period_events = [this_period_events; N1-N2];                   
                end
            else % if comparing 4 tracks
                if strfind(periods{p},'T') == 1 % for track events
                    [N1,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(1)),'_normalized')).(strcat(periods{p},'_norm_times'))],bin_edges); %events track 1
                    [N2,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(2)),'_normalized')).(strcat(periods{p},'_norm_times'))],bin_edges); %events track 3
                    [N3,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(3)),'_normalized')).(strcat(periods{p},'_norm_times'))],bin_edges); %events track 2
                    [N4,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(4)),'_normalized')).(strcat(periods{p},'_norm_times'))],bin_edges); %events track 4
                    this_period_events = [this_period_events; (N1+N2)-(N3+N4)]; % add events from first and second exposure, and then susbtract from the other track
                else
                    [N1,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(1)),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges);
                    [N2,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(2)),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges);
                    [N3,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(3)),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges);
                    [N4,~] = histcounts([track_replay_events(this_protocol_idx(idx)).(sprintf('%s','T',num2str(track(4)),'_normalized')).(strcat(periods{p},'_norm_',epoch,'_times'))],bin_edges);
                    this_period_events = [this_period_events; (N1+N2)-(N3+N4)];
                end
            end
        end
        
        % Normalize event count based on the length of longest time period,by looking how many sessions contribute to each time bin
        bins_with_active_period = ones(1,length(bin_edges))*length(this_protocol_idx); % Set the count as if all periods had the same length        
        for ii = 1 : length(this_protocol_idx)
            if period_time(this_protocol_idx(ii)).(strcat(periods{p})).length < longest_period_time % if this sessions is shorter than the longest period
                [~,idx] = min(abs(bin_edges - period_time(this_protocol_idx(ii)).(strcat(periods{p})).length)); %find bin indx where session is not active anymore
                bins_with_active_period(idx+1:end) = bins_with_active_period(idx+1:end) - 1;
            end
        end
        
        % Sum events of all sessions of this protocol & divide events of each bin by number of active periods in that bin
        N = sum(this_period_events);  
        event_count(i).(strcat(cell2mat(periods(p)))) = N./bins_with_active_period(1:end-1);       
        protocol_event_count = [protocol_event_count event_count(i).(strcat(cell2mat(periods(p))))];        

    end
    
    % Save for later plotting (each T row will be a comparison)
    T(c).protocol_event_count{i} = protocol_event_count;
    T(c).event_count{i} = event_count(i);
    
    % FOR EACH COMPARISON, PLOT EACH PROTOCOL AS A SUBPLOT
    figure(f(c*10))
    f(c*10).Name = strcat(plot_type,' - Replay events difference between tracks - ',num2str(cell2mat(comparisons(c))),'across time - ',epoch);
    ax(i) = subplot(length(protocols),1,i);

    switch num2str(track)
        case num2str([1,2])
            col = PP.grayscale(5,:);            
        case num2str([3,4])
            col = PP.grayscale(9,:);            
        case num2str([1,3,2,4])
            col = PP.grayscale(13,:);            
        case num2str([1,3])
            col = PP.T1;
        case num2str([2,4])
            col = PP.T2(i,:);
    end
    
    if strcmp(plot_type,'sum')
        plot(smooth(protocol_event_count),'LineWidth',2,'Color',col) %sum
    elseif strcmp(plot_type,'cumsum')
        plot(cumsum(protocol_event_count),'LineWidth',2,'Color',col) % cumulative sum
    end
    xlabel('Binned time (min)'); ylabel('Mean replay events diff')
    if protocols(i) == 30
        title('Control - 16 Laps x 30 min')
    else
        title(strcat('Protocol - ',num2str(protocols(i))))
    end
    box off
    hold on 
    
    % Find limits of each period based on the number of bins
    if strcmp(epoch,'sleep')
        pre_n = length(event_count(i).PRE); %adds 1 because histcount substracts 1
        sleeppot1_n = pre_n + length(event_count(i).sleep_pot1);  
        line([pre_n pre_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % PRE limit
        line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % sleep pot 1 end limit
       
        if isfield(track_replay_events,'T3') % if more than 2 tracks
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
        
        if isfield(track_replay_events,'T3') % if more than 2 tracks
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
    
    line([min(xlim) max(xlim)],[0 0],'Color','k','LineWidth',1,'LineStyle','--')  % to separate between tracks
    
    end
    
    figure(f(c*10))
    if i == 5
        linkaxes([ax(1),ax(2),ax(3),ax(4),ax(5)],'x','y')
    elseif i == 2
        linkaxes([ax(1),ax(2)],'x','y')
    end 

end

% PLOT ONLY IF MORE THAN 2 TRACKS: Plots comparisons 1 vs 2 ; 3 vs 4 ;and 1+3 vs 2+4
if isfield(track_replay_events,'T3')
    f1 = figure('units','normalized','outerposition',[0 0 1 1]);
    f1.Name = strcat(plot_type,' - Replay events difference between tracks - ',num2str(cell2mat(comparisons(1))),'/',num2str(cell2mat(comparisons(2))),'&',num2str(cell2mat(comparisons(3))),'across time - ',epoch);
    
    for j = 1: 3
        switch j
            case 1
                track = [1,2];
            case 2
                track = [3,4];
            case 3
                track = [1,3,2,4];
        end
        
        for z = 1 : length(T(j).protocol_event_count)
            ax(z) = subplot(length(protocols),1,z);
            hold on
            switch num2str(track)
                case num2str([1,2])
                    col = PP.grayscale(5,:);
                case num2str([3,4])
                    col = PP.grayscale(9,:);
                case num2str([1,3,2,4])
                    col = PP.grayscale(13,:);
            end
            
            if strcmp(plot_type,'sum')
                pl(j) = plot(smooth(cell2mat(T(j).protocol_event_count(z))),'LineWidth',PP.Linewidth{j},'Color',col,'LineStyle',PP.Linestyle{j}); % sum
            elseif strcmp(plot_type,'cumsum')
                pl(j) = plot(cumsum(cell2mat(T(j).protocol_event_count(z))),'LineWidth',PP.Linewidth{j},'Color',col,'LineStyle',PP.Linestyle{j}); % cumulative sum
            end
            hold on
            box off
            if j == 1
                xlabel('Binned time (min)','Fontsize',9); ylabel('Replay events diff')
                if protocols(i) == 30
                    title('Control - 16 Laps x 30 min')
                else
                    title(strcat('Protocol - ',num2str(protocols(z))),'FontSize',15)
                end
                
                % Find limits of each period based on the number of bins
                if strcmp(epoch,'sleep')
                    pre_n = length(T(j).event_count{z}.PRE); %adds 1 because histcount substracts 1
                    sleeppot1_n = pre_n + length(T(j).event_count{z}.sleep_pot1);
                    line([pre_n pre_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % PRE limit
                    line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % sleep pot 1 end limit
                    
                    if isfield(track_replay_events,'T3') %if more than 2 tracks
                        INTER_n = sleeppot1_n + length(T(j).event_count{z}.INTER_post);
                        sleeppot2_n = INTER_n + length(T(j).event_count{z}.sleep_pot2);
                        line([INTER_n INTER_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % inter post 2 end limit
                        line([sleeppot2_n sleeppot2_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % sleep pot 2 end limit
                    end
                    
                else
                    % Find limits of each period based on the number of bins
                    pre_n = length(T(j).event_count{z}.PRE); %adds 1 because histcount substracts 1
                    T1_n = pre_n + length(T(j).event_count{z}.T1);
                    sleeppot1_n = T1_n + length(T(j).event_count{z}.sleep_pot1);
                    T2_n =  sleeppot1_n + length(T(j).event_count{z}.T2);
                    line([pre_n pre_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % PRE limit
                    line([T1_n T1_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % track 1 end limit
                    line([sleeppot1_n sleeppot1_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % sleep pot 1 end limit
                    line([T2_n T2_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % track 2 end limit
                    
                    if isfield(track_replay_events,'T3') %if more than 2 tracks
                        INTER_n = T2_n + length(T(j).event_count{z}.INTER_post);
                        T3_n = INTER_n + length(T(j).event_count{z}.T3);
                        sleeppot2_n = T3_n + length(T(j).event_count{z}.sleep_pot2);
                        T4_n = sleeppot2_n + length(T(j).event_count{z}.T4);
                        line([INTER_n INTER_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % inter post 2 end limit
                        line([T3_n T3_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % track3 end limit
                        line([sleeppot2_n sleeppot2_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % sleep pot 2 end limit
                        line([T4_n T4_n],[min(ylim) max(ylim)],'Color','r','LineWidth',1)  % track4 end limit
                    end
                    
                end
                
                line([min(xlim) max(xlim)],[0 0],'Color','k','LineWidth',1,'LineStyle','--')  % to separate between tracks
                
            end
        end
    end
    if z == 5
        linkaxes([ax(1),ax(2),ax(3),ax(4),ax(5)],'x')
    elseif z == 2
        linkaxes([ax(1),ax(2)],'x')
    end
    legend([pl(1),pl(2),pl(3)],{'T1 vs T2','T3 vs T4','T1+T3 vs T2+T4'},'Position',[0.91 0.82 0.05 0.1],'FontSize',10)
    
    
end
end
