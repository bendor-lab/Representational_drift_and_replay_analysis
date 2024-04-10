% Bayesian Bias analysis

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

mode = 2; % 1 - All events ; 2 - Significant RE ; 3 - NS RE
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
    [sleepSWRID, timeSWR] = getAllSleepReplay(1, startTime, endTime, decoded_replay_eventsT1, sleep_state);
    sleepID = sleepSWRID;
    timeRep = timeSWR;

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
            path2get = [file, '\Replay\RUN1_Decoding'];
            temp = load(path2get + "\significant_replay_events_wcorr");
            significant_replay_events = temp.significant_replay_events;
            % good_ids = [significant_replay_events.track(1).ref_index, ...
            %             significant_replay_events.track(2).ref_index];
            good_ids = significant_replay_events.track(1).ref_index;
            good_ids = significant_replay_events.track(trackOI - 1 + mod(trackOI, 2)*2).ref_index;
            sleepID = intersect(sleepSWRID, good_ids);
            timeRep = timeSWR(ismember(sleepSWRID, sleepID));

        elseif mode == 3

            % We find all the significant replay events
            path2get = [file, '\Replay_T', num2str(trackOI), '_vs_T', num2str(trackOI + 2)];
            temp = load(path2get + "\significant_replay_events_wcorr");
            significant_replay_events = temp.significant_replay_events;
            good_ids = [significant_replay_events.track(1).ref_index, ...
                significant_replay_events.track(2).ref_index];
            sleepID = setdiff(sleepSWRID, good_ids);
            timeRep = timeSWR(ismember(sleepSWRID, sleepID));

        end

        current_nbReplay = numel(sleepID);

        % We iterate through each replay event
        for rID = 1:current_nbReplay

            replayID = sleepID(rID);
            current_time = timeRep(rID);

            decodedPosExp = decoded_replay_events(1).replay_events(replayID).decoded_position;
            decodedPosReexp = decoded_replay_events(2).replay_events(replayID).decoded_position;

            bb = log10(sum(sum(decodedPosReexp))/sum(sum(decodedPosExp)));

            sessionID = [sessionID; fID];
            animal = [animal; animalOI];
            condition = [condition; conditionOI];
            track = [track; trackOI];
            replay_id = [replay_id; rID/current_nbReplay];
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

%% Stats - mixed model

fitlme(data, "bayesian_bias ~ condition + replay_time + (1|animal)")
fitlme(data, "bayesian_bias ~ condition + replay_id + (1|animal)")


%% Plot - scatter all points

scatter(data.replay_time, data.bayesian_bias);
grid on;

%% Plot - take the mean each 1 minutes

data.timeDisc = discretize(data.replay_time, 0:60:1800)*3 - 3;
boxchart(data.timeDisc, data.bayesian_bias);
grid on;

%% Plot separate for each animal
allAnimals = unique(animal);
allConditions = [1, 2, 3, 4, 8, 16];

for anID = 1:numel(allAnimals)
    figure;
    tiledlayout(3, 2)

    for cID = 1:numel(allConditions)
        current_data = data(data.animal == allAnimals(anID) ...
            & data.condition == allConditions(cID), :);

        nexttile;
        if allConditions(cID) == 16
            allSessions = unique(current_data.sessionID);
            for sID = 1:numel(allSessions)
                plot(current_data(current_data.sessionID == allSessions(sID), :).replay_time, ...
                     current_data(current_data.sessionID == allSessions(sID), :).bayesian_bias);
                hold on;
            end
            hold off;

        else
            plot(current_data.replay_time, current_data.bayesian_bias);
        end

        title("Condition : " + num2str(allConditions(cID)) + " laps")
        ylim([-1, 1])
        xlim([0, 1800])
    end

end

%%
figure;
scatter(data.replay_time(data.condition ~= 16), data.bayesian_bias(data.condition ~= 16))

figure;
scatter(data.replay_time(data.condition == 16), data.bayesian_bias(data.condition == 16))
