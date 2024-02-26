% Script to find, for each session animal lap, the PV correlation between the
% forward and reverse half laps. 

clear

allPaths = data_folders_excl;

% Vectors to store our data

pvCorr = [];
lap = [];
track = [];
condition = [];
animal = [];

parfor cID = 1:length(allPaths)

    % Exception, need to recalculate

    if cID == 5
        continue;
    end

    currentPath = allPaths{cID};
    disp(currentPath);


    % load the data we need
    temp = load(currentPath + "/extracted_directional_lap_place_fields");
    temp2 = load(currentPath + "/extracted_directional_place_fields");
    temp3 = load(currentPath + "/extracted_place_fields");

    lap_directional_place_fields = temp.lap_directional_place_fields;
    directional_place_fields = temp2.directional_place_fields;
    place_fields = temp3.place_fields;

    [animalOI, conditionOI] = parseNameFile(currentPath); % We get the informations about the current data

    conditionOI = split(conditionOI, 'x');

    for t = 1:4
        dataDir1 = lap_directional_place_fields(t).dir1.half_Lap;
        dataDir2 = lap_directional_place_fields(t).dir2.half_Lap;

        % If odd number of half laps - we remove the last one to get an
        % event number

        if mod(length(dataDir1), 2) == 1
            dataDir1 = dataDir1(1:end-1);
            dataDir2 = dataDir2(1:end-1);
        end

        nbLaps = length(dataDir1)/2; % number of complete laps

        % Cells included -> directional cells during RUN1 union RUN2

        trackRUN1 = mod(t, 2) + mod(t + 1, 2)*2;
        trackRUN2 = trackRUN1 + 2;

        [directionalCellsRUN1, ~] = getDirectionalCells(directional_place_fields(1).place_fields.track(trackRUN1).smooth, ...
                                                   directional_place_fields(2).place_fields.track(trackRUN1).smooth);

        [directionalCellsRUN2, ~] = getDirectionalCells(directional_place_fields(1).place_fields.track(trackRUN2).smooth, ...
                                                   directional_place_fields(2).place_fields.track(trackRUN2).smooth);

        directionalCells = union(directionalCellsRUN1, directionalCellsRUN2);

        goodPC = union(directional_place_fields(1).place_fields.good_place_cells, ...
            directional_place_fields(2).place_fields.good_place_cells);

        if t == 1 || t == 3
            current_condition = str2double(conditionOI{1});
        else
            current_condition = str2double(conditionOI{2});
        end
            
        for current_lap = 1:nbLaps

            pfDir1 = dataDir1{current_lap*2 - 1}.smooth;
            pfDir2 = dataDir2{current_lap*2}.smooth;

            goodPC = union(goodPC, directionalCells);
            % idxToRemove = ismember(goodPC, directionalCells);
            % goodPC(idxToRemove) = [];

            % Get the PV correlation

            [corr, corrNormed] = getPVCor(goodPC, pfDir1, pfDir2, "pvCorrelation");

            % Save the data

            pvCorr = [pvCorr; median(corr, 'omitnan')];
            lap = [lap; current_lap];
            track = [track; t];
            condition = [condition; current_condition];
            animal = [animal; convertCharsToStrings(animalOI)];

        end
    end
end

exposition = (track > 2)*2 + (track <= 2)*1;
track(exposition == 2) = track(exposition == 2) - 2;

% We store the data in a table
data = table(animal, condition, track, exposition, lap, pvCorr);

% We mean the dimensionality across animals, laps and directions
G = groupsummary(data, ["condition", "exposition", "lap"], ...
                 {"mean", "std"}, ["pvCorr"]);

allConditions = unique(condition);
% allConditions = allConditions([1, 3, 4, 5, 6, 2]); % Re-order the condition
colors = lines(length(allConditions));

%% Plotting loop -
figure; 

maxX = [];
set_ylim = [0.2, 0.8];

for i = 1:length(allConditions) % We iterate through conditions
    current_condition = allConditions(i);
    color = colors(allConditions == current_condition, :);
    
    % We get the lap data of the exposure
    dataByLapExp1 = G(G.condition == current_condition & G.exposition == 1, :);

    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:current_condition, :);

    allLaps = dataByLapExp1.lap;
    allMean = dataByLapExp1.mean_pvCorr;
    allStd = dataByLapExp1.std_pvCorr;
    allSE = allStd./sqrt(dataByLapExp1.GroupCount);

    % We plot
    subplot(length(allConditions), 2, 2*(i - 1) + 1)
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if current_condition == 1
        errorbar(allLaps, allMean, allSE, "o", "MarkerSize", 5, "MarkerFaceColor", color);
    else
        errorbar(allLaps, allMean, allSE, 'Color', color, 'LineWidth', 2);
    end

    xlim([1, 16]);
    ylim(set_ylim);
    title("Condition : " + current_condition + " laps - First exposure")

    maxX(end + 1) = max(dataByLapExp1.mean_pvCorr);
    
    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.condition == current_condition & G.exposition == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);

    allLaps = dataByLapExp2.lap;
    allMean = dataByLapExp2.mean_pvCorr;
    allStd = dataByLapExp2.std_pvCorr;
    allSE = allStd./sqrt(dataByLapExp2.GroupCount);
    
    % We plot
    subplot(length(allConditions), 2, 2*(i - 1) + 2)
    errorbar(allLaps, allMean, allSE, 'Color', color, 'LineWidth', 2);

    xlim([1, 16]);
    ylim(set_ylim);
    title("Condition : " + current_condition + " laps - Re-exposure")
    
    maxX(end + 1) = max(dataByLapExp2.mean_pvCorr);    
end

subplot(length(allConditions), 2, 5);
ylabel("PV correlation between place field in opposite directions")

subplot(length(allConditions), 2, 6);
ylabel("PV correlation between place field in opposite directions")

subplot(length(allConditions), 2, length(allConditions)*2 - 1);
xlabel("Lap")

subplot(length(allConditions), 2, length(allConditions)*2);
xlabel("Lap")

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

