% BATCH ANALYSIS FOR REPLAY CONTROL FOR 1 LAP TRACK
% MH_2020
% For 1 lap session, this code takes each lap from T1, calculate it's place fields and compares it to T2 1 LAP (e.g. ratemaps Lap 5 T1 vs Lap1 T2).
% Then it used these new place fields to decode replay events, and runs the same shuffle analysis as for normal data.
% In this control, both the replay events and good cells will be changed, by replacing the T1 good cells for the new T1 good cells (which will be
% good cells after running X laps, where X is the same amount of laps run in T2). That means that replay events won't be including cells that will
% only appear in later laps in T1. This control tries to simulate what would have happened if there was the same number of laps in both tracks.


function replay_control_1LAP_shuffles(computer)

% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
elseif strcmp(computer,'08')
    sessions = data_folders_08;
    session_names = fieldnames(sessions);
else
    sessions = data_folders;
    session_names = fieldnames(sessions);
end

for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        tic
        
        rat_folder = pwd;
        if exist('replay_control_1LAP')~=7
            mkdir replay_control_1LAP
        end
        cd replay_control_1LAP
        main_save_folder = pwd;
        
        copyfile([rat_folder '\extracted_replay_events.mat'],[main_save_folder '\extracted_replay_events.mat']);
        copyfile([rat_folder '\extracted_sleep_state.mat'],[main_save_folder '\extracted_sleep_state.mat']);
        copyfile([rat_folder '\extracted_position.mat'],[main_save_folder '\extracted_position.mat']);
        copyfile([rat_folder '\extracted_clusters.mat'],[main_save_folder '\extracted_clusters.mat']);
        copyfile([rat_folder '\extracted_waveforms.mat'],[main_save_folder '\extracted_waveforms.mat']);
        copyfile([rat_folder '\MUA_clusters.mat'],[main_save_folder '\MUA_clusters.mat']);
        copyfile([rat_folder '\best_CSC.mat'],[main_save_folder '\best_CSC.mat']);
        copyfile([rat_folder '\extracted_CSC.mat'],[main_save_folder '\extracted_CSC.mat']);
        copyfile([rat_folder '\extracted_place_fields.mat'],[main_save_folder '\extracted_place_fields.mat']);

        load([rat_folder '\extracted_lap_place_fields_BAYESIAN.mat']);

        % For each lap in T1
        disp('Extracting lap place fields')
        laps_order = [5,4,3,2,1,6:length(lap_place_fields_BAYESIAN(1).Complete_Lap)];
        for lap = 1 : length(lap_place_fields_BAYESIAN(1).Complete_Lap)
            disp(laps_order(lap))
            % Create subfolder for this lap
            if exist(['T2-1LAP vs T1-LAP ' num2str(laps_order(lap))])~=7
                mkdir(['T2-1LAP vs T1-LAP ' num2str(laps_order(lap))])
            end
            lap_save_folder = [pwd '\T2-1LAP vs T1-LAP ' num2str(laps_order(lap))];
            
            create_1LAP_T1_place_fields(laps_order(lap),rat_folder,main_save_folder,lap_save_folder); % extract new ratemap for T1
            
            % Run batch analysis on replay
            batch_analysis_shuffles([7,8],[]);
            
            %Move files to corresponding folder
            msg = ['T1-LAP ' num2str(laps_order(lap))];
            [status,msg] = movefile([main_save_folder '\bayesian_spike_count.mat'],[lap_save_folder '\bayesian_spike_count.mat'])
            [status,~] = movefile([main_save_folder '\estimated_position.mat'],[lap_save_folder '\estimated_position.mat'])
            [status,~] = movefile([main_save_folder '\extracted_replay_events.mat'],[lap_save_folder '\extracted_replay_events.mat'])
            [status,~] = movefile([main_save_folder '\decoded_replay_events.mat'],[lap_save_folder '\decoded_replay_events.mat'])
            [status,~] = movefile([main_save_folder '\scored_replay.mat'],[lap_save_folder '\scored_replay.mat'])
            [status,~] = movefile([main_save_folder '\shuffle_scores.mat'],[lap_save_folder '\shuffle_scores.mat'])
            [status,~] = movefile([main_save_folder '\shuffle_scores_segments.mat'],[lap_save_folder '\shuffle_scores_segments.mat'])
            [status,~] = movefile([main_save_folder '\scored_replay_segments.mat'],[lap_save_folder '\scored_replay_segments.mat'])
            [status,~] = movefile([main_save_folder '\significant_replay_events_wcorr_individual_exposures.mat'],[lap_save_folder '\significant_replay_events_wcorr_individual_exposures.mat'])
            [status,~] = movefile([main_save_folder '\significant_replay_events_wcorr.mat'],[lap_save_folder '\significant_replay_events_wcorr.mat'])
            [status,~] = movefile([main_save_folder '\significant_replay_events_spearman_individual_exposures.mat'],[lap_save_folder '\significant_replay_events_spearman_individual_exposures.mat'])
            [status,~] = movefile([main_save_folder '\significant_replay_events_spearman.mat'],[lap_save_folder '\significant_replay_events_spearman.mat'])
            [status,~] = movefile([main_save_folder '\shuffled_decoded_events1.mat'],[lap_save_folder '\shuffled_decoded_events1.mat'])
            [status,~] = movefile([main_save_folder '\shuffled_decoded_segments_1.mat'],[lap_save_folder '\shuffled_decoded_segments_1.mat'])
            [status,~] = movefile([main_save_folder '\shuffled_decoded_events2.mat'],[lap_save_folder '\shuffled_decoded_events2.mat'])
            [status,~] = movefile([main_save_folder '\shuffled_decoded_segments_2.mat'],[lap_save_folder '\shuffled_decoded_segments_2.mat'])
            [status,~] = movefile([main_save_folder '\shuffled_decoded_events3.mat'],[lap_save_folder '\shuffled_decoded_events3.mat'])
            [status,~] = movefile([main_save_folder '\shuffled_decoded_segments_3.mat'],[lap_save_folder '\shuffled_decoded_segments_3.mat'])
            [status,~] = movefile([main_save_folder '\decoded_replay_events_segments.mat'],[lap_save_folder '\decoded_replay_events_segments.mat'])
            [status,~] = movefile([main_save_folder '\replayEvents_bayesian_spike_count.mat'],[lap_save_folder '\replayEvents_bayesian_spike_count.mat'])

        end
        
        %After running everything, delete for saving space
        cd main_save_folder
        delete extracted_replay_events.mat
        delete extracted_sleep_state.mat
        delete extracted_position.mat
        delete extracted_clusters.mat
        delete extracted_waveforms.mat
        delete MUA_clusters.mat
        delete best_CSC.mat
        delete extracted_laps.mat
        
    end
    toc
end
end