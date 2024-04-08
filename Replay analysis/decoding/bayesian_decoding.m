function estimated_position = bayesian_decoding(place_fields_BAYESIAN,bayesian_spike_count, tracks_compared)

% INPUTS :
% - Place field struct with 20 cm x_bins, for each track of interest
% - Bayesian spike count matrix (spikes per time for each track + candidat replay events)
% - tracks_compared : track concatenated for normalisation, format = array of track indices 1 -> 4

% OUTPUTS :
% - estimated_position struct

% This function load extracted_position.mat and list_of_parameters (needs to be in the PATH)

% Modified by Pierre Varichon 2024

%% Loading data
% Get the parameters for analysis
parameters=list_of_parameters;
run_bin_width = parameters.run_bin_width;
replay_run_bin_width = parameters.replay_bin_width;
% Get the position of the animal on each track - load position struct
load("extracted_position");

%% Parsing data before decoding

% We iterate through tracks of interest
for trackIndex = 1:length(tracks_compared)
    
    trackOI = tracks_compared(trackIndex);
    
    % Creates a vector of position bins and finds centre --
    % The position bins are 10 cm wide for bayesian decoding
    position_bin_edges = place_fields_BAYESIAN.track(trackOI).x_bin_edges;
    estimated_position(trackIndex).position_bin_centres = place_fields_BAYESIAN.track(trackOI).x_bin_centres;
    
    % Bin position for decoding error --
    sizePositionData = size(position.linear(trackOI).linear);
    
    % Initialize all positions with NaN
    estimated_position(trackIndex).discrete_position = NaN(sizePositionData);
    
    % Group position points in the 10 cm bins delimited by edges (so that they can act as indexs)
    discrete_position = discretize(position.linear(trackOI).linear,position_bin_edges);
    
    % Get all the poitions where discrete_position is not NaN (where animal is in a correct bin)
    index = find(~isnan(discrete_position));
    
    % Creates new positions based on centre of bins
    estimated_position(trackIndex).discrete_position(index) = estimated_position(trackIndex).position_bin_centres(discrete_position(index));
    
    % We save all the potential replay events in estimated_position
    estimated_position(trackIndex).replay_events = bayesian_spike_count.replay_events;
    
    % For each potential replay event, we create a position probability
    % matrix full of zeros
    for i = 1 : length(bayesian_spike_count.replay_events)
        estimated_position(trackIndex).replay_events(i).replay = zeros(length(estimated_position(trackIndex).position_bin_centres),length(estimated_position(trackIndex).replay_events(i).replay_time_centered));
    end
    
    % We get the whole good place cell on 4 tracks x concatenated replay events durations matrix,
    % to get the total duration
    n.replay = bayesian_spike_count.n.replay;
    
    % We create a global probable position x total duration and initiate it with zeros in out struct
    estimated_position(trackIndex).replay = zeros(length(estimated_position(trackIndex).position_bin_centres),length(n.replay));
    
    % We get the valid place cell index (all good place cells on at least one of the track of interest)
    place_field_index = unique([place_fields_BAYESIAN.track(tracks_compared).good_cells]);
    
    % We save and clean all the place fields in all_place_fields (nb of PF x 20 matrix)
    all_place_fields = zeros(length(place_field_index), length(estimated_position(trackIndex).position_bin_centres));
    
    for k = 1:length(place_field_index)
        % Get the raw place field
        single_place_field = place_fields_BAYESIAN.track(trackOI).raw{place_field_index(k)};
        % Remove NaNs in place field and replace by 0
        single_place_field(isnan(single_place_field)) = 0;
        % We check for aberrant < 0 values
        if min(single_place_field)<0
            disp('error- spike rate of place field less than zero')
        end
        % We add to the array
        all_place_fields(k,:) = single_place_field;
    end
    
    % Now we can subset n.replay to only keep good place cells in our
    % comparaison
    n.replay = n.replay(place_field_index, :);
    
    %% Bayesian decoding
    
    estimated_position(trackIndex).replay = reconstruct(n.replay,all_place_fields,replay_run_bin_width);
    
    % For running periods
    if isfield(bayesian_spike_count,'run_time_edges')
        estimated_position(trackIndex).run = reconstruct(n.run,all_place_fields,run_bin_width);
    end
    
    % This gives a non-normalised probability matrix
    
end

%% Normalisation

% Columns need to sum to 1 (total probability across positions).
% The normalisation across track is done for the tracks of interest

% Create a sum of probabilities vector, of the size equal to all replay
% events durations

summed_probability_replay = zeros(1,size(estimated_position(1).replay, 2));
if isfield(bayesian_spike_count,'run_time_edges')
    summed_probability_run = zeros(1,size(estimated_position(1).run, 2));
end

% Get the sum of the probability of all tracks of interest
for trackIndex = 1:length(tracks_compared)
    
    % Sum probabilties across rows (cells)
    % Initiate replay_OneTrack with NaNs
    estimated_position(trackIndex).replay_OneTrack = NaN(size(estimated_position(trackIndex).replay));
    % Increment summed_probability_replay by the sum of the current
    % track probabilities for each cell
    summed_probability_replay = summed_probability_replay + sum(estimated_position(trackIndex).replay, 1);
    
    if isfield(bayesian_spike_count,'run_time_edges')
        estimated_position(trackIndex).run_OneTrack = NaN(size(estimated_position(trackIndex).run));
        summed_probability_run=summed_probability_run+sum(estimated_position(trackIndex).run,1);
    end
end

% For each track, copy the summed_probablity

