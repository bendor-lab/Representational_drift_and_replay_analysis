function estimated_position = bayesian_decoding_modified(place_fields_BAYESIAN,bayesian_spike_count,save_option)
% Run normalization on track pairs (across 1 and 2, and across 3 and 4 independently), and only uses good cells of both tracks for each pair.
% This is a control method
% INPUTS:
   % place fields: matrix or []. Place fields that want to be used as a template in the decoding. If empty, it will load place fields for the whole session (extracted_place_fields_BAYESIAN.mat)
   % Save_option: enter 'Y' for saving. Else, won't save.
% OUTPUTS:
    % estimated_position structure. 
% Loads: 'extracted_position','extracted_place_fields_BAYESIAN','bayesian_spike_count'
   
   parameters=list_of_parameters;
   load extracted_position
   
   if strcmp(bayesian_spike_count, 'replayEvents_bayesian_spike_count')
       load replayEvents_bayesian_spike_count  %if decoding replay events (which will have different time bins)
       bayesian_spike_count = replayEvents_bayesian_spike_count;       
   elseif strcmp(bayesian_spike_count, 'replay_place_fields_spike_count')
       load replay_place_fields_spike_count %if decoding place fields within replay events
   elseif isempty(bayesian_spike_count) %if decoding the whole session
       load bayesian_spike_count
   end
   
   % If not planning to use only place fields from a specific period of time, load place fields from the whole session
   if isempty(place_fields_BAYESIAN)
       load extracted_place_fields_BAYESIAN
   end
   
   %%%%% BAYESIAN DECODING  %%%%%%
   
   for track_id = 1 : length(place_fields_BAYESIAN.track)
       
       % Creates a vector of position bins and finds centre
       position_bin_edges = place_fields_BAYESIAN.track(track_id).x_bin_edges;
       estimated_position(track_id).position_bin_centres = place_fields_BAYESIAN.track(track_id).x_bin_centres;
       
       % Bin position for decoding error
       estimated_position(track_id).discrete_position = NaN(size(position.linear(track_id).linear));
       discrete_position = discretize(position.linear(track_id).linear,position_bin_edges); %group position points in bins delimited by edges
       index = find(~isnan(discrete_position));
       estimated_position(track_id).discrete_position(index) = estimated_position(track_id).position_bin_centres(discrete_position(index)); %creates new positions based on centre of bins
       
       if isfield(bayesian_spike_count,'replay_events')  % When running replay events separately
           
           estimated_position(track_id).replay_events = bayesian_spike_count.replay_events;
           
           for i = 1 : length(bayesian_spike_count.replay_events)               
               estimated_position(track_id).replay_events(i).replay = zeros(length(estimated_position(track_id).position_bin_centres),length(estimated_position(track_id).replay_events(i).replay_time_centered));
           end
           
           n.replay = bayesian_spike_count.n.replay;
           estimated_position(track_id).replay = zeros(length(estimated_position(track_id).position_bin_centres),length(n.replay));
           
       else  %when computing decoded position for entire experiment
           
           % Time bins for replay : takes time vectors and centres each bin
           estimated_position(track_id).replay_time_edges = bayesian_spike_count.replay_time_edges;
           estimated_position(track_id).replay_time_centered = bayesian_spike_count.replay_time_centered; %centres of bins
           estimated_position(track_id).replay = zeros(length(estimated_position(track_id).position_bin_centres),length(estimated_position(track_id).replay_time_centered));
           %time bins for run
           if isfield(bayesian_spike_count,'run_time_edges')
               estimated_position(track_id).run_time_edges = bayesian_spike_count.run_time_edges;
               estimated_position(track_id).run_time_centered =  bayesian_spike_count.run_time_centered;%centres of bins
               estimated_position(track_id).run = zeros(length(estimated_position(track_id).position_bin_centres),length(estimated_position(track_id).run_time_centered));
           end
           
           n.replay = bayesian_spike_count.n.replay;
           if isfield(bayesian_spike_count,'run_time_edges')
               n.run = bayesian_spike_count.n.run;
           end
       end
       
       % Find ratemaps
       if isfield(place_fields_BAYESIAN,'good_place_cells')
           if track_id < 3
               place_field_index = intersect(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
           else
               place_field_index = intersect(place_fields_BAYESIAN.track(3).good_cells,place_fields_BAYESIAN.track(4).good_cells);
           end
           %place_field_index = place_fields_BAYESIAN.good_place_cells;  %use all place cells
       elseif isfield(place_fields_BAYESIAN.track,'good_cells')
           place_field_index = place_fields_BAYESIAN.track.good_cells;
       else
           disp('ERROR- field good_place_cells missing');
           place_field_index = place_fields_BAYESIAN.track.pyramidal_cells;
       end
       
       all_place_fields = [];
       for k=1:length(place_field_index)
           single_place_field = place_fields_BAYESIAN.track(track_id).raw{place_field_index(k)}; %get raw place field
           single_place_field(find(isnan(single_place_field))) = 0; % remove NaNs in place field and replace by 0
           if min(single_place_field)<0
               disp('error- spike rate of place field less than zero')
           end
           all_place_fields(k,:) = single_place_field;
       end
       
       %%%%%% TEMPORAL ADDITION
       % When decoding as individual tracks, will have to remove cells from other tracks
       [~,idd]=setdiff(place_fields_BAYESIAN.good_place_cells,place_field_index);
       n.replay(idd,:) = [];
       if isfield(bayesian_spike_count,'run_time_edges')
        n.run(idd,:) = [];
       end
       
       
       % Apply formula of bayesian decoding
       estimated_position(track_id).replay = reconstruct(n.replay,all_place_fields,parameters.replay_bin_width);
       if isfield(bayesian_spike_count,'run_time_edges')
           estimated_position(track_id).run = reconstruct(n.run,all_place_fields,parameters.run_bin_width);
       end
   end
   
   
   %%%%%% NORMALIZING  %%%%%%%
   %       columns need to sum to 1 (total probability across positions.
   %       options are normalizing across tracks or just within a track

   summed_probability_replay = zeros(1,size(estimated_position(1).replay,2));
   if isfield(bayesian_spike_count,'run_time_edges')
       summed_probability_run = zeros(1,size(estimated_position(1).run,2));
   end   
   
   for track_id=1:2%length(place_fields_BAYESIAN.track)     %normalize probability to sum to 1
       
       % Sum probabilties across rows (cells)
       estimated_position(track_id).replay_OneTrack = NaN(size(estimated_position(track_id).replay)); % in older version replay_raw
       summed_probability_replay=summed_probability_replay+sum(estimated_position(track_id).replay,1);
       if isfield(bayesian_spike_count,'run_time_edges')
           estimated_position(track_id).run_OneTrack = NaN(size(estimated_position(track_id).run)); % in older version run_raw
           summed_probability_run=summed_probability_run+sum(estimated_position(track_id).run,1);
       end
   end
   
   for track_id=1:2%length(place_fields_BAYESIAN.track)
       summed_probability(track_id).replay = summed_probability_replay;
       if isfield(bayesian_spike_count,'run_time_edges')
           summed_probability(track_id).run = summed_probability_run;
       end
   end
   
   % Divide decoded position by summed probability  (normalize)
   for track_id=1:2%length(place_fields_BAYESIAN.track)
       for j=1:size(estimated_position(track_id).replay,2)
           estimated_position(track_id).replay_OneTrack(:,j) = estimated_position(track_id).replay(:,j)./sum(estimated_position(track_id).replay(:,j)); %normalized by one track only (in older version replay_raw)
           estimated_position(track_id).replay(:,j) = estimated_position(track_id).replay(:,j)./summed_probability(track_id).replay(j); % normalized by the sum of prob of all tracks
           
       end
       % Calculate replay bias - measures which track has higher probability values for estimated positions
       estimated_position(track_id).replay_bias=sum(estimated_position(track_id).replay,1);
       
       if isfield(bayesian_spike_count,'run_time_edges')
           for j=1:size(estimated_position(track_id).run,2)
               estimated_position(track_id).run_OneTrack(:,j) = estimated_position(track_id).run(:,j)./sum(estimated_position(track_id).run(:,j)); %in older version run_raw
               estimated_position(track_id).run(:,j) = estimated_position(track_id).run(:,j)./summed_probability(track_id).run(j);
           end
           
           [estimated_position(track_id).max_prob,index] = max(estimated_position(track_id).run,[],1);
           estimated_position(track_id).peak_position = NaN(size(index));
           valid_bins = (find(~isnan(index)));
           estimated_position(track_id).peak_position(valid_bins) = estimated_position(track_id).position_bin_centres(index(valid_bins));
           estimated_position(track_id).run_bias = sum(estimated_position(track_id).run,1);
           estimated_position(track_id).run_error = abs(estimated_position(track_id).peak_position-interp1(position.t, estimated_position(track_id).discrete_position, estimated_position(track_id).run_time_centered, 'nearest'));
       end
   end
   
   
   %%%%%%%
   summed_probability_replay = zeros(1,size(estimated_position(1).replay,2));
   if isfield(bayesian_spike_count,'run_time_edges')
       summed_probability_run = zeros(1,size(estimated_position(1).run,2));
   end
   for track_id=3:4%length(place_fields_BAYESIAN.track)     %normalize probability to sum to 1
       
       % Sum probabilties across rows (cells)
       estimated_position(track_id).replay_OneTrack = NaN(size(estimated_position(track_id).replay)); % in older version replay_raw
       summed_probability_replay=summed_probability_replay+sum(estimated_position(track_id).replay,1);
       if isfield(bayesian_spike_count,'run_time_edges')
           estimated_position(track_id).run_OneTrack = NaN(size(estimated_position(track_id).run)); % in older version run_raw
           summed_probability_run=summed_probability_run+sum(estimated_position(track_id).run,1);
       end
   end
   
   for track_id=3:4%length(place_fields_BAYESIAN.track)
       summed_probability(track_id).replay = summed_probability_replay;
       if isfield(bayesian_spike_count,'run_time_edges')
           summed_probability(track_id).run = summed_probability_run;
       end
   end
   
   % Divide decoded position by summed probability  (normalize)
   for track_id=3:4%length(place_fields_BAYESIAN.track)
       for j=1:size(estimated_position(track_id).replay,2)
           estimated_position(track_id).replay_OneTrack(:,j) = estimated_position(track_id).replay(:,j)./sum(estimated_position(track_id).replay(:,j)); %normalized by one track only (in older version replay_raw)
           estimated_position(track_id).replay(:,j) = estimated_position(track_id).replay(:,j)./summed_probability(track_id).replay(j); % normalized by the sum of prob of all tracks
           
       end
       % Calculate replay bias - measures which track has higher probability values for estimated positions
       estimated_position(track_id).replay_bias=sum(estimated_position(track_id).replay,1);
       
       if isfield(bayesian_spike_count,'run_time_edges')
           for j=1:size(estimated_position(track_id).run,2)
               estimated_position(track_id).run_OneTrack(:,j) = estimated_position(track_id).run(:,j)./sum(estimated_position(track_id).run(:,j)); %in older version run_raw
               estimated_position(track_id).run(:,j) = estimated_position(track_id).run(:,j)./summed_probability(track_id).run(j);
           end
           
           [estimated_position(track_id).max_prob,index] = max(estimated_position(track_id).run,[],1);
           estimated_position(track_id).peak_position = NaN(size(index));
           valid_bins = (find(~isnan(index)));
           estimated_position(track_id).peak_position(valid_bins) = estimated_position(track_id).position_bin_centres(index(valid_bins));
           estimated_position(track_id).run_bias = sum(estimated_position(track_id).run,1);
           estimated_position(track_id).run_error = abs(estimated_position(track_id).peak_position-interp1(position.t, estimated_position(track_id).discrete_position, estimated_position(track_id).run_time_centered, 'nearest'));
       end
   end
   
   % If running replay events separately, also extract individual events from the estimated position matrix
   if isfield(bayesian_spike_count,'replay_events') 
       for track_id = 1:length(place_fields_BAYESIAN.track)
           for event = 1 : length(bayesian_spike_count.replay_events)
               thisReplay_indxs = bayesian_spike_count.replay_events_indices == event;
               estimated_position(track_id).replay_events(event).replay = estimated_position(track_id).replay(:,thisReplay_indxs);
               estimated_position(track_id).replay_events(event).replay_OneTrack = estimated_position(track_id).replay_OneTrack(:,thisReplay_indxs);
           end
       end
   end
   
   
   if strcmp(save_option, 'Y')
       save estimated_position estimated_position
   end
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function estimated_position=reconstruct(n,all_place_fields,bin_width)
    
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
        estimated_position(:,j) = product_of_place_fields.*(exp(-bin_width*sum_of_place_fields)); % bayesian formula 
    end
    %NOTE- columns do not sum to 1.  this is done at a later stage to allow normalization within a track or across tracks

end
