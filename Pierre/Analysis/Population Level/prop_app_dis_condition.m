clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

load(PATH.SCRIPT + "\..\..\Data\extracted_activity_mat_lap.mat")
load("Statistics\dataRegressionPop.mat");

sessionID = [];
animal = [];
condition = [];
track = [];
propApp = [];
propDis = [];
propStable = [];
oddsDisStable = [];
nbCells = [];

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
        current_label = repelem("", length(cells));
        current_label(isGoodPCRUN1 & isGoodPCRUN2) = "Stable";
        current_label(isGoodPCRUN1 & ~isGoodPCRUN2 & isGoodPCRUN2Other) = "Disapear";
        current_label(~isGoodPCRUN1 & isGoodPCRUN2 & isGoodPCRUN1Other) = "Appear";
        current_label(~isGoodPCRUN1 & ~isGoodPCRUN2) = "Unstable";

        nbStableSpec = sum(isGoodPCRUN1 & ~isGoodPCRUN2 & ~isGoodPCRUN1Other & ~isGoodPCRUN2Other)...
                       /sum(isGoodPCRUN1 & ~isGoodPCRUN2);
        
        % current_label = repelem("", length(cells));
        % current_label(isGoodPCRUN1 & isGoodPCRUN2) = "Stable";
        % current_label(isGoodPCRUN1 & ~isGoodPCRUN2) = "Disapear";
        % current_label(~isGoodPCRUN1 & isGoodPCRUN2) = "Appear";
        % current_label(~isGoodPCRUN1 & ~isGoodPCRUN2) = "Unstable";

        % We add the data
        sessionID = [sessionID; sID];
        animal = [animal; animalOI];
        condition = [condition; conditionOI];
        track = [track; trackOI];
        propApp = [propApp; sum(current_label == "Appear")/length(cells)];
        propDis = [propDis; sum(current_label == "Disapear")/length(cells)];
        propStable = [propStable; sum(current_label == "Stable")/length(cells)];
        oddsDisStable = [oddsDisStable; nbStableSpec];
        nbCells = [nbCells; length(cells)];

    end
end

data_prop = table(sessionID, animal, condition, track, propApp, propDis, propStable, oddsDisStable, nbCells);
dataT1 = data_prop(data_prop.track == 1, :);
dataT2 = data_prop(data_prop.track == 2, :);

dataT2.intraApp = (dataT1.propApp - dataT2.propApp)./(dataT1.propApp + dataT2.propApp);
dataT2.intraDis = (dataT1.propDis - dataT2.propDis)./(dataT1.propDis + dataT2.propDis);

condition_split = split(dataT2.condition, 'x');
dataT2.condition = str2double(condition_split(:, 2));

%%
tiledlayout(1, 2);
nexttile;
scatter(log2(dataT2.condition), dataT2.intraApp, "filled");
ylabel("<- More in T2                       More in T1 ->")
xlabel("log Number of laps")
title("% of appearing cells after sleep")
hold on;
coefficients = polyfit(log2(dataT2.condition), dataT2.intraApp, 1);
plot(0:0.1:3, polyval(coefficients, 0:0.1:3), 'r', "LineWidth", 2)
grid on;

nexttile
scatter(log2(dataT2.condition), dataT2.intraDis, "filled");
ylabel("<- More in T2                       More in T1 ->")
xlabel("log Number of laps")
title("% of disappearing cells after sleep")
hold on;
coefficients = polyfit(log2(dataT2.condition), dataT2.intraDis, 1);
plot(0:0.1:3, polyval(coefficients, 0:0.1:3), 'r', "LineWidth", 2)

grid on;

linkaxes;

%% Link with refinement
condition_mut = split(data_prop.condition, 'x');
data_prop.condition = str2double(condition_mut(:, 2));
data_prop.condition(data_prop.track == 1) = 16;
data_prop.conditionLogCent = log2(data_prop.condition) - mean(log2(data_prop.condition));

data_prop = horzcat(data_prop, data(:, 4:9));

scatter(data_prop.propApp, data_prop.refinCorr);
scatter(data_prop.propDis, data_prop.refinCorr);
scatter(data_prop.propStable, data_prop.refinCorr);

data_prop.propDisC = data_prop.propDis - mean(data_prop.propDis);

lme = fitlme(data_prop, "refinCorr ~ conditionLogCent * propDisC + (1|animal)");
disp(lme);

% scatter(data_prop.refinCorr(data_prop.condition == 16), data_prop.propApp(data_prop.condition == 16))
% scatter(data_prop.refinCorr(data_prop.condition ~= 16), data_prop.propDis(data_prop.condition ~= 16))

figure;
scatter(data_prop.condition, data_prop.oddsDisStable)