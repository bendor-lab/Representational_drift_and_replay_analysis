% Generate new sleep stages for each animals
clear

sessions = data_folders_excl;
sessions_leg = data_folders_excl_legacy;

for current_session = 1:numel(sessions)

    file = sessions{current_session};
    file_leg = sessions_leg{current_session};

    % Loading what we need
    load(file + "\extracted_sleep_state");
    load(file + "\extracted_position"); % Speed data
    load(file_leg + "\extracted_CSC"); % HP LFP
    threshold_speed = 4; % > 4 cm.s.-1 -> not sleep

    HC_LFP = CSC(string({CSC.channel_label}) == "best_theta").CSCraw; % LFP from
    % best theta channel
    HC_LFP_times = CSC(string({CSC.channel_label}) == "best_theta").CSCtime;
    HC_LFP_data = [HC_LFP_times HC_LFP]; % time / value format

    speed_data = [position.t' position.v_cm']; % good format speed data
    freq = mean(diff(speed_data(:, 1)));
    % Smooth speed with 1 second gaussian filter
    speed_data(:, 2) = smoothdata(speed_data(:, 2), "gaussian", 1/freq);

    % We run the stager
    [freezing, quietWake, SWS, REM] = detect_behavioural_states_masa([], HC_LFP_data, speed_data, threshold_speed);

    % Now we convert the data obtained to second per second state vectors

    time = HC_LFP_times(1):1:HC_LFP_times(end);
    isQuietWake = repelem(0, numel(time));
    isSWS = repelem(0, numel(time));
    isREM = repelem(0, numel(time));

    for i = 1:numel(quietWake(:, 1))
        current_interval = quietWake(i, :);
        isQuietWake(time >= current_interval(1) & time <= current_interval(2)) = 1;
    end

    for i = 1:numel(SWS(:, 1))
        current_interval = SWS(i, :);
        isSWS(time >= current_interval(1) & time <= current_interval(2)) = 1;
    end

    for i = 1:numel(REM(:, 1))
        current_interval = REM(i, :);
        isREM(time >= current_interval(1) & time <= current_interval(2)) = 1;
    end

    stages.t_sec = time;
    stages.quiet_wake = isQuietWake;
    stages.sws = isSWS;
    stages.rem = isREM;

    sleep_state.sleep_stages = stages;

    save(file + "/extracted_sleep_stages", "sleep_state")

end
