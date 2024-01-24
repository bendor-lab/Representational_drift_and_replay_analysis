% This script generates a file containing : 
% - Animal ID
% - Condition
% - Day
% - Lap
% - PV correlation with lap 16 - RUN2
% - Euclidian distance with lap 16 - RUN2
% - cosine similarity with lap 16 - RUN2

% This file is only treating Track 1 / 3 data
% Currently in progress

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

population_vector_laps = struct("animal", {}, "condition", {}, "day", {}, ...
                       "track", {}, "allLaps", {}, "testPlaceField", {});
                   
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
    
    %% We get the template place field : L16 RUN1
    
    testPlaceField = lap_place_fields(3).Complete_Lap{16};
    
    % For population vector analysis, we only use the good place cells of
    % the FPF - cells that will become good cells
    
    goodCells = testPlaceField.good_cells;
       
    % We iterate over tracks 1 and 3
    for track = 1:2:3
        
        % We find the number of laps
        nbLaps = min([lap_times(track).number_completeLaps, length(lap_place_fields(track).Complete_Lap)]);
        listLaps = 1:nbLaps;
        
        % We create the struct to store the data per lap
        
        allLaps = struct("lap", {}, "pvCorrelation", {}, "euclidianDistance", {}, "cosineSim", {});       
        
        % We iterate through laps
        for lap = listLaps
            
            % We get the relevant data regarding place fields
            goodPFData = lap_place_fields(track).Complete_Lap{lap};
            
            currentPFCellArray = goodPFData.raw;
            concurrentCellArray = testPlaceField.raw;
            
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
                       "track", {track}, "allLaps", {allLaps}, "testPlaceField", {testPlaceField})];
    
    end
end

save(PATH.SCRIPT + "\..\..\..\Data\population_vector_lapsLap16RUN2.mat", "population_vector_laps");