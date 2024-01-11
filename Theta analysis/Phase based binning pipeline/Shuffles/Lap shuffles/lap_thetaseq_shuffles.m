function lap_thetaseq_shuffles(computer)

if isempty(computer)
    sessions = data_folders;
elseif strcmp(computer,'GPU')
        sessions = data_folders_GPU;
elseif strcmp(computer,'08')
        sessions = data_folders_08;
end
session_names = fieldnames(sessions);
num_shuffles = 1000;

for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    
    for s = 1 : length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        tic
        load('Theta\decoded_lap_theta_sequences_SMOOTHED.mat')
        load extracted_directional_lap_place_fields.mat
        load Theta\theta_seq_bayesian_spike_count.mat
        load extracted_laps.mat
        
        for t = 1 : length(lap_times) % for each track
            num_laps = unique([decoded_thetaSeq.direction1(t).theta_sequences(:).lap_ID decoded_thetaSeq.direction2(t).theta_sequences(:).lap_ID]); 
            track_idx = find(theta_spike_count.replay_events_indices == t);
            
            for thisLap = 1 : length(num_laps) % for each lap
                disp(['Track' num2str(t) '-Lap ' num2str(thisLap)])
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

                out.direction1(t).theta_sequences = decoded_thetaSeq.direction1(t).theta_sequences([decoded_thetaSeq.direction1(t).theta_sequences(:).lap_ID] == thisLap);
                out.direction2(t).theta_sequences = decoded_thetaSeq.direction2(t).theta_sequences([decoded_thetaSeq.direction2(t).theta_sequences(:).lap_ID] == thisLap);

                   % Apply last threshold: position threshold
                [out,~]= theta_sequences_position_threshold(out);
                
                if isfield(out,'direction1') && isfield(out,'direction2')
                    if isempty(out.direction1(t).theta_sequences) && isempty(out.direction2(t).theta_sequences)
                        continue
                    end
                end
                
                % Shuffles
                disp('Phase shuffle')
                [~,lap_phase_shuffle(t).Lap{thisLap}] = thetaseq_circular_phase_shuffle(out,num_shuffles,0,[]);
                disp('Position shuffle')
                [~,lap_position_shuffle(t).Lap{thisLap}] = thetaseq_circular_position_shuffle(out,num_shuffles,0,[]);
                disp('PRE spike shuffle')
                [lap_PREspike_train_circ_shuffle_scores(t).Lap{thisLap}, ~] = lap_thetaseq_phase_PRE_spike_circ_shuffle(out,lap_directional_place_fields,lap_spike_count,t,thisLap,num_shuffles,0,[]);

                %plot_averaged_concat_theta_sequences(centered_averaged_thetaSeq,[],[])
                
                clear out lap_spike_count
            end
        end
        
        %%%Save shuffles
        save('Theta\lap_thetaSeq_PREspikeTrain_circ_shuffle_SMOOTHED.mat','lap_PREspike_train_circ_shuffle_scores','-v7.3')
        save('Theta\lap_thetaseq_position_shuffle_SMOOTHED.mat','lap_position_shuffle','-v7.3')
        save('Theta\lap_thetaseq_phase_shuffle_SMOOTHED.mat','lap_phase_shuffle','-v7.3')
        
         keep folders p s session_names sessions num_shuffles

    end
end
end

function  [decoded_thetaSeq,deleted_decoded_thetaSeq]= theta_sequences_position_threshold(decoded_thetaSeq)
% Set position threshold: theta sequences only analysed when the animal is in the middle of track (1/6 to 5/6) - Feng et al (2015, J Neuro)
curr_path = pwd;
if isempty(decoded_thetaSeq)
    load([curr_path '\Theta\decoded_theta_sequences.mat'])
end
load([curr_path '\extracted_position.mat'])

parameters = list_of_parameters;
deleted_decoded_thetaSeq = [];
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
