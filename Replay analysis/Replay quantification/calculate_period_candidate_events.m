function calculate_period_candidate_events(data_type)
% Calculate number of candidate events for each period within session, and
% for each bin within a period.
% Candidate events have passed ripple threshold


% Load name of data folders
if strcmp(data_type,'main')
    sessions = data_folders;
    session_names = fieldnames(sessions);
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
elseif strcmp(data_type,'speed')
    sessions = speed_data_folders;
    session_names = fieldnames(sessions);
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Speed';
elseif strcmp(data_type,'Only first exposure')
    sessions = data_folders; %main data
    session_names = fieldnames(sessions);
    data_sessions = arrayfun(@(y) arrayfun(@(x) append(sessions.(sprintf('%s',session_names{y})){x},'\Bayesian controls\Only first exposure' ),...
        1:length(sessions.(sprintf('%s',session_names{y}))),'UniformOutput',0),1:length(session_names),'UniformOutput',0);
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only first exposure';
elseif strcmp(data_type,'Only re-exposure')
    sessions = data_folders; %main data
    session_names = fieldnames(sessions);
    data_sessions = arrayfun(@(y) arrayfun(@(x) append(sessions.(sprintf('%s',session_names{y})){x},'\Bayesian controls\Only re-exposure' ),...
        1:length(sessions.(sprintf('%s',session_names{y}))),'UniformOutput',0),1:length(session_names),'UniformOutput',0);
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only re-exposure';
end
load([path '\extracted_time_periods_replay.mat'])
bin_width = 60; %1 min

epochs = {'sleep','awake','merged'};

