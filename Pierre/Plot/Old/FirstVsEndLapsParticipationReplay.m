clear

PATH.SCRIPT = fileparts(mfilename('fullpath'));

load(PATH.SCRIPT + "\..\Data\actMat1stLast_T1.mat");
load(PATH.SCRIPT + "\..\Data\actMat1stLast_T2.mat");

% Choose if you want to work with track 1 or track 2
actMat1stLast = actMat1stLast;

%% Look at all the correlations in the file naively
T = struct2table(actMat1stLast);
% We remove the non-double columns
% T.animal = [];
% T.condition = [];
% T.day = [];
% T.cell = [];

% corrplot(T);

%%

conditionOI = "16";

% We filter the data by only taking good place cells in the first AND in
% the last lap

actMat1stLastGoodRUN1 = actMat1stLast([actMat1stLast(:).IsGoodPC_RUN1Lap1] & [actMat1stLast(:).IsGoodPC_RUN1LapEnd] & contains({actMat1stLast(:).condition}, conditionOI));
actMat1stLastGoodRUN2 = actMat1stLast([actMat1stLast(:).IsGoodPC_RUN2Lap1] & [actMat1stLast(:).IsGoodPC_RUN2LapEnd] & contains({actMat1stLast(:).condition}, conditionOI));


% We compute the difference between peak FR and topology of PF betweem
% T1L1, T1LEnd and T2L1, T2LEnd

diff_FR_RUN1 = abs([actMat1stLastGoodRUN1(:).PF_MaxFRateRUN1LapEnd] - [actMat1stLastGoodRUN1(:).PF_MaxFRateRUN1Lap1]);
diff_Topo_RUN1 = abs([actMat1stLastGoodRUN1(:).PF_PositionRUN1LapEnd] - [actMat1stLastGoodRUN1(:).PF_PositionRUN1Lap1]);
diff_FR_RUN2 = abs([actMat1stLastGoodRUN2(:).PF_MaxFRateRUN2LapEnd] - [actMat1stLastGoodRUN2(:).PF_MaxFRateRUN2Lap1]);
diff_Topo_RUN2 = abs([actMat1stLastGoodRUN2(:).PF_PositionRUN2LapEnd] - [actMat1stLastGoodRUN2(:).PF_PositionRUN2Lap1]);

figure;
scatter(diff_FR_RUN1, diff_Topo_RUN1)
scatter(diff_FR_RUN2, diff_Topo_RUN2) % CONTROL : no correlation between the two.

%% We look at the involvment in awake replay in function of remapping

invAwakeRepRUN1 = [actMat1stLastGoodRUN1(:).part_ReplayRUN1];
invAwakeRepRUN2 = [actMat1stLastGoodRUN2(:).part_ReplayRUN2];

figure;
tiledlayout(2, 2)

ax1 = nexttile;
scatter(diff_FR_RUN1, invAwakeRepRUN1) % .15
xlabel("Firing Rate Drift")
ylabel("Awake Replay Participation")
title("RUN1")

ax2 = nexttile;
scatter(diff_Topo_RUN1, invAwakeRepRUN1)
xlabel("Peak location Drift")
ylabel("Awake Replay Participation")
title("RUN1")

ax3 = nexttile;
scatter(diff_FR_RUN2, invAwakeRepRUN2)
xlabel("Firing Rate Drift")
ylabel("Awake Replay Participation")
title("RUN2")

ax4 = nexttile;
scatter(diff_Topo_RUN2, invAwakeRepRUN2)
xlabel("Peak location Drift")
ylabel("Awake Replay Participation")
title("RUN2")

linkaxes([ax1 ax2 ax3 ax4],'xy')

%% We look at the involvment in SLEEP replay in function of remapping

invSleepRepPOST1 = [actMat1stLastGoodRUN1(:).part_ReplayPOST1];
invSleepRepPOST2 = [actMat1stLastGoodRUN2(:).part_ReplayPOST2];

figure;
tiledlayout(2, 2)

ax1 = nexttile;
scatter(diff_FR_RUN1, invSleepRepPOST1)
xlabel("Firing Rate Drift")
ylabel("POST1 Replay Participation")
title("T1")

ax2 = nexttile;
scatter(diff_Topo_RUN1, invSleepRepPOST1)
xlabel("Peak location Drift")
ylabel("POST1 Replay Participation")
title("T1")

