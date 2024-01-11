% BAYESIAN DECODING ERROR WITHIN EXPOSURES
% Looks at place cell remapping between different and same track exposures by calculating bayesian decoding error. 
% For each track exposure, calculates the decoding error using as template the other exposure to the same track. The template can be the whole session, first half or second half. 
% It also calculates the decoding error using exposure from different tracks (to assess remapping).
% MH, 11.02.20

function exposure_DecodingError = bayesian_decoding_error_exposures

   % TO ADD NEW COMPARISONS TO THE EXISTING STRUCTURE
    curr = pwd;
    cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\extracted_data'
    file = ['BetweenExposures_DecodingError_16x' curr(end) '.mat'];
    load(file)
    split = strsplit(curr,'\');
    idx= find(strcmp({betweenExposures_DecodingError.rat},split{8})==1);
    comparison = betweenExposures_DecodingError(idx).comparison;
    cd(curr)
    
    %Set parameters and load files
    parameters=list_of_parameters;
    load('extracted_clusters.mat');
    load('extracted_position.mat');
    load('extracted_laps.mat');
    
    %track comparisons to test
    comparisons = {[1,3],[3,1],[2,4],[4,2],[1,2],[2,1],[3,4],[4,3],[1,4],[3,2],[2,3],[4,1]}; % first number is decoded track, second is template track
    
    for c = 1 : length(comparisons)
        tracks_compared = comparisons{c};        
        decoded_track = tracks_compared(1);
        template_track = tracks_compared(2);
        
        templates = [];
        % Set lap IDs for the segments used a template to decode (first half, second half, or whole session)
        if template_track == 1 %if 16 laps run
            if lap_times(template_track).number_completeLaps > 16
                end_lap = 16;
            else
                end_lap = lap_times(template_track).number_completeLaps;
            end            
            templates(1,:) = [1 end_lap]; % full session
            templates(2,:) = [1 8]; % first half
            templates(3,:) = [9 end_lap]; % second half
        elseif template_track == 3 || template_track == 4 % if re-exposures
            templates(1,:) = [1 lap_times(template_track).number_completeLaps];  % full session
            templates(2,:) = [1 floor(lap_times(template_track).number_completeLaps/2)]; % first half
            templates(3,:) = [floor(lap_times(template_track).number_completeLaps/2)+1 lap_times(template_track).number_completeLaps]; % second half
        else % track 2
            templates(1,:) = [1 lap_times(template_track).number_completeLaps]; % full session
        end
        
        for i = 1 : size(templates,1) % repeat 3 times - each one using as template first half, second half, or whole session 
            
            % Template laps
            lap_start(1) = templates(i,1);
            lap_end(1) = templates(i,2);
  
            % Decoded session
            lap_start(2) = 1;
            lap_end(2) = lap_times(decoded_track).number_completeLaps;
            
            % Time window to be decoded : start and end time
            timeWindow_decodedLaps = [lap_times(decoded_track).completeLaps_start(lap_start(2)==lap_times(decoded_track).completeLap_id), lap_times(decoded_track).completeLaps_stop(lap_end(2)==lap_times(decoded_track).completeLap_id)];;
            
            % Calculates place field inside template lap(s) selected
            plFields_template.track = get_lap_place_fields(template_track,lap_start(1),lap_end(1),1); %using Bayesian place fields
            
            % Bayesian decoding
            bayesian_spike_count = spike_count(plFields_template,timeWindow_decodedLaps(1),timeWindow_decodedLaps(2),0,[]);
            estimated_position = bayesian_decoding(plFields_template,bayesian_spike_count,0,[]);
            bayesian_decodingError = decoding_error(estimated_position,plFields_template,template_track,decoded_track,timeWindow_decodedLaps(1),timeWindow_decodedLaps(2),0,'N');    % calculate decoding error
            
            % Save information in strcture
            if i == 1
                template_section = 'whole session';
            elseif i == 2
                template_section = 'first half';
            else
                template_section = 'second half';
            end 
            comparison(c).tracks_compared = [decoded_track template_track];
            comparison(c).template(i).template_section = template_section;
            comparison(c).template(i).decoded_laps = [lap_start(2) lap_end(2)];
            comparison(c).template(i).template_laps = [lap_start(1) lap_end(1)];
            comparison(c).template(i).decoding_error = bayesian_decodingError;
        end
        
    end
    exposure_DecodingError.comparison = comparison;
end
