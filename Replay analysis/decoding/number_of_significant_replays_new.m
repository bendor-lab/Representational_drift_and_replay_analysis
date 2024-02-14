function significant_replay_events = number_of_significant_replays_new(p_value_threshold, ripple_zscore_threshold, method, tracks_compared, globalPath)
% Establish significance for the replay events that are above a set ripple power threshold.
% The output will therefore have less replay events than the structures that have been loaded. The output will be two variables:
% sig_event_info - contains information about details of replay event
% significant_replay_event - info about replay events that are significant on one track

% INPUTS
%     p_value_threshold: INT. Default is 0.05
%     ripple_zscore_threshold: INT. Default is 3
%     method: method of analysis. 'path' for path finding/pacman, 'wcorr' for weighted correlation; 'linear' for linear fit and 'spearman' for spearman correlation
%     tracks_compared : [array of track ID].
%     if replay event significant on both tracks, we only register
%     the one with the higher bayesian biais.
%     globalPath : path of the folder where all the current analysis file
%     are stored

% Modified and commented by Pierre Varichon 2024

%% Load and set variables in current analysis folder
load(globalPath + "scored_replay_segments");
load(globalPath + "scored_replay");
load("extracted_replay_events");
load("extracted_position");
load("extracted_sleep_state");
load(globalPath + "decoded_replay_events");
load(globalPath + "decoded_replay_events_segments");

% Load global parameters
significant_replay_events.bin_size = 1;
significant_replay_events.smoothing_bin_size = 61*5;
significant_replay_events.bin_size_BIG = 61;

%% By default, set Z th. to 3 and p th. to .05

if isempty(ripple_zscore_threshold)
    ripple_zscore_threshold = 3; % 3 SD
end

if isempty(p_value_threshold)
    p_value_threshold = 0.05;
end

significant_replay_events.track1_and_1R_significant = [];
significant_replay_events.track2_and_2R_significant = [];

%% Data extraction

% Find indices of replay events with ripple power above threshold
replay_above_rippleThresh_index = find(replay.ripple_peak >= ripple_zscore_threshold);

% Extract replay score (e.g. wcorr value) and p value for each shuffle
% and event segment (whole, first, second) and for each track

[p_values, replay_scores] = extract_score_and_pvalue(scored_replay, scored_replay1, ...
    scored_replay2, method, replay_above_rippleThresh_index);

% Get the dimension of this new data
number_of_tracks = length(scored_replay);
number_of_events = length(replay_above_rippleThresh_index);

% Create variable significant_replay_event that contains all information
% related to replay events judged significant (for each track) with this function
significant_replay_events.p_value_threshold = p_value_threshold;
significant_replay_events.ripple_zscore_threshold = ripple_zscore_threshold;
significant_replay_events.method = method;
% Index of events with significant ripple power (to use if referencing other .mat files)
significant_replay_events.pre_ripple_threshold_index = replay_above_rippleThresh_index;

% Find midpoint time for each event to situate in time (start + end / 2)
significant_replay_events.all_event_times = (replay.onset(replay_above_rippleThresh_index) + ...
    replay.offset(replay_above_rippleThresh_index))/2;

% Histogram for small and big bins

startTime = min(position.t);
endTime = max(position.t);
binSize = significant_replay_events.bin_size;
bigBinSize = significant_replay_events.bin_size_BIG;

% Five second bins
significant_replay_events.time_bin_edges = startTime:binSize:endTime;
significant_replay_events.time_bin_centres = (startTime + binSize/2):binSize:(endTime - binSize/2);
significant_replay_events.HIST = histcounts(significant_replay_events.all_event_times, ...
    significant_replay_events.time_bin_edges);

% One minute bins
significant_replay_events.time_bin_edges_BIG = startTime:bigBinSize:endTime;
significant_replay_events.time_bin_centres_BIG = (startTime + bigBinSize/2):binSize:(endTime - bigBinSize/2);

%% For each event, we check if it's significant against all the shuffles

