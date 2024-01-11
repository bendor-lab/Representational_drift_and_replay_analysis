% LAP THETA SEQUENCE SIGNIFICANCE
%MH 2020
% Compares average theta sequence scores to shuffles. Takes the 95% for each shuffle (pre spike train circ shuffle, position circ shuffle & time
% bin suffle), and takes the maximum value between the three of them. A theta sequence will be significant if it's higher than the maximum value.

function lap_thetaseq_significance_scoring

load Theta\lap_theta_sequence_quantification_SMOOTHED.mat
load Theta\lap_thetaseq_phase_shuffle_SMOOTHED.mat
load Theta\lap_thetaseq_position_shuffle_SMOOTHED.mat
load Theta\lap_thetaSeq_PREspikeTrain_circ_shuffle_SMOOTHED.mat
pval_thresh = 0.05;
fields = {'unidirectional'};

%for d = 1 : length(fields)
d=1;
    
    for t = 1 : length(centered_averaged_thetaSeq.(sprintf('%s',fields{d})))
        
        for lap = 1 : length(find(~cellfun(@isempty,directional_lap_thetaseq(t).Lap)))
            
            if ~isempty(directional_lap_thetaseq(t).Lap{1,lap}) 
                %QUADRANT RATIO
                theta_score = abs(directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).quadrant_ratio);
                PREspike_limit = prctile([lap_PREspike_train_circ_shuffle_scores(t).Lap{1,lap}.(sprintf('%s',fields{d})).quadrant_ratio],95); %PRE spike train circ shuffle
                position_limit = prctile([lap_position_shuffle(t).Lap{1,lap}.(sprintf('%s',fields{d})).quadrant_ratio],95); % position circ shuffle
                phase_limit = prctile([lap_phase_shuffle(t).Lap{1,lap}.(sprintf('%s',fields{d})).quadrant_ratio],95); %time bin shuffle
                max_limit = max([PREspike_limit phase_limit position_limit]);
                
                QR_PREspike_pvalue = get_p_value(theta_score,[lap_PREspike_train_circ_shuffle_scores(t).Lap{1,lap}.(sprintf('%s',fields{d})).quadrant_ratio]);
                QR_phaseCirc_pvalue = get_p_value(theta_score,[lap_phase_shuffle(t).Lap{1,lap}.(sprintf('%s',fields{d})).quadrant_ratio]);
                QR_positionCirc_pvalue = get_p_value(theta_score,[lap_position_shuffle(t).Lap{1,lap}.(sprintf('%s',fields{d})).quadrant_ratio]);
                
                directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).QR_shuffles_pvals = [QR_PREspike_pvalue QR_phaseCirc_pvalue QR_positionCirc_pvalue];
                %directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).QR_shuffles_sig =  theta_score > [PREspike_limit phase_limit position_limit]; % save which shuffles passes
                %directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).QR_theta_sig =  theta_score > max_limit; % save it's overall significance
                directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).QR_shuffles_sig =  pval_thresh > [PREspike_limit phase_limit position_limit]; % save which shuffles passes
                directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).QR_theta_sig =  pval_thresh < max_limit; % save it's overall significance
                
                clear PREspike_limit time_limit position_limit
                
                % WEIGHTED CORRELATION
                theta_score = abs(directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).weighted_corr);
                PREspike_limit = prctile([lap_PREspike_train_circ_shuffle_scores(t).Lap{1,lap}.(sprintf('%s',fields{d})).weighted_corr],95); %PRE spike train circ shuffle
                position_limit = prctile([lap_position_shuffle(t).Lap{1,lap}.(sprintf('%s',fields{d})).weighted_corr],95); % position circ shuffle
                phase_limit = prctile([lap_phase_shuffle(t).Lap{1,lap}.(sprintf('%s',fields{d})).weighted_corr],95); %time bin shuffle
                max_limit = max([PREspike_limit phase_limit position_limit]);
                
                % Get p-vals for theta sequences comparing to each of the shuffle distributions
                WC_PREspike_pvalue = get_p_value(theta_score,[lap_PREspike_train_circ_shuffle_scores(t).Lap{1,lap}.(sprintf('%s',fields{d})).weighted_corr]);
                WC_phaseCirc_pvalue = get_p_value(theta_score,[lap_phase_shuffle(t).Lap{1,lap}.(sprintf('%s',fields{d})).weighted_corr]);
                WC_positionCirc_pvalue = get_p_value(theta_score,[lap_position_shuffle(t).Lap{1,lap}.(sprintf('%s',fields{d})).weighted_corr]);
                
                directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).WC_shuffles_pvals = [WC_PREspike_pvalue WC_phaseCirc_pvalue WC_positionCirc_pvalue];
               % directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).WC_shuffles_sig =  theta_score > [PREspike_limit phase_limit position_limit]; % save which shuffles passes
               % directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).WC_theta_sig =  theta_score < max_limit/20; % save it's overall significance
                directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).WC_shuffles_sig =  pval_thresh > [PREspike_limit phase_limit position_limit]; % save which shuffles passes
                directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).WC_theta_sig =  pval_thresh > max_limit; % save it's overall significance
                
                if lap == 1
                    disp(directional_lap_thetaseq(t).Lap{1,lap}.(sprintf('%s',fields{d}))(t).WC_theta_sig)
                    disp(['MC - ' num2str(pval_thresh/20 > max_limit)])
                end
                
                clear PREspike_limit time_limit position_limit
            end
            
        end
    end
%end



% Save
if exist('centered_averaged_CONCAT_thetaSeq','var')
    save('Theta\lap_theta_sequence_quantification_SMOOTHED.mat','centered_averaged_thetaSeq','centered_averaged_CONCAT_thetaSeq','directional_lap_thetaseq','-v7.3')
else
    save('Theta\lap_theta_sequence_quantification_SMOOTHED.mat','centered_averaged_thetaSeq','directional_lap_thetaseq','-v7.3')
end

         
end

function out = get_p_value(event_score,shuffles_scores)
% Finds the proportion of scores in the shuffled distribution greater than the score of the candidate trajectory

out = length(find(shuffles_scores>=event_score))/length(shuffles_scores);
if ~isempty(find(isnan(shuffles_scores),1)) %if shuffle scores are NaNs
    out = NaN;
end

end