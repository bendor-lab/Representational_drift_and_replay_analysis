% Script to plot the change in median CM during each lap, compared with the
% final place field
% Should replicate same plot with FPF PV correlation

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

load(PATH.SCRIPT + "/../../Data/extracted_activity_mat_lap.mat") % To get cells center of mass
load(PATH.SCRIPT + "/../../Data/population_vector_laps.mat") % To get the FPF for each session
% (and the clean number of laps)

% Arrays to hold all the data
animalV = [];
conditionV = [];
trackV = [];
lapV = [];
cellV = [];
expositionV = [];
deltaSumFRV = [];
destinyV = [];

%% Extraction & computation

for cFile = sessions
    disp(cFile);
    file = cFile{1}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    
    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    
    for track = 1:2
        
        for exposition = 1:2
            
            vTrack = track + exposition - mod(exposition, 2); % Map parameters to 1, 2, 3, 4
            
            % Get the good final place field
            FPF = population_vector_laps(string({population_vector_laps.animal}) == animalOI & ...
                                         string({population_vector_laps.condition}) == conditionOI & ...
                                         [population_vector_laps.track] == vTrack);
            FPF = FPF.finalPlaceField;
            
            fpfCM = FPF.centre_of_mass;
            fpfMaxFR = cellfun(@(x) max(x), FPF.smooth, 'UniformOutput', false);
            fpfSumFR = cellfun(@(x) sum(x), FPF.smooth, 'UniformOutput', false);

            fpfPeakLoc = cellfun(@(x, y) find(x == y), FPF.smooth, fpfMaxFR, 'UniformOutput', false);
            fpfPeakLoc(cell2mat(fpfMaxFR) == 0) = {NaN}; % If max == 0, we remove the position
            
            
            fpfMaxFR = cell2mat(fpfMaxFR); % We convert to vectors
            fpfSumFR = cell2mat(fpfSumFR);
            fpfPeakLoc = cell2mat(fpfPeakLoc);
            
            % Get the good lap data
            currData = activity_mat_laps(string({activity_mat_laps.animal}) == animalOI & ...
                                         string({activity_mat_laps.condition}) == conditionOI & ...
                                         [activity_mat_laps.track] == vTrack);

            lapDataGoodCells = activity_mat_laps(string({activity_mat_laps.animal}) == animalOI & ...
                                         string({activity_mat_laps.condition}) == conditionOI & ...
                                         [activity_mat_laps.track] == track + 2).allLaps;


            lapDataExposition = activity_mat_laps(string({activity_mat_laps.animal}) == animalOI & ...
                                         string({activity_mat_laps.condition}) == conditionOI & ...
                                         [activity_mat_laps.track] == track).allLaps;

            lapDataGoodCells = activity_mat_laps(string({activity_mat_laps.animal}) == animalOI & ...
                                         string({activity_mat_laps.condition}) == conditionOI & ...
                                         [activity_mat_laps.track] == track + 2).allLaps;

            lapData = currData.allLaps;
            nbLaps = length(lapData);       

            % Good cells are good place cells on RUN2
            % goodCells = lapDataGoodCells(1).cellsData.cell(lapDataGoodCells(1).cellsData.isGoodPCCurrentTrack);
            
            % We include all the pyramidal cells
            % goodCells = lapDataGoodCells(1).cellsData.cell;

            % We include good place cells during exposure or re-exposure
            goodCells = union(lapDataExposition(1).cellsData.cell(lapDataExposition(1).cellsData.isGoodPCCurrentTrack), ...
                              lapDataGoodCells(1).cellsData.cell(lapDataGoodCells(1).cellsData.isGoodPCCurrentTrack));

            nbGoodCells = length(goodCells); 

            % We get the destiny of each cell - FR die (- 1) or shine (1)

            sumPFLap1 = cellfun(@sum, lapDataExposition(1).cellsData.placeField);

            destinyAllCells = sign(fpfSumFR(lapDataExposition(1).cellsData.cell) - sumPFLap1);

            
            for lap = 1:nbLaps

                currentData = lapData(lap).cellsData;
                                
                sumPlaceField = cellfun(@sum, currentData.placeField);

                % Diffsum normalised
                deltaMaxFR = abs((fpfSumFR(currentData.cell) - sumPlaceField)...
                               ./(fpfSumFR(currentData.cell) + sumPlaceField));              
               
                isGoodPCFinal = ismember(currentData.cell, goodCells);
                
                deltaMaxFR = deltaMaxFR(isGoodPCFinal);

                destiny = destinyAllCells(isGoodPCFinal);
                
                % We add the data
            
                animalV = [animalV; repelem(animalOI, length(goodCells))'];
                conditionV = [conditionV; repelem(conditionOI, length(goodCells))'];
                trackV = [trackV; repelem(track, length(goodCells))'];
                expositionV = [expositionV; repelem(exposition, length(goodCells))'];
                lapV = [lapV; repelem(lap, length(goodCells))'];
                cellV = [cellV; goodCells'];
                deltaSumFRV = [deltaSumFRV; deltaMaxFR'];
                destinyV = [destinyV; destiny'];

            end        
        end
    end
    
end

% We mutate to only have the condition, not 16x...
conditionV(trackV == 1) = 16;
newConditions = split(conditionV(trackV ~= 1), 'x');
conditionV(trackV ~= 1) = newConditions(:, 2);
conditionV = str2double(conditionV);

data = table(animalV, conditionV, trackV, lapV, expositionV, cellV, destinyV, deltaSumFRV);

% This summary is just to give us the number of different destiny cells

X = groupsummary(data, ["animalV", "conditionV", "cellV", "destinyV"], ...
                 "median", []);


% We median by condition, exopsition and lap
G = groupsummary(data, ["conditionV", "expositionV", "lapV", "destinyV"], ...
                 "median", ["deltaSumFRV"]);

allConditions = unique(conditionV);
colors = lines(length(allConditions));


% We separate the data between different destiny cells

% We remove cells with destiny 0
G(G.destinyV == 0, :) = [];

GApp = G(G.destinyV == 1, :);
GDis = G(G.destinyV == -1, :);


%% Plotting loop -
figure; 

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
     color = colors(allConditions == condition, :);
    
    % We get the lap data of the exposure
    dataByLapExp1 = GApp(GApp.conditionV == condition & GApp.expositionV == 1, :);
    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:condition, :);
    
    % We plot
    subplot(2, 2, 1)
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if str2double(condition) == 1
        scatter(1, dataByLapExp1.median_deltaSumFRV, 30, color, "filled");
    else
        plot(dataByLapExp1.lapV, dataByLapExp1.median_deltaSumFRV, 'Color', color, 'LineWidth', 2);
    end
        
    hold on;
    
    % We get the lap data of the reexposure
    dataByLapExp2 = GApp(GApp.conditionV == condition & GApp.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);
    
    % We plot
    subplot(2, 2, 2)
    plot(dataByLapExp2.lapV, dataByLapExp2.median_deltaSumFRV, 'Color', color, 'LineWidth', 2);
    
    hold on;
    
end

% Set the legend for each subplot
subplot(2, 2, 1);
ylim([-1, 1])
legend({'1 lap', '2 laps', '3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Lap")
ylabel("median_deltaSumFRV difference with the FPF")
title("First exposure - Increasing cells")

subplot(2, 2, 2);
ylim([-1, 1])
xlabel("Lap")
ylabel("median_deltaSumFRV difference with the FPF")
title("Re-exposure - Increasing cells")

% ---------------------------------------------------------------------

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
     color = colors(allConditions == condition, :);
    
    % We get the lap data of the exposure
    dataByLapExp1 = GDis(GDis.conditionV == condition & GDis.expositionV == 1, :);
    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:condition, :);
    
    % We plot
    subplot(2, 2, 3)
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if str2double(condition) == 1
        scatter(1, dataByLapExp1.median_deltaSumFRV, 30, color, "filled");
    else
        plot(dataByLapExp1.lapV, dataByLapExp1.median_deltaSumFRV, 'Color', color, 'LineWidth', 2);
    end
        
    hold on;
    
    % We get the lap data of the reexposure
    dataByLapExp2 = GDis(GDis.conditionV == condition & GDis.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);
    
    % We plot
    subplot(2, 2, 4)
    plot(dataByLapExp2.lapV, dataByLapExp2.median_deltaSumFRV, 'Color', color, 'LineWidth', 2);
    
    hold on;
    
end

% Set the legend for each subplot
subplot(2, 2, 3);
ylim([-1, 1])
legend({'1 lap', '2 laps', '3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Lap")
ylabel("median_deltaSumFRV difference with the FPF")
title("First exposure - Decreasing cells")

subplot(2, 2, 4);
ylim([-1, 1])
xlabel("Lap")
ylabel("median_deltaSumFRV difference with the FPF")
title("Re-exposure - Decreasing cells")

hold off;

%% We look at the savings for each group

refinData = groupsummary(data, ["animalV", "cellV", "conditionV", "destinyV"], ...
                        "median", []);

refinFR = []; % Stabilisation over sleep of the FR

indexToRemove = [];

for lID = 1:length(refinData.cellV)
    line = refinData(lID, :);
    matchingData = data(data.animalV == line.animalV & data.conditionV == line.conditionV ...
                        & data.cellV == line.cellV, :);

    % If the cell is only present during exposure / re-exposure, we pass
    if length(unique(matchingData.expositionV)) ~= 2
        indexToRemove = [indexToRemove; lID];
        continue;
    end

    % We can extract, for each track, the last lap of RUN1 - first of RUN2
    
    run1Data = matchingData(matchingData.expositionV == 1, :);
    run2Data = matchingData(matchingData.expositionV == 2, :);

    refinementFR = run2Data(1, :).deltaSumFRV - run1Data(end, :).deltaSumFRV;

    refinFR = [refinFR; refinementFR];

end

refinData(indexToRemove, :) = [];

% We add our variable to the data

refinData.refinFR = refinFR;

% Inferential stats : more refinement when less laps ?

summaryData = groupsummary(refinData, ["animalV", "conditionV", "destinyV"], "median", ["refinFR"]);

%% We log-center the condition
summaryData.logConditionC = log(summaryData.conditionV) - mean(log(summaryData.conditionV));

summaryDataControl = groupsummary(refinData, ["animalV", "conditionV"], "median", ["refinFR"]);

summaryDataControl.logConditionC = log(summaryDataControl.conditionV) - mean(log(summaryDataControl.conditionV));

lm = fitlm(summaryDataControl,'median_refinFR ~ logConditionC');
disp(lm);

figure;
plot(lm)

% summaryData.median_refinFR = abs(summaryData.median_refinFR);

lm = fitlm(summaryData,'median_refinFR ~ logConditionC * destinyV');
disp(lm);

figure; % create a new figure

% separate the data into two groups
group1 = summaryData.destinyV == -1;
group2 = summaryData.destinyV == 1;

% scatter plot for each group
scatter(summaryData.logConditionC(group1), summaryData.median_refinFR(group1), 'filled'); % scatter plot for group 1
hold on; % hold on to add the next scatter plot to the same figure

scatter(summaryData.logConditionC(group2), summaryData.median_refinFR(group2), 'filled'); % scatter plot for group 2

% fit a line to the data for each group
p1 = polyfit(summaryData.logConditionC(group1), summaryData.median_refinFR(group1), 1);
p2 = polyfit(summaryData.logConditionC(group2), summaryData.median_refinFR(group2), 1);

% evaluate the fitted line at the X values for each group
fitted1 = polyval(p1, summaryData.logConditionC(group1));
fitted2 = polyval(p2, summaryData.logConditionC(group2));

% plot the fitted line for each group
plot(summaryData.logConditionC(group1), fitted1, 'b-'); % plot fitted line for group 1
plot(summaryData.logConditionC(group2), fitted2, 'r-'); % plot fitted line for group 2


% add legend
legend('Disapearing', 'Appearing');
xlabel("Lap ran during RUN1 (log-centered)");
ylabel("Distance with FPF improvement over sleep");
title("Different refinements for appearing & disapearing cells")
