function shuffle_type= score_shuffle(decoded_pos_tmp,tstLn_tmp,spd2Test,analysis_type)
num_shuffles_choices= length(decoded_pos_tmp);
num_tracks= length(decoded_pos_tmp{1});
% num_events= size(decoded_pos_tmp{1}(1).decoded_position,2);
num_shuffles= size(decoded_pos_tmp{1}(1).decoded_position,1);

% some pre-allocation for speed
shuffle_type= cell(num_shuffles_choices,1);

% p= gcp;
% num_cores = p.NumWorkers;

    parfor s=1:num_shuffles_choices
%     for s=1:num_shuffles_choices % if you want to run line_fitting
%     instead
        for track=1:num_tracks
            for event=1: size(decoded_pos_tmp{1}(track).decoded_position,2) %num_events
                for shuff=1:num_shuffles
                    decoded_position= decoded_pos_tmp{s}(track).decoded_position{shuff,event};
                        % Line fitting
                        if analysis_type(1) == 1   
                            if ~isnan(decoded_position)
                                [shuffle_type{s}.shuffled_track(track).replay_events(event).linear_score(shuff),~,~] = line_fitting2(decoded_position,tstLn_tmp,spd2Test);
%                              [shuffle_type{s}.shuffled_track(track).replay_events(event).linear_score(shuff),~,~,~] = line_fitting(decoded_position,0.02,10,1);
                            else
                                shuffle_type{s}.shuffled_track(track).replay_events(event).linear_score(shuff) = NaN;
                            end
                        end
                        % Weighted correlation
                        if analysis_type(2) == 1
                             if ~isnan(decoded_position)
                                 shuffle_type{s}.shuffled_track(track).replay_events(event).weighted_corr_score(shuff) = weighted_correlation(decoded_position);
                             else
                                 shuffle_type{s}.shuffled_track(track).replay_events(event).weighted_corr_score(shuff) = NaN;
                             end
                        end
                        % "pacman" path finding
                        if analysis_type(3) == 1
                            if ~isnan(decoded_position)
                                shuffle_type{s}.shuffled_track(track).replay_events(event).path_score(shuff) = pacman(decoded_position);
                            else
                                shuffle_type{s}.shuffled_track(track).replay_events(event).path_score(shuff) = NaN;
                            end
                        end
                end
            end
        end
    end
end