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
deltaCMV = [];
deltaMaxFRV = [];
deltaPeakLocationV = [];
partReplayV = [];

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

            lapData = currData.allLaps;
            nbLaps = length(lapData);       

            % Good cells are good place cells on RUN2
            goodCells = lapDataGoodCells(1).cellsData.cell(lapDataGoodCells(1).cellsData.isGoodPCCurrentTrack);
            nbGoodCells = length(goodCells);
            
            for lap = 1:nbLaps
                currentData = lapData(lap).cellsData;
                
                nbCells = length(currentData.cell); 
                
                % We get the main variables we need
                % We first take all the pyramidal cells then all the good
                % place cells on the track
                
                deltaCM = abs(currentData.pfCenterMass - fpfCM(currentData.cell));
                
                sumPlaceField = cellfun(@sum, currentData.placeField);

                % Diffsum normalised
                deltaMaxFR = abs(sumPlaceField - fpfSumFR(currentData.cell))...
                               ./(sumPlaceField + fpfSumFR(currentData.cell));
                
                deltaPeakLoc = abs(currentData.pfPeakPosition - fpfPeakLoc(currentData.cell));

                isGoodPCFinal = ismember(currentData.cell, goodCells);
                
                deltaCM = deltaCM(isGoodPCFinal);
                deltaMaxFR = deltaMaxFR(isGoodPCFinal);
                deltaPeakLoc = deltaPeakLoc(isGoodPCFinal);

                % We add the data
            
                animalV = [animalV; repelem(animalOI, nbGoodCells)'];
                conditionV = [conditionV; repelem(conditionOI, nbGoodCells)'];
                trackV = [trackV; repelem(track, nbGoodCells)'];
                expositionV = [expositionV; repelem(exposition, nbGoodCells)'];
                lapV = [lapV; repelem(lap, nbGoodCells)'];
                cellV = [cellV; goodCells'];
                deltaCMV = [deltaCMV; deltaCM'];
                deltaMaxFRV = [deltaMaxFRV; deltaMaxFR'];
                deltaPeakLocationV = [deltaPeakLocationV; deltaPeakLoc'];

            end        
        end
    end
    
end

% We mutate to only have the condition, not 16x...
conditionV(trackV == 1) = 16;
newConditions = split(conditionV(trackV ~= 1), 'x');
conditionV(trackV ~= 1) = newConditions(:, 2);
conditionV = str2double(conditionV);

data = table(animalV, conditionV, trackV, lapV, expositionV, cellV, deltaCMV, deltaMaxFRV, deltaPeakLocationV);

% We median by condition, exopsition and lap
G = groupsummary(data, ["conditionV", "expositionV", "lapV"], ...
                 "median", ["deltaCMV", "deltaMaxFRV", "deltaPeakLocationV"]);

allConditions = unique(conditionV);
% allConditions = allConditions([1, 3, 4, 5, 6, 2]); % Re-order the condition
colors = lines(length(allConditions));

%% Plotting loop - Center of mass
figure; 

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
     color = colors(allConditions == condition, :);
    
    % We get the lap data of the exposure
    dataByLapExp1 = G(G.conditionV == condition & G.expositionV == 1, :);
    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:condition, :);
    
    % We plot
    subplot(1, 2, 1)
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if condition == 1
        scatter(1, dataByLapExp1.median_deltaCMV, 30, color, "filled");
    else
        plot(dataByLapExp1.lapV, dataByLapExp1.median_deltaCMV, 'Color', color, 'LineWidth', 2);
    end
        
    hold on;
    
    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.conditionV == condition & G.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);
    
    % We plot
    subplot(1, 2, 2)
    plot(dataByLapExp2.lapV, dataByLapExp2.median_deltaCMV, 'Color', color, 'LineWidth', 2);
    
    hold on;
    
end

% Set the legend for each subplot
subplot(1, 2, 1);
ylim([0, 40])
legend({'1 lap', '2 laps', '3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Lap")
ylabel("Median center of mass difference with the FPF")
title("First exposure")

subplot(1, 2, 2);
ylim([0, 40])
xlabel("Lap")
ylabel("Median center of mass difference with the FPF")
title("Re-exposure")

hold off;

%% Plotting loop - Max Firing Rate Change
figure; 

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
     color = colors(allConditions == condition, :);
    
    % We get the lap data of the exposure
    dataByLapExp1 = G(G.conditionV == condition & G.expositionV == 1, :);
    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:condition, :);
    
    % We plot
    subplot(1, 2, 1)
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if condition == 1
        scatter(1, dataByLapExp1.median_deltaMaxFRV, 30, color, "filled");
    else
        plot(dataByLapExp1.lapV, dataByLapExp1.median_deltaMaxFRV, 'Color', color, 'LineWidth', 2);
    end
        
    hold on;
    
    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.conditionV == condition & G.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);
    
    % We plot
    subplot(1, 2, 2)
    plot(dataByLapExp2.lapV, dataByLapExp2.median_deltaMaxFRV, 'Color', color, 'LineWidth', 2);
    
    hold on;
    
end

% Set the legend for each subplot
subplot(1, 2, 1);
ylim([0.2, 0.6])
legend({'1 lap', '2 laps', '3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Lap")
ylabel("Median Sum of Firing Rate difference with the FPF (Diffsum normalised)")
title("First exposure")

subplot(1, 2, 2);
ylim([0.2, 0.6])
xlabel("Lap")
ylabel("Median Sum of Firing Rate difference with the FPF (Diffsum normalised)")
title("Re-exposure")

hold off;

%% Plotting loop - Peak Location Change
figure; 

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
     color = colors(allConditions == condition, :);
    
    % We get the lap data of the exposure
    dataByLapExp1 = G(G.conditionV == condition & G.expositionV == 1, :);
    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:condition, :);
    
   
    % We plot
    subplot(1, 2, 1)
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if condition == 1
        scatter(1, dataByLapExp1.median_deltaPeakLocationV, 30, color, "filled");
    else
        plot(dataByLapExp1.lapV, dataByLapExp1.median_deltaPeakLocationV, 'Color', color, 'LineWidth', 2);
    end
        
    hold on;
    
    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.conditionV == condition & G.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);
    
    % We plot
    subplot(1, 2, 2)
    plot(dataByLapExp2.lapV, dataByLapExp2.median_deltaPeakLocationV, 'Color', color, 'LineWidth', 2);
    
    hold on;
    
end

% Set the legend for each subplot
subplot(1, 2, 1);
ylim([0, 25])
legend({'1 lap', '2 laps', '3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Lap")
ylabel("Median PF Peak Location difference with the FPF")
title("First exposure")

subplot(1, 2, 2);
ylim([0, 25])
xlabel("Lap")
ylabel("Median PF Peak Location difference with the FPF")
title("Re-exposure")

hold off;

%% Look at the distribution of refinment

refinData = groupsummary(data, ["animalV", "cellV", "conditionV"], ...
                        "median", []);

refinCM = []; % Stabilisation over sleep of the CM
refinFR = [];
refinPeak = [];

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

    refinementCM = run2Data(1, :).deltaCMV - run1Data(end, :).deltaCMV;
    refinementFR = run2Data(1, :).deltaMaxFRV - run1Data(end, :).deltaMaxFRV;
    refinementPeak = run2Data(1, :).deltaPeakLocationV - run1Data(end, :).deltaPeakLocationV;

    refinCM = [refinCM; refinementCM];
    refinFR = [refinFR; refinementFR];
    refinPeak = [refinPeak; refinementPeak];

end

refinData(indexToRemove, :) = [];

% We add our variable to the data

refinData.refinCM = refinCM;
refinData.refinFR = refinFR;
refinData.refinPeak = refinPeak;

% Inferential stats : more refinement when less laps ?

summaryData = groupsummary(refinData, ["animalV", "conditionV"], "median", ["refinCM", "refinFR", ...
                                                                 "refinPeak"]);

% We log-center the condition
summaryData.logConditionC = log(summaryData.conditionV) - mean(log(summaryData.conditionV));

lm = fitlm(summaryData,'median_refinCM ~ logConditionC');
disp(lm);

figure;
plot(lm)

lm = fitlm(summaryData,'median_refinFR ~ logConditionC');
disp(lm);

figure;
plot(lm)

lm = fitlm(summaryData,'median_refinPeak ~ logConditionC');
disp(lm);

figure;
plot(lm)

%% SINGLE CELL SCATTER PLOT

% %% CM difference
% 
% figure;
% 
% % for i = 1:length(allConditions) % We iterate through conditions
% %     condition = allConditions(i);
% %     color = colors(allConditions == condition, :);
% %     plotPosition = 2 * i - 1;
% % 
% %     % We get the lap data of the exposure
% %     dataByLapExp1 = data(data.conditionV == condition & data.expositionV == 1, :);
% %     % We crop the data depending on the condition number
% %     dataByLapExp1 = dataByLapExp1(dataByLapExp1.lapV <= str2double(condition), :);
% % 
% %     % We plot
% %     subplot(6, 2, plotPosition)
% %     a = cellstr(string(1:max(dataByLapExp1.lapV)));
% %     violinplot(dataByLapExp1.deltaCMV, cellstr(int2str(dataByLapExp1.lapV)), 'GroupOrder', a, 'QuartileStyle','boxplot', 'HalfViolin','right',...
% %     'DataStyle', 'histogram');
% % 
% %     % Set the legend for each subplot
% %     ylim([0, 40])
% %     xlabel("Lap")
% %     ylabel("PF Peak Location difference with the FPF")
% %     title("First exposure")
% % 
% %     % We get the lap data of the reexposure
% %     dataByLapExp2 = data(data.conditionV == condition & data.expositionV == 2, :);
% %     % We crop the data at lap 16
% %     dataByLapExp2 = dataByLapExp2(dataByLapExp2.lapV <= 16, :);
% % 
% %     % We plot
% %     subplot(6, 2, plotPosition + 1)
% %     a = cellstr(string(1:max(dataByLapExp2.lapV)));
% %     violinplot(dataByLapExp2.deltaCMV, cellstr(int2str(dataByLapExp2.lapV)), 'GroupOrder', a, 'QuartileStyle','boxplot', 'HalfViolin','right',...
% %     'DataStyle', 'histogram');
% % 
% %     % Set the legend for each subplot
% % 
% %     ylim([0, 40])
% %     xlabel("Lap")
% %     ylabel("PF Peak Location difference with the FPF")
% %     title("Re-exposure")
% % end
% 
% %% Max FRate difference
% 
% figure;
% 
% % for i = 1:length(allConditions) % We iterate through conditions
% %     condition = allConditions(i);
% %     color = colors(allConditions == condition, :);
% %     plotPosition = 2 * i - 1;
% % 
% %     % We get the lap data of the exposure
% %     dataByLapExp1 = data(data.conditionV == condition & data.expositionV == 1, :);
% %     % We crop the data depending on the condition number
% %     dataByLapExp1 = dataByLapExp1(dataByLapExp1.lapV <= str2double(condition), :);
% % 
% %     % We plot
% %     subplot(6, 2, plotPosition)
% %     a = cellstr(string(1:max(dataByLapExp1.lapV)));
% %     % violinplot(dataByLapExp1.deltaMaxFRV, cellstr(int2str(dataByLapExp1.lapV)), 'GroupOrder', a, 'QuartileStyle','boxplot', 'HalfViolin','right',...
% %     % 'DataStyle', 'histogram');
% % 
% %     % Set the legend for each subplot
% %     ylim([-1.5, 1.5])
% %     xlabel("Lap")
% %     ylabel("PF Peak Location difference with the FPF")
% %     title("First exposure")
% % 
% %     % We get the lap data of the reexposure
% %     dataByLapExp2 = data(data.conditionV == condition & data.expositionV == 2, :);
% %     % We crop the data at lap 16
% %     dataByLapExp2 = dataByLapExp2(dataByLapExp2.lapV <= 16, :);
% % 
% %     % We plot
% %     subplot(6, 2, plotPosition + 1)
% %     a = cellstr(string(1:max(dataByLapExp2.lapV)));
% %     violinplot(dataByLapExp2.deltaMaxFRV, cellstr(int2str(dataByLapExp2.lapV)), 'GroupOrder', a, 'QuartileStyle','boxplot', 'HalfViolin','right',...
% %     'DataStyle', 'histogram');
% % 
% % 
% %     % Set the legend for each subplot
% % 
% %     ylim([-1.5, 1.5])
% %     xlabel("Lap")
% %     ylabel("PF Peak Location difference with the FPF")
% %     title("Re-exposure")
% % end
% 
% %% Peak location difference
% 
% figure;
% 
% for i = 1:length(allConditions) % We iterate through conditions
%     condition = allConditions(i);
%     color = colors(allConditions == condition, :);
%     plotPosition = 2 * i - 1;
% 
%     % We get the lap data of the exposure
%     dataByLapExp1 = data(data.conditionV == condition & data.expositionV == 1, :);
%     % We crop the data depending on the condition number
%     dataByLapExp1 = dataByLapExp1(dataByLapExp1.lapV <= str2double(condition), :);
% 
%     % We plot
%     subplot(6, 2, plotPosition)
% 
%     scatter(dataByLapExp1.lapV, dataByLapExp1.deltaPeakLocationV, [], color);
% 
%     % Set the legend for each subplot
%     ylim([0, 100])
%     xlabel("Lap")
%     ylabel("PF Peak Location difference with the FPF")
%     title("First exposure")
% 
%     % We get the lap data of the reexposure
%     dataByLapExp2 = data(data.conditionV == condition & data.expositionV == 2, :);
%     % We crop the data at lap 16
%     dataByLapExp2 = dataByLapExp2(dataByLapExp2.lapV <= 16, :);
% 
%     % We plot
%     subplot(6, 2, plotPosition + 1)
%     scatter(dataByLapExp2.lapV, dataByLapExp2.deltaPeakLocationV, [], color);
% 
%     % Set the legend for each subplot 
% 
%     ylim([0, 100])
%     xlabel("Lap")
%     ylabel("PF Peak Location difference with the FPF")
%     title("Re-exposure")
% end