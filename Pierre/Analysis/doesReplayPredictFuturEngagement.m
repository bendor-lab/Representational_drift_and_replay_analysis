% Script to see if previous engagement in a track (0 / 1)
% + engagement during replay predict futur engagement in track 
% Currently only for 16 laps

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

% For now, only takes file 1

sessionsOI = string(sessions(:));

trackOI = 2;

% We create a supra activity matrice for all sessions

supActivityMat = [];

for base_path_ID = 1:length(sessionsOI)
    
    base_path = sessionsOI(base_path_ID);
    disp(base_path);
    
    %% We find, for each cell, it's involvment during
    %% POST1 and POST2 on track 1 / 3
    
    load(base_path + "\extracted_place_fields_BAYESIAN")
    
    % We only take pyramidal cells
    pyram = place_fields_BAYESIAN.pyramidal_cells;
    
    % We create an activity matrice for each cell
    activityMat = [pyram', repelem(0, length(pyram))', repelem(0, length(pyram))', repelem(0, length(pyram))'];
    
    % We add to the counter for number of spikes during POST1 / POST2
    
    % We get the timestamps
    
    load(base_path + "\extracted_laps");
    
    POST1Start = lap_times(trackOI).halfLaps_start(1); % Beginning of the first lap
    POST1Stop = lap_times(trackOI).halfLaps_stop(end); % End of the last lap
    
    POST2Start = lap_times(trackOI + 2).halfLaps_start(1); % Beginning of the first lap
    POST2Stop = lap_times(trackOI + 2).halfLaps_stop(end); % End of the last lap
    
    % We then load clusters and save all the cell ID which fired during
    % this periods
    
    load(base_path + "\extracted_clusters");
    boolMatIsSpikePOST1 = clusters.spike_times <= POST1Stop & clusters.spike_times >= POST1Start;
    boolMatIsSpikePOST2 = clusters.spike_times <= POST2Stop & clusters.spike_times >= POST2Start;
    
    [nbSpikesPOST1, cellPOST1] = groupcounts(clusters.spike_id(boolMatIsSpikePOST1));
    [nbSpikesPOST2, cellPOST2] = groupcounts(clusters.spike_id(boolMatIsSpikePOST2));
    
    % We remove the non-pyramidal cells
    nbSpikesPOST1 = nbSpikesPOST1(ismember(cellPOST1, pyram));
    cellPOST1 = cellPOST1(ismember(cellPOST1, pyram));
    nbSpikesPOST2 = nbSpikesPOST2(ismember(cellPOST2, pyram));
    cellPOST2 = cellPOST2(ismember(cellPOST2, pyram));

    % Finally, we add each spike to the counter
    
    for cell_Index = 1:length(cellPOST1)
        matching_cell_data = find(activityMat(:, 1) == cellPOST1(cell_Index));
        activityMat(matching_cell_data, 2) = nbSpikesPOST1(cell_Index);
    end
    
    for cell_Index = 1:length(cellPOST2)
        matching_cell_data = find(activityMat(:, 1) == cellPOST2(cell_Index));
        activityMat(matching_cell_data, 4) = nbSpikesPOST2(cell_Index);
    end
    
    %% We analyse the replay to get involvment counting
    
    % We get the events to identity sleep sessions

    load(base_path + "\extracted_sleep_state");
    
    InterStart = sleep_state.state_time.INTER_post_start;
    InterStop = sleep_state.state_time.INTER_post_end;
    
    % We get the replay data based on POST1 - Track N
    
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
        
        % We increment each cell counter accordingly - IF THEY ARE
        % PYRAMIDAL CELLS
        
        for j = 1:length(all_ID)
            if(any(pyram == all_ID(j)))
                good_index = find(activityMat(:, 1) == all_ID(j));
                activityMat(good_index, 3) = activityMat(good_index, 3) + 1;
            end
        end
    end

    % We compute the "drop score" of each cell between POST1 and POST2

    activityMat(:, 5) = activityMat(:, 4) - activityMat(:, 2);

    % We compute the "offset score" in term of place field shift for each
    % neuron

    offsetScore = place_fields_BAYESIAN.track(trackOI).peak - place_fields_BAYESIAN.track(trackOI+2).peak;
    activityMat(:, 6) = offsetScore(activityMat(:, 1));
    
    % We populate the big activity mat
    
    if isempty(supActivityMat)
        supActivityMat = activityMat;
    else
        supActivityMat = [supActivityMat ; activityMat];
    end

    % Participation to POST1 as a function of replay of POST2
    subplot(2, 3, 1)
    scatter(activityMat(:, 2), activityMat(:, 4))
    xlabel("Participation to POST1")
    ylabel("Participation to POST2")
    
    hold on;

    % Participation to POST1 as a function of replay of POST1
    subplot(2, 3, 2)
    scatter(activityMat(:, 2), activityMat(:, 3))
    xlabel("Participation to POST1")
    ylabel("Participation to POST1R")
    
    hold on;

    % Participation to POST2 as a function of replay of POST1
    subplot(2, 3, 3)
    scatter(activityMat(:, 3), activityMat(:, 4))
    xlabel("Participation to POST1R")
    ylabel("Participation to POST2")
    
    hold on;

    % difference of spikes RUN2 - RUN1 as a function of replay of POST1
    subplot(2, 3, 4)
    scatter(activityMat(:, 3), activityMat(:, 5))
    xlabel("Participation to POST1R")
    ylabel("ΔSpikes(POST2 - POST1)")
    
    hold on;

    % difference of place field peak position POST2 - POST1 as a function of replay of POST1
    subplot(2, 3, 5)
    scatter(activityMat(:, 3), activityMat(:, 6))
    xlabel("Participation to POST1R")
    ylabel("ΔPF(POST2 - POST1)")

    hold on;
    
end