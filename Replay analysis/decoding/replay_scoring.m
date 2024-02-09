
function scored_replay = replay_scoring(data, place_fields_BAYESIAN, analysis_type)
% Runs up to 4 scoring methods for candidate replay events: line fitting, weighted correlation, path finding (or pacman), and spearman correlation coefficient.
% Modify_decoding.m subroutine is run to zero probability if no spikes from good place fields occur during time bin (which creates unwanted noise in
% these scoring algorithms only analyzes replay if there are no NaNs and at least 5 time bins in duration
% Input:
    % data: if empty, loads decoded_replay_events. Otherwise, pass replay event(s) that need to be scored (e.g. decoded replay of shuffle events)
    % analysis_type: 1 for selecting for running the scoring method and 0 for not. (e.g. [1 0 0 1] would be line fitting and spearman correlation)

    num_tracks = length(data);
    %num_replay_events = length(data(1).replay_events);
    
    % Allocate scores with NaNs
    for track = 1 : num_tracks
        [scored_replay(track).replay_events(1:length(data(track).replay_events)).linear_score] = deal(NaN);
        [scored_replay(track).replay_events(1:length(data(track).replay_events)).weighted_corr_score] = deal(NaN);
        [scored_replay(track).replay_events(1:length(data(track).replay_events)).spearman_score] = deal(NaN);
        [scored_replay(track).replay_events(1:length(data(track).replay_events)).spearman_p] = deal(NaN);
        [scored_replay(track).replay_events(1:length(data(track).replay_events)).path_score] = deal(NaN);
    end
    
    if analysis_type(1) == 1
        tmp = cellfun(@(x) {x.decoded_position}, {data.replay_events},'UniformOutput',0); % get all the decoded replay events per track
        unique_lengths= unique(cellfun(@(x) size(x,2),[tmp{:}])); %find all the time sizes per events (num of columns)
        clear tmp
        [all_tstLn,spd2Test]= construct_all_lines(unique_lengths);
        %decoded_lengths= cellfun(@(x) size(x,2), {data(1).replay_events.decoded_position});
    end
    
    if analysis_type(1) == 1  % Line fitting
        tic
        for track = 1 : num_tracks
            for event = 1 : length(data(track).replay_events)
                decoded_event = data(track).replay_events(event);
                if sum(isnan(decoded_event.decoded_position)) > 0 | length(decoded_event.timebins_centre) < 5  %NaN or event too short
                    scored_replay(track).replay_events(event).linear_score = NaN;
                else
                    decoded_position = modify_decoding(decoded_event);  % make column zero if there aren't any spikes
                    %decoded_position= decoded_event.decoded_position;
                    [scored_replay(track).replay_events(event).linear_score,~,~] = line_fitting2(decoded_position,all_tstLn(size(decoded_position,2)==unique_lengths),spd2Test);
                end
            end
        end
        toc
        clear all_tstLn spd2Test
    end
    
    if analysis_type(2) == 1 % Weighted correlation
        tic
        for track = 1 : num_tracks           
            for event = 1 : length(data(track).replay_events)
                decoded_event = data(track).replay_events(event);
                if sum(isnan(decoded_event.decoded_position)) > 0 | length(decoded_event.timebins_centre) < 5
                    scored_replay(track).replay_events(event).weighted_corr_score = NaN;
                else
                    decoded_position = modify_decoding(decoded_event);  % make column zero if there aren't any spikes
                    scored_replay(track).replay_events(event).weighted_corr_score = weighted_correlation(decoded_position);
                end
            end
        end
    end
    
    if analysis_type(3) == 1   % pacman
        for track = 1 : num_tracks            
            for event = 1 : length(data(track).replay_events)
                decoded_event = data(track).replay_events(event);
                if sum(isnan(decoded_event.decoded_position)) > 0 | length(decoded_event.timebins_centre) < 5
                    scored_replay(track).replay_events(event).path_score = NaN;
                else
                    decoded_position = modify_decoding(decoded_event);  % make column zero if there aren't any spikes
                    [scored_replay(track).replay_events(event).path_score,~] = pacman(decoded_position);
                end
            end
        end
    end
    
    if analysis_type(4) == 1  % spearman
        for track = 1 : num_tracks
            sorted_place_fields = place_fields_BAYESIAN.track(track).sorted_good_cells;
            for event = 1 : length(data(track).replay_events)
                decoded_event = data(track).replay_events(event);
                % Check if is no spike replay event case (rare)
                if isempty(decoded_event.spikes)
                    % Set the score and p value to NaN
                    scored_replay(track).replay_events(event).spearman_score = NaN;
                    scored_replay(track).replay_events(event).spearman_p = NaN;
                    continue;
                end
                if sum(isnan(decoded_event.decoded_position)) > 0 | length(decoded_event.timebins_centre) < 5
                    scored_replay(track).replay_events(event).spearman_score = NaN;
                    scored_replay(track).replay_events(event).spearman_p = NaN;
                else
                    spike_id = data(track).replay_events(event).spikes(:,1);
                    spike_times = data(track).replay_events(event).spikes(:,2);
                    [scored_replay(track).replay_events(event).spearman_score,scored_replay(track).replay_events(event).spearman_p] = spearman_median(spike_id, spike_times, sorted_place_fields);
                end
            end
        end
    end

end

function modified_decoded_event = modify_decoding(events)

modified_decoded_event = events.decoded_position;
for i = 1 : length(events.timebins_edges)-1
    % Check the case where a replay event has no good spikes
    if isempty(events.spikes)
        spikes = [];
    else
        spikes = find((events.spikes(:, 2) >= events.timebins_edges(i)) & (events.spikes(:,2) < events.timebins_edges(i+1)), 1);
    end
    
    if isempty(spikes)
        modified_decoded_event(:,i) = zeros(size(modified_decoded_event(:,i)));
    end   
end

end