function [decoded_replay_events, replayEvents_bayesian_spike_count] = replay_decoding(tracks_compared, path2save, saving)

% INPUT :
% - tracks_compared : tracks we want to compare (array of track_id, e.g. [1 3])
% - path2save : path to save the files we save (in good folders)
% - saving : "Y" -> saving, "N" don't saving

% OUTPUT :
% - decoded_replay_events struct : list of potential replay events with
% decoded position

% LOADS : extracted_replay_events.mat, extracted_clusters.mat,
% extracted_place_fields_BAYESIAN.mat, list_of_parameters

% Commented and modified by Pierre Varichon 2024


%% Load parameters
parameters = list_of_parameters;
load('extracted_replay_events.mat');
load('extracted_clusters.mat');
load('extracted_place_fields_BAYESIAN.mat');

%% REPLAY EVENTS STRUCTURE
% replay_events is an empty template for replay event analysis.
% Each track will create its own field

replay_events = struct('replay_id',{},...%the id of the candidate replay events in chronological order
    'spikes',{}); % column 1 is spike id, column 2 is spike time

%% TAKE SPIKES FROM ONLY good place fields (on at least one track of interest)

sorted_spikes = zeros(size(clusters.spike_id));
sorted_spikes(:,1) = clusters.spike_id; % Get the spike ID
sorted_spikes(:,2) = clusters.spike_times; % Get the spike time

all_units = unique(clusters.spike_id);
allGoodPCTracks = unique([place_fields_BAYESIAN.track(tracks_compared).good_cells]);

% Find cells that are not good place cells
non_pyramidal = setdiff(all_units, allGoodPCTracks);

% Remove spikes from bad cells
sorted_spikes(ismember(sorted_spikes(:, 1), non_pyramidal), :) = [];

num_spikes = length(sorted_spikes);
num_units = length(allGoodPCTracks);

% EXTRACT SPIKES IN REPLAY EVENTS

num_replay = size(replay.onset, 2);
current_replay = 1;
current_replay_spikes = [];

% To vectorise in the futur

for i = 1 : num_spikes
    % Collect spike data during replay
    if sorted_spikes(i,2) > replay.offset(current_replay)
        replay_events(current_replay).replay_id = current_replay;
        replay_events(current_replay).spikes = current_replay_spikes;
        current_replay = current_replay + 1;
        if current_replay > num_replay
            break
        end
        current_replay_spikes = [];
    end
    
    if sorted_spikes(i,2) >= replay.onset(current_replay)
        % If spike happens during replay, records it as replay spike
        current_replay_spikes = [current_replay_spikes; sorted_spikes(i,:)];
    end
end

num_replay_events = length(replay_events);
msg = [num2str(num_replay_events), ' candidate events.'];
disp(msg);

% Save all replay events all tracks
for trackIndex = 1:length(tracks_compared)
    decoded_replay_events(trackIndex).replay_events = replay_events;
end

%% Bayesian decoding

% Get the start and stop timebins of each replay event
replay_starts = replay.onset;
replay_ends = replay.offset;

% Get time vectors for bayesian decoding and matrix with spike count
disp('Spike count...');
replayEvents_bayesian_spike_count = spike_count(place_fields_BAYESIAN,replay_starts,replay_ends);

% Run bayesian decoding
disp('Decoding position...');
estimated_position = bayesian_decoding(place_fields_BAYESIAN,replayEvents_bayesian_spike_count, tracks_compared);

% Save in structure
for j = 1:length(tracks_compared)
    for i = 1 : num_replay_events
        decoded_replay_events(j).replay_events(i).timebins_edges = estimated_position(j).replay_events(i).replay_time_edges;
        decoded_replay_events(j).replay_events(i).timebins_centre = estimated_position(j).replay_events(i).replay_time_centered;
        decoded_replay_events(j).replay_events(i).timebins_index = 1:length(estimated_position(j).replay_events(i).replay_time_centered);
        decoded_replay_events(j).replay_events(i).decoded_position = estimated_position(j).replay_events(i).replay; % normalized by all tracks
    end
end

if strcmp("Y", saving)
    % Saves structures
    save(path2save + "replayEvents_bayesian_spike_count.mat",'replayEvents_bayesian_spike_count', '-v7.3')
    save(path2save + "estimated_position.mat", 'estimated_position', '-v7.3')
    save(path2save + "decoded_replay_events.mat", 'decoded_replay_events', '-v7.3');

end