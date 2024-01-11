% THETA SEQUENCES QUANTIFICATION: SPIKE TRAIN CORRELATION
% MH, 2020
% From Feng et al (2015,J Neuro). For each theta sequence, calculate Pearson's linear correlation coefficient between spike timing and place cell peak
% firing positions for spikes emitted during 45-315 degrees of individual theta cycle (referenced to global zero) and for cells whose peak firing
% positions were within 50cm behind or in fron of the animal's current position.

function centered_averaged_thetaSeq = spike_train_correlation_phase(decoded_thetaSeq,plot_option,save_option)

if isempty(decoded_thetaSeq)
    load Theta\decoded_theta_sequences.mat
end
load Theta\theta_sequence_quantification.mat
load extracted_CSC.mat
load extracted_clusters.mat
load extracted_position.mat
load extracted_directional_place_fields.mat


theta_CSC_time = CSC(4).CSCtime;
% Get theta phase
hilb = hilbert(CSC(4).theta);
theta_phase = angle(hilb);
theta_phase_unwrap = unwrap(theta_phase); % unwrap for interpolation

% Get active units in each track and direction
fields = fieldnames(decoded_thetaSeq);
fields = fields(cellfun(@(s) isempty(strmatch ('phase', s)), fieldnames(decoded_thetaSeq)));
for d = 1 : length(fields) %only 2 directions     
    c = 1;
    
    if plot_option == 1
        f(3*d) =  figure;
    end
    
    for t = 1 : length(directional_place_fields(d).place_fields.track) % for each track
        
        if centered_averaged_thetaSeq.(strcat(fields{d}))(t).direction_swapped == 1 %if directions have been swapped during the pipeline, get the units from the other direction
            if d == 1
                track_active_units_ID =  decoded_thetaSeq.(strcat(fields{2}))(t).track_active_units_ID; % units active in this track and direction
            else
                track_active_units_ID =  decoded_thetaSeq.(strcat(fields{1}))(t).track_active_units_ID; % units active in this track and direction
            end
        else
            track_active_units_ID =  decoded_thetaSeq.(strcat(fields{d}))(t).track_active_units_ID; % units active in this track and direction
        end
        
        units_idx = ismember(clusters.spike_id',track_active_units_ID); %find indices of units active in track
        track_units_id = clusters.spike_id(units_idx);
        [track_units_spikes,sort_idx] = sort(clusters.spike_times(units_idx)); %find spike times of units active in track
        track_units_id = track_units_id(sort_idx); %sort by time
        
        % Interpolate phases for each spike time
        spike_phases = interp1(theta_CSC_time,theta_phase_unwrap,track_units_spikes,'linear');
        phases_deg = rad2deg(mod(spike_phases,2*pi)); %change spike phases from rad to degrees
        
        count = 1;
        for tw = 1 : length([centered_averaged_thetaSeq.(strcat(fields{d}))(t).thetaseq])
                        
            % Get theta cycle window edges, from peak to peak
            peaks_times = centered_averaged_thetaSeq.(strcat(fields{d}))(t).thetaseq(tw).theta_cycle_peaks_times;
            
            % Find animal's real position at the time of the trough
            linear_position =  position.linear(t).linear(~isnan(position.linear(t).linear));
            %[~,time_idx] = min(abs(position.linear(t).timestamps - spike_count(t).spike_count(idx).trough));
            [~,time_idx] = min(abs(position.linear(t).timestamps - centered_averaged_thetaSeq.(strcat(fields{d}))(t).thetaseq(tw).theta_cycle_centre_trough_times));
            real_position = linear_position(time_idx);
            
            % Find spike times of the active units during the theta cycle
            spikes_phases_between_peaks = phases_deg(track_units_spikes >= peaks_times(1) & track_units_spikes <= peaks_times(2)); %spike phases between peaks
            ids_between_peaks = track_units_id(track_units_spikes >= peaks_times(1) & track_units_spikes <= peaks_times(2));  %spike IDs between peaks
            spikes_times_between_peaks = track_units_spikes(track_units_spikes >= peaks_times(1) & track_units_spikes <= peaks_times(2)); %spike times between peaks
             
            %figure;plot(spikes_times_between_peaks,spikes_phases_between_peaks)
            %hold on;plot(spikes_times_between_peaks,spikes_phases_between_peaks,'o')
            %hold on;plot(peaks_times,[200 200],'o')
            %hold on;plot(centered_averaged_thetaSeq.(strcat(fields{d}))(t).thetaseq(tw).theta_cycle_centre_trough_times,[200],'o')
            
%             % Find spikes emitted during 45-315 degrees
%             phase_idx = find(spikes_phases_between_peaks >= 45 & spikes_phases_between_peaks <= 315);
%             spikes_times_between_peaks = spikes_times_between_peaks(phase_idx);
%             ids_between_phases = ids_between_peaks(phase_idx);
%             hold on;plot(spikes_times_between_peaks,spikes_phases_between_peaks(phase_idx),'x')

            %If a cell has multiple spikes, find median
            ids_between_phases = ids_between_peaks;
            unique_units = unique(ids_between_phases); %ids_between_peaks
            id_count = histc(ids_between_phases,unique_units);
            mult_spike = unique_units(id_count > 1);
            for j = 1 : length(mult_spike)
                median_time = mean(spikes_times_between_peaks(ids_between_phases == mult_spike(j)));
                spikes_times_between_peaks(ids_between_phases == mult_spike(j)) = [];
                ids_between_phases(ids_between_phases == mult_spike(j)) = [];
                spikes_times_between_peaks(end+1)= median_time;
                ids_between_phases(end+1) = mult_spike(j);
            end
            [spikes_times_between_peaks,sort_idx] = sort(spikes_times_between_peaks);
            ids_between_phases = ids_between_phases(sort_idx);
            
            
            % Include only spikes from active units in track
            %             active_units_idx = ismember(ids_between_phases,active_units_ID);
            %             active_units_between_phases = ids_between_phases(active_units_idx);
            %             active_units_spikes_between_phases = spikes_between_phases(active_units_idx);
            
            % Find centre of mass of active units and check if they are within -+50cm from the animal's current position
            position_edges = [real_position-50 real_position+50];
            position_edges(position_edges<0) = 0; 
            position_edges(position_edges>200) = 200;
            active_units_centers_of_mass = directional_place_fields(d).place_fields.track(t).centre_of_mass(ids_between_phases);
            peak_position_idx = find(active_units_centers_of_mass >= position_edges(1) & active_units_centers_of_mass <= position_edges(2));
            
            % Pearson's correlation coefficient between spike timing and place cell peak firing position
            if length(spikes_times_between_peaks(peak_position_idx)) > 2
                [centered_averaged_thetaSeq.(strcat(fields{d}))(t).pearson_corr(count), centered_averaged_thetaSeq.(strcat(fields{d}))(t).pearson_pval(count)] = corr(spikes_times_between_peaks(peak_position_idx),active_units_centers_of_mass(peak_position_idx)');
                count = count + 1;
            end
        end
        
        if plot_option == 1
            sig_indices = find(centered_averaged_thetaSeq.(strcat(fields{d}))(t).pearson_pval(:) < 0.05);
            figure(f(3*d))
            ax(c) = subplot(4,2,c);
            h1 = histogram(centered_averaged_thetaSeq.(strcat(fields{d}))(t).pearson_corr(:),-1:0.05:1);
            h1.FaceColor = [0.3 0.3 0.3];
            h1.EdgeColor = [0.7 0.7 0.7];
            hold on;
            h2 = histogram(centered_averaged_thetaSeq.(strcat(fields{d}))(t).pearson_corr(sig_indices),-1:0.05:1);
            h2.FaceColor = [0.6 0.2 0.2];
            h2.EdgeColor = [0.6 0.6 0.6];
            xlabel('Spike train correlation')
            ylabel('Number of theta sequences')
            ax(c).FontSize = 13;
            
            ax(c+1) = subplot(4,2,c+1);
            h3 = histogram(centered_averaged_thetaSeq.(strcat(fields{d}))(t).pearson_pval(:),0:0.05:1);
            h3.FaceColor = [0.3 0.3 0.3];
            h3.EdgeColor = [0.7 0.7 0.7];
            hold on;
            hold on;
            h4 = histogram(centered_averaged_thetaSeq.(strcat(fields{d}))(t).pearson_pval(sig_indices),0:0.05:1);
            h4.FaceColor = [0.6 0.2 0.2];
            h4.EdgeColor = [0.6 0.6 0.6];
            xlabel('Spike train pval')
            ylabel('Number of theta sequences')
            ax(c+1).FontSize = 13;
        end
        c = c+2;
        
    end
end

% Save
if strcmp(save_option,'Y')
    save Theta\theta_sequence_quantification centered_averaged_thetaSeq centered_averaged_CONCAT_thetaSeq
    
end
end