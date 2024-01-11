% PRE SPIKE TRAIN CIRCULAR SHIFT
% Disrupts temporal domain.
% INPUT:
    % decoded_thetaSeq, directional_place_fields - data structs. If empty, loads them
    % num_shuffles: integer
    % save_shuffles: 1 or 0. To save shuffled structures
    % save_option: 'Y' or []. To save function outputs


function [PREspike_train_circ_shuffle_scores, PREspike_train_circular_shuffles] = thetaseq_phase_PRE_spike_circ_shuffle(decoded_thetaSeq,directional_place_fields,num_shuffles,save_shuffles,save_option)
tic
load Theta\theta_seq_bayesian_spike_count.mat
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

num_tracks =  length(decoded_sequences.direction1);

%Remove not needed fields for speed and memory
to_remove = {'timebins_centre'};
decoded_sequences.direction1 = rmfield(decoded_sequences.direction1,'track_active_units_ID');
decoded_sequences.direction2 = rmfield(decoded_sequences.direction2,'track_active_units_ID');
for t = 1 : num_tracks
    decoded_sequences.direction1(t).theta_sequences = rmfield(decoded_sequences.direction1(t).theta_sequences,to_remove);
    decoded_sequences.direction2(t).theta_sequences = rmfield(decoded_sequences.direction2(t).theta_sequences,to_remove);
