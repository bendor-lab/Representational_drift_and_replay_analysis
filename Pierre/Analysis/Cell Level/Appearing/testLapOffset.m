% Do we really detect more appearing cells during POST1 when taking PC
% classification just before / just after ?

clear
sessions = data_folders_excl; % We fetch all the sessions folders paths
trackOI = 1;

sessionID = [];
l = [];
nbAppearingCells = [];
nbDisCells = [];
nbPersistAppear = [];
nbPersistDis = [];

for fID = 1:numel(sessions)
    
    disp(fID);
    file = sessions{fID};

    % Load the data
    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;

    allLapsConcat = [lap_place_fields(trackOI).Complete_Lap  lap_place_fields(trackOI + 2).Complete_Lap];
    numberLapsRUN1 = numel(lap_place_fields(trackOI).Complete_Lap);
    numberLaps = numel(allLapsConcat);

    % Create a matrix to store all good place cells during lap L
    allGoodCells = cellfun(@(x) x.good_cells, allLapsConcat, 'UniformOutput', false);
    maxNbGoodCells = max(cellfun(@(x) numel(x), allGoodCells));

    goodMat = NaN(maxNbGoodCells, numberLaps);

    for el = 1:numberLaps
        goodMat(1:numel(allGoodCells{el}), el) = allGoodCells{el}';
    end

    for lap = 2:numberLaps
        currentGoodCells = goodMat(:, lap);
        currentGoodCells(isnan(currentGoodCells)) = [];

        pastGoodCells = unique(goodMat(:, lap-1));
        pastGoodCells(isnan(pastGoodCells)) = [];

        % Was the cell a good cell during the previous lap ?
        appearing = setdiff(currentGoodCells, pastGoodCells);
        disappearing = setdiff(pastGoodCells, currentGoodCells);

        nbApp = numel(appearing);
        nbDis = numel(disappearing);

        l(end + 1) = lap;
        nbAppearingCells(end + 1) = nbApp;
        nbDisCells(end + 1) = nbDis;

        % Other way of classifying : cells that were silent till now and that
        % will stay active

        current_app = [];
        current_dis = [];

        for cID = 1:numel(currentGoodCells)
            cell = currentGoodCells(cID);

            countCellInPast = sum(sum(goodMat(:, 1:lap-1) == cell));

            countCellInFutur = sum(sum(goodMat(:, lap:end) == cell));

            if countCellInPast == 0 && countCellInFutur == (numberLaps - lap) + 1
                current_app(end + 1) = cell;

            elseif countCellInPast == lap-1 && countCellInFutur == 0
                current_dis(end + 1) = cell;
            end
        end

        nbPersistAppear(end + 1) = numel(current_app);
        nbPersistDis(end + 1) = numel(current_dis);

    end

    sessionID(end + 1) = fID;

end

l = l';
nbAppearingCells = nbAppearingCells';
nbDisCells = nbDisCells';
nbPersistAppear = nbPersistAppear';
nbPersistDis = nbPersistDis';

data = table(l, nbAppearingCells, nbDisCells, nbPersistAppear, nbPersistDis);

%% Plotting

summaryData = groupsummary(data, ["l"], "mean", ["nbAppearingCells", "nbDisCells", "nbPersistAppear", "nbPersistDis"]);

% Plotting the number of appearing / disappearing based on lap and sleep

f = figure;
tiledlayout(2, 2);
n1 = nexttile;
plot(summaryData.l, summaryData.mean_nbAppearingCells);
hold on;
xline(numberLapsRUN1 + 0.5, "--", "Color", "r");
title("Number of app. cells - lap before vs. current lap")
xlabel("Cutoff Lap");
ylabel("Number of cells")

n2 = nexttile;
plot(summaryData.l, summaryData.mean_nbDisCells);
hold on;
xline(numberLapsRUN1 + 0.5, "--", "Color", "r");
title("Number of dis. cells - lap before vs. current lap")
xlabel("Cutoff Lap");
ylabel("Number of cells")

n3 = nexttile;
plot(summaryData.l, summaryData.mean_nbPersistAppear);
hold on;
xline(numberLapsRUN1 + 0.5, "--", "Color", "r");
title("Number of app. cells - persistent")
xlabel("Cutoff Lap");
ylabel("Number of cells")

n4 = nexttile;
plot(summaryData.l, summaryData.mean_nbPersistDis);
hold on;
xline(numberLapsRUN1 + 0.5, "--", "Color", "r");
title("Number of dis. cells - persistent")
xlabel("Cutoff Lap");
ylabel("Number of cells")
legend({"", "Sleep"});

f.Position = [680         263        1006         615];