for track = 1 :  number_of_tracks % for each track
    for event = 1 : number_of_events %for each event
        
        % Minimum pvalue between the 3 max pvalues (not the same than the min pvalue)
        sig_event_info.p_value(track,event) = min([max(p_values.WHOLE(track,event,:)) max(p_values.FIRST_HALF(track,event,:)) max(p_values.SECOND_HALF(track,event,:))]);
        
        % Checks if event is significant with a specific type of shuffle (for either WHOLE and/or event segments)
        for i = 1 : size(p_values.WHOLE,3)
            sig_event_info.method_idx(track,event,i) = [(p_values.WHOLE(track,event,i)) < p_value_threshold | ...
                (p_values.FIRST_HALF(track,event,i)) < p_value_threshold/2 | ...
                (p_values.SECOND_HALF(track,event,i)) < p_value_threshold/2];
        end
        
        % Is the highest p value within the 3 shuffles less than the p value threshold (for the whole event and for segments)
        sig_event_info.segment_idx(track,event,:) = [max(p_values.WHOLE(track,event,:)) < p_value_threshold  ...
            max(p_values.FIRST_HALF(track,event,:)) < p_value_threshold/2  ...
            max(p_values.SECOND_HALF(track,event,:)) < p_value_threshold/2];
        
        % ASSESS SIGNIFICANCE : For each event and each scoring method, check if the highest p value within
        % the 3 shuffles is significant (check for the entire whole and for both segments)
        
        sig_event_info.significance(track,event) = any(sig_event_info.segment_idx(track,event,:));
        
        % Save the score within segments and whole event for each scoring method
        sig_event_info.replay_scores(track,event,:) = [replay_scores.WHOLE(track,event) ...
            replay_scores.FIRST_HALF(track,event) ...
            replay_scores.SECOND_HALF(track,event)];
        
        % If the event is not significant, set the replay score to 0
        if sig_event_info.significance(track,event) == 0
            sig_event_info.replay_segment_index(track,event) = 0;
            sig_event_info.best_replay_score(track,event) = 0;
        else
            % find maximum score from significant whole/segmented events
            [sig_event_info.best_replay_score(track,event), sig_event_info.replay_segment_index(track,event)] = ...
                max(sig_event_info.segment_idx(track,event,:) .* sig_event_info.replay_scores(track,event,:));
        end
    end
end

%% Multi-track events handling

% Find events that are significant for more than one track (multi_tracks doesn't consider events
% significant for first and second exposure, as this will be assigned later on)

% We check if currently comparing different tracks (if so, sum will be odd or == 10)
isComparingTrack = mod(sum(tracks_compared), 2) | sum(tracks_compared) == 10;

if isComparingTrack == 1
    % We AND each exposure / rexeposure
    idTrack1 = find(mod(tracks_compared, 2) == 0);
    idTrack2 = find(mod(tracks_compared, 2) == 1);
    
    sigDataConcat = [any(sig_event_info.significance(idTrack1, :), 1); ...
        any(sig_event_info.significance(idTrack2, :), 1)];
    
    % Find events that are significant for both tracks
    multi_tracks_index = find(sum(sigDataConcat, 1) > 1);
else
    multi_tracks_index = [];
end

% If only two significant tracks with one being the first segment and the second being the second segment, and no track has higher significant score for the whole replay event,
% this is an exception and both are simultaneously signficant (no need to remove) - WHOLE/SEGMENT based on highest significant score
exceptions = [];

for i = 1:length(multi_tracks_index)
    % If the whole event is not sig for any track
    % But is sig for one first segment
    % AND for one second segment
    % We add to exception
    
    if (isempty(find(sig_event_info.replay_segment_index(:,multi_tracks_index(i)) == 1, 1)) && ...
            length(find(sig_event_info.replay_segment_index(:,multi_tracks_index(i)) == 2))==1 && ...
            length(find(sig_event_info.replay_segment_index(:,multi_tracks_index(i))==3))==1)
        
        exceptions = [exceptions i];
    end
end

% Add these exceptions to the struct
significant_replay_events.multi_track_BUT_diff_segments_exception_index = multi_tracks_index(exceptions);
% Remove from multi-tracks events
multi_tracks_index(exceptions) = [];
% Add multi tracks to struct
significant_replay_events.multi_tracks_index = multi_tracks_index;

% Filtering multi-events

% Take the list of significant replay events, and deal with events where more than one track is significant
sig_event_info.significance_NO_MULTI = sig_event_info.significance;
sig_event_info.significance_NO_MULTI(:, multi_tracks_index) = 0; % events significant just for one track from the start
sig_event_info.significance_MULTI = zeros(size(sig_event_info.significance));
sig_event_info.significance_MULTI(:,multi_tracks_index) = sig_event_info.significance(:,multi_tracks_index);

