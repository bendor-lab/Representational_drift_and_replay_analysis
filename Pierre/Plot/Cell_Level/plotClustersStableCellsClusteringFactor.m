
% Script to plot the clusters of cells, based on their stability at the end
% of RUN1 and at the beggening of RUN2

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

% Load the cell data
load(PATH.SCRIPT + "/../../Data/extracted_activity_mat_lap.mat");

% Define the comparaison of interest

conditionOI = "16x4";

nbLapsT2 = split(conditionOI, 'x');
nbLapsT2 = nbLapsT2(end);
matchingData = activity_mat_laps(string({activity_mat_laps.condition}) == conditionOI);

%% PLOT 1 - LN RUN1 vs L1 RUN2 - PF CENTER OF MASS

figure;

for trackOI = 1:2
    
    linesRUN1 = matchingData([matchingData.track] == trackOI);
    linesRUN2 = matchingData([matchingData.track] == trackOI + 2);
    
    % We get all the GOOD cells in a long vector
    % RUN1
    allCMRUN1 = cellfun(@(x, y) x(end).cellsData.pfCenterMass(x(end).cellsData.isGoodPCCurrentTrack ...
                        & y(end).cellsData.isGoodPCCurrentTrack), ...
                        {linesRUN1.allLaps}, {linesRUN2.allLaps}, 'UniformOutput', false);
                    
    allCMRUN1 = horzcat(allCMRUN1{:});
    
    % RUN2
    allCMRUN2 = cellfun(@(x, y) x(1).cellsData.pfCenterMass(x(end).cellsData.isGoodPCCurrentTrack ...
                        & y(end).cellsData.isGoodPCCurrentTrack), ...
                        {linesRUN2.allLaps}, {linesRUN1.allLaps}, 'UniformOutput', false);
                    
    allCMRUN2 = horzcat(allCMRUN2{:});
    
    changeCM = abs(allCMRUN2 - allCMRUN1);
    
    subplot(4, 2, trackOI)
    
    s = histogram(changeCM);
    
    title("Track " + trackOI)
    % Add labels for x and y axes
    ylabel('Count');
    xlabel('ΔCM between last lap RUN1 & 1st lap RUN2');
    
    hold on;
    
end

%% PLOT 2 - LN RUN1 vs L1 RUN2 - PF FIRING RATE

for trackOI = 1:2
    
    linesRUN1 = matchingData([matchingData.track] == trackOI);
    linesRUN2 = matchingData([matchingData.track] == trackOI + 2);
    
    % We get all the GOOD cells in a long vector
    % RUN1
    allCMRUN1 = cellfun(@(x, y) x(end).cellsData.pfMaxFRate(x(end).cellsData.isGoodPCCurrentTrack ...
                        & y(end).cellsData.isGoodPCCurrentTrack), ...
                        {linesRUN1.allLaps}, {linesRUN2.allLaps}, 'UniformOutput', false);
                    
    allCMRUN1 = horzcat(allCMRUN1{:});
    
    % RUN2
    allCMRUN2 = cellfun(@(x, y) x(1).cellsData.pfMaxFRate(x(end).cellsData.isGoodPCCurrentTrack ...
                        & y(end).cellsData.isGoodPCCurrentTrack), ...
                        {linesRUN2.allLaps}, {linesRUN1.allLaps}, 'UniformOutput', false);
                    
    allCMRUN2 = horzcat(allCMRUN2{:});
    
    changeCM = abs(allCMRUN2 - allCMRUN1);
    
    subplot(4, 2, trackOI + 2)
    
    s = histogram(changeCM);
    
    title("Track " + trackOI)
    % Add labels for x and y axes
    ylabel('Count');
    xlabel('ΔMax FR between last lap RUN1 & 1st lap RUN2');
    
    hold on;
    
end

%% PLOT 3 - LN RUN1 vs L1 RUN2 - PF PEAK LOCATION

for trackOI = 1:2
    
    linesRUN1 = matchingData([matchingData.track] == trackOI);
    linesRUN2 = matchingData([matchingData.track] == trackOI + 2);
    
    % We get all the GOOD cells in a long vector
    % RUN1
    allCMRUN1 = cellfun(@(x, y) x(end).cellsData.pfPeakPosition(x(end).cellsData.isGoodPCCurrentTrack ...
                        & y(end).cellsData.isGoodPCCurrentTrack), ...
                        {linesRUN1.allLaps}, {linesRUN2.allLaps}, 'UniformOutput', false);
                    
    allCMRUN1 = cell2mat(horzcat(allCMRUN1{:}));
    
    % RUN2
    allCMRUN2 = cellfun(@(x, y) x(1).cellsData.pfPeakPosition(x(end).cellsData.isGoodPCCurrentTrack ...
                        & y(end).cellsData.isGoodPCCurrentTrack), ...
                        {linesRUN2.allLaps}, {linesRUN1.allLaps}, 'UniformOutput', false);
                    
    allCMRUN2 = cell2mat(horzcat(allCMRUN2{:}));
    
    changeCM = abs(allCMRUN2 - allCMRUN1);
    
    subplot(4, 2, trackOI + 4)
    
    s = histogram(changeCM);
    
    title("Track " + trackOI)
    % Add labels for x and y axes
    ylabel('Count');
    xlabel('ΔPeak Position between last lap RUN1 & 1st lap RUN2');
    
    hold on;
    
end

%% DEFINE THE CONVERGENCE THRESHOLD

convThresh = 5; % 10 %
templateLen = 16;

%% PLOT 4 - Speed of convergence

