% This script generates a file containing : 
% - Animal ID
% - Condition
% - Lap
% - PV correlation with the Final Place Field / normalized & non-normalized
% - Euclidian distance with the Final Place Field / normalized & non-normalized
% - cosine similarity with the Final Place Field / normalized & non-normalized

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths
sessions_legacy = data_folders_excl_legacy;

population_vector_laps = struct("animal", {}, "condition", {},"day", {}, ...
                       "track", {}, "allLaps", {});
                              
% We iterate through files
parfor cID = 1:length(sessions)
    disp(cID);
    file = sessions{cID};
    
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    % We can't apply this for track 1, so we just continue
    if conditionOI == "16x1"
        continue;
    end

    matchingLegacyFolder = sessions_legacy{contains(sessions_legacy, animalOI) & ...
                                           contains(sessions_legacy, conditionOI)};

    splitted_path = split(matchingLegacyFolder, '\');
    splitted_infos = split(splitted_path{end}, '_');
    day = splitted_infos{2};
    day = str2double(day(end));

    %% Variable loading
    % We load the place fields computed per lap for each animal - lap_place_fields
    temp = load(file + "\extracted_lap_place_fields");
    lap_place_fields = temp.lap_place_fields;

    % And a general PF data to check if good cell on the whole track
    temp = load(file + "\extracted_place_fields");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_laps"); % Import table lap_times
    lap_times = temp.lap_times;
    
    %% We iterate through tracks
    
    for trackOI = 1:2
        disp("Track " + trackOI);

        % The good cells are cells that are good place cells during
        % RUN1 or RUN2
        goodCells = union(place_fields.track(trackOI).good_cells, ...
                          place_fields.track(trackOI + 2).good_cells);

        % We iterate over run 1 and 2
        for run = 1:2
            
            % We get the "theoritical Track" (1, 2, 3 or 4).
            
            theoTrack = trackOI;
            if run == 2
                theoTrack = trackOI + 2;
            end

            % We find the number of laps
            nbLaps = min([lap_times(theoTrack).number_completeLaps, length(lap_place_fields(theoTrack).Complete_Lap)]);
            
            % We create the struct to store the data per lap

            allLaps = struct("lap", {}, "pvCorrelation", {}, ...
                     "euclidianDistance", {}, ...
                     "cosineSim", {});

            % We iterate through laps, we remove one because we compute
            % successive correlation

            for lap = 1:nbLaps-1

                % We get the relevant data regarding place fields
                goodPFData = lap_place_fields(theoTrack).Complete_Lap{lap};
                conccurentPFData = lap_place_fields(theoTrack).Complete_Lap{lap + 1};

                currentPFCellArray = goodPFData.smooth;
                concurrentCellArray = conccurentPFData.smooth;

                % We compute the PV, PV correlation, ED, Cosine Sim
                pvCorrelation = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, "pvCorrelation");
                euclidianDistance = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, "euclidianDistance");
                cosineSim = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, "cosineSim");

                % We can add those to our struct

                allLaps = [allLaps; struct("lap", {lap}, "pvCorrelation", {pvCorrelation}, ...
                                           "euclidianDistance", {euclidianDistance}, ...
                                           "cosineSim", {cosineSim})];

            end

            population_vector_laps = [population_vector_laps; struct("animal", {animalOI}, "condition", {conditionOI}, ...
                                      "day", {day}, "track", {theoTrack}, "allLaps", {allLaps})];

        end
    end
       
end

save(PATH.SCRIPT + "\..\..\Data\population_vector_laps.mat", "population_vector_laps");