clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl_legacy; % Use the function to get all the file paths

% (and the clean number of laps)

% Arrays to hold all the data
animalV = [];
conditionV = [];
trackV = [];
cellV = [];

measureTimeV = []; % Last Lap RUN1 (-1), First Lap RUN2 (1)
StabilityCM = [];
StabilityFR = [];
StabilityPeakLoc = [];

partP1RepV = [];
partP1RepOtherV = [];

% Diffsum integral PF
diffsumInt = @(pf1, pf2) abs(sum(pf1) - sum(pf2)) / (sum(pf1) + sum(pf2));

%% Extraction & computation

parfor fileID = 1:length(sessions)
    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string

    % Exception, need to recalculate

    if fileID == 5
        continue;
    end

    % Load variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;


    % Track loop

    for track = 1:2

        % Good cells : cells that become good place cells on RUN2

        goodCells = place_fields.track(track + 2).good_cells;

        % We get the replay participation

        % Fetch the significant replay events
        temp = load(file + "\Bayesian controls\Only first exposure\significant_replay_events_wcorr");
        significant_replay_events = temp.significant_replay_events;

        RE_current_track = significant_replay_events.track(track);
        RE_other_track = significant_replay_events.track(mod(track, 2)*2 + mod(track + 1, 2));

        % Fetch the sleep times to filter POST1 replay events
        temp = load(file +  "/extracted_sleep_state");
        sleep_state = temp.sleep_state;
        startTime = sleep_state.state_time.INTER_post_start;
        endTime = startTime + 1800; % Only the 30 first minutes

        % Bool mat of the valid times
        subsetReplayBoolCurrent = RE_current_track.event_times <= endTime & RE_current_track.event_times >= startTime;
        subsetReplayBoolOther = RE_other_track.event_times <= endTime & RE_other_track.event_times >= startTime;

        filteredReplayEventsSpikesCurrent = RE_current_track.spikes(subsetReplayBoolCurrent);
        filteredReplayEventsSpikesOther = RE_other_track.spikes(subsetReplayBoolOther);

        % We get the final place field : mean of the 16 last laps RUN2

        RUN1LapPFData = lap_place_fields(track).Complete_Lap;
        RUN2LapPFData = lap_place_fields(track + 2).Complete_Lap;

        numberLapsRUN2 = length(RUN2LapPFData);

        finalPlaceField = {};

        % For each cell, we create the final place field
        for cellID = 1:length(place_fields.track(track + 2).smooth)
            temp = [];
            for lap = 0:15
                temp = [temp; RUN2LapPFData{numberLapsRUN2 - lap}.smooth{cellID}];
            end
            finalPlaceField(end + 1) = {mean(temp, 'omitnan')};
        end

        cmFPF = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), finalPlaceField);
        frFPF = cellfun(@sum, finalPlaceField);
        peakFPF = cellfun(@(x) find(x == max(x), 1), finalPlaceField);

        % If everything is 0, we NaN the max and the pfr
        frFPF(isnan(cmFPF)) = NaN;
        peakFPF(isnan(cmFPF)) = NaN;

        % Cell loop
        for cellID = 1:length(goodCells)

            cell = goodCells(cellID);

            for measureTime = -1:2:1

                if measureTime == -1 % if last lap RUN1
                   currentPF = RUN1LapPFData{end}.smooth{cell};
                else
                    currentPF = RUN2LapPFData{1}.smooth{cell};
                end

                currentCM = sum(currentPF.*(1:2:200)/sum(currentPF));

                % We get the metric variables

                stabCM = abs(currentCM - cmFPF(cell));
                stabFR = diffsumInt(currentPF, finalPlaceField{cell});

                indexMax = find(currentCM == max(currentCM), 1);

                % If we have a maximum of zero, just evaluate to NaN
                % If there is no maximum, also evaluate to NaN

                if max(currentCM) == 0 || isempty(indexMax)

                    indexMax = NaN;

                end

                stabPeakLoc = abs(peakFPF(cell) - indexMax);

                % We get the replay participation of the cell
                replayInvolvedCurrent = cellfun(@(ev) any(ev(:, 1) == cell), filteredReplayEventsSpikesCurrent);
                replayInvolvedOther = cellfun(@(ev) any(ev(:, 1) == cell), filteredReplayEventsSpikesOther);

                partP1Rep = sum(replayInvolvedCurrent);
                partP1RepOther = sum(replayInvolvedOther);

                % Save the data

                animalV = [animalV; animalOI];
                conditionV = [conditionV; conditionOI];
                trackV = [trackV; track];
                cellV = [cellV; cell];

                measureTimeV = [measureTimeV; measureTime]; % Last Lap RUN1 (-1), First Lap RUN2 (1)
                StabilityCM = [StabilityCM; stabCM];
                StabilityFR = [StabilityFR; stabFR];
                StabilityPeakLoc = [StabilityPeakLoc; stabPeakLoc];
                partP1RepV = [partP1RepV; partP1Rep];
                partP1RepOtherV = [partP1RepOtherV; partP1RepOther];

            end


        end
    end
end



% We mutate to only have the condition, not 16x...
conditionV(trackV == 1) = 16;
newConditions = split(conditionV(trackV ~= 1), 'x');
conditionV(trackV ~= 1) = newConditions(:, 2);

conditionV = str2double(conditionV);


data = table(animalV, conditionV, trackV, cellV, measureTimeV, StabilityCM, StabilityFR, StabilityPeakLoc, partP1RepV, partP1RepOtherV);

%% Inferential stats : more refinement when less laps ?

summaryData = groupsummary(data, ["animalV", "conditionV", "measureTimeV"], "median", ["StabilityCM", "StabilityFR", ...
    "StabilityPeakLoc", "partP1RepV", "partP1RepOtherV"]);

% We center the condition
summaryData.log_condition_centered = log(summaryData.conditionV);
summaryData.log_condition_centered = summaryData.log_condition_centered - mean(summaryData.log_condition_centered);


lme = fitlme(summaryData,'median_StabilityCM ~ measureTimeV * log_condition_centered + (1|animalV)');
disp(lme);

figure;
plot(lme); % The animal is having a very small effect

lm = fitlm(summaryData,'median_partP1RepV ~ log_condition_centered');
disp(lm);

figure;
plot(lm)

lm = fitlm(summaryData,'median_refinFRV ~ log_condition_centered');
disp(lm);

figure;
plot(lm)

lm = fitlm(summaryData,'median_refinPeakV ~ log_condition_centered');
disp(lm);

figure;
plot(lm)

% Check if the amount of replay of the track have an influence on the
% refinment

lm = fitlm(summaryData,'median_refinCMV ~ log_condition_centered + median_partP1RepV');
disp(lm);

figure;
plot(lm)

% T
