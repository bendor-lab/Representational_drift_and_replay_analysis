% TIME SHUFFLE  
% Disrupts temporal/phase domain. Random shuffle of the phases of the average theta cycle (columns). Keep relationship between spike
% probability and position intact, but disrupts relationship between phase and position.
% INPUT - 
    % num_shuffles: integer

function [time_bin_shuffles,time_shuffle] = average_theta_sequences_timebins_phase_shuffle(num_shuffles,save_shuffles)
tic
parameters = list_of_parameters;
load Theta\theta_sequence_quantification.mat

fields = fieldnames(centered_averaged_thetaSeq);
num_tracks = length(centered_averaged_thetaSeq.direction1);
for d = 1 : length(fields)
    for t = 1 : num_tracks
        decoded_sequences.(strcat(fields{d}))(t).mean_relative_position = centered_averaged_thetaSeq.(strcat(fields{d}))(t).mean_relative_position;
    end
end

% Find number of cores available 
p = gcp; % Starting parallel pool
if isempty(p)
    num_cores = 0;
else
    num_cores = p.NumWorkers-1; 
end
loops = ceil(num_shuffles/num_cores);

% Run shuffles
parfor jj = 1 : num_cores
    [out{jj}.shuffled_thetaseq,out2{jj}] = run_time_bin_shuffles(loops,decoded_sequences,save_shuffles);
end

if save_shuffles == 1
    for d = 1 : length(fields)
        for t = 1 : num_tracks
            cellArray1 = cellfun(@(x) x.(strcat(fields{d}))(t).mean_relative_position, out2,'UniformOutput',0)';
            time_bin_shuffles.(strcat(fields{d}))(t).mean_relative_position = vertcat(cellArray1{:});
            time_bin_shuffles.(strcat(fields{d}))(t).mean_relative_position = time_bin_shuffles.(strcat(fields{d}))(t).mean_relative_position(1:num_shuffles,:);
        end
    end
save Theta\time_shuffles_theta_sequences time_bin_shuffles
end
    
% Save in final structure
for d = 1 : length(fields)
    for j = 1 : num_tracks
        for jj = 1 : num_cores
            num_col = size(out{jj}.shuffled_thetaseq.(strcat(fields{d}))(j).quadrant_ratio,2);
            if jj == 1
                time_shuffle.(strcat(fields{d}))(j).quadrant_ratio(:,(jj:num_col)) = out{jj}.shuffled_thetaseq.(strcat(fields{d}))(j).quadrant_ratio;
                time_shuffle.(strcat(fields{d}))(j).weighted_corr(:,(jj:num_col)) = out{jj}.shuffled_thetaseq.(strcat(fields{d}))(j).weighted_corr;
                %time_shuffle.(strcat(fields{d}))(j).linear_score(:,(jj:num_col)) = out{jj}.shuffled_thetaseq.(strcat(fields{d}))(j).linear_score;
            else
                time_shuffle.(strcat(fields{d}))(j).quadrant_ratio(:,((jj-1)*num_col+1:jj*num_col)) = out{jj}.shuffled_thetaseq.(strcat(fields{d}))(j).quadrant_ratio;
                time_shuffle.(strcat(fields{d}))(j).weighted_corr(:,((jj-1)*num_col+1:jj*num_col)) = out{jj}.shuffled_thetaseq.(strcat(fields{d}))(j).weighted_corr;
                %time_shuffle.(strcat(fields{d}))(j).linear_score(:,((jj-1)*num_col+1:jj*num_col)) = out{jj}.shuffled_thetaseq.(strcat(fields{d}))(j).linear_score;
            end
        end
    end
end

save Theta\averaged_thetaSeq_time_shuffle time_shuffle
toc
end


