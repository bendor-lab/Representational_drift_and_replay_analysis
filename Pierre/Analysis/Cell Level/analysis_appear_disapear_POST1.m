clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

load(PATH.SCRIPT + "\..\..\Data\extracted_activity_mat_lap.mat")

animal = [];
condition = [];
track = [];
cell = [];
label = [];
replayPart = [];

allAnimals = unique(string({activity_mat_laps.animal}));
allConditions = unique(string({activity_mat_laps.condition}));

for animalID = 1:length(allAnimals)
    for conditionID = 1:length(allConditions)

        currentAnimal = allAnimals(animalID);
        currentCondition = allConditions(conditionID);

        matchingData = activity_mat_laps(string({activity_mat_laps.animal}) == currentAnimal & ...
            string({activity_mat_laps.condition}) == currentCondition);

        if isempty(matchingData)
            continue;
        end

        split_condition = split(allConditions(conditionID));

        for trackOI = 1:2
            isGoodPCRUN1 = matchingData([matchingData.track] == trackOI).allLaps(end).cellsData.isGoodPCCurrentLap;
            isGoodPCRUN2 = matchingData([matchingData.track] == trackOI + 2).allLaps(1).cellsData.isGoodPCCurrentLap;
            cells = matchingData([matchingData.track] == trackOI).allLaps(end).cellsData.cell;
            
            % We get the labels
            current_label = repelem("", length(cells));
            current_label(isGoodPCRUN1 & isGoodPCRUN2) = "Stable";
            current_label(isGoodPCRUN1 & ~isGoodPCRUN2) = "Disapear";
            current_label(~isGoodPCRUN1 & isGoodPCRUN2) = "Appear";
            current_label(~isGoodPCRUN1 & ~isGoodPCRUN2) = "Unstable";

            % We get the replay participation in same track 
            replay_participation = matchingData([matchingData.track] == trackOI).cellsReplayData.partPOST1;

            % We add the data

            animal = [animal; repelem(currentAnimal, length(cells))'];
            condition = [condition; repelem(currentCondition, length(cells))'];
            track = [track; repelem(trackOI, length(cells))'];
            cell = [cell; cells'];
            label = [label; current_label'];
            replayPart = [replayPart; replay_participation'];

        end
    end
end

%% We make a table

data = table(animal, condition, track, cell, label, replayPart);

X = groupsummary(data, ["animal", "condition", "track", "label"], ...
                        "median", ["replayPart"]);

Y = groupsummary(data, ["label"], ...
                        "median", []);

% Plot effectives
figure;

bar(categorical(Y.label), Y.GroupCount);
ylabel("Number of cells - every session / animal")

%% Boxplot mean replay participation depending on the type of cell
figure;

allNewCond = unique(data.condition);
t = tiledlayout(numel(allNewCond), 2);

for conditionID = 1:numel(allNewCond)
    disp(conditionID);

    for trackOI = 1:2
        matchingData = data(data.condition ==  allNewCond(conditionID) & ...
                            data.track == trackOI, :);
        nexttile;

        boxplot(matchingData.replayPart, matchingData.label, "GroupOrder", ["Appear", "Disapear", "Stable", "Unstable"]);
        hold on;

        title(allNewCond(conditionID) + " laps - Track " + trackOI);

    end
end

title(t, "Number of replay events participation vs. category");

hold off;

diff = anova(data.label, data.replayPart);
multcompare(diff) 

% Stable have more replay than every other. 
% Unstable have less
% Appear and disapear have the same amount of replay.