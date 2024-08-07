
function shuffled_track = run_shuffles(shuffle_choice,analysis_type, num_shuffles, decoded_replay_events, ...
                                       place_fields_BAYESIAN, replayEvents_bayesian_spike_count, tracks_compared)

% computes shuffles on replay events
% shuffle_choice- determines what type of shuffles will be performed, entered as a string
%
% analysis type- vector of 0's and 1's for which replaying
% scoring method is used [line fitting, weighted
% correlation, "pac-man" path finding, and spearman correlation coefficient]
% (e.g. [1 0 0 1] would be line fitting and spearman correlation)
%
% num_shuffles= number of shuffles

analysis_type(4) = 0;  % don't do shuffles on spearman correlation

% If spike circular shift (usually first shuffle), we extract the relevant
% variables

if strcmp(shuffle_choice, 'PRE spike_train_circular_shift')
    replay_indices = replayEvents_bayesian_spike_count.replay_events_indices;
    spike_count_structure = replayEvents_bayesian_spike_count;
end

% Get the number of tracks in the current analysis
num_tracks = length(decoded_replay_events);
% Get the current number of replay events
num_replay_events = length(decoded_replay_events(1).replay_events);

% We define the anonymous functions for the shuffles

% For POST place bin circular shift
placeCircularShift = @(mat) cell2mat(cellfun(@(col) circshift(col, randi([1, size(mat, 2)], size(mat, 1), 1)), ...
                       num2cell(mat, 1), 'UniformOutput', false));

timeCircularShift = @(mat) cell2mat(cellfun(@(row) circshift(row, randi([1, size(mat, 1)], size(mat, 2), 1)), ...
                    num2cell(mat, 2), 'UniformOutput', false));
                   
% For POST time bin permutation
timeBinPerm = @(mat) mat(:, randperm(size(mat, 2)));

