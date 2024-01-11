
function consecutive_laps_DecodingError = bayesian_decoding_error_consecutive_laps(number_of_laps)
% Looks at place cell stability using bayesian decoding error. For each track, compares each consecutive lap, 
% and gets the mean and median decoding error (per lap and as a single value).
% Marta Huelin, 02.20

    % Set parameters and load files
    parameters=list_of_parameters;
    load('extracted_clusters.mat');
    load('extracted_position.mat');
    load('extracted_laps.mat');
    
    for track = 1: length(lap_times)
        if lap_times(track).number_completeLaps == 1 % Skip track 2 for 1 lap as not enough laps to calculate decoding error
            continue
        end
                
        consecutive_laps(track).tracks_compared = mat2str([track track]);
        consecutive_laps(track).laps_jump =number_of_laps;
        
        for lap = 1 : lap_times(track).number_completeLaps-number_of_laps
            
            
            % Set lap IDs for the segments used a template to decode and for the segments decoded
            % Template laps
            lap_start(1) = lap_times(track).completeLap_id(lap+number_of_laps);
            lap_end(1) = lap_times(track).completeLap_id(lap+number_of_laps);
            % Decoded laps
            lap_start(2) = lap_times(track).completeLap_id(lap);
            lap_end(2) =lap_times(track).completeLap_id(lap);
            
            % Time window to be decoded
            timeWindow_decodedLaps = [lap_times(track).completeLaps_start(lap_start(2)==lap_times(track).completeLap_id), lap_times(track).completeLaps_stop(lap_end(2)==lap_times(track).completeLap_id)];
            
            % Calculates place field inside template lap(s) selected
            plFields_template.track = get_lap_place_fields(track,lap_start(1),lap_end(1),'Y','complete'); %using Bayesian place fields
            
            % Bayesian decoding
            bayesian_spike_count = spike_count(plFields_template,timeWindow_decodedLaps(1),timeWindow_decodedLaps(2),0,[]);
            estimated_position = bayesian_decoding(plFields_template,bayesian_spike_count,0,[]);
            bayesian_decodingError = decoding_error(estimated_position,plFields_template,track,track,timeWindow_decodedLaps(1),timeWindow_decodedLaps(2),'N');    % calculate decoding error
            
            % Save selected inputs from bayesian_decodingError into a new structure, where each column will be the value per lap
            consecutive_laps(track).decoded_lap(lap,:) = lap_start(2);
            consecutive_laps(track).template_lap(lap,:) = lap_start(1);
            consecutive_laps(track).mean_trackDecodingError(lap,:) = bayesian_decodingError.mean_trackDecodingError;
            consecutive_laps(track).median_trackDecodingError(lap,:) = bayesian_decodingError.median_trackDecodingError;
            consecutive_laps(track).mean_weighted_decodingError(lap,:) = bayesian_decodingError.mean_weighted_decodingError;
            consecutive_laps(track).median_weighted_decodingError(lap,:) = bayesian_decodingError.median_weighted_decodingError;
        end

        consecutive_laps_DecodingError = consecutive_laps;
    end
            

end