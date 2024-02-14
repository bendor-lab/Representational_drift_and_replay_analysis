% New function to analyse and score replay events

function [] = replay_sequence_analysis(folders, tracks_compared)

% INPUT : List of data folders to run the analysis, array of tracks we
% want to compare during bayesian decoding (across track normalisation)
% OUTPUT : None, creation of a folder with all the relevant files in it
% Loads : extracted_place_fields_BAYESIAN.mat

% Global analysis variables --

clear

% Types of scoring we want to run
% [linear wcorr path spearman]
scoringType = [0 1 0 0];

% Number of shuffles to do for each method
num_shuffles = 4;

% Choosing the type of shuffle we want to execute num_shuffles times
shuffle_choice = {'PRE spike_train_circular_shift','PRE place_field_circular_shift', 'POST place bin circular shift'};

for folderID = 1:length(folders)
    
    folder = folders{folderID};
    
    % For tests
    folder = data_folders_excl;
    folder = folder{1};
    tracks_compared = [1, 3];
    
    cd(folder);
    
    % We find the name of the current folder comparison
    
    formatted_strings = arrayfun(@(x) sprintf('T%d', x), tracks_compared, 'UniformOutput', false);
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

    save(globalPath + "decoded_replay_events.mat", "decoded_replay_events");
    save(globalPath + "replayEvents_bayesian_spike_count.mat", "replayEvents_bayesian_spike_count");
    
    %% Score the replay events
    disp('Scoring replay events')
    scored_replay = replay_scoring(decoded_replay_events, place_fields_BAYESIAN, scoringType);
    
    %% Shuffles
    
    disp("Starting shuffles")
        
    p = gcp; % Starting new parallel pool
    
    shuffle_type = [];
        
    % Trying to start a parallel pool, otherwise classical computation
    % Add the num_shuffles shuffled scores to the shuffle_type object
    
    if ~isempty(p)
        for shuffle_id=1:length(shuffle_choice)
            shuffle_type{shuffle_id}.shuffled_track = parallel_shuffles(shuffle_choice{shuffle_id}, scoringType, ...
                                                                        num_shuffles, decoded_replay_events, place_fields_BAYESIAN, ...
                                                                        replayEvents_bayesian_spike_count, tracks_compared);
        end
    else
        disp('Parallel processing not possible');
        for shuffle_id=1:length(shuffle_choice)
            shuffle_type{shuffle_id}.shuffled_track = run_shuffles(shuffle_choice{shuffle_id}, scoringType,...
                                                                   num_shuffles, decoded_replay_events, place_fields_BAYESIAN, ...
                                                                   replayEvents_bayesian_spike_count, tracks_compared);
        end

    end
    
    save(globalPath + "shuffled_tracks.mat", "shuffle_type");
    
    % Evaluate significance
    scored_replay = replay_significance(scored_replay, shuffle_type);
    save(globalPath + "scored_replay", "scored_replay")
    
    %% Now we can analyse segments
    
    load("extracted_replay_events"); % Load the structure replay
    
    % We get the array of splitted events at the middle
    [decoded_replay_events1, decoded_replay_events2] = replay_decoding_split_events(decoded_replay_events, replay);
    % We save decoded_replay_events_segments
    save(globalPath + "decoded_replay_events_segments.mat", "decoded_replay_events1", "decoded_replay_events2");
    
    % We score each event
    scored_replay1 = replay_scoring(decoded_replay_events1, place_fields_BAYESIAN, scoringType);
    scored_replay2 = replay_scoring(decoded_replay_events2, place_fields_BAYESIAN, scoringType);

    save(globalPath + "scored_replay_segments.mat", "scored_replay1", "scored_replay2");
    
    % Initiate objects to hold shuffled segments
    shuffle_type1 = [];
    shuffle_type2 = [];

    p = gcp; % Starting new parallel pool

    if ~isempty(p)
        for shuffle_id=1:length(shuffle_choice)
            shuffle_type1{shuffle_id}.shuffled_track = parallel_shuffles(shuffle_choice{shuffle_id}, scoringType, ...
                                                                        num_shuffles, decoded_replay_events1, place_fields_BAYESIAN, ...
                                                                        replayEvents_bayesian_spike_count, tracks_compared);
                                                                    
            shuffle_type2{shuffle_id}.shuffled_track = parallel_shuffles(shuffle_choice{shuffle_id}, scoringType, ...
                                                                        num_shuffles, decoded_replay_events2, place_fields_BAYESIAN, ...
                                                                        replayEvents_bayesian_spike_count, tracks_compared);
        end
    else
        disp('Parallel processing not possible');
        for shuffle_id=1:length(shuffle_choice)
            shuffle_type1{shuffle_id}.shuffled_track = run_shuffles(shuffle_choice{shuffle_id}, scoringType,...
                                                                   num_shuffles, decoded_replay_events1, place_fields_BAYESIAN, ...
                                                                   replayEvents_bayesian_spike_count, tracks_compared);
                                                               
            shuffle_type2{shuffle_id}.shuffled_track = run_shuffles(shuffle_choice{shuffle_id}, scoringType,...
                                                                   num_shuffles, decoded_replay_events2, place_fields_BAYESIAN, ...
                                                                   replayEvents_bayesian_spike_count, tracks_compared);                                                 
        end
    end
    
    % We save 
    save(globalPath + "shuffled_tracks_segments.mat", "shuffle_type1", "shuffle_type2");
    
    %We get the score of each segment
    scored_replay1 = replay_significance(scored_replay1, shuffle_type1);
    scored_replay2 = replay_significance(scored_replay2, shuffle_type2);
    
    % We save
    save(globalPath + "scored_replay_segments.mat", "scored_replay1", "scored_replay2");
    
    % Generate the significant replay events file - saves the file in the
    % function
    
    significant_replay_events = number_of_significant_replays_new(0.05, 3, "wcorr", tracks_compared, globalPath);
    
end

end