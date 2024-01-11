% EXTRACT THETA WINDOW AND APPLY THRESHOLDS
% MH 2020
% First extracts theta windows based on theta phases (peak to peak). Then applies thresholds of speed, duration of cycle
% and number of active units per cycle to discard noisy cycles. Finally splits theta windows based on running direction

function theta_windows = extract_theta_window(theta_spike_count,save_option)

if isempty(theta_spike_count)
    load Theta\theta_seq_bayesian_spike_count.mat
end
load extracted_position.mat
load extracted_laps.mat
load extracted_directional_place_fields.mat
parameters = list_of_parameters;
number_cycle_bins  = parameters.number_cycle_bins;
min_active_units = parameters.min_active_units;


% Create theta windows, peak to peak (based on  Farooq et al 2019, Muessig et al 2019)
% For each track, first time bin edge is a peak. Peak to peak segments consist of 9 edges (8 bin centers)
for t = 1 : length(position.linear)
   theta_windows.track(t).theta_time_windows_edges = theta_spike_count.replay_events(t).replay_time_edges(bsxfun(@plus,(1:number_cycle_bins+1),(0:number_cycle_bins:length(theta_spike_count.replay_events(t).replay_time_edges)-number_cycle_bins-1)'));
   theta_windows.track(t).theta_windows = [theta_windows.track(t).theta_time_windows_edges(:,1) theta_windows.track(t).theta_time_windows_edges(:,number_cycle_bins+1)];    
 end

% Apply speed threshold: find periods where velocity is > 5cm
for t = 1 : length(position.linear)
    interp_speed = interp1(position.t,position.v_cm,theta_windows.track(t).theta_windows(:,1)); %interpolate velocity at time bin edges
    below_running_speed = find(interp_speed < parameters.speed_threshold_laps);
    theta_windows.track(t).theta_windows(below_running_speed,:)=[];
    theta_windows.track(t).theta_time_windows_edges(below_running_speed,:)=[];
end
clear position

% Following Drieu et al 2018 - Discard theta cycle if it's shorter than 80ms or longer than 200ms
for t = 1 : length(theta_windows.track)
    durations = theta_windows.track(t).theta_windows(:,2)-theta_windows.track(t).theta_windows(:,1);
    indx = find(durations > parameters.max_theta_window_width & durations < parameters.min_theta_window_width);
    theta_windows.track(t).theta_windows(indx,:)=[];
    theta_windows.track(t).theta_time_windows_edges(indx,:)=[];
end

% Number of units active treshold: discard =>2 active units in theta cycle
for dir = 1 :  length(directional_place_fields)
    for t = 1 : length(theta_windows.track)
        % Take n matrix and remove cells that are not part of the track
        n.replay = theta_spike_count.n.replay;
        all_cells = unique([directional_place_fields(1).place_fields.good_place_cells directional_place_fields(2).place_fields.good_place_cells]);
        [~,idd] = setdiff(all_cells,directional_place_fields(dir).place_fields.track(t).good_cells);
        n.replay(idd,:) = [];
        c = 1;
        track_indices = find(theta_spike_count.replay_events_indices == t);
        low_units_participation_indx = [];
        c = 1;
        for s = 1 : length(theta_windows.track(t).theta_windows)
            spike_count_idx = find(theta_spike_count.replay_events(t).replay_time_centered > theta_windows.track(t).theta_windows(s,1) & ...
                theta_spike_count.replay_events(t).replay_time_centered < theta_windows.track(t).theta_windows(s,2));
            num_active_units = length(find(sum(n.replay(:,spike_count_idx),2) >= 1));
            idx_active_units = find(sum(n.replay(:,spike_count_idx),2) >= 1);
            % If there's equal or less than 3 units active, save index
            if num_active_units <= min_active_units
                low_units_participation_indx = [low_units_participation_indx, s];
            else % save
                theta_windows.track(t).event_spike_count{c} = n.replay(:,spike_count_idx);
                theta_windows.track(t).thetaseq_num_active_units(c) = num_active_units;
                theta_windows.track(t).thetaseq_idx_active_units{c} = idx_active_units;
                c = c+1;
            end
        end
        % Delete indices of cycles with less than 2 units
        theta_windows.track(t).theta_windows(low_units_participation_indx,:) = [];
        theta_windows.track(t).theta_time_windows_edges(low_units_participation_indx,:)=[];
    end
end
clear theta_spike_count directional_place_fields
               
for t = 1 : length(theta_windows.track)
   theta_windows.track(t).theta_peaks_timestamps = [theta_windows.track(t).theta_windows(:,1); theta_windows.track(t).theta_windows(end,1)];
   theta_windows.track(t).theta_troughs_timestamps = theta_windows.track(t).theta_time_windows_edges(:,floor((number_cycle_bins/2)+1));
end

% Classify half laps in directions: save start and end timestamps in two columns
for t = 1 : length(lap_times)
        track_halfLaps_times(t).direction_1(:,1) = lap_times(t).halfLaps_start(1:2:end);
        track_halfLaps_times(t).direction_1(:,2) = lap_times(t).halfLaps_stop(1:2:end);
        track_halfLaps_times(t).direction_2(:,1) = lap_times(t).halfLaps_start(2:2:end);
        track_halfLaps_times(t).direction_2(:,2) = lap_times(t).halfLaps_stop(2:2:end);
end
clear lap_times

% Classify each theta trough window in direction 1 or direction 2
for track = 1 : length(theta_windows.track)
    % alocate variables
    theta_windows.track(track).theta_windows(:,3:4) = zeros(length(theta_windows.track(track).theta_windows),2); % alocate variables
    theta_windows.track(track).theta_troughs_timestamps(:,2) = zeros(length(theta_windows.track(track).theta_troughs_timestamps),1);
    % Check cycles within direction 1
    for i = 1 : size(track_halfLaps_times(track).direction_1,1)
        dir_idx = find(theta_windows.track(track).theta_windows(:,1) > track_halfLaps_times(track).direction_1(i,1) & ...
            theta_windows.track(track).theta_windows(:,1) <= track_halfLaps_times(track).direction_1(i,2));
        if any(theta_windows.track(track).theta_windows(dir_idx,3)) == 0
            theta_windows.track(track).theta_windows(dir_idx,3) = 1; %save as 1 if cycles occur in direction 1
            theta_windows.track(track).theta_troughs_timestamps(dir_idx,2) = 1;
        else
            ambiguous_cycles = find(any(theta_windows.track(track).theta_windows(dir_idx,3)) == 1); %if a cycle is found to be in both directions
            theta_windows.track(track).theta_windows(dir_idx,3) = 1;
            theta_windows.track(track).theta_windows(ambiguous_cycles,4) = 1;
        end
    end
    % Check cycles within direction 2
    for i = 1 : size(track_halfLaps_times(track).direction_2,1)
        dir_idx = find(theta_windows.track(track).theta_windows(:,1) > track_halfLaps_times(track).direction_2(i,1) & ...
            theta_windows.track(track).theta_windows(:,1) <= track_halfLaps_times(track).direction_2(i,2));
        if any(theta_windows.track(track).theta_windows(dir_idx,3)) == 0
            theta_windows.track(track).theta_windows(dir_idx,3) = 2; %save as 2 if cycles occur in direction 2
            theta_windows.track(track).theta_troughs_timestamps(dir_idx,2) = 2;
        else
            ambiguous_cycles = find(any(theta_windows.track(track).theta_window(dir_idx,3)) == 1); %if a cycle is found to be in both directions
            theta_windows.track(track).theta_windows(dir_idx,3) = 2;
            theta_windows.track(track).theta_windows(ambiguous_cycles,4) = 1;
        end
    end
        
end

if strcmp(save_option,'Y')
    save Theta\theta_time_window theta_windows
end

% %%% Safety check figure
%  load('extracted_CSC.mat'); load('Theta\theta_peak_trough.mat'); 
% figure
% plot(CSC(4).CSCtime,CSC(4).theta,'k','LineWidth',2)
% hold on; plot( theta_peaks(:,4),ones(1,length( theta_peaks(:,4))),'d','MarkerFaceColor','m','MarkerEdgeColor','m','MarkerSize',8)
% plot(theta_troughs(:,4),ones(1,length(theta_troughs(:,4))),'d','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize',8)
% plot( theta_spike_count.replay_events(t).replay_time_centered,ones(1,length( theta_spike_count.replay_events(t).replay_time_centered)),'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',6)
% plot( theta_spike_count.replay_events(t).replay_time_edges,ones(1,length( theta_spike_count.replay_events(t).replay_time_edges)),'o','MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',6)
% ylabel('Phase','FontSize',16); xlabel('Time','FontSize',16)
% legend({'Theta','CSC theta peaks','CSC theta troughs','Time bin centres','Time bin edges'},'FontSize',15);
end