for ep  = 1 : length(epochs)
    % Find indices for each type of protocol
    t2 = [];
    for s = 1 : length(period_time)
        name = cell2mat(period_time(s).sessions_order);
        t2 = [t2 str2num(name(end))];
    end
    protocols = unique(t2,'stable');
    
    % Set periods to be analysed
    if strcmp(epochs{ep},'awake')
        if isfield(period_time,'T3')
            periods = [{'PRE'},{'T1'},{'sleep_pot1'},{'T2'},{'INTER_post'},{'T3'},{'sleep_pot2'},{'T4'},{'FINAL_post'}];
        else  % 2 tracks only
            periods = [{'PRE'},{'T1'},{'sleep_pot1'},{'T2'},{'FINAL_post'}];
        end
    else
        % Set periods to be analysed
        if isfield(period_time,'T3')
            periods = [{'PRE'},{'sleep_pot1'},{'INTER_post'},{'sleep_pot2'},{'FINAL_post'}];
        else  % 2 tracks only
            periods = [{'PRE'},{'sleep_pot1'},{'FINAL_post'}];
        end
    end

    % For each protocol (8,4,3,2 or 1)
    for i = 1 : length(protocols)
        if strfind(path,'Bayesian Controls') ~= 0
            folders = data_sessions{i};
        else
            folders = sessions.(sprintf('%s',session_names{i}));
        end
        this_protocol_idx = find(t2 == protocols(i)); %find indices of sessions from the current protocol

        for p = 1 : length(periods) %for each time period (sleep or run) within the protocol
            if strcmp(epochs{ep},'sleep')
                if isempty(period_time(this_protocol_idx(1)).(strcat(periods{p})).(strcat(epochs{ep},'_cumulative_time')))
                    continue
                end
            end

            N = [];
            % find the longest period between these protocol sessions
            mt = [];
            for ii = 1 : length (this_protocol_idx)
                if strcmp(epochs{ep},'merged')
                    mt = [mt; period_time(this_protocol_idx(ii)).(strcat(periods{p})).length];
                else
                    if strfind(periods{p},'T') == 1
                        if ~isempty(period_time(this_protocol_idx(ii)).(strcat(periods{p})).cumulative_times)
                            mt = [mt; max(period_time(this_protocol_idx(ii)).(strcat(periods{p})).cumulative_times,[],'all')];
                        end
                    else
                        if ~isempty(period_time(this_protocol_idx(ii)).(strcat(periods{p})).(strcat(epochs{ep},'_cumulative_time')))
                            mt = [mt; max(period_time(this_protocol_idx(ii)).(strcat(periods{p})).(strcat(epochs{ep},'_cumulative_time')),[],'all')];
                        end
                    end
                end
            end
            longest_period_time = max(mt);
            if longest_period_time > 0 & longest_period_time < bin_width %if this period only has 1 bin, that is smaller than 60 sec
                bin_edges = 0:longest_period_time:longest_period_time;
                disp(strcat('Time bin for :', periods{p},' is smaller than 1 min'))
            else
                bin_edges = 0:bin_width:longest_period_time; %bin the time based on the longest period
            end


            % For these protocol sessions, find number of events for each time bin (for this period)
            for ii = 1 : length (this_protocol_idx)
                cd(folders{ii})
                load('significant_replay_events_wcorr.mat')
                time_limits = period_time(this_protocol_idx(ii)).(sprintf('%s',periods{p})).time_limits;

                if ep == 2
                    period_candidate_events(this_protocol_idx(ii)).session = period_time(this_protocol_idx(ii)).sessions_order;
                    period_candidate_events(this_protocol_idx(ii)).(sprintf('%s',periods{p})) = length(find(significant_replay_events.all_event_times >= time_limits(1) & ...
                        significant_replay_events.all_event_times <= time_limits(2))); %number of events per period
                end

                period_events = significant_replay_events.all_event_times(significant_replay_events.all_event_times >= time_limits(1) & ...
                    significant_replay_events.all_event_times <= time_limits(2)); %timestamps of replay events within the current period
                if strcmp(epochs{ep},'merged')
                    cum_times = period_time(this_protocol_idx(ii)).(sprintf('%s',periods{p})).time_limits - min(period_time(this_protocol_idx(ii)).(sprintf('%s',periods{p})).time_limits);
                    cum_events = interpolate_cumulative_time(cum_times,period_time(this_protocol_idx(ii)).(sprintf('%s',periods{p})).time_limits, period_events);
                else
                    if strfind(periods{p},'T') == 1
                        cum_events = interpolate_cumulative_time(period_time(this_protocol_idx(ii)).(sprintf('%s',periods{p})).cumulative_times,...
                            period_time(this_protocol_idx(ii)).(sprintf('%s',periods{p})).time_limits, period_events);
                    else
                        cum_events = interpolate_cumulative_time(period_time(this_protocol_idx(ii)).(sprintf('%s',periods{p})).(strcat(epochs{ep},'_cumulative_time')),...
                            period_time(this_protocol_idx(ii)).(sprintf('%s',periods{p})).(strcat(epochs{ep})),period_events);
                    end
                end
                binned_period_candidate_events.(sprintf('%s',epochs{ep}))(this_protocol_idx(ii)).session = period_time(this_protocol_idx(ii)).sessions_order;
                [binned_period_candidate_events.(sprintf('%s',epochs{ep}))(this_protocol_idx(ii)).(sprintf('%s',periods{p})),~] = histcounts(cum_events,bin_edges); %events track 1
                not_binned_period_candidate_events.(sprintf('%s',epochs{ep}))(this_protocol_idx(ii)).session = period_time(this_protocol_idx(ii)).sessions_order;
                not_binned_period_candidate_events.(sprintf('%s',epochs{ep}))(this_protocol_idx(ii)).(sprintf('%s',periods{p})) = length(cum_events); %events track 1

            end

            clear bin_edges

        end
    end
end

 save([path '\period_candidate_events.mat'], 'period_candidate_events','binned_period_candidate_events','not_binned_period_candidate_events')

end


function cumulative_event_times = interpolate_cumulative_time(cumulative_time,time, event_times)
% Interpolate replay event times to cumulative time

    if isempty(time)
        cumulative_event_times = NaN;
    else
        time(2:end,1) = time(2:end,1)+1e-10;
        cumulative_time(2:end,1) = cumulative_time(2:end,1)+1e-10;
        t = NaN(1,size(time,1)*size(time,2));
        t_c = NaN(1,size(time,1)*size(time,2));
        t(1:2:end) = time(:,1);
        t(2:2:end) = time(:,2);
        t_c(1:2:end) = cumulative_time(:,1);
        t_c(2:2:end) = cumulative_time(:,2);
        cumulative_event_times = interp1(t,t_c,event_times,'linear');
    end
end