ax3 = nexttile;
scatter(diff_FR_RUN2, invSleepRepPOST2)
xlabel("Firing Rate Drift")
ylabel("POST2 Replay Participation")
title("T2")

ax4 = nexttile;
scatter(diff_Topo_RUN2, invSleepRepPOST2)
xlabel("Peak location Drift")
ylabel("POST2 Replay Participation")
title("T2")

linkaxes([ax1 ax2 ax3 ax4],'xy')

% Nothing for 16x8

%% Effect of the previous replay on remapping

% Get the good data : only cells that have a good PF in last RUN1 - first
% RUN2

goodCellsEndRUN1FirstRUN2 = actMat1stLast([actMat1stLast(:).IsGoodPC_RUN1LapEnd] & [actMat1stLast(:).IsGoodPC_RUN2Lap1] ...
                                           & contains({actMat1stLast(:).condition}, conditionOI));

% Get the vector of remapping between last lap RUN1 and first lap RUN2
deltaFRRUN1RUN2 = abs([goodCellsEndRUN1FirstRUN2(:).PF_MaxFRateRUN1LapEnd] - [goodCellsEndRUN1FirstRUN2(:).PF_MaxFRateRUN2Lap1]);
deltaTopoRUN1RUN2 = abs([goodCellsEndRUN1FirstRUN2(:).PF_PositionRUN1LapEnd] - [goodCellsEndRUN1FirstRUN2(:).PF_PositionRUN2Lap1]);

% Get the participation of those cells in the replay
partReplayPOST1GoodRUN1RUN2 = [goodCellsEndRUN1FirstRUN2(:).part_ReplayPOST1];

figure;
tiledlayout(2, 1)

ax1 = nexttile;
scatter(deltaFRRUN1RUN2, partReplayPOST1GoodRUN1RUN2)
xlabel("Firing Rate Drift EndRUN1 <-> FirstRUN2")
ylabel("POST1 Replay Participation")

ax2 = nexttile;
scatter(deltaTopoRUN1RUN2, partReplayPOST1GoodRUN1RUN2)
xlabel("Peak location Drift EndRUN1 <-> FirstRUN2")
ylabel("POST1 Replay Participation")

%% Correlation between awake replay RUN1 and remapping

partReplayRUN1GoodRUN1RUN2 = [goodCellsEndRUN1FirstRUN2(:).part_ReplayRUN1];

figure;
tiledlayout(2, 1)

ax1 = nexttile;
scatter(deltaFRRUN1RUN2, partReplayRUN1GoodRUN1RUN2)
xlabel("Firing Rate Drift EndRUN1 <-> FirstRUN2")
ylabel("RUN1 Replay Participation")

ax2 = nexttile;
scatter(deltaTopoRUN1RUN2, partReplayRUN1GoodRUN1RUN2)
xlabel("Peak location Drift EndRUN1 <-> FirstRUN2")
ylabel("RUN1 Replay Participation")

%% Identifying no_change neurons, increase and decrease neurons

% RUN1
changeInvolvmentLap1EndRUN1 = [actMat1stLastGoodRUN1(:).PF_MaxFRateRUN1LapEnd] - [actMat1stLastGoodRUN1(:).PF_MaxFRateRUN1Lap1];
changeInvolvmentLap1EndRUN1Percent = changeInvolvmentLap1EndRUN1./[actMat1stLastGoodRUN1(:).PF_MaxFRateRUN1LapEnd];
changeInvolvmentLap1EndRUN1Percent = changeInvolvmentLap1EndRUN1Percent * 100; % Convert to %

toleranceNoChange = 10; % Changes of less than 10% = no changes

noChangeNeuronsRUN1 = actMat1stLastGoodRUN1(abs(changeInvolvmentLap1EndRUN1Percent) <= toleranceNoChange);
increaseNeuronsRUN1 = actMat1stLastGoodRUN1(changeInvolvmentLap1EndRUN1Percent > toleranceNoChange);
decreaseNeuronsRUN1 = actMat1stLastGoodRUN1(changeInvolvmentLap1EndRUN1Percent < -toleranceNoChange);

% We look at the repartition of remapping after this classification
figure;
meanFirstRUN1 = [mean([increaseNeuronsRUN1.PF_MaxFRateRUN1Lap1]), ...
                 mean([decreaseNeuronsRUN1.PF_MaxFRateRUN1Lap1]), ...
                 mean([noChangeNeuronsRUN1.PF_MaxFRateRUN1Lap1])];
             
