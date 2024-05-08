% Plot the mean bayesian bias of the theta cycles in each session
% Bayesian bias is between RUN1 and RUN2 of the same track.

% Look at the difference in bayesian bias dynamics between
% sleep and awake - rest

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

% Initiate the final files

sessionID = [];
animal = [];
condition = [];
track = [];
cycleID = [];
cycleTime = [];
bayesian_bias = [];

% For each session

parfor fID = 1:length(sessions)

    file = sessions{fID};
    disp(fID);

    % Parse the name to get infos
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    animalOI = string(animalOI);
    conditionOI = string(conditionOI);
    disp(conditionOI);

    % We load all the put. rep. ev EXP vs. REEXP

    temp = load(file + "\REM\past_vs_futur\T1_vs_T3\decoded_replay_events");
    decoded_replay_eventsT1 = temp.decoded_replay_events;

    temp = load(file + "\REM\past_vs_futur\T2_vs_T4\decoded_replay_events");
    decoded_replay_eventsT2 = temp.decoded_replay_events;

    % Load sleep data
    temp = load(file + "\extracted_sleep_state");
    sleep_state = temp.sleep_state;

    % We get the start / end of POST1
    startTime = sleep_state.state_time.INTER_post_start;
    endTime = sleep_state.state_time.INTER_post_end;

    % We get all the sleep replay events during POST1
    [sleepSWRID, timeSWR] = getAllSleepReplay(1, startTime, endTime, decoded_replay_eventsT1, sleep_state);
    sleepID = sleepSWRID;
    timeRep = timeSWR;

    for trackOI = 1:2

        if trackOI == 1
            decoded_replay_events = decoded_replay_eventsT1;
        else
            decoded_replay_events = decoded_replay_eventsT2;
        end

        bigTimes = sleep_state.time;

        isSleeping = sleep_state.state_binned;
        isSleeping(isSleeping == -1) = 0;
        isSleeping = logical(isSleeping);

        if sum(sleep_state.REM_idx & isSleeping) == 0
            continue; % If no POST1 REM, we pass
        end

        allReplayTimes = cellfun(@(a) a(1),...
            {decoded_replay_events(1).replay_events.timebins_edges});

        allReplayTimes = allReplayTimes(sleepID);

        current_quantity_rem = sum(sleep_state.REM_idx & isSleeping & ...
            (sleep_state.time >= startTime) & (sleep_state.time <= endTime));

        goodREMIDs = [];
        goodTimes = []; % cumulative REM time

        isRem = sleep_state.REM_idx & isSleeping;
        timeVector = sleep_state.time(1):0.020:sleep_state.time(end)+59.980;
        fulRemVector = [];

        for i = 1:numel(isRem)
            if isRem(i) == 0
                fulRemVector = [fulRemVector repelem(0, 3000)];
            else
                fulRemVector = [fulRemVector repelem(1/3000, 3000)];
            end
        end

        fulRemVectorCum = cumsum(fulRemVector);

        for reID = 1:numel(allReplayTimes)
            histReplay = histcounts(allReplayTimes(reID), [bigTimes bigTimes(end) + 60]);

            histReplay(~isRem) = 0;

            % histReplaySleep = histReplay(sleep_state.time <= endTime & sleep_state.time >= startTime);
            % Useless bc for now, only POST1 cycles are analyzed

            if any(histReplay) % If during REM
                goodREMIDs(end + 1) = sleepID(reID);

                % We get the cumulative rem time
                eventTime = allReplayTimes(reID);
                curr_cumRemTime = fulRemVectorCum(timeVector >= eventTime & timeVector <= eventTime + 0.020);
                goodTimes(end + 1) = curr_cumRemTime;
            end
        end

        current_nbCycles = numel(goodREMIDs);

        % We iterate through each REM cycle

        for rID = 1:current_nbCycles

            replayID = goodREMIDs(rID);
            current_time = goodTimes(rID);

            decodedPosExp = decoded_replay_events(1).replay_events(replayID).decoded_position;
            decodedPosReexp = decoded_replay_events(2).replay_events(replayID).decoded_position;

            bb = log10(sum(sum(decodedPosReexp))/sum(sum(decodedPosExp)));

            sessionID = [sessionID; fID];
            animal = [animal; animalOI];
            condition = [condition; conditionOI];
            track = [track; trackOI];
            cycleID = [cycleID; replayID];
            cycleTime = [cycleTime; current_time];
            bayesian_bias = [bayesian_bias; bb];

        end

    end
end

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);
condition = str2double(condition);

data = table(sessionID, animal, condition, cycleID, cycleTime, bayesian_bias);

%%

dataFilt = data;
dataFilt.bbz = (dataFilt.bayesian_bias - mean(dataFilt.bayesian_bias, 'omitnan'))/std(dataFilt.bayesian_bias, 'omitnan');
dataFilt(abs(dataFilt.bbz) <= 1, :) = [];
dataFilt(isnan(dataFilt.bbz), :) = [];