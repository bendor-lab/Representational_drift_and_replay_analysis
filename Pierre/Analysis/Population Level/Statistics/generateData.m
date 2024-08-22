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
corrEndRUN1 = [];

partP1Rep = [];
numberSWR = [];
expReexpBias = [];
SWS_replay_prop = [];

amountSleep = [];
amountRem = [];
amountSWS = [];
amountQuiet = [];

nbSpikesBefREM = [];
nbSpikesAfREM = [];

heatmap_refinement_T1 = [];
heatmap_refinement_T2 = [];

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

    % temp = load(file + "\extracted_directional_lap_place_fields");
    % lap_directional_place_fields = temp.lap_directional_place_fields;

    % Track loop

    for trackOI = 1:2

        % Good cells : cells that become good place cells on RUN2
        % goodCells = union(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);
        % goodCells = intersect(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);
          goodCells = place_fields.interneurons;
          
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

        sleepSWRID = getAllSleepReplay(trackOI, startTime, endTime, decoded_replay_events, sleep_state);
        current_nbSWR = numel(sleepSWRID);

        % We get the IDs of all the sleep replay events
        goodIDCurrent = getAllSleepReplay(trackOI, startTime, endTime, significant_replay_events, sleep_state);

        nbReplayEvents = numel(goodIDCurrent);

        % We get the amount of time slept
        % RN, the proportion of REM sleep

        current_amount_sleep = sum(sleep_state.state_binned == 1 & ...
                                  sleep_state.time <= endTime & ...
                                  sleep_state.time >= startTime);

        current_amount_rem = sum(sleep_state.sleep_stages.rem == 1 & ...
                                  sleep_state.sleep_stages.t_sec <= endTime & ...
                                  sleep_state.sleep_stages.t_sec >= startTime)/60;

        current_amount_sws = sum(sleep_state.sleep_stages.sws == 1 & ...
                                  sleep_state.sleep_stages.t_sec <= endTime & ...
                                  sleep_state.sleep_stages.t_sec >= startTime)/60;

        current_amount_quiet = sum(sleep_state.sleep_stages.quiet_wake == 1 & ...
                                  sleep_state.sleep_stages.t_sec <= endTime & ...
                                  sleep_state.sleep_stages.t_sec >= startTime)/60;
        

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

        % % IF USING DIRECTIONAL
        % 
        % % Check 1 - We check if the number of complete laps is correct --
        % nbLapsRUN1 = numel(lap_directional_place_fields(trackOI).dir1.half_Lap) - ...
        %              mod(numel(lap_directional_place_fields(trackOI).dir1.half_Lap), 2);
        % nbLapsRUN1 = nbLapsRUN1/2;
        % 
        % pfDir1RUN1 = lap_directional_place_fields(trackOI).dir1.Complete_Lap{nbLapsRUN1};
        % pfDir2RUN1 = lap_directional_place_fields(trackOI).dir2.Complete_Lap{nbLapsRUN1};
        % 
        % 
        % pfDir1RUN2 = lap_directional_place_fields(trackOI + 2).dir1.Complete_Lap{1};
        % pfDir2RUN2 = lap_directional_place_fields(trackOI + 2).dir2.Complete_Lap{1};
        % 
        % directionalityRUN1 = getPVCor(goodCells, pfDir1RUN1.smooth, pfDir2RUN1.smooth, "pvCorrelation");
        % directionalityRUN2 = getPVCor(goodCells, pfDir1RUN2.smooth, pfDir2RUN2.smooth, "pvCorrelation");
        % 
        % current_refinement = median(directionalityRUN2, "omitnan") - ...
        %                      median(directionalityRUN1, "omitnan");
        % 
        % % We can now find the PV correlation of the last lap RUN1 and first
        % % lap RUN2 with the FPF
        % 

        pvCorRUN1 = getPVCor(goodCells, RUN1LapPFData{end}.smooth, finalPlaceField, "pvCorrelation");

        pvCorRUN2 = getPVCor(goodCells, RUN2LapPFData{1}.smooth, finalPlaceField, "pvCorrelation");

        current_refinement = median(pvCorRUN2, 'omitnan') - median(pvCorRUN1, 'omitnan');
        
        if trackOI == 1
            heatmap_refinement_T1{end + 1} = pvCorRUN2 - pvCorRUN1;
        else
            heatmap_refinement_T2{end + 1} = pvCorRUN2 - pvCorRUN1;
        end

        % Get all the sleep replay Exposure vs. Re-exposure

        track_label = ['Replay_T', int2str(trackOI), '_vs_T', int2str(trackOI + 2)];
        % temp = load(file + "\balanced_analysis\one_lap_all\" + track_label + "\significant_replay_events_wcorr");
        temp = load(file + "\" + track_label + "\significant_replay_events_wcorr");
        Exp_Rexp = temp.significant_replay_events;

        replayExpSleep = getAllSleepReplay(1, startTime, endTime, Exp_Rexp, sleep_state);
        replayReexpSleep = getAllSleepReplay(2, startTime, endTime, Exp_Rexp, sleep_state);

        commonReplayID = intersect(Exp_Rexp.track(1).ref_index(replayExpSleep), ...
                                 Exp_Rexp.track(2).ref_index(replayReexpSleep));

        disp("X :" + numel(commonReplayID))

        replayExpSleep = replayExpSleep(~ismember(Exp_Rexp.track(1).ref_index(replayExpSleep), commonReplayID));
        replayReexpSleep = replayReexpSleep(~ismember(Exp_Rexp.track(2).ref_index(replayReexpSleep), commonReplayID));

        nbfiltExpRepSpikes = numel(Exp_Rexp.track(1).spikes(replayExpSleep));
        nbfiltReexpRepSpikes = numel(Exp_Rexp.track(2).spikes(replayReexpSleep));

        ratioReexp = (nbfiltReexpRepSpikes - nbfiltExpRepSpikes)/...
                     (nbfiltReexpRepSpikes + nbfiltExpRepSpikes);

        % Get the number of replay events during REM
        temp = load(file + "\Replay\RUN1_Decoding\significant_replay_events_wcorr");
        RE_T1vsT2 = temp.significant_replay_events;

        allTimesCurrent = RE_T1vsT2.track(trackOI).event_times;
        
        timesSleeping = sleep_state.time;
        histReplaySleep = histcounts(allTimesCurrent, [timesSleeping - 30 timesSleeping(end) + 30]);

        isSleeping = sleep_state.state_binned;
        isSleeping(isSleeping == -1) = 0;
        isSleeping = logical(isSleeping);

        number_sleep_replay = sum(histReplaySleep(isSleeping & sleep_state.time <= endTime & ...
                                                  sleep_state.time >= startTime));
        
        bigTimes = sleep_state.sleep_stages.t_sec;
        histReplay = histcounts(allTimesCurrent, [bigTimes bigTimes(end) + 1]);
        isSWS = sleep_state.sleep_stages.sws;
        histReplay(~isSWS) = 0;
        histReplay = histReplay(sleep_state.time <= endTime & ...
                                sleep_state.time >= startTime);

        current_RE_SWS = sum(histReplay)/number_sleep_replay;

        % Get the quantity of replay one minut before REM and one minut
        % after

        current_before_rem = [];
        current_after_rem = [];

        for re = 1:numel(allTimesCurrent(goodIDCurrent))
            current_time = allTimesCurrent(re);
            current_second = find(bigTimes <= current_time & bigTimes + 1 >= current_time);

            if current_second - 120 < 1 | current_second + 120 > numel(bigTimes)
                continue;
            end
            
            if any(sleep_state.sleep_stages.sws(current_second-60:current_second))
                current_before_rem(end + 1) = re;
            end

            if any(sleep_state.sleep_stages.sws(current_second:current_second+60))
                current_after_rem(end + 1) = re;
            end
        end

        % Save the data
        
        sessionID = [sessionID; fileID];
        animal = [animal; animalOI];
        condition = [condition; conditionOI];
        track = [track; trackOI];
        refinCorr = [refinCorr; current_refinement];

        corrEndRUN1 = [corrEndRUN1; median(pvCorRUN1, 'omitnan')];
        partP1Rep = [partP1Rep; nbReplayEvents];
        numberSWR = [numberSWR; current_nbSWR];
        expReexpBias = [expReexpBias; ratioReexp];
        SWS_replay_prop = [SWS_replay_prop; current_RE_SWS];

        amountSleep = [amountSleep; current_amount_sleep];
        amountRem = [amountRem; current_amount_rem];
        amountSWS = [amountSWS; current_amount_sws];
        amountQuiet = [amountQuiet; current_amount_quiet];

        nbSpikesBefREM = [nbSpikesBefREM; numel(current_before_rem)];
        nbSpikesAfREM = [nbSpikesAfREM; numel(current_after_rem)];


    end
end

% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

data = table(sessionID, animal, condition, refinCorr, corrEndRUN1, ...
             partP1Rep, numberSWR, expReexpBias, SWS_replay_prop, ...
             amountSleep, amountRem, amountSWS, amountQuiet, ...
             nbSpikesBefREM, nbSpikesAfREM);

save("interneuronsPV.mat", "data")

%%

% allT1 = cat(1, heatmap_refinement_T1{:});
% meanAllT1 = mean(allT1, 'omitnan');
% 
% allT2 = cat(1, heatmap_refinement_T2{:});
% meanAllT2 = mean(allT2, 'omitnan');
% 
% plot(1:2:200, meanAllT1, 'b');
% hold on;
% plot(1:2:200, meanAllT2, 'r');

%%

load("dataRegressionPop.mat")

data.logConditionC = log2(data.condition) - mean(log2(data.condition), 'omitnan');
data.propBefore = data.nbSpikesBefREM ./ data.partP1Rep;
data.propAfter = data.nbSpikesAfREM ./ data.partP1Rep;


lme = fitlme(data(data.condition ~= 16, :), 'refinCorr ~ logConditionC + propBefore + propAfter + (1|animal) + (1|sessionID:animal)');
disp(lme)

scatter(data.condition, data.propAfter)

