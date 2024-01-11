
function plot_replay_score_distribution(method)
% Plot distribution of event scores for both weighted correlation and bayesian decoding 
% INPUT:
    % method: 'wcorr' for analyzing weighted correlation scores, and 'bayesian', for analysing probability sum

if strcmp(method,'wcorr')
    load('extracted_replay_plotting_info.mat')
end

scores = [];
pvals = [];
for i = 1 : 4
    a = track_replay_events(1).score_sig_events{i};
    b = track_replay_events(1).max_pval_sig_events{i};
    scores = [scores; a];
    pvals = [pvals; b];
end



end