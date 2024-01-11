% CHECK BEST PHASE RANGE FOR CREATING THETA WINDOW
% MH 2020
% Checks if the theta window is correctly fitting the theta sequence. Looks at different combinations of windows ranges (from -2 bins to +2bins
% compared to the current one) and checks which one has higher weighted correlation score. It does only for re-exposure tracks, where the theta
% sequences are well defined. 
% OUTPUT: 
    % best_window: indices of window range that best demarcates the theta sequence


function [best_window_indices,phase_shift] = check_phase_range_window(centered_averaged_CONCAT_thetaSeq)

if isempty(centered_averaged_CONCAT_thetaSeq)
    load('Theta\theta_sequence_quantification.mat')
end

parameters = list_of_parameters;
window_width = parameters.number_cycle_bins;
% Creates different theta windows, shifting from 1 to 2 bins backwards and forward
window_options = [{window_width-1:window_width*2-2},{window_width:window_width*2-1},{window_width+1: window_width*2}, {window_width+2: window_width*2+1},...
    {window_width+3: window_width*2+2}];
phase_shift_options = [3,2,1,0,-1];

all_scores =[];
fields = fieldnames(centered_averaged_CONCAT_thetaSeq);
for d = 1 : length(fields) % for each direction
    thetaseq = centered_averaged_CONCAT_thetaSeq.(strcat(fields{d}));
    for t = 3 : length(thetaseq) % for re-exposures only
        for w = 1 : length(window_options)
            central_cycle = thetaseq(t).mean_relative_position(:,window_options{w});
            temp_scores.(strcat(fields{d}))(t).weighted_corr(w) = weighted_correlation(central_cycle);
        end
        [~,temp_scores.(strcat(fields{d}))(t).max_score_window] = max(temp_scores.(strcat(fields{d}))(t).weighted_corr);
        all_scores = [all_scores temp_scores.(strcat(fields{d}))(t).max_score_window];
    end
end

mean_score = floor(median(all_scores));
best_window_indices = window_options{mean_score};
phase_shift = phase_shift_options(mean_score); 



end