for trackIndex = 1:length(tracks_compared)
    summed_probability(trackIndex).replay = summed_probability_replay;
    if isfield(bayesian_spike_count,'run_time_edges')
        summed_probability(trackIndex).run = summed_probability_run;
    end
end

% Divide decoded position by summed probability  (normalize to 1) --
% For each track
for trackIndex = 1:length(tracks_compared)
    
    % For each time bin in the whole session
    % We save the probabilities, raw, normalised for one track or
    % normalised across tracks
    
    % Not normalised
    estimated_position(trackIndex).replay_raw(:,:) = estimated_position(trackIndex).replay(:,:);
    % Normalized by one track only (in older version replay_raw)
    estimated_position(trackIndex).replay_OneTrack(:,:) = estimated_position(trackIndex).replay(:,:)./sum(estimated_position(trackIndex).replay(:,:));
    % Normalized by the sum of prob of all tracks of interest
    estimated_position(trackIndex).replay(:,:) = estimated_position(trackIndex).replay(:,:)./summed_probability(trackIndex).replay;
    
    % Calculate replay bias - measures which track has higher probability values for estimated positions
    estimated_position(trackIndex).replay_bias = sum(estimated_position(trackIndex).replay, 1);
    
    % Same thing for running if in option
    if isfield(bayesian_spike_count,'run_time_edges')
        
        estimated_position(trackIndex).run_raw(:,:) = estimated_position(trackIndex).run(:,:);
        estimated_position(trackIndex).run_OneTrack(:,:) = estimated_position(trackIndex).run(:,:)./sum(estimated_position(trackIndex).run(:,:));
        estimated_position(trackIndex).run(:,:) = estimated_position(trackIndex).run(:,:)./summed_probability(trackIndex).run;
        
        % for no activity bins, the index will be 1, but the max prob will be NaN
        [estimated_position(trackIndex).max_prob,index] = max(estimated_position(trackIndex).run,[],1);
        estimated_position(trackIndex).peak_position = NaN(size(index));
        valid_bins = (find(~isnan(index)));
        estimated_position(trackIndex).peak_position(valid_bins) = estimated_position(trackIndex).position_bin_centres(index(valid_bins));
        estimated_position(trackIndex).run_bias = sum(estimated_position(trackIndex).run,1);
        estimated_position(trackIndex).run_error = abs(estimated_position(trackIndex).peak_position-interp1(position.t, estimated_position(trackIndex).discrete_position, estimated_position(trackIndex).run_time_centered, 'nearest'));
    end
end

% also extract individual events from the estimated position matrix
for trackIndex = 1:length(tracks_compared)
    
    replayIndicesVector = cellfun(@(x) find(bayesian_spike_count.replay_events_indices == x), ...
                                            num2cell(1:length(bayesian_spike_count.replay_events)), 'UniformOutput', false);
    
    for event = 1 : length(bayesian_spike_count.replay_events)
        
        thisReplay_indxs = replayIndicesVector{event};
        
        % We look for replay events with NO good cells, and set the probability
        % to 0 (to avoid bad bayesian results) - rare case
        if sum(sum(n.replay(:, thisReplay_indxs))) == 0
            % disp("Replay event n" + event + " contains no spikes. Set to zero.");
            estimated_position(trackIndex).replay_events(event).replay = zeros(size(all_place_fields,2), length(thisReplay_indxs));
            continue;
        end
        
        % If no problem, we save
        estimated_position(trackIndex).replay_events(event).replay = estimated_position(trackIndex).replay(:,thisReplay_indxs);
    end
end

end

%% FUNCTIONS

% Apply the bayesian decoding formula to the spiking matrix - 3D vectorized

function estimated_position = reconstruct(n,all_place_fields,bin_width)

% allocate variable for speed
estimated_position = zeros(size(all_place_fields,2),size(n,2)); % size [n_cells , n_time_bins]

% Creates matrix where rows are cells and columns are position bins
bin_length = size(all_place_fields,2); %columns
number_of_cells = size(all_place_fields,1); %rows
parameters.bayesian_threshold=10.^(log2(number_of_cells)-log2(400)); % small value multiplied to all values to get rid of zeros
all_place_fields(all_place_fields < parameters.bayesian_threshold) = parameters.bayesian_threshold;
sum_of_place_fields = sum(all_place_fields,1);  % adds up spikes per bin (used later for exponential)
sumOfPlaceFields2D = repmat(sum_of_place_fields', [1, size(n,2)]);

% Repeat the number of spikes per cell per x_bin on the track (to get same dimension as pf)
n_spikes = repmat(n, [1, 1, bin_length]);

% Create a 3D matrix full of repeating place field 2D matrices
allPlaceFields3D = repmat(reshape(all_place_fields, [number_of_cells, 1, bin_length]), [1, size(n,2), 1]);

% Place field values raised to num of spikes
pre_product = allPlaceFields3D.^n_spikes;

% Apply the threshold to remove 0 values
pre_product(pre_product<parameters.bayesian_threshold) = parameters.bayesian_threshold;

% Product of place fields of each cell
product_of_place_fields = prod(pre_product, 1);
product_of_place_fields = squeeze(product_of_place_fields);
product_of_place_fields = product_of_place_fields';

if length(bin_width) > 1 % if it's running theta sequences, each bin width is different
    estimated_position(:,:) = product_of_place_fields.*(exp(-bin_width.*sumOfPlaceFields2D)); % bayesian formula
else
    estimated_position(:,:) = product_of_place_fields.*(exp(-bin_width * sumOfPlaceFields2D)); % bayesian formula
end

% NOTE- columns do not sum to 1.  this is done at a later stage to allow normalization within and across tracks

end