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
mean_bayesian_bias = [];
quantity_rem = [];
std_bayesian_bias = [];

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

        allReplayTimes = cellfun(@(a) a(1),...
                             {decoded_replay_events(1).replay_events.timebins_edges});

        allReplayTimes = allReplayTimes(sleepID);

        current_quantity_rem = sum(sleep_state.REM_idx & isSleeping & ...
            (sleep_state.time >= startTime) & (sleep_state.time <= endTime));

        goodREMIDs = [];

        for reID = 1:numel(allReplayTimes)
            histReplay = histcounts(allReplayTimes(reID), [bigTimes bigTimes(end) + 60]);
            isRem = sleep_state.REM_idx;
            % isRem = circshift(isRem, 1);

            histReplay(~isRem) = 0;
            histReplay(~isSleeping) = 0;
            % histReplaySleep = histReplay(sleep_state.time <= endTime & sleep_state.time >= startTime);
            % Useless bc for now, only POST1 cycles are analyzed

            if any(histReplay) % If during REM
                goodREMIDs(end + 1) = sleepID(reID);
            end
        end
        
        current_nbCycles = numel(goodREMIDs);

        % We iterate through each REM cycle

        all_bb = [];

        for rID = 1:current_nbCycles

            replayID = goodREMIDs(rID);

            decodedPosExp = decoded_replay_events(1).replay_events(replayID).decoded_position;
            decodedPosReexp = decoded_replay_events(2).replay_events(replayID).decoded_position;

            bb = log10(sum(sum(decodedPosReexp))/sum(sum(decodedPosExp)));
            all_bb(end + 1) = bb;

        end

        figure;
        plot(all_bb)

        current_mean_bb = mean(all_bb, 'omitnan');
        current_std_bb = std(all_bb, 'omitnan');

        sessionID = [sessionID; fID];
        animal = [animal; animalOI];
        condition = [condition; conditionOI];
        track = [track; trackOI];
        mean_bayesian_bias = [mean_bayesian_bias; current_mean_bb];
        std_bayesian_bias = [std_bayesian_bias; current_std_bb];
        quantity_rem = [quantity_rem; current_quantity_rem];

    end
end

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);
condition = str2double(condition);

data = table(sessionID, animal, condition, mean_bayesian_bias, std_bayesian_bias, quantity_rem);

%%

all_bb_z = (all_bb - mean(all_bb, 'omitnan'))/std(all_bb, 'omitnan');
all_good = find(all_bb_z > 3);

for g = 1:numel(all_good)
    figure;
    imagesc(decoded_replay_events(2).replay_events(all_good(g)).decoded_position)
end