% Look at, for each session and track, the asymetry between first and
% second part of cumulative sleep

% Generate a table with animal, condition, stability at the end of RUN1,
% PV-correlation with the FPF and replay participation.

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths

% Arrays to hold all the data

sessionID = [];
animal = [];
condition = [];
track = [];

refinCorr = [];
propSec = []; % ratio of RE during the second part of cumulative sleep
amountSWS = [];
amountREM = [];
amountQuiet = [];
propSWSReplay = [];

time_in_sleep_T1 = [];
time_in_sleep_T2 = [];

for fileID = 1:length(sessions)

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

    temp = load(file + "\extracted_laps.mat");
    lap_times = temp.lap_times;


    % Track loop

    for trackOI = 1:2

        goodCells = intersect(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);

        % We get the replay participation

        % Fetch the significant replay events
        temp = load(file + "\Replay\RUN1_Decoding\significant_replay_events_wcorr");
        significant_replay_events = temp.significant_replay_events;

        temp = load(file + "\Replay\RUN1_Decoding\decoded_replay_events");
        decoded_replay_events = temp.decoded_replay_events;

        RE_current_track = significant_replay_events.track(trackOI);

        % Fetch the sleep times to filter POST1 replay events
        temp = load(file +  "/extracted_sleep_stages");
        sleep_state = temp.sleep_state;
        startTime = sleep_state.state_time.INTER_post_start;
        endTime = sleep_state.state_time.INTER_post_end;

        sleepSWRID = getAllSleepReplay(trackOI, startTime, endTime, decoded_replay_events, sleep_state, 120);
        current_nbSWR = numel(sleepSWRID);

        % We get the IDs of all the sleep replay events
        [goodIDCurrent, timeCurrent] = getAllSleepReplay(trackOI, startTime, endTime, significant_replay_events, sleep_state, 120);

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

        pvCorRUN1 = getPVCor(goodCells, RUN1LapPFData{end}.smooth, finalPlaceField, "pvCorrelation");
        pvCorRUN2 = getPVCor(goodCells, RUN2LapPFData{1}.smooth, finalPlaceField, "pvCorrelation");

        current_refinement = median(pvCorRUN2, 'omitnan') - median(pvCorRUN1, 'omitnan');
        
        current_ratio = sum(timeCurrent > 0.5)/numel(timeCurrent);

        current_amount_sws = sum(sleep_state.sleep_stages.sws);
        current_amount_rem = sum(sleep_state.sleep_stages.rem);
        current_amount_quiet = sum(sleep_state.sleep_stages.quiet_wake);
        %% Proportion of replay events during SWS
        goodTimeReplay = significant_replay_events.track(trackOI).event_times(goodIDCurrent);

        histSWSReplay = histcounts(goodTimeReplay, [sleep_state.sleep_stages.t_sec ...
                                                    sleep_state.sleep_stages.t_sec(end)+1]);

        propSWSRep = sum(histSWSReplay(~~sleep_state.sleep_stages.sws))/...
                     sum(histSWSReplay);   

        % Save the data
        
        sessionID = [sessionID; fileID];
        animal = [animal; animalOI];
        condition = [condition; conditionOI];
        track = [track; trackOI];
        refinCorr = [refinCorr; current_refinement];
        propSec = [propSec; current_ratio];
        amountSWS = [amountSWS; current_amount_sws];
        amountREM = [amountREM; current_amount_rem];
        amountQuiet = [amountQuiet; current_amount_quiet];
        propSWSReplay = [propSWSReplay; propSWSRep];

        for rID = 1:numel(timeCurrent)
            current_time = timeCurrent(rID);
            if trackOI == 1
                time_in_sleep_T1(end + 1) = current_time;
            else
                time_in_sleep_T2(end + 1) = current_time;
            end
        end


    end
end

% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

data = table(sessionID, animal, condition, refinCorr, propSec, amountSWS, amountREM, propSWSReplay);

%%

data.logCondC = log2(data.condition) - mean(log2(data.condition));
data.propSWSReplayC = data.propSWSReplay - mean(data.propSWSReplay);
data.propREM = data.amountREM./(data.amountREM + data.amountSWS);
data.propREMC = data.propREM - mean(data.propREM);

mod1 = fitlme(data, "refinCorr ~ logCondC + propSWSReplayC + (1|animal) + (1|sessionID:animal)")

mod1 = fitlme(data, "refinCorr ~ logCondC * propREM + (1|animal) + (1|sessionID:animal)")


scatter(data.propSWSReplay, data.refinCorr);

%%

figure;
histogram(time_in_sleep_T1, 100)

figure;
histogram(time_in_sleep_T2, 100)