meanLastRUN1 = [mean([increaseNeuronsRUN1.PF_MaxFRateRUN1LapEnd]), ...
                 mean([decreaseNeuronsRUN1.PF_MaxFRateRUN1LapEnd]), ...
                 mean([noChangeNeuronsRUN1.PF_MaxFRateRUN1LapEnd])];
             
stdFirstRUN1 = [std([increaseNeuronsRUN1.PF_MaxFRateRUN1Lap1]), ...
                 std([decreaseNeuronsRUN1.PF_MaxFRateRUN1Lap1]), ...
                 std([noChangeNeuronsRUN1.PF_MaxFRateRUN1Lap1])];
             
stdLastRUN1 = [std([increaseNeuronsRUN1.PF_MaxFRateRUN1LapEnd]), ...
                 std([decreaseNeuronsRUN1.PF_MaxFRateRUN1LapEnd]), ...
                 std([noChangeNeuronsRUN1.PF_MaxFRateRUN1LapEnd])];
             
groups = 1:3;
errorbar(groups - 0.1, meanFirstRUN1, stdFirstRUN1, 'b', 'LineStyle', 'none', 'Marker', 's');
hold on;
errorbar(groups + 0.1, meanLastRUN1, stdLastRUN1, 'r', 'LineStyle', 'none', 'Marker', 'o');

xticks(groups);
xticklabels(["Increasing", "Decreasing", "No Changes"]);
ylabel("Number of spikes during the lap");
legend("LAP1", "Final lap");

figure;
scatter([increaseNeuronsRUN1.part_ReplayRUN1], [increaseNeuronsRUN1.part_ReplayRUN2], 'r');
hold on;
r = corrcoef([increaseNeuronsRUN1.part_ReplayRUN1], [increaseNeuronsRUN1.part_ReplayRUN2]);
plot([increaseNeuronsRUN1.part_ReplayRUN1], [increaseNeuronsRUN1.part_ReplayRUN1]*r(2, 1), 'r');

scatter([decreaseNeuronsRUN1.part_ReplayRUN1], [decreaseNeuronsRUN1.part_ReplayRUN2], 'b');
r = corrcoef([decreaseNeuronsRUN1.part_ReplayRUN1], [decreaseNeuronsRUN1.part_ReplayRUN2]);
plot([decreaseNeuronsRUN1.part_ReplayRUN1], [decreaseNeuronsRUN1.part_ReplayRUN1]*r(2, 1), 'b');

scatter([noChangeNeuronsRUN1.part_ReplayRUN1], [noChangeNeuronsRUN1.part_ReplayRUN2], 'g');
r = corrcoef([noChangeNeuronsRUN1.part_ReplayRUN1], [noChangeNeuronsRUN1.part_ReplayRUN2]);
plot([noChangeNeuronsRUN1.part_ReplayRUN1], [noChangeNeuronsRUN1.part_ReplayRUN1]*r(2, 1), 'g');

legend("Increasing neurons", "Fitting + neurons", "Decreasing neurons", "Fitting - neurons", "No-change neurons", ...
       "Fitting = neurons");

% Same correlation for all groups (good correlation, around .4)

%% Effect of the previous replay on remapping - for 3 groups

% Get the good data : only cells that have a good PF in last RUN1 - first
% RUN2

goodCellsEndRUN1FirstRUN2Incr = increaseNeuronsRUN1([increaseNeuronsRUN1(:).IsGoodPC_RUN1LapEnd] & [increaseNeuronsRUN1(:).IsGoodPC_RUN2Lap1]);
goodCellsEndRUN1FirstRUN2Decr = decreaseNeuronsRUN1([decreaseNeuronsRUN1(:).IsGoodPC_RUN1LapEnd] & [decreaseNeuronsRUN1(:).IsGoodPC_RUN2Lap1]);
goodCellsEndRUN1FirstRUN2NoCh = noChangeNeuronsRUN1([noChangeNeuronsRUN1(:).IsGoodPC_RUN1LapEnd] & [noChangeNeuronsRUN1(:).IsGoodPC_RUN2Lap1]);

