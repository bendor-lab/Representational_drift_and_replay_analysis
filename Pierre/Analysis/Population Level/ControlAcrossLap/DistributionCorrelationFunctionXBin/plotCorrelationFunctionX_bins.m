% This script plot an histogram of the correlation values in function of
% the spatial position across the PF

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

meanCorr = repelem(0, 100);
corr = [NaN];
counter = 0;

% We iterate through files
for cfile = sessions
    disp(cfile);
    file = cfile{1};
    
    [animalOI, conditionOI, dayOI] = parseNameFile(file); % We get the informations about the current data
    
    %% Variable loading
    % We load the place fields computed per lap for each animal - lap_place_fields
    load(file + "\extracted_lap_place_fields");
    load(file + "\extracted_laps"); % Import table lap_times
    load(file + "\extracted_clusters"); % Import table clusters
    load(file + "\extracted_waveforms"); % Import allclusters_waveform
    load(file + "\extracted_position"); % Import position
    
    %% We compute the final place field
    
    % Definition : place field of the 16 last lap of RUN2.
    
    % We find the common number of laps on T3 - RUN2 between the files
    totalLapsRUN2 = min(lap_times(3).number_completeLaps, length(lap_place_fields(3).Complete_Lap));
    
    % We register the number of laps available for RUN2 decoding after
    % substraction
    
    remainingLapsRUN2 = totalLapsRUN2 - 16;
    
    % If we have enough laps, we just take the start and the end of those,
    % otherwise we let the 16th one for the RUN2 decoding ad take the ones
    % before for FPF
    
    if remainingLapsRUN2 >= 16
        % We find the start / end times of the 16 last laps
        
        startTime = lap_times(3).completeLaps_start(totalLapsRUN2 - 16);
        endTime = lap_times(3).completeLaps_stop(totalLapsRUN2);
        
        % We then crop the position mat, and compute the place field
        mutPositions = cropPositionsAtTime(position, 3, startTime, endTime);
    else
        % We take one extra
        startTime = lap_times(3).completeLaps_start(totalLapsRUN2 - 17);
        endTime = lap_times(3).completeLaps_stop(totalLapsRUN2);
        % We crop a first mut
        mutPositions = cropPositionsAtTime(position, 3, startTime, endTime);
        
        % We crop position only for lap 16
        startTime = lap_times(3).completeLaps_start(16);
        endTime = lap_times(3).completeLaps_stop(16);
        % We crop the second mut
        mut2Positions = cropPositionsAtTime(position, 3, startTime, endTime);
        % We find where mut2 linear is not NaN, and we remove those data
        % from mut
        newLinear = mutPositions.linear(3);
        mutPositions.linear(3).linear(~isnan(mut2Positions.linear(3).linear)) = NaN;
    end
    
    finalPlaceField = calculate_place_fields_RD(2, mutPositions, clusters, allclusters_waveform);
    finalPlaceField = finalPlaceField.track(3);
    
    % For population vector analysis, we only use the good place cells of
    % the FPF - cells that will become good cells
    
    goodCells = finalPlaceField.good_cells;
    
    % We iterate over tracks 1 and 3
    for track = 1:2:3
        
        % We find the number of laps
        nbLaps = min([lap_times(track).number_completeLaps, length(lap_place_fields(track).Complete_Lap)]);
        if track ~= 3
            listLaps = 1:nbLaps;
        elseif remainingLapsRUN2 >= 16
            listLaps = [1:remainingLapsRUN2];
        else
            listLaps = [1:(remainingLapsRUN2 - 1), 16];
        end
        
        % We iterate through laps
        for lap = listLaps
            
            % We get the relevant data regarding place fields
            goodPFData = lap_place_fields(track).Complete_Lap{lap};
            
            currentPFCellArray = goodPFData.raw;
            concurrentCellArray = finalPlaceField.raw;
            
            % rare case : if not the same resolution, for now we ignore
            if(length(currentPFCellArray{1}) ~= length(concurrentCellArray{1}))
                continue;
            end
            
            
            % We compute the PV correlation vector
            % Subsample the cell arrays based on the good cells that are in
            % currentPFCellArray
            
            currentPFCellArray = currentPFCellArray(goodCells);
            concurrentCellArray = concurrentCellArray(goodCells);
            
            % We reverse the data XBIN -> cells for population vector
    
            currentPFXBins = repelem({0}, length(currentPFCellArray{1}));
            concurrentPFYBins = repelem({0}, length(currentPFCellArray{1}));
            
            for xbin = 1:length(currentPFCellArray{1})
                allCurrentCellAct = cellfun(@(x) x(xbin), currentPFCellArray);
                allConcurrentCellAct = cellfun(@(x) x(xbin), concurrentCellArray);
                
                currentPFXBins(xbin) = {allCurrentCellAct};
                concurrentPFYBins(xbin) = {allConcurrentCellAct};
            end
            
            corVector = cellfun(@(x, y) corrcoef(x, y), currentPFXBins, concurrentPFYBins, 'UniformOutput', false);
            corVector = cellfun(@(x) x(2, 1), corVector);
            
            corr = [corr, corVector];
            
            corVector(isnan(corVector)) = 0;
            
            meanCorr = meanCorr + corVector;
            counter = counter + 1;
        end
        
    end
end

corr(1) = [];

tiledlayout(1, 2);
nexttile;
hist(corr)
title("Distribution of PV correlation across track")

nexttile;
bar(1:100, meanCorr./counter)
title("Mean PV correlation vs. position on track")

