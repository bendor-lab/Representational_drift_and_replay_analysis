% EXTRACT THETA SEQUENCES FOR EACH LAP
% MH 2020
% For each track, extracts theta sequences for each lap. Uses place fields
% from individual laps. Meaning each lap needs to be decoded individually
% Then averages all theta sequences within a lap and scores it using quantification methods,

function extract_lap_thetaseq_With_lap_plfields

sessions = data_folders_08;
session_names = fieldnames(sessions);
num_shuffles = 1000;

for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    
    for s = 1 : length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        tic
        
        load extracted_laps.mat
        load Theta\theta_seq_bayesian_spike_count.mat
        %load extracted_lap_place_fields.mat
        load extracted_directional_lap_place_fields.mat
        load Theta\theta_time_window.mat
        folder_name = strsplit(pwd,'\');
   
        for t = 1 : length(lap_times) % for each track
            
            % Preallocate variables
            c_1 = 1;
            c_2 = 1;
            track_idx = find(theta_spike_count.replay_events_indices == t);
            if t<3
                num_laps = length(lap_times(t).completeLaps_start);
            else
                num_laps = 16;
            end
            
            for thisLap = 1 : num_laps-1 % for each lap
                disp(['Lap ' num2str(thisLap) '-Track ' num2str(t)])
                cc = 1;
                cc1 = 1;
                % Find start and end time
                start_time = lap_times(t).completeLaps_start(thisLap);
                end_time = lap_times(t).completeLaps_stop(thisLap);
                
                %Get spike count for that half lap
                center_idx = find(theta_spike_count.replay_events(t).replay_time_centered >= start_time & theta_spike_count.replay_events(t).replay_time_centered <= end_time);
                lap_spike_count.replay_time_centered = theta_spike_count.replay_events(t).replay_time_centered(center_idx); %keep name of variable for bayesian code
                lap_spike_count.replay_time_edges = theta_spike_count.replay_events(t).replay_time_edges(theta_spike_count.replay_events(t).replay_time_edges >= start_time & ...
                    theta_spike_count.replay_events(t).replay_time_edges <= end_time);
                % add value to take into account the column of NaNs separating the tracks within the n.replay structure
                if t == 2
                    center_idx = track_idx(center_idx);
                elseif t == 3
                    center_idx = track_idx(center_idx);
                elseif t ==4
                    center_idx = track_idx(center_idx);
                end
                lap_spike_count.n.replay = theta_spike_count.n.replay(:,center_idx);
                lap_spike_count.theta_bins_width_concat = theta_spike_count.theta_bins_width_concat(center_idx);
                
                %%% If using half lap place fields
%                 if ~isempty(lap_directional_place_fields(t).dir2.half_Lap{1,thisLap}.good_cells)
%                     plfields = lap_directional_place_fields(t).dir2.half_Lap{1,thisLap};
%                 else
%                     plfields = lap_directional_place_fields(t).dir1.half_Lap{1,thisLap};
%                 end
                    
                % Bayesian decoding
                temp_estimated_position.dir1 = bayesian_decoding_lap_thetaseq(lap_directional_place_fields(t).dir1.Complete_Lap{1,thisLap+1},lap_spike_count,t);%lap_place_fields(t).half_Lap{1,thisLap}
                temp_estimated_position.dir2 = bayesian_decoding_lap_thetaseq(lap_directional_place_fields(t).dir2.Complete_Lap{1,thisLap+1},lap_spike_count,t);%lap_place_fields(t).half_Lap{1,thisLap}
                
                 if isempty(temp_estimated_position.dir2.replay_OneTrack) | isempty(temp_estimated_position.dir1.replay_OneTrack)  %when analysing complete laps - if it's a half lap skip
                     directional_lap_thetaseq(t).Lap{thisLap} = [];
                     continue
                end
                
                % Split the decoded lap in theta cycles, and classify according to direction
                lap_cycles = find(theta_windows.track(t).theta_windows(:,2) >= start_time & theta_windows.track(t).theta_windows(:,2) <= end_time); %indices of theta cycles in this lap
                
                for tw = 1 : length(lap_cycles) %for each theta window
                    if theta_windows.track(t).theta_windows(lap_cycles(tw),3) ~= 0
                        % Find indices of time bins edges and centres within each theta window (should match)
                        idcs = find(temp_estimated_position.dir1.replay_time_edges >= theta_windows.track(t).theta_windows(lap_cycles(tw),1)  &...
                            temp_estimated_position.dir1.replay_time_edges  <= theta_windows.track(t).theta_windows(lap_cycles(tw),2));
                        idcs_cent = find(temp_estimated_position.dir1.replay_time_centered > theta_windows.track(t).theta_windows(lap_cycles(tw),1)  &...
                            temp_estimated_position.dir1.replay_time_centered  < theta_windows.track(t).theta_windows(lap_cycles(tw),2));
                        % If theta window is in direction 1
                        if theta_windows.track(t).theta_windows(lap_cycles(tw),3) == 1 && length(idcs_cent) == 10
%                             decoded_thetaSeq.direction1(t).theta_sequences(c_1).theta_cycle_peaks_times = [theta_windows.track(t).theta_windows(lap_cycles(tw),1) theta_windows.track(t).theta_windows(lap_cycles(tw),2)];
%                             decoded_thetaSeq.direction1(t).theta_sequences(c_1).theta_cycle_trough_time = theta_windows.track(t).theta_troughs_timestamps(lap_cycles(tw),1);
%                             decoded_thetaSeq.direction1(t).theta_sequences(c_1).timebins_edges = temp_estimated_position.dir1.replay_time_edges(idcs);
%                             decoded_thetaSeq.direction1(t).theta_sequences(c_1).timebins_centre = temp_estimated_position.dir1.replay_time_centered(idcs_cent);
%                             decoded_thetaSeq.direction1(t).theta_sequences(c_1).timebins_edge_index = idcs;
%                             decoded_thetaSeq.direction1(t).theta_sequences(c_1).timebins_centre_index = idcs_cent;
%                             decoded_thetaSeq.direction1(t).theta_sequences(c_1).decoded_position = temp_estimated_position.dir1.replay_OneTrack(:,idcs_cent); % normalized by all tracks                            
%                             decoded_thetaSeq.direction1(t).theta_sequences(c_1).index_from_theta_windows = lap_cycles(tw); %index of theta event in theta windows structure
%                             decoded_thetaSeq.direction1(t).theta_sequences(c_1).lap_ID = thisLap; 
%                             if isfield('decoded_thetaSeq.direction1(t)','track_active_units_ID')
%                                 decoded_thetaSeq.direction1(t).track_active_units_ID = intersect(decoded_thetaSeq.direction1(t).track_active_units_ID,temp_estimated_position.dir1.active_units_ID);
%                             else
%                                 decoded_thetaSeq.direction1(t).track_active_units_ID = temp_estimated_position.dir1.active_units_ID;
%                             end
                            c_1 = c_1+1;
                            out.direction1(t).theta_sequences(cc).theta_cycle_peaks_times = [theta_windows.track(t).theta_windows(lap_cycles(tw),1) theta_windows.track(t).theta_windows(lap_cycles(tw),2)];
                            out.direction1(t).theta_sequences(cc).theta_cycle_trough_time = theta_windows.track(t).theta_troughs_timestamps(lap_cycles(tw),1);
                            out.direction1(t).theta_sequences(cc).timebins_edges = temp_estimated_position.dir1.replay_time_edges(idcs);
                            out.direction1(t).theta_sequences(cc).timebins_centre = temp_estimated_position.dir1.replay_time_centered(idcs_cent);
                            out.direction1(t).theta_sequences(cc).timebins_edge_index = idcs;
                            out.direction1(t).theta_sequences(cc).timebins_centre_index = idcs_cent;
                            out.direction1(t).theta_sequences(cc).decoded_position = temp_estimated_position.dir1.replay_OneTrack(:,idcs_cent); % normalized by all tracks                            
                            out.direction1(t).theta_sequences(cc).index_from_theta_windows = lap_cycles(tw); %index of theta event in theta windows structure
                            out.direction1(t).theta_sequences(cc).lap_ID = thisLap; 
                            if isfield('decoded_thetaSeq.direction1(t)','track_active_units_ID')
                                out.direction1(t).track_active_units_ID = intersect(out.direction1.track_active_units_ID,temp_estimated_position.dir1.active_units_ID);
                            else
                                out.direction1(t).track_active_units_ID = temp_estimated_position.dir1.active_units_ID;
                            end
                            cc = cc+1;
                            
                            % If theta window is in direction 2
                        elseif theta_windows.track(t).theta_windows(lap_cycles(tw),3) == 2 && length(idcs_cent) == 10
%                             decoded_thetaSeq.direction2(t).theta_sequences(c_2).theta_cycle_peaks_times = [theta_windows.track(t).theta_windows(lap_cycles(tw),1) theta_windows.track(t).theta_windows(lap_cycles(tw),2)];
%                             decoded_thetaSeq.direction2(t).theta_sequences(c_2).theta_cycle_trough_time = theta_windows.track(t).theta_troughs_timestamps(lap_cycles(tw),1);
%                             decoded_thetaSeq.direction2(t).theta_sequences(c_2).timebins_edges = temp_estimated_position.dir2.replay_time_edges(idcs);
%                             decoded_thetaSeq.direction2(t).theta_sequences(c_2).timebins_centre = temp_estimated_position.dir2.replay_time_centered(idcs_cent);
%                             decoded_thetaSeq.direction2(t).theta_sequences(c_2).timebins_edge_index = idcs;
%                             decoded_thetaSeq.direction2(t).theta_sequences(c_2).timebins_centre_index = idcs_cent;
%                             decoded_thetaSeq.direction2(t).theta_sequences(c_2).decoded_position = temp_estimated_position.dir2.replay_OneTrack(:,idcs_cent); % normalized by all tracks
%                             decoded_thetaSeq.direction2(t).theta_sequences(c_2).index_from_theta_windows = lap_cycles(tw); %index of theta event in theta windows structure
%                             decoded_thetaSeq.direction2(t).theta_sequences(c_2).lap_ID = thisLap; 
%                             if isfield('decoded_thetaSeq.direction2(t)','track_active_units_ID')
%                                 decoded_thetaSeq.direction2(t).track_active_units_ID = intersect(decoded_thetaSeq.direction2(t).track_active_units_ID,temp_estimated_position.dir2.active_units_ID);
%                             else
%                                 decoded_thetaSeq.direction2(t).track_active_units_ID = temp_estimated_position.dir2.active_units_ID;
%                             end
                            c_2 = c_2 +1;
                            out.direction2(t).theta_sequences(cc1).theta_cycle_peaks_times = [theta_windows.track(t).theta_windows(lap_cycles(tw),1) theta_windows.track(t).theta_windows(lap_cycles(tw),2)];
                            out.direction2(t).theta_sequences(cc1).theta_cycle_trough_time = theta_windows.track(t).theta_troughs_timestamps(lap_cycles(tw),1);
                            out.direction2(t).theta_sequences(cc1).timebins_edges = temp_estimated_position.dir2.replay_time_edges(idcs);
                            out.direction2(t).theta_sequences(cc1).timebins_centre = temp_estimated_position.dir2.replay_time_centered(idcs_cent);
                            out.direction2(t).theta_sequences(cc1).timebins_edge_index = idcs;
                            out.direction2(t).theta_sequences(cc1).timebins_centre_index = idcs_cent;
                            out.direction2(t).theta_sequences(cc1).decoded_position = temp_estimated_position.dir2.replay_OneTrack(:,idcs_cent); % normalized by all tracks
                            out.direction2(t).theta_sequences(cc1).index_from_theta_windows = lap_cycles(tw); %index of theta event in theta windows structure
                            out.direction2(t).theta_sequences(cc1).lap_ID = thisLap; 
                            if isfield('decoded_thetaSeq.direction2(t)','track_active_units_ID')
                                out.direction2(t).track_active_units_ID = intersect(out.direction2.track_active_units_ID,temp_estimated_position.dir2.active_units_ID);
                            else
                                out.direction2(t).track_active_units_ID = temp_estimated_position.dir2.active_units_ID;
                            end
                            cc1 = cc1 +1;

                        end
                    end
                end
                
                % Apply last threshold: position threshold
                [out,~]= theta_sequences_position_threshold(out);
                
                if isfield(out,'direction1') && isfield(out,'direction2')
                    if isempty(out.direction1(t).theta_sequences) && isempty(out.direction2(t).theta_sequences)
                        directional_lap_thetaseq(t).Lap{thisLap} = [];
                        continue
                    end
                end
                
                %%% Calculate average theta sequence
                [centered_averaged_thetaSeq,~] = averaged_concat_theta_cycle(out,0);
                
                %%%%% Apply quantification methods
                % Quadrant Ratio
                centered_averaged_thetaSeq = phase_quadrant_ratio(centered_averaged_thetaSeq);
                
                % Weighted Correlation
                fields = fieldnames(centered_averaged_thetaSeq);
                for d = 1 : length(fields) % for each direction
                    for track= 1 : length(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))) % for each track
                        if isempty(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(track).thetaseq)
                            continue
                        end
                        central_cycle = centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(track).mean_relative_position;
                        centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(track).weighted_corr = weighted_correlation(central_cycle);
                    end
                end
                
                directional_lap_thetaseq(t).Lap{thisLap} = centered_averaged_thetaSeq;
                
                %Shuffles
                [~,lap_phase_shuffle(t).Lap{thisLap}] = thetaseq_circular_phase_shuffle(out,num_shuffles,0,[]);
                [~,lap_position_shuffle(t).Lap{thisLap}] = thetaseq_circular_position_shuffle(out,num_shuffles,0,[]);
                [lap_PREspike_train_circ_shuffle_scores(t).Lap{thisLap}, ~] = lap_thetaseq_phase_PRE_spike_circ_shuffle(out,lap_directional_place_fields,lap_spike_count,t,thisLap+1,num_shuffles,0,[]);
                
                %plot_averaged_concat_theta_sequences(centered_averaged_thetaSeq,[],[])
                
                clear centered_averaged_thetaSeq out temp_estimated_position 
            end
        end
        
        %Save shuffles
        save('Theta\lap_thetaSeq_PREspikeTrain_circ_shuffle_NEXTLAP.mat','lap_PREspike_train_circ_shuffle_scores','-v7.3')
        save('Theta\lap_thetaseq_position_shuffle_NEXTLAP.mat','lap_position_shuffle','-v7.3') 
        save('Theta\lap_thetaseq_phase_shuffle_NEXTLAP.mat','lap_phase_shuffle','-v7.3') 
        
       % clear lap_PREspike_train_circ_shuffle_scores lap_position_shuffle lap_phase_shuffle
