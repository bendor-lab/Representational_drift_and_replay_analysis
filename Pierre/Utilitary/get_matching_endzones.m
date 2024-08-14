% Function to get, for each half_lap, the period in the endzone
% after the lap

function [matching_end] = get_matching_endzones(lap_times, vTrack)

% We filter the end_zone
end_zone = lap_times(vTrack).end_zone;

for l = 1:numel(end_zone)
    is_good_side = sign(end_zone(l).x) == mode(sign(end_zone(l).x));
    end_zone(l).x = end_zone(l).x(is_good_side);
    end_zone(l).t = end_zone(l).t(is_good_side);
end

% We get every start and end of endzones
all_end_start = cellfun(@(x) x(1), {end_zone.t});
all_end_stop = cellfun(@(x) x(end), {end_zone.t});

final_start = [];
final_end = [];

% Now for each half-lap
for h_l = 1:numel(lap_times(vTrack).halfLaps_start)
    
    % get the start and end
    x = [lap_times(vTrack).halfLaps_start(h_l), lap_times(vTrack).halfLaps_stop(h_l)];
    
    % We find the end_zone which has a start during the lap 
    valid_end = find(all_end_start >= x(1) & all_end_start <= x(2));
    
    valid_end = valid_end(end); % If multiple end zones, take the latest 
    
    final_start(end + 1) = all_end_start(valid_end);
    final_end(end + 1) = all_end_stop(valid_end);
end

matching_end.startIdle = final_start';
matching_end.stopIdle = final_end';

% FUNCTION TO DEBUG VISUALLY

% for h_l = 1:numel(lap_times(vTrack).halfLaps_start)
%     % get the start and end
%     x = [lap_times(vTrack).halfLaps_start(h_l), lap_times(vTrack).halfLaps_stop(h_l)];
%     
%     % We find the end_zone which has a start during the lap 
%     valid_end = find(all_end_start >= x(1) & all_end_start <= x(2));
%     
%     % Find the matching time in the position
%     valid_times = position.t <= x(2) & position.t >= x(1);
%     speed_time = position.t(valid_times);
%     lap_speed = position.v_cm(valid_times);
%     
%     plot(x, [h_l h_l], "LineWidth", 2);
%     hold on;
%     plot([all_end_start(valid_end) all_end_start(valid_end)], ...
%          [h_l - 0.2, h_l + 0.2], "r");
%     plot([all_end_stop(valid_end) all_end_stop(valid_end)], ...
%          [h_l - 0.2, h_l + 0.2], "r");
%      
%     plot(speed_time, (lap_speed > 5)/2 + h_l);
%     plot(speed_time, position.x(valid_times)/300);
% end

end