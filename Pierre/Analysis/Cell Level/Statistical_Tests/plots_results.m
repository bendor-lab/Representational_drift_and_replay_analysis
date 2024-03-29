% Script to generate the main plots of the cell analysis
clear

data = load("dataRegression.mat");
data = data.data;
set(0,'defaultfigurecolor',[1 1 1])

session = data_folders_excl;
session = session{6};

load(session + "/extracted_place_fields.mat")
load(session + "\extracted_lap_place_fields.mat")

%% I. Stacked plot of sorted place field ----------------------------------

%% a. Remapping Track 1 vs. Track 2

goodCells = intersect(place_fields.track(3).good_cells, place_fields.track(4).good_cells);

pf_track1 = cell2mat(place_fields.track(3).smooth');
pf_track1 = pf_track1(goodCells, :);
pf_track2 = cell2mat(place_fields.track(4).smooth');
pf_track2 = pf_track2(goodCells, :);

pf_track1 = normalize(pf_track1, 2, "range");
pf_track2 = normalize(pf_track2, 2, "range");

sortOrderT1 = findSortOrder(pf_track1);
sortOrderT2 = findSortOrder(pf_track2);

pfT1ST1 = pf_track1(sortOrderT1, :);
pfT2ST1 = pf_track2(sortOrderT1, :);
pfT1ST2 = pf_track1(sortOrderT2, :);
pfT2ST2 = pf_track2(sortOrderT2, :);

fig = figure;
fig.Position = [680,421,682,457];
t = tiledlayout(2, 2);
set(gca,'fontname','times')  % Set it to times

nexttile;
stackPF(pfT1ST1, "Place fields on Track 1", "Cells (sorted by Track 1)");
nexttile;
stackPF(pfT1ST2, "Place fields on Track 1", "Cells (sorted by Track 2)");
nexttile;
stackPF(pfT2ST1, "Place fields on Track 2", "Cells (sorted by Track 1)");
nexttile;
stackPF(pfT2ST2, "Place fields on Track 2", "Cells (sorted by Track 2)");

%% b. Remapping first vs. last lap RUN1, ordered by Final Place Field

goodCells = lap_place_fields(1).Complete_Lap{end}.good_cells;

pf_trackLap1 = cell2mat(lap_place_fields(1).Complete_Lap{1}.smooth');
pf_trackLap1 = pf_trackLap1(goodCells, :);

pf_trackLap2 = cell2mat(lap_place_fields(1).Complete_Lap{2}.smooth');
pf_trackLap2 = pf_trackLap2(goodCells, :);

pf_trackLap3 = cell2mat(lap_place_fields(1).Complete_Lap{3}.smooth');
pf_trackLap3 = pf_trackLap3(goodCells, :);

pf_trackLapEnd = cell2mat(lap_place_fields(1).Complete_Lap{end}.smooth');
pf_trackLapEnd = pf_trackLapEnd(goodCells, :);

% We get the final place field
allLapsRUN2 = lap_place_fields(3).Complete_Lap;
meanMat = zeros(numel(goodCells), 100, 6);

for lap = 1:6
    data = cell2mat(allLapsRUN2{16 + lap}.smooth');
    data = data(goodCells, :);
    meanMat(:, :, lap) = data;
end

meanMat = normalize(mean(meanMat, 3, 'omitnan'), 2, "range");

pf_trackLap1 = normalize(pf_trackLap1, 2, "range");
pf_trackLap2 = normalize(pf_trackLap2, 2, "range");
pf_trackLap3 = normalize(pf_trackLap3, 2, "range");
pf_trackLapEnd = normalize(pf_trackLapEnd, 2, "range");

sortOrder = findSortOrder(meanMat);

fig2 = figure;
fig2.Position = [200, 200, 1400,300];
t2 = tiledlayout(1, 4);
set(gca,'fontname','times')  % Set it to times

set(gcf,'color','w');
nexttile;
stackPF(pf_trackLap1(sortOrder, :), "Place fields - Lap 1", "");
mylabel = ylabel({"Cells          ", "(sorted by FPF)"}, "Rotation", 0, "FontSize", 13);

nexttile;
stackPF(pf_trackLap2(sortOrder, :), "Place fields - Lap 2", "");
nexttile;
stackPF(pf_trackLap3(sortOrder, :), "Place fields - Lap 3", "");
nexttile;
stackPF(pf_trackLapEnd(sortOrder, :), "Place fields - Lap 16", "");

%% c. Remapping last lap before sleep - first lap after sleep

goodCells = lap_place_fields(4).Complete_Lap{1}.good_cells;

pf_trackEXP = cell2mat(lap_place_fields(2).Complete_Lap{end}.smooth');
pf_trackEXP = pf_trackEXP(goodCells, :);
pf_trackREEXP = cell2mat(lap_place_fields(4).Complete_Lap{1}.smooth');
pf_trackREEXP = pf_trackREEXP(goodCells, :);

% We get the final place field
allLapsRUN2 = lap_place_fields(4).Complete_Lap;
meanMat = zeros(numel(goodCells), 100, 6);

for lap = 1:6
    data = cell2mat(allLapsRUN2{16 + lap}.smooth');
    data = data(goodCells, :);
    meanMat(:, :, lap) = data;
end

meanMat = normalize(mean(meanMat, 3, 'omitnan'), 2, "range");

pf_trackEXP = normalize(pf_trackEXP, 2, "range");
pf_trackREEXP = normalize(pf_trackREEXP, 2, "range");

sortOrder = findSortOrder(meanMat);

fig2 = figure;
fig2.Position = [500, 500, 830,290];
t2 = tiledlayout(1, 2);
set(gca,'fontname','times')  % Set it to times

set(gcf,'color','w');
nexttile;
stackPF(pf_trackEXP(sortOrder, :), "Place fields - Lap before sleep", "");

mylabel = ylabel({"Cells        ", "(sorted by FPF)"}, "Rotation", 0, "FontSize", 13);

nexttile;
stackPF(pf_trackREEXP(sortOrder, :), "Place fields - Lap after sleep", "");


%% II. Remapping over laps -----------------------------------

%% a. Population change

% 1. PV - Correlation with the final place field



% 2. PV- Correlation between one direction and the other (directionality)

%% b. Cell change --------------------------------------------------------

dataLap = load("timeSeries.mat");
dataLap = dataLap.data;
summaryLapData = groupsummary(dataLap, ["condition", "exposure", "lap"], ["median", "std"], ["CMdiff", "FRdiff", "PeakDiff"]);

% 1. Center of mass
f5 = figure; 
f5.Position = [680,336,964,542];
timeSeriesOverLap(summaryLapData, "median_CMdiff", "Center of Mass");

% 2. Peak Location

f6 = figure; 
f6.Position = [680,336,964,542];
timeSeriesOverLap(summaryLapData, "median_FRdiff", "Max Firing Rate");

% 3. Max firing rate

f7 = figure; 
f7.Position = [680,336,964,542];
timeSeriesOverLap(summaryLapData, "median_PeakDiff", "Peak Location");


%% c. Cell change - 1 vs 16 vs 1 vs 16 vs FPF

summaryLapDataAnim = groupsummary(dataLap, ["animal", "condition", "exposure", "lap"], ["mean", "std"], ["CMdiff", "FRdiff", "PeakDiff"]);

f8 = figure;

dataExpLap1 = summaryLapDataAnim(summaryLapDataAnim.lap == 1 & summaryLapDataAnim.exposure == 1, :);
dataReExpLap1 = summaryLapDataAnim(summaryLapDataAnim.lap == 1 & summaryLapDataAnim.exposure == 2, :);
dataExpLapEnd = summaryLapDataAnim(summaryLapDataAnim.lap == summaryLapDataAnim.condition & summaryLapDataAnim.exposure == 1, :);
dataReExpLapEnd = summaryLapDataAnim(summaryLapDataAnim.lap == 16 & summaryLapDataAnim.exposure == 2, :);

conditionCat = categorical(dataExpLap1.condition);


subplot(1,4,1)
boxchart(conditionCat, dataExpLap1.mean_CMdiff)
title('Data 1')
ylim([0 60])

subplot(1,4,2)
boxchart(conditionCat, dataExpLapEnd.mean_CMdiff)
title('Data 2')
ylim([0 60])

subplot(1,4,3)
boxchart(conditionCat, dataReExpLap1.mean_CMdiff)
title('Data 3')
ylim([0 60])

subplot(1,4,4)
boxchart(conditionCat, dataReExpLapEnd.mean_CMdiff)
title('Data 4')
ylim([0 60])
