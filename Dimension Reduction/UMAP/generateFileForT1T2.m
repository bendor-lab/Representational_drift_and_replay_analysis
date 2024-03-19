clear

currentPath = data_folders_excl_legacy;
currentPath = currentPath{2};

direction = 1;
unilateral = 2; % 2 for unilateral, 1 for bi
groupBy = 1;
speed_th = 5;

% Parameters for the speed filter

trigger_position = 15; % 15 cm before the end / after the start

% Load the data

load(currentPath + "/extracted_laps");
load(currentPath + "/extracted_clusters");
load(currentPath + "/extracted_place_fields");
load(currentPath + "/extracted_directional_place_fields");

load(currentPath + "/extracted_position");

% Creates the array to hold the data
x_array = [];
track_array = [];
lap_array = [];
speed_array = [];
hist_array = [];
exposure_array = [];

for track = 1:2

    for exposure = 1:2

        trackOI = track + (exposure == 2)*2;

        % Start and end times of the whole session
        startTime = lap_times(trackOI).completeLaps_start(1);
        endTime = lap_times(trackOI).completeLaps_stop(end);

        % Get the position of the animal across time
        positionArray = position.linear(trackOI).linear;
        timePositionBool = position.t <= endTime & position.t >= startTime;
        positionArray = positionArray(timePositionBool);
        % Get the speed of the animal at each time
        position_speed = abs(position.v_cm);

        % Create the new time vector - .100 s
        binEdges = startTime:0.100:endTime + 0.100;  % Create bins of timeBin intervals

        % Interpolate the position and the speed at each one of these times
        x = interp1(position.t(timePositionBool), positionArray, binEdges(1:end-1), 'nearest');
        interp_speed = interp1(position.t(timePositionBool), position_speed(timePositionBool), ...
            binEdges, 'nearest');

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

        % Direction filtering

        % if unilateral ~= 1
        %
        %     % We filter to get only data from when the animal is headed towards ONE direction
        %     % In lap_times, direction 1 is 200 -> 0 and -1 is reversed
        %
        %     headedDir = sign(diff(x));
        %     if direction == 1
        %         % We take the direction of the first lap
        %         dirWanted = lap_times(trackOI).initial_dir;
        %     else
        %         % We take the opposite direction
        %         dirWanted = (-1)*lap_times(trackOI).initial_dir;
        %     end
        %
        %     % Now we NaN every position that's when the animal is headed in the
        %     % wrong direction
        %     headedDir = [0 headedDir]; % Add an element to the front cause one less
        %     headedDir(headedDir == 0) = dirWanted;
        %     x(headedDir ~= dirWanted) = NaN;
        % end

        % Speed filtering
        % NaN the rows of the hist where the speed is less than 5 cm / s
        histBinned(:, interp_speed < speed_th) = NaN;

        % Position filtering

        % We find all the moments where the position was less / more than our
        % threshold

        xLessTh = x < trigger_position;
        xSupTh = x > 200 - trigger_position;

        % We NaN all the values not in our threshold
        x(xLessTh | xSupTh) = NaN;


        % We extract all the half laps we're interested in with the bool
        % runningTimes

        runningTimes = zeros(1, length(binEdges) - 1);
        lapVector = zeros(1, length(binEdges) - 1);

        % Careful : if not the same starting direction between RUN1 and RUN2,
        % take that into account
        if lap_times(track).initial_dir ~= lap_times(track + 2).initial_dir
            if exposure == 2
                startingDir = direction + 1;
            else
                startingDir = direction;
            end
        else
            startingDir = direction;
        end


        halfLaps = startingDir:unilateral:length(lap_times(trackOI).halfLaps_start);
        nbLaps = numel(halfLaps);

        if unilateral == 2
            numberWholeGroups = floor(nbLaps/groupBy);
            numberMod = mod(nbLaps, groupBy);
            labels = repelem(1:numberWholeGroups, groupBy);
            if numberMod ~= 0
                labels(end+1:end+numberMod) = repelem(numberWholeGroups + 1, numberMod);
            end
        else
            labels = 1:nbLaps;
        end

        if exposure == 2
            labels = labels + max(lap_array(track_array == track));
        end

        for lid = 1:nbLaps

            half_lap = halfLaps(lid);
            label = labels(lid);

            runningTimes(binEdges <= lap_times(trackOI).halfLaps_stop(half_lap) & ...
                binEdges >= lap_times(trackOI).halfLaps_start(half_lap)) = 1;

            lapVector(binEdges <= lap_times(trackOI).halfLaps_stop(half_lap) & ...
                binEdges >= lap_times(trackOI).halfLaps_start(half_lap)) = label;

        end

        % We NaN if not running
        histBinned(:, ~logical(runningTimes)) = NaN;

        % We flip the data vectors to create a table
        lap = lapVector';
        speed = interp_speed(1:end-1)';
        x = x';
        tr = repelem(track, numel(speed))';

        % Now we can pivot the hist
        histBinned = histBinned';

        % We filter the cells we want to study

        % cellLabel = place_fields_BAYESIAN.other_cells;
        % cellLabel = allCells(~ismember(allCells, union(place_fields.track(track).good_cells, place_fields.track(track + 2).good_cells)));
        cellLabel = union(place_fields.track(track).good_cells, place_fields.track(track + 2).good_cells);
        % cellLabel = place_fields.pyramidal_cells;
        % cellLabel = allCells;

        % pfDir1 = directional_place_fields(1).place_fields.track(trackOI).smooth;
        % pfDir2 = directional_place_fields(2).place_fields.track(trackOI).smooth;
        % [directionalCells, ~] = getDirectionalCells(pfDir1, pfDir2);
        % % cellLabel = directionalCells;
        % cellLabel = allCells(~ismember(allCells, directionalCells));

        histBinned = histBinned(:, cellLabel);

        % We save the data

        x_array = [x_array; x];
        track_array = [track_array; tr];
        lap_array = [lap_array; lap];
        speed_array = [speed_array; speed];
        hist_array = [hist_array; histBinned];
        exposure_array = [exposure_array; repelem(exposure, numel(speed))'];
    end

end

% Rename the array to have nice variable names in the csv

x = x_array;
lap = lap_array;
speed = speed_array;
hist = hist_array;
track = track_array;
exposure = exposure_array;

t = table(x, lap, track, exposure, speed);

for c = 1:numel(cellLabel)
    cell = cellLabel(c);
    lab = "c" + cell;
    values = hist(:, c);

    t.(lab) = values;
end

t = rmmissing(t);

writetable(t, "doubleTrackData.csv")

%%


% Function to get directional place cells based on Foster 2008 criteria
% Note : does not filters out bad place cells / non-pyramidal pc

function [directionalCells, dirOP] = getDirectionalCells(pfDir1, pfDir2)
peakDir1 = cellfun(@(x) max(x), pfDir1);
peakDir2 = cellfun(@(x) max(x), pfDir2);

directionalCells = find(peakDir1./peakDir2 >= 2 | peakDir1./peakDir2 <= 0.5);
dirOP = (peakDir1./peakDir2 >= 2)*1 + (peakDir1./peakDir2 <= 0.5)*2;
dirOP = dirOP(directionalCells);
end



