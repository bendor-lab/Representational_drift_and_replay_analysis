% Looking at the neighboor during replay as predictors of the refined
% position

%% 1. Get, for all cells, the neighboring cells during replay

sessions = data_folders_excl;

animal = [];
condition = [];
track = [];
cell = [];
realRem = [];
predDis = [];

for fileID = 10 %1:numel(sessions)

    disp(fileID);

    file = sessions{fileID};

    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string

    % Load the variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;

    for trackOI = 1:2

        goodPCRUN1 = lap_place_fields(trackOI).Complete_Lap{end}.good_cells;
        goodPCRUN2 = lap_place_fields(trackOI + 2).Complete_Lap{1}.good_cells;

        other_track = mod(trackOI + 1, 2) + mod(trackOI, 2)*2;

        goodPCRUN1Other = lap_place_fields(other_track).Complete_Lap{end}.good_cells;
        goodPCRUN2Other = lap_place_fields(other_track + 2).Complete_Lap{1}.good_cells;

        % Good cells : Cells that where good place cells during RUN1 or RUN2
        % goodCells = union(goodPCRUN1, goodPCRUN2);

        % Control : Cells that where good place cells during RUN1 and RUN2
        % (no appearing / disappearing cells).
        goodCells = intersect(goodPCRUN1, goodPCRUN2);

        % Control : Cells that were good place cells during RUN1 xor RUN2
        % (only appearing / disappearing cells).
        % goodCells = setxor(goodPCRUN1, goodPCRUN2);

        % We get the labels

        isGoodPCRUN1 = ismember(goodCells, goodPCRUN1);
        isGoodPCRUN2 = ismember(goodCells, goodPCRUN2);
        isGoodPCRUN1Other = ismember(goodCells, goodPCRUN1Other);
        isGoodPCRUN2Other = ismember(goodCells, goodPCRUN2Other);

        current_label = repelem("Unstable", 1, numel(goodCells));
        current_label(isGoodPCRUN1 & isGoodPCRUN2)= "Stable";
        current_label(isGoodPCRUN1 & ~isGoodPCRUN2 & isGoodPCRUN2Other)= "Disappear";
        current_label(~isGoodPCRUN1 & isGoodPCRUN2 & isGoodPCRUN1Other)= "Appear";

        % We get the replay participation

        % Fetch the significant replay events
        temp = load(file + "\Replay\RUN1_Decoding\significant_replay_events_wcorr");
        significant_replay_events = temp.significant_replay_events;

        temp = load(file + "\Replay\RUN1_Decoding\decoded_replay_events");
        decoded_replay_events = temp.decoded_replay_events;

        RE_current_track = significant_replay_events.track(trackOI);

        % Fetch the sleep times to filter POST1 replay events
        temp = load(file +  "/extracted_sleep_state");
        sleep_state = temp.sleep_state;
        startTime = sleep_state.state_time.INTER_post_start;
        endTime = sleep_state.state_time.INTER_post_end;

        % We get the IDs of all the sleep replay events
        goodIDCurrent = getAllSleepReplay(trackOI, startTime, endTime, significant_replay_events, sleep_state);

        % We get the ID of all the sleep SWR
        sleepSWRID = getAllSleepReplay(trackOI, startTime, endTime, decoded_replay_events, sleep_state);

        % Get all the sleep replay Exposure vs. Re-exposure

        track_label = ['Replay_T', int2str(trackOI), '_vs_T', int2str(trackOI + 2)];
        % temp = load(file + "\balanced_analysis\" + track_label + "\significant_replay_events_wcorr");
        temp = load(file + "\" + track_label + "\significant_replay_events_wcorr");
        Exp_Rexp = temp.significant_replay_events;

        replayExpSleep = getAllSleepReplay(1, startTime, endTime, Exp_Rexp, sleep_state);
        replayReexpSleep = getAllSleepReplay(2, startTime, endTime, Exp_Rexp, sleep_state);

        commonReplayID = intersect(Exp_Rexp.track(1).ref_index(replayExpSleep), ...
            Exp_Rexp.track(2).ref_index(replayReexpSleep));

        disp("Common replay found : " + numel(commonReplayID));

        replayExpSleep = replayExpSleep(~ismember(Exp_Rexp.track(1).ref_index(replayExpSleep), commonReplayID));
        replayReexpSleep = replayReexpSleep(~ismember(Exp_Rexp.track(2).ref_index(replayReexpSleep), commonReplayID));

        filtExpRepSpikes = Exp_Rexp.track(1).spikes(replayExpSleep);
        filtReexpRepSpikes = Exp_Rexp.track(2).spikes(replayReexpSleep);

        nbReplay = numel(goodIDCurrent);

        filteredReplayEventsSpikesCurrent = RE_current_track.spikes(goodIDCurrent);
        filteredSWR = {decoded_replay_events(trackOI).replay_events(sleepSWRID).spikes};

        % We get the final place field : mean of the 6 laps following the
        % 16th lap of RUN2

        RUN1LapPFData = lap_place_fields(trackOI).Complete_Lap;
        RUN2LapPFData = lap_place_fields(trackOI + 2).Complete_Lap;
        % 
        % numberLapsRUN2 = length(RUN2LapPFData);
        % 
        % finalPlaceField = {};
        % 
        % % For each cell (good or not), we create the final place field
        % for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
        %     temp = [];
        % 
        %     for lap = 1:6
        %         temp = [temp; RUN2LapPFData{16 + lap}.smooth{cellID}];
        %     end
        % 
        %     finalPlaceField(end + 1) = {mean(temp, 'omitnan')};
        % end
        % 
        % cmFPF = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), finalPlaceField);
        % frFPF = cellfun(@max, finalPlaceField);
        % peakFPF = cellfun(@(x) find(x == max(x), 1), finalPlaceField);
        % 
        % % If the firing rate is 0 on the whole track, the CM calculation
        % % will return NaN. In that case, max firing rate and peak don't
        % % have sense, we can NaN  everything.
        % 
        % frFPF(isnan(cmFPF)) = NaN;
        % peakFPF(isnan(cmFPF)) = NaN;

        Vt = NaN(length(goodCells), 1);
        Vt1 = NaN(length(goodCells), 1);
        N = zeros(length(goodCells), length(goodCells));

        % Cell loop
        for cellID = 1:length(goodCells)
            cellOI = goodCells(cellID);

            endRUN1PF = RUN1LapPFData{end}.smooth{cellOI};
            startRUN2PF = RUN2LapPFData{1}.smooth{cellOI};

            endRUN1CM = sum(endRUN1PF.*(1:2:200)/sum(endRUN1PF));
            startRUN2CM = sum(startRUN2PF.*(1:2:200)/sum(startRUN2PF));

            endRUN1MaxFR = max(endRUN1PF);
            startRUN2MaxFR = max(startRUN2PF);

            endRUN1PeakLoc = find(endRUN1PF == max(endRUN1PF), 1);
            startRUN2PeakLoc = find(startRUN2PF == max(startRUN2PF), 1);

            Vt(cellID) = endRUN1CM;
            Vt1(cellID) = startRUN2CM;

        end

        for cellID = 1:length(goodCells)

            % We get the replay participation of the cell
            replayInvolvedCurrentBool = cellfun(@(ev) any(ev(:, 1) == cellOI), filteredSWR);
            replayInvolvedCurrent = filteredSWR(replayInvolvedCurrentBool);

            % We get all the neighbors during the replay
            for repID = 1:numel(replayInvolvedCurrent)
                current_replay = replayInvolvedCurrent{repID};
                AllIdCell = find(current_replay(:, 1) == goodCells(cellID));

                for cIdCell = 1:numel(AllIdCell)

                    idCell = AllIdCell(cIdCell);

                    if idCell > 1
                        cellBefore = current_replay(idCell - 1, 1);
                        cellBeforeID = find(goodCells == cellBefore);
                        if ~isempty(cellBeforeID)
                            N(cellID, cellBeforeID) = N(cellID, cellBeforeID) + 1;
                        end
                    end

                    if idCell < numel(current_replay(:, 1))
                        cellAfter = current_replay(idCell + 1, 1);
                        cellAfterID = find(goodCells == cellAfter);
                        if ~isempty(cellBeforeID)
                            N(cellID, cellBeforeID) = N(cellID, cellBeforeID) + 1;
                        end
                    end
                end
            end
        end

        % We normalize N
        weights = sum(N, 2);
        normN = N./weights;
        normN(isnan(normN)) = 0;
        % normN = normN.*~eye(size(normN)); % Set diagonal to 0
        cleanVt = Vt;
        cleanVt(isnan(cleanVt)) = 0;
        Vt1_predicted = normN * cleanVt;
        Vt1_predicted(Vt1_predicted == 0) = NaN;

        % We get the distance with past PF and the distance with futur PF

        pastDis = abs(Vt1 - Vt);
        futurDis = abs(Vt1 - Vt1_predicted);

        animal = [animal; repelem(animalOI, numel(goodCells), 1)];
        condition = [condition; repelem(conditionOI, numel(goodCells), 1)];
        track = [track; repelem(trackOI, numel(goodCells), 1)];
        cell = [cell; goodCells'];
        realRem = [realRem; pastDis];
        predDis = [predDis; futurDis];

    end
end

% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

data = table(animal, condition, track, cell, realRem, predDis);

%%
figure;
tiledlayout(1, 2)
nexttile;
histogram(data(data.track == 1, :).realRem, 10)
hold on;
histogram(data(data.track == 1, :).predDis, 10)
legend({"Real remap.", "Replay remap."})

nexttile;
histogram(data(data.track == 2, :).realRem, 10)
hold on;
histogram(data(data.track == 2, :).predDis, 10)
legend({"Real remap.", "Replay remap."})

linkaxes
