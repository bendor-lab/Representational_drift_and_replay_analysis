clear
sessions = data_folders_excl;

%% Define important storage vectors

session = [];
animal = [];
condition = [];
track = [];
lap = [];
cell = [];
variance_FR = [];
mean_FR = [];

for sID = 1:numel(sessions)
    
    disp(sID);
    
    %% Loading relevant files
    file = sessions{sID};
    
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    
    temp = load(file + "\extracted_place_fields");
    place_fields = temp.place_fields;
    
    temp = load(file + "\extracted_laps");
    lap_times = temp.lap_times;
    
    temp = load(file + "\extracted_clusters");
    clusters = temp.clusters;
    
    for trackOI = 1:4
        
        %% Identify the inhibitory interneurons
        % Based on firing rate for the entire session : > 28 Hz
        
        inter = place_fields.interneurons;
        fr_sess = place_fields.mean_rate(inter);
        inhib_neurons = inter(fr_sess >= 28);
        other_inter = inter(fr_sess < 28);
        
        %% Find the variance of firing rate for each lap
        
        number_laps = numel(lap_times(trackOI).completeLaps_start);
        
        if number_laps > 16
            number_laps = 16;
        end
        
        all_variance = zeros(numel(inhib_neurons), number_laps);
        all_mean = zeros(numel(inhib_neurons), number_laps);
        
        for lapOI = 1:number_laps
            
            % Find the start and end of the lap
            start_lap = lap_times(trackOI).completeLaps_start(lapOI);
            end_lap = lap_times(trackOI).completeLaps_stop(lapOI);
            
            isDuringLap = (clusters.spike_times >= start_lap) & ...
                (clusters.spike_times <= end_lap);
            
            spikes_lap = clusters.spike_id(isDuringLap);
            times_lap = clusters.spike_times(isDuringLap);
            times_lap = times_lap - times_lap(1); % We start from 0
            
            for cID = 1:numel(inhib_neurons)
                cellOI = inhib_neurons(cID);
                isSpiking = (spikes_lap == cellOI); % All spikes
                binned_time = floor(times_lap); % We bin every second
                mean_values = accumarray(binned_time+1, isSpiking', [], @sum);
                
                mean_values(end) = []; % Remove last second cause not complete
                
                % We now take the variance of these spike counts
                current_variance = std(mean_values, "omitnan");
                current_mean = mean(mean_values, "omitnan");
                all_variance(cID, lapOI) = current_variance;
                all_mean(cID, lapOI) = current_mean;
            end
        end
        
        % We add the data
        for cID = 1:numel(inhib_neurons)
            
            % Name of the cell is cell id + id before
            cell_name = sID*1000 + inhib_neurons(cID);
            session = [session; repelem(sID, number_laps, 1)];
            animal = [animal; repelem(animalOI, number_laps, 1)];
            condition = [condition; repelem(conditionOI, number_laps, 1)];
            track = [track; repelem(trackOI, number_laps, 1)];
            lap = [lap; (1:number_laps)'];
            cell = [cell; repelem(cell_name, number_laps, 1)];
            variance_FR = [variance_FR; all_variance(cID, :)'];
            mean_FR = [mean_FR; all_mean(cID, :)'];
        end
    end
end

exposure = track;
exposure(track == 3 | track == 4) = 2;
exposure(track == 1 | track == 2) = 1;

track(track == 3) = 1;
track(track == 4) = 2;

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);
condition = str2double(condition);

data = table(session, animal, condition, exposure, lap, ...
             cell, variance_FR, mean_FR);
         
save("inhibitory_inter_variations.mat", "data");

%%

load("inhibitory_inter_variations.mat")

sum1 = groupsummary(data, ["condition", "exposure", "lap"], ...
    ["mean", "std"], ["variance_FR", "mean_FR"]);

figure;
timeSeriesOverLap(sum1, 'mean_variance_FR', 'std_variance_FR', 'var')

figure;
timeSeriesOverLap(sum1, 'mean_mean_FR', 'std_mean_FR', 'var')