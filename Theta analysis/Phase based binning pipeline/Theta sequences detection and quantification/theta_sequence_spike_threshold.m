% FIND NUMBER OF UNITS PARTICIPATING IN EACH THETA WINDOW
% Output: indices of theta windows with = or less than 2 units active. This
% is to apply a threshold to cycles that might be too noisy

function [thetacycles_spike_count] = theta_sequence_spike_threshold(theta_spike_count)

load extracted_directional_place_fields.mat
cd([pwd '\Theta'])
if isempty(theta_spike_count)
    load theta_seq_bayesian_spike_count.mat
end
load theta_time_window.mat
load theta_peak_trough.mat
cd ..
thetacycles_spike_count = [];

theta_spike_count.theta_windows_indices = nan(1,length(theta_spike_count.replay_events_indices)); %preallocate

for dir = 1 :  length(directional_place_fields)
    place_fields = directional_place_fields(dir).place_fields;
    thetacyles = struct;
    %theta_spike_count.theta_windows_indices(dir,:) = nan(1,length(theta_spike_count.replay_events_indices)); %preallocate

    for t = 1 : length(place_fields.track)
        % Take n matrix and remove cells that are not part of the track
        n.replay = theta_spike_count.n.replay;
        all_cells = unique([directional_place_fields(1).place_fields.good_place_cells directional_place_fields(2).place_fields.good_place_cells]);
        [~,idd] = setdiff(all_cells,place_fields.track(t).good_cells);
        n.replay(idd,:) = [];
        c = 1;
        track_indices = find(theta_spike_count.replay_events_indices == t);
        
        for s = 1 : length(theta_windows.track(t).theta_window)
            if theta_windows.track(t).theta_window(s,3) ~= 0
                
                % Find trough indx of the current window and it's surrounding peaks (this would be the central theta cycle
                % in the theta window)
                trough_idx = find(theta_troughs(:,4) == theta_windows.track(t).theta_window_trough_center(s,1));
                upper = theta_peaks(theta_peaks(:,4) > theta_troughs(trough_idx,4),4); 
                lower = theta_peaks(theta_peaks(:,4) < theta_troughs(trough_idx,4),4); 
                surround_peaks = [lower(end) upper(1)];
                
                % Find timebins within theta cycle and save spike count of theta cycle
                idcs = find(theta_spike_count.replay_events(t).replay_time_centered >= surround_peaks(1)  &...
                    theta_spike_count.replay_events(t).replay_time_centered  <= surround_peaks(2));
                thetacyles(t).spike_count(c).peaks = surround_peaks;
                thetacyles(t).spike_count(c).trough = theta_windows.track(t).theta_window_trough_center(s,1);
                thetacyles(t).spike_count(c).theta_windows_idx = s;
                thetacyles(t).spike_count(c).event_spike_count = n.replay(:,idcs);
                num_active_units = length(find(sum(thetacyles(t).spike_count(c).event_spike_count,2) >= 1));
                % If there's equal or less than 2 units active, save index
                if num_active_units <= 2
                    thetacyles(t).spike_count(c).low_units_participation_indx = s;
                end
                
%                 % save indices of each theta window in n.replay
%                 idcs_edges = track_indices(theta_spike_count.replay_events(t).replay_time_edges >= surround_peaks(1)  &...
%                     theta_spike_count.replay_events(t).replay_time_edges  <= surround_peaks(2));
%                 theta_spike_count.theta_windows_indices(dir,idcs_edges) = ones(1,length(idcs_edges))*s;

                
                c = c+1;
            end
        end
    end
    
    thetacycles_spike_count.(strcat('direction',num2str(dir))) = thetacyles;
    
end


end