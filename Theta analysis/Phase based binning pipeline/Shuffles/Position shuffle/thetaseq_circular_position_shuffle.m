% POSITION CIRCULAR SHUFFLE
% MH 2020
% Circular shuffle of positions within each time/phase bin. Maintains relationship between phase and cell assembly spike probability, and spike
% time/phase. 
% INPUT:
    % decoded_thetaSeq, directional_place_fields - data structs. If empty, loads them
    % num_shuffles: integer
    % save_shuffles: 1 or 0. To save shuffled structures
    % save_option: 'Y' or []. To save function outputs


function [position_bin_shuffles,position_shuffle] = thetaseq_circular_position_shuffle(decoded_thetaSeq,num_shuffles,save_shuffles,save_option)

parameters = list_of_parameters;
if isempty(decoded_thetaSeq)
    load Theta\decoded_theta_sequences.mat
end

decoded_sequences =  decoded_thetaSeq;
num_tracks = length(decoded_thetaSeq.direction1);
position_bin_shuffles = [];

% Find number of cores available 
p = gcp; % Starting parallel pool
if isempty(p)
    num_cores = 0;
else
    num_cores = p.NumWorkers; 
end
loops = ceil(num_shuffles/num_cores);

% Run shuffles
parfor jj = 1 : num_cores
    [out{jj}.shuffled_thetaseq,out2{jj}] = run_circular_position_shuffles(loops,decoded_sequences,save_shuffles);
end

future_fields = {'direction1','direction2','unidirectional'};% there will be 3 fields
if save_shuffles == 1
    for d = 1 : length(future_fields)
        for t = 1 : num_tracks
            cellArray1 = cellfun(@(x) x.(strcat(future_fields{d}))(t).mean_relative_position, out2,'UniformOutput',0)';
            position_bin_shuffles.(strcat(future_fields{d}))(t).mean_relative_position = vertcat(cellArray1{:});
            position_bin_shuffles.(strcat(future_fields{d}))(t).mean_relative_position = position_bin_shuffles.(strcat(future_fields{d}))(t).mean_relative_position(1:num_shuffles,:);
        end
    end
    if strcmp(save_option,'Y')
        save('Theta\position_shuffles_theta_sequences','position_bin_shuffles','-v7.3') % shuffled matrices
    end
end

