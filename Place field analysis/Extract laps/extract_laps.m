
function lap_times = extract_laps(plot_option)
% MH
% Plot option: 'Y'/'N'

load extracted_position
parameters=list_of_parameters;

for track_id = 1 : length(position.linear)
    
    x_original = rescale(position.linear(track_id).linear(~isnan(position.linear(track_id).linear)));
    x = medfilt1(x_original,10);  % smooth position data
    y = x-0.5; %rescales y axis of linearized position to a smaller size
    
    t = position.linear(track_id).timestamps;
    %no_lap_indices = find((y>0.1 & y<0.4) | isnan(y)); %find indices of NaNs (points outside track) and of value above and below 0.4 (ends of tracks)
    no_lap_indices = find((y>-0.3 & y<0.4));
    y(no_lap_indices) = []; %removes indices
    t(no_lap_indices) = [];
    
    state = sign(y(1)); %returns 1 if y(1) is larger than 0
    past_state = state;
    
    j = 1;
    lap_times(track_id).end_zone(j).x = []; % alocate variables
    lap_times(track_id).end_zone(j).t = [];
    
    time_jump = diff(t); %find time steps
    state_change = diff(sign(y)); %finds half ways of the laps (crossing 0 in Y axis - as one end of track is + and the other end is -)
    
    % Saves x and t positions for each lap (a half lap = 1 direction)
    for i = 1:(length(y)-1)
        if (state_change(i)~=0) || time_jump(i)>30 %if state switch or time jump
            j=j+1;
            lap_times(track_id).end_zone(j).x = [];
            lap_times(track_id).end_zone(j).t = [];
        end
        lap_times(track_id).end_zone(j).x(end+1) = y(i); 
        lap_times(track_id).end_zone(j).t(end+1) = t(i);
    end
  
    % Saves in which direction is the first lap (1 for facing PC or -1 for facing wall)
    if lap_times(track_id).end_zone(1).x > 0
        lap_times(track_id).initial_dir =  1;
    else
        lap_times(track_id).initial_dir = -1;
    end
       
    % Find the start point of each lap (direction), by finding median of time
    for j=1:length(lap_times(track_id).end_zone)
        lap_times(track_id).halfLaps_start(j) = median(lap_times(track_id).end_zone(j).t);
    end
       
    % START AND END TIMEPOINTS PER LAP
    lap_times(track_id).halfLaps_stop = lap_times(track_id).halfLaps_start(2:end); % lap end time
    lap_times(track_id).halfLaps_start(end) = []; % lap start time
    lap_times(track_id).duration  = lap_times(track_id).halfLaps_stop-lap_times(track_id).halfLaps_start; % lap durations
    
    % Finds length of X points for each lap within the track (not including ends of tracks)
    running_along_track = [];  
    for i=1:length(lap_times(track_id).duration)
        timestamps_within_lap_indices = find(position.linear(track_id).timestamps >= lap_times(track_id).halfLaps_start(i) & position.linear(track_id).timestamps < lap_times(track_id).halfLaps_stop(i)); % find indices of time within a lap
        running_along_track(i) = length(find(x(timestamps_within_lap_indices)>0.2 & x(timestamps_within_lap_indices)<0.8)); %find x indices for these time points excluding ends of track (>0.2 & >0.8)
    end
    
    %combine noisy laps that are less than 2 second or spends less than 1 second running
    noisy_laps_indices = find(lap_times(track_id).duration<1 | running_along_track<25);   
    lap_times(track_id).clip = [];
    
    for i = 1:length(noisy_laps_indices)
        if i>1 && i < length(lap_times(track_id).duration)  %if not first or last lap, combine with nearby lap
            if abs(lap_times(track_id).halfLaps_start(noisy_laps_indices(i))-lap_times(track_id).halfLaps_stop(noisy_laps_indices(i)-1))<600
                lap_times(track_id).halfLaps_stop(noisy_laps_indices(i)-1) = lap_times(track_id).halfLaps_stop(noisy_laps_indices(i));
            else
                lap_times(track_id).halfLaps_start(noisy_laps_indices(i)+1) = lap_times(track_id).halfLaps_start(noisy_laps_indices(i));
            end
        elseif noisy_laps_indices(i)==1 %if first lap
            lap_times(track_id).halfLaps_start(noisy_laps_indices(i)+1) = lap_times(track_id).halfLaps_start(noisy_laps_indices(i));
        elseif i == length(lap_times(track_id).duration) %if short duration
            lap_times(track_id).halfLaps_stop(noisy_laps_indices(i)-1) = lap_times(track_id).halfLaps_stop(noisy_laps_indices(i));
        end
        
        lap_times(track_id).clip(end+1) = (noisy_laps_indices(i)); %save noisy lap indices
        
    end
    lap_times(track_id).halfLaps_start(lap_times(track_id).clip)=[];
    lap_times(track_id).halfLaps_stop(lap_times(track_id).clip)=[];
    lap_times(track_id).duration(lap_times(track_id).clip)=[];
    
    %remove noise
    total_number_of_laps = length(lap_times(track_id).halfLaps_start);
    
    for i= 1 : total_number_of_laps
        
        lap_time_indices = find(position.linear(track_id).timestamps >= lap_times(track_id).halfLaps_start(i) & position.linear(track_id).timestamps<lap_times(track_id).halfLaps_stop(i)); %finds time indices per lap
        not_nan = length(find(~isnan(x(lap_time_indices)))); %find if these indices are NOT NaNs in the x position
        is_nan  = length(find(isnan(x(lap_time_indices)))); %find if these indices ARE NaNs in the x position
    
    %if there's lots of NaNs between lap start and lap end time, it means there's a large jump (e.g. jump from 1st to 2nd exposure) - fill with NaNs
    %if there's less than 25 points (not NaN) - short lap - fill with NaNs
        if  is_nan>250 | not_nan<25 
            lap_times(track_id).halfLaps_start(i) = NaN;
            lap_times(track_id).halfLaps_stop(i)  = NaN;
        end       
    end
    
    %clean NaNs
    lap_times(track_id).halfLaps_start(find(isnan(lap_times(track_id).halfLaps_start))) = [];
    lap_times(track_id).halfLaps_stop(find(isnan(lap_times(track_id).halfLaps_stop))) = [];
    
    lap_times(track_id).completeLaps_start =  lap_times(track_id).halfLaps_start(1:2:end);
    lap_times(track_id).completeLaps_stop = lap_times(track_id).halfLaps_stop(2:2:end);
    if lap_times(track_id).completeLaps_stop(end) ==  lap_times(track_id).halfLaps_stop(end-1)
        lap_times(track_id).completeLaps_stop = [lap_times(track_id).completeLaps_stop lap_times(track_id).halfLaps_stop(end)];
    end
    
    % Re-calculate number of laps
    lap_times(track_id).number_halfLaps = length(lap_times(track_id).halfLaps_start);
    lap_times(track_id).number_completeLaps = length(lap_times(track_id).completeLaps_start);

    % Set lap IDs for both half and complete laps
     lap_times(track_id).completeLap_id = 1:lap_times(track_id).number_completeLaps;
     lap_times(track_id).halfLap_id = 1:lap_times(track_id).number_halfLaps;

    
 %%%%%%%%%%%% PLOTTING %%%%%%%%%%

 if plot_option
     if length(position.linear) == 4
         if rem(track_id,2) ~= 0 % Plot Track 1 and track 3 together (1st and 2nd exposure)
             figure(1)
             if track_id == 1
                 subplot(1,2,1);
                 title(strcat('Track ',num2str(track_id)))
                 hold on;
             else
                 subplot(1,2,2);
                 title(strcat('Track ',num2str(track_id)))
                 hold on;
             end
         else
             figure(2) % Plot Track 2 and track 4 together (1st and 2nd exposure)
             if track_id == 2
                 subplot(1,2,1);
                 title(strcat('Track ',num2str(track_id)))
                 hold on;
             else
                 subplot(1,2,2);
                 title(strcat('Track ',num2str(track_id)))
                 hold on;
             end
         end
     else
         figure(1) % if all are diferent tracks, plot them together
         subplot(1,length(position.linear),track_id)
         hold on;
     end
     
     for i=1:lap_times(track_id).number_halfLaps
         index=find(position.t>=lap_times(track_id).halfLaps_start(i) & position.t<lap_times(track_id).halfLaps_stop(i));
         if ~isempty(index)
                 time = position.t(index)-min(position.t(index));
                 laps = i + 0.05 + 0.9 * x(index);
                 plot(time,laps,'Color',parameters.plot_color_line{track_id}); 
         end
     end
     
     xlabel('linearized lap')
     ylabel('lap number')
     set(gca,'YTick',min(ylim):1:max(ylim))
   
 end 
 
end

save extracted_laps lap_times

end

function y=rescale(x)

y = (x-min(x))/(max(x)-min(x));

end