%         
%         % Apply last threshold: position threshold
%         [decoded_thetaSeq,~]= theta_sequences_position_threshold(decoded_thetaSeq);
%         
%         % Saves structure
%         save('Theta\decoded_lap_theta_sequences_SMOOTHED','decoded_thetaSeq','-v7.3')
%         
%         %%% Calculate average theta sequence
%         [centered_averaged_thetaSeq,centered_averaged_CONCAT_thetaSeq] = averaged_concat_theta_cycle(decoded_thetaSeq,1);
% 
%          %plot_averaged_concat_theta_sequences(centered_averaged_thetaSeq,centered_averaged_CONCAT_thetaSeq,[])
%          
%          % Save
%          save('Theta\lap_theta_sequence_quantification_SMOOTHED','centered_averaged_thetaSeq','centered_averaged_CONCAT_thetaSeq','directional_lap_thetaseq','-v7.3')
    toc
    end
    keep folders p s session_names sessions
end
end


function  [decoded_thetaSeq,deleted_decoded_thetaSeq]= theta_sequences_position_threshold(decoded_thetaSeq)
% Set position threshold: theta sequences only analysed when the animal is in the middle of track (1/6 to 5/6) - Feng et al (2015, J Neuro)

if isempty(decoded_thetaSeq)
    load Theta\decoded_theta_sequences.mat
