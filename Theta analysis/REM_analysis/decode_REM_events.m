% Decode each theta cycle using bayesian decoding
% Creates a file decoded_theta_events.mat with the same format as
% decoded_replay_events

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl;

for sID = 1:1 %numel(sessions)
    file = sessions{sID};

    % Load the data
    temp = load(file + "/REM/theta_peak_trough");
    allPeaks = temp.theta_peaks;
    temp = load(file+ "/extracted_sleep_state.mat");
    sleep_state = temp.sleep_state;

    % Generate the file "extracted_replay_events.mat"
    % We only gonna select theta phase during POST1

    startPOST1 = sleep_state.state_time.INTER_post_start;
    endPOST1 = sleep_state.state_time.INTER_post_end;

    validIDs = find(allPeaks(:, 4) >= startPOST1 & allPeaks(:, 4) <= endPOST1);

    replay.onset = allPeaks(validIDs, 4)';
    replay.offset = allPeaks(validIDs+1, 4)';

    if ~exist(file + "\REM\past_vs_futur", 'dir')
        mkdir(file + "\REM\past_vs_futur");
    end

    save(file + "/REM/past_vs_futur/extracted_replay_events.mat", "replay");

    % We also copy some files into this new folder
    copyfile(file + "\extracted_clusters.mat", file + "/REM/past_vs_futur/");
    copyfile(file + "\extracted_place_fields_BAYESIAN.mat", file + "/REM/past_vs_futur/");
    copyfile(file + "\extracted_position.mat", file + "/REM/past_vs_futur/");

    cd(file + "/REM/past_vs_futur/");

    % Now we can decode for each track the past vs. futur
    for trackOI = 1:2
        path2save = file + "/REM/past_vs_futur/" + "T" + trackOI + "_vs_T" + (trackOI + 2) + "/";

        if ~exist(path2save, 'dir')
            mkdir(path2save);
        end

        [decoded_replay_events, replayEvents_bayesian_spike_count] = replay_decoding([trackOI, trackOI + 2], path2save, "N");

        save(path2save + "decoded_replay_events.mat", "decoded_replay_events");
        save(path2save + "replayEvents_bayesian_spike_count.mat", "replayEvents_bayesian_spike_count");

    end
end

