clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

% (and the clean number of laps)

% Arrays to hold all the data
animalV = [];
conditionV = [];
trackV = [];
lapV = [];
cellV = [];
directionV = [];
expositionV = [];
emdV = [];
diffSumV = [];
peakLocChangeV = [];
cmChangeV = [];

%% Extraction & computation

parfor fileID = 1:length(sessions)
    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    
    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string

    % Exception, need to recalculate

    if fileID == 5
        continue;
    end
    
    temp = load(file + "\extracted_directional_lap_place_fields.mat");
    temp2 = load(file + "\extracted_directional_place_fields.mat");

    lap_directional_place_fields = temp.lap_directional_place_fields;
    directional_place_fields = temp2.directional_place_fields;
    
    for track = 1:2
        for exposition = 1:2
            vTrack = track + exposition - mod(exposition, 2); % Map parameters to 1, 2, 3, 4
            
            % Get the directional cells for the current Track
            
            [directionalCellsRUN1, ~] = getDirectionalCells(directional_place_fields(1).place_fields.track(track).smooth, ...
                                                   directional_place_fields(2).place_fields.track(track).smooth);

            [directionalCellsRUN2, ~] = getDirectionalCells(directional_place_fields(1).place_fields.track(track + 2).smooth, ...
                                                       directional_place_fields(2).place_fields.track(track + 2).smooth);
    
            directionalCells = union(directionalCellsRUN1, directionalCellsRUN2);

            
            % Good Cells are good place cells on RUN2
            goodCells = union(directional_place_fields(1).place_fields.track(track + 2).good_cells, ...
                              directional_place_fields(2).place_fields.track(track + 2).good_cells);
    
                
            goodDirCells = intersect(goodCells, directionalCells); % To test with directional cells

            % goodDirCells = goodCells; % Test with all cells, not just directional

            % removeIdx = ismember(goodCells, directionalCells);
            % goodCellsWttDir = goodCells;
            % goodCellsWttDir(removeIdx) = [];
            % goodDirCells = goodCellsWttDir; % To test only non-directional cells

            % Get the directional lap data

            dataDir1 = lap_directional_place_fields(vTrack).dir1.half_Lap;
            dataDir2 = lap_directional_place_fields(vTrack).dir2.half_Lap;
            
            % Always a pair number of half laps
            if mod(length(dataDir1), 2) == 1
                dataDir1 = dataDir1(1:end-1);
                dataDir2 = dataDir2(1:end-1);
            end
    
            nbLaps = length(dataDir1)/2; % number of complete laps
            
            % For each lap
            for current_lap = 1:nbLaps

                pfDir1 = dataDir1{current_lap*2 - 1}.smooth;
                pfDir2 = dataDir2{current_lap*2}.smooth;

        
                for cellID = 1:length(goodDirCells)
                    
                    cell = goodDirCells(cellID);

                    % We get the Wasserstein distance between our place
                    % fields

                    current_emd = earthMoversDistance(pfDir1{cell}, pfDir2{cell});

                    % We get the standardised FR difference between
                    % directions

                    if (max(pfDir1{cell}) + max(pfDir2{cell})) == 0
                        current_diffSum = NaN;
                    else
                        current_diffSum = (sum(pfDir1{cell}) - sum(pfDir2{cell})) / ...
                                      (sum(pfDir1{cell}) + sum(pfDir2{cell}));

                        current_diffSum = abs(current_diffSum);
                    end

                    % Get the spatial metric 

                    [~, peakLocDir1] = max(pfDir1{cell});
                    [~, peakLocDir2] = max(pfDir2{cell});

                    peakLocChange = abs(peakLocDir1 - peakLocDir2);

                    % Get the center of mass 

                    x_bin_centres = 1:2:200;

                    cmDir1 = sum(pfDir1{cell}.*x_bin_centres/sum(pfDir1{cell}));
                    cmDir2 = sum(pfDir2{cell}.*x_bin_centres/sum(pfDir2{cell}));

                    cmChange = abs(cmDir1 - cmDir2);


                    % Save the data
        
                    animalV = [animalV; animalOI];
                    conditionV = [conditionV; conditionOI];
                    trackV = [trackV; track];
                    expositionV = [expositionV; exposition];
                    lapV = [lapV; current_lap];
                    cellV = [cellV; cell];
                    emdV = [emdV; current_emd];
                    diffSumV = [diffSumV; current_diffSum];
                    peakLocChangeV = [peakLocChangeV; peakLocChange];
                    cmChangeV = [cmChangeV; cmChange];

                end
            end
        end
    end
