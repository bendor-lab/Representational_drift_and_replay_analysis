% LAP DECODING ERRROR
% MH, 05.2020
% Based on van der Meer et al(2017,Hippocampus). Optimizing for Generalization in the Decoding of Internally Generated Activity in the Hippocampus
% Calculate track decoding error by calculating the error for each lap and then averaging. Each lap is decoded using the ratemaps of all the other
% laps (so, excluding the decoded lap).
% Codes used are: get_place_fields_lap_exclusion.mat; spike_count.mat; bayesian_decoding.mat; decoding_error.mat


function track_decoding_error = lap_decoding_error(save_option)

load extracted_laps.mat
load extracted_position.mat
parameters =  list_of_parameters;

c = 1;

foldername = strsplit(pwd,'\');
session = foldername{end};

for track = 1 : length(lap_times)
    
    lap_IDs = lap_times(track).completeLap_id;
    % Save in structure
    track_decoding_error(c).protocol = str2num(session(end));
    track_decoding_error(c).track = track;
    
    for lap = 1 : length(lap_IDs)
        
        % Select lap IDs before (chunk1) and after (chunk2) the excluded lap
        if lap == 1 % if it's the first lap
            chunk1 = [lap+1 length(lap_IDs)];
            chunk2 = [];
        elseif lap == length(lap_IDs) % if it's the last lap
            chunk1 = [1 lap-1];
            chunk2 = [];
        else
            chunk1 = [1 lap-1];
            chunk2 = [lap+1 length(lap_IDs)];
        end
        
        % If it's 1 lap track, correct and run individually
        if length(lap_IDs) == 1 %if it's 1 lap
            LAP1 = 1;
            % Runs twice, using each half a lap as a template and as decoded 
            for t = 1 : 2
                if t == 1
                    % Decoded time window is first half lap
                    decoded_timeWindow = [lap_times(track).halfLaps_start(1) lap_times(track).halfLaps_stop(1)];
                    chunk1 = [2 2]; %template is second half lap
                    chunk2 = [];
                else
                    % Decoded time window is second half lap
                    decoded_timeWindow = [lap_times(track).halfLaps_start(2) lap_times(track).halfLaps_stop(2)];
                    chunk1 = [1 1]; %template is first half lap
                    chunk2 = [];
                end
                plFields_excluded_lap.track = get_place_fields_lap_exclusion(track,chunk1,chunk2,1,LAP1);
                
                % Bayesian decoding
                bayesian_spike_count = spike_count(plFields_excluded_lap,decoded_timeWindow(1),decoded_timeWindow(2),[]);
                estimated_position = bayesian_decoding(plFields_excluded_lap,bayesian_spike_count,0,[]);
                bayesian_decodingError = decoding_error(estimated_position,plFields_excluded_lap,track,track,...
                    decoded_timeWindow(1),decoded_timeWindow(2),LAP1,[]);    % calculate decoding error
                
                % Save in structure
                track_decoding_error(c).decoded_laps(t) = lap/2;
                track_decoding_error(c).template_laps(t) = 0.5;
                track_decoding_error(c).median_decoding_error(t) = bayesian_decodingError.median_trackDecodingError;
                track_decoding_error(c).true_positions{t} = bayesian_decodingError.track_actual_positions; %true position
                track_decoding_error(c).decoded_positions{t} = bayesian_decodingError.track_decoded_positions; % decoded positions
                track_decoding_error(c).decoded_errors{t} = bayesian_decodingError.track_decodingErrors; % true - decoded position
                track_decoding_error(c).decoding_error_info{t} = bayesian_decodingError;
            end
            
        else % for more than one lap, get the decoded window using full laps
            LAP1 = 0;
            % Decoded time window
            decoded_timeWindow = [lap_times(track).completeLaps_start(lap) lap_times(track).completeLaps_stop(lap)];
            
            
            % Get place fields
            plFields_excluded_lap.track = get_place_fields_lap_exclusion(track,chunk1,chunk2,1,LAP1);
            
            % Bayesian decoding
            bayesian_spike_count = spike_count(plFields_excluded_lap,decoded_timeWindow(1),decoded_timeWindow(2),[]);
            estimated_position = bayesian_decoding(plFields_excluded_lap,bayesian_spike_count,0,[]);
            bayesian_decodingError = decoding_error(estimated_position,plFields_excluded_lap,track,track,...
                decoded_timeWindow(1),decoded_timeWindow(2),LAP1,'N');    % calculate decoding error
            
            % Save in structure
            track_decoding_error(c).decoded_laps(lap) = lap;
            if LAP1 == 1
                track_decoding_error(c).template_laps(lap) = 2;
            elseif isempty(chunk2)
                track_decoding_error(c).template_laps{lap} = chunk1;
            else
                track_decoding_error(c).template_laps{lap} = [chunk1; chunk2];
            end
            track_decoding_error(c).median_decoding_error(lap) = bayesian_decodingError.median_trackDecodingError;
            track_decoding_error(c).true_positions{lap} = bayesian_decodingError.track_actual_positions; %true position
            track_decoding_error(c).decoded_positions{lap} = bayesian_decodingError.track_decoded_positions; % decoded positions
            track_decoding_error(c).decoded_errors{lap} = bayesian_decodingError.track_decodingErrors; % true - decoded position
            track_decoding_error(c).decoding_error_info{lap} = bayesian_decodingError;
        end
    end
    
    % Calculate mean and median decoding error for the whole track
    track_decoding_error(c).track_mean_MedianDecodingError = mean([track_decoding_error(c).median_decoding_error]);
    all_decoding_error = [];
    for j = 1 : length(track_decoding_error(c).decoded_errors)
        all_decoding_error = [all_decoding_error track_decoding_error(c).decoded_errors{j}];
    end
    track_decoding_error(c).track_MEDIAN_decoding_error = median(all_decoding_error);
    
    c = c+1;
end

   if strcmp(save_option, 'Y')
         save('track_decoding_error','track_decoding_error','-v7.3');
   end
end

 
