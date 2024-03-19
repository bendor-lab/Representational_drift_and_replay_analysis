% Function to get the sleep replay between certain timestamps
% Only consider the cumulative first 30 minutes of sleeping times !

function [allMatchingReplay] = getAllSleepReplay(track, startTime,stopTime, significant_replay_events, sleep_state)

% We get the sleeping state each timepoint and we interpolate the correspondant time
stateVec = sleep_state.state;
timeVec = linspace(sleep_state.time(1), sleep_state.time(end), numel(stateVec));
freq = timeVec(end) - timeVec(end - 1);

stateVec = stateVec(timeVec <= stopTime & timeVec >= startTime);
stateVec(stateVec == -1) = 0; % We convert to a logical
stateVec = logical(stateVec);
timeVec = timeVec(timeVec <= stopTime & timeVec >= startTime);

% We find when the cumulative duration of sleep is bigger than 30 minutes, 
% and we switch everything after to 0 (awake)

cumsumSleep = cumsum(stateVec);
id30Minutes = find(cumsumSleep >= 1800/freq, 1);
stateVec(id30Minutes:end) = 0;

% Now we return all the replay events in that range

allTimesReplay = significant_replay_events.track(track).event_times;

allMatchingReplay = [];

for re = 1:numel(allTimesReplay)
    % Find the timebin where the replay happend
    findTB = histcounts(allTimesReplay(re), [timeVec timeVec(end) + freq]);

    % remove all the timebin when the animal was awake
    findTB(~stateVec) = 0;

    % Now, if the replay event is still here, it's saved
    if sum(findTB) ~= 0
        allMatchingReplay = [allMatchingReplay; re];
    end
end

% Now we return the list of good replay events indices

end