end


% We mutate to only have the condition, not 16x...
conditionV(trackV == 1) = 16;
newConditions = split(conditionV(trackV ~= 1), 'x');
conditionV(trackV ~= 1) = newConditions(:, 2);

data = table(animalV, conditionV, trackV, lapV, expositionV, cellV, emdV, cmChangeV, diffSumV, peakLocChangeV);


% We mean by condition, exopsition and lap
G = groupsummary(data, ["conditionV", "expositionV", "lapV"], ...
                        "median", ["diffSumV", "emdV", "cmChangeV", "peakLocChangeV"]);

allConditions = unique(conditionV);
allConditions = allConditions([1, 3, 4, 5, 6, 2]); % Re-order the condition
colors = lines(length(allConditions));

%% Plotting loop - EMD : global metric

figure; 

maxX = [];
set_ylim = [0, 3000];

for i = 1:length(allConditions) % We iterate through conditions
    current_condition = allConditions(i);
    color = colors(allConditions == current_condition, :);
    
    % We get the lap data of the exposure
    dataByLapExp1 = G(G.conditionV == current_condition & G.expositionV == 1, :);

    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:str2double(current_condition), :);

    allLaps = dataByLapExp1.lapV;
    allMean = dataByLapExp1.median_emdV;
    allStd = dataByLapExp1.median_emdV;
    allSE = allStd./sqrt(dataByLapExp1.GroupCount);

    % We plot
    subplot(length(allConditions), 2, 2*(i - 1) + 1)
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if str2double(current_condition) == 1
        errorbar(allLaps, allMean, allSE, "o", "MarkerSize", 5, "MarkerFaceColor", color);
    else
        errorbar(allLaps, allMean, allSE, 'Color', color, 'LineWidth', 2);
    end

    xlim([1, 16]);
    ylim(set_ylim);
    title("Condition : " + current_condition + " laps - First exposure")

    maxX(end + 1) = max(dataByLapExp1.median_emdV);
    
    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.conditionV == current_condition & G.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);

    allLaps = dataByLapExp2.lapV;
    allMean = dataByLapExp2.median_emdV;
    allStd = dataByLapExp2.median_emdV;
    allSE = allStd./sqrt(dataByLapExp2.GroupCount);
    
    % We plot
    subplot(length(allConditions), 2, 2*(i - 1) + 2)
    errorbar(allLaps, allMean, allSE, 'Color', color, 'LineWidth', 2);

    xlim([1, 16]);
    ylim(set_ylim);
    title("Condition : " + current_condition + " laps - Re-exposure")
    
    maxX(end + 1) = max(dataByLapExp2.median_emdV);    
end

subplot(length(allConditions), 2, 5);
ylabel("Median EMD between place field in opposite directions")

subplot(length(allConditions), 2, 6);
ylabel("Median EMD between place field in opposite directions")

subplot(length(allConditions), 2, length(allConditions)*2 - 1);
xlabel("Lap")

subplot(length(allConditions), 2, length(allConditions)*2);
xlabel("Lap")

%% Plotting loop - DiffSum (firing rate metric)

figure; 

maxX = [];
set_ylim = [0, 1];

for i = 1:length(allConditions) % We iterate through conditions
    current_condition = allConditions(i);
    color = colors(allConditions == current_condition, :);
    
    % We get the lap data of the exposure
    dataByLapExp1 = G(G.conditionV == current_condition & G.expositionV == 1, :);

    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:str2double(current_condition), :);

    allLaps = dataByLapExp1.lapV;
    allMean = dataByLapExp1.median_diffSumV;
    allStd = dataByLapExp1.median_diffSumV;
    allSE = allStd./sqrt(dataByLapExp1.GroupCount);

    % We plot
    subplot(length(allConditions), 2, 2*(i - 1) + 1)
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if str2double(current_condition) == 1
        errorbar(allLaps, allMean, allSE, "o", "MarkerSize", 5, "MarkerFaceColor", color);
    else
        errorbar(allLaps, allMean, allSE, 'Color', color, 'LineWidth', 2);
    end

    xlim([1, 16]);
    ylim(set_ylim);
    title("Condition : " + current_condition + " laps - First exposure")

    maxX(end + 1) = max(dataByLapExp1.median_diffSumV);
    
    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.conditionV == current_condition & G.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);

    allLaps = dataByLapExp2.lapV;
    allMean = dataByLapExp2.median_diffSumV;
    allStd = dataByLapExp2.median_diffSumV;
    allSE = allStd./sqrt(dataByLapExp2.GroupCount);
    
    % We plot
    subplot(length(allConditions), 2, 2*(i - 1) + 2)
    errorbar(allLaps, allMean, allSE, 'Color', color, 'LineWidth', 2);

    xlim([1, 16]);
    ylim(set_ylim);
    title("Condition : " + current_condition + " laps - Re-exposure")
    
    maxX(end + 1) = max(dataByLapExp2.median_diffSumV);    
