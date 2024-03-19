clear

allPaths = data_folders_excl_legacy;

animal = [];
condition = [];
track = [];
exposition = [];
lap = [];
spikePerS = [];

for i = 1:numel(allPaths)
    currentPath = allPaths{i};
    disp(i);

    [animalOI, conditionOI] = parseNameFile(currentPath); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI);

    % Load the data

    lap_times = load(currentPath + "/extracted_laps");
    lap_times = lap_times.lap_times;

    clusters = load(currentPath + "/extracted_clusters");
    clusters = clusters.clusters;

    place_fields_BAYESIAN = load(currentPath + "/extracted_place_fields_BAYESIAN");
    place_fields_BAYESIAN = place_fields_BAYESIAN.place_fields_BAYESIAN;

    position = load(currentPath + "/extracted_position");
    position = position.position;

    for cTrack = 1:2
        for cExposition = 1:2

            trackOI = cTrack + (cExposition == 2)*2;

            opposite_track = mod(cTrack, 2)*2 + mod(cTrack + 1, 2);

            positionArray = position.linear(trackOI).linear;

            % Start and end times of the whole session

            startTime = lap_times(trackOI).completeLaps_start(1);
            endTime = lap_times(trackOI).completeLaps_stop(end);

            timePositionBool = position.t <= endTime & position.t >= startTime;
            positionArray = positionArray(timePositionBool);

            binEdges = startTime:0.100:endTime + 0.100;  % Create bins of timeBin intervals

            x = interp1(position.t(timePositionBool), positionArray, binEdges(1:end-1), 'nearest');

            % We create a big histogram of each spike of each cell

            allCells = unique(clusters.spike_id);
            histBinned = zeros(length(allCells), length(binEdges) - 1);

            for cID = 1:length(allCells)
                currentCell = allCells(cID);
                allSpikeTimes = clusters.spike_times(clusters.spike_id == currentCell);

                % Get the count
                spikeCounts = histcounts(allSpikeTimes, binEdges);

                % add to the histBinned
                histBinned(cID, :) = spikeCounts;
            end

            % We filter the hist with only good place cells

            % goodCells = union(place_fields_BAYESIAN.track(cTrack + 2).good_cells, ...
            %                 place_fields_BAYESIAN.track(opposite_track + 2).good_cells);

            goodCells = xor(ismember(allCells, place_fields_BAYESIAN.track(cTrack + 2).good_cells), ...
                            ismember(allCells, place_fields_BAYESIAN.track(opposite_track + 2).good_cells));

            histBinned = histBinned(goodCells, :);

            % We smooth using a 500 ms gaussian kernel
            % histBinned = smoothdata(histBinned, 2, "gaussian", 5);

            % We speed filter

            % Get the speed of the animal at each time
            position_speed = abs(position.v_cm);
            % Get the speed of the animal at every timebin
            interp_speed = interp1(position.t(timePositionBool), position_speed(timePositionBool), ...
                binEdges, 'nearest');
            % NaN the rows of the hist where the speed is less than 5 cm / s
            histBinned(:, interp_speed < 5) = NaN;

            % We remove all the times in the hist that are not running
            % RunningTimes contains only time values inside laps
            % Note : Speed Filter does the job usually

            runningTimes = zeros(1, length(binEdges) - 1);
            lapVector = NaN(1, length(binEdges) - 1);

            direction = 1;
            halfLaps = direction:2:length(lap_times(trackOI).halfLaps_start);
            nbLaps = numel(halfLaps);

            nb_clusters = nbLaps;
            labels = floor(halfLaps * (nb_clusters/2) / nbLaps) + 1;

            for lid = 1:nbLaps

                half_lap = halfLaps(lid);
                label = labels(lid);

                runningTimes(binEdges <= lap_times(trackOI).halfLaps_stop(half_lap) & ...
                    binEdges >= lap_times(trackOI).halfLaps_start(half_lap)) = 1;

                lapVector(binEdges <= lap_times(trackOI).halfLaps_stop(half_lap) & ...
                    binEdges >= lap_times(trackOI).halfLaps_start(half_lap)) = label;

            end

            idleTimes = not(runningTimes);

            %  We remove the idle times
            histBinned(:, idleTimes) = [];
            lapVector(idleTimes) = [];

            uniqueLaps = unique(lapVector);

            % Now we take the mean spike per cell per second for each lap

            for lapID = 1:numel(uniqueLaps)
                lapOI = uniqueLaps(lapID);

                subsetFiring = histBinned(:, lapVector == lapOI);
                lenLap = size(subsetFiring, 2)/10; % We get the time in seconds



                spike_per_second = (sum(sum(subsetFiring, 'omitnan'), 'omitnan')/numel(allCells))/lenLap;

                % We save everything

                animal = [animal; animalOI];
                condition = [condition; conditionOI];
                track = [track; cTrack];
                exposition = [exposition; cExposition];
                lap = [lap; lapOI];
                spikePerS = [spikePerS; spike_per_second];

            end
        end
    end
