% Function to get the sleep replay between certain timestamps
% Only consider the cumulative first 30 minutes of sleeping times !

function [allMatchingReplay, timeVector] = getAllSleepReplay(track, startTime,stopTime, replay_events, sleep_state, ...
                                                             cumTime)

if ~exist("cumTime", "var")
    cumTime = 30;
end

% We get the sleeping state each timepoint and we interpolate the correspondant time
stateVec = sleep_state.state;
timeVec = linspace(sleep_state.time(1), sleep_state.time(end), numel(stateVec));
freq = timeVec(end) - timeVec(end - 1); % number of second per bin

stateVec = stateVec(timeVec <= stopTime & timeVec >= startTime);
stateVec(stateVec == -1) = 0; % We convert to a logical
stateVec = logical(stateVec);
timeVec = timeVec(timeVec <= stopTime & timeVec >= startTime);

% We find when the cumulative duration of sleep is bigger than 30 minutes, 
% and we switch everything after to 0 (awake)

cumsumSleep = cumsum(stateVec)*freq;
id30Minutes = find(cumsumSleep >= cumTime*60, 1);
stateVec(id30Minutes:end) = 0;

% Now we return all the replay events in that range

% If the file is significant replay events
if isfield(replay_events, "track")
    allTimesReplay = replay_events.track(track).event_times;
else % If this is decoded replay events
    allTimesReplay = cellfun(@(x) x(1), {replay_events(track).replay_events.timebins_edges}); % Take the start of each SWR
end

allMatchingReplay = [];
timeVector = [];

for re = 1:numel(allTimesReplay)
    % Find the timebin where the replay happend
    findTB = find(timeVec <= allTimesReplay(re) & timeVec + freq >= allTimesReplay(re), 1);

    % Now, if the replay event is still here, it's saved
    if stateVec(findTB) == 1
        allMatchingReplay = [allMatchingReplay; re];
        timeVector = [timeVector; cumsumSleep(findTB)/max(cumsumSleep)];
    end
end

% Now we return the list of good replay events indices

end

