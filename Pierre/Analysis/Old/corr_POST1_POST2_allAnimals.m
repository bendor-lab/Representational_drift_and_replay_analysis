% For each cell and each session, compute the relative participation to the
% relpay events FOR TRACK N - All animals together

sessions = data_folders_excl; % Use the function to get all the file paths

animal_cell = {};
condition_cell = {};
track_cell = {};
activityMat_cell = {};

% Test

for sIndex = 1:length(sessions)
   
    session_string = sessions(sIndex);
    session_sliced = split(session_string, '\');
    % Based on this, infos on the data
    animalOI = char(session_sliced(end-1));
    conditionOI = split(session_sliced(end), '_');
    conditionOI = char(conditionOI(end));
    
    disp("Processing " + animalOI + " - " + conditionOI);

    % Base path for all the loadings
    base_path = string(session_string);

    % We get the nb of good neurons
    load(base_path + "\extracted_place_fields_BAYESIAN");
    nb_good_neurons = length(place_fields_BAYESIAN.good_place_cells);

    %%% We iterate to compare track 1 and track 2

    for trackOI = 1:2
        % Mat storing CellID / nb replay Inter Sleep / mnb replay Final Sleep

        activityMat = [(1:nb_good_neurons)', repelem(0, nb_good_neurons)', repelem(0, nb_good_neurons)'];

        % We get the events to identity sleep sessions

        load(base_path + "\extracted_sleep_state");

        InterStart = sleep_state.state_time.INTER_post_start;
        InterStop = sleep_state.state_time.INTER_post_end;

        FinalStart = sleep_state.state_time.FINAL_post_start;
        FinalStop = sleep_state.state_time.FINAL_post_end;

        %% We get the replay data based on POST1 - Track N

        % DECODED no p value (to retrieve data)
        load(base_path + '\Bayesian controls\Only first exposure\decoded_replay_events');
        replayDataPOST1 = decoded_replay_events(trackOI).replay_events;

        % P < .05 for INDEXING
        load(base_path + '\Bayesian controls\Only first exposure\significant_replay_events_wcorr');
        replayRegisterPOST1 = significant_replay_events.track(trackOI);

        % We create a list of all the cells involved in RE between these timestamps

        % bool mat of all valid timestamps
        isDuringInterSleep = (replayRegisterPOST1.event_times <= InterStop) & (replayRegisterPOST1.event_times >= InterStart);

        % We take the list of replay events ID during this sleep
        allIDMatInter = replayRegisterPOST1.ref_index(isDuringInterSleep);

        % We get the ID of each event
        for i = 1:length(allIDMatInter)
            current_ID = allIDMatInter(i);
            % Then we go to decoded events to retrieve the information, here cells
            % involved
            current_event = replayDataPOST1([replayDataPOST1.replay_id] == current_ID).spikes;
            all_ID = current_event(:, 1);

            % We increment each cell counter accordingly - IF THEY ARE GOOD CELLS
            for j = 1:length(all_ID)
                if(all_ID(j) <= nb_good_neurons)
                    activityMat(all_ID(j), 2) = activityMat(all_ID(j), 2) + 1;
                end
            end
        end

        %% We get the replay data based on POST2 - Track N

        % DECODED no p value (to retrieve data)
        load(base_path + '\Bayesian controls\Only re-exposure\decoded_replay_events');
        replayDataPOST2 = decoded_replay_events(trackOI).replay_events;

        % P < .05 for INDEXING
        load(base_path + '\Bayesian controls\Only re-exposure\significant_replay_events_wcorr');
        replayRegisterPOST2 = significant_replay_events.track(trackOI);

        % We create a list of all the cells involved in RE between these timestamps

        % bool mat of all valid timestamps
        isDuringFinalSleep = (replayRegisterPOST2.event_times <= FinalStop) & (replayRegisterPOST2.event_times >= FinalStart);

        % We take the list of replay events ID during this sleep
        allIDMatFinal = replayRegisterPOST2.ref_index(isDuringFinalSleep);

        % We get the ID of each event
        for i = 1:length(allIDMatFinal)
            current_ID = allIDMatFinal(i);
            % Then we go to decoded events to retrieve the information, here cells
            % involved
            current_event = replayDataPOST2([replayDataPOST2.replay_id] == current_ID).spikes;
            all_ID = current_event(:, 1);

            % We increment each cell counter accordingly - IF THEY ARE GOOD CELLS
            for j = 1:length(all_ID)
                if(all_ID(j) <= nb_good_neurons)
                    activityMat(all_ID(j), 3) = activityMat(all_ID(j), 3) + 1;
                end
            end
        end
        
        % We save the activity matrix in the cells
        animal_cell{end + 1} = animalOI;
        condition_cell{end + 1} = conditionOI;
        track_cell{end + 1} = trackOI;
        activityMat_cell{end + 1} = activityMat;
    end

end

corr_POST1_POST2 = struct("animal", animal_cell, "condition", condition_cell, "track", track_cell, "activityMat", activityMat_cell);
save('./Data/corr_POST1_POST2_data.mat', 'corr_POST1_POST2');

%% Plot Track 1 vs Track " for each condition

% subplot(5,2,trackOI + 2*counter_plot)
% scatter(activityMat(:, 2), activityMat(:, 3))
% xlabel("POST1");
% ylabel("POST2");
% titleFig = "Track " + trackOI;
% % If track 2, we also plot the nb of lab ran
% if(trackOI == 2)
%     conditionSplit = split(conditionOI, 'x');
%     nbLaps = conditionSplit(end);
%     titleFig = titleFig + " - " + nbLaps;
% end
% 
% title(titleFig)
