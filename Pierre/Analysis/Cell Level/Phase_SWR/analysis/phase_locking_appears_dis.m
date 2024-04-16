clear

% Load the data

phase_data_sig = load("../phase_data_SIG.mat");
phase_data_sig = phase_data_sig.phase_data;

phase_data_nsig = load("../phase_data_NSIG.mat");
phase_data_nsig = phase_data_nsig.phase_data;

load("../phase_data.mat");

% For now, as a filter for 1-spike cells, we remove all cells with 1 phase
% lock
% 
phase_data(phase_data.phaseLocking > 0.95, :) = [];
phase_data_sig(phase_data_sig.phaseLocking > 0.95, :) = [];
phase_data_nsig(phase_data_nsig.phaseLocking > 0.95, :) = [];

%% 1. Visual inspection between sig / nsig / all

sumDataSig = groupsummary(phase_data_sig, ["label"], "mean", ["phaseLocking", "significance"]);
sumDataNsig = groupsummary(phase_data_nsig, ["label"], "mean", ["phaseLocking", "significance"]);
sumDataAll = groupsummary(phase_data, ["label"], "mean", ["phaseLocking", "significance"]);

figure;
tiledlayout(3, 2);

n1 = nexttile;
bar(1:3, sumDataSig.mean_phaseLocking)
yl = ylabel("Sig. SWR", 'FontWeight','bold');
yl.Rotation = 0;
xticklabels(sumDataSig.label)
title("Phase locking")

n4 = nexttile;
bar(1:3, sumDataSig.mean_significance)
xticklabels(sumDataSig.label)
title("% of sig. tuned cells")

n2 = nexttile;
bar(1:3, sumDataNsig.mean_phaseLocking)
yl = ylabel("Non Sig. SWR", 'FontWeight','bold');
yl.Rotation = 0;
xticklabels(sumDataNsig.label)


n5 = nexttile;
bar(1:3, sumDataNsig.mean_significance)
xticklabels(sumDataNsig.label)


n3 = nexttile;
bar(1:3, sumDataAll.mean_phaseLocking)
yl = ylabel("All SWR", 'FontWeight','bold');
yl.Rotation = 0;
xticklabels(sumDataAll.label)

n6 = nexttile;
bar(1:3, sumDataAll.mean_significance)
xticklabels(sumDataAll.label)

linkaxes([n1, n2, n3])
linkaxes([n4 n5 n6])

%% For appearing / stable vs. disappearing stable vs. stable / stable

stableT1AppT2 = [];
stableT1DisT2 = [];
stableT1StableT2 = [];
AppT1StableT2 = [];
DisT1StableT2 = [];

uniqueSessions = unique(phase_data_sig.sessionID);

for sID = 1:numel(uniqueSessions)
    matchingDataT1 = phase_data_sig(phase_data_sig.sessionID == uniqueSessions(sID) & phase_data_sig.condition == 16, :);
    matchingDataT2 = phase_data_sig(phase_data_sig.sessionID == uniqueSessions(sID) & phase_data_sig.condition ~= 16, :);

    commonCells = intersect(matchingDataT1.cell, matchingDataT2.cell);

    for cID = 1:numel(commonCells)
        currentCell = commonCells(cID);

        labelT1 = matchingDataT1.label(matchingDataT1.cell == currentCell);
        labelT2 = matchingDataT2.label(matchingDataT2.cell == currentCell);

        currentTuningT1 = matchingDataT1.phaseLocking(matchingDataT1.cell == currentCell);
        currentTuningT2 = matchingDataT2.phaseLocking(matchingDataT2.cell == currentCell);

        currentSigT1 = matchingDataT1.significance(matchingDataT1.cell == currentCell);
        currentSigT2 = matchingDataT2.significance(matchingDataT2.cell == currentCell);

        if labelT1 == "Stable" && labelT2 == "Appears"
            stableT1AppT2 = [stableT1AppT2; currentTuningT1 currentTuningT2 currentSigT1 currentSigT2];
        elseif labelT1 == "Stable" && labelT2 == "Stable"
            stableT1StableT2 = [stableT1StableT2; currentTuningT1 currentTuningT2 currentSigT1 currentSigT2];
        elseif labelT1 == "Stable" && labelT2 == "Disappear"
            stableT1DisT2 = [stableT1DisT2; currentTuningT1 currentTuningT2 currentSigT1 currentSigT2];
        elseif labelT1 == "Appears" && labelT2 == "Stable"
            AppT1StableT2 = [AppT1StableT2; currentTuningT1 currentTuningT2 currentSigT1 currentSigT2];
        elseif labelT1 == "Disappear" && labelT2 == "Stable"
            DisT1StableT2 = [DisT1StableT2; currentTuningT1 currentTuningT2 currentSigT1 currentSigT2];
        end

    end

