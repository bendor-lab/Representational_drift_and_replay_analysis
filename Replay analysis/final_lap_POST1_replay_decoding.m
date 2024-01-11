% REPLAY DECODING
% Extracts spikes for each replay event and decodes it. Saves in a
% structure called decoded_replay_events. Inside each field (each track) the replay events are saved.
% Loads: extracted_replay_events, extracted_clusters and extracted_place_fields_BAYESIAN

function decoded_replay_events = final_lap_POST1_replay_decoding()

    % Load parameters
    parameters = list_of_parameters;
    % Load candidate events + single final lap extracted place fields
    load('Bayesian controls\Only first exposure\extracted_replay_events.mat');
    load('extracted_clusters.mat');
    load('extracted_lap_place_fields_BAYESIAN.mat');
    
    place_fields_BAYESIAN.track(1) = lap_place_fields_BAYESIAN(1).Complete_Lap{end}; % Finial lap from Track 1 RUN1
    place_fields_BAYESIAN.track(2) = lap_place_fields_BAYESIAN(2).Complete_Lap{end};% Finial lap from Track 2 RUN1
    
    place_fields_BAYESIAN.good_place_cells = unique([lap_place_fields_BAYESIAN(1).Complete_Lap{end}.good_cells...
        lap_place_fields_BAYESIAN(2).Complete_Lap{end}.good_cells]);
    save('replay_control_final_lap\extracted_place_fields_BAYESIAN.mat','place_fields_BAYESIAN','-v7.3')
    
    
    % REPLAY EVENTS STRUCTURE
    %replay_events is an empty template for replay event analysis.
    %Each track will create its own field

    replay_events = struct('replay_id',{},...%the id of the candidate replay events in chronological order
        'spikes',{});%column 1 is spike id, column 2 is spike time

    % TAKE SPIKES FROM ONLY GOOD PLACE FIELDS (on at least one track)
    
    sorted_spikes = zeros(size(clusters.spike_id));
    sorted_spikes(:,1) = clusters.spike_id;
    sorted_spikes(:,2) = clusters.spike_times;
    
    all_units = unique(clusters.spike_id);
    non_pyramidal = setdiff(all_units,place_fields_BAYESIAN.good_place_cells);
    for i = 1 : length(non_pyramidal)
        non_pyramidal_indices = find(sorted_spikes(:,1)== non_pyramidal(i));
        sorted_spikes(non_pyramidal_indices,:) = [];
        non_pyramidal_indices =[];
    end
    num_spikes = length(sorted_spikes);
    num_units = length(place_fields_BAYESIAN.good_place_cells);


    % EXTRACT SPIKES IN REPLAY EVENTS

    num_replay = size(replay.onset, 2);
    current_replay = 1;
    current_replay_spikes = [];
    for i = 1 : num_spikes
        if sorted_spikes(i,2) > replay.offset(current_replay)
            replay_events(current_replay).replay_id = current_replay;
            replay_events(current_replay).spikes = current_replay_spikes;
            current_replay = current_replay + 1;
            if current_replay > num_replay
                break
            end
            current_replay_spikes = [];

        end
        if sorted_spikes(i,2) >= replay.onset(current_replay)
            current_replay_spikes = [current_replay_spikes; sorted_spikes(i,:)];
        end
    end
    num_replay_events = length(replay_events);
    msg = [num2str(num_replay_events), ' candidate events.'];
    disp(msg);

    % Save all replay events all tracks
    for j = 1:2%length(place_fields_BAYESIAN.track)
        decoded_replay_events(j).replay_events = replay_events;
    end

    %%%%%% BAYESIAN DECODING ON REPLAY EVENTS %%%%%%
    replay_starts = replay.onset;
    replay_ends = replay.offset;
    
    % Get time vectors for bayesian decoding and matrix with spike count
    disp('Spike count...');
    replayEvents_bayesian_spike_count = spike_count(place_fields_BAYESIAN,replay_starts,replay_ends,'N');  % Takes a long time to run (few minutes)
    save('replay_control_final_lap\replayEvents_bayesian_spike_count.mat','replayEvents_bayesian_spike_count','-v7.3')
    
    % Run bayesian decoding
    disp('Decoding position...');
    estimated_position = bayesian_decoding(place_fields_BAYESIAN,replayEvents_bayesian_spike_count,[],'N');
    
    % Save in structure
    for j = 1:2%length(place_fields_BAYESIAN.track)
        for i = 1 : num_replay_events
            decoded_replay_events(j).replay_events(i).timebins_edges = estimated_position(j).replay_events(i).replay_time_edges; 
            decoded_replay_events(j).replay_events(i).timebins_centre = estimated_position(j).replay_events(i).replay_time_centered; 
            decoded_replay_events(j).replay_events(i).timebins_index = 1:length(estimated_position(j).replay_events(i).replay_time_centered);
            decoded_replay_events(j).replay_events(i).decoded_position = estimated_position(j).replay_events(i).replay; % normalized by 2 tracks
        end
    end

    % Saves structure
    save('replay_control_final_lap\decoded_replay_events.mat','decoded_replay_events','-v7.3')
end