figure;
counter = 0;
% Get the vector of remapping between last lap RUN1 and first lap RUN2
for datax = {goodCellsEndRUN1FirstRUN2Incr, goodCellsEndRUN1FirstRUN2Decr, goodCellsEndRUN1FirstRUN2NoCh}
    data = datax{1};
    deltaFRRUN1RUN2 = abs([data(:).PF_MaxFRateRUN1LapEnd] - [data(:).PF_MaxFRateRUN2Lap1]);
    deltaTopoRUN1RUN2 = abs([data(:).PF_PositionRUN1LapEnd] - [data(:).PF_PositionRUN2Lap1]);
    
    % Get the participation of those cells in the replay
    partReplayPOST1GoodRUN1RUN2 = [data(:).part_ReplayPOST1];
    
    subplot(3, 2, counter + 1)
    scatter(deltaFRRUN1RUN2, partReplayPOST1GoodRUN1RUN2)
    
    
    subplot(3, 2, counter + 2)
    scatter(deltaTopoRUN1RUN2, partReplayPOST1GoodRUN1RUN2)
    
    counter = counter + 2;

end

% CONTROL : NO DIFFERENCES BETWEEN THE 3 GROUPS in term of consequences of
% remote replay on remapping

%% Does the increase neurons were replayed more during POST1 ?
% In term of proportion


figure;
meanReplayPOST1 = [mean([increaseNeuronsRUN1.part_ReplayPOST1]), ...
                 mean([decreaseNeuronsRUN1.part_ReplayPOST1]), ...
                 mean([noChangeNeuronsRUN1.part_ReplayPOST1])];
             
stdReplayPOST1 = [std([increaseNeuronsRUN1.part_ReplayPOST1]), ...
                 std([decreaseNeuronsRUN1.part_ReplayPOST1]), ...
                 std([noChangeNeuronsRUN1.part_ReplayPOST1])];
             
meanReplayRUN1 = [mean([increaseNeuronsRUN1.part_ReplayRUN1]), ...
                 mean([decreaseNeuronsRUN1.part_ReplayRUN1]), ...
                 mean([noChangeNeuronsRUN1.part_ReplayRUN1])];
             
stdReplayRUN1 = [std([increaseNeuronsRUN1.part_ReplayRUN1]), ...
                 std([decreaseNeuronsRUN1.part_ReplayRUN1]), ...
                 std([noChangeNeuronsRUN1.part_ReplayRUN1])];             
             
groups = 1:3;
errorbar(groups - 0.1, meanReplayPOST1, stdReplayPOST1, 'b', 'LineStyle', 'none', 'Marker', 's');
hold on;
errorbar(groups + 0.1, meanReplayRUN1, stdReplayRUN1, 'r', 'LineStyle', 'none', 'Marker', 'o');

xticks(groups);
xticklabels(["Increasing", "Decreasing", "No Changes"]);
ylabel("Number of replay events");
legend("Sleep Replay POST1", "Awake replay RUN1");

% No differences, Increasing / Decr / No changes were not significantly
% more replayed during awakeness or sleep

%% Plot the correlation between replay / RUN2 participation

figure;
tiledlayout(2, 1)

ax1 = nexttile;
scatter([actMat1stLastGoodRUN2.part_ReplayPOST1], [actMat1stLastGoodRUN2.part_RUN2Lap1]) 
disp(corrcoef([actMat1stLastGoodRUN2.part_ReplayPOST1], [actMat1stLastGoodRUN2.part_RUN2Lap1]));
% Small corr for T1 all conditions
% Corr fot T2 depends on the condition (2l, 3l, 4l)


ax2 = nexttile;
scatter([actMat1stLastGoodRUN2.part_ReplayPOST1], [actMat1stLastGoodRUN2.part_RUN2LapEnd])
disp(corrcoef([actMat1stLastGoodRUN2.part_ReplayPOST1], [actMat1stLastGoodRUN2.part_RUN2LapEnd]));
% No correlation T1 / T2

%% Split the neurons in increase neurons RUN1 - RUN2 decrease neurons and no change

goodNeurons = actMat1stLast(logical([actMat1stLast.IsGoodPC_RUN1LapEnd]));

changeInvolvmentEndRUN1RUN2 = [goodNeurons(:).PF_MaxFRateRUN2LapEnd] - [goodNeurons(:).PF_MaxFRateRUN1LapEnd];
changeInvolvmentEndRUN1RUNPercent = changeInvolvmentEndRUN1RUN2./[goodNeurons(:).PF_MaxFRateRUN2LapEnd];
changeInvolvmentEndRUN1RUNPercent = changeInvolvmentEndRUN1RUNPercent * 100; % Convert to %

