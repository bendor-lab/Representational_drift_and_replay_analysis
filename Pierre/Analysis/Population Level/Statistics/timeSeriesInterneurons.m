% File to generate the metric data over laps

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths

% We create identifiers for cells from each session.
% Format is : IDENT-00-XXX
identifiers = 1:numel(sessions);
identifiers = identifiers* 1000;

% Arrays to hold all the data

sessionID = [];
animal = [];
cell = [];
condition = [];
track = [];
exposure = [];
lap = [];
pvCorr = [];
firing_rate = [];
speed_corr = [];

% We take the absolute value of the difference over sum to get the relative
% distance with the FPF, independently of the direction
diffSum = @(x1, x2) abs(x1 - x2)/(x1 + x2);

%% Extraction & computation

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
    %
    temp = load(file + "\extracted_directional_lap_place_fields");
    lap_directional_place_fields = temp.lap_directional_place_fields;
    
    temp = load(file + "\extracted_position");
    position = temp.position;
    
    temp = load(file + "\extracted_laps");
    lap_times = temp.lap_times;
    
    temp = load(file + "\extracted_clusters");
    clusters = temp.clusters;
    
    % Track loop
    
    for trackOI = 1:2
        
        other_track = mod(trackOI + 1, 2) + 2*mod(trackOI, 2);
        goodCells = place_fields.interneurons;
        
        if numel(goodCells) <= 2
            continue;
        end
        
        % We get the final place field : mean of the 6 laps following the
        % 16th lap of RUN2
        
        RUN1LapPFData = lap_place_fields(trackOI).Complete_Lap;
        RUN2LapPFData = lap_place_fields(trackOI + 2).Complete_Lap;
        
        numberLapsRUN2 = length(RUN2LapPFData);
        
        finalPlaceField = {};
        
        % For each cell, we create the final place field
        for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
            temp = [];
            
            for clap = 1:6
                temp = [temp; RUN2LapPFData{16 + clap}.smooth{cellID}];
            end
            
            finalPlaceField(end + 1) = {mean(temp, 'omitnan')};
        end
        
        for exposureOI = 1:2
            
            vTrack = trackOI + mod(exposureOI + 1, 2)*2;
            
            current_numberLaps = numel(lap_place_fields(vTrack).Complete_Lap);
            
            if current_numberLaps > 16
                current_numberLaps = 16;
            end
            
            for lapOI = 1:current_numberLaps
                
                lap_start = lap_times(vTrack).completeLaps_start(lapOI);
                lap_end = lap_times(vTrack).completeLaps_stop(lapOI);
                
                current_lap_data = lap_place_fields(vTrack).Complete_Lap{lapOI};
                current_place_fields = current_lap_data.smooth;
                
                current_pvCorr = getPVCor(goodCells, current_place_fields, finalPlaceField, "pvCorrelation");
                current_pvCorr = median(current_pvCorr, 'omitnan');
                
                current_speed = position.v_cm(position.t >= lap_start & ...
                    position.t <= lap_end);
                
                current_t_pos = position.t(position.t >= lap_start & ...
                    position.t <= lap_end);
                
                current_t_pos = current_t_pos - current_t_pos(1);
                
                sampling_rate = mode(diff(current_t_pos));
                
                isDuringLap = (clusters.spike_times >= lap_start) & ...
                    (clusters.spike_times <= lap_end);
                
                spikes_lap = clusters.spike_id(isDuringLap);
                times_lap = clusters.spike_times(isDuringLap);
                times_lap = times_lap - times_lap(1); % We start from 0
                
                interp_speed = interp1(current_t_pos, current_speed, times_lap);
                binned_time = floor(times_lap); % We bin every second
                mean_speed = accumarray(binned_time+1, ...
                    interp_speed', [], @mean);
                mean_speed(end) = []; % Last minut not complete
                
                % Get for each cell, the correlation between FR and speed
                for c = goodCells
                    isSpiking = (spikes_lap == c);
                    mean_values = accumarray(binned_time+1, isSpiking', [], @sum);
                    mean_values(end) = []; % Last minut not complete
                    current_corr = corrcoef(mean_values, mean_speed);
                    current_corr = current_corr(1, 2);
                    
                    % Firing rate
                    mean_firing_rate = current_lap_data.mean_rate_lap(c);
                    
                    % Correlation with FPF
                    cell_curr_PF = current_place_fields{c};
                    cell_FPF = finalPlaceField{c};
                    
                    corr_FPF = corrcoef(cell_curr_PF, cell_FPF, "rows", "complete");
                    corr_FPF = corr_FPF(1, 2);
                    
                    % Save the data
                    
                    sessionID = [sessionID; fileID];
                    animal = [animal; animalOI];
                    cell = [cell; fileID*1000 + c];
                    condition = [condition; conditionOI];
                    track = [track; trackOI];
                    exposure = [exposure; exposureOI];
                    lap = [lap; lapOI];
                    % pvCorr = [pvCorr; current_pvCorr];
                    pvCorr = [pvCorr; corr_FPF];
                    firing_rate = [firing_rate; mean_firing_rate];
                    speed_corr = [speed_corr; current_corr];
                    
                end
            end
        end
    end
end



% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

data = table(sessionID, animal, cell, condition, exposure, lap, ...
    firing_rate, pvCorr, speed_corr);

save("timeSeries_interneurons.mat", "data")

%%

all_c = [1 2 3 4 8 16];
sum_data = groupsummary(data, ["condition", "exposure", "lap"], ...
           ["mean", "std"], ["firing_rate", "pvCorr", "speed_corr"]);


for c = 1:6
    figure;
    title("Condition : " + c);
    subplot(1, 2, 1)
    d1 = sum_data(sum_data.exposure == 1 & sum_data.condition == all_c(c), :);
    d2 = sum_data(sum_data.exposure == 2 & sum_data.condition == all_c(c), :);
    plot(d1.lap, d1.mean_speed_corr);
    hold on;
    scatter(d1.lap, d1.mean_speed_corr, "r");
    grid on;
    xlim([0, 16]);
    ylim([0, 1]);
    
    subplot(1, 2, 2)
    plot(d2.lap, d2.mean_speed_corr);
    hold on;
    scatter(d2.lap, d2.mean_speed_corr, "r");
    grid on;
    
    linkaxes();
end

%%

isDropper = data(data.exposure == 1 & ...
                data.lap == 1, :).firing_rate > ...
            2*data(data.exposure == 2 & ...
                data.lap == 16, :).firing_rate;
            
droppers = data(data.exposure == 1 & ...
                data.lap == 1, :).cell(isDropper);
droppers = unique(droppers);

d1 = data(data.exposure == 1 & ismember(data.cell, droppers), :);
d2 = data(data.exposure == 2 & ismember(data.cell, droppers), :);

boxplot(d1.speed_corr, d1.lap);
boxplot(d2.speed_corr, d2.lap);
