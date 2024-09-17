%% For a given cell, finds all the significant replay events
% furing POST1 during which this cell fires at least one

% ARGUMENTS : 
% - significant_replay_events file
% - sleep_state file
% - trackOI : track of interest
% - cellOI : cell of interest

function [valid_index] = getCellReplays(significant_replay_events, ...
                                   sleep_state, trackOI, cellOI)
                               
% Find spikes for all the sig replay events
all_spikes = significant_replay_events.track(trackOI).spikes;

% We filter these events if they happened during non POST1 sleep
startTime = sleep_state.state_time.INTER_post_start;
stopTime = sleep_state.state_time.INTER_post_end;
[allMatchingReplay, ~] = getAllSleepReplay(trackOI, startTime,stopTime, ...
    significant_replay_events, sleep_state, 1000);

valid_index = []; % for sign replay event file

% For the valid events, if the cell participated, we add the id
for rev = allMatchingReplay'
    all_part_cells = all_spikes{rev}(:, 1);
    is_cell_part = ismember(cellOI, all_part_cells);
    if is_cell_part
        valid_index(end + 1) = rev;
    end
end

end