end
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
    [out{jj}.shuffled_thetaseq,out2{jj}] = run_spike_circular_shuffle(loops,decoded_sequences,spikecount,place_fields,save_shuffles);
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
    for j = 1 : num_tracks
        for jj = 1 : num_cores
            num_col = size(out{jj}.shuffled_thetaseq.(sprintf('%s',future_fields{d}))(j).quadrant_ratio,2);
            if jj == 1
                spike_shuffle.(sprintf('%s',future_fields{d}))(j).quadrant_ratio(:,(jj:num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',future_fields{d}))(j).quadrant_ratio;
                spike_shuffle.(sprintf('%s',future_fields{d}))(j).weighted_corr(:,(jj:num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',future_fields{d}))(j).weighted_corr;
                %spike_shuffle.(sprintf('%s',future_fields{d}))(j).linear_score(:,(jj:num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',future_fields{d}))(j).linear_score;
            else
                spike_shuffle.(sprintf('%s',future_fields{d}))(j).quadrant_ratio(:,((jj-1)*num_col+1:jj*num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',future_fields{d}))(j).quadrant_ratio;
                spike_shuffle.(sprintf('%s',future_fields{d}))(j).weighted_corr(:,((jj-1)*num_col+1:jj*num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',future_fields{d}))(j).weighted_corr;
                %spike_shuffle.(sprintf('%s',future_fields{d}))(j).linear_score(:,((jj-1)*num_col+1:jj*num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',future_fields{d}))(j).linear_score;
            end
        end
    end
end

PREspike_train_circ_shuffle_scores = spike_shuffle;
if strcmp(save_option,'Y')
    save('Theta\thetaSeq_PREspikeTrain_circ_shuffle.mat','PREspike_train_circ_shuffle_scores','-v7.3')
end
toc
end

function [all_shuffles,matrix_shuffles] = run_spike_circular_shuffle(loops,decoded_sequences,theta_spike_count,directional_place_fields,save_shuffles)
 
parameters = list_of_parameters;
num_tracks =  length(decoded_sequences.direction1);
fields = fieldnames(decoded_sequences);
fields = fields(cellfun(@(s) isempty(strmatch ('phase', s)), fieldnames(decoded_sequences)));
matrix_shuffles = [];

% Get spike count for the whole session
thetaseq_spike_count = theta_spike_count.n.replay;

% creates template structure to save all position shuffles
future_fields = {'direction1','direction2','unidirectional'};% there will be 3 fields
for d = 1 : length(future_fields)
    for t = 1 : num_tracks
        all_shuffles.(sprintf('%s',future_fields{d}))(t).quadrant_ratio = zeros(1,loops);
        all_shuffles.(sprintf('%s',future_fields{d}))(t).weighted_corr= zeros(1,loops);
        %all_shuffles.(sprintf('%s',future_fields{d}))(t).linear_score = zeros(1,loops);
    end
end

if save_shuffles == 1
    % preallocate
    for t = 1 : num_tracks
        matrix_shuffles.direction1(t).mean_relative_position = repmat({NaN(parameters.theta_position_window_width+1,parameters.number_cycle_bins)},loops,1);
        matrix_shuffles.direction2(t).mean_relative_position = repmat({NaN(parameters.theta_position_window_width+1,parameters.number_cycle_bins)},loops,1);
        matrix_shuffles.unidirectional(t).mean_relative_position = repmat({NaN(parameters.theta_position_window_width+1,parameters.number_cycle_bins)},loops,1);
    end
end

% START RUNNING SHUFFLES
for s = 1 : loops
    disp(s)
    
    % Initiate structures
    decoded_thetaSeq = decoded_sequences;
    for t = 1 : num_tracks    %Remove not needed fields for speed and memory
        decoded_thetaSeq.direction1(t).theta_sequences = rmfield(decoded_thetaSeq.direction1(t).theta_sequences,'decoded_position');
        decoded_thetaSeq.direction2(t).theta_sequences = rmfield(decoded_thetaSeq.direction2(t).theta_sequences,'decoded_position');
    end
    
    % Create a copy of output structure
    shuffled_struct = decoded_sequences;
    to_remove = {'timebins_edges','timebins_edge_index','timebins_centre_index'}; %Remove not needed fields for speed and memory
    for t = 1 : num_tracks
        shuffled_struct.direction1(t).theta_sequences = rmfield(shuffled_struct.direction1(t).theta_sequences,to_remove);
        shuffled_struct.direction2(t).theta_sequences = rmfield(shuffled_struct.direction2(t).theta_sequences,to_remove);
    end
    
    % For each theta window, find central theta cycle, take spike count matrix and do circular shuffle on the spikes of each cell (so, for each row)
    for d = 1 : length(fields) %for each direction
        
        for t = 1 : num_tracks
            track_indices =  find(theta_spike_count.replay_events_indices == t); %track indices in n.replay
            
            for tw = 1 : size(decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences,2) %for each theta window

                cycle_idcs = decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(tw).timebins_centre_index; % theta window indices in n.replay
                spike_count_idx = track_indices(cycle_idcs);
                
                % Shift each row (spike count per cell) within central theta cycle
                for i = 1 : size(thetaseq_spike_count,1)
                    thetaseq_spike_count(i,spike_count_idx) = circshift(thetaseq_spike_count(i,spike_count_idx),ceil(rand*length(spike_count_idx)),2);
                end
            end
        end
    end
    
    % Save in structure to input in bayesian decoding code
    theta_spike_count.n.replay = thetaseq_spike_count;
    
    % Run bayesian decoding
    estimated_position.dir1 = bayesian_decoding(directional_place_fields,theta_spike_count,1,'N');
    estimated_position.dir2 = bayesian_decoding(directional_place_fields,theta_spike_count,2,'N');
    
    % replace the decoded position in the shuffle structure with the new shuffled decoded position
    for d = 1 : length(fields) %for each direction
        for t = 1 : num_tracks
            for tw = 1 : size(decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences,2) %for each theta window
                tw_idx =  decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(tw).timebins_centre_index;
                shuffled_struct.(sprintf('%s',fields{d}))(t).theta_sequences(tw).decoded_position = estimated_position.(sprintf('%s','dir',num2str(d)))(t).replay_events(t).replay_OneTrack(:,tw_idx); % normalized by all tracks
            end
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
        for t = 1 : num_tracks
            matrix_shuffles.direction1(t).mean_relative_position{s} = centered_averaged_thetaSeq.direction1(t).mean_relative_position;
            matrix_shuffles.direction2(t).mean_relative_position{s} = centered_averaged_thetaSeq.direction2(t).mean_relative_position;
            matrix_shuffles.unidirectional(t).mean_relative_position{s} = centered_averaged_thetaSeq.unidirectional(t).mean_relative_position;
        end
    end
    
    % Weighted correlation
    for d = 1 : length(future_fields) %for each direction
        for t = 1 : num_tracks % for each track
            central_cycle =  centered_averaged_thetaSeq.(sprintf('%s',future_fields{d}))(t).mean_relative_position;
            centered_averaged_thetaSeq.(sprintf('%s',future_fields{d}))(t).weighted_corr = weighted_correlation(central_cycle);
        end
    end
    
%     % Line fitting
%     time_bins_length = size(centered_averaged_thetaSeq.direction1(1).mean_relative_position,2); % all matrices should have the same size
%     [all_tstLn,spd2Test]= construct_all_lines(time_bins_length);
%     
%     for d = 1 : length(future_fields) % for each direction
%         thetaseq = centered_averaged_thetaSeq.(strcat(future_fields{d}));
%         for t = 1 : length(thetaseq) % for each track
%             central_cycle = thetaseq(t).mean_relative_position;
%             [centered_averaged_thetaSeq.(strcat(future_fields{d}))(t).linear_score,~,~] = line_fitting2(central_cycle,all_tstLn(size(central_cycle,2)==time_bins_length),spd2Test);
%         end
%     end
    
    % Adds the scoring results of each shuffle to the same structure
    for d = 1 : length(future_fields)
        for j = 1 : num_tracks
            all_shuffles.(sprintf('%s',future_fields{d}))(j).quadrant_ratio(s) = centered_averaged_thetaSeq.(sprintf('%s',future_fields{d}))(j).quadrant_ratio;
            all_shuffles.(sprintf('%s',future_fields{d}))(j).weighted_corr(s) = centered_averaged_thetaSeq.(sprintf('%s',future_fields{d}))(j).weighted_corr;
            %all_shuffles.(sprintf('%s',future_fields{d}))(j).linear_score(s) = centered_averaged_thetaSeq.(sprintf('%s',future_fields{d}))(j).linear_score;
        end
    end
    
end
end


