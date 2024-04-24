% Script to generate the data used for the statistical tests.

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths

% We create identifiers for cells from each session.
% Format is : IDENT-00-XXX
identifiers = 1:numel(sessions);
identifiers = identifiers* 1000;

% Arrays to hold all the data

sessionID = [];
animal = [];
condition = [];
track = [];
cell = [];
label = [];
peakEndRUN1 = [];
peakStartRUN2 = [];
firingRateRUN1 = [];

refinCM = [];
refinFR = [];
refinPeak = [];

partP1Rep = [];
propPartRep = []; % % of replay participated in
partSWR = [];
expReexpBias = [];

% We take the absolute value of the difference over sum to get the relative
% distance with the FPF, independently of the direction
diffSum = @(x1, x2) abs(x1 - x2)/(x1 + x2);

%% Extraction & computation

parfor fileID = 1:length(sessions)

    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    ident = identifiers(fileID); % We get the identifier for the session

    % Load the variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;

    % Track loop

    for trackOI = 1:2

        goodPCRUN1 = lap_place_fields(trackOI).Complete_Lap{end}.good_cells;
        goodPCRUN2 = lap_place_fields(trackOI + 2).Complete_Lap{1}.good_cells;

        other_track = mod(trackOI + 1, 2) + mod(trackOI, 2)*2;

        goodPCRUN1Other = lap_place_fields(other_track).Complete_Lap{end}.good_cells;
        goodPCRUN2Other = lap_place_fields(other_track + 2).Complete_Lap{1}.good_cells;

        % Good cells : Cells that where good place cells during RUN1 or RUN2
        goodCells = union(goodPCRUN1, goodPCRUN2);

        % Control : Cells that where good place cells during RUN1 and RUN2
        % (no appearing / disappearing cells).
        % goodCells = intersect(goodPCRUN1, goodPCRUN2);

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
        % temp = load(file + "\balanced_analysis\one_lap_all\" + track_label + "\significant_replay_events_wcorr");
        temp = load(file + "\" + track_label + "\significant_replay_events_wcorr");
        Exp_Rexp = temp.significant_replay_events;

        replayExpSleep = getAllSleepReplay(1, startTime, endTime, Exp_Rexp, sleep_state);
        replayReexpSleep = getAllSleepReplay(2, startTime, endTime, Exp_Rexp, sleep_state);

        commonReplayID = intersect(Exp_Rexp.track(1).ref_index(replayExpSleep), ...
            Exp_Rexp.track(2).ref_index(replayReexpSleep));

        disp("X : " + numel(commonReplayID));

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

        numberLapsRUN2 = length(RUN2LapPFData);

        finalPlaceField = {};

        % For each cell (good or not), we create the final place field
        for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
            temp = [];

            for lap = 1:6
                temp = [temp; RUN2LapPFData{16 + lap}.smooth{cellID}];
            end

            finalPlaceField(end + 1) = {mean(temp, 'omitnan')};
        end

        cmFPF = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), finalPlaceField);
        frFPF = cellfun(@max, finalPlaceField);
        peakFPF = cellfun(@(x) find(x == max(x), 1), finalPlaceField);

        % If the firing rate is 0 on the whole track, the CM calculation
        % will return NaN. In that case, max firing rate and peak don't
        % have sense, we can NaN  everything.

        frFPF(isnan(cmFPF)) = NaN;
        peakFPF(isnan(cmFPF)) = NaN;


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

            % Like for the FPF, we NaN everything if the CM is NaN
            % Here we can NaN every variables because the metric will be
            % NaN anyway

            if isnan(endRUN1CM) | isnan(startRUN2CM)
                endRUN1MaxFR = NaN;
                startRUN2MaxFR = NaN;
                endRUN1PeakLoc = NaN;
                startRUN2PeakLoc = NaN;
            end

            % We compute the metrics we're interested in

            current_refinCM = abs(cmFPF(cellOI) - endRUN1CM) - abs(cmFPF(cellOI) - startRUN2CM);


            current_refinFR = diffSum(frFPF(cellOI), endRUN1MaxFR) ...
                - diffSum(frFPF(cellOI), startRUN2MaxFR);

            current_refinPeak = abs(peakFPF(cellOI) - endRUN1PeakLoc) - ...
                abs(peakFPF(cellOI) - startRUN2PeakLoc);


            % We get the replay participation of the cell - in nb of events
            replayInvolvedCurrent = cellfun(@(ev) any(ev(:, 1) == cellOI), filteredReplayEventsSpikesCurrent);
            current_partP1Rep = sum(replayInvolvedCurrent);
            current_propPart = current_partP1Rep/nbReplay;

            % We get the SWR participation of the cell - in nb of events
            swrInvolvedCurrent = cellfun(@(ev) any(ev(:, 1) == cellOI), filteredSWR);
            current_partSWR = sum(swrInvolvedCurrent);

            % We get the participation in RUN1 vs. RUN3 replay
            partExpReplay = sum(cellfun(@(ev) any(ev(:, 1) == cellOI), filtExpRepSpikes));
            partReexpReplay = sum(cellfun(@(ev) any(ev(:, 1) == cellOI), filtReexpRepSpikes));

            current_expReexpBias = (partReexpReplay - partExpReplay) / (partExpReplay + partReexpReplay);


            % Save the data

            sessionID = [sessionID; fileID];
            animal = [animal; animalOI];
            condition = [condition; conditionOI];
            track = [track; trackOI];
            cell = [cell; ident + cellOI];
            label = [label; current_label(cellID)];
            peakEndRUN1 = [peakEndRUN1; abs(peakFPF(cellOI) - endRUN1PeakLoc)];
            peakStartRUN2 = [peakStartRUN2; abs(peakFPF(cellOI) - startRUN2PeakLoc)];
            firingRateRUN1 = [firingRateRUN1; endRUN1MaxFR];

            refinCM = [refinCM; current_refinCM];
            refinFR = [refinFR; current_refinFR];
            refinPeak = [refinPeak; current_refinPeak];
            partP1Rep = [partP1Rep; current_partP1Rep];
            propPartRep = [propPartRep; current_propPart];
            partSWR = [partSWR; current_partSWR];
            expReexpBias = [expReexpBias; current_expReexpBias];

        end
    end
