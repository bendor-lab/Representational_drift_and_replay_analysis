%% Get the "place field" of interneurons

clear
sessions = data_folders_excl;

%% Define important storage vectors


% sID = 12;
% trackOI = 4;
% lapOI = 1;
% incr = 3;

%% Loading relevant files

for sID = 15:15%1:19
    
    disp(sID);
    file = sessions{sID};
    
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    animalOI = string(animalOI);
    %conditionOI = string(conditionOI); % We convert everything to string
    
    temp = load(file + "\extracted_place_fields");
    place_fields = temp.place_fields;
    
    temp = load(file + "\extracted_laps");
    lap_times = temp.lap_times;
    
    temp = load(file + "\extracted_clusters");
    clusters = temp.clusters;
    
    temp = load(file + "\extracted_position");
    position = temp.position;
    
    %% Identify the inhibitory interneurons
    % Based on firing rate for the entire session : > 28 Hz
    
    inter = place_fields.interneurons;
    
    %% Find the variance of firing rate for each lap
    
    for trackOI = 4:4 %1:4
        
        number_laps = numel(lap_times(trackOI).completeLaps_start);
        
        if number_laps > 16
            number_laps = 16;
        end
        
        lapOI = 1;
        
        % Find the start and end of the lap
        start_lap = lap_times(trackOI).completeLaps_start(1);
        end_lap = lap_times(trackOI).completeLaps_stop(end);
        
        current_pos = position.linear(trackOI).linear(position.t >= start_lap & ...
            position.t <= end_lap);
        
        current_speed = position.v_cm(position.t >= start_lap & ...
            position.t <= end_lap);
        
        current_t_pos = position.t(position.t >= start_lap & ...
            position.t <= end_lap);
        
        current_t_pos = current_t_pos - current_t_pos(1);
        
        sampling_rate = mode(diff(current_t_pos));
        
        isDuringLap = (clusters.spike_times >= start_lap) & ...
            (clusters.spike_times <= end_lap);
        
        spikes_lap = clusters.spike_id(isDuringLap);
        times_lap = clusters.spike_times(isDuringLap);
        times_lap = times_lap - times_lap(1); % We start from 0
        
        interp_speed = interp1(current_t_pos, current_speed, times_lap);
        interp_position = interp1(current_t_pos, current_pos, times_lap);
        
        for cID = 1:numel(inter)
            cellOI = inter(cID);
            isSpiking = (spikes_lap == cellOI); % All spikes from interneuron
            
            % Find all the positions when the neuron fired
            interp_position_clean = interp_position; % Clean the position to include running only
            interp_position_clean(interp_speed <= 5) = NaN;
            all_pos_fire = interp_position_clean(isSpiking);            
            
            % Now we create an histogram
            spikes_per_spot = histcounts(all_pos_fire, 0:200);
            occupancy = histcounts(current_pos, 0:200);
            
            % If the occupancy is 0, occupancy is 1 to avoid NaNs
            occupancy(occupancy == 0) = 1;
            
            % Divide the nb of spikes per the occupancy to get a firing
            % rate
            place_field = spikes_per_spot./occupancy;
            place_field = place_field./sampling_rate; % convert to Hz
            
            % We smooth the place field
            place_field_smooth = smoothdata(place_field,"gaussian", 10);
            
            % We repeat to get a speed field
            interp_speed_clean = interp_speed;
            %interp_speed_clean(interp_speed_clean <= 5) = NaN;
            all_speed_fire = interp_speed_clean(isSpiking);
            spikes_per_speed = histcounts(all_speed_fire, 0:30);
            speed_occupancy = histcounts(current_speed, 0:30);
            speed_occupancy(speed_occupancy == 0) = 1;
            speed_field = spikes_per_speed./speed_occupancy;
            speed_field = speed_field./sampling_rate; % convert to Hz
            % speed_field_smooth = smoothdata(speed_field,"gaussian", 2);
            
            binned_time = floor(times_lap); % We bin every second
            mean_values = accumarray(binned_time+1, isSpiking', [], @sum);
            
            figure;
            ax(1) = subplot(1, 2, 1);
            bar(1:200, place_field_smooth);
            grid on;
            xlabel("Position (cm)");
            ylabel("Smoothed firing rate (Hz)")
            title("Place field - c" + cellOI + " - sess. " + sID);
            %ylim([0 0.5])
            
            ax(2) = subplot(1, 2, 2);
            bar(1:30, speed_field);
            grid on;
            xlabel("Speed (cm/s)");
            ylabel("Smoothed firing rate (Hz)")
            title("Speed field -" + cellOI + " - " + sID);
            %ylim([0, 0.25]);
            
            
%             linkaxes(ax, "x");
            
        end
    end
end