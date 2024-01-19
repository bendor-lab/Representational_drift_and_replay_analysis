% Plot, for each session and all track templates, the number of RE 
% per cell for all animals

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)
% Loads the file
load([PATH.SCRIPT, '\..\', 'Data\', 'corr_POST1_POST2_data']);

% We split by condition 
unique_cond = unique({(corr_POST1_POST2.condition)});

% We bind animals to different colors
unique_anim = unique({(corr_POST1_POST2.animal)});
animalsColors = containers.Map(unique_anim, {'r', 'g', 'b', 'm'});

for i = 1:length(unique_cond)
    % We find all the sessions in this condition
    current_cond = string(unique_cond(i));
    for track = 1:2
        subplot(5, 2, 2*(i - 1) + track)
        hold on;
        % We try to find the good sessions
        boolMatCond = ({corr_POST1_POST2.condition} == current_cond) & ([corr_POST1_POST2.track] == track);
        all_match_sess = corr_POST1_POST2(boolMatCond);
        for sessId = 1:length(all_match_sess)
            currentSess = all_match_sess(sessId);
            currentActivityMat = currentSess.activityMat;
            scatter(currentActivityMat(:, 2), currentActivityMat(:, 3), animalsColors(currentSess.animal));
        end
        
        % We compute the correlation
        r = corrcoef(currentActivityMat(:, 2), currentActivityMat(:, 3));
        r = r(2, 1);
        text(max(xlim), max(ylim), sprintf('r = %.2f', r))
        % We give a title
        xlabel("Nb Replays POST1")
        ylabel("Nb Replays POST2")
        title("Track " + track + " - " + current_cond)
        hold off;
    end
end