%% Compute the bayesian biais to choose which track to assign the event to
% Only works with 2 tracks (for bayesian bias calculation)

c = 1;
significant_replay_events.BAYESIAN_BIAS_excluded_events_index = [];
sig_event_info.significance_BEST_BAYESIAN = zeros(size(sig_event_info.significance));

% For each event
for event = 1 : number_of_events
    for track = 1 :  number_of_tracks % for each track
        bayesian_sum(track)  = sum(sum(decoded_replay_events(track).replay_events(replay_above_rippleThresh_index(event)).decoded_position));  %sum bayesian in x and y dimensions WHOLE EVENT
        bayesian_sum1(track) = sum(sum(decoded_replay_events1(track).replay_events(replay_above_rippleThresh_index(event)).decoded_position));  %sum bayesian in x and y dimensions FIRST HALF
        bayesian_sum2(track) = sum(sum(decoded_replay_events2(track).replay_events(replay_above_rippleThresh_index(event)).decoded_position));  %sum bayesian in x and y dimensions SECOND HALF
    end
    
    % Index of significant tracks for this event
    tracks_that_are_significant = find(sig_event_info.significance(:, event) == 1);
    
    % Index of not significant tracks
    tracks_that_are_NOT_significant = find(sig_event_info.significance(:, event) == 0);
    
    % Find what part of replay is significant for this event
    type_of_event = sig_event_info.replay_segment_index(tracks_that_are_significant, event);
    
    bayesian_bias_ONLY_SIG_TRACKS(1:number_of_tracks) = 0;
    
    % Depending on the type of sig (second half, first half or whole event)
    
    if min(type_of_event) == 3   % only second half significant
        % We the bayesian bias between significant tracks
        bayesian_bias_ONLY_SIG_TRACKS(tracks_that_are_significant) = bayesian_sum2(tracks_that_are_significant)/sum(bayesian_sum2(tracks_that_are_significant));
        % We get the bayesian bias for all tracks
        bayesian_biasRAW = bayesian_sum2/sum(bayesian_sum2);
        
    elseif min(type_of_event) == 2 & max(type_of_event) == 2 % only first half significant
        bayesian_bias_ONLY_SIG_TRACKS(tracks_that_are_significant) = bayesian_sum1(tracks_that_are_significant)/sum(bayesian_sum1(tracks_that_are_significant));
        bayesian_biasRAW = bayesian_sum1/sum(bayesian_sum1);
        
    else % if whole event is significant on at least one track or mixtures of segments significant
        % Find the proportional value of summed bayesian across tracks (but only tracks with significant replay)
        bayesian_bias_ONLY_SIG_TRACKS(tracks_that_are_significant) = bayesian_sum(tracks_that_are_significant)/sum(bayesian_sum(tracks_that_are_significant));
        bayesian_biasRAW = bayesian_sum/sum(bayesian_sum);
    end
    
    % If original track and rexposure are significant, pick the one with a 
    % higher bayesian sum, and convert its bayesian sum into the sum of 
    % both the first and second exposure bayesian
    
    % If event is sig for T1 and T1-R
    if ~isempty(find(tracks_that_are_significant == 1, 1)) && ~isempty(find(tracks_that_are_significant == 3, 1))
        significant_replay_events.track1_and_1R_significant(size(significant_replay_events.track1_and_1R_significant,1)+1,1:3) = [event; bayesian_bias_ONLY_SIG_TRACKS(1); bayesian_bias_ONLY_SIG_TRACKS(3)];
        % if bayesian sum is higher for T1
        if bayesian_bias_ONLY_SIG_TRACKS(1) >= bayesian_bias_ONLY_SIG_TRACKS(3)
            bayesian_bias_ONLY_SIG_TRACKS(1) = bayesian_bias_ONLY_SIG_TRACKS(1) + bayesian_bias_ONLY_SIG_TRACKS(3); %combine both bayesians into T1
            bayesian_bias_ONLY_SIG_TRACKS(3) = 0; % change T3 to 0, as not significant anymore since T1 has been selected
            sig_event_info.significance(3,event) = 0;
        % if bayesian sum is higher for T3    
        else
            bayesian_bias_ONLY_SIG_TRACKS(3) = bayesian_bias_ONLY_SIG_TRACKS(3) + bayesian_bias_ONLY_SIG_TRACKS(1);
            bayesian_bias_ONLY_SIG_TRACKS(1) = 0;
            sig_event_info.significance(1,event) = 0;
        end
    end
    
    % If event is sig for T2 and T2-R
    if ~isempty(find(tracks_that_are_significant == 2, 1)) &&  ~isempty(find(tracks_that_are_significant == 4, 1))
        significant_replay_events.track2_and_2R_significant(size(significant_replay_events.track2_and_2R_significant, 1)+1,1:3) = ...
                                                    [event; bayesian_bias_ONLY_SIG_TRACKS(2); bayesian_bias_ONLY_SIG_TRACKS(4)];
                                                
        if bayesian_bias_ONLY_SIG_TRACKS(2) >= bayesian_bias_ONLY_SIG_TRACKS(4)
            bayesian_bias_ONLY_SIG_TRACKS(2) = bayesian_bias_ONLY_SIG_TRACKS(2) + bayesian_bias_ONLY_SIG_TRACKS(4);
            bayesian_bias_ONLY_SIG_TRACKS(4) = 0;
            sig_event_info.significance(4,event) = 0;
        else
            bayesian_bias_ONLY_SIG_TRACKS(4) = bayesian_bias_ONLY_SIG_TRACKS(4) + bayesian_bias_ONLY_SIG_TRACKS(2);
            bayesian_bias_ONLY_SIG_TRACKS(2) = 0;
            sig_event_info.significance(2,event) = 0;
        end
    end
    
    % Finally, for each multi-event,check if the remaining bayesian bias are above a set threshold and decide on which track is significant
    
        
    if max(bayesian_bias_ONLY_SIG_TRACKS) >= 1.2/2  %max of two tracks
        bayesian_bias_selection = floor(bayesian_bias_ONLY_SIG_TRACKS/max(bayesian_bias_ONLY_SIG_TRACKS)); %max value will be one, all other values will be zero
    
    % bayesian bias not different enough between tracks.  exclude mutli-track event
    elseif ~isempty(find(multi_tracks_index == event, 1))
        % Events excluded because multiple events and bayesian bias too similar (see max_bayesian_bias calculation)
        significant_replay_events.BAYESIAN_BIAS_excluded_events_index(c) = event;
        c = c + 1;
        bayesian_bias_selection = zeros(size(bayesian_bias_ONLY_SIG_TRACKS));
    
    % when the event is not significant for any track
    elseif sum(sig_event_info.significance(:,event)) == 0
        bayesian_bias_selection = zeros(size(bayesian_bias_ONLY_SIG_TRACKS));
    
    % only one track is significant
    elseif isempty(find(multi_tracks_index == event, 1))
        bayesian_bias_selection= 1;
        
    else  % to alert potential exceptions
        disp('ERROR')
        bayesian_bias_selection= 1;
    end
    
    sig_event_info.bayesian_bias_ONLY_SIG_TRACKS(:,event) = bayesian_bias_ONLY_SIG_TRACKS;
    sig_event_info.bayesian_biasRAW(:,event) = bayesian_biasRAW;
    sig_event_info.significance_BEST_BAYESIAN(:,event) = sig_event_info.significance(:,event).*bayesian_bias_selection'; %if multiple significant events, pick the one with the greater bayesian sum
