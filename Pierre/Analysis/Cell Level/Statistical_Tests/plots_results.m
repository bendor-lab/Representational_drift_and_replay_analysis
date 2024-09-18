% Script to generate the main plots of the cell analysis
clear

data = load("dataRegression.mat");
data = data.data;
set(0,'defaultfigurecolor',[1 1 1])

session = data_folders_excl;
session = session{6};

load(session + "/extracted_place_fields.mat")
load(session + "\extracted_lap_place_fields.mat")
load(session + "\extracted_directional_lap_place_fields.mat")

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


x = linspace(-5, 5, 100);
y1 = normpdf(x, 0, 1.2);
y2 = 0.3 *normpdf(x, 0, 1.2);

figure;
hold on;
area(x, y1, 'FaceColor', '#4789bb', 'EdgeColor', 'none');
area(x, y2, 'FaceColor', '#e15e4e', 'EdgeColor', 'none');
hold off;
axis off;
axis square;

%% a. Population change

% 1. PV - Correlation with the final place field

dataLapCorr = load("../../Population Level/Statistics/timeSeriesStable.mat");
dataLapCorr = dataLapCorr.data;
% dataLapCorr.condition(dataLapCorr.condition <= 8) = 8;
summaryLapDataCorr = groupsummary(dataLapCorr, ["condition", "exposure", "lap"], ["median", "std"], ["pvCorr"]);
summaryLapDataCorr.se_pvCorr = summaryLapDataCorr.std_pvCorr./sqrt(summaryLapDataCorr.GroupCount);

f4_5 = figure;
f4_5.Position = [0,0,964,542];
timeSeriesOverLapPop(summaryLapDataCorr, "median_pvCorr", "se_pvCorr", "PV correlation with the FPF");


% 2. PV- Correlation between one direction and the other (directionality)

dataLapCorr = load("../../Population Level/Statistics/timeSeriesDirectionalityStable.mat");
dataLapCorr = dataLapCorr.data;
summaryLapDataCorr = groupsummary(dataLapCorr, ["condition", "exposure", "lap"], ["median", "std"], ["pvCorr"]);
summaryLapDataCorr.se_pvCorr = summaryLapDataCorr.std_pvCorr./sqrt(summaryLapDataCorr.GroupCount);

f4_7 = figure;
f4_7.Position = [0,0,964,542];
timeSeriesOverLapPop(summaryLapDataCorr, "median_pvCorr", "se_pvCorr", "PV correlation between opposite direction PF");

%% b. Cell change --------------------------------------------------------

dataLap = load("timeSeriesInterneurons.mat");
dataLap = dataLap.data;

popDataLap = load("../../Population Level/Statistics/timeSeries_interneurons.mat");
popDataLap = popDataLap.data;

summaryLapData = groupsummary(dataLap, ["condition", "exposure", "lap"], ["median", "std"], ...
    ["CMdiff", "FRdiff", "PeakDiff"]);

summaryLapDataPop = groupsummary(popDataLap, ["condition", "exposure", "lap"], ["median", "std"], ...
    ["pvCorr", "speed"]);

summaryLapData.se_CMdiff = summaryLapData.std_CMdiff./sqrt(summaryLapData.GroupCount);
summaryLapData.se_FRdiff = summaryLapData.std_FRdiff./sqrt(summaryLapData.GroupCount);
summaryLapData.se_PeakDiff = summaryLapData.std_PeakDiff./sqrt(summaryLapData.GroupCount);
summaryLapDataPop.se_pvCorr = summaryLapDataPop.std_pvCorr./sqrt(summaryLapDataPop.GroupCount);
summaryLapDataPop.se_speed = summaryLapDataPop.std_speed./sqrt(summaryLapDataPop.GroupCount);

% 1. Center of mass
f5 = figure;
f5.Position = [0,0,964,542];
timeSeriesOverLap(summaryLapData, "median_CMdiff", "se_CMdiff", "Center of Mass");

% 2. Max FR

f6 = figure;
f6.Position = [0, 0, 964, 542];
timeSeriesOverLap(summaryLapData, "median_FRdiff", "se_FRdiff", "Max Firing Rate");

% 3. Peak location

