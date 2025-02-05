% Function to get the awake replay between certain timestamps

function [allMatchingReplay, timeVector] = getAllAwakeReplay(track, startTime,stopTime, replay_events, sleep_state)

% We get the sleeping state each timepoint and we interpolate the correspondant time
stateVec = sleep_state.state;
timeVec = linspace(sleep_state.time(1), sleep_state.time(end), numel(stateVec));
freq = timeVec(end) - timeVec(end - 1); % number of second per bin

stateVec = stateVec(timeVec <= stopTime & timeVec >= startTime);
stateVec(stateVec == 1) = 0; % Sleep is 0
stateVec(stateVec == -1) = 1; % Awake is 1
stateVec = logical(stateVec);
timeVec = timeVec(timeVec <= stopTime & timeVec >= startTime);

cumsumAwake = cumsum(stateVec)*freq;
% id30Minutes = find(cumsumSleep >= 1800, 1);
% stateVec(id30Minutes:end) = 0;

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
        timeVector = [timeVector; cumsumAwake(findTB)/60]; % cumulative
        
        % timeVector = [timeVector; (allTimesReplay(re) - startTime)/60];
    end
end

% Now we return the list of good replay events indices

end