end


%% HISTOGRAMS OF REPLAY ACTIVITY
for track=1:number_of_tracks
    sig_event_info.track(track).HIST = histcounts(significant_replay_events.all_event_times(sig_event_info.significance(track,:)==1),significant_replay_events.time_bin_edges); %significant events for each track at each time bin (includes multiple events)
    sig_event_info.track(track).HIST_BEST_BAYESIAN = histcounts(significant_replay_events.all_event_times(sig_event_info.significance_BEST_BAYESIAN(track,:)==1),significant_replay_events.time_bin_edges);%significant events for each track at each time bin (events ONLY sig for one track)
    sig_event_info.track(track).HIST_MULTI = histcounts(significant_replay_events.all_event_times(sig_event_info.significance_MULTI(track,:)==1),significant_replay_events.time_bin_edges); % events sig for multiple tracks at each time bin
    sig_event_info.track(track).HIST_NO_MULTI = histcounts(significant_replay_events.all_event_times(sig_event_info.significance_NO_MULTI(track,:)==1),significant_replay_events.time_bin_edges); % events sig for one track only at each time bin
end


%% REPLAY INFORMATION - output of function
for track = 1 :  number_of_tracks
    significant_replay_events.track(track).HIST = sig_event_info.track(track).HIST_BEST_BAYESIAN;
    significant_replay_events.track(track).index = find(sig_event_info.significance_BEST_BAYESIAN(track,:)==1); %index of sig events for this track
    significant_replay_events.track(track).ref_index = replay_above_rippleThresh_index(sig_event_info.significance_BEST_BAYESIAN(track,:)==1);
    significant_replay_events.track(track).event_times = significant_replay_events.all_event_times(significant_replay_events.track(track).index);
    significant_replay_events.track(track).replay_score = sig_event_info.best_replay_score(track,significant_replay_events.track(track).index); %score of sig replay events
    significant_replay_events.track(track).p_value =  sig_event_info.p_value(track,significant_replay_events.track(track).index); %pvalue
    significant_replay_events.track(track).bayesian_bias = sig_event_info.bayesian_biasRAW(track,significant_replay_events.track(track).index); %bayesian decoding proportional to number of tracks
    significant_replay_events.track(track).event_segment_best_score = sig_event_info.replay_segment_index(track,significant_replay_events.track(track).index); % info about if events is sig for whole or segment
    
    for i = 1:length(significant_replay_events.track(track).index)
        if (significant_replay_events.track(track).event_segment_best_score(i)==1)  %if best score in WHOLE event
            significant_replay_events.track(track).spikes{i} = decoded_replay_events(track).replay_events(replay_above_rippleThresh_index(significant_replay_events.track(track).index(i))).spikes;
            significant_replay_events.track(track).decoded_position{i} = decoded_replay_events(track).replay_events(replay_above_rippleThresh_index(significant_replay_events.track(track).index(i))).decoded_position;
            significant_replay_events.track(track).event_duration(i) = range(decoded_replay_events(track).replay_events(replay_above_rippleThresh_index(significant_replay_events.track(track).index(i))).timebins_edges);
            
        elseif (significant_replay_events.track(track).event_segment_best_score(i)==2) %if best score in first half of event
            significant_replay_events.track(track).spikes{i} = decoded_replay_events1(track).replay_events(replay_above_rippleThresh_index(significant_replay_events.track(track).index(i))).spikes;
            significant_replay_events.track(track).decoded_position{i} = decoded_replay_events1(track).replay_events(replay_above_rippleThresh_index(significant_replay_events.track(track).index(i))).decoded_position;
            significant_replay_events.track(track).event_duration(i) = range(decoded_replay_events1(track).replay_events(replay_above_rippleThresh_index(significant_replay_events.track(track).index(i))).timebins_edges);
            
        elseif (significant_replay_events.track(track).event_segment_best_score(i)==3) %if best score in second half of event
            significant_replay_events.track(track).spikes{i} = decoded_replay_events2(track).replay_events(replay_above_rippleThresh_index(significant_replay_events.track(track).index(i))).spikes;
            significant_replay_events.track(track).decoded_position{i} = decoded_replay_events2(track).replay_events(replay_above_rippleThresh_index(significant_replay_events.track(track).index(i))).decoded_position;
            significant_replay_events.track(track).event_duration(i) = range(decoded_replay_events2(track).replay_events(replay_above_rippleThresh_index(significant_replay_events.track(track).index(i))).timebins_edges);
        else
            significant_replay_events.track(track).spikes{i} = NaN;
            significant_replay_events.track(track).decoded_position{i} = NaN;
            significant_replay_events.track(track).event_duration(i) = NaN;
        end
    end