end

% Generate the plot

figure;
tiledlayout(2, 3);
n1 = nexttile;
scatter(stableT1AppT2(:, 1), stableT1AppT2(:, 2), 20, "filled")
xlabel("Phase Locking T1");
ylabel("Phase Locking T2");
hold on;
plot(0:0.1:1, 0:0.1:1, "--r", "LineWidth", 1.5)
title("Stable T1 - Appears T2 (bias = " + mean(stableT1AppT2(:, 1) < stableT1AppT2(:, 2)) + ")")

n2 = nexttile;
scatter(stableT1DisT2(:, 1), stableT1DisT2(:, 2), 20, "filled")
xlabel("Phase Locking T1");
ylabel("Phase Locking T2");
hold on;
plot(0:0.1:1, 0:0.1:1, "--r", "LineWidth", 1.5)
title("Stable T1 - Disappear T2 (bias = " + mean(stableT1DisT2(:, 1) < stableT1DisT2(:, 2)) + ")")

n3 = nexttile;
scatter(stableT1StableT2(:, 1), stableT1StableT2(:, 2), 20, "filled")
xlabel("Phase Locking T1");
ylabel("Phase Locking T2");
hold on;
plot(0:0.1:1, 0:0.1:1, "--r", "LineWidth", 1.5)
title("Stable T1 - Stable T2 (bias = " + mean(stableT1StableT2(:, 1) < stableT1StableT2(:, 2)) + ")")

n4 = nexttile;
scatter(AppT1StableT2(:, 1), AppT1StableT2(:, 2), 20, "filled")
xlabel("Phase Locking T1");
ylabel("Phase Locking T2");
hold on;
plot(0:0.1:1, 0:0.1:1, "--r", "LineWidth", 1.5)
title("Appear T1 - Stable T2 (bias = " + mean(AppT1StableT2(:, 1) < AppT1StableT2(:, 2)) + ")")

n5 = nexttile;
scatter(DisT1StableT2(:, 1), DisT1StableT2(:, 2), 20, "filled")
xlabel("Phase Locking T1");
ylabel("Phase Locking T2");
hold on;
plot(0:0.1:1, 0:0.1:1, "--r", "LineWidth", 1.5)
title("Disappear T1 - Stable T2 (bias = " + mean(DisT1StableT2(:, 1) < DisT1StableT2(:, 2)) + ")")

% Same plot for the significance in a 2x2 heatmap

figure;
tiledlayout(2, 3);

bias = @(x, y) sum(x == 1 & y ~= 1)/(sum(x == 1 & y ~= 1) + sum(x ~= 1 & y == 1));

n1 = nexttile;
plotQuadrant(stableT1AppT2(:, 3), stableT1AppT2(:, 4))
xlabel("Phase Locking T1");
ylabel("Phase Locking T2");
title("Stable T1 - Appears T2 (bias = " + bias(stableT1AppT2(:, 4), stableT1AppT2(:, 3)) + ")")

n2 = nexttile;
plotQuadrant(stableT1DisT2(:, 3), stableT1DisT2(:, 4))
xlabel("Phase Locking T1");
ylabel("Phase Locking T2");
title("Stable T1 - Disappear T2 (bias = " + bias(stableT1DisT2(:, 4), stableT1DisT2(:, 3)) + ")")

n3 = nexttile;
plotQuadrant(stableT1StableT2(:, 3), stableT1StableT2(:, 4))
xlabel("Phase Locking T1");
ylabel("Phase Locking T2");
title("Stable T1 - Stable T2 (bias = " + bias(stableT1StableT2(:, 4), stableT1StableT2(:, 3)) + ")")

n4 = nexttile;
plotQuadrant(AppT1StableT2(:, 3), AppT1StableT2(:, 4))
xlabel("Phase Locking T1");
ylabel("Phase Locking T2");
title("Appear T1 - Stable T2 (bias = " + bias(AppT1StableT2(:, 4), AppT1StableT2(:, 3)) + ")")

n5 = nexttile;
plotQuadrant(DisT1StableT2(:, 3), DisT1StableT2(:, 4))
xlabel("Phase Locking T1");
ylabel("Phase Locking T2");
title("Disappear T1 - Stable T2 (bias = " + bias(DisT1StableT2(:, 4), DisT1StableT2(:, 3)) + ")")
