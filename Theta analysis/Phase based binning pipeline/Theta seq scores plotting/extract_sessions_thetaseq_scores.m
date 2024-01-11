% EXTRACT THETA SEQUENCES SCORES FOR TRACK AND SESSION
% MH 2020
% Takes the averaged theta sequence score for each session and track calculated in the theta pipeline and saves it in a structure. Within each
% method structure, each row is a track and each column is a session. It's ordered from 16x8 to 16x1 sessions.


function quantification_scores = extract_sessions_thetaseq_scores(data_type,bayesian_control)


% Load name of data folders
if strcmp(data_type,'main') 
    sessions = data_folders;
elseif strcmp(data_type,'speed')
    sessions = speed_data_folders;
end
session_names = fieldnames(sessions);
if ~isempty(bayesian_control)
    path1 = '\Bayesian controls\Only first exposure';
    path2 = '\Bayesian controls\Only re-exposure';
    sessions_1 = arrayfun(@(y) arrayfun(@(x) append(sessions.(sprintf('%s',session_names{y})){x},path1),...
        1:length(sessions.(sprintf('%s',session_names{y}))),'UniformOutput',0),1:length(session_names),'UniformOutput',0);
    sessions_2 = arrayfun(@(y) arrayfun(@(x) append(sessions.(sprintf('%s',session_names{y})){x},path2),...
        1:length(sessions.(sprintf('%s',session_names{y}))),'UniformOutput',0),1:length(session_names),'UniformOutput',0);
end

c = 1;
for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',session_names{p}));
    for s = 1: length(folders)
        cd(folders{s})
        if ~isempty(bayesian_control)
            folders_F = cell2mat(sessions_1{1,p}(s));
            folders_R = cell2mat(sessions_2{1,p}(s));
        end

        centered_averaged_thetaSeq_F = load([folders_F '\Theta\theta_sequence_quantification.mat'],'centered_averaged_thetaSeq');
        centered_averaged_thetaSeq_R = load([folders_R '\Theta\theta_sequence_quantification.mat'],'centered_averaged_thetaSeq');
        centered_averaged_thetaSeq = centered_averaged_thetaSeq_F.centered_averaged_thetaSeq;
        
        for t = 1 : length(centered_averaged_thetaSeq.unidirectional)
            if ~isempty(bayesian_control) & t < 3
                centered_averaged_thetaSeq = centered_averaged_thetaSeq_F.centered_averaged_thetaSeq;
            elseif ~isempty(bayesian_control) & t > 2
                centered_averaged_thetaSeq = centered_averaged_thetaSeq_R.centered_averaged_thetaSeq;
            end
              
            quantification_scores(1).method = 'Quantification ratio';
            quantification_scores(1).scores(t,c) = centered_averaged_thetaSeq.unidirectional(t).quadrant_ratio;
            quantification_scores(1).theta_sig(t,c) = centered_averaged_thetaSeq.unidirectional(t).QR_theta_sig;
            quantification_scores(1).pvals{t,c} = centered_averaged_thetaSeq.unidirectional(t).QR_shuffles_pvals;
            quantification_scores(1).num_thetaseq(t,c) = length(centered_averaged_thetaSeq.unidirectional(t).thetaseq);
            
            quantification_scores(2).method = 'Weighted correlation';
            quantification_scores(2).scores(t,c) = centered_averaged_thetaSeq.unidirectional(t).weighted_corr;
            quantification_scores(2).theta_sig(t,c) = centered_averaged_thetaSeq.unidirectional(t).WC_theta_sig;
            quantification_scores(2).pvals{t,c} = centered_averaged_thetaSeq.unidirectional(t).WC_shuffles_pvals;
            quantification_scores(2).num_thetaseq(t,c) = length(centered_averaged_thetaSeq.unidirectional(t).thetaseq);
            
            %             quantification_scores(3).method = 'Line fitting score';
            %             quantification_scores(3).scores(t,c) = centered_averaged_thetaSeq.unidirectional(t).linear_score;
            %             quantification_scores(4).method = 'Line fitting slope';
            %             quantification_scores(4).scores(t,c) = entered_averaged_thetaSeq.direction1(t).linear_slope(2);
        end
        c = c + 1;
    end
    
end

if strcmp(data_type,'main') & isempty(bayesian_control)
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\';
elseif strcmp(data_type,'speed')
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Speed\Theta sequence scores\';
elseif strcmp(data_type,'main') & ~isempty(bayesian_control)
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\Bayesian controls\';
end
    save([path 'session_thetaseq_scores.mat'],'quantification_scores')

end
        