toleranceNoChange = 10; % Changes of less than 10% = no changes

noChangeNeuronsRUN1RUN2 = goodNeurons(abs(changeInvolvmentEndRUN1RUN2) <= toleranceNoChange);
increaseNeuronsRUN1RUN2 = goodNeurons(changeInvolvmentEndRUN1RUNPercent > toleranceNoChange);
decreaseNeuronsRUN1RUN2 = goodNeurons(changeInvolvmentEndRUN1RUNPercent < -toleranceNoChange);

figure;
meanReplayPOST1 = [mean([increaseNeuronsRUN1RUN2.part_ReplayPOST1]), ...
                 mean([decreaseNeuronsRUN1RUN2.part_ReplayPOST1]), ...
                 mean([noChangeNeuronsRUN1RUN2.part_ReplayPOST1])];
             
stdReplayPOST1 = [std([increaseNeuronsRUN1RUN2.part_ReplayPOST1]), ...
                 std([decreaseNeuronsRUN1RUN2.part_ReplayPOST1]), ...
                 std([noChangeNeuronsRUN1RUN2.part_ReplayPOST1])];
             
meanReplayRUN1 = [mean([increaseNeuronsRUN1RUN2.part_ReplayRUN1]), ...
                 mean([decreaseNeuronsRUN1RUN2.part_ReplayRUN1]), ...
                 mean([noChangeNeuronsRUN1RUN2.part_ReplayRUN1])];
             
stdReplayRUN1 = [std([increaseNeuronsRUN1RUN2.part_ReplayRUN1]), ...
                 std([decreaseNeuronsRUN1RUN2.part_ReplayRUN1]), ...
                 std([noChangeNeuronsRUN1RUN2.part_ReplayRUN1])];             
             
groups = 1:3;
errorbar(groups - 0.1, meanReplayPOST1, stdReplayPOST1, 'b', 'LineStyle', 'none', 'Marker', 's');
hold on;
errorbar(groups + 0.1, meanReplayRUN1, stdReplayRUN1, 'r', 'LineStyle', 'none', 'Marker', 'o');

xticks(groups);
xticklabels(["Increasing R1-R2", "Decreasing R1-R2", "No Changes R1-R2"]);
ylabel("Number of replay events");
legend("Sleep Replay POST1", "Awake replay RUN1");

% CONTROL : No differences

figure;
meanReplayPOST1 = [mean([increaseNeuronsRUN1RUN2.part_ReplayPOST2]), ...
                 mean([decreaseNeuronsRUN1RUN2.part_ReplayPOST2]), ...
                 mean([noChangeNeuronsRUN1RUN2.part_ReplayPOST2])];
             
stdReplayPOST1 = [std([increaseNeuronsRUN1RUN2.part_ReplayPOST2]), ...
                 std([decreaseNeuronsRUN1RUN2.part_ReplayPOST2]), ...
                 std([noChangeNeuronsRUN1RUN2.part_ReplayPOST2])];
             
meanReplayRUN1 = [mean([increaseNeuronsRUN1RUN2.part_ReplayRUN2]), ...
                 mean([decreaseNeuronsRUN1RUN2.part_ReplayRUN2]), ...
                 mean([noChangeNeuronsRUN1RUN2.part_ReplayRUN2])];
             
stdReplayRUN1 = [std([increaseNeuronsRUN1RUN2.part_ReplayRUN2]), ...
                 std([decreaseNeuronsRUN1RUN2.part_ReplayRUN2]), ...
                 std([noChangeNeuronsRUN1RUN2.part_ReplayRUN2])];             
             
groups = 1:3;
errorbar(groups - 0.1, meanReplayPOST1, stdReplayPOST1, 'b', 'LineStyle', 'none', 'Marker', 's');
hold on;
errorbar(groups + 0.1, meanReplayRUN1, stdReplayRUN1, 'r', 'LineStyle', 'none', 'Marker', 'o');

xticks(groups);
xticklabels(["Increasing R1-R2", "Decreasing R1-R2", "No Changes R1-R2"]);
ylabel("Number of replay events");
legend("Sleep Replay POST2", "Awake replay RUN2");

% CONTROL : No differences

