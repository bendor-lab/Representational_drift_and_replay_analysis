% Testing drift monitoring during sleep using replay events
clear

sID = 2;
trackOI = 1;

sessions = data_folders_excl;
sessions_legacy = data_folders_excl_legacy;

file = sessions{sID};
file_legacy = sessions_legacy{sID};

% Load the necessery files

temp = load(file + "/extracted_place_fields_BAYESIAN");
place_fields_BAYESIAN = temp.place_fields_BAYESIAN;

temp = load(file + "/extracted_sleep_state");
sleep_state = temp.sleep_state;

temp = load(file + "/Replay/RUN1_decoding/significant_replay_events_wcorr");
significant_replay_events = temp.significant_replay_events;

temp = load(file + "/replayEvents_bayesian_spike_count");
bayesian_spike_count = temp.replayEvents_bayesian_spike_count;

temp = load(file + "/extracted_clusters");
clusters = temp.clusters;

%% Get files important for bayesian decoding

% spike_count for the whole session
n = bayesian_spike_count.n.replay;
spikecount_indices = bayesian_spike_count.replay_events_indices;

% By default, this spike counts has every good cell, no matter the track.
% To get all the cells we are interested in, we filter our cells from the 
% general good cells
% Here, cells that are good during RUN1 and RUN2 ! 

all_cells = place_fields_BAYESIAN.track(trackOI).good_cells;
all_cells = all_cells(ismember(all_cells, ...
            place_fields_BAYESIAN.track(trackOI + 2).good_cells));

all_cells_alltracks = place_fields_BAYESIAN.good_place_cells;

is_good_PC_track = ismember(all_cells_alltracks, all_cells);
n = n(is_good_PC_track, :); % We filter

% We save and clean all the place fields in all_place_fields (nb of PF x 20 matrix)
all_place_fields = genFieldsFile(place_fields_BAYESIAN, trackOI, all_cells);

% We get all the spikes of all the replay events of trackOI
all_spikes = significant_replay_events.track(trackOI).spikes;

%% For each cell ---

cellID = 14; % Id of the cell in the good cells vector
cellOI = all_cells(cellID); % real ID of the cell

% We can create a mutated version of the two files without the cell
all_place_fields_mut = all_place_fields(all_cells ~= cellOI, :);
n_mut = n(all_cells ~= cellOI, :);

% We find all the replay events where that cell was involved
valid_index = getCellReplays(significant_replay_events, ...
                             sleep_state, trackOI, cellOI);
                         
fields_replay = {};

% Now for each replay
for rID = valid_index
    
    % Find the id in the big replay file (all candidate events)
    global_id = significant_replay_events.track(trackOI).ref_index(rID);
    eventEdges = bayesian_spike_count.replay_events(global_id).replay_time_edges;
    
    % Find all the bins in n falling in that replay event
    isCurrentReplay = (bayesian_spike_count.replay_events_indices == global_id);
    sub_n_mut = n_mut(:, isCurrentReplay);
    
    % Find all the times when the cell fired during this replay
    current_spikes = all_spikes{rID};
    all_times_spikes = current_spikes(current_spikes(:, 1) == cellOI, 2);
    
    current_replay = {};
    times = [];
    
    % For each spike during the replay event
    for spike_t = all_times_spikes'
        
        % We get all the spikes of all the cells deltaT/2 before and after
        % the spike
        delta = 0.020; % We want 20 ms around the spike
        allIDs = clusters.spike_id(clusters.spike_times >= spike_t - delta/2 & ...
                                   clusters.spike_times <= spike_t + delta/2);
                               
        allIDs(~ismember(allIDs, all_cells)) = []; % filter good cells
        disp(numel(allIDs));
        
        if ~isempty(allIDs) % If we have spikes
            
            % We count how many times each cell fired
            spike_vector = [];
            
            for c = all_cells
                spike_vector(end + 1) = sum(allIDs == c);
            end
            
            spike_vector(all_cells == cellOI) = []; % filter cellOI
            
            % Quick fix : we add zeros to make matlab understand it's 2D
            spike_vector = [spike_vector' zeros(numel(spike_vector), 1)];
            
            % Now we can decode
            est_position = reconstruct(spike_vector, all_place_fields_mut, 0.02);
            est_position = est_position(:, 1);
            
            % We normalise the reconstructed position
            est_position = est_position/sum(est_position);
            
            current_replay{end + 1} = est_position;
            times(end + 1) = spike_t;
        end   
    end
    
    fields_replay{end + 1} = current_replay;
    
end

%% Plotting

plotDriftReplay(fields_replay, place_fields_BAYESIAN, ...
                trackOI, cellOI, 1);