% NUMBER OF LOCAL AND REMOTE AWAKE REPLAY EVENTS IN TRACKS PER PROTOCOL
% MH 2020
% Plots a figure per protocol. Each subplot is a rat. Within subplot, all tracks plotted with bar plot, each bar indicating number of replay events
% decoded during that track, for each possible track decoded.
% INPUT: mutlievent. 1 to select. If selection, then loads multieventsdata and plots only 2 bars for T1 and T2. Meaning it does not take into account events
% for re-exposure during T1 and T2.

function plot_awake_replay_track(multievents)

% Parameters
if multievents == 1
    load('extracted_replay_plotting_info_MultiEvents.mat')
    multievents_data = track_replay_events;
    clear track_replay_events
    load('extracted_replay_plotting_info.mat')
    alltracks_data = track_replay_events;
    if isfield(track_replay_events,'T4')
        num_tracks = 4;
    else
        num_tracks = 2;
    end
    num_sessions = length(track_replay_events);
    num_events_in_track = nan(1,num_tracks*num_tracks);
    event_times_in_track = nan(155,num_tracks*num_tracks,length(track_replay_events));
    clear track_replay_events
else
    load('extracted_replay_plotting_info.mat')
    if isfield(track_replay_events,'T4')
        num_tracks = 4;
    else
        num_tracks = 2;
    end
    num_sessions = length(track_replay_events);
    num_events_in_track = nan(1,num_tracks*num_tracks);
    event_times_in_track = nan(155,num_tracks*num_tracks,length(track_replay_events));
end
load('extracted_time_periods_replay.mat')
PP =  plotting_parameters;

for s = 1 : num_sessions
    c = 1;
    % For each track, find replay events occurring during the track
    for t = 1 : num_tracks
        if multievents == 1 %if using multievents, for T1 and T2 use multievent (to not take into account the re-exposures)
            if t < 3
                track_replay_events = multievents_data;
            else
                track_replay_events = alltracks_data;
            end
        end
        for  track = 1 : num_tracks
            % Each row a session. Columns e.g.T1 = col 1:4, with 1 being T1 events during T1, 2 - T2 events during T1, 3 are T3 events
            % during T1 & 4 are T4 events during T1. Next 4 columns (5:9)would be events during T2, etc
            num_events_in_track(s,c) = length(track_replay_events(s).(strcat('T',num2str(track))).(strcat('T',num2str(t),'_index')));
            event_times_in_track(1:length(track_replay_events(s).(strcat('T',num2str(track))).(strcat('T',num2str(t),'_times'))),c,s) = ...
                track_replay_events(s).(strcat('T',num2str(track))).(strcat('T',num2str(t),'_times'));
            c = c+1;
        end
    end
end


% BAR PLOT - NUMBER OF REPLAY EVENTS PER TRACK IN EACH TRACK - PER EACH SESSION
protocols = [8,4,3,2,1];
count = 1;
for p = 1 : length(protocols)
    
    cols = repmat([PP.P(p).colorT(1,:); PP.P(p).colorT(2,:);PP.P(p).colorT(3,:) ;PP.P(p).colorT(4,:)],[4,1]);
    f(p) = figure('units','normalized','outerposition',[0 0 1 1]);
    if multievents == 1
        f(p).Name = ['Number of awake replay events per track_per rat_MultiEvents_Protocol 16x' num2str(protocols(p))];
    else
        f(p).Name = ['Number of awake replay events per track_per rat_Protocol 16x' num2str(protocols(p))];
    end
    if multievents == 1
        x = [1:2,4:5,7:10,12:15];
        jj =[1:2,5:6,9:16];
    else
        x = [1:4,6:9,11:14,16:19];
    end
    for c =  1 : 4
        ax(c) = subplot(4,1,c);
        for ii = 1 : length(x)
            hold on
            if multievents == 1
                b(ii) = bar(x(ii), num_events_in_track(count,jj(ii)),0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
            else
                b(ii) = bar(x(ii), num_events_in_track(count,ii),0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
            end
        end
        box off
        ylabel('Mean number of cells','Fontsize',18)
        xticks([2.5,7.5,12.5,17.5]); xticklabels({'T1','T2','R-T1','R-T2'});
        legend([b(1),b(2),b(3),b(4)],{'T1','T2','T3','T4'},'Location','northeastoutside');
        ylabel('# replay events')
        ax(c).FontSize = 16;
        count = count+1;
    end
end

save_all_figures(pwd,[])




end