% Generate the data for regressions
% Related to the directionality of the cell

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths

% We create identifiers for cells from each session.
% Format is : IDENT-00-XXX
identifiers = 1:numel(sessions);
identifiers = identifiers* 1000;

% Arrays to hold all the data

animal = [];
condition = [];
track = [];
cell = [];

refinDir = [];

partP1Rep = [];
propPartRep = []; % % of replay participated in


%% Extraction & computation

for fileID = 1:length(sessions)

    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    ident = identifiers(fileID); % We get the identifier for the session

    % Load the variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_directional_lap_place_fields.mat");
    lap_directional_place_fields = temp.lap_directional_place_fields;

    temp = load(file + "\extracted_directional_place_fields.mat");
    directional_place_fields = temp.directional_place_fields;

    temp = load(file + "\extracted_laps.mat");
    lap_times = temp.lap_times;

    % Track loop

    for trackOI = 1:2

        % Good cells : Cells that where good place cells during RUN1 / RUN2
        goodCells = union(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);

        % We get the replay participation

        % Fetch the significant replay events
        temp = load(file + "\Replay\RUN1_Decoding\significant_replay_events_wcorr");
        significant_replay_events = temp.significant_replay_events;

        RE_current_track = significant_replay_events.track(trackOI);

        % Fetch the sleep times to filter POST1 replay events
        temp = load(file +  "/extracted_sleep_state");
        sleep_state = temp.sleep_state;
        startTime = sleep_state.state_time.INTER_post_start;
        endTime = sleep_state.state_time.INTER_post_end;

        % We get the IDs of all the sleep replay events
        goodIDCurrent = getAllSleepReplay(trackOI, startTime, endTime, significant_replay_events, sleep_state);

        nbReplay = numel(goodIDCurrent);

        filteredReplayEventsSpikesCurrent = RE_current_track.spikes(goodIDCurrent);

        % We get the place fields in each direction at each lap
        RUN1LapDataDir1 = lap_directional_place_fields(trackOI).dir1.Complete_Lap;
        RUN1LapDataDir2 = lap_directional_place_fields(trackOI).dir2.Complete_Lap;
        RUN2LapDataDir1 = lap_directional_place_fields(trackOI + 2).dir1.Complete_Lap;
        RUN2LapDataDir2 = lap_directional_place_fields(trackOI + 2).dir2.Complete_Lap;

        % VERIFICATIONS :
        % 1. If the starting direction is different at the begginning of
        % RUN1 and RUN2, we will take the opposite of the RUN2
        % directionnality (to restore inbound / outbound order)

        startDirRUN1 = lap_times(trackOI).initial_dir;
        startDirRUN2 = lap_times(trackOI + 2).initial_dir;

        if startDirRUN1 ~= startDirRUN2
            correctionDir = -1;
        else
            correctionDir = 1;
        end

        % 2. If number of half lap is odd, we remove one and we
        % cut the data we just registered

        nbHalfLapsRUN1 = numel(lap_times(trackOI).halfLaps_start);
        nbHalfLapsRUN2 = numel(lap_times(trackOI + 2).halfLaps_start);

        nbHalfLapsRUN1 = nbHalfLapsRUN1 - mod(nbHalfLapsRUN1, 2);
        nbHalfLapsRUN2 = nbHalfLapsRUN2 - mod(nbHalfLapsRUN2, 2);

        RUN1LapDataDir1 = RUN1LapDataDir1(1:nbHalfLapsRUN1/2);
        RUN1LapDataDir2 = RUN1LapDataDir2(1:nbHalfLapsRUN1/2);
        RUN2LapDataDir1 = RUN2LapDataDir1(1:nbHalfLapsRUN2/2);
        RUN2LapDataDir2 = RUN2LapDataDir2(1:nbHalfLapsRUN2/2);

        numberLapsRUN2 = length(nbHalfLapsRUN2/2);

        % We get the final place field : mean of the 6 laps following the
        % 16th lap of RUN2
        % Here, we compute the FPF for each direction

        finalPlaceFieldDir1 = {};
        finalPlaceFieldDir2 = {};

        % For each cell, we create the final place field
        for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
            temp = [];
            temp2 = [];

            for lap = 1:5
                temp = [temp; RUN2LapDataDir1{16 + lap}.smooth{cellID}];
                temp2 = [temp2; RUN2LapDataDir2{16 + lap}.smooth{cellID}];
            end

            finalPlaceFieldDir1(end + 1) = {mean(temp, 'omitnan')};
            finalPlaceFieldDir2(end + 1) = {mean(temp2, 'omitnan')};
        end

        % Here, we compute the directionnality of each cell as being the
        % difference over sum of the max of the place field in direction
        % 1 vs. 2. 1 is totally directional in dir 1, -1 is reverse.

        dirFPF = cellfun(@(x, y) correctionDir*(max(x) - max(y))/(max(x) + max(y)), finalPlaceFieldDir1, finalPlaceFieldDir2);

        % Cell loop
        for cellID = 1:length(goodCells)

            cellOI = goodCells(cellID);

            endRUN1Dir1 = RUN1LapDataDir1{end}.smooth{cellOI};
            endRUN1Dir2 = RUN1LapDataDir2{end}.smooth{cellOI};

            startRUN2Dir1 = RUN2LapDataDir1{end}.smooth{cellOI};
            startRUN2Dir2 = RUN2LapDataDir2{end}.smooth{cellOI};

            endRUN1Direc = correctionDir*(max(endRUN1Dir1) - max(endRUN1Dir2))/(max(endRUN1Dir1) + max(endRUN1Dir2));
            startRUN2Direc = correctionDir*(max(startRUN2Dir1) - max(startRUN2Dir2))/(max(startRUN2Dir1) + max(startRUN2Dir2));

            endRUN1DistFPF = abs(dirFPF(cellOI) - endRUN1Direc);
            startRUN2DistFPF = abs(dirFPF(cellOI) - startRUN2Direc);

            current_refinDir = endRUN1DistFPF - startRUN2DistFPF;

            % We get the replay participation of the cell - in nb of events
            replayInvolvedCurrent = cellfun(@(ev) any(ev(:, 1) == cellOI), filteredReplayEventsSpikesCurrent);
            current_partP1Rep = sum(replayInvolvedCurrent);
            current_propPart = current_partP1Rep/nbReplay;

            % Save the data

            animal = [animal; animalOI];
            condition = [condition; conditionOI];
            track = [track; trackOI];
            cell = [cell; cellOI];
            refinDir = [refinDir; current_refinDir];
            partP1Rep = [partP1Rep; current_partP1Rep];
            propPartRep = [propPartRep; current_propPart]; % % of replay participated in


        end
    end
end



% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

data = table(animal, condition, cell, refinDir, partP1Rep, propPartRep);

save("dataRegressionDirectionality.mat", "data")