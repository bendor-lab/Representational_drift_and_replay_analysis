% LAP PRE SPIKE TRAIN CIRCULAR SHIFT
% Disrupts temporal domain. Shuffle used when analysing laps separately 
% INPUT:
    % decoded_thetaSeq, directional_place_fields,theta_spike_count - data structs
    % track: current track ID being analysed
    % lap_id: current lap ID being analysed
    % num_shuffles: integer
    % save_shuffles: 1 or 0. To save shuffled structures
    % save_option: 'Y' or []. To save function outputs


function [PREspike_train_circ_shuffle_scores, PREspike_train_circular_shuffles] = lap_thetaseq_phase_PRE_spike_circ_shuffle(decoded_thetaSeq,directional_place_fields,theta_spike_count,track,lap_id,num_shuffles,save_shuffles,save_option)

if isempty(theta_spike_count)
    load Theta\theta_seq_bayesian_spike_count.mat
end
if isempty(decoded_thetaSeq)
    load Theta\decoded_theta_sequences.mat
end
if isempty(directional_place_fields)    
    load extracted_directional_place_fields.mat
end

%Rename variables
place_fields = directional_place_fields;
spikecount = theta_spike_count;
decoded_sequences =  decoded_thetaSeq;
PREspike_train_circular_shuffles = [];

%Remove not needed fields for speed and memory
if isfield(decoded_sequences.direction1,'track_active_units_ID')
    decoded_sequences.direction1 = rmfield(decoded_sequences.direction1,'track_active_units_ID');
    decoded_sequences.direction2 = rmfield(decoded_sequences.direction2,'track_active_units_ID');
end
decoded_sequences.direction1(track).theta_sequences = rmfield(decoded_sequences.direction1(track).theta_sequences,'timebins_centre');
decoded_sequences.direction2(track).theta_sequences = rmfield(decoded_sequences.direction2(track).theta_sequences,'timebins_centre');

clear theta_spike_count theta_peak theta_troughs decoded_thetaSeq centered_averaged_thetaSeq

% Find number of cores available
p = gcp; % Starting parallel pool
if isempty(p)
    num_cores = 0;
else
    num_cores = p.NumWorkers; %leave one core available for other computer tasks
end
loops = ceil(num_shuffles/num_cores);

% Run shuffles
parfor jj = 1 : num_cores
    [out{jj}.shuffled_thetaseq,out2{jj}] = run_spike_circular_shuffle(loops,decoded_sequences,spikecount,place_fields,track,lap_id,save_shuffles);
end

future_fields = {'direction1','direction2','unidirectional'};% there will be 3 fields
if save_shuffles == 1
    for d = 1 : length(future_fields)
        for t = 1 : num_tracks
            cellArray1 = cellfun(@(x) x.(strcat(future_fields{d}))(t).mean_relative_position, out2,'UniformOutput',0)';
            PREspike_train_circular_shuffles.(sprintf('%s',future_fields{d}))(t).mean_relative_position = vertcat(cellArray1{:});
            PREspike_train_circular_shuffles.(sprintf('%s',future_fields{d}))(t).mean_relative_position = PREspike_train_circular_shuffles.(sprintf('%s',future_fields{d}))(t).mean_relative_position(1:num_shuffles,:);
        end
    end
    if strcmp(save_option,'Y')
        save('Theta\shuffles_PREspikeTrain.mat','PREspike_train_circular_shuffles','-v7.3')
    end
end