end


% For plotting
for track = 1 : number_of_tracks
    for j = 1 : length(significant_replay_events.time_bin_edges_BIG)-11 %for each time bin
        index = find(significant_replay_events.track(track).event_times >= significant_replay_events.time_bin_edges_BIG(j) & significant_replay_events.track(track).event_times < significant_replay_events.time_bin_edges_BIG(j+11));
        if isempty(index)
            significant_replay_events.track(track).mean_best_score(j) = NaN;
            significant_replay_events.track(track).mean_bayesian_bias(j) = NaN;
            significant_replay_events.track(track).median_log_pvalue(j) = NaN;
            significant_replay_events.track(track).min_log_pvalue(j) = NaN;
        else
            significant_replay_events.track(track).mean_best_score(j) = mean(significant_replay_events.track(track).replay_score(index));
            significant_replay_events.track(track).mean_bayesian_bias(j) = mean(significant_replay_events.track(track).bayesian_bias(index));
            significant_replay_events.track(track).median_log_pvalue(j) = median(log10(1e-5+significant_replay_events.track(track).p_value(index)));  %limit p-value to 1e-4
            significant_replay_events.track(track).min_log_pvalue(j) = min(log10(1e-5+significant_replay_events.track(track).p_value(index)));  %limit p-value to 1e-4
            
        end
    end
