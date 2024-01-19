% Script producing multiple .mat files containing 
% for each animal, for each condition, and for each track
% the place field decoding in function of the lap number in the session

clear

PATH.SCRIPT = fileparts(mfilename('fullpath'));

sessions = data_folders_excl; % Use the function to get all the file paths

% Right now, we only work with M-BLU
val_sess = [2, 5, 9, 13, 17];

for sIndex = val_sess
   
    session_string = sessions(sIndex);
    session_sliced = split(session_string, '\');
    % Based on this, infos on the data
    animalOI = char(session_sliced(end-1));
    conditionOI = split(session_sliced(end), '_');
    conditionOI = char(conditionOI(end));
    
    disp("Processing " + animalOI + " - " + conditionOI);
    
    % Base path for all the loadings
    base_path = string(session_string);

    % We get the data for place field computing
    load(base_path + "\extracted_clusters.mat");
    load(base_path + "\extracted_position.mat");
    load(base_path + "\extracted_waveforms.mat");
    load(base_path + "\extracted_laps.mat");
    
    % We iterate through track
    for track = 1:4
        
        % We create a struct to save the data
        placeFieldDecEachLap = struct("lap", [], "place_fields", {}, "good_cells", {}, "peak", {}, "center_of_mass", {});
        
        % We iterate throught laps
        nbLaps = getNumberLaps(lap_times, track);
        
        for lap = 1:nbLaps
            disp(lap);
            % We get the start, stop times of this lap
            [startTime, stopTime] = getTimeLapN(lap_times, track, lap);
            
            % We crop the position object
            croppedPosition = cropPositionsAtTime(position, track, startTime, stopTime);
            
            % We then can compute the place fields with the current lap
            % informations
            current_PF = calculate_place_fields_RD(2, croppedPosition, clusters, allclusters_waveform);
            
            % We save the variable "raw" in a struct
            toAdd = struct("lap", lap, "place_fields", {current_PF.track(track).raw}, "good_cells", {current_PF.good_place_cells}, "peak", {current_PF.track(track).peak}, "center_of_mass", {current_PF.track(track).centre_of_mass});
            
            % We concat
            placeFieldDecEachLap = [placeFieldDecEachLap; toAdd];
        end
        
        % We save the struct in at mat file
        save(PATH.SCRIPT + "\..\Data\PC_Decoding_Each_Lap_ALL\PF_" + animalOI + "_" + conditionOI + "_" + "Track" + track + ".mat", "placeFieldDecEachLap");
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         