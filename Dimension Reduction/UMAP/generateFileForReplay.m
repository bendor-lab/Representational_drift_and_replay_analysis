clear

currentPath = data_folders_excl_legacy;
currentPath = currentPath{6};

track = 2;

load(currentPath + "\replayEvents_bayesian_spike_count")
load(currentPath + "\Bayesian controls\Only first exposure\significant_replay_events_wcorr")
load(currentPath + "\extracted_sleep_state")
load(currentPath + "/extracted_place_fields");
load(currentPath + "/extracted_clusters");


timePOST1Start = sleep_state.state_time.INTER_post_start;
timePOST1Stop = sleep_state.state_time.INTER_post_end;

binEdges = timePOST1Start:0.020:timePOST1Stop;  % Create bins of timeBin intervals

% We get all the sleep replay during POST1
goodIndex = getAllSleepReplay(track, timePOST1Start, timePOST1Stop, significant_replay_events, sleep_state);

allSpikesConcat = cell2mat(cellfun(@(x) x(:, 1)', ...
    significant_replay_events.track(track).spikes(goodIndex), ...
    'UniformOutput', false));

allTimesConcat = cell2mat(cellfun(@(x) x(:, 2)', ...
    significant_replay_events.track(track).spikes(goodIndex), ...
    'UniformOutput', false));


idReplayVector = cellfun(@(x, y) (binEdges' >= x(1, 2) & binEdges' <= x(end, 2))*y, ...
    significant_replay_events.track(track).spikes(goodIndex), ...
    num2cell(goodIndex'), 'UniformOutput', false);

idReplayVector = cell2mat(idReplayVector);

id = sum(idReplayVector, 2);

% We determine which cells to include

% allCells = unique(clusters.spike_id);
% allCells = union(place_fields.track(track).good_cells, place_fields.track(track + 2).good_cells);
allCells = place_fields.pyramidal_cells;

% We create a big histogram of each spike of each cell
histBinned = zeros(length(allCells), length(binEdges) - 1);

for i = 1:length(allCells)
    cell = allCells(i);

    % We get the histcount for that cell, and happend to the big hist
    currentHist = histcounts(allTimesConcat(allSpikesConcat == cell), binEdges);

    histBinned(i, :) = currentHist;
end

% We smooth using a 40  ms gaussian kernel
histBinned = smoothdata(histBinned, 2, "gaussian", 2);


% We NaN every time that's not a replay time

id = id(1:end-1);
binEdges = binEdges(1:end-1)';

isReplayTime = logical(id);
histBinned(:, ~isReplayTime) = NaN;
histBinned = histBinned';

% We create a table with our variables, and we remove the NaN rows

t = table(binEdges, id);

order = zeros(length(t.id), 1);

for i = 1:numel(goodIndex)
    currentID = goodIndex(i);

    if ~any(t.id == currentID)
        continue;
    end

    toAdd = cumsum(t.id == currentID) .* ((t.id == currentID));
    toAdd = toAdd / sum(t.id == currentID);
    order = order + toAdd;
end

t.order = order;

for c = 1:numel(allCells)
    cell = allCells(c);
    lab = "c" + cell;
    values = histBinned(:, c);

    t.(lab) = values;
end

t = rmmissing(t);


writetable(t, "replayData.csv")