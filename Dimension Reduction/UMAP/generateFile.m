clear

currentPath = data_folders_excl_legacy;
currentPath = currentPath{9};

% Load the data

load(currentPath + "/extracted_laps");
load(currentPath + "/extracted_clusters");
load(currentPath + "/extracted_place_fields_BAYESIAN");
load(currentPath + "/extracted_position");

trackOI = 3;

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
% histBinned = histBinned(place_fields_BAYESIAN.good_place_cells, :);

% We smooth using a 500 ms gaussian kernel
histBinned = smoothdata(histBinned, 2, "gaussian", 5);

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
lapVector = zeros(1, length(binEdges) - 1);

direction = 1;
halfLaps = direction:2:length(lap_times(trackOI).halfLaps_start);
nbLaps = numel(halfLaps);

nb_clusters = 4;
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

%  We NaN those times in the hist
histBinned(:, idleTimes) = NaN;
lap = lapVector';

x = x';

% Now we can pivot the hist, add info and export to csv

histBinned = histBinned';
% cellLabel = place_fields_BAYESIAN.good_place_cells;
cellLabel = allCells;

t = table(x, lap);

for c = 1:numel(cellLabel)
    cell = cellLabel(c);
    lab = "c" + cell;
    values = histBinned(:, c);

    t.(lab) = values;
end

t = rmmissing(t);

writetable(t, "neuralData_MBLU-8.csv")

