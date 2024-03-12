% Common replay analysis

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
replayIndices = [];
degreeAll = [];
degreeApp = [];
degreeDis = [];
degreeStable = [];

all_files = data_folders_excl;

allAnimals = unique(string({activity_mat_laps.animal}));
allConditions = unique(string({activity_mat_laps.condition}));

for animalID = 1:length(allAnimals)
    disp(animalID);
    for conditionID = 1:length(allConditions)

        currentAnimal = allAnimals(animalID);
        currentCondition = allConditions(conditionID);

        matchingPath = cell2mat(cellfun(@(s) contains(s, currentAnimal) && ...
            contains(s, currentCondition), all_files, 'UniformOutput', false));

        if ~any(matchingPath)
            continue;
        end

        matchingPath = all_files{matchingPath};

        matchingData = activity_mat_laps(string({activity_mat_laps.animal}) == currentAnimal & ...
            string({activity_mat_laps.condition}) == currentCondition);

        if isempty(matchingData)
            continue;
        end

        split_condition = split(allConditions(conditionID));

        load(matchingPath + "/Replay/RUN1_Decoding/significant_replay_events_wcorr");

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

            % We filter to get only POST1 sleep replay spikes

            % Fetch the sleep times to filter POST1 replay events
            temp = load(matchingPath +  "/extracted_sleep_state");
            sleep_state = temp.sleep_state;
            startTime = sleep_state.state_time.INTER_post_start;
            endTime = startTime + 1800; % Only the 30 first minutes
    
            % We get the IDs of all the sleep replay events
            goodIDCurrent = getAllSleepReplay(trackOI, startTime, endTime, significant_replay_events, sleep_state);
            
            % We get the ID of the eplay events the cell was involved in

            allIDs = [significant_replay_events.track(trackOI).ref_index(goodIDCurrent)];
            allSpikes = {significant_replay_events.track(trackOI).spikes{goodIDCurrent}};

            cellArrayIds = [];

            for c = 1:length(cells)
                currentCell = cells(c);

                % We find all the replay events where that cell fired
                allSpotInReplay = cellfun(@(x) ismember(currentCell, x(:, 1)), allSpikes);
                allIndices = significant_replay_events.track(trackOI).ref_index(allSpotInReplay);
                cellArrayIds = [cellArrayIds; {allIndices}];
            end

            % Now we find the conjoint participation of each cells wt all
            % cells, app, dis, stable and unstable cells

            conjPartAll = [];
            conjPartApp = [];
            conjPartDis = [];
            conjPartStable = [];

            filter = 2;

            for c = 1:length(cells)
                currentCell = cells(c);

                countAll = cellfun(@(x) sum(ismember(cellArrayIds{c}, x)), cellArrayIds(1:end ~= c));
                countAll = sum(logical(countAll));

                countApp = cellfun(@(x) sum(ismember(cellArrayIds{c}, x)), ...
                    cellArrayIds(current_label == "Appear" & 1:end ~= c));
                countApp = sum(logical(countApp));

                countDis = cellfun(@(x) sum(ismember(cellArrayIds{c}, x)), ...
                    cellArrayIds(current_label == "Disapear" & 1:end ~= c));
                countDis = sum(logical(countDis));

                countStable = cellfun(@(x) sum(ismember(cellArrayIds{c}, x)), ...
                    cellArrayIds(current_label == "Stable" & 1:end ~= c));
                countStable = sum(logical(countStable));

                conjPartAll = [conjPartAll; countAll];
                conjPartApp = [conjPartApp; countApp];
                conjPartDis = [conjPartDis; countDis];
                conjPartStable = [conjPartStable; countStable];
            end

            % We add the data

            animal = [animal; repelem(currentAnimal, length(cells))'];
            condition = [condition; repelem(currentCondition, length(cells))'];
            track = [track; repelem(trackOI, length(cells))'];
            cell = [cell; cells'];
            label = [label; current_label'];
            replayIndices = [replayIndices; cellArrayIds];
            degreeAll = [degreeAll; conjPartAll];
            degreeApp = [degreeApp; conjPartApp];
            degreeDis = [degreeDis; conjPartDis];
            degreeStable = [degreeStable; conjPartStable];


        end
    end
end

%% Analysis : degree of neurons depending on label

data = table(animal, condition, track, cell, label, degreeAll, degreeApp, degreeDis, degreeStable);

X = groupsummary(data, ["animal", "condition", "track", "label"], ...
    "median", ["degreeAll"]);

%% Boxplot mean replay degree depending on the type of cell

figure;

allNewCond = unique(data.condition);
t = tiledlayout(numel(allNewCond), 2);

for conditionID = 1:numel(allNewCond)
    disp(conditionID);

    for trackOI = 1:2
        matchingData = data(data.condition ==  allNewCond(conditionID) & ...
            data.track == trackOI, :);

        nexttile;
        boxplot(matchingData.degreeAll, matchingData.label, "GroupOrder", ...
                             ["Appear", "Disapear", "Stable", "Unstable"]);
        title(allNewCond(conditionID) + " laps - Track " + trackOI);

    end
end

title(t, "Number of cells that co-replayed");

%%

figure;

allNewCond = unique(data.condition);
t = tiledlayout(numel(allNewCond), 2);

for conditionID = 1:numel(allNewCond)
    disp(conditionID);

    for trackOI = 1:2
        matchingData = data(data.condition ==  allNewCond(conditionID) & ...
            data.track == trackOI, :);

        nexttile;
        boxplot(matchingData.degreeApp, matchingData.label, "GroupOrder", ...
                             ["Appear", "Disapear", "Stable", "Unstable"]);
        title(allNewCond(conditionID) + " laps - Track " + trackOI);

    end
end

title(t, "Number of appearing cells that co-replayed");

%%

figure;

allNewCond = unique(data.condition);
t = tiledlayout(numel(allNewCond), 2);

for conditionID = 1:numel(allNewCond)
    disp(conditionID);

    for trackOI = 1:2
        matchingData = data(data.condition ==  allNewCond(conditionID) & ...
            data.track == trackOI, :);

        nexttile;
        boxplot(matchingData.degreeDis, matchingData.label, "GroupOrder", ...
                             ["Appear", "Disapear", "Stable", "Unstable"]);
        title(allNewCond(conditionID) + " laps - Track " + trackOI);

    end
end

title(t, "Number of disapearing cells that co-replayed");





%% We then create the weight matrix between each cell

% weightMat = zeros(numel(cell), numel(cell));
%
% for c1 = 1:numel(cell)
%     for c2 = 1:numel(cell)
%
%         % We get the ID of the replay events, and the number of common RE
%
%         nbCommonReplay = sum(ismember(replayIndices{c1}, replayIndices{c2}));
%         totalNbReplay = sum(length(replayIndices{c1}) + length(replayIndices{c2}));
%
%         if c1 == c2
%             weightMat(c1, c2) = 0;
%             continue;
%         end
%
%         if totalNbReplay == 0
%             totalNbReplay = 1;
%         end
%
%         weightMat(c1, c2) = nbCommonReplay/totalNbReplay;
%     end
% end
%
% nameNodes = string(cell);
%
% % Create the graph
% G = graph(weightMat, nameNodes);
% h = plot(G, 'Layout','force');
%
% numlinks = degree(G) + 1;
% h.MarkerSize = numlinks/4;
%
% highlight(h, nameNodes(label == "Appear"),'NodeColor','g')
% highlight(h, nameNodes(label == "Disapear"),'NodeColor','r')
% highlight(h, nameNodes(label == "Unstable"),'NodeColor','k')
% highlight(h, nameNodes(label == "Stable"),'NodeColor','m')
%
%

function [] = boxplotMetric(data, metric, title)

figure;

allNewCond = unique(data.condition);
t = tiledlayout(numel(allNewCond), 2);

for conditionID = 1:numel(allNewCond)
    disp(conditionID);

    for trackOI = 1:2
        matchingData = data(data.condition ==  allNewCond(conditionID) & ...
            data.track == trackOI, :);

        nexttile;
        boxplot(matchingData(:, metric), matchingData.label, "GroupOrder", ...
                             ["Appear", "Disapear", "Stable", "Unstable"]);
        title(allNewCond(conditionID) + " laps - Track " + trackOI);

    end
end

title(t, title);
end
