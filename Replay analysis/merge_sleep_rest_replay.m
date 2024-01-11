% MERGES SLEEP AND REST REPLAY EVENTS IN track_replay_events STRUCTURE
% This code gets the output from 'extract_replay_plotting.mat' and merges
% sleep and awake (=rest) replay events, adding a subfield called 'merged'

function merge_sleep_rest_replay(multievents,bayesian_controls)

if multievents == 1
    load('extracted_replay_plotting_info_MultiEvents.mat')
else
    load('extracted_replay_plotting_info.mat')
end
load("extracted_time_periods_replay.mat")

% Depending on how many exposures, set name of session periods
if  bayesian_controls == 1
    fields = {'T1','T2'};
    session_periods = {'PRE','sleep_pot1','INTER_post','sleep_pot2','FINAL_post'};
elseif isfield(track_replay_events,'T3') % if there's re-exposure
    fields = {'T1','T2','T3','T4'};
    session_periods = {'PRE','sleep_pot1','INTER_post','sleep_pot2','FINAL_post'};
else % if there's only 2 exposures
    fields = {'T1','T2'};
    session_periods = {'PRE','sleep_pot1','FINAL_post'};
end

for s = 1 : length(track_replay_events)    
    for f =  1 : length(fields)
        for per = 1 : length(session_periods)
            track_replay_events(s).(sprintf('%s',fields{f})).(sprintf('%s',session_periods{per},'_merged_index')) = sort([track_replay_events(s).(sprintf('%s',fields{f})).(sprintf('%s',session_periods{per},'_awake_index')) ...
                track_replay_events(s).(sprintf('%s',fields{f})).(sprintf('%s',session_periods{per},'_sleep_index'))]);
            track_replay_events(s).(sprintf('%s',fields{f})).(sprintf('%s',session_periods{per},'_merged_REAL_index')) = sort([track_replay_events(s).(sprintf('%s',fields{f})).(sprintf('%s',session_periods{per},'_awake_REAL_index')) ...
                track_replay_events(s).(sprintf('%s',fields{f})).(sprintf('%s',session_periods{per},'_sleep_REAL_index'))]);
            track_replay_events(s).(sprintf('%s',fields{f})).(sprintf('%s',session_periods{per},'_merged_times')) = sort([track_replay_events(s).(sprintf('%s',fields{f})).(sprintf('%s',session_periods{per},'_awake_times')) ...
                track_replay_events(s).(sprintf('%s',fields{f})).(sprintf('%s',session_periods{per},'_sleep_times'))]);
            % Interpolate times
            cum_times = period_time(s).(sprintf('%s',session_periods{per})).time_limits - min(period_time(s).(sprintf('%s',session_periods{per})).time_limits);
            track_replay_events(s).(sprintf('%s',fields{f})).(sprintf('%s',session_periods{per},'_merged_cumulative_times')) = interpolate_cumulative_time(cum_times,period_time(s).(sprintf('%s',session_periods{per})).time_limits,...
                track_replay_events(s).(sprintf('%s',fields{f})).(sprintf('%s',session_periods{per},'_merged_times')));

        end
    end
end

if multievents == 1
    save('extracted_replay_plotting_info_MultiEvents.mat','track_replay_events','-v7.3')
else
    save('extracted_replay_plotting_info.mat','track_replay_events','-v7.3')
end

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