end

subplot(length(allConditions), 2, 5);
ylabel("Median DiffSum between place field in opposite directions")

subplot(length(allConditions), 2, 6);
ylabel("Median DiffSum between place field in opposite directions")

subplot(length(allConditions), 2, length(allConditions)*2 - 1);
xlabel("Lap")

subplot(length(allConditions), 2, length(allConditions)*2);
xlabel("Lap")

%% Plotting loop - Peak location change (spatial metric)

figure; 

maxX = [];
set_ylim = [0, 50];

for i = 1:length(allConditions) % We iterate through conditions
    current_condition = allConditions(i);
    color = colors(allConditions == current_condition, :);
    
    % We get the lap data of the exposure
    dataByLapExp1 = G(G.conditionV == current_condition & G.expositionV == 1, :);

    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:str2double(current_condition), :);

    allLaps = dataByLapExp1.lapV;
    allMean = dataByLapExp1.median_peakLocChangeV;
    allStd = dataByLapExp1.median_peakLocChangeV;
    allSE = allStd./sqrt(dataByLapExp1.GroupCount);

    % We plot
    subplot(length(allConditions), 2, 2*(i - 1) + 1)
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if str2double(current_condition) == 1
        errorbar(allLaps, allMean, allSE, "o", "MarkerSize", 5, "MarkerFaceColor", color);
    else
        errorbar(allLaps, allMean, allSE, 'Color', color, 'LineWidth', 2);
    end

    xlim([1, 16]);
    ylim(set_ylim);
    title("Condition : " + current_condition + " laps - First exposure")

    maxX(end + 1) = max(dataByLapExp1.median_peakLocChangeV);
    
    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.conditionV == current_condition & G.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);

    allLaps = dataByLapExp2.lapV;
    allMean = dataByLapExp2.median_peakLocChangeV;
    allStd = dataByLapExp2.median_peakLocChangeV;
    allSE = allStd./sqrt(dataByLapExp2.GroupCount);
    
    % We plot
    subplot(length(allConditions), 2, 2*(i - 1) + 2)
    errorbar(allLaps, allMean, allSE, 'Color', color, 'LineWidth', 2);

    xlim([1, 16]);
    ylim(set_ylim);
    title("Condition : " + current_condition + " laps - Re-exposure")
    
    maxX(end + 1) = max(dataByLapExp2.median_peakLocChangeV);    
end

subplot(length(allConditions), 2, 5);
ylabel("Median Peak location change between place field in opposite directions")

subplot(length(allConditions), 2, 6);
ylabel("Median Peak location change between place field in opposite directions")

subplot(length(allConditions), 2, length(allConditions)*2 - 1);
xlabel("Lap")

subplot(length(allConditions), 2, length(allConditions)*2);
xlabel("Lap")

%% Plotting loop - Peak location change (spatial metric)

figure; 

maxX = [];
set_ylim = [0, 50];

for i = 1:length(allConditions) % We iterate through conditions
    current_condition = allConditions(i);
    color = colors(allConditions == current_condition, :);
    
    % We get the lap data of the exposure
    dataByLapExp1 = G(G.conditionV == current_condition & G.expositionV == 1, :);

    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:str2double(current_condition), :);

    allLaps = dataByLapExp1.lapV;
    allMean = dataByLapExp1.median_cmChangeV;
    allStd = dataByLapExp1.median_cmChangeV;
    allSE = allStd./sqrt(dataByLapExp1.GroupCount);

    % We plot
    subplot(length(allConditions), 2, 2*(i - 1) + 1)
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if str2double(current_condition) == 1
        errorbar(allLaps, allMean, allSE, "o", "MarkerSize", 5, "MarkerFaceColor", color);
    else
        errorbar(allLaps, allMean, allSE, 'Color', color, 'LineWidth', 2);
    end

    xlim([1, 16]);
    ylim(set_ylim);
    title("Condition : " + current_condition + " laps - First exposure")

    maxX(end + 1) = max(dataByLapExp1.median_cmChangeV);
    
    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.conditionV == current_condition & G.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);

    allLaps = dataByLapExp2.lapV;
    allMean = dataByLapExp2.median_cmChangeV;
    allStd = dataByLapExp2.median_cmChangeV;
    allSE = allStd./sqrt(dataByLapExp2.GroupCount);
    
    % We plot
    subplot(length(allConditions), 2, 2*(i - 1) + 2)
    errorbar(allLaps, allMean, allSE, 'Color', color, 'LineWidth', 2);

    xlim([1, 16]);
    ylim(set_ylim);
    title("Condition : " + current_condition + " laps - Re-exposure")
    
    maxX(end + 1) = max(dataByLapExp2.median_cmChangeV);    
