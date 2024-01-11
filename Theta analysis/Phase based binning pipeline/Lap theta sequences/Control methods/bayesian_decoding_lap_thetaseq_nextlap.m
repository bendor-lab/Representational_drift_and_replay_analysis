function estimated_position = bayesian_decoding_lap_thetaseq(place_fields,theta_spike_count,track_id)
% INPUTS:
   % place fields: matrix or []. Place fields that want to be used as a template in the decoding. If empty, it will load place fields for the whole session (extracted_place_fields_BAYESIAN.mat)
   % bayesian spike count: matrix with spikes per time bin - can be loaded
   % or input (string). The string can be to determine if it's decoding replay or theta sequences.
   % thetaseq :1 for analysing theta sequences in direction 1, 2 for analysing theta sequences in direction 2, otherwise 0
   % Save_option: enter 'Y' for saving. Else, won't save.
   % OUTPUTS:
   % estimated_position structure.
   % Loads: 'extracted_position','extracted_place_fields_BAYESIAN','bayesian_spike_count'
   
   parameters=list_of_parameters;
   load extracted_position
   load extracted_directional_place_fields.mat
   if isempty(theta_spike_count)
       load Theta\theta_seq_bayesian_spike_count.mat
   end
   theta_run_bin_width = theta_spike_count.theta_bins_width_concat;
   
   
   %%%%% BAYESIAN DECODING  %%%%%%
   
   % Creates a vector of position bins and finds centre
   position_bin_edges = place_fields.x_bin_edges;
   estimated_position.position_bin_centres = place_fields.x_bin_centres;
   
   % Bin position for decoding error
   estimated_position.discrete_position = NaN(size(position.linear(track_id).linear));
   discrete_position = discretize(position.linear(track_id).linear,position_bin_edges); %group position points in bins delimited by edges
   index = find(~isnan(discrete_position));
   estimated_position.discrete_position(index) = estimated_position.position_bin_centres(discrete_position(index)); %creates new positions based on centre of bins
   estimated_position.replay_time_centered = theta_spike_count.replay_time_centered;
   estimated_position.replay_time_edges = theta_spike_count.replay_time_edges;

   estimated_position.replay = zeros(length(estimated_position.position_bin_centres),length(theta_spike_count.replay_time_centered));
   n.replay = theta_spike_count.n.replay;
   estimated_position.replay = zeros(length(estimated_position.position_bin_centres),length(n.replay));
   
   % When decodingfor theta sequences, will have to remove cells from other tracks
   all_cells = unique([directional_place_fields(1).place_fields.good_place_cells directional_place_fields(2).place_fields.good_place_cells]); % all good place cells for both directions
   [~,idd] = setdiff(all_cells,place_fields.good_cells); % find place cells in the track for the current direction analyzed
   n.replay(idd,:) = [];
   estimated_position.active_units_ID = intersect(all_cells,place_fields.good_cells);
   
   % Find ratemaps depending on what is being analysed
   place_field_index = place_fields.good_cells; %when analysing directional theta sequences
   idd2 = setdiff(place_fields.good_cells,all_cells);
   place_field_index(ismember(place_field_index,idd2)) = [];
   
   all_place_fields = [];
   for k = 1 :length(place_field_index)
       single_place_field = place_fields.smooth{place_field_index(k)}; %get raw place field
       single_place_field(find(isnan(single_place_field))) = 0; % remove NaNs in place field and replace by 0
       if min(single_place_field)<0
           disp('error- spike rate of place field less than zero')
       end
       all_place_fields(k,:) = single_place_field;
   end
   
   % Apply formula of bayesian decoding
   estimated_position.replay = reconstruct(n.replay,all_place_fields,theta_run_bin_width);
      
   %%%%%% NORMALIZING  %%%%%%%
   %       columns need to sum to 1 (total probability across positions.
   %       options are normalizing across tracks or just within a track
   
   summed_probability_replay = zeros(1,size(estimated_position(1).replay,2));

   % Sum probabilties across rows (cells)
   estimated_position.replay_OneTrack = NaN(size(estimated_position.replay)); % in older version replay_raw
   summed_probability_replay = summed_probability_replay + sum(estimated_position.replay,1);  
   summed_probability.replay = summed_probability_replay;

   % Divide decoded position by summed probability  (normalize)
   for j=1:size(estimated_position.replay,2)
       estimated_position.replay_raw(:,j) = estimated_position.replay(:,j);
       estimated_position.replay_OneTrack(:,j) = estimated_position.replay(:,j)./sum(estimated_position.replay(:,j)); %normalized by one track only (in older version replay_raw)
       estimated_position.replay(:,j) = estimated_position.replay(:,j)./summed_probability.replay(j); % normalized by the sum of prob of all tracks
   end
   % Calculate replay bias - measures which track has higher probability values for estimated positions
   estimated_position.replay_bias=sum(estimated_position.replay,1);
       
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function estimated_position=reconstruct(n,all_place_fields,bin_width)

% allocate variable for speed
estimated_position= zeros(size(all_place_fields,2),size(n,2)); % size [n_cells , n_time_bins]
% Creates matrix where rows are cells and columns are position bins
bin_length = size(all_place_fields,2); %columns
number_of_cells = size(all_place_fields,1); %rows
parameters.bayesian_threshold=10.^(log2(number_of_cells)-log2(400)); % small value multiplied to all values to get rid of zeros
all_place_fields(find(all_place_fields<parameters.bayesian_threshold)) = parameters.bayesian_threshold;
sum_of_place_fields = sum(all_place_fields,1);  % adds up spikes per bin (used later for exponential)

for j = 1: size(n,2)
    n_spikes = n(:,j)*ones(1,bin_length); %number of spikes in time bin
    pre_product = all_place_fields.^n_spikes; % pl field values raised to num of spikes
    pre_product(find(pre_product<parameters.bayesian_threshold)) = parameters.bayesian_threshold;
    product_of_place_fields = prod(pre_product,1); %product of pl fields
    if length(bin_width) > 1 %if it's running theta sequences, each bin width is different
        estimated_position(:,j) = product_of_place_fields.*(exp(-bin_width(j)*sum_of_place_fields)); % bayesian formula
    else
        estimated_position(:,j) = product_of_place_fields.*(exp(-bin_width*sum_of_place_fields)); % bayesian formula
    end
end
%NOTE- columns do not sum to 1.  this is done at a later stage to allow normalization within a track or across tracks

end
