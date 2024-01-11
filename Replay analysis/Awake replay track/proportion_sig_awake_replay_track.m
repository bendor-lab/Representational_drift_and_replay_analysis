% For each lap, calculates the proportion of significant events with
% respect to candidate events for the lap

function proportion_sig_awake_replay_track(data_type)

if strcmp(data_type,'main')
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\extracted_replay_plotting_info.mat')
end

sessions = data_folders;
session_names = fieldnames(sessions);
c = 1;
for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    
    for s = 1 : length(folders)
        cd(cell2mat(folders(s)))
        load('significant_replay_events_wcorr.mat')
        load('extracted_laps');
        
        for t = 1 : length(lap_times) %for each track
            % For each lap find candidate events
            for lap = 1 : lap_times(t).number_completeLaps
                times = [lap_times(t).completeLaps_start(lap) lap_times(t).completeLaps_stop(lap)]; %start and end time lap
                %find number of candidate events detected during that time
                num_cand_events = length(find(significant_replay_events.all_event_times > times(1) & significant_replay_events.all_event_times < times(2)));
                % Calculate proportion of sig events found
                %lap_sig_events = length(protocol(p).(strcat('T',num2str(t)))(s).Rat_replay_REF_idx{t,lap});
                lap_sig_events = length(find(significant_replay_events.track(t).event_times > times(1) & significant_replay_events.track(t).event_times < times(2)));
                lap_prop_sig_replay(t).num_cand_events(lap,c) = num_cand_events;
                lap_prop_sig_replay(t).lap_sig_events(lap,c) = lap_sig_events;
                lap_prop_sig_replay(t).prop_sig_events(lap,c) = lap_sig_events/num_cand_events;
                
            end
        end
        c = c+1;
    end
end


T1_mean_prop_sig_events = mean(lap_prop_sig_replay(1).prop_sig_events,2,'omitnan');
T1_median_prop_sig_events = median(lap_prop_sig_replay(1).prop_sig_events,2,'omitnan');

T2_mean_prop_sig_events = sum(lap_prop_sig_replay(2).prop_sig_events(1:8,:),2,'omitnan')./[20,16,12,8,ones(1,4)*4]';
T3_mean_prop_sig_events = mean(lap_prop_sig_replay(3).prop_sig_events,2,'omitnan');
T4_mean_prop_sig_events = mean(lap_prop_sig_replay(4).prop_sig_events,2,'omitnan');

tst = nan(16,4);
tst(1:16,1) = T1_mean_prop_sig_events(1:16);
tst(1:8,2) = T2_mean_prop_sig_events(1:8);
tst(1:16,3) = T3_mean_prop_sig_events(1:16);
tst(1:16,4) = T4_mean_prop_sig_events(1:16);

[p,~,stats] = kruskalwallis(tst');

figure;
plot(T1_mean_prop_sig_events(1:16))
hold on
plot(T2_mean_prop_sig_events)
plot(T3_mean_prop_sig_events(1:16))
plot(T4_mean_prop_sig_events(1:16))



end