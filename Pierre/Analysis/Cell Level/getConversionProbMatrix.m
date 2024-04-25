% Get the probability for each cell of leaving / entering a representation

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

load(PATH.SCRIPT + "\..\..\Data\extracted_activity_mat_lap.mat")
load("..\Population Level\Statistics\dataRegressionPop.mat");

sessionID = [];
animal = [];
condition = [];
track = [];
cell = [];
label = [];

allFiles = data_folders_excl;

for sID = 1:numel(allFiles)

    file = allFiles{sID};

    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string

    matchingData = activity_mat_laps(string({activity_mat_laps.animal}) == animalOI & ...
        string({activity_mat_laps.condition}) == conditionOI);

    if isempty(matchingData)
        continue;
    end

    for trackOI = 1:2
        other_track = mod(trackOI + 1, 2) + 2*mod(trackOI, 2);

        isGoodPCRUN1 = matchingData([matchingData.track] == trackOI).allLaps(end).cellsData.isGoodPCCurrentLap;
        isGoodPCRUN2 = matchingData([matchingData.track] == trackOI + 2).allLaps(1).cellsData.isGoodPCCurrentLap;

        isGoodPCRUN1Other = matchingData([matchingData.track] == other_track).allLaps(end).cellsData.isGoodPCCurrentLap;
        isGoodPCRUN2Other = matchingData([matchingData.track] == other_track + 2).allLaps(1).cellsData.isGoodPCCurrentLap;

        cells = matchingData([matchingData.track] == trackOI).allLaps(end).cellsData.cell;

        % We get the labels
        % For control, we make sure the cell is ALIVE (it's stable on the other track)
        % current_label = repelem("", length(cells));
        % current_label(isGoodPCRUN1 & isGoodPCRUN2) = "Stable";
        % current_label(isGoodPCRUN1 & ~isGoodPCRUN2 & isGoodPCRUN2Other) = "Disappear";
        % current_label(~isGoodPCRUN1 & isGoodPCRUN2 & isGoodPCRUN1Other) = "Appear";
        % current_label(~isGoodPCRUN1 & ~isGoodPCRUN2) = "Unstable";
        
        current_label = repelem("Unstable", length(cells));
        current_label(isGoodPCRUN1 & isGoodPCRUN2) = "Stable";
        current_label(isGoodPCRUN1 & ~isGoodPCRUN2) = "Disappear";
        current_label(~isGoodPCRUN1 & isGoodPCRUN2) = "Appear";
        current_label(~isGoodPCRUN1 & ~isGoodPCRUN2) = "Unstable";

        % We add the data
        sessionID = [sessionID; repelem(sID, numel(cells), 1)];
        animal = [animal; repelem(animalOI, numel(cells), 1)];
        condition = [condition; repelem(conditionOI, numel(cells), 1)];
        track = [track; repelem(trackOI, numel(cells), 1)];
        cell = [cell; cells'];
        label = [label; current_label'];

    end
end

data = table(sessionID, animal, condition, track, cell, label);

% We remove unsafe cells
allUnsafeLines = find(data.label == "");
indexToRemove = [];

for lID = 1:numel(allUnsafeLines)
    cLine = data(allUnsafeLines(lID), :);
    sessionID = cLine.sessionID;
    cellID = cLine.cell;
    badIdx = find(data.sessionID == sessionID & data.cell == cellID);
    indexToRemove = [indexToRemove badIdx];
end

data(indexToRemove, :) = [];

%% Can we predict the status of the cell based on its status after sleep ?

matProb = zeros(4, 4, 5);
posLabels = {'Unstable', 'Stable', 'Appear', 'Disappear'};
condition_count = [4 4 4 3 4]; % for normalization

for sID = 1:19
    matchingDataT1 = data(data.sessionID == sID & data.track == 1, :);
    matchingDataT2 = data(data.sessionID == sID & data.track == 2, :);
    
    current_condition = split(matchingDataT2.condition(1), 'x');
    current_condition = str2double(current_condition{2});

    if current_condition == 8
        current_condition = 5;
    end
    
    labelsT1 = matchingDataT1.label;
    labelsT2 = matchingDataT2.label;

    % We get all the possible combination

    [~, vector1_indices] = ismember(labelsT1, posLabels);
    [~, vector2_indices] = ismember(labelsT2, posLabels);

    % Get joint histogram
    jointHistogram = histcounts2(vector1_indices, vector2_indices, 1:length(posLabels)+1, 1:length(posLabels)+1);

    % Normalize to get joint probability matrix
    jointProbabilityMatrix = jointHistogram / sum(jointHistogram, 'all');
    jointProbabilityMatrix = jointProbabilityMatrix/condition_count(current_condition);
    
    matProb(:, :, current_condition) = matProb(:, :, current_condition) + jointProbabilityMatrix;

end

%%

figure;
t = tiledlayout(2, 3);
nVec = [];
for cID = 1:5
    n = nexttile;
    nVec(end + 1) = n;
    imagesc(matProb(:, :, cID));
    xticks([1 2 3 4]);
    xticklabels(posLabels);
    xlabel("Track 1 type")
    yticks([1 2 3 4]);
    yticklabels(posLabels);
    ylabel("Track 2 type")
    current_cond = cID;
    if cID == 5
        current_cond = 8;
    end
    c = colorbar(n);
    colormap(c, "jet");
    clim(n, [0, 0.4]);
    title("Condition - " + current_cond + " laps")
end