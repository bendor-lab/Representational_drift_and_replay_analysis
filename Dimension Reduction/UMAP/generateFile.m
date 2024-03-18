clear

currentPath = data_folders_excl_legacy;
currentPath = currentPath{3};

direction = 1;
unilateral = 2; % 2 for unilateral, 1 for bi
groupBy = 1;


% Load the data

load(currentPath + "/extracted_laps");
load(currentPath + "/extracted_clusters");
load(currentPath + "/extracted_place_fields");
load(currentPath + "/extracted_directional_place_fields");

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

halfLaps = direction:unilateral:length(lap_times(trackOI).halfLaps_start);
nbLaps = numel(halfLaps);

labels = floor(halfLaps * (floor(nbLaps/groupBy)/2) / nbLaps);

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
speed = interp_speed(1:end-1)';

x = x';

% Now we can pivot the hist, add info and export to csv

histBinned = histBinned';

% cellLabel = place_fields_BAYESIAN.other_cells;
% cellLabel = allCells(~ismember(allCells, place_fields.track(trackOI).good_cells));
% cellLabel = place_fields.track(trackOI).good_cells;
cellLabel = allCells;
% 
% pfDir1 = directional_place_fields(1).place_fields.track(trackOI).smooth;
% pfDir2 = directional_place_fields(2).place_fields.track(trackOI).smooth;
% [directionalCells, ~] = getDirectionalCells(pfDir1, pfDir2);
% % cellLabel = directionalCells;
% cellLabel = allCells(~ismember(allCells, directionalCells));

% We filter if needed
histBinned = histBinned(:, cellLabel);

t = table(x, lap, speed);

for c = 1:numel(cellLabel)
    cell = cellLabel(c);
    lab = "c" + cell;
    values = histBinned(:, c);

    t.(lab) = values;
end

t = rmmissing(t);

writetable(t, "neuralData_MBLU-8.csv")

% Function to get directional place cells based on Foster 2008 criteria
% Note : does not filters out bad place cells / non-pyramidal pc

function [directionalCells, dirOP] = getDirectionalCells(pfDir1, pfDir2)
peakDir1 = cellfun(@(x) max(x), pfDir1);
peakDir2 = cellfun(@(x) max(x), pfDir2);

directionalCells = find(peakDir1./peakDir2 >= 2 | peakDir1./peakDir2 <= 0.5);
dirOP = (peakDir1./peakDir2 >= 2)*1 + (peakDir1./peakDir2 <= 0.5)*2;
dirOP = dirOP(directionalCells);
end

