% Calculates the inter-tracks correlation at each space bin
% Depending on the reference took for the place field calculation

% We need to mutate extracted_position.mat
% in function of extracted_laps

% Note : the place fields pipeline already set to 0 spikes when position is
% NaN so don't have to mutate spike clusters.

base_path = "X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day3_16x1";

load(base_path + "\extracted_clusters.mat");
load(base_path + "\extracted_position.mat");
load(base_path + "\extracted_waveforms.mat");
load(base_path + "\extracted_laps.mat");

%% FIRST LAP DECODING
positionFirstLap = position;

% We find the time-stamps of the first lap on track 1
startTime = lap_times(1).completeLaps_start(1);
endTime = lap_times(1).completeLaps_stop(1); 

% We reduce the positions available for the place field calculation
allTimesPosition = position.t;
boolValidTimes = (allTimesPosition > startTime & allTimesPosition < endTime);
positionFirstLap.linear(1).linear(~boolValidTimes) = false;

%% LAST LAP DECODING

positionLastLap = position;

% We find the time-stamps of the first lap on track 1
startTime = lap_times(1).completeLaps_start(end);
endTime = lap_times(1).completeLaps_stop(end); 

% We reduce the positions available for the place field calculation
allTimesPosition = position.t;
boolValidTimes = (allTimesPosition > startTime & allTimesPosition < endTime);
positionLastLap.linear(1).linear(~boolValidTimes) = false;

%% ALL LAPS DECODING

positionAllLaps = position;


%% END - Calculation of all the place fields 
clear position

place_fields_FirstLap = calculate_place_fields_RD(2, positionFirstLap, clusters, allclusters_waveform);
save("../Data/PC_Decoding_By_T1_X/place_fields_FirstLap_T1", "place_fields_FirstLap")
place_fields_LastLap = calculate_place_fields_RD(2, positionLastLap, clusters, allclusters_waveform);
save("../Data/PC_Decoding_By_T1_X/place_fields_LastLap_T1", "place_fields_LastLap")
place_fields_AllLaps = calculate_place_fields_RD(2, positionAllLaps, clusters, allclusters_waveform);
save("../Data/PC_Decoding_By_T1_X/place_fields_AllLaps_T1", "place_fields_AllLaps")

