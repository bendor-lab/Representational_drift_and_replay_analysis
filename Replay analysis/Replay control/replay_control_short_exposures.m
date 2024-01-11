% BATCH ANALYSIS FOR REPLAY CONTROL FOR SHORTER EXPOSURES
% MH_2020
% For each session, this code takes the rate maps of T1 for the same number of laps than for T2 (e.g. If T2 is 2 Laps, then it takes ratemaps after 2
% laps in T1). Then it used these new place fields to decode replay events, and runs the same shuffle analysis as for normal data.
% INPUT - Control type:
    % 'Stability': In this control we keep both the replay events and the good cells from the orgininal data set (i.e. in replay_decoding, use original good cells
        % to find spikes inside replay event). This control tells us about place field stability, that is, how well can you decode with earlier cells in
        % the exposure. The analysis would be equivalent to adding a 5th track to decode.
    % 'short_exposure': In this control, both the replay events and good cells will be changed, by replacing the T1 good cells for the new T1 good cells (which will be
        % good cells after running X laps, where X is the same amount of laps run in T2). That means that replay events won't be including cells that will
        % only appear in later laps in T1. This control tries to simulate what would have happened if there was the same number of laps in both tracks.
% INPUT - lap_order:
    % 'first': uses the first laps of the exposure to calculate the new place fields
    % 'last': uses the last laps of the exposure to calculate the new place fields

function replay_control_short_exposures(control_type,lap_order)

rat_folder = pwd;

if strcmp(control_type,'short_exposure') && strcmp(lap_order,'first') %using first laps
    if exist('replay_control_short_exposures')~=7
        mkdir replay_control_short_exposures
    end
    cd replay_control_short_exposures
    main_save_folder = pwd;
elseif strcmp(control_type,'short_exposure') && strcmp(lap_order,'last') % using last laps
    if exist('replay_control_short_exposures_LAST')~=7
        mkdir replay_control_short_exposures_LAST
    end
    cd replay_control_short_exposures_LAST
    main_save_folder = pwd;
elseif strcmp(control_type,'Stability')
    if exist('replay_control_stability')~=7
        mkdir replay_control_stability
    end
    cd replay_control_stability
    main_save_folder = pwd;
end

copyfile([rat_folder '\extracted_replay_events.mat'],[main_save_folder '\extracted_replay_events.mat']);
copyfile([rat_folder '\extracted_sleep_state.mat'],[main_save_folder '\extracted_sleep_state.mat']);
copyfile([rat_folder '\extracted_position.mat'],[main_save_folder '\extracted_position.mat']);
copyfile([rat_folder '\extracted_clusters.mat'],[main_save_folder '\extracted_clusters.mat']);
copyfile([rat_folder '\extracted_waveforms.mat'],[main_save_folder '\extracted_waveforms.mat']);
copyfile([rat_folder '\MUA_clusters.mat'],[main_save_folder '\MUA_clusters.mat']);
copyfile([rat_folder '\best_CSC.mat'],[main_save_folder '\best_CSC.mat']);
copyfile([rat_folder '\extracted_CSC.mat'],[main_save_folder '\extracted_CSC.mat']);
copyfile([rat_folder '\extracted_laps.mat'],[main_save_folder '\extracted_laps.mat']);
  

disp('Creating new place fields')
create_shorter_T1_place_fields(control_type,'last');

% Run batch analysis on replay
batch_analysis([7,8],[]); 

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