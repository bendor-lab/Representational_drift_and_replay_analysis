% Generate a table with animal, condition, stability at the end of RUN1,
% PV-correlation with the FPF and replay participation.

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths

% Arrays to hold all the data

animal = [];
condition = [];
track = [];

refinCorr = [];
corrEndRUN1 = [];

partP1Rep = [];

parfor fileID = 1:length(sessions)

    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string


    % Load the variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;

    % Track loop

    for trackOI = 1:2

        % Good cells : cells that become good place cells on RUN2
        goodCells = place_fields.track(trackOI + 2).good_cells;

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

        nbReplayEvents = numel(goodIDCurrent);

        % We get the final place field : mean of the 6 laps following the
        % 16th lap of RUN2

        RUN1LapPFData = lap_place_fields(trackOI).Complete_Lap;
        RUN2LapPFData = lap_place_fields(trackOI + 2).Complete_Lap;

        numberLapsRUN2 = length(RUN2LapPFData);

        finalPlaceField = {};

        % For each cell, we create the final place field
        for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
            temp = [];

            for lap = 1:6
                temp = [temp; RUN2LapPFData{16 + lap}.smooth{cellID}];
            end

            finalPlaceField(end + 1) = {mean(temp, 'omitnan')};
        end

        % We can now find the PV correlation of the last lap RUN1 and first
        % lap RUN2 with the FPF

        pvCorRUN1 = getPVCor(goodCells, RUN1LapPFData{end}.smooth, finalPlaceField, "pvCorrelation");
        pvCorRUN1 = median(pvCorRUN1, 'omitnan');

        pvCorRUN2 = getPVCor(goodCells, RUN2LapPFData{1}.smooth, finalPlaceField, "pvCorrelation");
        pvCorRUN2 = median(pvCorRUN2, 'omitnan');

        current_refinement = pvCorRUN2 - pvCorRUN1;

        % Save the data

        animal = [animal; animalOI];
        condition = [condition; conditionOI];
        track = [track; trackOI];
        refinCorr = [refinCorr; current_refinement];
        corrEndRUN1 = [corrEndRUN1; pvCorRUN1];
        partP1Rep = [partP1Rep; nbReplayEvents];

    end
end

% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

data = table(animal, condition, refinCorr, corrEndRUN1, partP1Rep);

save("dataRegressionPop.mat", "data")