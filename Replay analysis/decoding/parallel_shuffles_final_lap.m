function [shuffled_track,all_shuffles] = parallel_shuffles_final_lap(shuffle_choice,analysis_type,num_shuffles,decoded_replay_events)
% runs run_shuffles on multiple cores in parallel shuffle_choice- determines what type of shuffles will be performed, entered as a string
%
% analysis type- vector of 0's and 1's for which replaying scoring method is used [line fitting, weighted
% correlation, "pac-man" path finding, and spearman correlation coefficient] (e.g. [1 0 0 1] would be line fitting and spearman correlation)
%
% num_shuffles= number of shuffles
% decoded_replay_events is data obtained from "load decoded_replay_events"
    
    disp(shuffle_choice)  %display shuffle choice

    if isempty(decoded_replay_events)
        load('Bayesian controls\Only first exposure\decoded_replay_events.mat')
    end


    p = gcp; % Starting new parallel pool
    if isempty(p)
        num_cores = 0;
        disp('parallel processing not possible');
    else
        num_cores = p.NumWorkers; 
    end
    
    % Set parameters
    shuffled_track = [];
    number_of_loops = num_cores;
    disp(number_of_loops)
    new_num_shuffles = ceil(num_shuffles/number_of_loops); %new number of shuffles based on cores availables

    parfor i = 1 : number_of_loops
        [out{i}.shuffled_track,out2{i}] = run_shuffles_final_lap(shuffle_choice,analysis_type,new_num_shuffles,decoded_replay_events);
    end
    
    all_shuffles = [];
%     num_tracks=length(out2{1}); % Currently not saving all shuffle data
%     for track = 1 : num_tracks
%         cellArray = cellfun(@(x) x(track).decoded_position, out2,'UniformOutput',0)';
%         all_shuffles(track).decoded_position= vertcat(cellArray{:});
%         all_shuffles(track).decoded_position= all_shuffles(track).decoded_position(1:num_shuffles,:);
%     end
    
    num_tracks = length(out{1}.shuffled_track);
    %num_replay_events = length(out{1}.shuffled_track(1).replay_events);
    
    % Allocate variables
    for track = 1 : num_tracks
        for event = 1: length(out{1}.shuffled_track(track).replay_events)
            shuffled_track(track).replay_events(event).linear_score = [];
            shuffled_track(track).replay_events(event).weighted_corr_score = [];
            shuffled_track(track).replay_events(event).path_score = [];
        end
    end
    % Save all shuffle scores for each event in each track (concatenate each loop of shuffles)
    for track = 1 : num_tracks
        for event = 1: length(out{1}.shuffled_track(track).replay_events)
            for i=1:number_of_loops
                shuffled_track(track).replay_events(event).linear_score = [shuffled_track(track).replay_events(event).linear_score; out{i}.shuffled_track(track).replay_events(event).linear_score];
                shuffled_track(track).replay_events(event).weighted_corr_score = [shuffled_track(track).replay_events(event).weighted_corr_score; out{i}.shuffled_track(track).replay_events(event).weighted_corr_score];
                shuffled_track(track).replay_events(event).path_score = [shuffled_track(track).replay_events(event).path_score; out{i}.shuffled_track(track).replay_events(event).path_score];
            end
        end
    end
    % Restructure the saved scores: copy exact number of shuffles needed (more shuffles will be performed if
    %total number is not equall divisible by the number of cores used for parallel processing
    for track = 1 : num_tracks
        for event = 1: length(out{1}.shuffled_track(track).replay_events)
                shuffled_track(track).replay_events(event).linear_score = shuffled_track(track).replay_events(event).linear_score(1:num_shuffles);
                shuffled_track(track).replay_events(event).weighted_corr_score = shuffled_track(track).replay_events(event).weighted_corr_score(1:num_shuffles);
                shuffled_track(track).replay_events(event).path_score = shuffled_track(track).replay_events(event).path_score(1:num_shuffles);
        end
    end
    
    %save type of shuffle used
    for track = 1 : num_tracks
        shuffled_track(track).shuffle_choice = shuffle_choice;% Add as info the type of shuffle run
    end
    
end