end

subplot(length(allConditions), 2, 5);
ylabel("Median CM change between place field in opposite directions")

subplot(length(allConditions), 2, 6);
ylabel("Median CM change between place field in opposite directions")

subplot(length(allConditions), 2, length(allConditions)*2 - 1);
xlabel("Lap")

subplot(length(allConditions), 2, length(allConditions)*2);
xlabel("Lap")

%% Sorted cell plot for directionality

colorFunc = @(x) 1-x;


for c = 1:length(allConditions(1:end - 1))
    condition = allConditions(c);

    figure;

    uniqueAnimals = unique(data.animalV);

    % one subplot per animal
    t = tiledlayout(length(uniqueAnimals), 1);
    
    for a = 1:length(uniqueAnimals)

        nexttile;

        animal = uniqueAnimals(a);
        currentData = data(data.conditionV == condition & data.animalV == animal, :);

        % We crop based on the condition
        intCond = str2double(condition);

        toDelete = (currentData.expositionV == 1 & currentData.lapV > intCond) | ...
            (currentData.expositionV == 2 & currentData.lapV > 16);

        currentData(toDelete, :) = [];

        if isempty(currentData)
            continue; % If no data for that session, pass
        end

        % We get the number of lap during RUN1 (not always equal to condition)
        numerLapRanRUN1 = max([currentData.lapV([currentData.expositionV] == 1)]);

        % For re-exposure, we add numberLapRUN1 to get a continuous
        % variable (laps are from 1 o x).

        currentData.lapV(currentData.expositionV == 2) = currentData.lapV(currentData.expositionV == 2) + numerLapRanRUN1;

        increment = 0;

         % We add a line at sleep
         xline(numerLapRanRUN1 + 0.5, ['k--'], 'LineWidth', 2);
         
         % We get all the cells during the last lap
         allCells = currentData.cellV(currentData.lapV == max(currentData.lapV));

         % We sort the cells based on our metric
         allDirec16Laps = currentData.diffSumV(currentData.lapV == max(currentData.lapV));
         [~, sortIdx] = sort(allDirec16Laps, 'descend');
         sortedCells = allCells(sortIdx);

         % We create the viz matrix
         dataMat = zeros(length(sortedCells), max([currentData.lapV]));

        for cID = 1:length(sortedCells)
            
            cell = sortedCells(cID);

            % We get the data we need for the plot
            cellData = currentData(currentData.cellV == cell, :);

            % Create the plot
            hold on;
            for i = 1:length(cellData.lapV)
                % Now we find the color from blue to red depending on the diffSumV
                colr = colorFunc(cellData.diffSumV(i));
                dataMat(cID, i) = colr;
            end
        end

        imagesc(dataMat);
        colorbar

        hold off;

        title(condition + " - " + animal);

    end
end

%% Functions

% Function to get directional place cells based on Foster 2008 criteria
% Note : does not filters out bad place cells / non-pyramidal pc

function [directionalCells, dirOP] = getDirectionalCells(pfDir1, pfDir2)
peakDir1 = cellfun(@(x) max(x), pfDir1);
peakDir2 = cellfun(@(x) max(x), pfDir2);

directionalCells = find(peakDir1./peakDir2 >= 2 | peakDir1./peakDir2 <= 0.5);
dirOP = (peakDir1./peakDir2 >= 2)*1 + (peakDir1./peakDir2 <= 0.5)*2;
dirOP = dirOP(directionalCells);
end

function emd = earthMoversDistance(p1, p2)
    cdf1 = cumsum(p1);
    cdf2 = cumsum(p2);
    emd = sum(abs(cdf1 - cdf2));
end