% SPIKE PHASE HISTOGRAM
% MH, 2020
% Method to find center of theta sequences by finding the theta phase with max firing rate. For each theta sequence, find active spikes and their
% phases, and find at which phase there are more spikes. Then plots histogram of all phases per track and direction, and gives the peak phase
% of the histogram and the median phase 
% INPUT - 
    % decoded_thetaSeq: if empty, loads the file from the current folder
    % thresholded_decoded_thetaSeq_option: 1 if using theta sequences that have passed the position threshold (not happening neither at the
    % start or end of track). Otherwise empty

function [preferred_median_theta_phase,preferred_theta_phase] = extract_spike_phase_histogram(decoded_thetaSeq,thresholded_decoded_thetaSeq_option)

cd([pwd '\Theta'])
if thresholded_decoded_thetaSeq_option == 1
    load thresholded_decoded_thetaSeq.mat
    load theta_sequence_quantification_thresholded.mat
elseif isempty(decoded_thetaSeq)
    load decoded_theta_sequences.mat
    load theta_sequence_quantification.mat
end
load theta_peak_trough.mat
cd ..
load extracted_CSC.mat
load extracted_clusters.mat

phase_bin_width = 5;
theta_phases_bins = 0:phase_bin_width:360;

theta_CSC_time = CSC(4).CSCtime;
% Get theta phase
hilb = hilbert(CSC(4).theta);
theta_phase = angle(hilb);
theta_phase_unwrap = unwrap(theta_phase); % unwrap for interpolation

% Get active units in each track and direction (but not merged directions)
fields = fieldnames(centered_averaged_thetaSeq);
fields = fields(~contains(fields,'uni')); %remove unidirectional field
for d = 1 : length(fields)
    thetaseq = centered_averaged_thetaSeq.(strcat(fields{d}));
    
    for t = 1 : length(thetaseq) % for each track
        track_active_units_ID =  decoded_thetaSeq.(strcat(fields{d}))(t).track_active_units_ID; % units active in this track and direction
        
        units_idx = ismember(clusters.spike_id',track_active_units_ID); %find indices of units active in track
        track_units_id = clusters.spike_id(units_idx);
        [track_units_spikes,sort_idx] = sort(clusters.spike_times(units_idx)); %find spike times of units active in track
        track_units_id = track_units_id(sort_idx); %sort by time
        
        % Interpolate phases for each spike time
        spike_phases = interp1(theta_CSC_time,theta_phase_unwrap,track_units_spikes,'linear');
        phases_deg = rad2deg(mod(spike_phases,2*pi));       
        
        
        this_track_thetaSeq = theta_seq_indices.(strcat(fields{d}))(t).index_fom_theta_windows; %indices of the theta windows that have passed all the thresholds

%         f(t) = figure;
%         theta_phase_deg= rad2deg(mod(theta_phase_unwrap,2*pi));
%         plot(theta_CSC_time,theta_phase_deg,'Color','k','LineWidth',3)
%         hold on
%         plot(track_units_spikes,phases_deg,'o','MarkerFaceColor','m','MarkerEdgeColor','m')
        
        all_windows_spikes = [];
        all_units_spike_id = [];
        all_phases = [];

        for tw = 1 : length(this_track_thetaSeq)
              
            idx = find([thetaseq(t).thetaseq(:).theta_window_index] == this_track_thetaSeq(tw));     

            % Find edges of central theta cycle (peak to peak)
            %peaks_times = spike_count(t).spike_count(idx).peaks;
            trough_idx = find(theta_troughs(:,4) == thetaseq(t).thetaseq(idx).theta_cycle_centre_trough_times);
            upper = theta_peaks(theta_peaks(:,4) > theta_troughs(trough_idx,4),4);
            lower = theta_peaks(theta_peaks(:,4) < theta_troughs(trough_idx,4),4);
            peaks_times = [lower(end), upper(1)];
            
            % Find spike times of the active units during the theta cycle
            spikes_phases_between_peaks = phases_deg(track_units_spikes >= peaks_times(1) & track_units_spikes <= peaks_times(2)); %spike phases between peaks
            ids_between_peaks = track_units_id(track_units_spikes >= peaks_times(1) & track_units_spikes <= peaks_times(2));  %spike IDs between peaks
            spikes_between_peaks = track_units_spikes(track_units_spikes >= peaks_times(1) & track_units_spikes <= peaks_times(2)); %spike times between peaks
            
%             figure(f(t))
%             hold on
%             plot(peaks_times,[360 360],'o','MarkerFaceColor','y','MarkerEdgeColor','y')
%             plot([spike_count(t).spike_count(idx).trough spike_count(t).spike_count(idx).trough],[min(ylim) max(ylim)],'Color','y','LineWidth',2)
%             plot(spikes_between_peaks,spikes_phases_between_peaks,'o','MarkerFaceColor','b','MarkerEdgeColor','b')
            
            % Find spikes emitted during 45-315 degrees
            phase_idx = find(spikes_phases_between_peaks >= 45 & spikes_phases_between_peaks <= 315);
            spikes_between_phases = spikes_between_peaks(phase_idx);
            ids_between_phases = ids_between_peaks(phase_idx);
            spikes_phases_between_phases = spikes_phases_between_peaks(phase_idx);
            
            all_phases = [all_phases; spikes_phases_between_phases];
            all_units_spike_id = [all_units_spike_id; ids_between_phases];
            all_windows_spikes = [all_windows_spikes; spikes_between_phases];

        end
        
       % Find which phase has a higher number of spikes across all theta cycles
        theta_phase_hist = histcounts(all_phases,theta_phases_bins);
        [~,max_idx] = max(theta_phase_hist);
        preferred_theta_phase(d,t) = theta_phases_bins(max_idx);
        preferred_median_theta_phase(d,t) = median(all_phases);

       figure; histogram(all_phases)
    end
end

cd([pwd '\Theta'])
if thresholded_decoded_thetaSeq_option == 1
    save preferred_theta_phase_tresholded preferred_theta_phase preferred_median_theta_phase
else
    save preferred_theta_phase preferred_theta_phase preferred_median_theta_phase
end
cd ..

end

