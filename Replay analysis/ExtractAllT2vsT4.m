% Long analysis : extraction of all the replay events for T2 vs. T4

folders = data_folders_excl;
tracks_compared = [2, 4];

folders = folders(1:end);

replay_sequence_analysis(folders, tracks_compared, "balanced_analysis")