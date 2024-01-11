
function replay_decoding_split_events_final_lap
% Splits each replay event approximately in half, based on when the MUA is
% lowest in the middle third of the event.  This is used to seperately analyze the
% first and second half of long duration replay events

% Load parameters
parameters = list_of_parameters;
load('replay_control_final_lap\decoded_replay_events.mat') 
load('Bayesian controls\Only first exposure\extracted_replay_events.mat'); %raw replay events 

num_replay_events = length(decoded_replay_events(1).replay_events);

fnames= fieldnames(decoded_replay_events(1).replay_events);
fnames= [fnames' {'midpoint'} {'onset'} {'offset'} {'duration'}];
for track = 1:length(decoded_replay_events)
    decoded_replay_events1(track).replay_events=  cell2struct(cell(numel(fnames),1),fnames);
    decoded_replay_events2(track).replay_events=  cell2struct(cell(numel(fnames),1),fnames);
    [decoded_replay_events(track).replay_events(:).midpoint]= deal(NaN);
    [decoded_replay_events(track).replay_events(:).onset]= deal(NaN);
    [decoded_replay_events(track).replay_events(:).offset]= deal(NaN);
    [decoded_replay_events(track).replay_events(:).duration]= deal(NaN);
end

for track = 1 : length(decoded_replay_events)
    for event = 1 : num_replay_events
        
        spikes = decoded_replay_events(track).replay_events(event).spikes(:,2);  %spike times for this replay event
        
        % Find time bin where midpoint of replay event occurs (where the event is split)
        [~,index] = min(abs(decoded_replay_events(track).replay_events(event).timebins_centre-replay.midpoint(event)));
        bin_after_index = index+1; % to allow segments to overlap by one bin
        if bin_after_index>length(decoded_replay_events(track).replay_events(event).timebins_edges) % if index is the last timebin_edge value
            bin_after_index = length(decoded_replay_events(track).replay_events(event).timebins_edges);
        end
        
        % Each event is split into two segments: decoded_replay_events1 and decoded_replay_events2
        % Create structure for the first replay segment
        decoded_replay_events1(track).replay_events(event).replay_id = decoded_replay_events(track).replay_events(event).replay_id;
        decoded_replay_events1(track).replay_events(event).midpoint = replay.midpoint(event);
        decoded_replay_events1(track).replay_events(event).onset = replay.onset(event);
        decoded_replay_events1(track).replay_events(event).offset = replay.midpoint(event); %new offset will be where the replay event is split
        decoded_replay_events1(track).replay_events(event).duration = replay.midpoint(event)-replay.onset(event);
        
        % Find spike IDs and times for each event, split them by the segments and save
        spike_index1 = find(spikes<=replay.midpoint(event)); % spikes in segment 1
        decoded_replay_events1(track).replay_events(event).spikes(:,1) = decoded_replay_events(track).replay_events(event).spikes(spike_index1,1); % spike IDs
        decoded_replay_events1(track).replay_events(event).spikes(:,2) = decoded_replay_events(track).replay_events(event).spikes(spike_index1,2); % spike times
        
        % Split timebins and decoded event by the segments and save: 
            % set 1 overlapping bin between segments
        decoded_replay_events1(track).replay_events(event).timebins_edges = decoded_replay_events(track).replay_events(event).timebins_edges(1:bin_after_index); 
        decoded_replay_events1(track).replay_events(event).timebins_centre = decoded_replay_events(track).replay_events(event).timebins_centre(1:index);
        decoded_replay_events1(track).replay_events(event).timebins_index = 1:index;
        decoded_replay_events1(track).replay_events(event).decoded_position = decoded_replay_events(track).replay_events(event).decoded_position(:,1:index);

        
        % Create structure for the second replay segment     
        decoded_replay_events2(track).replay_events(event).replay_id = decoded_replay_events(track).replay_events(event).replay_id;
        decoded_replay_events2(track).replay_events(event).midpoint = replay.midpoint(event);
        decoded_replay_events2(track).replay_events(event).onset = replay.midpoint(event); %onset for the second segment will be where the replay event is split
        decoded_replay_events2(track).replay_events(event).offset = replay.offset(event);
        decoded_replay_events2(track).replay_events(event).duration = replay.offset(event)-replay.midpoint(event);
        
        % Find spike IDs and times for each event, split them by the segments and save
        spike_index2 = find(spikes>=replay.midpoint(event)); % spikes in segment 2
        decoded_replay_events2(track).replay_events(event).spikes(:,1) = decoded_replay_events(track).replay_events(event).spikes(spike_index2,1);
        decoded_replay_events2(track).replay_events(event).spikes(:,2) = decoded_replay_events(track).replay_events(event).spikes(spike_index2,2);
        
        % Split timebins and decoded event by the segments and save: 
            % set 1 overlapping bin between segments
        decoded_replay_events2(track).replay_events(event).timebins_edges = decoded_replay_events(track).replay_events(event).timebins_edges(index:end);
        decoded_replay_events2(track).replay_events(event).timebins_centre = decoded_replay_events(track).replay_events(event).timebins_centre(index:end);
        decoded_replay_events2(track).replay_events(event).timebins_index = index:length(decoded_replay_events(track).replay_events(event).timebins_centre);
        decoded_replay_events2(track).replay_events(event).decoded_position = decoded_replay_events(track).replay_events(event).decoded_position(:,index:end);
    end
end

% Saves structure
save('replay_control_final_lap\decoded_replay_events_segments.mat','decoded_replay_events1','decoded_replay_events2','-v7.3')
end