f7 = figure;
f7.Position = [0, 0, 964, 542];
timeSeriesOverLap(summaryLapData, "median_PeakDiff", "se_PeakDiff", "Peak Location");

% 4. PV correlation

f20 = figure;
f20.Position = [0, 0, 964, 542];
timeSeriesOverLap(summaryLapDataPop, "median_pvCorr", "se_pvCorr", "PV correlation");

% 5. Speed

f21 = figure;
f21.Position = [0, 0, 964, 542];
timeSeriesOverLap(summaryLapDataPop, "median_speed", "se_speed", "Speed");

%% c. Cell change - 1 vs 16 vs 1 vs 16 vs FPF

summaryLapDataAnim = groupsummary(dataLap, ["animal", "condition", "exposure", "lap"], ["mean", "std"], ["CMdiff", "FRdiff", "PeakDiff"]);

f8 = figure;
f8.Position = [0,0,900,420];

dataExpLap1 = summaryLapDataAnim(summaryLapDataAnim.lap == 1 & summaryLapDataAnim.exposure == 1, :);
dataReExpLap1 = summaryLapDataAnim(summaryLapDataAnim.lap == 1 & summaryLapDataAnim.exposure == 2, :);
dataExpLapEnd = summaryLapDataAnim(summaryLapDataAnim.lap == summaryLapDataAnim.condition & summaryLapDataAnim.exposure == 1, :);
dataReExpLapEnd = summaryLapDataAnim(summaryLapDataAnim.lap == 16 & summaryLapDataAnim.exposure == 2, :);
conditionCat = categorical(dataExpLap1.condition);

t8 = tiledlayout(1, 4);
colors = [255, 215, 0;
    255, 168, 0;
    255, 98, 82;
    205, 52, 181;
    157, 2, 215;
    0, 0, 255];

% Normalize the RGB values to be between 0 and 1
colors = colors / 255;
colors = flip(colors);

n1 = nexttile(1);
b1 = boxplot(dataExpLap1.mean_CMdiff, conditionCat);
title('1^{st} lap - RUN1')
ylim([0 60])

h = findobj(n1, 'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'), colors(j, :),'FaceAlpha',.5);
end

n2 = nexttile(2);
b2 = boxplot(dataExpLapEnd.mean_CMdiff, conditionCat);
title('Last lap - RUN1')
ylim([0 60])

h = findobj(n2, 'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'), colors(j, :),'FaceAlpha',.5);
end

n3 = nexttile(3);
b3 = boxplot(dataReExpLap1.mean_CMdiff, conditionCat);
title('1^{st} lap - RUN2')
ylim([0 60])

h = findobj(n3, 'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'), colors(j, :),'FaceAlpha',.5);
end

n4 = nexttile(4);
b4 = boxplot(dataReExpLapEnd.mean_CMdiff, conditionCat);
title('16^{th} lap - RUN1')
ylim([0 60])

h = findobj(n4, 'Tag','Box');
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'), colors(j, :),'FaceAlpha',.5);
end

n1.FontSize = 12;
n2.FontSize = 12;
n3.FontSize = 12;
n4.FontSize = 12;

xlabel(t8, "Condition", 'FontSize', 12)
ylabel(t8, "\DeltaCM with the FPF", 'FontSize', 12)

%% III. Replay plots -----------------------------------------------------

% 1. Replay decoding

load(session + "\Replay\RUN1_decoding\significant_replay_events_wcorr");
minPIndex = find(significant_replay_events.track(1).p_value == min(significant_replay_events.track(1).p_value));
minPIndex = minPIndex(4);
dec_position = significant_replay_events.track(1).decoded_position{minPIndex};
time_size = numel(dec_position(1, :));

% We get a raster plot of all the activity
allSpikes = significant_replay_events.track(1).spikes{minPIndex};

f = figure;

tiledlayout(1, 2);
t10 = nexttile;
makeRaster(allSpikes, time_size)
title("Spike count")

t11 = nexttile;
imagesc(dec_position);
axis on;
xticks(0:2:time_size);
xticklabels(0:0.040:(time_size*0.020))
xlabel("Time (s)");
ylabel("Position (cm)")
yticks([0.5, 10.5, 20.5]);
yticklabels([200, 100, 0])
title("Bayesian reconstruction")
colorbar;