end

% We mutate to only have the condition, not 16x...
old_condition = condition;
condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);
condition = str2double(condition);

data = table(animal, old_condition, condition, track, exposition, lap, spikePerS);

% We median by condition, exopsition and lap
G = groupsummary(data, ["condition", "exposition", "lap"], ...
    "median", ["spikePerS"]);

allConditions = unique(condition);
colors = lines(length(allConditions));

%% Plotting loop
figure;

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
    color = colors(allConditions == condition, :);

    % We get the lap data of the exposure
    dataByLapExp1 = G(G.condition == condition & G.exposition == 1, :);
    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:condition, :);

    % We plot
    subplot(1, 2, 1)

    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if condition == 1
        scatter(1, dataByLapExp1.median_spikePerS, 30, color, "filled");
    else
        plot(dataByLapExp1.lap, dataByLapExp1.median_spikePerS, 'Color', color, 'LineWidth', 2);
    end

    hold on;

    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.condition == condition & G.exposition == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);

    % We plot
    subplot(1, 2, 2)
    plot(dataByLapExp2.lap, dataByLapExp2.median_spikePerS, 'Color', color, 'LineWidth', 2);

    hold on;

end

% Set the legend for each subplot
subplot(1, 2, 1);
ylim([0, 0.5])
legend({'1 lap', '2 laps', '3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Lap")
ylabel("Median spike / cell / s")
title("First exposure")

subplot(1, 2, 2);
ylim([0, 0.5])
xlabel("Lap")
ylabel("Median spike / cell / s")
title("Re-exposure")

hold off;

%% Only for 16 laps, plot each one

allAnimals = unique(data.animal);
allOldConditions = unique(data.old_condition);

colors2 = lines(length(allAnimals));


figure;

for i = 1:length(allOldConditions) % We iterate through conditions
    for j = 1:length(allAnimals)
        condition = allOldConditions(i);
        animal = allAnimals(j);

        color = colors2(allAnimals == animal, :);

        % We get the lap data of the exposure
        dataByLapExp1 = data(data.old_condition == condition & data.track == 1 & ...
                             data.exposition == 1 & data.animal == animal, :);

        if isempty(dataByLapExp1)
            continue;
        end

        dataByLapExp1 = dataByLapExp1(1:end, :);

        % We plot
        subplot(1, 2, 1)

        % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
        plot(dataByLapExp1.lap, dataByLapExp1.spikePerS, 'Color', color, 'LineWidth', 2);

        hold on;

        % We get the lap data of the reexposure
        dataByLapExp2 = data(data.old_condition == condition & data.track == 1 ...
                             & data.exposition == 2 & data.animal == animal, :);

        dataByLapExp2 = dataByLapExp2(1:16, :);

        % We plot
        subplot(1, 2, 2)
        plot(dataByLapExp2.lap, dataByLapExp2.spikePerS, 'Color', color, 'LineWidth', 2);

        hold on;

    end
end

% Set the legend for each subplot
subplot(1, 2, 1);
ylim([0, 4])
legend('show');
xlabel("Lap")
ylabel("Median spike / cell / s")
title("First exposure")

subplot(1, 2, 2);
ylim([0, 4])
xlabel("Lap")
ylabel("Median spike / cell / s")
title("Re-exposure")

hold off;
