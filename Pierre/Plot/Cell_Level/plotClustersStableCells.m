
% Script to plot the clusters of cells, based on their stability at the end
% of RUN1 and at the beggening of RUN2

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

% Load the cell data
load(PATH.SCRIPT + "/../../Data/extracted_activity_mat_lap.mat");

% Define the comparaison of interest

conditionOI = "16x2";

nbLapsT2 = split(conditionOI, 'x');
nbLapsT2 = nbLapsT2(end);
matchingData = activity_mat_laps(string({activity_mat_laps.condition}) == conditionOI);

%% PLOT 1 - LN RUN1 vs L1 RUN2

figure;

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityCMRUN1 = abs(lineRUN1.allLaps(end).cellsData.pfCenterMass - ...
                          lineRUN1.allLaps(end - 1).cellsData.pfCenterMass);
                      
        % Compute the difference between 1 RUN2 and n RUN1 for each cell
        stabilityCMRUN1RUN2 = abs(lineRUN2.allLaps(1).cellsData.pfCenterMass - ...
                          lineRUN1.allLaps(end).cellsData.pfCenterMass);
        
        % Now, we create a label vector - appear, disappear, stable,
        % unstable
        label = repelem("", length(stabilityCMRUN1));
        
        % We get, for each cell, if it was a good PC during RUN1 / RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityCMRUN1 = stabilityCMRUN1(wasGoodPCRUN1 | wasGoodPCRUN2);
        stabilityCMRUN1RUN2 = stabilityCMRUN1RUN2(wasGoodPCRUN1 | wasGoodPCRUN2);
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(2, 2, 1)
        s = scatter(stabilityCMRUN1RUN2, stabilityCMRUN1, 'MarkerEdgeColor',[0 .5 .5],...
                                                          'MarkerFaceColor',color,...
                                                          'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('ΔCM between N % N-1 laps of RUN1');
        xlabel('ΔCM between last lap RUN1 & 1st lap RUN2');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("End RUN1 shift (Ln - Ln-1) vs. End RUN1-FirstLap RUN2 shift")

hold off;

% PLOT 2 - L2 RUN2 vs. L1 RUN2

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityCMRUN1 = abs(lineRUN1.allLaps(end).cellsData.pfCenterMass - ...
                              lineRUN1.allLaps(end - 1).cellsData.pfCenterMass);
                      
        % Compute the difference between 2 RUN2 and 1 RUN2 for each cell
        stabilityCMRUN2 = abs(lineRUN2.allLaps(2).cellsData.pfCenterMass - ...
                                  lineRUN2.allLaps(1).cellsData.pfCenterMass);
        
        % We get, for each cell, if it was a good PC during RUN1 / RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityCMRUN1 = stabilityCMRUN1(wasGoodPCRUN1 | wasGoodPCRUN2);
        stabilityCMRUN2 = stabilityCMRUN2(wasGoodPCRUN1 | wasGoodPCRUN2);
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(2, 2, 2)
        s = scatter(stabilityCMRUN2, stabilityCMRUN1, 'MarkerEdgeColor',[0 .5 .5],...
                                                          'MarkerFaceColor',color,...
                                                          'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('ΔCM between N & N-1 laps of RUN1');
        xlabel('ΔCM between 2nd & 1st lap RUN2');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("End RUN1 shift vs. Start RUN2 shift (L1-L2)")

hold off;

% PLOT 3 - L3 RUN2 vs. L2 RUN2

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityCMRUN1 = abs(lineRUN1.allLaps(end).cellsData.pfCenterMass - ...
                              lineRUN1.allLaps(end - 1).cellsData.pfCenterMass);
                      
        % Compute the difference between 3 RUN2 and 2 RUN2 for each cell
        stabilityCMRUN2 = abs(lineRUN2.allLaps(3).cellsData.pfCenterMass - ...
                                  lineRUN2.allLaps(2).cellsData.pfCenterMass);
        
        % We get, for each cell, if it was a good PC during RUN1 / RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityCMRUN1 = stabilityCMRUN1(wasGoodPCRUN1 | wasGoodPCRUN2);
        stabilityCMRUN2 = stabilityCMRUN2(wasGoodPCRUN1 | wasGoodPCRUN2);
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(2, 2, 3)
        s = scatter(stabilityCMRUN2, stabilityCMRUN1, 'MarkerEdgeColor',[0 .5 .5],...
                                                          'MarkerFaceColor',color,...
                                                          'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('ΔCM between N & N-1 laps of RUN1');
        xlabel('ΔCM between 3rd & 2nd lap RUN2');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("End RUN1 shift vs. Start RUN2 shift (L2-L3)")

hold off;

% PLOT 4 - RANDOM DATA WITH CELL ID SHUFFLE

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
                            
        centerMassEndRUN1 = lineRUN1.allLaps(end).cellsData.pfCenterMass;
        centerMassEndRUN1 = centerMassEndRUN1(randperm(length(centerMassEndRUN1)));
        centerMassEndM1RUN1 = lineRUN1.allLaps(end - 1).cellsData.pfCenterMass;
        centerMassEndM1RUN1 = centerMassEndM1RUN1(randperm(length(centerMassEndM1RUN1)));
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityCMRUN1 = abs(centerMassEndRUN1 - centerMassEndM1RUN1);
        
        centerMassL1RUN2 = lineRUN2.allLaps(1).cellsData.pfCenterMass;
        centerMassL1RUN2 = centerMassL1RUN2(randperm(length(centerMassL1RUN2)));
        
        % Compute the difference between 3 RUN2 and 2 RUN2 for each cell
        stabilityCMRUN2 = abs(centerMassL1RUN2 - centerMassEndRUN1);
        
        % We get, for each cell, if it was a good PC during RUN1 / RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityCMRUN1 = stabilityCMRUN1(wasGoodPCRUN1 | wasGoodPCRUN2);
        stabilityCMRUN2 = stabilityCMRUN2(wasGoodPCRUN1 | wasGoodPCRUN2);
        
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(2, 2, 4)
        s = scatter(stabilityCMRUN2, stabilityCMRUN1, 'MarkerEdgeColor',[0 .5 .5],...
                                                          'MarkerFaceColor',color,...
                                                          'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('ΔCM between N & N-1 laps of RUN1');
        xlabel('ΔCM between last lap RUN1 & 1st lap RUN2');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("Cell-ID Shuffled - End RUN1 shift vs. End RUN1-FirstLap RUN2 shift")

hold off;

%% PLOT 5 - Shift RUN1 - RUN2 vs. Participation POST1 Replay

figure;

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityRUN1RUN2 = abs(lineRUN2.allLaps(1).cellsData.pfCenterMass - ...
                              lineRUN1.allLaps(end).cellsData.pfCenterMass);
                      
        participationReplayPOST1 = lineRUN1.cellsReplayData.partPOST1;
        
        % We get, for each cell, if it was a good PC during RUN1 / RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityRUN1RUN2 = stabilityRUN1RUN2(wasGoodPCRUN1 & wasGoodPCRUN2);
        participationReplayPOST1 = participationReplayPOST1(wasGoodPCRUN1 & wasGoodPCRUN2);
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(3, 1, 1)
        s = scatter(stabilityRUN1RUN2, participationReplayPOST1, 'MarkerEdgeColor',[0 .5 .5],...
                                                                'MarkerFaceColor',color,...
                                                                'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('Cell participation in POST1 Replay');
        xlabel('ΔCM between 1st lap RUN2 and last lap RUN1');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("Sleep remapping vs. POST1 replay participation")

hold off;

% PLOT 6 - Shift RUN2 vs. Participation POST1 Replay

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityCMRUN2 = abs(lineRUN2.allLaps(2).cellsData.pfCenterMass - ...
                              lineRUN2.allLaps(1).cellsData.pfCenterMass);
                      
        participationReplayPOST1 = lineRUN1.cellsReplayData.partPOST1;
        
        % We get, for each cell, if it was a good PC during RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityCMRUN2 = stabilityCMRUN2(wasGoodPCRUN1 & wasGoodPCRUN2);
        participationReplayPOST1 = participationReplayPOST1(wasGoodPCRUN1 & wasGoodPCRUN2);
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(3, 1, 2)
        s = scatter(stabilityCMRUN2, participationReplayPOST1, 'MarkerEdgeColor',[0 .5 .5],...
                                                                'MarkerFaceColor',color,...
                                                                'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('Cell participation in POST1 Replay');
        xlabel('ΔCM between laps 1 & 2 of RUN2');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("Start RUN2 shift (L2 - L1) vs. POST1 replay participation")

hold off;

% PLOT 7 - Shift RUN1 vs. Participation POST1 Replay

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityRUN2 = abs(lineRUN2.allLaps(end).cellsData.pfCenterMass - ...
                              lineRUN2.allLaps(1).cellsData.pfCenterMass);
                      
        participationReplayPOST1 = lineRUN1.cellsReplayData.partPOST1;
        
        % We get, for each cell, if it was a good PC during RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityRUN2 = stabilityRUN2(wasGoodPCRUN1 & wasGoodPCRUN2);
        participationReplayPOST1 = participationReplayPOST1(wasGoodPCRUN1 & wasGoodPCRUN2);
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(3, 1, 3)
        s = scatter(stabilityRUN2, participationReplayPOST1, 'MarkerEdgeColor',[0 .5 .5],...
                                                                'MarkerFaceColor',color,...
                                                                'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('Cell participation in POST1 Replay');
        xlabel('ΔCM between Lap 1 Run 2 and Lap End Run 2');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("All RUN2 shift (LEnd - L1) vs. POST1 replay participation")

hold off;

%% PLOT 8 - Shift RUN1 - RUN2 vs. Participation POST1 Replay Max firing rate

figure;

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityRUN1RUN2 = abs(lineRUN2.allLaps(1).cellsData.pfMaxFRate - ...
                              lineRUN1.allLaps(end).cellsData.pfMaxFRate);
                      
        participationReplayPOST1 = lineRUN1.cellsReplayData.partPOST1;
        
        % We get, for each cell, if it was a good PC during RUN1 / RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityRUN1RUN2 = stabilityRUN1RUN2(wasGoodPCRUN1 & wasGoodPCRUN2);
        participationReplayPOST1 = participationReplayPOST1(wasGoodPCRUN1 & wasGoodPCRUN2);
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(3, 1, 1)
        s = scatter(stabilityRUN1RUN2, participationReplayPOST1, 'MarkerEdgeColor',[0 .5 .5],...
                                                                'MarkerFaceColor',color,...
                                                                'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('Cell participation in POST1 Replay');
        xlabel('ΔMaxFRate between 1st lap RUN2 and last lap RUN1');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("Sleep remapping vs. POST1 replay participation")

hold off;

% PLOT 6 - Shift RUN2 vs. Participation POST1 Replay

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityCMRUN2 = abs(lineRUN2.allLaps(2).cellsData.pfMaxFRate - ...
                              lineRUN2.allLaps(1).cellsData.pfMaxFRate);
                      
        participationReplayPOST1 = lineRUN1.cellsReplayData.partPOST1;
        
        % We get, for each cell, if it was a good PC during RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityCMRUN2 = stabilityCMRUN2(wasGoodPCRUN1 & wasGoodPCRUN2);
        participationReplayPOST1 = participationReplayPOST1(wasGoodPCRUN1 & wasGoodPCRUN2);
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(3, 1, 2)
        s = scatter(stabilityCMRUN2, participationReplayPOST1, 'MarkerEdgeColor',[0 .5 .5],...
                                                                'MarkerFaceColor',color,...
                                                                'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('Cell participation in POST1 Replay');
        xlabel('ΔMaxFRate between laps 1 & 2 of RUN2');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("Start RUN2 shift (L2 - L1) vs. POST1 replay participation")

hold off;

% PLOT 7 - Shift RUN1 vs. Participation POST1 Replay

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityRUN2 = abs(lineRUN2.allLaps(end).cellsData.pfMaxFRate - ...
                              lineRUN2.allLaps(1).cellsData.pfMaxFRate);
                      
        participationReplayPOST1 = lineRUN1.cellsReplayData.partPOST1;
        
        % We get, for each cell, if it was a good PC during RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityRUN2 = stabilityRUN2(wasGoodPCRUN1 & wasGoodPCRUN2);
        participationReplayPOST1 = participationReplayPOST1(wasGoodPCRUN1 & wasGoodPCRUN2);
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(3, 1, 3)
        s = scatter(stabilityRUN2, participationReplayPOST1, 'MarkerEdgeColor',[0 .5 .5],...
                                                                'MarkerFaceColor',color,...
                                                                'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('Cell participation in POST1 Replay');
        xlabel('ΔMaxFRate between Lap 1 Run 2 and Lap End Run 2');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("All RUN2 shift (LEnd - L1) vs. POST1 replay participation")

hold off;

%% PLOT 11 - Shift RUN1 - RUN2 vs. Participation POST1 Replay Peak position

figure;

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityRUN1RUN2 = abs(cell2mat(lineRUN2.allLaps(1).cellsData.pfPeakPosition)   - ...
                              cell2mat(lineRUN1.allLaps(end).cellsData.pfPeakPosition)  );
                      
        participationReplayPOST1 = lineRUN1.cellsReplayData.partPOST1;
        
        % We get, for each cell, if it was a good PC during RUN1 / RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityRUN1RUN2 = stabilityRUN1RUN2(wasGoodPCRUN1 & wasGoodPCRUN2);
        participationReplayPOST1 = participationReplayPOST1(wasGoodPCRUN1 & wasGoodPCRUN2);
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(3, 1, 1)
        s = scatter(stabilityRUN1RUN2, participationReplayPOST1, 'MarkerEdgeColor',[0 .5 .5],...
                                                                'MarkerFaceColor',color,...
                                                                'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('Cell participation in POST1 Replay');
        xlabel('ΔPeak Position between 1st lap RUN2 and last lap RUN1');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("Sleep remapping vs. POST1 replay participation")

hold off;

% PLOT 6 - Shift RUN2 vs. Participation POST1 Replay

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityCMRUN2 = abs(cell2mat(lineRUN2.allLaps(2).cellsData.pfPeakPosition)   - ...
                              cell2mat(lineRUN2.allLaps(1).cellsData.pfPeakPosition)  );
                      
        participationReplayPOST1 = lineRUN1.cellsReplayData.partPOST1;
        
        % We get, for each cell, if it was a good PC during RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityCMRUN2 = stabilityCMRUN2(wasGoodPCRUN1 & wasGoodPCRUN2);
        participationReplayPOST1 = participationReplayPOST1(wasGoodPCRUN1 & wasGoodPCRUN2);
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(3, 1, 2)
        s = scatter(stabilityCMRUN2, participationReplayPOST1, 'MarkerEdgeColor',[0 .5 .5],...
                                                                'MarkerFaceColor',color,...
                                                                'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('Cell participation in POST1 Replay');
        xlabel('ΔPeak Position between laps 1 & 2 of RUN2');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("Start RUN2 shift (L2 - L1) vs. POST1 replay participation")

hold off;

% PLOT 7 - Shift RUN1 vs. Participation POST1 Replay

% Now, we iterate through animals

for animalOI = unique({matchingData.animal})
    
    % We iterate through tracks
    for trackOI = 1:2
        
        lineRUN1 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI);
        lineRUN2 = matchingData(string({matchingData.animal}) == animalOI & ...
                                [matchingData.track] == trackOI + 2);
        
        % Compute the difference between n and n - 1 RUN1 for each cell
        stabilityRUN2 = abs(cell2mat(lineRUN2.allLaps(end).cellsData.pfPeakPosition)   - ...
                            cell2mat(lineRUN2.allLaps(1).cellsData.pfPeakPosition)  );
                      
        participationReplayPOST1 = lineRUN1.cellsReplayData.partPOST1;
        
        % We get, for each cell, if it was a good PC during RUN2
        wasGoodPCRUN1 = lineRUN1.allLaps(end).cellsData.isGoodPCCurrentTrack;
        wasGoodPCRUN2 = lineRUN2.allLaps(end).cellsData.isGoodPCCurrentTrack;
        
        % We subset the data with only good cells on RUN1 and / or RUN2
        
        stabilityRUN2 = stabilityRUN2(wasGoodPCRUN1 & wasGoodPCRUN2);
        participationReplayPOST1 = participationReplayPOST1(wasGoodPCRUN1 & wasGoodPCRUN2);
        
        % Now we can ad those to our plot
        
        if trackOI == 1
            color = [0 .7 .7];
        else
            color = [.8 .5 .5];
        end
        
        subplot(3, 1, 3)
        s = scatter(stabilityRUN2, participationReplayPOST1, 'MarkerEdgeColor',[0 .5 .5],...
                                                                'MarkerFaceColor',color,...
                                                                'LineWidth',1.5);
        
        % Add labels for x and y axes
        ylabel('Cell participation in POST1 Replay');
        xlabel('ΔPeak Position between Lap 1 Run 2 and Lap End Run 2');
        
        
        
        hold on;
    end
end

% We add the legend - workaround to keep everything in a loop

h = zeros(2, 1);
h(1) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[0 .7 .7],...
                      'LineWidth',1.5);
h(2) = scatter(NaN,NaN, 'MarkerEdgeColor',[0 .5 .5],...
                      'MarkerFaceColor',[.8 .5 .5],...
                      'LineWidth',1.5);
                  
legend(h, '16 laps', nbLapsT2 + ' laps');

title("All RUN2 shift (LEnd - L1) vs. POST1 replay participation")

hold off;

