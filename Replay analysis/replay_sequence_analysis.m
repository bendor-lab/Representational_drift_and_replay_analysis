% New function to analyse and score replay events

function [] = replay_sequence_analysis(folders, tracks_compared)

% INPUT : List of data folders to run the analysis, array of tracks we
% want to compare during bayesian decoding (across track normalisation)
% OUTPUT : None, creation of a folder with all the relevant files in it
% Loads : extracted_place_fields_BAYESIAN.mat

for folderID = 1:length(folders)
    
    folder = folders{folderID};
    
    % For tests
    clear
    folder = data_folders_excl;
    folder = folder{1};
    tracks_compared = [1, 3];
    
    cd(folder);
    
    % We find the name of the current folder comparison
    a = [1, 3];
    formatted_strings = arrayfun(@(x) sprintf('T%d', x), a, 'UniformOutput', false);
    targetFolder = ['Replay_', strjoin(formatted_strings, '_vs_')];
    
    % We check if the folder exist in the current folder
    
    if ~exist(targetFolder, 'dir')
        mkdir(targetFolder);
    end
    
    % We create the global path to save all the data
    globalPath = folder + "\" + targetFolder + "\";
    
    %% Load data
    
    load("extracted_place_fields_BAYESIAN");
    
    %% Extract replay events and Bayesian decoding
  
    [decoded_replay_events, replayEvents_bayesian_spike_count] = replay_decoding(tracks_compared, globalPath, "N");

    
    %% Score the replay events
    disp('Scoring replay events')
    scored_replay = replay_scoring(decoded_replay_events, place_fields_BAYESIAN, [0 1 0 0]);
    
    %% Shuffles
    
    disp("Starting shuffles")
    
    % Number of shuffles to do for each method
    num_shuffles = 4;
    
    % Types of shuffle we want to run
    % [linear wcorr path spearman]
    analysis_type = [0 1 0 0];
    
    p = gcp; % Starting new parallel pool
    
    shuffle_type = [];
    
    % Choosing the type of shuffle we want to execute num_shuffles times
    shuffle_choice = {'PRE spike_train_circular_shift','PRE place_field_circular_shift', 'POST place bin circular shift'};
    
    % Trying to start a parallel pool, otherwise classical computation
    % Add the num_shuffles shuffled scores to the shuffle_type object
    
    if ~isempty(p)
        for shuffle_id=1:length(shuffle_choice)
            shuffle_type{shuffle_id}.shuffled_track = parallel_shuffles(shuffle_choice{shuffle_id}, analysis_type, ...
                                                                        num_shuffles, decoded_replay_events, place_fields_BAYESIAN, ...
                                                                        replayEvents_bayesian_spike_count, tracks_compared);
        end
    else
        disp('Parallel processing not possible');
        for shuffle_id=1:length(shuffle_choice)
            shuffle_type{shuffle_id}.shuffled_track = run_shuffles(shuffle_choice{shuffle_id}, analysis_type,...
                                                                   num_shuffles, decoded_replay_events, place_fields_BAYESIAN, ...
                                                                   replayEvents_bayesian_spike_count, tracks_compared);
        end

    end
    
    save(globalPath + "shuffled_tracks.mat", "shuffle_type");
    
    % Evaluate significance
    scored_replay = replay_significance(scored_replay, shuffle_type);
    save(globalPath + "scored_replay", "scored_replay")
    
    %% Now we can analyse segments
    
    replay_decoding_split_events;
    
    
end

end