function [all_shuffles,matrix_shuffles] = run_time_bin_shuffles(loops,decoded_sequences,save_shuffles)


    parameters = list_of_parameters;
    matrix_shuffles = [];
    fields = fieldnames(decoded_sequences);
    fields = fields(cellfun(@(s) isempty(strmatch ('phase', s)), fieldnames(decoded_sequences)));
    num_tracks = length(decoded_sequences.direction1);
    
    % creates template structure to save all position shuffles
    for d = 1 : length(fields)
        for t = 1 : num_tracks
            all_shuffles.(strcat(fields{d}))(t).quadrant_ratio = zeros(1,loops);
            all_shuffles.(strcat(fields{d}))(t).weighted_corr= zeros(1,loops);
            %all_shuffles.(strcat(fields{d}))(t).linear_score = zeros(1,loops);
        end
    end
    
    if save_shuffles == 1
        % preallocate
        for t = 1 : num_tracks
            matrix_shuffles.direction1(t).mean_relative_position = repmat(cellfun(@(x) NaN(size(x)), {decoded_sequences.direction1(t).mean_relative_position},'UniformOutput',0),loops,1);
            matrix_shuffles.direction2(t).mean_relative_position = repmat(cellfun(@(x) NaN(size(x)), {decoded_sequences.direction2(t).mean_relative_position},'UniformOutput',0),loops,1);
            matrix_shuffles.unidirectional(t).mean_relative_position = repmat(cellfun(@(x) NaN(size(x)), {decoded_sequences.unidirectional(t).mean_relative_position},'UniformOutput',0),loops,1);
        end
    end

    %all_shuffles.shuffled_thetaseq = shuffled_thetaseq;
    %matrix_shuffles = time_bin_shuffles;

    for s = 1 : loops
        
        shuffled_struct = decoded_sequences;
        
        % For each shuffle, creates a new structure where the time bins in each decoded event have been shuffled
        for d = 1 : length(fields)
            for j = 1 : num_tracks
                matrix_size = size(decoded_sequences.(strcat(fields{d}))(j).mean_relative_position);
                shuffled_struct.(strcat(fields{d}))(j).mean_relative_position= shuffled_struct.(strcat(fields{d}))(j).mean_relative_position(:,randperm(matrix_size(2)));
            end
        end
        
        if save_shuffles == 1
            % keep shuffled theta window matrices
            for t = 1 : num_tracks
                matrix_shuffles.direction1(t).mean_relative_position{s} = shuffled_struct.direction1(t).mean_relative_position;
                matrix_shuffles.direction2(t).mean_relative_position{s} = shuffled_struct.direction2(t).mean_relative_position;
                matrix_shuffles.unidirectional(t).mean_relative_position{s} = shuffled_struct.unidirectional(t).mean_relative_position;
            end
        end
        
        %%%% For each new shuffled structure, runs quantification methods
        
        % Quadrant Ratio
        centered_averaged_thetaSeq = phase_quadrant_ratio(shuffled_struct);

        % Weighted correlation
        for d = 1 : length(fields) %for each direction
            for t = 1 : num_tracks % for each track
                central_cycle = centered_averaged_thetaSeq.(strcat(fields{d}))(t).mean_relative_position;
                centered_averaged_thetaSeq.(strcat(fields{d}))(t).weighted_corr = weighted_correlation(central_cycle);
            end
        end
        
%         % Line fitting
%         time_bins_length = size(centered_averaged_thetaSeq.direction1(1).mean_relative_position,2); % all matrices should have the same size
%         [all_tstLn,spd2Test]= construct_all_lines(time_bins_length);
%         
%         for d = 1 : length(fields) % for each direction
%             thetaseq = centered_averaged_thetaSeq.(strcat(fields{d}));
%             for t = 1 : length(thetaseq) % for each track
%                 central_cycle = thetaseq(t).mean_relative_position;
%                 [centered_averaged_thetaSeq.(strcat(fields{d}))(t).linear_score,~,~] = line_fitting2(central_cycle,all_tstLn(size(central_cycle,2)==time_bins_length),spd2Test);
%             end
%         end
        
        % Adds the scoring results of each shuffle to the same structure
        for d = 1 : length(fields)
            for j = 1 : num_tracks
                all_shuffles.(strcat(fields{d}))(j).quadrant_ratio(s) = centered_averaged_thetaSeq.(strcat(fields{d}))(j).quadrant_ratio;
                all_shuffles.(strcat(fields{d}))(j).weighted_corr(s) = centered_averaged_thetaSeq.(strcat(fields{d}))(j).weighted_corr;
                %all_shuffles.(strcat(fields{d}))(j).linear_score(s) = centered_averaged_thetaSeq.(strcat(fields{d}))(j).linear_score;
            end
        end
        
    end
end