end
load extracted_position.mat

parameters = list_of_parameters;

% Exclude reward sites, both are 20 cm (total length 200cm)
lower_thresh = 20; 
high_thresh = 180;

fields = fieldnames(decoded_thetaSeq);
for d = 1 : length(fields) % for each direction
    
    for t = 1 : length(decoded_thetaSeq.(sprintf('%s',fields{d}))) % for each track
        indices_to_remove = [];
        if isempty(decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences)
            continue
        end
        for s = 1 : size(decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences,2) %for each theta sequence
            
            linear_position =  position.linear(t).linear(~isnan(position.linear(t).linear));
            [~,time_idx] = min(abs(position.linear(t).timestamps - decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(s).theta_cycle_trough_time));
            real_position(s) = linear_position(time_idx);
            
            % If animal position is at the start or end of track, save index
            if real_position(s) < lower_thresh | real_position(s) > high_thresh
                indices_to_remove = [indices_to_remove s];
            end
        end
        
        %%% Uncomment for safety check figure
        %figure;
        %histogram(real_position)
        %xlabel('Position (cm)'); ylabel('number of theta windows')
        
        clear real_position
        % For checking, save only the deleted sequences
        deleted_decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences = decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(indices_to_remove);
        % Delete indices
        decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(indices_to_remove) = [];
        
    end
    
end

end
