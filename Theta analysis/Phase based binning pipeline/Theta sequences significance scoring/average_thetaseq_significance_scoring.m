% AVERAGE THETA SEQUENCE SIGNIFICANCE
%MH 2020
% Compares average theta sequence scores to shuffles. Takes the 95% for each shuffle (pre spike train circ shuffle, position circ shuffle & time
% bin suffle), and takes the maximum value between the three of them. A theta sequence will be significant if it's higher than the maximum value.

function centered_averaged_thetaSeq = average_thetaseq_significance_scoring

load Theta\thetaSeq_PREspikeTrain_circ_shuffle.mat
load Theta\thetaseq_phase_shuffle.mat
load Theta\thetaseq_position_shuffle.mat
load Theta\theta_sequence_quantification.mat


fields = fieldnames(centered_averaged_thetaSeq);

for d = 1 : length(fields)
    
    for t = 1 : length(centered_averaged_thetaSeq.(sprintf('%s',fields{d})))
        
        if isempty(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).quadrant_ratio)
            continue
        end
        % QUADRANT RATIO
         theta_score = abs(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).quadrant_ratio);
         PREspike_limit = prctile([PREspike_train_circ_shuffle_scores.(sprintf('%s',fields{d}))(t).quadrant_ratio],95); %PRE spike train circ shuffle
         position_limit = prctile([position_shuffle.(sprintf('%s',fields{d}))(t).quadrant_ratio],95); % position circ shuffle
         phase_limit = prctile([phase_shuffle.(sprintf('%s',fields{d}))(t).quadrant_ratio],95); %time bin shuffle
         max_limit = max([PREspike_limit phase_limit position_limit]);
        
         QR_PREspike_pvalue = get_p_value(theta_score,[PREspike_train_circ_shuffle_scores.(sprintf('%s',fields{d}))(t).quadrant_ratio]);
         QR_phaseCirc_pvalue = get_p_value(theta_score,[position_shuffle.(sprintf('%s',fields{d}))(t).quadrant_ratio]);
         QR_positionCirc_pvalue = get_p_value(theta_score,[phase_shuffle.(sprintf('%s',fields{d}))(t).quadrant_ratio]);
         
         centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).QR_shuffles_pvals = [QR_PREspike_pvalue QR_phaseCirc_pvalue QR_positionCirc_pvalue];
         centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).QR_shuffles_sig =  theta_score > [PREspike_limit phase_limit position_limit]; % save which shuffles passes
         centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).QR_theta_sig =  theta_score > max_limit; % save it's overall significance
         
         % Repeat with 98percentile 
         PREspike_limit98 = prctile([PREspike_train_circ_shuffle_scores.(sprintf('%s',fields{d}))(t).quadrant_ratio],98); %PRE spike train circ shuffle
         position_limit98 = prctile([position_shuffle.(sprintf('%s',fields{d}))(t).quadrant_ratio],98); % position circ shuffle
         phase_limit98 = prctile([phase_shuffle.(sprintf('%s',fields{d}))(t).quadrant_ratio],98); %time bin shuffle
         max_limit98 = max([PREspike_limit98 phase_limit98 position_limit98]);

         centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).QR_shuffles_sig_98 =  theta_score > [PREspike_limit98 phase_limit98 position_limit98]; % save which shuffles passes
         centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).QR_theta_sig_98 =  theta_score > max_limit98; % save it's overall significance

         clear PREspike_limit time_limit position_limit PREspike_limit98 phase_limit98 position_limit98
         
         % WEIGHTED CORRELATION
         theta_score = abs(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).weighted_corr);
         PREspike_limit = prctile([PREspike_train_circ_shuffle_scores.(sprintf('%s',fields{d}))(t).weighted_corr],95); %PRE spike train circ shuffle
         position_limit = prctile([position_shuffle.(sprintf('%s',fields{d}))(t).weighted_corr],95); % position circ shuffle
         phase_limit = prctile([phase_shuffle.(sprintf('%s',fields{d}))(t).weighted_corr],95); %time bin shuffle
         max_limit = max([PREspike_limit phase_limit position_limit]);
         
         WC_PREspike_pvalue = get_p_value(theta_score,[PREspike_train_circ_shuffle_scores.(sprintf('%s',fields{d}))(t).weighted_corr]);
         WC_phaseCirc_pvalue = get_p_value(theta_score,[position_shuffle.(sprintf('%s',fields{d}))(t).weighted_corr]);
         WC_positionCirc_pvalue = get_p_value(theta_score,[phase_shuffle.(sprintf('%s',fields{d}))(t).weighted_corr]);
        
         centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).WC_shuffles_pvals = [WC_PREspike_pvalue WC_phaseCirc_pvalue WC_positionCirc_pvalue];
         centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).WC_shuffles_sig =  theta_score > [PREspike_limit phase_limit position_limit]; % save which shuffles passes
         centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).WC_theta_sig =  theta_score > max_limit; % save it's overall significance
         
         % Repeat with 98percentile 
         PREspike_limit98 = prctile([PREspike_train_circ_shuffle_scores.(sprintf('%s',fields{d}))(t).weighted_corr],95); %PRE spike train circ shuffle
         position_limit98 = prctile([position_shuffle.(sprintf('%s',fields{d}))(t).weighted_corr],95); % position circ shuffle
         phase_limit98 = prctile([phase_shuffle.(sprintf('%s',fields{d}))(t).weighted_corr],95); %time bin shuffle
         max_limit98 = max([PREspike_limit phase_limit position_limit]);

         centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).WC_shuffles_sig98 =  theta_score > [PREspike_limit98 phase_limit98 position_limit98]; % save which shuffles passes
         centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).WC_theta_sig98 =  theta_score > max_limit98; % save it's overall significance

         clear PREspike_limit time_limit position_limit PREspike_limit98 phase_limit98 position_limit98
         
    end
end
       

% Save
if exist('centered_averaged_CONCAT_thetaSeq','var')
    save('Theta\theta_sequence_quantification','centered_averaged_thetaSeq','centered_averaged_CONCAT_thetaSeq','-v7.3')
else
    save('Theta\theta_sequence_quantification','centered_averaged_thetaSeq','-v7.3')
end

         
end

function out = get_p_value(event_score,shuffles_scores)
% Finds the proportion of scores in the shuffled distribution greater than the score of the candidate trajectory

out = length(find(abs(shuffles_scores)>=event_score))/length(shuffles_scores);
if ~isempty(find(isnan(shuffles_scores),1)) %if shuffle scores are NaNs
    out = NaN;
end

end