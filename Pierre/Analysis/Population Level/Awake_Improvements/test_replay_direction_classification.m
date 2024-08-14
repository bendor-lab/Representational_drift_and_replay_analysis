% Trying to decode, for each replay of a given lap, if replay were forward
% or backward replay

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths
sessions_legacy = data_folders_excl_legacy; % We fetch all the sessions folders paths

sID = 4;
trackOI = 1;
exposureOI = 1;
lapOI = 2;

tracks_compared = [1, 2];

file = sessions{sID};
file_legacy = sessions_legacy{sID};

% Load the data
temp = load(file_legacy + "/extracted_directional_place_fields_BAYESIAN");
directional_place_fields_BAYESIAN = temp.directional_place_fields_BAYESIAN;

temp = load(file + "/extracted_replay_events");
replay = temp.replay;

temp = load(file + "/extracted_laps");
lap_times = temp.lap_times;

temp = load(file + "/extracted_clusters");
clusters = temp.clusters;

if exposureOI == 1
    temp = load(file + "/Replay/RUN1_Decoding/significant_replay_events_wcorr");
else
    temp = load(file + "/Replay/RUN2_Decoding/significant_replay_events_wcorr");
end
significant_replay_events = temp.significant_replay_events;

% We find the times that can qualify for awake replay during the lap
% end-zone of half lap lapOI*2 (-1)

vTrack = trackOI + (exposureOI == 2)*2;
first_hl = lapOI*2 - 1; % We will add 1 to this because end zones start with beginning of 1st lap
sec_hl = lapOI*2; % idem

end_zone_1_t = lap_times(vTrack).end_zone(first_hl+1).t;
end_zone_1_x = lap_times(vTrack).end_zone(first_hl+1).x;
end_zone_2_t = lap_times(vTrack).end_zone(sec_hl+1).t;
end_zone_2_x = lap_times(vTrack).end_zone(sec_hl+1).x;

% We filter the end-zone to only include the times where the position is
% the opposite from the start position

end_zone_1_t = end_zone_1_t(sign(end_zone_1_x) == ...
    mode(sign(end_zone_1_x)));

end_zone_2_t = end_zone_2_t(sign(end_zone_2_x) == ...
    mode(sign(end_zone_2_x)));

% We find all the significant replay that happened during those times

index_replay = significant_replay_events.track(trackOI).ref_index;
time_replay = significant_replay_events.track(trackOI).event_times;
decoded_positions = significant_replay_events.track(trackOI).decoded_position;

is_during_lap_1 = (time_replay <= end_zone_1_t(end)) & ...
    (time_replay >= end_zone_1_t(1));

is_during_lap_2 = (time_replay <= end_zone_2_t(end)) & ...
    (time_replay >= end_zone_2_t(1));

% Label the replay based on if they come from 1 or 2

is_during_lap = is_during_lap_1 | is_during_lap_2;
valid_index = index_replay(is_during_lap);
valid_dec_positions = decoded_positions(is_during_lap);

% We create a new place field file with two concurrent directions

place_fields_BAYESIAN = directional_place_fields_BAYESIAN(1).place_fields;

place_fields_BAYESIAN.track(1) = directional_place_fields_BAYESIAN(1)...
    .place_fields.track(trackOI);

place_fields_BAYESIAN.track(2) = directional_place_fields_BAYESIAN(2)...
    .place_fields.track(trackOI);

place_fields_BAYESIAN.track(3:4) = [];

% We filter the replay file
all_replay_fields = fieldnames(replay)';

for i = all_replay_fields(1:end-2)
    replay.(i{1}) = replay.(i{1})(valid_index);
end

cd(file);


%% Decode the events
% replay_events is an empty template for replay event analysis.
% Each track will create its own field

replay_events = struct('replay_id',{},...%the id of the candidate replay events in chronological order
    'spikes',{}); % column 1 is spike id, column 2 is spike time

% TAKE SPIKES FROM ONLY good place fields (on at least one track of interest)

sorted_spikes = zeros(size(clusters.spike_id));
sorted_spikes(:, 1) = clusters.spike_id; % Get the spike ID
sorted_spikes(:, 2) = clusters.spike_times; % Get the spike time

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

if num_replay ~= 0
    
    
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
    
    if numel(replay_starts) == 1 % If only one replay event
        % We change slightly the format
        replayEvents_bayesian_spike_count.replay_events.replay_time_centered = ...
            {replayEvents_bayesian_spike_count.replay_time_centered};
        
        replayEvents_bayesian_spike_count.replay_events.replay_time_edges = ...
            {replayEvents_bayesian_spike_count.replay_time_edges};
        
        replayEvents_bayesian_spike_count.replay_events_indices = ...
            repelem(1, numel(replayEvents_bayesian_spike_count.replay_time_edges)-1);
    end
    
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
    
    
    
    %% The direction of START is the 1st direction in the file directional place field
    % (very important)
    
    startDirection = lap_times(vTrack).initial_dir; %D1 direction
    
    % Direction -1 goes from - to +
    % Direction 1 goes from + to -
    
    % startLap = lap_times(vTrack).halfLaps_start(1);
    % endLap = lap_times(vTrack).halfLaps_stop(1);
    % plot(position.y(position.t <= endLap & ...
    %                 position.t >= startLap));
    
    %% Now that we have our decoded positions, we can calculate the bias between the positions
end

typesOfReplay = zeros(1, numel(valid_index));

for current_r = 1:numel(valid_index)
    % We get the decoded head direction
    decoded = valid_dec_positions{current_r};
    decoded_D1 = decoded_replay_events(1).replay_events(current_r).decoded_position;
    decoded_D2 = decoded_replay_events(2).replay_events(current_r).decoded_position;
    sum_D1 = sum(sum(decoded_D1));
    sum_D2 = sum(sum(decoded_D2));
    
    % If D1 > D2, D1 is the head direction
    % Otherwise, D2
    
    decoded_head_dir = (sum_D1 > sum_D2)* startDirection + ...
        (sum_D1 < sum_D2)* -startDirection;
    
    % We get the decoded replay direction (-1 -> 1 or 1 -> -1)
    % Negative correlation : 1 -> -1
    direction = weighted_correlation(decoded, false);
    if -sign(direction) == decoded_head_dir
        typesOfReplay(current_r) = 1;
    else
        typesOfReplay(current_r) = -1;
    end
end


disp(sum(typesOfReplay == 1));
disp(sum(typesOfReplay == -1));

%%

typesOfReplay = get_replay_lap(file, file_legacy, ...
                   trackOI, exposureOI, lapOI, ...
                   directional_place_fields_BAYESIAN, ...
                   replay, lap_times, clusters, ...
                   significant_replay_events);

disp(sum(typesOfReplay == 1));
disp(sum(typesOfReplay == -1));