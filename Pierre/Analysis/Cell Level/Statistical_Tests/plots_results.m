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

%% b. Remapping first vs. last lap RUN1

goodCells = lap_place_fields(1).Complete_Lap{end}.good_cells;

pf_trackLap1 = cell2mat(lap_place_fields(1).Complete_Lap{1}.smooth');
pf_trackLap1 = pf_trackLap1(goodCells, :);
pf_trackLapEnd = cell2mat(lap_place_fields(1).Complete_Lap{end}.smooth');
pf_trackLapEnd = pf_trackLapEnd(goodCells, :);

pf_trackLap1 = normalize(pf_trackLap1, 2, "range");
pf_trackLapEnd = normalize(pf_trackLapEnd, 2, "range");

sortOrderLap1 = findSortOrder(pf_trackLap1);
sortOrderLapEnd = findSortOrder(pf_trackLapEnd);

fig2 = figure;
fig2.Position = [500, 500, 830,290];
t2 = tiledlayout(1, 2);
set(gca,'fontname','times')  % Set it to times

set(gcf,'color','w');
nexttile;
stackPF(pf_trackLap1(sortOrderLapEnd, :), "Place fields - Lap 1", "");

mylabel = ylabel({"Cells          ", "(sorted by Lap 16)"}, "Rotation", 0, "FontSize", 13);

nexttile;
stackPF(pf_trackLapEnd(sortOrderLapEnd, :), "Place fields - Lap 16", "");

%% c. Remapping last lap before sleep - first lap after sleep

goodCells = lap_place_fields(4).Complete_Lap{1}.good_cells;

pf_trackEXP = cell2mat(lap_place_fields(2).Complete_Lap{end}.smooth');
pf_trackEXP = pf_trackEXP(goodCells, :);
pf_trackREEXP = cell2mat(lap_place_fields(4).Complete_Lap{1}.smooth');
pf_trackREEXP = pf_trackREEXP(goodCells, :);

pf_trackEXP = normalize(pf_trackEXP, 2, "range");
pf_trackREEXP = normalize(pf_trackREEXP, 2, "range");

sortOrderLapEXP = findSortOrder(pf_trackEXP);
sortOrderLapREEXP = findSortOrder(pf_trackREEXP);

fig2 = figure;
fig2.Position = [500, 500, 830,290];
t2 = tiledlayout(1, 2);
set(gca,'fontname','times')  % Set it to times

set(gcf,'color','w');
nexttile;
stackPF(pf_trackEXP(sortOrderLapREEXP, :), "Place fields - Lap before sleep", "");

mylabel = ylabel({"Cells                    ", "(sorted by first lap after sleep)"}, "Rotation", 0, "FontSize", 13);

nexttile;
stackPF(pf_trackREEXP(sortOrderLapREEXP, :), "Place fields - Lap after sleep", "");


%% II. Remapping over laps -----------------------------------

%% Visualisation of the center of mass, peak location and peak firing rate

% Generate a range of x-values
x = 0:200;

% Compute the y-values of the Gaussian function
y = normpdf(x, 160, 15);
y2 = normpdf(x, 60, 20)*0.4;
y = y + y2;

maxY = max(y);
peakLoc = find(y == maxY, 1);
centerMass = sum(y.*(0:200)/sum(y));
centerMassFR = y(floor(centerMass));

% Plot the Gaussian bell curve
figure;
area(x, y, 'FaceAlpha', .4);
xlabel('Position');
ylabel('Firing rate');
xticks([centerMass, peakLoc]);
xticklabels({"Center of Mass", "Peak location"})
yticks([maxY]);
yticklabels({"Max FR"});

% Firing rate
line([0 peakLoc], [maxY maxY], 'Color', "#D95319", "LineWidth", 1.5);
% Peak Location
line([peakLoc peakLoc], [0 maxY], 'Color', 	"#7E2F8E", "LineWidth", 1.5);
% Center of mass
line([floor(centerMass) floor(centerMass)], [0 centerMassFR], 'Color', "#EDB120", "LineWidth", 1.5);


%% a. Population change

% 1. PV - Correlation with the final place field



% 2. PV- Correlation between one direction and the other (directionality)

%% b. Cell change --------------------------------------------------------

dataLap = load("timeSeries.mat");
dataLap = dataLap.data;
summaryLapData = groupsummary(dataLap, ["condition", "exposure", "lap"], ["median", "std"], ["CMdiff", "FRdiff", "PeakDiff"]);

% 1. Center of mass
f5 = figure; 
f5.Position = [0,0,964,542];
timeSeriesOverLap(summaryLapData, "median_CMdiff", "Center of Mass");

% 2. Peak Location

f6 = figure; 
f6.Position = [0, 0, 964, 542];
timeSeriesOverLap(summaryLapData, "median_FRdiff", "Max Firing Rate");

% 3. Max firing rate

f7 = figure; 
f7.Position = [0, 0, 964, 542];
timeSeriesOverLap(summaryLapData, "median_PeakDiff", "Peak Location");


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