end

% Excluded events because they are significant for more than one track and can't be tell a part
number_of_excluded_events_from_BAYESIAN_BIAS = length(significant_replay_events.BAYESIAN_BIAS_excluded_events_index);
% disp(number_of_excluded_events_from_BAYESIAN_BIAS)

%% Save
switch method
    case 'wcorr'
        save(globalPath + "significant_replay_events_wcorr", "significant_replay_events");
    case 'spearman'
        save(globalPath + "significant_replay_events_spearman", "significant_replay_events");
    case 'path'
        save(globalPath + "significant_replay_events_path", "significant_replay_events");
    case 'linear'
        save(globalPath + "significant_replay_events_linear", "significant_replay_events");
end

end

%% Functions

% Function to retrieve the score and p value for each replay event

function [p_values, replay_scores] = extract_score_and_pvalue(scored_replay, scored_replay1, scored_replay2, method, replay_above_rippleThresh_index)

% INPUTS:
%     Scored_replay, scored_replay1, scored_replay2: structures loaded. Contain score and pvalue of each replay event for each method analysed.
%     Method: method of analysis. 'path' for path finding/pacman, 'wcorr' for weighted correlation; 'linear' for linear fit and 'spearman' for spearman correlation

number_of_tracks = length(scored_replay);
number_of_events = length(scored_replay(1).replay_events);

% Switch to get the fields we're gonna retrieve the data from
switch method
    case "path"
        pValueField = "p_value_path";
        scoreField = "path_score";
        
    case "wcorr"
        pValueField = "p_value_wcorr";
        scoreField = "weighted_corr_score";
        
    case "linear"
        pValueField = "p_value_linear";
        scoreField = "linear_score";
        
    case "spearman"
        pValueField = "spearman_p";
        scoreField = "spearman_score";
        
    otherwise
        disp('ERROR: scoring method not recognized');
        
end

% Create a p_values object with 3 fields :
% p-value of the entire replay events, (dimension = number of shuffle)
% of the first half of the replay
% of the second half of the replay

% Same for replay score but only one score per event

for track = 1 :  number_of_tracks % for each track
    for event = 1 : number_of_events % for each event
        p_values.WHOLE(track, event, :) = scored_replay(track).replay_events(event).(pValueField);
        replay_scores.WHOLE(track, event) = scored_replay(track).replay_events(event).(scoreField);
        p_values.FIRST_HALF(track,event,:) = scored_replay1(track).replay_events(event).(pValueField);
        replay_scores.FIRST_HALF(track,event) = scored_replay1(track).replay_events(event).(scoreField);
        p_values.SECOND_HALF(track,event,:) = scored_replay2(track).replay_events(event).(pValueField);
        replay_scores.SECOND_HALF(track,event) = scored_replay2(track).replay_events(event).(scoreField);
    end
end

% remove NANs for first and second half events - convert pvalue to 1
% (to make it non significant) and score to 0 (minimum score)

p_values.FIRST_HALF(isnan(p_values.FIRST_HALF)) = 1;
replay_scores.FIRST_HALF(isnan(replay_scores.FIRST_HALF)) = 0;
p_values.SECOND_HALF(isnan(p_values.SECOND_HALF)) = 1;
replay_scores.SECOND_HALF(isnan(replay_scores.SECOND_HALF)) = 0;

% If we have applied the threshold for ripple power, then select the correct indices

if ~isempty(replay_above_rippleThresh_index)
    p_values.WHOLE = p_values.WHOLE(:,replay_above_rippleThresh_index,:);
    p_values.FIRST_HALF = p_values.FIRST_HALF(:,replay_above_rippleThresh_index,:);
    p_values.SECOND_HALF = p_values.SECOND_HALF(:,replay_above_rippleThresh_index,:);
    replay_scores.WHOLE = replay_scores.WHOLE(:,replay_above_rippleThresh_index);
    replay_scores.FIRST_HALF = replay_scores.FIRST_HALF(:,replay_above_rippleThresh_index);
    replay_scores.SECOND_HALF = replay_scores.SECOND_HALF(:,replay_above_rippleThresh_index);
end

end