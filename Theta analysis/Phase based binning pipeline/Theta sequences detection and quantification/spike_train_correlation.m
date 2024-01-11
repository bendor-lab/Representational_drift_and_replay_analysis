% THETA SEQUENCES QUANTIFICATION: SPIKE TRAIN CORRELATION
% MH, 2020
% From Feng et al (2015,J Neuro). For each theta sequence, calculate Pearson's linear correlation coefficient between spike timing and place cell peak
% firing positions for spikes emitted during 45-315 degrees of individual theta cycle (referenced to global zero) and for cells whose peak firing
% positions were within 50cm behind or in fron of the animal's current position.

function centered_averaged_thetaSeq = spike_train_correlation(decoded_thetaSeq,thresholded_decoded_thetaSeq_option)

cd([pwd '\Theta'])
if thresholded_decoded_thetaSeq_option == 1
    load thresholded_decoded_thetaSeq.mat
    load theta_sequence_quantification_thresholded.mat
elseif isempty(decoded_thetaSeq)
    load decoded_theta_sequences.mat
    load theta_sequence_quantification.mat
end
%load theta_seq_bayesian_spike_count.mat
load theta_peak_trough.mat

cd ..
load extracted_CSC.mat
load extracted_clusters.mat
load extracted_position.mat
load extracted_directional_place_fields.mat


phase_bin_width = 5;
theta_phases_bins = 0:phase_bin_width:360;

theta_CSC_time = CSC(4).CSCtime;
% Get theta phase
hilb = hilbert(CSC(4).theta);
theta_phase = angle(hilb);
theta_phase_unwrap = unwrap(theta_phase); % unwrap for interpolation

