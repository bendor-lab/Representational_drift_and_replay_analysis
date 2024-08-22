clear
sessions = data_folders_excl;

%% Define important storage vectors

all_corr = [];
corr_binary = [];
track_reg = [];
cell = [];
condition = [];

% sID = 12;
% trackOI = 4;
% lapOI = 1;
% incr = 3;

%% Loading relevant files

for sID = 1:19
    disp(sID);
    file = sessions{sID};
    
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    animalOI = string(animalOI);
    %conditionOI = string(conditionOI); % We convert everything to string
    
    temp = load(file + "\extracted_place_fields");
    place_fields = temp.place_fields;
    
    temp = load(file + "\extracted_laps");
    lap_times = temp.lap_times;
    
    temp = load(file + "\extracted_clusters");
    clusters = temp.clusters;
    
    temp = load(file + "\extracted_position");
    position = temp.position;
    
    %% Identify the inhibitory interneurons
    % Based on firing rate for the entire session : > 28 Hz
    
    inter = place_fields.interneurons;
    
    %% Find the variance of firing rate for each lap
    
    for trackOI = 1:4
        
        number_laps = numel(lap_times(trackOI).completeLaps_start);
        
        if number_laps > 16
            number_laps = 16;
        end
        
        lapOI = 1;
        
        all_variance = zeros(numel(inter), number_laps);
        all_mean = zeros(numel(inter), number_laps);
        
        % Find the start and end of the lap
        start_lap = lap_times(trackOI).completeLaps_start(1);
        end_lap = lap_times(trackOI).completeLaps_stop(end);
        
        half_laps = lap_times(trackOI).halfLaps_start(1:end) - start_lap(1);
        current_pos = position.linear(trackOI).linear(position.t >= start_lap & ...
            position.t <= end_lap);
        current_speed = position.v_cm(position.t >= start_lap & ...
            position.t <= end_lap);
        current_t_pos = position.t(position.t >= start_lap & ...
            position.t <= end_lap);
        current_t_pos = current_t_pos - current_t_pos(1);
        
        isDuringLap = (clusters.spike_times >= start_lap) & ...
            (clusters.spike_times <= end_lap);
        
        spikes_lap = clusters.spike_id(isDuringLap);
        times_lap = clusters.spike_times(isDuringLap);
        times_lap = times_lap - times_lap(1); % We start from 0
        
        interp_speed = interp1(current_t_pos, current_speed, times_lap);
        
        for cID = 1:numel(inter)
            cellOI = inter(cID);
            isSpiking = (spikes_lap == cellOI); % All spikes
            binned_time = floor(times_lap); % We bin every second
            mean_values = accumarray(binned_time+1, isSpiking', [], @sum);
            
            % We do the same binning for speed
            mean_speeds = accumarray(binned_time+1, ...
                interp_speed', [], @mean);
            
            mean_speeds(end) = [];
            mean_values(end) = []; % Remove last second cause not complete
            
            mean_speed_bin = mean_speeds >= 5;
            
            current_cor = corrcoef(mean_speeds, mean_values, "rows", "complete");
            current_cor_bin = corrcoef(mean_speed_bin, mean_values, "rows", "complete");
            
            all_corr(end + 1) = current_cor(1, 2);
            corr_binary(end + 1) = current_cor_bin(1, 2);
            track_reg(end + 1) = trackOI;
            cell(end + 1) = cellOI;
            condition(end + 1) = str2num(conditionOI(end));
            
            %     figure;
            %     ax(1) = subplot(3, 1, 1);
            %     plot(1:numel(mean_values), movmean(mean_values, 3));
            %     grid on;
            %     xlabel("Time (s)");
            %     ylabel("Spikes per second (3-window average)")
            %     title(cellOI);
            %     ylim([0 100]);
            %
            %     hold on;
            %
            %     for idx = 1:numel(half_laps)
            %         plot([half_laps(idx) half_laps(idx)], [0 100]);
            %     end
            %
            %     ax(2) = subplot(3, 1, 2);
            %     plot(current_t_pos, current_pos);
            %     grid on;
            %     title("Position");
            %
            %     ax(3) = subplot(3, 1, 3);
            %     plot(current_t_pos, current_speed);
            %     grid on;
            %     title("Speed");
            %
            %     linkaxes(ax, "x");
            
            % xlim([0 200])
            
            %     subplot(1, 2, 2)
            %     spectrogram(mean_values, 'yaxis');
        end
    end
end

%% Diff between T1 and T3

T1_cor = all_corr(track_reg == 1);
T3_cor = all_corr(track_reg == 3);

scatter(T1_cor, T3_cor)
grid on;
hold on;
plot(-0.5:0.1:1, -0.5:0.1:1)
title("Track 1 vs. Track 3 FR correlation with speed");
xlabel("Track 1 corr.")
ylabel("Track 3 corr.")

%% Diff between T2 and T4

for cID = [1 2 3 4 8]
    T2_cor = all_corr(track_reg == 2 & condition == cID);
    T4_cor = all_corr(track_reg == 4 & condition == cID);
    
    figure;
    scatter(T2_cor, T4_cor)
    grid on;
    hold on;
    plot(-0.5:0.1:1, -0.5:0.1:1)
    title("T2 vs. T4 - Condition " + cID);
    xlabel("Track 2 corr.")
    ylabel("Track 4 corr.")
    
%     disp(cID)
%     disp(" : ")
%     disp(mean(T2_cor - T4_cor));
end

%%

hist(corr_binary, 30)
grid on;
xlabel("Correlation between FR and speed")
ylabel("Count")
title("Interneurons fire more with speed")