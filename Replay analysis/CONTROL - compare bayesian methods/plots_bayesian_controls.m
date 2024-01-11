

function plots_bayesian_controls(computer)

% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
else
    sessions = data_folders;
    session_names = fieldnames(sessions);
end

for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        load('significant_replay_events_wcorr.mat');
        load('extracted_place_fields_BAYESIAN.mat');
        load('decoded_replay_events.mat');
        real = significant_replay_events;
        real_place_cells = place_fields_BAYESIAN;
        real_decoded = decoded_replay_events;
        clear significant_replay_events
        clear decode_replay_events
        clear place_fields_BAYESIAN
        
        if exist([pwd '\Bayesian controls']) == 7
            cd([pwd '\Bayesian controls'])
            %if exist([pwd '\Normalize to each exposure_tracks good cells']) == 7
            if exist([pwd '\One track normalization']) == 7
                cd([pwd '\Normalize to each exposure_tracks good cells'])
                load('significant_replay_events_spearman.mat');
                load('decoded_replay_events.mat');
                pair_track = significant_replay_events;
                pair_track_decoded = decoded_replay_events;
                clear significant_replay_events
                clear decode_replay_events
                cd ..\
            end
            if exist([pwd '\One track norm_track good cells']) == 7
                cd([pwd '\One track norm_track good cells'])
                load('significant_replay_events_spearman.mat');
                load('decoded_replay_events.mat');
                one_track = significant_replay_events;
                one_track_decoded = decoded_replay_events;
                clear significant_replay_events
                clear decode_replay_events
                cd ..\
                cd ..\
            end
        
            
%             for t = 1 : length(real_place_cells.track)
%                 % Find common events between methods
%                 common_events_real_pair(t) = length(intersect(pair_track.track(t).ref_index,real.track(t).ref_index))/length(real.track(t).ref_index);
%                 common_events_real_one(t)  =  length(intersect(one_track.track(t).ref_index,real.track(t).ref_index))/length(real.track(t).ref_index);
%                 % Diff events between pair+real and onetrack
%                 events_only_real_pair(t)  = setdiff(common_events_real_pair(t) ,one_track.track(t).ref_index(t))/length(real.track(t).ref_index); % events that are only sig in real + pair
%                 events_only_one_track(t)  = setdiff(one_track.track(t).ref_index(t) ,common_events_real_pair(t))/length(real.track(t).ref_index); % events that are only sig in one_track
%             end
%              
%             % For each set of diff events, find if they've been classified in other tracks
%             for t = 1 : length(real_place_cells.track)
%                 diff_events = events_only_one_track{t};
%                 for tt = 1 : length(real_place_cells.track)
%                     if tt ~= t
%                         in_other_tracks_REAL{t,tt} = intersect(real.track(tt).ref_index,diff_events);
%                         in_other_tracks_PAIR{t,tt} = intersect(pair_track.track(tt).ref_index,diff_events);
%                     end
%                 end
%             end
%             % Repeat for events_only_real_pair
%             for t = 1 : length(real_place_cells.track)
%                 diff_events = events_only_real_pair{t};
%                 for tt = 1 : length(real_place_cells.track)
%                     if tt ~= t
%                         in_other_tracks_ONE_TRACK{t,tt} = intersect(one_track.track(tt).ref_index,diff_events);
%                     end
%                 end
%             end
%             
%             % Events classified as T1 in ONE TRACKS but as T3 in REAL
%             diff_classif = intersect(in_other_tracks_ONE_TRACK{3,1},in_other_tracks_REAL{1,3});
%             
%             plot_replay_events(real,real_place_cells,diff_classif(1:6),3);
%             plot_replay_events(one_track,one_track_place_cells,diff_classif(1:6),1);
%             
%             % Events that are only T1 for pair and real
%             events_in_other_tracks = unique([in_other_tracks_ONE{1,2},in_other_tracks_ONE{1,3},in_other_tracks_ONE_TRACK{1,2},in_other_tracks_ONE_TRACK{1,3},in_other_tracks_ONE_TRACK{1,4}]);
%             unique_T1_real_pair = setdiff(events_only_real_pair{1},events_in_other_tracks);
%             

                REAL_T1_events(p,s) = length(real.track(1).ref_index);
                REAL_T2_events(p,s) = length(real.track(2).ref_index);
                REAL_RT1_events(p,s) = length(real.track(3).ref_index);
                REAL_RT2_events(p,s) = length(real.track(4).ref_index);
                
                if exist([pwd '\Bayesian controls\One track normalization']) == 7
                    PAIR_T1_events(p,s) = length(pair_track.track(1).ref_index);
                    PAIR_T2_events(p,s) = length(pair_track.track(2).ref_index);
                    PAIR_RT1_events(p,s) = length(pair_track.track(3).ref_index);
                    PAIR_RT2_events(p,s) = length(pair_track.track(4).ref_index);
                end
                
                ONE_T1_events(p,s) = length(one_track.track(1).ref_index);
                ONE_T2_events(p,s) = length(one_track.track(2).ref_index);
                ONE_RT1_events(p,s) = length(one_track.track(3).ref_index);
                ONE_RT2_events(p,s) = length(one_track.track(4).ref_index);
        end
    end
end

figure
PP = plotting_parameters;
for j = 1 : 5 %for each protocol
    cols = [PP.T1; [0.3 0.3 0.3]; [0.6 0.6 0.6];PP.T2(j,:); [0.3 0.3 0.3]; [0.6 0.6 0.6];PP.T1; [0.3 0.3 0.3]; [0.6 0.6 0.6]; PP.T2(j,:);[0.3 0.3 0.3]; [0.6 0.6 0.6]];
    subplot(3,2,j)
    boxplot([REAL_T1_events(j,:)' PAIR_T1_events(j,:)' ONE_T1_events(j,:)' REAL_T1_events(j,:)' PAIR_T2_events(j,:)' ONE_T2_events(j,:)' ...
        REAL_RT1_events(j,:)' PAIR_RT1_events(j,:)' ONE_RT1_events(j,:)' REAL_RT2_events(j,:)' PAIR_RT2_events(j,:)' ONE_RT2_events(j,:)'],...
        'PlotStyle','traditional','Color',cols)
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes =a(idx);
    set(boxes(7:12),'LineWidth',2); % Set width
    set(boxes(1:6),'LineWidth',2); % Set width
    set(boxes(1:6),'LineStyle',':'); % Set width
end





end