for trackOI = 1:2
    
    allConvIndex = [];
    
    linesRUN2 = activity_mat_laps([activity_mat_laps.track] == trackOI + 2);
    
    for line = 1:length(linesRUN2)
        currentLine = linesRUN2(line);
        
        % We get a lap x cell metric matrice with only good cells during
        % RUN2
        cmMatrice = cellfun(@(x) x.pfCenterMass(x.isGoodPCCurrentTrack), ...
                    {currentLine.allLaps.cellsData}, 'UniformOutput', false);
        cmMatrice = vertcat(cmMatrice{:});
        
        % We take the two final laps, mean and calculate the 10% tolerance
        % window
        
        mean_vector = mean(cmMatrice(end-templateLen:end, :), 'omitnan');
        
        lowerbound = mean_vector - (mean_vector./(100 / convThresh));
        upperbound = mean_vector + (mean_vector./(100 / convThresh));
        
        % Now we get a bool vector for each column
        
        for i = 1:length(mean_vector)
            boolVec = cmMatrice(:, i) >= lowerbound(i) ...
                & cmMatrice(:, i) <= upperbound(i);
            
            % We crop the last two values because used for threshold
            % computation ?
            
            boolVec = boolVec(1:end-templateLen);
            
            % Now we find the index after which all values are 1
            
            indexConv = NaN;
            
            % Find the indices of the ones in the vector -> 
            indices = find(boolVec == 1);
            
            % iterate through indices
            for index = 1:length(indices)
                ind = indices(index);
                if all(boolVec(ind:end))
                    indexConv = ind;
                    break;
                end
            end

            % Register the relative convergence position
            allConvIndex(end + 1) = indexConv/length(boolVec);
        end
        
        
    end
    
    subplot(4, 2, trackOI + 6)
    
    s = histogram(allConvIndex);
    
    title("Track " + trackOI)
    % Add labels for x and y axes
    ylabel('Count');
    xlabel('Convergence Index during RUN2');
    
    hold on;
    
end

%% PLOT 5 - Speed of convergence vs. participation in POST1 replay
figure;

for trackOI = 1:2
    
    allConvIndex = [];
    allPOST1ReplayPart = [];
    
    linesRUN1 = activity_mat_laps([activity_mat_laps.track] == trackOI); % For replay participation
    linesRUN2 = activity_mat_laps([activity_mat_laps.track] == trackOI + 2);
    
    for line = 1:length(linesRUN2)
        currentLine = linesRUN2(line);
        
        % We get a lap x cell metric matrice with only good cells during
        % RUN2
        cmMatrice = cellfun(@(x) x.pfCenterMass(x.isGoodPCCurrentTrack), ...
                    {currentLine.allLaps.cellsData}, 'UniformOutput', false);
        cmMatrice = vertcat(cmMatrice{:});
        
        % We take the two final laps, mean and calculate the 10% tolerance
        % window
        
        mean_vector = mean(cmMatrice(end-templateLen:end, :), 'omitnan');
        
        lowerbound = mean_vector - (mean_vector./(100 / convThresh));
        upperbound = mean_vector + (mean_vector./(100 / convThresh));
        
        % Now we get a bool vector for each column
        
        for i = 1:length(mean_vector)
            boolVec = cmMatrice(:, i) >= lowerbound(i) ...
                & cmMatrice(:, i) <= upperbound(i);
            
            % We crop the last two values because used for threshold
            % computation ?
            
            boolVec = boolVec(1:end-templateLen);
            
            % Now we find the index after which all values are 1
            
            indexConv = NaN;
            
            % Find the indices of the ones in the vector -> 
            indices = find(boolVec == 1);
            
            % iterate through indices
            for index = 1:length(indices)
                ind = indices(index);
                if all(boolVec(ind:end))
                    indexConv = ind;
                    break;
                end
            end

            % Register the relative convergence position
            allConvIndex(end + 1) = indexConv/length(boolVec);
        end
        
        
    replayPartVector = linesRUN1(line).cellsReplayData.partPOST1(linesRUN2(line).allLaps(end).cellsData.isGoodPCCurrentTrack);
    allPOST1ReplayPart = [allPOST1ReplayPart replayPartVector];
        
    end
    
    subplot(2, 2, 2 * trackOI - 1)
    s = scatter(allConvIndex, allPOST1ReplayPart);
    
    title("Track " + trackOI)
    % Add labels for x and y axes
    ylabel('POST1 Replay');
    xlabel('Convergence Location during RUN2 (% of laps)');
    
    hold on;
    % Subplot bar plot - converging vs. non-converging cells POST1
    % participation
    
    meanPart = [mean(allPOST1ReplayPart(~isnan(allConvIndex)), 'omitnan') ...
                mean(allPOST1ReplayPart(isnan(allConvIndex)), 'omitnan')];
    label = ["Converging cells", "Never converging cells"];
    
    subplot(2, 2, 2 * trackOI)
    bar(meanPart)
    set(gca,'xticklabel',label);
    
    title("Track " + trackOI)
    % Add labels for x and y axes
    ylabel('Mean POST1 Replay Participation');
    
    p = ranksum(allPOST1ReplayPart(~isnan(allConvIndex)), allPOST1ReplayPart(isnan(allConvIndex)));
    disp("Track " + trackOI);
    disp(p);
    
    disp(sum(allConvIndex < 0.2)/length(allConvIndex));
    p = ranksum(allPOST1ReplayPart(allConvIndex < 0.2),allPOST1ReplayPart(allConvIndex > 0.2));
    disp(p);
end



