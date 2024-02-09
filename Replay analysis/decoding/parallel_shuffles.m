function shuffled_track = parallel_shuffles(shuffle_choice, analysis_type, num_shuffles, decoded_replay_events, ...
                                            place_fields_BAYESIAN, replayEvents_bayesian_spike_count, tracks_compared)
%runs run_shuffles on multiple cores in parallel
% shuffle_choice- determines what type of shuffles will be performed, entered as a string
%
% analysis type- vector of 0's and 1's for which replaying
% scoring method is used [line fitting, weighted
%correlation, "pac-man" path finding, and spearman correlation coefficient]
% (e.g. [1 0 0 1] would be line fitting and spearman correlation)
%
% num_shuffles= number of shuffles

% Commented and modified by Pierre Varichon 2024

disp(shuffle_choice);  % display shuffle choice

p = gcp; % Starting new parallel pool
if isempty(p)
    num_cores = 0;
    disp('parallel processing not possible');
else
    num_cores = p.NumWorkers;
end

% Struct to hold the shuffled scores
shuffled_track = [];
% We can create a different loop per CPU core
number_of_loops = num_cores;
% Number of shuffle per core - this calculation don't work for odd ratio
% and less than 4 shuffles.
new_num_shuffles = ceil(num_shuffles/number_of_loops);

% For each core, run the analyis and append to the object out
% One cell per shuffle, and 2 tracks per cells
% Could remove intermediate variable shuffled_track

parfor i=1:number_of_loops
    out{i}.shuffled_track = run_shuffles(shuffle_choice,analysis_type,new_num_shuffles,decoded_replay_events, ...
                                         place_fields_BAYESIAN, replayEvents_bayesian_spike_count, tracks_compared);
end

% Get the current numbr of tracks
num_tracks = length(out{1}.shuffled_track);
% Get the current number of replay events
num_replay_events = length(out{1}.shuffled_track(1).replay_events);

% Pre-allocating

for track = 1 : num_tracks
    [shuffled_track(track).replay_events(1:num_replay_events).linear_score] = deal([]);
    [shuffled_track(track).replay_events(1:num_replay_events).weighted_corr_score] = deal([]);
    [shuffled_track(track).replay_events(1:num_replay_events).path_score] = deal([]);
end

% Concat each loop of shuffles

for track = 1 : num_tracks
    for event = 1: num_replay_events
        for i=1:number_of_loops
            shuffled_track(track).replay_events(event).linear_score = [shuffled_track(track).replay_events(event).linear_score; out{i}.shuffled_track(track).replay_events(event).linear_score];
            shuffled_track(track).replay_events(event).weighted_corr_score = [shuffled_track(track).replay_events(event).weighted_corr_score; out{i}.shuffled_track(track).replay_events(event).weighted_corr_score];
            shuffled_track(track).replay_events(event).path_score = [shuffled_track(track).replay_events(event).path_score; out{i}.shuffled_track(track).replay_events(event).path_score];
        end
    end
end

%copy exact number of shuffles needed (more shuffles will be performed if
%total number is not equall divisible by the number of cores used for
%parallel processing

for track = 1 : num_tracks
    for event = 1: num_replay_events
        shuffled_track(track).replay_events(event).linear_score = shuffled_track(track).replay_events(event).linear_score(1:num_shuffles);
        shuffled_track(track).replay_events(event).weighted_corr_score = shuffled_track(track).replay_events(event).weighted_corr_score(1:num_shuffles);
        shuffled_track(track).replay_events(event).path_score = shuffled_track(track).replay_events(event).path_score(1:num_shuffles);
    end
end

%save type of shuffle used
for track = 1 : num_tracks
    shuffled_track(track).shuffle_choice=shuffle_choice;
end
end