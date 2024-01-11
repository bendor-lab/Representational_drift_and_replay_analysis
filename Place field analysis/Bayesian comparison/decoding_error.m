% DECODING ERROR FOR BAYESIAN DECODING 
% Marta Huelin_2019
% Calculates decoding error between real position and the bayesian decoded position. 
% INPUTS:
    % estimated_position: structure witht the matrix and information of the position decoded.
    % place_fields: structure. place fields as a template for decoding
    % template_tracks: Int.track(s) used as a template to decode
    % decoded_tracks: Int. track(s) that have been decoded
    % start_time: Int. start time of the part that has been decoded
    % end_time: Int. end time of the part that has been decoded
    % LAP1: for decoding single laps, 1 or 0 (for not 1 lap)
    % figure option: 'Y' or []. If chosen, plots real position with estimated position on top, and sections of the decoding at different time points.
    
    function bayesian_decodingError = decoding_error(estimated_position,place_fields,template_tracks,decoded_tracks,start_time,end_time,LAP1,figure_option)
    
    load('extracted_position.mat');
    load('extracted_laps.mat');
    parameters =  list_of_parameters;
    
    % Decoded position
    if isempty(estimated_position)
        load('estimated_position.mat')
    end
    
    for track_id = 1 : length(decoded_tracks)
        
        if isempty(start_time) && isempty(end_time)   % if no start and end time have been input
            start_time = min(position.linear(track_id).timestamps);
            end_time   = max(position.linear(track_id).timestamps);
        end
               
        decoded_track = decoded_tracks(track_id);
        template_track = template_tracks(track_id);
        start_time = start_time(track_id);
        end_time = end_time(track_id);
        
        % Finds timestamps and position data of the decoded data in the raw data
        linear_time = position.t(position.t>=start_time & position.t<=end_time);
        linear = position.linear(decoded_track).linear(position.t>=start_time & position.t<=end_time);         
        linear(isnan(linear)) = -100;     %to interpolate, first remove NaNs from linear position by converting them to negative values
        decoded_time = estimated_position(track_id).run_time_centered;
        decoded_run = estimated_position(track_id).run;

        % Finds the time indices of the section of place fields that has been used as a template to decode the rest of the data            
        % If needed, subtracts this section from the data in order to calculate the decoding error
        if any(place_fields.track(track_id).time_window(1) <=  linear_time) ==1 && any(place_fields.track(track_id).time_window(1) >= linear_time) ==1 && ... %check if section of data used to decode is part of your decoded data
           any(place_fields.track(track_id).time_window(2) <=  linear_time) ==1 && any(place_fields.track(track_id).time_window(2) >= linear_time) ==1
            
            time_window_1 = place_fields.track(track_id).time_window(1);
            time_window_2 = place_fields.track(track_id).time_window(2);
            timeWindow1_index = find(lap_times(template_track).completeLaps_start == time_window_1); %finds index of first start_lap_time of section used to calculate pl fields
            timeWindow2_index = find(lap_times(template_track).completeLaps_stop == time_window_2); %finds index of last stop_lap_time of section used to calculate pl fields
            
            if timeWindow1_index == 1 % if the first lap is the actual first lap of that session 
                track_indices = find(~isnan(position.linear(decoded_track).linear)==1);
                time_window_1 = position.t(track_indices(1)-1); %use first timestamp of first lap
            end
            
            if timeWindow2_index(end) == length(lap_times(decoded_track).completeLaps_stop) %if the last stop_lap_time of the section is the actual last lap
                track_indices = find(~isnan(position.linear(decoded_track).linear)==1);
                time_window_2 = position.t(track_indices(end)); %find index of last timestamp in the track
            end
            
            timeWindow_indices = find(position.t > time_window_1 & position.t < time_window_2); %otherwise uses indices of time window used to calculate pl fields           
            
            linear(timeWindow_indices)=[];          %remove section from position data
            linear_time(timeWindow_indices)=[];     %remove section from time data          
            
            % finds correspondent time window edges in the binned run_time
            [~,indx1] = min(abs(estimated_position(track_id).run_time_centered - position.t(timeWindow_indices(1)))); %finds index of closest value to time window(1) time in run_time
            [~,indx2] = min(abs(estimated_position(track_id).run_time_centered - position.t(timeWindow_indices(end)))); %finds index of closest value to time window(2) time in run_time
            timeWindow_binned_indices = find(estimated_position(track_id).run_time_centered > estimated_position(track_id).run_time_centered(indx1)& estimated_position(track_id).run_time_centered < estimated_position(track_id).run_time(indx2));
            decoded_time(timeWindow_binned_indices)=[]; %remove section from estimated time data
            decoded_run(:,timeWindow_binned_indices)=[]; %remove section from estimated position data
        
        end
        
        % Finds the maximum decoded probability for each time bin 
        all_maxProbability = [];
        decoded_positions =[];
        % Look for columns with no spikes - all values in the column will be the same (close to zero)
        sim_idx = all(~diff(decoded_run));
        empty_col = find(sim_idx == 1);        
        for jj = 1 : size(decoded_run,2)
            if ~any(ismember(empty_col,jj))
                [maxProbability_bin,indx_maxProbability_bin] =  max(decoded_run(:,jj)); %find the value and index of maximum probability per time bin(each column)
                all_maxProbability = [all_maxProbability, maxProbability_bin]; % save all max probabilities
                decoded_positions = [decoded_positions, estimated_position(track_id).position_bin_centres(indx_maxProbability_bin)]; %find the maximum probability decoded position per time bin
            else
                disp(['Excluded bin in track ' num2str(decoded_tracks)])
            end
        end

        % conversion from actual position in each time bin to the closest binned position value
        actual_positions = interp1(linear_time,linear,decoded_time,'nearest'); %finds the actual position for each decoded time bin
        converted_positions = (round(actual_positions*length(estimated_position(track_id).position_bin_centres)))/length(estimated_position(track_id).position_bin_centres); %find the closest 'bin value' to the actual position value

        % Decoding error only using position data from when the rat is in the track and when the rat is running (velocity threshold)
        track_indices = find(converted_positions >= 0); % find the indices corresponding to running in tracks        
        track_decoded_time = decoded_time(track_indices);
        track_decoded_positions = decoded_positions(track_indices);
        track_converted_positions = converted_positions(track_indices);
        track_all_max_prob = all_maxProbability(track_indices);
                
        % scale velocity to new time bins 
        velocity_binned = interp1(position.t,abs(position.v_cm),track_decoded_time,'nearest'); %finds the velocity for each decoded time bin
        velocity_index =  find(velocity_binned > parameters.speed_threshold_laps); %find indices where rat is running 
        bayesian_decodingError(track_id).track_decoded_positions = track_decoded_positions(velocity_index); 
        bayesian_decodingError(track_id).track_actual_positions = track_converted_positions(velocity_index);
        bayesian_decodingError(track_id).track_time = track_decoded_time(velocity_index);
        track_all_max_prob_speedfiltered = track_all_max_prob(velocity_index);
        
        % Remove decoded positions that have a max probability lower than 0.1 (thresholded)
        high_prob_indices = find(track_all_max_prob(velocity_index)>0.1);
        bayesian_decodingError(track_id).track_thresholded_decoded_positions = bayesian_decodingError(track_id).track_decoded_positions(high_prob_indices); 
        bayesian_decodingError(track_id).track_thresholded_actual_positions =  bayesian_decodingError(track_id).track_actual_positions(high_prob_indices);
        bayesian_decodingError(track_id).track_thresholded_time = bayesian_decodingError(track_id).track_time(high_prob_indices);
       
        % alocate variables
        bayesian_decodingError(track_id).track_decodingErrors = [];
        bayesian_decodingError(track_id).weighted_decodingErrors = [];
        bayesian_decodingError(track_id).weighted_thresholded_decodingErrors = [];
        
        % Calculate decoding error with and without threshold for low probabilities
        bayesian_decodingError(track_id).track_decodingErrors = abs(bayesian_decodingError(track_id).track_decoded_positions-bayesian_decodingError(track_id).track_actual_positions);   % difference between actual and decoded position
        bayesian_decodingError(track_id).weighted_decodingErrors = [bayesian_decodingError(track_id).weighted_decodingErrors, bayesian_decodingError(track_id).track_decodingErrors.*track_all_max_prob_speedfiltered]; % multiply each diff value by the max probability on that time bin   
        bayesian_decodingError(track_id).track_thresholded_decodingErrors = abs(bayesian_decodingError(track_id).track_thresholded_decoded_positions-bayesian_decodingError(track_id).track_thresholded_actual_positions);   % difference between actual and decoded position
        bayesian_decodingError(track_id).weighted_thresholded_decodingErrors = [bayesian_decodingError(track_id).weighted_thresholded_decodingErrors, bayesian_decodingError(track_id).track_thresholded_decodingErrors.*track_all_max_prob_speedfiltered(high_prob_indices)]; % multiply each diff value by the max probability on that time bin   

        bayesian_decodingError(track_id).mean_trackDecodingError = mean(bayesian_decodingError(track_id).track_decodingErrors); %median decoding error
        bayesian_decodingError(track_id).median_trackDecodingError = median(bayesian_decodingError(track_id).track_decodingErrors); %mean decoding error
        bayesian_decodingError(track_id).mean_weighted_decodingError = mean(bayesian_decodingError(track_id).weighted_decodingErrors)/sum(track_all_max_prob_speedfiltered); %mean weighted decoding error
        bayesian_decodingError(track_id).median_weighted_decodingError = median(bayesian_decodingError(track_id).weighted_decodingErrors)/sum(track_all_max_prob_speedfiltered); %median weighted decoding error

        bayesian_decodingError(track_id).mean_thresholded_trackDecodingError = mean(bayesian_decodingError(track_id).track_thresholded_decodingErrors); %median decoding error
        bayesian_decodingError(track_id).median_thresholded_trackDecodingError = median(bayesian_decodingError(track_id).track_thresholded_decodingErrors); %mean decoding error
        bayesian_decodingError(track_id).mean_weighted_thresholded_decodingError = mean(bayesian_decodingError(track_id).weighted_thresholded_decodingErrors)/sum(track_all_max_prob_speedfiltered(high_prob_indices)); %mean weighted decoding error
        bayesian_decodingError(track_id).median_weighted_thresholded_decodingError = median(bayesian_decodingError(track_id).weighted_thresholded_decodingErrors)/sum(track_all_max_prob_speedfiltered(high_prob_indices)); %median weighted decoding error
    
        %sanity check figure : plots decoded position on top of real one, coloured by probability
        if strcmp(figure_option,'Y')
            zero_prob =  find(track_all_max_prob_speedfiltered<0.1);
            low_prob = find(track_all_max_prob_speedfiltered >= 0.1 & track_all_max_prob_speedfiltered < 0.4);
            middle_prob = find(track_all_max_prob_speedfiltered >=0.4 & track_all_max_prob_speedfiltered <= 0.75);
            high_prob = find(track_all_max_prob_speedfiltered > 0.75);
            
            figure
            p = plot(bayesian_decodingError(track_id).track_time,bayesian_decodingError(track_id).track_actual_positions,'Color',[0.4, 0.4, 0.4],'LineWidth',3);
            hold on
            p1 = scatter(bayesian_decodingError(track_id).track_time(zero_prob),bayesian_decodingError(track_id).track_decoded_positions(zero_prob),40,'o','MarkerFaceColor',[0 0 0.4],'MarkerEdgeColor',[0 0 0.4]);
            p2 = scatter(bayesian_decodingError(track_id).track_time(low_prob),bayesian_decodingError(track_id).track_decoded_positions(low_prob),40,'o','MarkerFaceColor',[0.2 0.2 0.6],'MarkerEdgeColor',[0.2 0.2 0.6]);
            p3 = scatter(bayesian_decodingError(track_id).track_time(middle_prob),bayesian_decodingError(track_id).track_decoded_positions(middle_prob),40,'o','MarkerFaceColor',[0.6 0 0.6],'MarkerEdgeColor',[0.6 0 0.6]);
            p4 = scatter(bayesian_decodingError(track_id).track_time(high_prob),bayesian_decodingError(track_id).track_decoded_positions(high_prob),40,'o','MarkerFaceColor',[0.8, 0.0, 0.1],'MarkerEdgeColor',[0.8, 0.0, 0.1]);
            title(strcat('track',num2str(decoded_track)))
            xlabel('Time (sec)')
            ylabel('Linearized position (cm)')
            legend([p(1),p1(1),p2(1),p3(1),p4(1)],{'Linear position','Zero prob (<0.1)', 'Low prob(>=0.1 & <0.4)', 'Middle prob(>=0.4 & <=0.75)', 'High prob(>0.75)'},'Position',[0.92 0.85 0.045 0.05])
        end
        
        %% Decoding error lap per lap
        
        % Find number of laps in the data that is being decoded
        if LAP1 ~= 1 
            lap_start_times = lap_times(decoded_track).completeLaps_start(lap_times(decoded_track).completeLaps_start >= start_time & lap_times(decoded_track).completeLaps_start< end_time);
            lap_stop_times = lap_times(decoded_track).completeLaps_stop(lap_times(decoded_track).completeLaps_stop <= end_time);
        else % if it's 1 Lap track
            lap_start_times = lap_times(decoded_track).halfLaps_start(lap_times(decoded_track).halfLaps_start >= start_time & lap_times(decoded_track).halfLaps_start< end_time);
            lap_stop_times = lap_times(decoded_track).halfLaps_stop(lap_times(decoded_track).halfLaps_stop <= end_time);
        end
        
        % Find the start times for each decoded lap and find the nearest value to estimated_position.track_time
        bayesian_decodingError(track_id).decoded_LapStartTimes = [];
        for jj = 1 : length(lap_start_times)
            [~,min_ind] = min(abs(lap_start_times(jj) - bayesian_decodingError(track_id).track_time)); %finds index of closest value to lap start time in track_time
            bayesian_decodingError(track_id).decoded_LapStartTimes = [bayesian_decodingError(track_id).decoded_LapStartTimes, bayesian_decodingError(track_id).track_time(min_ind)]; % new lap start time values
        end
        
        % Calculates median and mean error per lap
        bayesian_decodingError(track_id).medianError_perLap = [];
        bayesian_decodingError(track_id).meanError_perLap = [];
        for kk = 1 : length(lap_start_times)
            indices_perLap = find(bayesian_decodingError(track_id).track_time >= bayesian_decodingError(track_id).decoded_LapStartTimes(kk) & bayesian_decodingError(track_id).track_time < lap_stop_times(kk)); %find indices per each lap
            bayesian_decodingError(track_id).medianError_perLap = [bayesian_decodingError(track_id).medianError_perLap, median(bayesian_decodingError(track_id).track_decodingErrors(indices_perLap))]; % find median decoded error per lap
            bayesian_decodingError(track_id).meanError_perLap = [bayesian_decodingError(track_id).meanError_perLap, mean(bayesian_decodingError(track_id).track_decodingErrors(indices_perLap))]; % find mean decoded error per lap
        end
        
        % Finds line with best fit for the decoding errors over time and calculates decay
        nan_indx = find(isnan(bayesian_decodingError(track_id).medianError_perLap));
        bayesian_decodingError(track_id).medianError_perLap(nan_indx)=[];
        bayesian_decodingError(track_id).decoded_LapStartTimes(nan_indx)=[];
        bayesian_decodingError(track_id).meanError_perLap(nan_indx)=[];
        
        if length(lap_start_times) >= 3 % condifence bounds need #observations >= #coefficients
       
            % MEDIAN: Best fit line calculated with General model Exp1  (f(x) = a*exp(b*x))
            bayesian_decodingError(track_id).median_f.median_f = fit(bayesian_decodingError(track_id).decoded_LapStartTimes'-min(bayesian_decodingError(track_id).decoded_LapStartTimes),bayesian_decodingError(track_id).medianError_perLap','exp1');
            bayesian_decodingError(track_id).median_f.median_exp_line = bayesian_decodingError(track_id).median_f.median_f.a*exp(bayesian_decodingError(track_id).median_f.median_f.b*(bayesian_decodingError(track_id).decoded_LapStartTimes'-min(bayesian_decodingError(track_id).decoded_LapStartTimes)));
            confidence_bounds = confint(bayesian_decodingError(track_id).median_f.median_f);
            b_confidence_bounds = [confidence_bounds(3) confidence_bounds(4)];
            bayesian_decodingError(track_id).median_f.upper_confidence_bound = confidence_bounds(1)*exp(confidence_bounds(3)*(bayesian_decodingError(track_id).decoded_LapStartTimes'-min(bayesian_decodingError(track_id).decoded_LapStartTimes)));
            bayesian_decodingError(track_id).median_f.lower_confidence_bound = confidence_bounds(2)*exp(confidence_bounds(4)*(bayesian_decodingError(track_id).decoded_LapStartTimes'-min(bayesian_decodingError(track_id).decoded_LapStartTimes)));
            
            % MEAN: Best fit line calculated with General model Exp1  (f(x) = a*exp(b*x))
            bayesian_decodingError(track_id).mean_f.mean_f = fit(bayesian_decodingError(track_id).decoded_LapStartTimes'-min(bayesian_decodingError(track_id).decoded_LapStartTimes),bayesian_decodingError(track_id).meanError_perLap','exp1');
            bayesian_decodingError(track_id).mean_f.mean_exp_line = bayesian_decodingError(track_id).mean_f.mean_f.a*exp(bayesian_decodingError(track_id).mean_f.mean_f.b*(bayesian_decodingError(track_id).decoded_LapStartTimes'-min(bayesian_decodingError(track_id).decoded_LapStartTimes)));
            confidence_bounds = confint(bayesian_decodingError(track_id).mean_f.mean_f);
            b_confidence_bounds = [confidence_bounds(3) confidence_bounds(4)];
        end
        
        if strcmp(figure_option,'Y')

        %Plot example of laps decoded at different time points : start, middle & end
        if length(bayesian_decodingError(track_id).decoded_LapStartTimes)>=3
            
            laps_per_plot = length(bayesian_decodingError(track_id).decoded_LapStartTimes)/3; % calculate how to divide the laps in three plots 
            if ~isinf(laps_per_plot) %check if is integer
                laps_per_plot = floor(laps_per_plot);
            end
            
            %(substract minimum to zero the time)
            first_laps_window = [bayesian_decodingError(track_id).decoded_LapStartTimes(1)-min(bayesian_decodingError(track_id).decoded_LapStartTimes) bayesian_decodingError(track_id).decoded_LapStartTimes(laps_per_plot)-min(bayesian_decodingError(track_id).decoded_LapStartTimes)];
            first_laps_indices= find(bayesian_decodingError(track_id).track_time > bayesian_decodingError(track_id).decoded_LapStartTimes(1) & bayesian_decodingError(track_id).track_time <= bayesian_decodingError(track_id).decoded_LapStartTimes(laps_per_plot));
            
            middle_laps_window = [bayesian_decodingError(track_id).decoded_LapStartTimes(laps_per_plot+1)-min(bayesian_decodingError(track_id).decoded_LapStartTimes) bayesian_decodingError(track_id).decoded_LapStartTimes(laps_per_plot*2)-min(bayesian_decodingError(track_id).decoded_LapStartTimes)];
            middle_laps_indices= find(bayesian_decodingError(track_id).track_time > bayesian_decodingError(track_id).decoded_LapStartTimes(laps_per_plot+1) & bayesian_decodingError(track_id).track_time <= bayesian_decodingError(track_id).decoded_LapStartTimes(laps_per_plot*2));
            
            last_laps_window = [bayesian_decodingError(track_id).decoded_LapStartTimes((laps_per_plot*2)+1)-min(bayesian_decodingError(track_id).decoded_LapStartTimes) bayesian_decodingError(track_id).decoded_LapStartTimes(end-1)-min(bayesian_decodingError(track_id).decoded_LapStartTimes)];
            last_laps_indices= find(bayesian_decodingError(track_id).track_time > bayesian_decodingError(track_id).decoded_LapStartTimes((laps_per_plot*2)+1) & bayesian_decodingError(track_id).track_time <= bayesian_decodingError(track_id).decoded_LapStartTimes(end-1));
            
            % FIGURE - DECODING ERROR OVER TIME
            figure
            plot(bayesian_decodingError(track_id).decoded_LapStartTimes-min(bayesian_decodingError(track_id).decoded_LapStartTimes),bayesian_decodingError(track_id).medianError_perLap,'Color','k','LineWidth',1)
            hold on
            if length(lap_start_times) > 3
                plot(bayesian_decodingError(track_id).decoded_LapStartTimes - min(bayesian_decodingError(track_id).decoded_LapStartTimes),bayesian_decodingError(track_id).median_f.median_exp_line,'LineWidth',1,'Color',[0.8500 0.3250 0.0980])
                plot(bayesian_decodingError(track_id).decoded_LapStartTimes - min(bayesian_decodingError(track_id).decoded_LapStartTimes),bayesian_decodingError(track_id).median_f.upper_confidence_bound,'LineWidth',0.5,'Color','r','LineStyle',':')
                plot(bayesian_decodingError(track_id).decoded_LapStartTimes - min(bayesian_decodingError(track_id).decoded_LapStartTimes),bayesian_decodingError(track_id).median_f.lower_confidence_bound,'LineWidth',0.5,'Color','r','LineStyle',':')
            end
            add_shaded_areas(gca,[first_laps_window(1) first_laps_window(2)],[min(ylim) max(ylim)],[0 0.4470 0.7410],0.1)
            add_shaded_areas(gca,[middle_laps_window(1) middle_laps_window(2)],[min(ylim) max(ylim)],[0 0.4470 0.7410],0.1)
            add_shaded_areas(gca,[last_laps_window(1) last_laps_window(2)],[min(ylim) max(ylim)],[0 0.4470 0.7410],0.1)
            
            xlabel('Time (sec)')
            ylabel('Median decoding error (cm)')
            title(strcat('Second exposure to Track ', num2str(template_track),' decoded from first exposure'))
            
           % FIGURE - DECODING ERROR ON THREE LAP SECTIONS
            figure
               subplot(1,3,1)
            zero_prob = find(track_all_max_prob(velocity_index(first_laps_indices))<0.1);
            low_prob = find(track_all_max_prob(velocity_index(first_laps_indices)) >= 0.1 & track_all_max_prob(velocity_index(first_laps_indices)) < 0.4);
            middle_prob = find(track_all_max_prob(velocity_index(first_laps_indices)) >= 0.4 & track_all_max_prob(velocity_index(first_laps_indices)) < 0.75);
            high_prob = find(track_all_max_prob(velocity_index(first_laps_indices)) > 0.75);
            
            plot(bayesian_decodingError(track_id).track_time(first_laps_indices)-min(bayesian_decodingError(track_id).track_time),bayesian_decodingError(track_id).track_actual_positions(first_laps_indices),'Color',[0.4, 0.4, 0.4],'LineWidth',3)
            hold on
            plot(bayesian_decodingError(track_id).track_time(first_laps_indices(middle_prob))-min(bayesian_decodingError(track_id).track_time(middle_prob)),bayesian_decodingError(track_id).track_decoded_positions(first_laps_indices(middle_prob)),'o','MarkerFaceColor',[0.6 0 0.6],'MarkerEdgeColor',[0.6 0 0.6],'MarkerSize',8)
            plot(bayesian_decodingError(track_id).track_time(first_laps_indices(high_prob))-min(bayesian_decodingError(track_id).track_time(high_prob)),bayesian_decodingError(track_id).track_decoded_positions(first_laps_indices(high_prob)),'o','MarkerFaceColor',[0.8, 0.0, 0.1],'MarkerEdgeColor',[0.8, 0.0, 0.1],'MarkerSize',8)
            xlabel('Time (sec)')
            ylabel('Linearized position (cm)')
            title(strcat('track',num2str(decoded_track),' first laps'))
            
               subplot(1,3,2)
            zero_prob = find(track_all_max_prob(velocity_index(middle_laps_indices))<0.1);
            low_prob = find(track_all_max_prob(velocity_index(middle_laps_indices)) >= 0.1 & track_all_max_prob(velocity_index(middle_laps_indices)) < 0.4);
            middle_prob = find(track_all_max_prob(velocity_index(middle_laps_indices)) >= 0.4 & track_all_max_prob(velocity_index(middle_laps_indices)) < 0.75);
            high_prob = find(track_all_max_prob(velocity_index(middle_laps_indices)) > 0.75);
            
            plot(bayesian_decodingError(track_id).track_time(middle_laps_indices)-min(bayesian_decodingError(track_id).track_time),bayesian_decodingError(track_id).track_actual_positions(middle_laps_indices),'Color',[0.4, 0.4, 0.4],'LineWidth',3)
            hold on
            plot(bayesian_decodingError(track_id).track_time(middle_laps_indices(middle_prob))-min(bayesian_decodingError(track_id).track_time(middle_prob)),bayesian_decodingError(track_id).track_decoded_positions(middle_laps_indices(middle_prob)),'o','MarkerFaceColor',[0.6 0 0.6],'MarkerEdgeColor',[0.6 0 0.6],'MarkerSize',8)
            plot(bayesian_decodingError(track_id).track_time(middle_laps_indices(high_prob))-min(bayesian_decodingError(track_id).track_time(high_prob)),bayesian_decodingError(track_id).track_decoded_positions(middle_laps_indices(high_prob)),'o','MarkerFaceColor',[0.8, 0.0, 0.1],'MarkerEdgeColor',[0.8, 0.0, 0.1],'MarkerSize',8)
            xlabel('Time (sec)')
            ylabel('Linearized position (cm)')
            title(strcat('track',num2str(decoded_track),' middle laps'))
            
                subplot(1,3,3)
            zero_prob = find(track_all_max_prob(velocity_index(last_laps_indices))<0.1);
            low_prob = find(track_all_max_prob(velocity_index(last_laps_indices)) >= 0.1 & track_all_max_prob(velocity_index(last_laps_indices)) < 0.4);
            middle_prob = find(track_all_max_prob(velocity_index(last_laps_indices)) >= 0.4 & track_all_max_prob(velocity_index(last_laps_indices)) < 0.75);
            high_prob = find(track_all_max_prob(velocity_index(last_laps_indices)) > 0.75);
            
            plot(bayesian_decodingError(track_id).track_time(last_laps_indices)-min(bayesian_decodingError(track_id).track_time),bayesian_decodingError(track_id).track_actual_positions(last_laps_indices),'Color',[0.4, 0.4, 0.4],'LineWidth',3)
            hold on
            plot(bayesian_decodingError(track_id).track_time(last_laps_indices(middle_prob))-min(bayesian_decodingError(track_id).track_time(middle_prob)),bayesian_decodingError(track_id).track_decoded_positions(last_laps_indices(middle_prob)),'o','MarkerFaceColor',[0.6 0 0.6],'MarkerEdgeColor',[0.6 0 0.6],'MarkerSize',8)
            plot(bayesian_decodingError(track_id).track_time(last_laps_indices(high_prob))-min(bayesian_decodingError(track_id).track_time(high_prob)),bayesian_decodingError(track_id).track_decoded_positions(last_laps_indices(high_prob)),'o','MarkerFaceColor',[0.8, 0.0, 0.1],'MarkerEdgeColor',[0.8, 0.0, 0.1],'MarkerSize',8)
            title(strcat('track',num2str(decoded_track),' last laps'))
            xlabel('Time (sec)')
            ylabel('Linearized position (cm)')
            legend('real position','decoded position > 0.4 & <0.75','decoded position >0.75')
            
        end
    end
    end 
    