% We iterate through shuffles
for s = 1:num_shuffles
    
    % Struct to hold data
    shuffled_struct = [];
    
    switch shuffle_choice
        %% POST place bin circular shift
        case 'POST place bin circular shift'
            % For each shuffle, creates a new structure where the position rows within each time bin in each decoded event have been shuffled
            for track = 1 : num_tracks
                
                allDecodedReplay = decoded_replay_events(track).replay_events;
                
                % We get the size of the replay events
                pixel_sizes = cellfun(@size, {allDecodedReplay(:).decoded_position}, 'UniformOutput', false);
                timeSizeMat = cell2mat(cellfun(@(x) x(2), pixel_sizes, 'UniformOutput', false));
                
                % We copy the replay events in our struct, withotu decoded
                % position
                shuffled_struct(track).replay_events = rmfield(allDecodedReplay, "decoded_position");
                
                % We get the time indexs of the replay event
                % (index is needed when analyzing segments of replay event)
                index = {decoded_replay_events(track).replay_events(:).timebins_index};
                
                % For each replay, we circshift the rows of each colums
                allShuffledMat = cellfun(@(mat) placeCircularShift(mat), {allDecodedReplay(:).decoded_position}, 'UniformOutput', false);
                
                % We assign to our struct
                [shuffled_struct(track).replay_events.decoded_position] = deal(allShuffledMat{:});
                
                % Filter : If event duration is more than 5x timebin
                % (usually 0.020 ms), we NaN the decoded position
                
                [shuffled_struct(track).replay_events(timeSizeMat < 5).decoded_position] = deal(NaN);
                
            end
            
            
        %% POST time bin circular shift
        case 'POST time bin circular shift'
            % For each shuffle, creates a new structure where the time bins within each position bin in each decoded event have been shuffled
            for track = 1 : num_tracks
                
                allDecodedReplay = decoded_replay_events(track).replay_events;
                
                % We get the size of the replay events
                pixel_sizes = cellfun(@size, {allDecodedReplay(:).decoded_position}, 'UniformOutput', false);
                timeSizeMat = cell2mat(cellfun(@(x) x(2), pixel_sizes, 'UniformOutput', false));
                
                % We copy the replay events in our struct, withotu decoded
                % position
                shuffled_struct(track).replay_events = rmfield(allDecodedReplay, "decoded_position");
                                
                % For each replay, we circshift the columns
                allShuffledMat = cellfun(@(mat) timeCircularShift(mat), {allDecodedReplay(:).decoded_position}, 'UniformOutput', false);
                
                % We assign to our struct
                [shuffled_struct(track).replay_events.decoded_position] = deal(allShuffledMat{:});
                
                % Filter : If event duration is more than 5x timebin
                % (usually 0.020 ms), we NaN the decoded position
                
                [shuffled_struct(track).replay_events(timeSizeMat < 5).decoded_position] = deal(NaN);
                
            end
            
        %% POST time bin permutation    
        case 'POST time bin permutation'
            for track = 1 : num_tracks
                
                allDecodedReplay = decoded_replay_events(track).replay_events;
                
                % We get the size of the replay events
                pixel_sizes = cellfun(@size, {allDecodedReplay(:).decoded_position}, 'UniformOutput', false);
                timeSizeMat = cell2mat(cellfun(@(x) x(2), pixel_sizes, 'UniformOutput', false));
                
                % We copy the replay events in our struct, withotu decoded
                % position
                shuffled_struct(track).replay_events = rmfield(allDecodedReplay, "decoded_position");
                
                % We get the time indexs of the replay event
                % (index is needed when analyzing segments of replay event)
                index = {decoded_replay_events(track).replay_events(:).timebins_index};
                
                % For each replay, we circshift the rows of each colums
                allShuffledMat = cellfun(@(mat) timeBinPerm(mat), {allDecodedReplay(:).decoded_position}, 'UniformOutput', false);
                
                % We assign to our struct
                [shuffled_struct(track).replay_events.decoded_position] = deal(allShuffledMat{:});
                
                % Filter : If event duration is more than 5x timebin
                % (usually 0.020 ms), we NaN the decoded position
                
                [shuffled_struct(track).replay_events(timeSizeMat < 5).decoded_position] = deal(NaN);
                
            end
            
        case 'PRE spike_train_circular_shift'
            
            % We get the spike count matrix cell x time (concat)
            replay_events_spike_count = spike_count_structure.n.replay;
            
            % We circularly shuffle spike trains in each replay window
            % given by replay_indices
            
            unique_indices = unique(replay_indices(~isnan(replay_indices)));
                        
            replay_events_spike_count = cellfun(@(id) timeCircularShift(replay_events_spike_count(:, replay_indices == id)), ...
                                                      num2cell(unique_indices), 'UniformOutput', false);
                                                             
                                                  
            % We combine everything, adding the 0 layer between each
            % event for back compatibility
            
            replay_events_spike_count = cell2mat(cellfun(@(x) [x repelem(0, size(x, 1))'], ...
                                                               replay_events_spike_count, 'UniformOutput', false));
            
            % We remove the last 0 layer to match replay_events_spike_count
            % dimension
            replay_events_spike_count = replay_events_spike_count(:, 1:end-1);

            % Save in structure to input in bayesian decoding code
            shuffled_spike_count.n.replay = replay_events_spike_count;
            shuffled_spike_count.replay_events_indices = replay_indices;
            shuffled_spike_count.replay_events = replayEvents_bayesian_spike_count.replay_events;
            
            % Each replay event is then decoded using the new spike count structure
            estimated_position = bayesian_decoding(place_fields_BAYESIAN, shuffled_spike_count, tracks_compared);
            
            % We assign to our struct
            
            for track = 1:num_tracks
                
                allDecodedReplay = decoded_replay_events(track).replay_events;
                
                % We get the size of the replay events
                pixel_sizes = cellfun(@size, {allDecodedReplay(:).decoded_position}, 'UniformOutput', false);
                timeSizeMat = cell2mat(cellfun(@(x) x(2), pixel_sizes, 'UniformOutput', false));
                
                shuffled_struct(track).replay_events = allDecodedReplay;
                
                index = {decoded_replay_events(track).replay_events(:).timebins_index};  %index is needed when analyzing segments of replay event
                
                % We subset the decoded position based on index to account
                % for segment replay events
                
                cellArrayDecodedPos = {estimated_position(track).replay_events.replay};
                cellArrayDecodedPos = cellfun(@(mat, index) mat(:, index), cellArrayDecodedPos, index, 'UniformOutput', false);
                
                [shuffled_struct(track).replay_events.decoded_position] = deal(cellArrayDecodedPos{:});

                % Filter : If event duration is more than 5x timebin
                % (usually 0.020 ms), we NaN the decoded position

                [shuffled_struct(track).replay_events(timeSizeMat < 5).decoded_position] = deal(NaN);
            end
            
        %% PRE place_field_circular_shift    
        case 'PRE place_field_circular_shift'
        
            % Initiate struct
            shuffled_place_fields = place_fields_BAYESIAN;
            
            for track = 1:num_tracks
                num_cells = size(shuffled_place_fields.track(track).raw,2);
                
                % For each cell, we circularly shift position of place
                % fields
                                
                for i = 1:num_cells
                    field =  cell2mat(shuffled_place_fields.track(track).raw(i));
                    shuffled_place_fields.track(track).raw(i) = {circshift(field, ceil(rand*length(field)))};
                end
            end
            
            estimated_position = bayesian_decoding(shuffled_place_fields, replayEvents_bayesian_spike_count, tracks_compared);
            
            % We assign to our struct
            
            for track = 1:num_tracks
                
                allDecodedReplay = decoded_replay_events(track).replay_events;
                
                % We get the size of the replay events
                pixel_sizes = cellfun(@size, {allDecodedReplay(:).decoded_position}, 'UniformOutput', false);
                timeSizeMat = cell2mat(cellfun(@(x) x(2), pixel_sizes, 'UniformOutput', false));
                
                shuffled_struct(track).replay_events = allDecodedReplay;
                
                index = {decoded_replay_events(track).replay_events(:).timebins_index};  %index is needed when analyzing segments of replay event
                
                % We subset the decoded position based on index to account
                % for segment replay events
                
                cellArrayDecodedPos = {estimated_position(track).replay_events.replay};
                cellArrayDecodedPos = cellfun(@(mat, index) mat(:, index), cellArrayDecodedPos, index, 'UniformOutput', false);
                
                [shuffled_struct(track).replay_events.decoded_position] = deal(cellArrayDecodedPos{:});

                % Filter : If event duration is more than 5x timebin
                % (usually 0.020 ms), we NaN the decoded position

                [shuffled_struct(track).replay_events(timeSizeMat < 5).decoded_position] = deal(NaN);
            end
    end
    
    %% Score replay for decoded events with shuffled place fields
    shuffle_output = replay_scoring(shuffled_struct, place_fields_BAYESIAN, analysis_type);  %don't do shuffle for spearman
    for track = 1 : num_tracks
        for event = 1: num_replay_events
            shuffled_track(track).replay_events(event).linear_score(s) = shuffle_output(track).replay_events(event).linear_score;
            shuffled_track(track).replay_events(event).weighted_corr_score(s) = shuffle_output(track).replay_events(event).weighted_corr_score;
            shuffled_track(track).replay_events(event).path_score(s) = shuffle_output(track).replay_events(event).path_score;
        end
        
    end
    
end

% save shuffle choice
for track = 1 : num_tracks
    shuffled_track(track).shuffle_choice = shuffle_choice;
end

end