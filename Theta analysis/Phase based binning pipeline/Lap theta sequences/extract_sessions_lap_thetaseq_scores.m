% EXTRACT LAP THETA SEQUENCES SCORES FOR TRACK AND SESSION
% MH 2020
% Extracts theta sequence scores for each lap saved in each animal's folder. Uses data where theta sequences are decoded with place fields from same lap
% rather than whole session place fields. Output - each row is a track and each column is a lap. It's ordered from 16x8 to 16x1 sessions.


function [lap_QuadrantRatio,lap_WeightedCorr] = extract_sessions_lap_thetaseq_scores


% Load name of data folders
sessions = data_folders;
session_names = fieldnames(sessions);

c = 1;
for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    
    for s = 1: length(folders)
        cd(cell2mat(folders(s)))
        
        load Theta\lap_theta_sequence_quantification_SMOOTHED.mat
        
        %extract data
        for t = 1 : size(directional_lap_thetaseq,2)
            
            for lap = 1 : length(directional_lap_thetaseq(t).Lap)
                if ~isempty(directional_lap_thetaseq(t).Lap{1,lap})
                    lap_QuadrantRatio(c).track(t).score(lap) = directional_lap_thetaseq(t).Lap{1,lap}.unidirectional(t).quadrant_ratio;
                    lap_WeightedCorr(c).track(t).score(lap)  = directional_lap_thetaseq(t).Lap{1,lap}.unidirectional(t).weighted_corr;
                    lap_QuadrantRatio(c).track(t).num_thetaseq(lap) = length(directional_lap_thetaseq(t).Lap{1,lap}.unidirectional(t).thetaseq);
                    lap_WeightedCorr(c).track(t).num_thetaseq(lap)  = length(directional_lap_thetaseq(t).Lap{1,lap}.unidirectional(t).thetaseq);
                    lap_theta_window_indx(c).track(t).undir_idx{lap} = [directional_lap_thetaseq(t).Lap{1,lap}.unidirectional(t).thetaseq(:).theta_window_index];
                end
            end
            
        end
        c = c + 1;
    end
end

save('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\thetaseq_scores_individual_laps.mat','lap_WeightedCorr','lap_QuadrantRatio','lap_theta_window_indx','-v7.3')

end