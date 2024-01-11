% AVERAGE THETA SEQUENCE SIGNIFICANCE
%MH 2020
% Compares average theta sequence scores to shuffles. Takes the 95% for each shuffle (pre spike train circ shuffle, position circ shuffle & time
% bin suffle), and takes the maximum value between the three of them. A theta sequence will be significant if it's higher than the maximum value.

function average_thetaseq_significance = session_average_thetaseq_significance_scoring(data_type)



% Load name of data folders
if strcmp(data_type,'main')
    sessions = data_folders;
    session_names = fieldnames(sessions);
elseif strcmp(data_type,'speed')
    sessions = speed_data_folders;
    session_names = fieldnames(sessions);
end


for p = 1 : length(session_names) %for each protocol
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    
    fields = {'direction1','direction2','unidirectional'};
    for f = 1 : length(fields)
        for t = 1 : 4
        all_PREspike_shuffles.(sprintf('%s',fields{f}))(t).quadrant_ratio = [];
        all_position_shuffles.(sprintf('%s',fields{f}))(t).quadrant_ratio = [];
        all_phase_shuffles.(sprintf('%s',fields{f}))(t).quadrant_ratio = [];
        all_theta_score.(sprintf('%s',fields{f}))(t).quadrant_ratio = [];
        
        all_PREspike_shuffles.(sprintf('%s',fields{f}))(t).weighted_corr = [];
        all_position_shuffles.(sprintf('%s',fields{f}))(t).weighted_corr = [];
        all_phase_shuffles.(sprintf('%s',fields{f}))(t).weighted_corr = [];
        all_theta_score.(sprintf('%s',fields{f}))(t).weighted_corr = [];
        end
    end
    
    for s = 1 : length(folders)
        cd(cell2mat(folders(s)))
        
        load Theta\thetaSeq_PREspikeTrain_circ_shuffle.mat
        load Theta\thetaSeq_phase_shuffle.mat
        load Theta\thetaseq_position_shuffle.mat
        load Theta\theta_sequence_quantification.mat
        
        
        fields = fieldnames(centered_averaged_thetaSeq);
        
        for d = 1 : length(fields)
            
            for t = 1 : length(centered_averaged_thetaSeq.(sprintf('%s',fields{d})))
                all_PREspike_shuffles.(sprintf('%s',fields{d}))(t).quadrant_ratio = [all_PREspike_shuffles.(sprintf('%s',fields{d}))(t).quadrant_ratio PREspike_train_circ_shuffle_scores.(sprintf('%s',fields{d}))(t).quadrant_ratio];
                all_position_shuffles.(sprintf('%s',fields{d}))(t).quadrant_ratio = [all_position_shuffles.(sprintf('%s',fields{d}))(t).quadrant_ratio position_shuffle.(sprintf('%s',fields{d}))(t).quadrant_ratio];
                all_phase_shuffles.(sprintf('%s',fields{d}))(t).quadrant_ratio = [all_phase_shuffles.(sprintf('%s',fields{d}))(t).quadrant_ratio phase_shuffle.(sprintf('%s',fields{d}))(t).quadrant_ratio];
                all_theta_score.(sprintf('%s',fields{d}))(t).quadrant_ratio = [all_theta_score.(sprintf('%s',fields{d}))(t).quadrant_ratio abs(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).quadrant_ratio)];

                all_PREspike_shuffles.(sprintf('%s',fields{d}))(t).weighted_corr = [all_PREspike_shuffles.(sprintf('%s',fields{d}))(t).weighted_corr PREspike_train_circ_shuffle_scores.(sprintf('%s',fields{d}))(t).weighted_corr];
                all_position_shuffles.(sprintf('%s',fields{d}))(t).weighted_corr = [all_position_shuffles.(sprintf('%s',fields{d}))(t).weighted_corr position_shuffle.(sprintf('%s',fields{d}))(t).weighted_corr];
                all_phase_shuffles.(sprintf('%s',fields{d}))(t).weighted_corr = [all_phase_shuffles.(sprintf('%s',fields{d}))(t).weighted_corr phase_shuffle.(sprintf('%s',fields{d}))(t).weighted_corr];
                all_theta_score.(sprintf('%s',fields{d}))(t).weighted_corr = [all_theta_score.(sprintf('%s',fields{d}))(t).weighted_corr abs(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).weighted_corr)];
            end
        end
        
    end
    
    for d = 1 : length(fields)
        for t = 1 : length(centered_averaged_thetaSeq.(sprintf('%s',fields{d})))
            mean_theta_score_QR = mean(all_theta_score.(sprintf('%s',fields{d}))(t).quadrant_ratio);
            PREspike_limit_QR = prctile([all_PREspike_shuffles.(sprintf('%s',fields{d}))(t).quadrant_ratio],95); %PRE spike train circ shuffle
            position_limit_QR = prctile([all_position_shuffles.(sprintf('%s',fields{d}))(t).quadrant_ratio],95); % position circ shuffle
            time_limit_QR = prctile([all_phase_shuffles.(sprintf('%s',fields{d}))(t).quadrant_ratio],95); %time bin shuffle
            max_limit_QR = max([PREspike_limit_QR time_limit_QR position_limit_QR]);
            
            average_thetaseq_significance.prot(p).(sprintf('%s',fields{d}))(t).QR_shuffles_sig = mean_theta_score_QR > [PREspike_limit_QR time_limit_QR position_limit_QR]; % save which shuffles passes
            average_thetaseq_significance.prot(p).(sprintf('%s',fields{d}))(t).QR_theta_sig = mean_theta_score_QR > max_limit_QR;% save it's overall significance
            
            mean_theta_score_WR = mean(all_theta_score.(sprintf('%s',fields{d}))(t).weighted_corr);
            PREspike_limit_WR = prctile([all_PREspike_shuffles.(sprintf('%s',fields{d}))(t).weighted_corr],95); %PRE spike train circ shuffle
            position_limit_WR = prctile([all_position_shuffles.(sprintf('%s',fields{d}))(t).weighted_corr],95); % position circ shuffle
            time_limit_WR = prctile([all_phase_shuffles.(sprintf('%s',fields{d}))(t).weighted_corr],95); %time bin shuffle
            max_limit_WR = max([PREspike_limit_WR time_limit_WR position_limit_WR]);
            
            average_thetaseq_significance.prot(p).(sprintf('%s',fields{d}))(t).WR_shuffles_sig = mean_theta_score_WR > [PREspike_limit_WR time_limit_WR position_limit_WR]; % save which shuffles passes
            average_thetaseq_significance.prot(p).(sprintf('%s',fields{d}))(t).WR_theta_sig = mean_theta_score_WR > max_limit_WR;% save it's overall significance

        end
    end
    
    keep p folders sessions session_names average_thetaseq_significance
end

% Save
if strcmp(data_type,'main')
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores';
elseif strcmp(data_type,'speed')
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Speed\Theta sequence scores';

end
save([path '\average_thetaseq_significance.mat'],'average_thetaseq_significance','-v7.3')


         
end