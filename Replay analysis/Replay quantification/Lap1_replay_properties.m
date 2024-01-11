% 1 LAP REPLAY EVENTS PROPERTIES

load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\extracted_replay_plotting_info.mat')
PP =plotting_parameters;

sessions = data_folders;
session_names = fieldnames(sessions);
periods = {'PRE','INTER_post','FINAL_post'};
ses =1;
for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
f(p) = figure;
for s = 1: length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        load(['significant_replay_events_wcorr.mat'])
        %load('decoded_replay_events.mat')
        %load('decoded_replay_events_segments.mat')
        
        for per = 1: 3 % for each sleep period
            %find indices of significant events for T1 and T2 in PRE and INTER sleeep
            if per == 1 | per == 2
                T1_idx = [track_replay_events(ses).T1.(sprintf('%s',periods{per},'_awake_index')) track_replay_events(ses).T1.(sprintf('%s',periods{per},'_sleep_index'))];
                T2_idx = [track_replay_events(ses).T2.(sprintf('%s',periods{per},'_awake_index')) track_replay_events(ses).T2.(sprintf('%s',periods{per},'_sleep_index'))];
                if per == 1
                    events_dur(p,s).rat{1,1} = significant_replay_events.track(1).event_duration(T1_idx);
                    events_dur(p,s).rat{1,2} = significant_replay_events.track(2).event_duration(T2_idx);
                else
                    events_dur(p,s).rat{1,3} = significant_replay_events.track(1).event_duration(T1_idx);
                    events_dur(p,s).rat{1,4} = significant_replay_events.track(2).event_duration(T2_idx);

                end
            end
            
            if per == 3
                RT1_idx = [track_replay_events(ses).T3.(sprintf('%s',periods{per},'_awake_index')) track_replay_events(ses).T3.(sprintf('%s',periods{per},'_sleep_index'))];
                RT2_idx = [track_replay_events(ses).T4.(sprintf('%s',periods{per},'_awake_index')) track_replay_events(ses).T4.(sprintf('%s',periods{per},'_sleep_index'))];
                events_dur(p,s).rat{1,5} = significant_replay_events.track(3).event_duration(RT1_idx);
                events_dur(p,s).rat{1,6} = significant_replay_events.track(4).event_duration(RT2_idx);
            end
            
            
%             figure
%             subplot(2,2,1)
%             plot(significant_replay_events.track(1).event_duration(T1_idx))
%             title(mean(significant_replay_events.track(1).event_duration(T1_idx)))
%             hold on
%             
%             subplot(2,2,2)
%             plot(significant_replay_events.track(2).event_duration(T2_idx))
%             title(mean(significant_replay_events.track(2).event_duration(T2_idx)))
%             
%             subplot(2,2,3)
%             plot(significant_replay_events.track(3).event_duration(RT1_idx))
%             title(mean(significant_replay_events.track(3).event_duration(RT1_idx)))
%             
%             subplot(2,2,4)
%             plot(significant_replay_events.track(4).event_duration(RT2_idx))
%             title(mean(significant_replay_events.track(4).event_duration(RT2_idx)))
            
        end
        
        subplot(2,2,s)
        temp = nan(300,6);
        for j = 1 : 6
            temp(1:length(events_dur(p,s).rat{1,j}),j) = events_dur(p,s).rat{1,j};
        end
            
        boxplot(temp)
        hold on
        for j = 1 : 6
            if ~isempty(events_dur(p,s).rat{1,j})
                plot(j,events_dur(p,s).rat{1,j},'o','MarkerFaceColor',PP.T2(p,:),'MarkerEdgeColor',PP.T2(p,:))
            end
        end
        
        ses = ses +1;
    end
end