% Get active units in each track and direction
fields = fieldnames(centered_averaged_thetaSeq);
for d = 1 : length(fields) %2 directions + unidirection
    thetaseq = decoded_thetaSeq.(strcat(fields{d}));
    %    spike_count = thetacycles_spike_count.(strcat('direction',num2str(d)));
    place_fields = directional_place_fields(d).place_fields;
    c = 1;
    
    f(3*d) =  figure;
    for t = 1 : length(thetaseq) % for each track
        track_active_units_ID =  thetaseq(t).track_active_units_ID; % units active in this track and direction
        
        units_idx = ismember(clusters.spike_id',track_active_units_ID); %find indices of units active in track
        track_units_id = clusters.spike_id(units_idx);
        [track_units_spikes,sort_idx] = sort(clusters.spike_times(units_idx)); %find spike times of units active in track
        track_units_id = track_units_id(sort_idx); %sort by time
        
        % Interpolate phases for each spike time
        spike_phases = interp1(theta_CSC_time,theta_phase_unwrap,track_units_spikes,'linear');
        phases_deg=rad2deg(mod(spike_phases,2*pi));
        
        this_track_thetaSeq = theta_seq_indices(d).track(t).index_fom_theta_windows;
        
        %         for tw = 1 : length(thetaseq(t).theta_sequences) % for each theta window in the track
        %             % Find event spike count for this window, and from there find units that are
        %             % active during the central theta cycle
        %             theta_window_idx = thetaseq(t).theta_sequences(tw).index_from_theta_windows; %index in theta window structure
        %             idx = find([spike_count(t).spike_count(:).theta_windows_idx] == theta_window_idx); %find corresponding indx in spike count structure
        %             event_active_units = sum(spike_count(t).spike_count(idx).event_spike_count,2) ~= 0; %find which units have spikes during the theta cycle
        %             active_units_ID = track_active_units_ID(event_active_units); % find corresponding place cell ID
        count = 1;
        for tw = 1 : length(this_track_thetaSeq)
            
            idx = find([thetaseq(t).theta_sequences(:).index_from_theta_windows] == this_track_thetaSeq(tw));
            
            % Get theta cycle window edges, from peak to peak
            %peaks_times = spike_count(t).spike_count(idx).peaks;
            trough_idx = [theta_troughs(:,4)] == thetaseq(t).theta_sequences(idx).theta_cycle_centre_trough_times;
            upper = theta_peaks(theta_peaks(:,4) > theta_troughs(trough_idx,4),4);
            lower = theta_peaks(theta_peaks(:,4) < theta_troughs(trough_idx,4),4);
            peaks_times = [lower(end), upper(1)];
            
            % Find animal's real position at the time of the trough
            linear_position =  position.linear(t).linear(~isnan(position.linear(t).linear));
            %[~,time_idx] = min(abs(position.linear(t).timestamps - spike_count(t).spike_count(idx).trough));
            [~,time_idx] = min(abs(position.linear(t).timestamps - thetaseq(t).theta_sequences(idx).theta_cycle_centre_trough_times));
            real_position = linear_position(time_idx);
            
            % Find spike times of the active units during the theta cycle
            spikes_phases_between_peaks = phases_deg(track_units_spikes >= peaks_times(1) & track_units_spikes <= peaks_times(2)); %spike phases between peaks
            ids_between_peaks = track_units_id(track_units_spikes >= peaks_times(1) & track_units_spikes <= peaks_times(2));  %spike IDs between peaks
            spikes_between_peaks = track_units_spikes(track_units_spikes >= peaks_times(1) & track_units_spikes <= peaks_times(2)); %spike times between peaks
            
            % Find spikes emitted during 45-315 degrees
            phase_idx = find(spikes_phases_between_peaks >= 45 & spikes_phases_between_peaks <= 315);
            spikes_between_phases = spikes_between_peaks(phase_idx);
            ids_between_phases = ids_between_peaks(phase_idx);
            
            % Include only spikes from active units in track
            %             active_units_idx = ismember(ids_between_phases,active_units_ID);
            %             active_units_between_phases = ids_between_phases(active_units_idx);
            %             active_units_spikes_between_phases = spikes_between_phases(active_units_idx);
            
            % Find centre of mass of active units and check if they are within -+50cm from the animal's current position
            position_edges = [real_position-50 real_position+50];
            position_edges(position_edges<0) = 0;
            active_units_centers_of_mass = place_fields.track(t).centre_of_mass(ids_between_phases);
            peak_position_idx = find(active_units_centers_of_mass >= position_edges(1) & active_units_centers_of_mass <= position_edges(2));
            
            % Pearson's correlation
            if length(spikes_between_phases(peak_position_idx)) > 1
                [track_pearsons_corr(d).track(t).corr(count), track_pearsons_corr(d).track(t).pval(count)] = corr(spikes_between_phases(peak_position_idx),ids_between_phases(peak_position_idx));
                count = count + 1;
            end
        end
        
        sig_indices = find(track_pearsons_corr(d).track(t).pval(:) < 0.05);
        figure(f(3*d))
        ax(c) = subplot(4,2,c);
        h1 = histogram(track_pearsons_corr(d).track(t).corr(:),-1:0.05:1);
        h1.FaceColor = [0.3 0.3 0.3];
        h1.EdgeColor = [0.7 0.7 0.7];
        hold on;
        h2 = histogram(track_pearsons_corr(d).track(t).corr(sig_indices),-1:0.05:1);
        h2.FaceColor = [0.6 0.2 0.2];
        h2.EdgeColor = [0.6 0.6 0.6];
        xlabel('Spike train correlation')
        ylabel('Number of theta sequences')
        ax(c).FontSize = 13;
        
        ax(c+1) = subplot(4,2,c+1);
        h3 = histogram(track_pearsons_corr(d).track(t).pval(:),0:0.05:1);
        h3.FaceColor = [0.3 0.3 0.3];
        h3.EdgeColor = [0.7 0.7 0.7];
        hold on;
        hold on;
        h4 = histogram(track_pearsons_corr(d).track(t).pval(sig_indices),0:0.05:1);
        h4.FaceColor = [0.6 0.2 0.2];
        h4.EdgeColor = [0.6 0.6 0.6];
        xlabel('Spike train pval')
        ylabel('Number of theta sequences')
        ax(c+1).FontSize = 13;
        
        c = c+2;
        
    end
end



end