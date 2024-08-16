% Testing drift monitoring during sleep using replay events

sID = 3;
trackOI = 1;

sessions = data_folders_excl;
sessions_legacy = data_folders_excl_legacy;

file = sessions{sID};
file_legacy = sessions_legacy{sID};

% Load the necessery files

temp = load(file + "/extracted_place_fields_BAYESIAN");
place_fields_BAYESIAN = temp.place_fields_BAYESIAN;

temp = load(file + "/extracted_sleep");
sleep_states = temp.sleep_states;

temp = load(file + "/Replay/RUN1_decoding/significant_replay_events");
significant_replay_events = temp.significant_replay_events;

% Select the target cell

all_cells = place_fields_BAYESIAN.track(trackOI).good_cells;
cellOI = all_cells(3);

% We find all the replay events where that cell was involved
% Take all replay
all_spikes = significant_replay_events.track(trackOI).spikes;
% Only filtering replay during POST1 sleep
startTime = sleep_states;
[allMatchingReplay, ~] = getAllSleepReplay(trackOI, startTime,stopTime, ...
                         replay_events, sleep_state, 1000);

all_spikes = all_spikes(allMatchingReplay);

valid_index = [];
all_times_fire = []; % All times when the cell fired (usefull for later)

for rev = 1:numel(all_spikes)
    all_part_cells = all_spikes{rev}(:, 1);
    is_cell_part = ismember(cellOI, all_part_cells);
    if is_cell_part 
        valid_index(end + 1) = rev; 
        all_times_fire = [all_times_fire all_spikes{rev}(:, all_part_cells == cellOI)];
    end
end