% Save in final structure
for d = 1 : length(future_fields)
    for jj = 1 : num_cores
        num_col = size(out{jj}.shuffled_thetaseq.(sprintf('%s',future_fields{d})).quadrant_ratio,2);
        if jj == 1
            spike_shuffle.(sprintf('%s',future_fields{d})).quadrant_ratio(:,(jj:num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',future_fields{d})).quadrant_ratio;
            spike_shuffle.(sprintf('%s',future_fields{d})).weighted_corr(:,(jj:num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',future_fields{d})).weighted_corr;
        else
            spike_shuffle.(sprintf('%s',future_fields{d})).quadrant_ratio(:,((jj-1)*num_col+1:jj*num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',future_fields{d})).quadrant_ratio;
            spike_shuffle.(sprintf('%s',future_fields{d})).weighted_corr(:,((jj-1)*num_col+1:jj*num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',future_fields{d})).weighted_corr;
        end
    end
end

PREspike_train_circ_shuffle_scores = spike_shuffle;
if strcmp(save_option,'Y')
    save('Theta\thetaSeq_PREspikeTrain_circ_shuffle.mat','PREspike_train_circ_shuffle_scores','-v7.3')
end

end

function [all_shuffles,matrix_shuffles] = run_spike_circular_shuffle(loops,decoded_sequences,theta_spike_count,directional_place_fields,track_id,lap_id,save_shuffles)
 
parameters = list_of_parameters;
fields = fieldnames(decoded_sequences);
fields = fields(cellfun(@(s) isempty(strmatch ('phase', s)), fieldnames(decoded_sequences)));
matrix_shuffles = [];

% Get spike count for the whole session
thetaseq_spike_count = theta_spike_count.n.replay;

% creates template structure to save all position shuffles
future_fields = {'direction1','direction2','unidirectional'};% there will be 3 fields
for d = 1 : length(future_fields)
    all_shuffles.(sprintf('%s',future_fields{d})).quadrant_ratio = zeros(1,loops);
    all_shuffles.(sprintf('%s',future_fields{d})).weighted_corr= zeros(1,loops);
end

if save_shuffles == 1
    % preallocate
    matrix_shuffles.direction1.mean_relative_position = repmat({NaN(parameters.theta_position_window_width+1,parameters.number_cycle_bins)},loops,1);
    matrix_shuffles.direction2.mean_relative_position = repmat({NaN(parameters.theta_position_window_width+1,parameters.number_cycle_bins)},loops,1);
    matrix_shuffles.unidirectional.mean_relative_position = repmat({NaN(parameters.theta_position_window_width+1,parameters.number_cycle_bins)},loops,1);
end

% START RUNNING SHUFFLES
for s = 1 : loops
    %disp(s)
    
    % Initiate structures
    decoded_thetaSeq = decoded_sequences;
    %Remove not needed fields for speed and memory
    decoded_thetaSeq.direction1(track_id).theta_sequences = rmfield(decoded_thetaSeq.direction1(track_id).theta_sequences,'decoded_position');
    decoded_thetaSeq.direction2(track_id).theta_sequences = rmfield(decoded_thetaSeq.direction2(track_id).theta_sequences,'decoded_position');
    
    % Create a copy of output structure
    shuffled_struct = decoded_sequences;
    to_remove = {'timebins_edges','timebins_edge_index','timebins_centre_index'}; %Remove not needed fields for speed and memory
    shuffled_struct.direction1(track_id).theta_sequences = rmfield(shuffled_struct.direction1(track_id).theta_sequences,to_remove);
    shuffled_struct.direction2(track_id).theta_sequences = rmfield(shuffled_struct.direction2(track_id).theta_sequences,to_remove);
    
    % For each theta window, find central theta cycle, take spike count matrix and do circular shuffle on the spikes of each cell (so, for each row)
    for d = 1 : length(fields) %for each direction
        for tw = 1 : size(decoded_thetaSeq.(sprintf('%s',fields{d}))(track_id).theta_sequences,2) %for each theta window
            cycle_idcs = decoded_thetaSeq.(sprintf('%s',fields{d}))(track_id).theta_sequences(tw).timebins_centre_index; % theta window indices in n.replay            
            % Shift each row (spike count per cell) within central theta cycle
            for i = 1 : size(thetaseq_spike_count,1)
                thetaseq_spike_count(i,cycle_idcs) = circshift(thetaseq_spike_count(i,cycle_idcs),ceil(rand*length(cycle_idcs)),2);
            end
        end
    end
    
    % Save in structure to input in bayesian decoding code
    theta_spike_count.n.replay = thetaseq_spike_count;
    
    % Run bayesian decoding
    estimated_position.dir1 = bayesian_decoding_lap_thetaseq(directional_place_fields(track_id).dir1.Complete_Lap{1,lap_id},theta_spike_count,track_id);
    estimated_position.dir2 = bayesian_decoding_lap_thetaseq(directional_place_fields(track_id).dir2.Complete_Lap{1,lap_id},theta_spike_count,track_id);
    
    % replace the decoded position in the shuffle structure with the new shuffled decoded position
    for d = 1 : length(fields) %for each direction
        for tw = 1 : size(decoded_thetaSeq.(sprintf('%s',fields{d}))(track_id).theta_sequences,2) %for each theta window
            tw_idx =  decoded_thetaSeq.(sprintf('%s',fields{d}))(track_id).theta_sequences(tw).timebins_centre_index;
            shuffled_struct.(sprintf('%s',fields{d}))(track_id).theta_sequences(tw).decoded_position = estimated_position.(sprintf('%s','dir',num2str(d))).replay_OneTrack(:,tw_idx); % normalized by all tracks
        end
    end
    clear estimated_position
    
    % For each new shuffled structure, runs quantification methods
    % Get average theta cycle
    [centered_averaged_thetaSeq,~] = averaged_concat_theta_cycle(shuffled_struct,0);
    
    % Quadrant Ratio
    centered_averaged_thetaSeq = phase_quadrant_ratio(centered_averaged_thetaSeq); %quadrant_ratio_shuffle
    
    if save_shuffles == 1
        % keep shuffled theta window matrices
        matrix_shuffles.direction1.mean_relative_position{s} = centered_averaged_thetaSeq.direction1.mean_relative_position;
        matrix_shuffles.direction2.mean_relative_position{s} = centered_averaged_thetaSeq.direction2.mean_relative_position;
        matrix_shuffles.unidirectional.mean_relative_position{s} = centered_averaged_thetaSeq.unidirectional.mean_relative_position;
    end
    new_fields = fieldnames(centered_averaged_thetaSeq);
    % Weighted correlation
    for d = 1 : length(new_fields) %for each direction
        if isempty(centered_averaged_thetaSeq.(sprintf('%s',new_fields{d}))(track_id).thetaseq)
            continue
        end
        central_cycle = centered_averaged_thetaSeq.(sprintf('%s',new_fields{d}))(track_id).mean_relative_position;
        centered_averaged_thetaSeq.(sprintf('%s',new_fields{d}))(track_id).weighted_corr = weighted_correlation(central_cycle);
    end

    % Adds the scoring results of each shuffle to the same structure
    for d = 1 : length(new_fields)
        if isempty(centered_averaged_thetaSeq.(sprintf('%s',new_fields{d}))(track_id).thetaseq)
            continue
        end
        all_shuffles.(sprintf('%s',new_fields{d})).quadrant_ratio(s) = centered_averaged_thetaSeq.(sprintf('%s',new_fields{d}))(track_id).quadrant_ratio;
        all_shuffles.(sprintf('%s',new_fields{d})).weighted_corr(s) = centered_averaged_thetaSeq.(sprintf('%s',new_fields{d}))(track_id).weighted_corr;
    end
    
end
end

