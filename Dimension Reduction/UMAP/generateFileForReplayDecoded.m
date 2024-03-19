clear

currentPath = data_folders_excl;
currentPath = currentPath{2};

track = 2;

load(currentPath + "\replayEvents_bayesian_spike_count")
load(currentPath + "\Replay\RUN1_Decoding\decoded_replay_events")
load(currentPath + "/extracted_place_fields");
load(currentPath + "\extracted_sleep_state")
load(currentPath + "/extracted_clusters");


timePOST1Start = sleep_state.state_time.INTER_post_start;
timePOST1Stop = sleep_state.state_time.INTER_post_end;

binEdges = timePOST1Start:0.020:timePOST1Stop;  % Create bins of timeBin intervals

%% We get all the sleep replay during POST1

% We get the sleeping state each timepoint and we interpolate the correspondant time
stateVec = sleep_state.state;
timeVec = linspace(sleep_state.time(1), sleep_state.time(end), numel(stateVec));
freq = timeVec(end) - timeVec(end - 1);

stateVec = stateVec(timeVec <= timePOST1Stop & timeVec >= timePOST1Start);
stateVec(stateVec == -1) = 0; % We convert to a logical
stateVec = logical(stateVec);
timeVec = timeVec(timeVec <= timePOST1Stop & timeVec >= timePOST1Start);

% Now we return all the replay events in that range

allTimesReplay = cellfun(@(x) x(1), {decoded_replay_events(track).replay_events.timebins_edges});

allMatchingReplay = [];

for re = 1:numel(allTimesReplay)
    % Find the minute where the replay happend
    findMinute = histcounts(allTimesReplay(re), [timeVec timeVec(end) + freq]);

    % remove all the minutes when the animal was awake
    findMinute(~stateVec) = 0;

    % Now, if the replay event is still here, it's saved
    if sum(findMinute) ~= 0
        allMatchingReplay = [allMatchingReplay; re];
    end
end

goodIndex = allMatchingReplay;

%%

allSpikesConcat = cell2mat(cellfun(@(x) x(:, 1)', ...
    {decoded_replay_events(track).replay_events(goodIndex).spikes}, ...
    'UniformOutput', false));

allTimesConcat = cell2mat(cellfun(@(x) x(:, 2)', ...
    {decoded_replay_events(track).replay_events(goodIndex).spikes}, ...
    'UniformOutput', false));

id = zeros(numel(binEdges), 1);

% We determine which cells to include
% allCells = unique(clusters.spike_id);
allCells = union(place_fields.track(track).good_cells, place_fields.track(track + 2).good_cells);
% allCells = place_fields.pyramidal_cells;

for i = 1:numel(allMatchingReplay)
    currentID = allMatchingReplay(i);

    % We get the beggining and end of the event
    startEvent = decoded_replay_events(track).replay_events(currentID).spikes(1, 2);
    endEvent = decoded_replay_events(track).replay_events(currentID).spikes(end, 2);
    
    id(binEdges <= endEvent & binEdges >= startEvent) = currentID;

end

% We create a big histogram of each spike of each cell
histBinned = zeros(length(allCells), length(binEdges) - 1);

for i = 1:length(allCells)
    cell = allCells(i);

    % We get the histcount for that cell, and happend to the big hist
    currentHist = histcounts(allTimesConcat(allSpikesConcat == cell), binEdges);

    histBinned(i, :) = currentHist;
end

% No smoothing, we are only considering single time points

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


writetable(t, "replayDataDec.csv")