%% Explaining Final Place Field and PV-correlation

%% Final place field

% 6 x 1 subplots of place fields during consecutive laps
f = figure;
cellChosen = goodCells(11);
xChosen = 25:27;
fpf = zeros(1, 100);

f.Position = [680   122   560   756];

for i = 1:6
    pf_trackLap = cell2mat(lap_place_fields(3).Complete_Lap{16 + i}.smooth');
    pf_trackLap = pf_trackLap(cellChosen, :);
    fpf = fpf + pf_trackLap;

    subplot(8, 1, i)
    area(pf_trackLap, "EdgeColor", "none", "FaceColor", '#4789bb');
    hold on;
    area(xChosen, pf_trackLap(xChosen), "EdgeColor", "none", "FaceColor", '#e15e4e');
    axis off

end

fpf = fpf/6;

subplot(8, 1, 8);
area(fpf, "EdgeColor", "none", "FaceColor", '#4789bb');
hold on;
area(xChosen, fpf(xChosen), "EdgeColor", "none", "FaceColor", '#e15e4e');

h=gca;
h.Box = "off";
h.XAxis.TickLength = [0 0];
h.YAxis.TickLength = [0 0];
ylabel("FR")
xlabel("Position (cm)")

%% PV correlation

f = figure;
f.Position = [680   122   560   756];

cellsChosen = [16 60 61 31];
cellsChosen = goodCells(cellsChosen);
xChosen = 50:54;

cellsPFLap1 = cell2mat(lap_place_fields(1).Complete_Lap{6}.smooth');
cellsPFLap1 = cellsPFLap1(cellsChosen, :);

cellsFPF = zeros(size(cellsPFLap1));

for cellID = 1:numel(cellsChosen)
    current_cell = cellsChosen(cellID);
    fpf = zeros(1, 100);

    for i = 1:6
        current_pf = lap_place_fields(3).Complete_Lap{16 + i}.smooth{current_cell};
        fpf = fpf + current_pf;
    end
    cellsFPF(cellID, :) = fpf/6;
end

ylimLap1 = max(max(cellsPFLap1));
ylimFPF =  max(max(cellsFPF));

current_ylim = max([ylimLap1, ylimFPF]);

for cellID = 1:numel(cellsChosen)

    current_cell = cellsChosen(cellID);
    subplot(numel(cellsChosen) + 1, 2, 2*cellID - 1)
    area(cellsPFLap1(cellID, :), "EdgeColor", "none", "FaceColor", '#4789bb')
    ylim([0 current_ylim]);
    hold on;
    area(xChosen, cellsPFLap1(cellID, xChosen), "EdgeColor", "none", "FaceColor", '#e15e4e');
    axis off;

    subplot(numel(cellsChosen) + 1, 2, 2*cellID)
    area(cellsFPF(cellID, :), "EdgeColor", "none", "FaceColor", '#4789bb')
    ylim([0 current_ylim]);
    hold on;
    area(xChosen, cellsFPF(cellID, xChosen), "EdgeColor", "none", "FaceColor", '#e15e4e');
    axis off;

    subplot(numel(cellsChosen) + 1, 2, 2*numel(cellsChosen) + 1)
    area(xChosen - 22 + cellID * 10, cellsPFLap1(cellID, xChosen), "EdgeColor", "none", "FaceColor", '#e15e4e');
    hold on;
    axis off;
    xlim([0 100]);
    ylim([0 current_ylim]);

    subplot(numel(cellsChosen) + 1, 2, 2*numel(cellsChosen) + 2)
    area(xChosen - 22 + cellID * 10, cellsFPF(cellID, xChosen), "EdgeColor", "none", "FaceColor", '#e15e4e');
    hold on;
    axis off;
    xlim([0 100]);
    ylim([0 current_ylim]);

end

%% Suplementary stuff

% Look at firing rate for dis / app / stable

dataLap = load("timeSeries.mat");
dataLap = dataLap.data;
dataLap.condition(dataLap.condition <= 8) = 8;
summaryLapData = groupsummary(dataLap, ["condition", "exposure", "lap"], ["median", "std"], ["CMdiff", "FRdiff", "PeakDiff", "meanFR"]);
summaryLapData.se_meanFR = summaryLapData.std_meanFR./sqrt(summaryLapData.GroupCount);
summaryLapData.se_CMdiff = summaryLapData.std_CMdiff./sqrt(summaryLapData.GroupCount);
summaryLapData.se_FRdiff = summaryLapData.std_FRdiff./sqrt(summaryLapData.GroupCount);

timeSeriesOverLap(summaryLapData(summaryLapData.label == "Appear", :), "median_FRdiff", "se_FRdiff", "Max FR");

timeSeriesOverLap(summaryLapData(summaryLapData.label == "Stable", :), "median_meanFR", "se_meanFR", "Firing rate");
ylim([0 9]);

% Why is the FR of laps < 8 inferior to 16 laps ?

%% Plot evolution of firing rate distribution
figure;
timeSeriesOverLap(summaryLapData(summaryLapData.label == "Disappear", :), "median_meanFR", "se_meanFR", "Firing rate");
ylim([0 9]);

%%

sum = groupsummary(data, ["sessionID", "condition"], "median", ["refinCM", "refinFR"]);

fig = figure;
ax = gca;

old_values = [1, 2, 3, 4, 8, 16];
new_values = [1, 3, 5, 7, 9, 11];

x = changem(sum.condition, new_values, old_values);
x = x + randn(numel(x), 1)/10;

%% Directional stabilization of place fields

load("X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day3_16x1\extracted_directional_lap_place_fields.mat")
load("X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day3_16x1\extracted_place_fields.mat")
%%

laps_to_get = [1, 2, 3, 4, NaN, 13, 14, 15];
cell = 1; % 12th good place cell
trackOI = 1;
cellID = place_fields.track(trackOI).good_cells(cell);

pfDir1 = {};
pfDir2 = {};

for i = 1:numel(laps_to_get)
    l2get = laps_to_get(i);
    
    if isnan(l2get)
        pfDir1{end + 1} = zeros(1, 100);
        pfDir2{end + 1} = zeros(1, 100);
        continue;
    end
    
    % Dir 1
    current_PF_dir1 = lap_directional_place_fields(trackOI).dir1.Complete_Lap{l2get}.smooth{cellID};
    % Dir 2
    current_PF_dir2 = lap_directional_place_fields(trackOI).dir2.Complete_Lap{l2get}.smooth{cellID};
    
    pfDir1{end + 1} = current_PF_dir1;
    pfDir2{end + 1} = current_PF_dir2;
end

f = figure;
for i = 1:numel(laps_to_get)
    if isnan(laps_to_get(i))
        continue;
    end
    
    subplot(2, 1, 1);
    area((0:99) + 100*(i - 1), pfDir1{i}, 'FaceColor', 'b');
    ylim([0 10])
    hold on;
    
    subplot(2, 1, 2);
    area((0:99) + 100*(i - 1), pfDir2{i}, 'FaceColor', 'r');
    ylim([0 10])
    hold on;
end


for c = 1:numel(old_values)
    curr_cond = old_values(c);
    scatter(x(sum.condition == curr_cond), ...
        y(sum.condition == curr_cond), ...
        "filled")
    hold on;
end

grid on;
xticks(new_values)
xticklabels(old_values)

xlabel('Laps ran during the 1st exposure', 'FontSize', 12);
ylabel('Reduction in CM distance with the FPF over sleep', 'FontSize', 12);

%%

data2 = data;
data2(isnan(data.partP1Rep) | isnan(data.refinCM), :) = [];

scatter(data2.partP1Rep, data2.refinCM, "filled");

xlabel('Number of POST1 sleep replay', 'FontSize', 12);
ylabel('Reduction in CM distance with the FPF over sleep', 'FontSize', 12);
grid on;
p = polyfit(data2.partP1Rep, data2.refinCM, 1);
hold on;
plot(data2.partP1Rep, polyval(p, data2.partP1Rep), 'r')

%% Plot new data
% Need to be in population folder
load("timeSeries_new_data_1.mat");
summaryLapDataPop = groupsummary(data, ["condition", "exposure", "lap"], ["median", "std"], ...
    ["pvCorr", "speed"]);

subplot(1, 2, 1)
subset = summaryLapDataPop(summaryLapDataPop.exposure == 1, :);
all_conditions = unique(subset.condition);
for c = all_conditions'
    subsub = subset(subset.condition == c, :);
    if (height(subsub) == 1)
        scatter(subsub.lap, subsub.median_pvCorr)
    else
        plot(subsub.lap, subsub.median_pvCorr, "LineWidth", 2)
    end

    hold on;
end

xlim([0 16])
ylim([0 1])
grid on;
title("First exposure");
xlabel("Lap number")
ylabel("PV correlation with last lap")

subplot(1, 2, 2)
subset = summaryLapDataPop(summaryLapDataPop.exposure == 2, :);
all_conditions = unique(subset.condition);
for c = all_conditions'
    subsub = subset(subset.condition == c, :);
    if (height(subsub) == 1)
        scatter(subsub.lap, subsub.median_pvCorr)
    else
        plot(subsub.lap, subsub.median_pvCorr, "LineWidth", 2)
    end

    hold on;
end

xlim([0 16])
ylim([0 1])
grid on;
title("Re-exposure");

legend({"1 lap", "16 laps"})

%%

load("timeSeries_new_data_1.mat");
summaryLapData = groupsummary(data, ["condition", "exposure", "lap"], ["median", "std"], ...
    ["CMdiff", "FRdiff", "PeakDiff"]);

summaryLapData.se_CMdiff = summaryLapData.std_CMdiff./sqrt(summaryLapData.GroupCount);
summaryLapData.se_FRdiff = summaryLapData.std_FRdiff./sqrt(summaryLapData.GroupCount);
summaryLapData.se_PeakDiff = summaryLapData.std_PeakDiff./sqrt(summaryLapData.GroupCount);

subplot(3, 2, 1)
subset = summaryLapData(summaryLapData.exposure == 1, :);
all_conditions = unique(subset.condition);
for c = all_conditions'
    subsub = subset(subset.condition == c, :);
    if (height(subsub) == 1)
        scatter(subsub.lap, subsub.median_CMdiff)
    else
        errorbar(subsub.lap, subsub.median_CMdiff, subsub.se_CMdiff, "LineWidth", 2)
    end

    hold on;
end

xlim([0 16])
ylim([0 20])
grid on;
title("First exposure");
xlabel("Lap number")
ylabel("CM difference with last lap")

subplot(3, 2, 2)
subset = summaryLapData(summaryLapData.exposure == 2, :);
all_conditions = unique(subset.condition);
for c = all_conditions'
    subsub = subset(subset.condition == c, :);
    if (height(subsub) == 1)
        errorbar(subsub.lap, subsub.median_CMdiff, subsub.se_CMdiff)
    else
        errorbar(subsub.lap, subsub.median_CMdiff, subsub.se_CMdiff, "LineWidth", 2)
    end

    hold on;
end

xlim([0 16])
ylim([0 20])
grid on;
title("Re-exposure");

legend({"1 lap", "16 laps"})

subplot(3, 2, 3)
subset = summaryLapData(summaryLapData.exposure == 1, :);
all_conditions = unique(subset.condition);
for c = all_conditions'
    subsub = subset(subset.condition == c, :);
    if (height(subsub) == 1)
        scatter(subsub.lap, subsub.median_FRdiff)
    else
        errorbar(subsub.lap, subsub.median_FRdiff, subsub.se_FRdiff, "LineWidth", 2)
    end

    hold on;
end

xlim([0 16])
ylim([0 0.5])
grid on;
title("First exposure");
xlabel("Lap number")
ylabel("Firing Rate difference with last lap")

subplot(3, 2, 4)
subset = summaryLapData(summaryLapData.exposure == 2, :);
all_conditions = unique(subset.condition);
for c = all_conditions'
    subsub = subset(subset.condition == c, :);
    if (height(subsub) == 1)
        errorbar(subsub.lap, subsub.median_FRdiff, subsub.se_FRdiff)
    else
        errorbar(subsub.lap, subsub.median_FRdiff, subsub.se_FRdiff, "LineWidth", 2)
    end

    hold on;
end

xlim([0 16])
ylim([0 0.5])
grid on;
title("Re-exposure");

legend({"1 lap", "16 laps"})

subplot(3, 2, 5)
subset = summaryLapData(summaryLapData.exposure == 1, :);
all_conditions = unique(subset.condition);
for c = all_conditions'
    subsub = subset(subset.condition == c, :);
    if (height(subsub) == 1)
        scatter(subsub.lap, subsub.median_PeakDiff)
    else
        errorbar(subsub.lap, subsub.median_PeakDiff, subsub.se_PeakDiff, "LineWidth", 2)
    end

    hold on;
end

xlim([0 16])
ylim([0 30])
grid on;
title("First exposure");
xlabel("Lap number")
ylabel("Peak difference with last lap")

subplot(3, 2, 6)
subset = summaryLapData(summaryLapData.exposure == 2, :);
all_conditions = unique(subset.condition);
for c = all_conditions'
    subsub = subset(subset.condition == c, :);
    if (height(subsub) == 1)
        errorbar(subsub.lap, subsub.median_PeakDiff, subsub.se_PeakDiff)
    else
        errorbar(subsub.lap, subsub.median_PeakDiff, subsub.se_PeakDiff, "LineWidth", 2)
    end

    hold on;
end

xlim([0 16])
ylim([0 30])
grid on;
title("Re-exposure");

legend({"1 lap", "16 laps"})

%%

subset1 = data(data.condition == 16, :);
subset2 = data(data.condition ~= 16, :);

sub1_last = subset1(subset1.exposure == 1 & subset1.lap == 13, :);
sub1_first = subset1(subset1.exposure == 2 & subset1.lap == 1, :);

refinement_16_CM = sub1_last.CMdiff - sub1_first.CMdiff;
refinement_16_FR = sub1_last.FRdiff - sub1_first.FRdiff;
refinement_16_Peak = sub1_last.PeakDiff - sub1_first.PeakDiff;

sub2_last = subset2(subset2.exposure == 1 & subset2.lap == 1, :);
sub2_first = subset2(subset2.exposure == 2 & subset2.lap == 1, :);

refinement_1_CM = sub2_last.CMdiff - sub2_first.CMdiff;
refinement_1_FR = sub2_last.FRdiff - sub2_first.FRdiff;
refinement_1_Peak = sub2_last.PeakDiff - sub2_first.PeakDiff;

figure;

subplot(3, 2, 1)
histogram(refinement_16_CM, -50:10:50)
hold on;
xline(0, 'r--', "LineWidth", 2)
grid on;

[~, p, ~, ~] = ttest(refinement_16_CM);

title("Refinement - 16 laps (p = " + p + ")")
ylabel("Count")
xlabel("CM distance reduction after REST (30 s)")

subplot(3, 2, 2)
histogram(refinement_1_CM, -50:10:50)
hold on;
xline(0, 'r--', "LineWidth", 2)
grid on;

[~, p, ~, ~] = ttest(refinement_1_CM);
title("Refinement - 1 lap (p = " + p + ")")

% ------------------------------------------

subplot(3, 2, 3)
histogram(refinement_16_FR, -1:0.1:1)
hold on;
xline(0, 'r--', "LineWidth", 2)
grid on;

[~, p, ~, ~] = ttest(refinement_16_FR);

title("Refinement - 16 laps (p = " + p + ")")
ylabel("Count")
xlabel("FR distance reduction after REST (30 s)")

subplot(3, 2, 4)
histogram(refinement_1_FR, -1:0.1:1)
hold on;
xline(0, 'r--', "LineWidth", 2)
grid on;

[~, p, ~, ~] = ttest(refinement_1_FR);
title("Refinement - 1 lap (p = " + p + ")")

% ------------------------------------------

subplot(3, 2, 5)
histogram(refinement_16_Peak, -100:20:100)
hold on;
xline(0, 'r--', "LineWidth", 2)
grid on;

[~, p, ~, ~] = ttest(refinement_16_Peak);

title("Refinement - 16 laps (p = " + p + ")")
ylabel("Count")
xlabel("Peak Loc. distance reduction after REST (30 s)")

subplot(3, 2, 6)
histogram(refinement_1_Peak, -100:20:100)
hold on;
xline(0, 'r--', "LineWidth", 2)
grid on;

[~, p, ~, ~] = ttest(refinement_1_Peak);
title("Refinement - 1 lap (p = " + p + ")")