end



% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

data = table(sessionID, animal, condition, cell, label, ...
    refinCM, refinFR, refinPeak, ...
    partP1Rep, propPartRep, partSWR, expReexpBias);

save("dataRegression.mat", "data")
% save("dataRegressionXor.mat", "data")
% save("dataRegressionIntersection.mat", "data")

%%

% boxchart(categorical(data.label), data.firingRateRUN1);
% ylabel("Max FR during last lap RUN1");
% 
% allCond = [1, 2, 3, 4, 8, 16];
% for c = 1:16
%     figure;
%     cc = allCond(c);
%     boxchart(categorical(data.label(data.condition == cc)), data.firingRateRUN1(data.condition == cc));
%     ylabel("Distance with FPF");
% end

% boxchart(data.condition(data.label == "Appear"), data.peakStartRUN2(data.label == "Appear"))
% grid on;
% xlabel("Number of laps");
% ylabel("Distance with FPF");
% title("Distance of appearing cells with FPF during 1st lap - RUN2")
% 
% allCond = [1, 2, 3, 4, 8, 16];
% for c = 1:16
%     figure;
%     cc = allCond(c);
%     boxchart(categorical(data.label(data.condition == cc)), data.peakEndRUN1(data.condition == cc));
%     ylabel("Distance with FPF");
% end

% subdata = data(data.condition ~=1111, :);
% 
% figure;
% subplot(1, 2, 1);
% hist(subdata.peakEndRUN1, 30);
% subplot(1, 2, 2);
% hist(subdata.peakStartRUN2, 30);
% 
% figure;
% subplot(1, 3, 1);
% hist(subdata.peakEndRUN1(subdata.label == "Disappear"), 30);
% subplot(1, 3, 2);
% hist(subdata.peakStartRUN2(subdata.label == "Appear"), 30);
% subplot(1, 3, 3);
% hist(subdata.peakStartRUN2(subdata.label == "Stable"), 30);
% 
% %% Calculate the redundancy of place fields
% allSessionID = unique(subdata.sessionID);
% run1Red = [];
% run2Red = [];
% 
% for id = 1:numel(allSessionID)
%     matchingData = subdata(subdata.sessionID == allSessionID(id), :);
%     allRun1Peak = matchingData.peakEndRUN1;
%     allRun2Peak = matchingData.peakStartRUN2;
% 
%     for c = 1:numel(matchingData(:, "cell"))
%         run1Peak = allRun1Peak(c);
%         run2Peak = allRun2Peak(c);
% 
%         % Redudancy is defined as the proportion of cells within 20 cm of
%         % the peak
% 
%         current_red_run1 = sum(allRun1Peak >= run1Peak - 10 & allRun1Peak <= run1Peak + 10)/numel(allRun1Peak);
%         current_red_run2 = sum(allRun2Peak >= run2Peak - 10 & allRun2Peak <= run2Peak + 10)/numel(allRun2Peak);
% 
%         if isnan(run1Peak)
%             current_red_run1 = NaN;
%         end
% 
%         if isnan(run2Peak)
%             current_red_run2 = NaN;
%         end
% 
%         run1Red(end + 1) = current_red_run1;
%         run2Red(end + 1) = current_red_run2;
%     end
% end