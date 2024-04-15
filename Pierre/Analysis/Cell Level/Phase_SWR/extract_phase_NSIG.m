% Function to extract the number of participation in SWR at a certain phase
% Also returns the vector of cellID

function [phasePartMatrice, meanPhaseVector, phaseLocking, significance, unique_cells] = extract_phase_NSIG(CSC, sleep_state, decoded_replay_events, significant_replay_events, track)

%% 1. Loading & cropping

% We find the best channel for the SWR analysis
best_channel_line = find(string({CSC.channel_label}) == 'best_ripple');

% We get the LFP from the best ripple channel
swr_vector = CSC(best_channel_line).ripple;
lfp_times = CSC(best_channel_line).CSCtime;

% We find the times of sleep
startTime = sleep_state.state_time.INTER_post_start;
endTime = sleep_state.state_time.INTER_post_end;

% We can crop all the times not during POST1
swr_vector = swr_vector(lfp_times <= endTime & lfp_times >= startTime);
lfp_times = lfp_times(lfp_times <= endTime & lfp_times >= startTime);

%% 2. We find the phase at each timebin

swr_phase = angle(hilbert(swr_vector));
swr_power = abs(hilbert(swr_vector));
swr_unwrap = unwrap(swr_phase); % unwrap for interpolation


%% 3. We find every sleep replay event

allGoodDec = getAllSleepReplay(track, startTime, endTime, decoded_replay_events, sleep_state);

% Find all the significant events during sleep
sleepSWR = getAllSleepReplay(track, startTime, endTime, significant_replay_events, sleep_state);
sigIndex = significant_replay_events.track(track).ref_indexs(sleepSWR);

sleepSWR = sediff(allGoodDec, sigIndex);

a = []; % structure to hold every spike / spike time / replay id
for replayID = 1:numel(sleepSWR)
    dataCurrentRep = decoded_replay_events(sleepSWR(replayID)).spikes;
    dataCurrentRep(:, 3) = sleepSWR(replayID);
    a = [a; dataCurrentRep];
end

disp("Found all sleep SWR");

%% 4. Now we keep only the spikes that happened during the real SWR (band between peak and 1 STD)

% We z-score the filtered LFP
z_swr = normalize(swr_power, "zscore");

validSpikesBool = [];

for replayID = 1:numel(sleepSWR)
    cID = sleepSWR(replayID);
    allTimes = a(a(:, 3) == cID, 2);
    stTime = allTimes(1);
    enTime = allTimes(end);

    % We get the ripple power between those times
    current_zswr = z_swr(lfp_times <= enTime & lfp_times >= stTime);
    current_swr_time = lfp_times(lfp_times <= enTime & lfp_times >= stTime);

    if isempty(current_zswr)
        continue;
    end

    % We find the all the local max > 5 std
    [local_maxs, loc_local_maxs] = findpeaks(current_zswr);
    loc_local_maxs = loc_local_maxs(local_maxs > 5);
    local_maxs = local_maxs(local_maxs > 5);

    % We find all the points where the ripple power is < 1
    lessOneRP = current_zswr < 1;

    % We find all the transition points
    transPoints = diff(lessOneRP);

    % We find, for each, the previous point closer to 1 std,and the next
    % point closer to 1 std

    spikeValidityMat = zeros(numel(allTimes), 1);

    for lID = 1:numel(local_maxs)

        % Define the current max
        current_max = local_maxs(lID);
        max_location = loc_local_maxs(lID);

        % Find the indices of all the transition points
        allLower = find(transPoints == -1);
        allLower(allLower > max_location) = [];
        allUpper = find(transPoints == 1);
        allUpper(allUpper < max_location) = [];

        if isempty(allLower)
            current_lower_ID = 1;
        else
            % Find the distance of all these transition points with the index
            % of the max
            distanceToPeakLow = abs(allLower - max_location); % Distance from the peak

            % Find the ID of the closest -1 transition point
            current_lower_ID = allLower(distanceToPeakLow == min(distanceToPeakLow));

            % We take whether point on each side of the tranisition which has
            % the smallest difference with 0;

            values_trans = current_zswr(current_lower_ID);
            concurrentPointLow = current_zswr(current_lower_ID + 1);

            if abs(values_trans - 1) > abs(concurrentPointLow - 1)
                current_lower_ID = current_lower_ID + 1;
            end
        end

        if isempty(allUpper)
            current_upper_ID = numel(current_zswr);
        else
            % Find the distance of all these transition points with the index
            % of the max

            distanceToPeakHigh = abs(allUpper - max_location);

            % Find the ID of the closest -1 transition point
            current_upper_ID = allUpper(distanceToPeakHigh == min(distanceToPeakHigh));

            % We take whether point on each side of the tranisition which has
            % the smallest difference with 0;

            values_trans = current_zswr(current_upper_ID);
            concurrentPointLow = current_zswr(current_upper_ID - 1);

            if abs(values_trans - 1) > abs(concurrentPointLow - 1)
                current_upper_ID = current_upper_ID - 1;
            end

        end

        % We find the times binded with each of these indexes
        timeStartValid = current_swr_time(current_lower_ID);
        timeStopValid = current_swr_time(current_upper_ID);

        % Now we can assign 1 to every values between those bounds
        spikeValidityMat(allTimes <= timeStopValid & allTimes >= timeStartValid) = 1;
    end

    % Now we can add to our spike register only the SWR spikes

    validSpikesBool = [validSpikesBool; spikeValidityMat];
end

disp("Filtered all spikes");

%% 5. We can filter based on our bool mat, match phase and calculate mat

a = a(logical(validSpikesBool), :);

allSpikes = a(:, 1);
allTimes = a(:, 2);

allPhases = interp1(lfp_times, swr_unwrap, allTimes);
allPhases = mod(allPhases, 2*pi); % We re-wrap

% We bin the phases to 2pi/8
allPhasesBinned = discretize(allPhases, 0:pi/4:2*pi);
occupancyPhase = allPhasesBinned;

unique_phases = 1:8;
unique_cells = unique(allSpikes);
phasePartMatrice = zeros(numel(unique_cells), numel(unique_phases));

for phaseID = 1:numel(unique_phases)
    for cellID = 1:numel(unique_cells)

        current_phase = unique_phases(phaseID);
        current_cell = unique_cells(cellID);

        numberOccurences = sum(allSpikes == current_cell & allPhasesBinned == current_phase);
        phasePartMatrice(cellID, phaseID) = numberOccurences;
    end
end

%% 6. We get the mean phase of each cell

meanPhaseVector = zeros(1, numel(unique_cells));
phaseLocking = zeros(1, numel(unique_cells));
significance = zeros(1, numel(unique_cells));

for cellID = 1:numel(unique_cells)
    current_cell = unique_cells(cellID);

    % We get the phase of each spike
    current_coll_phases = allPhases(allSpikes == current_cell);

    % We get the x and y coordinates of the vector
    current_x = cos(current_coll_phases);
    current_y = sin(current_coll_phases);

    % We find the mean phase and the vector strength
    current_mean_phase = atan2(sum(current_y), sum(current_x));
    current_v_strength = sqrt(sum(current_y)^2 + sum(current_x)^2)/sum(allSpikes == current_cell);

    % We get the Rayleigh value. If >= 13.8, p < .001
    isSig = 2*sum(allSpikes == current_cell)*current_v_strength^2 >= 13.8;

    meanPhaseVector(cellID) = current_mean_phase;
    phaseLocking(cellID) = current_v_strength;
    significance(cellID) = isSig;
end

meanPhaseVector = meanPhaseVector + pi; % We want the vector to go from 0 to 2pi

end

