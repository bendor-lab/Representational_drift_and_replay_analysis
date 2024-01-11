
cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day5_16x8\Bayesian controls\One track norm_track good cells')
load('significant_replay_events_wcorr.mat');
load('extracted_place_fields_BAYESIAN.mat');
load('decoded_replay_events.mat');
one_track = significant_replay_events;
one_track_place_cells = place_fields_BAYESIAN;
one_track_decoded = decoded_replay_events;

cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day5_16x8\Bayesian controls\One track normalization')
load('significant_replay_events_wcorr.mat');
load('extracted_place_fields_BAYESIAN.mat');
load('decoded_replay_events.mat');
one = significant_replay_events;
one_place_cells = place_fields_BAYESIAN;
one_decoded = decoded_replay_events;

cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day5_16x8\Bayesian controls\Normalize to each exposure_tracks good cells')
load('significant_replay_events_wcorr.mat');
load('extracted_place_fields_BAYESIAN.mat');
load('decoded_replay_events.mat');
pair_track = significant_replay_events;
pair_track_place_cells = place_fields_BAYESIAN;
pair_track_decoded = decoded_replay_events;

cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day5_16x8')
load('significant_replay_events_wcorr.mat');
load('extracted_place_fields_BAYESIAN.mat');
load('decoded_replay_events.mat');
real = significant_replay_events;
real_place_cells = place_fields_BAYESIAN;
real_decoded = decoded_replay_events;

for t = 1 : length(real_place_cells.track)
    % Find common events between methods
    common_events_real_pair{t} = intersect(pair_track.track(t).ref_index,real.track(t).ref_index);
    common_events_one_track{t} = intersect(one.track(t).ref_index,one_track.track(t).ref_index);
    common_events{t}  =  intersect(common_events_real_pair{t},common_events_one_track{t});
    % Diff events between pair+real and onetrack
    events_only_real_pair{t} = setdiff(common_events_real_pair{t},common_events_one_track{t}); % events that are only sig in real + pair
    events_only_one_track{t} = setdiff(common_events_one_track{t},common_events_real_pair{t}); % events that are only sig in one + one_track
    
end

 plot_replay_events(real,real_place_cells,common_events{1}(1:11),1);
 plot_replay_events(pair_track,pair_track_place_cells,common_events{1}(1:11),1);
 plot_replay_events(one,one_place_cells,common_events{1}(1:11),1);
 plot_replay_events(one_track,one_track_place_cells,common_events{1}(1:11),1);


% For each set of diff events, find if they've been classified in other tracks
for t = 1 : length(real_place_cells.track)
    diff_events = events_only_one_track{t};
    for tt = 1 : length(real_place_cells.track)
        if tt ~= t
            in_other_tracks_REAL{t,tt} = intersect(real.track(tt).ref_index,diff_events);
            in_other_tracks_PAIR{t,tt} = intersect(pair_track.track(tt).ref_index,diff_events);
        end
    end
end
% Repeat for events_only_real_pair 
for t = 1 : length(real_place_cells.track)
    diff_events = events_only_real_pair{t};
    for tt = 1 : length(real_place_cells.track)
        if tt ~= t
            in_other_tracks_ONE{t,tt} = intersect(one.track(tt).ref_index,diff_events);
            in_other_tracks_ONE_TRACK{t,tt} = intersect(one_track.track(tt).ref_index,diff_events);
        end
    end
end

% Events classified as T1 in ONE TRACKS but as T3 in REAL
 diff_classif = intersect(in_other_tracks_ONE_TRACK{3,1},in_other_tracks_REAL{1,3});
 
 plot_replay_events(real,real_place_cells,diff_classif(1:6),3);
 plot_replay_events(one_track,one_track_place_cells,diff_classif(1:6),1);

 % Events that are only T1 for pair and real
events_in_other_tracks = unique([in_other_tracks_ONE{1,2},in_other_tracks_ONE{1,3},in_other_tracks_ONE_TRACK{1,2},in_other_tracks_ONE_TRACK{1,3},in_other_tracks_ONE_TRACK{1,4}]); 
unique_T1_real_pair = setdiff(events_only_real_pair{1},events_in_other_tracks);

c =1;
for i = 1 : 12: length(unique_T1_real_pair)
 plot_replay_events(real,real_place_cells,unique_T1_real_pair(c:c+11),1);
 c = c+12;
end


 % Events that are only T1 for one and one T
events_in_other_tracks = unique([in_other_tracks_PAIR{1,2},in_other_tracks_PAIR{1,3},in_other_tracks_PAIR{1,4},....
    in_other_tracks_REAL{1,2},in_other_tracks_REAL{1,3},in_other_tracks_REAL{1,4}]); 
unique_T1_one_oneT = setdiff(events_only_one_track{1},events_in_other_tracks);

c =1;
for i = 1 : 12: length(unique_T1_one_oneT)
 plot_replay_events(one_track,one_track_place_cells,unique_T1_one_oneT(c:c+11),1);
 c = c+12;
end



