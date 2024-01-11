% THETA SEQUENCES QUANTIFICATION
% MH 2020
% Version used in theta_phase_pipeline
% For each direction and track, gets the average theta window. Then quantifies it with quadrant ratio and weighted correlation
% INPUTS:
    % plot_option - if 1, plots averaged theta sequences

function [centered_averaged_thetaSeq,centered_averaged_CONCAT_thetaSeq]= phase_theta_sequence_quantification(decoded_thetaSeq,concat_option,plot_option,save_option)

%%% Calculate average theta sequence
[centered_averaged_thetaSeq,centered_averaged_CONCAT_thetaSeq] = averaged_concat_theta_cycle(decoded_thetaSeq,concat_option);

if plot_option == 1
    plot_averaged_concat_theta_sequences(centered_averaged_thetaSeq,centered_averaged_CONCAT_thetaSeq,[]);
end

%%%%% Check if the current window is demarcating the theta sequence properly

[~,phase_shift] = check_phase_range_window(centered_averaged_CONCAT_thetaSeq);
phase_shift
% If the current settings are not the best, run again the pipeline till this point with new window range
if phase_shift ~= 1 %1 means no shifting needed
    theta_sequences_detection_decoding(phase_shift);
    [centered_averaged_thetaSeq,centered_averaged_CONCAT_thetaSeq] = averaged_concat_theta_cycle(decoded_thetaSeq);
    plot_averaged_concat_theta_sequences(centered_averaged_thetaSeq,centered_averaged_CONCAT_thetaSeq,[]);
end
    
%%%%% From each averaged theta sequence, quantify using: 

% Quadrant Ratio
centered_averaged_thetaSeq = phase_quadrant_ratio(centered_averaged_thetaSeq);

% Weighted Correlation
fields = fieldnames(centered_averaged_thetaSeq);
for d = 1 : length(fields) % for each direction
    for t = 1 : length(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))) % for each track
        central_cycle = centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).mean_relative_position;
        centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).weighted_corr = weighted_correlation(central_cycle);
    end
end

% % Line fitting
% time_bins_length = size(centered_averaged_thetaSeq.direction1(1).mean_relative_position,2); % all matrices should have the same size
% [all_tstLn,spd2Test]= construct_all_lines(time_bins_length);
% 
% for d = 1 : length(fields) % for each direction
%     thetaseq = centered_averaged_thetaSeq.(strcat(fields{d}));
%     for t = 1 : length(thetaseq) % for each track
%         central_cycle =  thetaseq(t).mean_relative_position;
%         [centered_averaged_thetaSeq.(strcat(fields{d}))(t).linear_score,centered_averaged_thetaSeq.(strcat(fields{d}))(t).linear_slope,~] = line_fitting2(central_cycle,all_tstLn(size(central_cycle,2)==time_bins_length),spd2Test);
%     end
% end


% Save
if strcmp(save_option,'Y')
    save('Theta\theta_sequence_quantification','centered_averaged_thetaSeq','centered_averaged_CONCAT_thetaSeq','-v7.3')
end

end 