% This script generates a file containing : 
% - Animal ID
% - Condition
% - Day
% - Lap
% - PV correlation with the Final Place Field 
% - Euclidian distance with the Final Place Field
% - cosine similarity with the Final Place Field

% This file is only treating Track 1 / 3 data
% Currently in progress

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

population_vector_laps = struct("animal", {}, "condition", {}, "day", {}, ...
                       "track", {}, "allLaps", {}, "finalPlaceField", {});
                   
allLaps = struct("lap", {}, "pvCorrelation", {}, "euclidianDistance", {}, "cosineSim", {});
                              
% We iterate through files
for cfile = sessions
    disp(cfile);
    file = cfile{1};
    
    [animalOI, conditionOI, dayOI] = parseNameFile(file); % We get the informations about the current data

    %% Variable loading
    % We load the place fields computed per lap for each animal - lap_place_fields
    load(file + "\extracted_lap_place_fields");
    % And a general PF data to check if good cell on the whole track
    load(file + "\extracted_place_fields");
    load(file + "\extracted_laps"); % Import table lap_times
    load(file + "\extracted_clusters"); % Import table clusters
    load(file + "\extracted_waveforms"); % Import allclusters_waveform
    load(file + "\extracted_position"); % Import position
    
    %% We compute the final place field
    
    % Definition : place field of the 16 last lap of RUN2.
    
    % We find the common number of laps on T3 - RUN2 between the files
    totalLapsRUN2 = min(lap_times(3).number_completeLaps, length(lap_place_fields(3).Complete_Lap));
    
    % We find the start / end times of the 16 last laps
    
    startTime = lap_times(3).completeLaps_start(totalLapsRUN2 - 16);
    endTime = lap_times(3).completeLaps_stop(totalLapsRUN2);
    
    % We then crop the position mat, and compute the place field
    mutPositions = cropPositionsAtTime(position, 3, startTime, endTime);
    
    finalPlaceField = calculate_place_fields_RD(2, mutPositions, clusters, allclusters_waveform);
    finalPlaceField = finalPlaceField.track(3);
    
    % For population vector analysis, we only use the good place cells of
    % the FPF - cells that will become good cells
    
    goodCells = finalPlaceField.good_cells;
    
    % We register the number of laps now available for RUN2 decoding
    
    remainingLapsRUN2 = totalLapsRUN2 - 16;
       
    % We iterate over tracks 1 and 3
    for track = 1:2:3
        
        % We find the number of laps
        nbLaps = min([lap_times(track).number_completeLaps, length(lap_place_fields(track).Complete_Lap)]);
        
        % We create the struct to store the data per lap
        
        allLaps = struct("lap", {}, "pvCorrelation", {}, "euclidianDistance", {}, "cosineSim", {});                
               
        % We iterate through laps
        for lap = 1:nbLaps
            
            % We get the relevant data regarding place fields
            goodPFData = lap_place_fields(track).Complete_Lap{lap};
            
            currentPFCellArray = goodPFData.raw;
            concurrentCellArray = finalPlaceField.raw;
            
            % rare case : if not the same resolution, for now we ignore
            if(length(currentPFCellArray{1}) ~= length(concurrentCellArray{1}))
                continue;
            end
            
            % We find all the goodCells of the FPF that are in 
            
            % We compute the PV correlation
            pvCorrelation = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, "pvCorrelation");
            euclidianDistance = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, "euclidianDistance");
            cosineSim = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, "cosineSim");
            
            % We can add those to our struct
            
            allLaps = [allLaps; struct("lap", {lap}, "pvCorrelation", {pvCorrelation}, "euclidianDistance", {euclidianDistance}, "cosineSim", {cosineSim})];
            
        end
        
        % Now we can save everything in our meta-struct
    
        population_vector_laps = [population_vector_laps ; struct("animal", {animalOI}, "condition", {conditionOI}, "day", {dayOI}, ...
                       "track", {track}, "allLaps", {allLaps}, "finalPlaceField", {finalPlaceField})];
    
    end
end

% save(PATH.SCRIPT + "\..\Data\extracted_activity_mat_lap.mat", "activity_mat_laps");