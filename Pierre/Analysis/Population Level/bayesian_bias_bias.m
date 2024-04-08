% Bayesian Bias analysis

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

mode = 1; % 1 - All events ; 2 - Significant RE ; 3 - NS RE
% Replay events are poled from exp vs. re-exp

% Initiate the final files

sessionID = [];
animal = [];
condition = [];
track = [];
replay_id = [];
replay_time = [];
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

    temp = load(file + "\Replay_T1_vs_T3\decoded_replay_events");
    decoded_replay_eventsT1 = temp.decoded_replay_events;

    temp = load(file + "\Replay_T2_vs_T4\decoded_replay_events");
    decoded_replay_eventsT2 = temp.decoded_replay_events;

    % Load sleep data
    temp = load(file + "\extracted_sleep_state");
    sleep_state = temp.sleep_state;

    % We get the start / end of POST1
    startTime = sleep_state.state_time.INTER_post_start;
    endTime = sleep_state.state_time.INTER_post_end;

    % We get all the sleep replay events during POST1
    sleepSWRID = getAllSleepReplay(1, startTime, endTime, decoded_replay_eventsT1, sleep_state);
    sleepID = sleepSWRID;
    
    for trackOI = 1:2

        if trackOI == 1
            decoded_replay_events = decoded_replay_eventsT1;
        else
            decoded_replay_events = decoded_replay_eventsT2;
        end

        % If mode ~= 1, we filter this ID list
        if mode == 2

            % We find all the significant replay events
            path2get = [file, '\Replay_T', num2str(trackOI), '_vs_T', num2str(trackOI + 2)];
            temp = load(path2get + "\significant_replay_events_wcorr");
            significant_replay_events = temp.significant_replay_events;
            good_ids = [significant_replay_events.track(1).ref_index, ...
                        significant_replay_events.track(2).ref_index];
            sleepID = intersect(sleepSWRID, good_ids);

        elseif mode == 3

            % We find all the significant replay events
            path2get = [file, '\Replay_T', num2str(trackOI), '_vs_T', num2str(trackOI + 2)];
            temp = load(path2get + "\significant_replay_events_wcorr");
            significant_replay_events = temp.significant_replay_events;
            good_ids = [significant_replay_events.track(1).ref_index, ...
                        significant_replay_events.track(2).ref_index];
            sleepID = setdiff(sleepSWRID, good_ids);

        end

        current_nbSWR = numel(sleepID);

        % We iterate through each replay event
        for rID = 1:current_nbSWR

            replayID = sleepID(rID);
            current_time = decoded_replay_events(1).replay_events(replayID).timebins_edges(1);
            current_time = current_time - decoded_replay_events(1).replay_events(sleepID(1)).timebins_edges(1)

            decodedPosExp = decoded_replay_events(1).replay_events(replayID).decoded_position;
            decodedPosReexp = decoded_replay_events(2).replay_events(replayID).decoded_position;

            bb = log10(sum(sum(decodedPosReexp))/sum(sum(decodedPosExp)));

            sessionID = [sessionID; fID];
            animal = [animal; animalOI];
            condition = [condition; conditionOI];
            track = [track; trackOI];
            replay_id = [replay_id; rID];
            replay_time = [replay_time; current_time];
            bayesian_bias = [bayesian_bias; bb];
        end

    end
end

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);
condition = str2double(condition);

data = table(sessionID, animal, condition, replay_id, replay_time, bayesian_bias);

%% Plot

boxchart(data.condition, data.bayesian_bias);