fields = fieldnames(out{1,1}.shuffled_thetaseq);
% Save in final structure
for d = 1 : length(fields)
    for t = 1 : num_tracks
        for jj = 1 : num_cores
            num_col = size(out{jj}.shuffled_thetaseq.(strcat(fields{d}))(t).quadrant_ratio,2);
            if jj == 1
                position_shuffle.(sprintf('%s',fields{d}))(t).quadrant_ratio(:,(jj:num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',fields{d}))(t).quadrant_ratio;
                position_shuffle.(sprintf('%s',fields{d}))(t).weighted_corr(:,(jj:num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',fields{d}))(t).weighted_corr;
                %position_shuffle.(sprintf('%s',fields{d}))(t).linear_score(:,(jj:num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',fields{d}))(t).linear_score;
            else
                position_shuffle.(sprintf('%s',fields{d}))(t).quadrant_ratio(:,((jj-1)*num_col+1:jj*num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',fields{d}))(t).quadrant_ratio;
                position_shuffle.(sprintf('%s',fields{d}))(t).weighted_corr(:,((jj-1)*num_col+1:jj*num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',fields{d}))(t).weighted_corr;
                %position_shuffle.(sprintf('%s',fields{d}))(t).linear_score(:,((jj-1)*num_col+1:jj*num_col)) = out{jj}.shuffled_thetaseq.(sprintf('%s',fields{d}))(t).linear_score;
            end
        end
    end
end


if strcmp(save_option,'Y')
    save('Theta\thetaseq_position_shuffle','position_shuffle','-v7.3') % scores
end
end


function [all_shuffles,matrix_shuffles] = run_circular_position_shuffles(loops,decoded_sequences,save_shuffles)
parameters = list_of_parameters;

num_tracks =  length(decoded_sequences.direction1);
%fields = fieldnames(decoded_sequences);
%fields = fields(cellfun(@(s) isempty(strmatch('phase', s)), fieldnames(decoded_sequences)));
matrix_shuffles =[];

future_fields = {'direction1','direction2','unidirectional'};% there will be 3 fields
% creates template structure to save all position shuffles
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

for s = 1 : loops
    %disp(s)
    
    shuffled_struct = decoded_sequences;
    fields = fieldnames(shuffled_struct);
    fields = fields(cellfun(@(s) isempty(strmatch ('phase', s)), fieldnames(shuffled_struct)));
    % For each shuffle, creates a new structure where the time bins in each decoded event have been shuffled circularly (each column),
    % shuffling positions within phase as a result
    for d = 1 : length(fields)
        for t = 1 : num_tracks
            for event = 1 : length(shuffled_struct.(sprintf('%s',fields{d}))(t).theta_sequences)
                matrix_size = size(shuffled_struct.(sprintf('%s',fields{d}))(t).theta_sequences(event).decoded_position);
                for k = 1 : matrix_size(2)
                    shuffled_struct.(sprintf('%s',fields{d}))(t).theta_sequences(event).decoded_position(:,k)= circshift(shuffled_struct.(sprintf('%s',fields{d}))(t).theta_sequences(event).decoded_position(:,k),ceil(rand*matrix_size(1)));
                end
            end
        end
    end
    
    % Get average theta cycle
    [centered_averaged_thetaSeq,~] = averaged_concat_theta_cycle(shuffled_struct,0);
    
    % keep shuffled theta window matrices
    if save_shuffles == 1
        for t = 1 : num_tracks
            matrix_shuffles.direction1(t).mean_relative_position{s} = centered_averaged_thetaSeq.direction1(t).mean_relative_position;
            matrix_shuffles.direction2(t).mean_relative_position{s} = centered_averaged_thetaSeq.direction2(t).mean_relative_position;
            matrix_shuffles.unidirectional(t).mean_relative_position{s} = centered_averaged_thetaSeq.unidirectional(t).mean_relative_position;
        end
    end
    
    %%%% For each new shuffled structure, runs quantification methods
    
    % Quadrant Ratio
    centered_averaged_thetaSeq = phase_quadrant_ratio(centered_averaged_thetaSeq);
    
    fields = fieldnames(centered_averaged_thetaSeq);
    % Weighted correlation
    for d = 1 : length(fields) %for each direction
        for t = 1 : num_tracks % for each track
            if isempty(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq)
                continue
            end
            centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).weighted_corr = weighted_correlation(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).mean_relative_position);
        end
    end
    
%     % Line fitting
%     time_bins_length = size(centered_averaged_thetaSeq.direction1(1).mean_relative_position,2); % all matrices should have the same size
%     [all_tstLn,spd2Test]= construct_all_lines(time_bins_length);
%     
%     for d = 1 : length(fields) % for each direction
%         thetaseq = centered_averaged_thetaSeq.(strcat(fields{d}));
%         for t = 1 : length(thetaseq) % for each track
%             central_cycle = thetaseq(t).mean_relative_position;
%             [centered_averaged_thetaSeq.(strcat(fields{d}))(t).linear_score,~,~] = line_fitting2(central_cycle,all_tstLn(size(central_cycle,2)==time_bins_length),spd2Test);
%         end
%     end

    % Adds the scoring results of each shuffle to the same structure
    for d = 1 : length(fields)
        for t = 1 : num_tracks
            if isempty(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq)
                continue
            end
            all_shuffles.(sprintf('%s',fields{d}))(t).quadrant_ratio(s) = centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).quadrant_ratio;
            all_shuffles.(sprintf('%s',fields{d}))(t).weighted_corr(s) = centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).weighted_corr;
            %all_shuffles.(sprintf('%s',fields{d}))(t).linear_score(s) = centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).linear_score;
        end
    end
    
end


end