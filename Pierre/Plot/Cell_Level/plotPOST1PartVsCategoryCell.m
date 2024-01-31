% Script to plot the replay participation of cells, based on their stability at the end
% of RUN1 and at the beggining of RUN2

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

% Load the cell data
load(PATH.SCRIPT + "/../../Data/extracted_activity_mat_lap.mat");

sessions = data_folders_excl; % Use the function to get all the file paths

% all vector to store our data
conditionV = [];
labelT1V = [];
labelT2V = [];
POST1ReplayPartT1V = [];
POST1ReplayPartT2V = [];

% We get all the cells label and POST1 activity for each session

for cFile = sessions
    file = cFile{1};
    [animalOI, conditionOI, dayOI] = parseNameFile(file); % We get the informations about the current data
    
    currentLines = activity_mat_laps(string({activity_mat_laps.animal}) == animalOI & ...
                                    string({activity_mat_laps.condition}) == conditionOI);
    
    currentLineT1R1 = currentLines([currentLines.track] == 1);
    goodCellsT1R1 = currentLineT1R1.allLaps(end).cellsData.isGoodPCCurrentTrack;
    
    currentLineT1R2 = currentLines([currentLines.track] == 3);
    goodCellsT1R2 = currentLineT1R2.allLaps(end).cellsData.isGoodPCCurrentTrack;
    
    currentLineT2R1 = currentLines([currentLines.track] == 2);
    goodCellsT2R1 = currentLineT2R1.allLaps(end).cellsData.isGoodPCCurrentTrack;
    
    currentLineT2R2 = currentLines([currentLines.track] == 4);
    goodCellsT2R2 = currentLineT2R2.allLaps(end).cellsData.isGoodPCCurrentTrack;
    
    labelT1 = repelem("", length(currentLineT1R1));
        
    % Now, we give label depending on the case
    labelT1(goodCellsT1R1 & goodCellsT1R2) = "Stable";
    labelT1(goodCellsT1R1 & ~goodCellsT1R2) = "Disappear";
    labelT1(~goodCellsT1R1 & goodCellsT1R2) = "Appear";
    labelT1(~goodCellsT1R1 & ~goodCellsT1R2) = "Unstable";
        
    labelT2 = repelem("", length(currentLineT2R1));
    
    % Now, we give label depending on the case
    labelT2(goodCellsT2R1 & goodCellsT2R2) = "Stable";
    labelT2(goodCellsT2R1 & ~goodCellsT2R2) = "Disappear";
    labelT2(~goodCellsT2R1 & goodCellsT2R2) = "Appear";
    labelT2(~goodCellsT2R1 & ~goodCellsT2R2) = "Unstable";
  
    
    % We get the replay participation of each cell POST1
    
    replayPartT1 = currentLineT1R1.cellsReplayData.partPOST1;
    replayPartT2 = currentLineT2R1.cellsReplayData.partPOST1;
    
    % We add to our struct
    
    conditionV = [conditionV ; repelem(string(conditionOI), length(replayPartT1))'];
    labelT1V = [labelT1V ; labelT1'];
    labelT2V = [labelT2V ; labelT2'];
    POST1ReplayPartT1V = [POST1ReplayPartT1V ; replayPartT1'];
    POST1ReplayPartT2V = [POST1ReplayPartT2V ; replayPartT2'];  
    
end

data = table(conditionV, labelT1V, labelT2V, POST1ReplayPartT1V, POST1ReplayPartT2V);

% We add the switcher label
switchLabelV = repelem("No Switch", length(conditionV));

switchLabelV(data.labelT1V == "Disappear" & data.labelT2V == "Appear") = "T1 to T2 Switch";
switchLabelV(data.labelT1V == "Appear" & data.labelT2V == "Disappear") = "T2 to T1 Switch";

data.switchLabelV = switchLabelV';

%% PLOT 1

allConditions = unique(conditionV);
for i = 1:length(allConditions)
    conditionOI = allConditions(i);
    goodData = data(data.conditionV == conditionOI, :);
    
    subplot(5, 2, 2 * i - 1)
    G = groupsummary(goodData, "labelT1V", "median", "POST1ReplayPartT1V");
    bar(table2array(G(:, 3)))
    set(gca,'xticklabel', table2array(G(:, 1)));
    title("Track 1 - " + conditionOI)
    ylabel("POST1 Replay Part.")
    
    hold on;
    GStd = groupsummary(goodData, "labelT1V", "std", "POST1ReplayPartT1V");
    stdErr = table2array(GStd(:, 3)) ./ sqrt(table2array(GStd(:, 2)));
    errorbar([1 2 3 4], table2array(G(:, 3)), stdErr ,'o')
    hold off;
    
    subplot(5, 2, 2 * i)
    G = groupsummary(goodData, "labelT2V", "median", "POST1ReplayPartT2V");
    bar(table2array(G(:, 3)))
    set(gca,'xticklabel', table2array(G(:, 1)));
    title("Track 2 - " + conditionOI)
    
    hold on;
    GStd = groupsummary(goodData, "labelT2V", "std", "POST1ReplayPartT2V");
    stdErr = table2array(GStd(:, 3)) ./ sqrt(table2array(GStd(:, 2)));
    errorbar([1 2 3 4], table2array(G(:, 3)), stdErr ,'o')
    hold off;
end

% subplot(1, 2, 1)
% G = groupsummary(data, "labelT1V", "mean", "POST1ReplayPartT1V");
% bar(table2array(G(:, 3)))
% set(gca,'xticklabel', table2array(G(:, 1)));
% title("Track 1 - ")
% ylabel("POST1 Replay Part., decoded with Track 1")
% 
% subplot(1, 2, 2)
% G = groupsummary(data, "labelT2V", "mean", "POST1ReplayPartT2V");
% bar(table2array(G(:, 3)))
% set(gca,'xticklabel', table2array(G(:, 1)));
% title("Track 2 - ")
% ylabel("POST1 Replay Part., decoded with Track 2")

%% PLOT 2

figure;

for i = 1:length(allConditions)
    conditionOI = allConditions(i);
    goodData = data(data.conditionV == conditionOI, :);
    
    subplot(5, 2, 2 * i - 1)
    G = groupsummary(goodData, "labelT1V", "median", "POST1ReplayPartT2V");
    bar(table2array(G(:, 3)))
    set(gca,'xticklabel', table2array(G(:, 1)));
    title("Track 1 - " + conditionOI)
    ylabel("POST1 Replay Part.")
    
    hold on;
    GStd = groupsummary(goodData, "labelT1V", "std", "POST1ReplayPartT2V");
    stdErr = table2array(GStd(:, 3)) ./ sqrt(table2array(GStd(:, 2)));
    errorbar([1 2 3 4], table2array(G(:, 3)), stdErr ,'o')
    hold off;
    
    subplot(5, 2, 2 * i)
    G = groupsummary(goodData, "labelT2V", "median", "POST1ReplayPartT1V");
    bar(table2array(G(:, 3)))
    set(gca,'xticklabel', table2array(G(:, 1)));
    title("Track 2 - " + conditionOI)
    
    hold on;
    GStd = groupsummary(goodData, "labelT2V", "std", "POST1ReplayPartT1V");
    stdErr = table2array(GStd(:, 3)) ./ sqrt(table2array(GStd(:, 2)));
    errorbar([1 2 3 4], table2array(G(:, 3)), stdErr ,'o')
    hold off;
end

% subplot(1, 2, 1)
% G = groupsummary(data, "labelT1V", "mean", "POST1ReplayPartT2V");
% bar(table2array(G(:, 3)))
% set(gca,'xticklabel', table2array(G(:, 1)));
% title("Track 1 - ")
% ylabel("POST1 Replay Part., decoded with Track 2")
% 
% subplot(1, 2, 2)
% G = groupsummary(data, "labelT2V", "mean", "POST1ReplayPartT1V");
% bar(table2array(G(:, 3)))
% set(gca,'xticklabel', table2array(G(:, 1)));
% title("Track 2 - ")
% ylabel("POST1 Replay Part., decoded with Track 1")

%% PLOT 3 - PAS ASSEZ DE POINTS ! 40 cellules max

% figure;
% 
% for i = 1:length(allConditions)
%     conditionOI = allConditions(i);
%     goodData = data(data.conditionV == conditionOI, :);
%     
%     subplot(5, 2, 2 * i - 1)
%     G = groupsummary(goodData, "switchLabelV", "mean", "POST1ReplayPartT1V");
%     bar(table2array(G(:, 3)))
%     set(gca,'xticklabel', table2array(G(:, 1)));
%     title("Track 1 - " + conditionOI)
%     ylabel("POST1 Replay Part.")
%     
%     subplot(5, 2, 2 * i)
%     G = groupsummary(goodData, "switchLabelV", "mean", "POST1ReplayPartT2V");
%     bar(table2array(G(:, 3)))
%     set(gca,'xticklabel', table2array(G(:, 1)));
%     title("Track 2 - " + conditionOI)
% end

% subplot(1, 2, 1)
% G = groupsummary(data, "switchLabelV", "mean", "POST1ReplayPartT1V");
% bar(table2array(G(:, 3)))
% set(gca,'xticklabel', table2array(G(:, 1)));
% title("Track 1 - ")
% ylabel("POST1 Replay Part., decoded with Track 1")
% 
% subplot(1, 2, 2)
% G = groupsummary(data, "switchLabelV", "mean", "POST1ReplayPartT2V");
% bar(table2array(G(:, 3)))
% set(gca,'xticklabel', table2array(G(:, 1)));
% title("Track 2 - ")
% ylabel("POST1 Replay Part., decoded with Track 2")

% figure;
% grp = table2array(data(:, "switchLabelV"));
% 
% grpInt = repelem(0, length(grp))';
% grpInt(grp == "T1 to T2 Switch") = 1;
% grpInt(grp == "T2 to T1 Switch") = 2;
% 
% y1 = data.POST1ReplayPartT1V;
% subplot(1, 2, 1);
% beeswarm(grpInt(grpInt ~= 0), y1(grpInt ~= 0), 3,'sort_style','up','overlay_style','ci');
% 
% % Rank sum test
% p1 = ranksum(y1(grpInt == 1), y1(grpInt == 2));
% 
% disp(p1);
% 
% subplot(1, 2, 2);
% y2 = data.POST1ReplayPartT2V;
% beeswarm(grpInt(grpInt ~= 0), y2(grpInt ~= 0), 3,'sort_style','up','overlay_style','ci');
% 
% % Rank sum test
% p2 = ranksum(y2(grpInt == 1), y2(grpInt == 2));
% 
% disp(p2);