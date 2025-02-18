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
                       "track", {}, "allLaps", {}, "finalPlaceField", {});
                              
% We iterate through files
parfor cID = 1:length(sessions)
    disp(cID);
    file = sessions{cID};
    
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

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
    
    temp = load(file + "\extracted_clusters"); % Import table clusters
    clusters = temp.clusters;

    temp = load(file + "\extracted_waveforms"); % Import allclusters_waveform
    allclusters_waveform = temp.allclusters_waveform;

    temp = load(file + "\extracted_position"); % Import position
    position = temp.position;
    
    %% We iterate through tracks
    
    for trackOI = 1:2
        tic
        %% We compute the final place field

        % Definition : place field of the 16 last lap of RUN2.

        % We find the common number of laps on T3 - RUN2 between the files
        totalLapsRUN2 = min(lap_times(trackOI + 2).number_completeLaps, length(lap_place_fields(trackOI + 2).Complete_Lap));

        % We register the number of laps available for RUN2 decoding after
        % substraction

        remainingLapsRUN2 = totalLapsRUN2 - 16;

        % If we have enough laps, we just take the start and the end of those,
        % otherwise we let the 16th one for the RUN2 decoding ad take the ones
        % before for FPF

        if remainingLapsRUN2 >= 16
            % We find the start / end times of the 16 last laps

            startTime = lap_times(trackOI + 2).completeLaps_start(totalLapsRUN2 - 16);
            endTime = lap_times(trackOI + 2).completeLaps_stop(totalLapsRUN2);

            % We then crop the position mat, and compute the place field
            mutPositions = cropPositionsAtTime(position, trackOI + 2, startTime, endTime);
        else
            % We take one extra
            startTime = lap_times(trackOI + 2).completeLaps_start(totalLapsRUN2 - 17);
            endTime = lap_times(trackOI + 2).completeLaps_stop(totalLapsRUN2);
            % We crop a first mut
            mutPositions = cropPositionsAtTime(position, trackOI + 2, startTime, endTime);

            % We crop position only for lap 16
            startTime = lap_times(trackOI + 2).completeLaps_start(16);
            endTime = lap_times(trackOI + 2).completeLaps_stop(16);
            % We crop the second mut
            mut2Positions = cropPositionsAtTime(position, trackOI + 2, startTime, endTime);
            % We find where mut2 linear is not NaN, and we remove those data
            % from mut
            newLinear = mutPositions.linear(trackOI + 2);
            mutPositions.linear(trackOI + 2).linear(~isnan(mut2Positions.linear(trackOI + 2).linear)) = NaN;
        end

        finalPlaceField = calculate_place_fields_LBL(2, mutPositions, clusters, allclusters_waveform);
        finalPlaceField = finalPlaceField.track(trackOI + 2);

        % For population vector analysis, we only use the good place cells of
        % the FPF - cells that will become good cells

        goodCells = finalPlaceField.good_cells;

        % We iterate over run 1 and 2
        for run = 1:2
            
            % We get the "theoritical Track" (1, 2, 3 or 4).
            
            theoTrack = trackOI;
            if run == 2
                theoTrack = trackOI + 2;
            end

            % We find the number of laps
            nbLaps = min([lap_times(theoTrack).number_completeLaps, length(lap_place_fields(theoTrack).Complete_Lap)]);
            if theoTrack <= 2
                listLaps = 1:nbLaps;
            elseif remainingLapsRUN2 >= 16
                listLaps = [1:remainingLapsRUN2];
            else
                listLaps = [1:(remainingLapsRUN2 - 1), 16];
            end

            % We create the struct to store the data per lap

            allLaps = struct("lap", {}, "pvCorrelation", {}, "pvCorrelationNorm", {}, ...
                     "euclidianDistance", {}, "euclidianDistanceNorm", {}, ...
                     "cosineSim", {}, "cosineSimNorm", {});       

            % We iterate through laps
            for lap = listLaps

                % We get the relevant data regarding place fields
                goodPFData = lap_place_fields(theoTrack).Complete_Lap{lap};

                currentPFCellArray = goodPFData.smooth;
                concurrentCellArray = finalPlaceField.smooth;
                
                shouldNotSave = false;
                
                % rare case : if not the same resolution, for now we ignore
                if(length(currentPFCellArray{1}) ~= length(concurrentCellArray{1}))
                    shouldNotSave = true;
                    continue;
                end

                % We find all the goodCells of the FPF that are in 

                % We compute the PV, PV correlation, ED, Cosine Sim
                [pvCorrelation, pvCorrelationNorm] = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, "pvCorrelation");
                [euclidianDistance, euclidianDistanceNorm] = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, "euclidianDistance");
                [cosineSim, cosineSimNorm] = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, "cosineSim");

                % We can add those to our struct

                allLaps = [allLaps; struct("lap", {lap}, "pvCorrelation", {pvCorrelation}, "pvCorrelationNorm", {pvCorrelationNorm}, ...
                                           "euclidianDistance", {euclidianDistance}, "euclidianDistanceNorm", {euclidianDistanceNorm}, ...
                                           "cosineSim", {cosineSim}, "cosineSimNorm", {cosineSimNorm})];

            end

            % Now we can save everything in our meta-struct
            % If should not save, we pass
            if shouldNotSave
                continue;
            end

            population_vector_laps = [population_vector_laps ; struct("animal", {animalOI}, "condition", {conditionOI}, ...
                           "day", {day}, "track", {theoTrack}, "allLaps", {allLaps}, "finalPlaceField", {finalPlaceField})];

        end
        toc
    end
       
end

save(PATH.SCRIPT + "\..\..\Data\population_vector_laps.mat", "population_vector_laps");