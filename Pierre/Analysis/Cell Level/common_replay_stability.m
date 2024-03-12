% Look at the % of replay with stable cells vs. not stable cells (median)
% in function of the stability

% Idea : if stable, will replay with less stable. And inverse

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

load(PATH.SCRIPT + "/../../Data/extracted_activity_mat_lap.mat") % To get cells center of mass
load(PATH.SCRIPT + "/../../Data/population_vector_laps.mat") % To get the FPF for each session
% (and the clean number of laps)

% Arrays to hold all the data
animalV = [];
conditionV = [];
trackV = [];
lapV = [];
cellV = [];
expositionV = [];
deltaCMV = [];
deltaMaxFRV = [];
deltaPeakLocationV = [];
coReplayStableV = [];
coReplayUnstableV = [];

%% Extraction & computation

for cID = 1:numel(sessions)
    disp(cID);
    file = sessions{cID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string

    for track = 1:2

        % Get the good final place field
        FPF = population_vector_laps(string({population_vector_laps.animal}) == animalOI & ...
            string({population_vector_laps.condition}) == conditionOI & ...
            [population_vector_laps.track] == track + 2);
        FPF = FPF.finalPlaceField;

        fpfCM = FPF.centre_of_mass;
        fpfMaxFR = cellfun(@(x) max(x), FPF.smooth, 'UniformOutput', false);
        fpfSumFR = cellfun(@(x) sum(x), FPF.smooth, 'UniformOutput', false);

        fpfPeakLoc = cellfun(@(x, y) find(x == y), FPF.smooth, fpfMaxFR, 'UniformOutput', false);
        fpfPeakLoc(cell2mat(fpfMaxFR) == 0) = {NaN}; % If max == 0, we remove the position

        fpfMaxFR = cell2mat(fpfMaxFR); % We convert to vectors
        fpfSumFR = cell2mat(fpfSumFR);
        fpfPeakLoc = cell2mat(fpfPeakLoc);

        % Get the good lap data
        currData = activity_mat_laps(string({activity_mat_laps.animal}) == animalOI & ...
            string({activity_mat_laps.condition}) == conditionOI & ...
            [activity_mat_laps.track] == track);

        lapDataGoodCells = activity_mat_laps(string({activity_mat_laps.animal}) == animalOI & ...
            string({activity_mat_laps.condition}) == conditionOI & ...
            [activity_mat_laps.track] == track + 2).allLaps;

        lapData = currData.allLaps;
        nbLaps = length(lapData);

        % Good cells are good place cells on RUN2
        goodCells = lapDataGoodCells(1).cellsData.cell(lapDataGoodCells(1).cellsData.isGoodPCCurrentTrack);
        nbGoodCells = numel(goodCells);
        %% Now we get the stability metrics for the last lap of RUN1

        currentData = lapData(end).cellsData; % We take the last lap of RUN1
        nbCells = length(currentData.cell);

        % We get the main variables we need
        % We first take all the pyramidal cells then all the good
        % place cells on the track

        deltaCM = abs(currentData.pfCenterMass - fpfCM(currentData.cell));

        sumPlaceField = cellfun(@sum, currentData.placeField);

        % Diffsum normalised
        deltaMaxFR = abs(sumPlaceField - fpfSumFR(currentData.cell))...
            ./(sumPlaceField + fpfSumFR(currentData.cell));

        deltaPeakLoc = abs(currentData.pfPeakPosition - fpfPeakLoc(currentData.cell));

        %% We load the replay events
        load(file + "/Replay/RUN1_Decoding/significant_replay_events_wcorr");

        % We filter to get only POST1 sleep replay spikes

        % Fetch the sleep times to filter POST1 replay events
        temp = load(file +  "/extracted_sleep_state");
        sleep_state = temp.sleep_state;
        startTime = sleep_state.state_time.INTER_post_start;
        endTime = startTime + 1800; % Only the 30 first minutes

        % We get the IDs of all the sleep replay events
        goodIndexCurrent = getAllSleepReplay(track, startTime, endTime, significant_replay_events, sleep_state);

        % We get the id of all the cells that replayed

        allSpikes = significant_replay_events.track(track).spikes(goodIndexCurrent);

        coReplayStable = [];
        coReplayUnstable = [];

        threshInstability = median(deltaCM, 'omitnan');
        
        % We find all the replay events where the cell was involved.
        % We then get all the co-replaying cells
        
        for c = 1:numel(currentData.cell)
            currentCell = currentData.cell(c);

            countStable = 0;
            countUnstable = 0;
            nbReplayCells = 0;

            for replayEventID = 1:numel(allSpikes)
                currentEvent = allSpikes{replayEventID};
                isCellPresent = any(currentEvent(:, 1) == c);

                if isCellPresent
                    otherCells = unique(currentEvent(currentEvent(:, 1) ~= c, 1));
                    
                    numberUnstable = sum(deltaCM(ismember(currentData.cell, otherCells)) <= threshInstability);
                    numberStable = numel(otherCells) - numberUnstable;

                    countStable = countStable + numberStable;
                    countUnstable = countUnstable + numberUnstable;
                    nbReplayCells = nbReplayCells + numel(otherCells);
                end
            end

            % We reduce to a percentage
            countStable = countStable/nbReplayCells;
            countUnstable = countUnstable/nbReplayCells;

            % We add to the holders
            coReplayStable = [coReplayStable; countStable];
            coReplayUnstable = [coReplayUnstable; countUnstable];

        end

        %% We filter everything based on the good cells

        isGoodPCFinal = ismember(currentData.cell, goodCells);

        deltaCM = deltaCM(isGoodPCFinal);
        deltaMaxFR = deltaMaxFR(isGoodPCFinal);
        deltaPeakLoc = deltaPeakLoc(isGoodPCFinal);

        coReplayStable = coReplayStable(isGoodPCFinal);
        coReplayUnstable = coReplayUnstable(isGoodPCFinal);

        % We add the data

        animalV = [animalV; repelem(animalOI, nbGoodCells)'];
        conditionV = [conditionV; repelem(conditionOI, nbGoodCells)'];
        trackV = [trackV; repelem(track, nbGoodCells)'];
        cellV = [cellV; goodCells'];
        deltaCMV = [deltaCMV; deltaCM'];
        deltaMaxFRV = [deltaMaxFRV; deltaMaxFR'];
        deltaPeakLocationV = [deltaPeakLocationV; deltaPeakLoc'];
        coReplayStableV = [coReplayStableV; coReplayStable];
        coReplayUnstableV = [coReplayUnstableV; coReplayUnstable];

    end
end

