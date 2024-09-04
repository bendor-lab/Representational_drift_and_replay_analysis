% Generate a table with animal, condition, stability at the end of RUN1,
% PV-correlation with the FPF and replay participation.

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths

% Arrays to hold all the data

sessionID = [];
animal = [];
cell = [];
condition = [];
track = [];

nbInter = []; % Nb of interneurons
refinCorr = [];
corrEndRUN1 = [];

numberSWR = [];
firingChangeRest = [];


parfor fileID = 1:length(sessions)
    
    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    
    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    
    % Load the variables
    
    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;
    
    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;
    
    temp = load(file + "\extracted_laps.mat");
    lap_times = temp.lap_times;
    
    % temp = load(file + "\extracted_directional_lap_place_fields");
    % lap_directional_place_fields = temp.lap_directional_place_fields;
    
    % Track loop
    
    for trackOI = 1:2
        
        % Good cells : cells that become good place cells on RUN2
        % goodCells = union(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);
        % goodCells = intersect(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);
        goodCells = place_fields.interneurons;
        
        current_nb_inter = numel(goodCells);
        
        if current_nb_inter == 2
            continue;
        end
        
        % We get the replay participation
        
        temp = load(file + "\Replay\RUN1_Decoding\decoded_replay_events");
        decoded_replay_events = temp.decoded_replay_events;
        
        % Fetch the sleep times to filter POST1 replay events
        temp = load(file +  "/extracted_sleep_stages");
        sleep_state = temp.sleep_state;
        startTime = sleep_state.state_time.INTER_post_start;
        endTime = sleep_state.state_time.INTER_post_end;
        
        sleepSWRID = getAllSleepReplay(trackOI, startTime, endTime, decoded_replay_events, sleep_state);
        current_nbSWR = numel(sleepSWRID);
        
        % We get the final place field : mean of the 6 laps following the
        % 16th lap of RUN2
        
        RUN1LapPFData = lap_place_fields(trackOI).Complete_Lap;
        RUN2LapPFData = lap_place_fields(trackOI + 2).Complete_Lap;
        
        numberLapsRUN2 = length(RUN2LapPFData);
        
        finalPlaceField = {};
        
        % For each cell, we create the final place field
        for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
            temp = [];
            
            for lap = 1:6
                temp = [temp; RUN2LapPFData{16 + lap}.smooth{cellID}];
            end
            
            finalPlaceField(end + 1) = {mean(temp, 'omitnan')};
        end
        
        pvCorRUN1 = getPVCor(goodCells, RUN1LapPFData{end}.smooth, finalPlaceField, "pvCorrelation");
        pvCorRUN2 = getPVCor(goodCells, RUN2LapPFData{1}.smooth, finalPlaceField, "pvCorrelation");
        
        current_refinement = median(pvCorRUN2, 'omitnan') - median(pvCorRUN1, 'omitnan');
        
        % Get the amount of spikes during REST
        
        temp = load(file + "\extracted_clusters");
        clusters = temp.clusters;
        
        temp = load(file + "\extracted_sleep_state");
        sleep_state = temp.sleep_state;
        
        isSleeping = sleep_state.state_binned;
        sleepTime = sleep_state.time;
        
        allFrChanges = [];
        
        for c = goodCells
            % get spikes from this interneuron
            spikes_inter = (clusters.spike_id == c);
            baseline_FR = place_fields.track(trackOI).mean_rate_track(c);
            
            % We get the REST firing rate
            spikesREST = spikes_inter & ...
                clusters.spike_times <= endTime & ...
                clusters.spike_times >= startTime;
            
            nbSpikes = sum(spikesREST); % Nb of spikes during rest
            
            spikeTimesREST = clusters.spike_times(spikesREST);
            binned_spikes = histcounts(spikeTimesREST, ...
                            [sleepTime sleepTime(end) + mode(diff(sleepTime))]);
            
            binned_sleep_spikes = binned_spikes(isSleeping == 1);
            
            % rest_firing_rate = nbSpikes/(endTime - startTime);
            
            rest_firing_rate = sum(binned_sleep_spikes)/(endTime - startTime);
            deltaFR = (rest_firing_rate - baseline_FR)/baseline_FR;
            
            % We get the refinement as difference in correlation
            
            corRUN1 = corrcoef(RUN1LapPFData{end}.smooth{c}, finalPlaceField{c});
            corRUN2 = corrcoef(RUN2LapPFData{1}.smooth{c}, finalPlaceField{c});
            
            current_refinement = corRUN2(1, 2) - corRUN1(1, 2);

            
            % Save the data
            
            sessionID = [sessionID; fileID];
            animal = [animal; animalOI];
            cell = [cell; fileID*1000 + c];
            condition = [condition; conditionOI];
            track = [track; trackOI];
            refinCorr = [refinCorr; current_refinement];
            
            corrEndRUN1 = [corrEndRUN1; median(pvCorRUN1, 'omitnan')];
            numberSWR = [numberSWR; current_nbSWR];
            firingChangeRest = [firingChangeRest; deltaFR];
        end
        
    end
end

% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

data = table(sessionID, animal, cell, condition, refinCorr, corrEndRUN1, ...
    numberSWR, firingChangeRest);

save("interneuronsPV.mat", "data")
data.logCondC = log2(data.condition) - mean(log2(data.condition));
fitlme(data, "refinCorr ~ logCondC + firingChangeRest + (1|animal) + (1|animal:cell)")
fitlme(data, "firingChangeRest ~ logCondC + (1|animal) + (1|animal:cell)")

datac = data(data.firingChangeRest < 5, :);
scatter(datac.refinCorr, datac.firingChangeRest)