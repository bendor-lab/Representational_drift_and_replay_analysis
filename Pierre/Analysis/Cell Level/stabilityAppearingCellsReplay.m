% Question : Appearing cells don't have, by definintion, 
% Experience as place cells during RUN1. 
% Are there stability at the beginning of RUN2 linked with replay ? 

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

stabCMV = [];
stabFRV = [];
stabPeakV = [];

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

        % Good cells : cells were not good place cells during RUN1 but are
        % during RUN2

        goodCells = setdiff(place_fields.track(track + 2).good_cells, ...
                            place_fields.track(track).good_cells);

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
        
        % We get the IDs of all the sleep replay events
        goodIDCurrent = getAllSleepReplay(track, startTime, endTime, significant_replay_events, sleep_state);
        goodIDOther = getAllSleepReplay(mod(track, 2)*2 + mod(track + 1, 2), startTime, endTime, significant_replay_events, sleep_state);

        filteredReplayEventsSpikesCurrent = RE_current_track.spikes(goodIDCurrent);
        filteredReplayEventsSpikesOther = RE_other_track.spikes(goodIDOther);

        % We get the final place field : mean of the 16 last laps RUN2
        
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

            startRUN2PF = RUN2LapPFData{1}.smooth{cell};

            startRUN2CM = sum(startRUN2PF.*(1:2:200)/sum(startRUN2PF));

            % We get the metric variables

            stabCM = abs(cmFPF(cell) - startRUN2CM);

            stabFR = abs(frFPF(cell) - sum(startRUN2PF))/(frFPF(cell) + sum(startRUN2PF));
            
            indexMaxRUN2 = find(startRUN2PF == max(startRUN2PF), 1);

            % If we have a maximum of zero, just evaluate to NaN
            % If there is no maximum, also evaluate to NaN

            if max(startRUN2PF) == 0 || isempty(indexMaxRUN2)
                indexMaxRUN2 = NaN;
            end

            stabPeak = abs(peakFPF(cell) - indexMaxRUN2);

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
            stabCMV = [stabCMV; stabCM];
            stabFRV = [stabFRV; stabFR];
            stabPeakV = [stabPeakV; stabPeak];
            partP1RepV = [partP1RepV; partP1Rep];
            partP1RepOtherV = [partP1RepOtherV; partP1RepOther];

        end
    end
end



% We mutate to only have the condition, not 16x...
conditionV(trackV == 1) = 16;
newConditions = split(conditionV(trackV ~= 1), 'x');
conditionV(trackV ~= 1) = newConditions(:, 2);

conditionV = str2double(conditionV);


data = table(animalV, conditionV, trackV, cellV, stabCMV, stabFRV, stabPeakV, partP1RepV, partP1RepOtherV);

%% We plot the stability and replay participation

G = groupsummary(data, ["animalV", "conditionV"], "mean", ...
                       ["stabCMV", "stabFRV", "stabPeakV", "partP1RepV"]);
t = tiledlayout(1, 3);

nexttile;
scatter(G.mean_stabCMV, G.mean_partP1RepV)
xlabel("CM difference with the FPF")
ylabel("Mean replay participation")
ylim([0, 1.2])

nexttile;
scatter(G.mean_stabFRV, G.mean_partP1RepV)
xlabel("FR difference with the FPF")
ylabel("Mean replay participation")

ylim([0, 1.2])


nexttile;
scatter(G.mean_stabPeakV, G.mean_partP1RepV)
xlabel("Peak location difference with the FPF")
ylabel("Mean replay participation")

ylim([0, 1.2])

title(t, "Stability of appearing cells during the 1s lap of RUN2 x Replay participation")

