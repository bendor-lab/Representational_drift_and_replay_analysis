% TIME SHUFFLE  
% Disrupts temporal domain.

function time_shuffle = theta_sequences_timebins_shuffle(num_shuffles)

parameters = list_of_parameters;
load decoded_theta_sequences.mat

decoded_sequences= decoded_thetaSeq;
directions = length(fieldnames(decoded_thetaSeq));
num_tracks = length(decoded_thetaSeq.direction1);

% Find number of cores available 
p = gcp; % Starting parallel pool
if isempty(p)
    num_cores = 0;
else
    num_cores = p.NumWorkers; 
end
loops = ceil(num_shuffles/num_cores);

% creates template structure to save all position shuffles
for t = 1:num_tracks
    shuffled_thetaseq.direction1(t).quadrant_ratio = zeros(1,loops);
    shuffled_thetaseq.direction2(t).quadrant_ratio= zeros(1,loops);
    shuffled_thetaseq.direction1(t).weighted_corr = zeros(1,loops);
    shuffled_thetaseq.direction2(t).weighted_corr= zeros(1,loops);
end

for jj = 1 : num_cores
    
    all_shuffles(jj).shuffled_thetaseq = shuffled_thetaseq;

    for s = 1 : loops
        
        shuffled_struct = decoded_sequences;
        
        % For each shuffle, creates a new structure where the time bins in each decoded event have been shuffled
        for d = 1 : directions
            for j = 1 : num_tracks
                for i = 1: length(decoded_sequences.(strcat('direction',num2str(d)))(j).theta_sequences)
                    matrix_size = size(decoded_sequences.(strcat('direction',num2str(d)))(j).theta_sequences(i).decoded_position);
                    shuffled_struct.(strcat('direction',num2str(d)))(j).theta_sequences(i).decoded_position = shuffled_struct.(strcat('direction',num2str(d)))(j).theta_sequences(i).decoded_position(:,randperm(matrix_size(2)));
                end
            end
        end
        
        %%%% For each new shuffled structure, runs quantification methods
        centered_averaged_thetaSeq = averaged_theta_cycle(shuffled_struct,0);
        % Quadrant Ratio
        centered_averaged_thetaSeq = quadrant_ratio(centered_averaged_thetaSeq);
        % Weighted correlation
        for d = 1 : directions %for each direction
            thetaseq = centered_averaged_thetaSeq.(strcat('direction',num2str(d)));
            for t = 1 : num_tracks % for each track
                averaged_sequence = thetaseq(t).mean_relative_position;
                num_bins = 0.05/parameters.thetaseq_bin_width; %window of 100ms (50 around centre)
                
                central_cycle = averaged_sequence(:,21-num_bins:20+num_bins);
                
                centered_averaged_thetaSeq.(strcat('direction',num2str(d)))(t).weighted_corr = weighted_correlation(central_cycle);
            end
        end

        % Adds the scoring results of each shuffle to the same structure
        for d = 1 : directions
            for j = 1:num_tracks
                all_shuffles(jj).shuffled_thetaseq.(strcat('direction',num2str(d)))(j).quadrant_ratio(s) = centered_averaged_thetaSeq.(strcat('direction',num2str(d)))(j).quadrant_ratio;
                all_shuffles(jj).shuffled_thetaseq.(strcat('direction',num2str(d)))(j).weighted_corr(s) = centered_averaged_thetaSeq.(strcat('direction',num2str(d)))(j).weighted_corr;
            end
        end
        
    end
end


% Save in final structure
for d = 1 : directions
    for j = 1 : num_tracks
        for jj = 1 : num_cores
            num_col = size(all_shuffles(jj).shuffled_thetaseq.(strcat('direction',num2str(d)))(j).quadrant_ratio,2);
            if jj == 1
                time_shuffle.(strcat('direction',num2str(d)))(j).quadrant_ratio(:,(jj:num_col)) = all_shuffles(jj).shuffled_thetaseq.(strcat('direction',num2str(d)))(j).quadrant_ratio;
                time_shuffle.(strcat('direction',num2str(d)))(j).weighted_corr(:,(jj:num_col)) = all_shuffles(jj).shuffled_thetaseq.(strcat('direction',num2str(d)))(j).weighted_corr;
            else
                time_shuffle.(strcat('direction',num2str(d)))(j).quadrant_ratio(:,((jj-1)*num_col+1:jj*num_col)) = all_shuffles(jj).shuffled_thetaseq.(strcat('direction',num2str(d)))(j).quadrant_ratio;
                time_shuffle.(strcat('direction',num2str(d)))(j).weighted_corr(:,((jj-1)*num_col+1:jj*num_col)) = all_shuffles(jj).shuffled_thetaseq.(strcat('direction',num2str(d)))(j).weighted_corr;
            end
        end
    end
end

save thetaSeq_time_shuffle time_shuffle
end