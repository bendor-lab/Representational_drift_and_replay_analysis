% Look at context selectivity tuning

clear

% Load the data

phase_data_sig = load("../phase_data_SIG.mat");
phase_data_sig = phase_data_sig.phase_data;

phase_data_nsig = load("../phase_data_NSIG_split.mat");
phase_data_nsig = phase_data_nsig.phase_data;

load("../phase_data.mat");

% For now, as a filter for 1-spike cells, we remove all cells with 1 phase
% lock
% 
phase_data(phase_data.phaseLocking > 0.95, :) = [];
phase_data_sig(phase_data_sig.phaseLocking > 0.95, :) = [];
phase_data_nsig(phase_data_nsig.phaseLocking > 0.95, :) = [];

%% 1. Visual analysis of the tuning of common good cells dependent on replay

allSessionID = unique(phase_data_sig.sessionID);
allDifferencesPhase = [];
allDifferencesLocking = [];
allDifferencesSig = [];

for sID = 1:numel(allSessionID)
    currentData = phase_data_sig(phase_data_sig.sessionID == allSessionID(sID), :);
    dataT1 = currentData(currentData.condition == 16, :);
    dataT2 = currentData(currentData.condition ~= 16, :);
    commonCells = intersect(dataT1.cell, dataT2.cell);

    for cID = 1:numel(commonCells)
        mean_phaseT1 = dataT1.meanPhase(dataT1.cell == commonCells(cID));
        mean_phaseT2 = dataT2.meanPhase(dataT2.cell == commonCells(cID));
        mean_phaseDiff = mean_phaseT1 - mean_phaseT2;

        if mean_phaseDiff > pi
            mean_phaseDiff = mean_phaseDiff - 2*pi;
        elseif mean_phaseDiff < -pi
            mean_phaseDiff = mean_phaseDiff + 2*pi;
        end

        allDifferencesPhase = [allDifferencesPhase; mean_phaseDiff];

        mean_lockingT1 = dataT1.phaseLocking(dataT1.cell == commonCells(cID));
        mean_lockingT2 = dataT2.phaseLocking(dataT2.cell == commonCells(cID));
        mean_lockingDiff = mean_lockingT1 - mean_lockingT2;
        allDifferencesLocking = [allDifferencesLocking; mean_lockingDiff];

        mean_sigT1 = dataT1.significance(dataT1.cell == commonCells(cID));
        mean_sigT2 = dataT2.significance(dataT2.cell == commonCells(cID));
        allDifferencesSig = [allDifferencesSig; mean_sigT1 mean_sigT2];

    end
end

% For a control, we take the non-replay events locking

allDifferencesPhaseNRep = [];
allDifferencesLockingNRep = [];
allDifferencesSigNRep = [];

for sID = 1:numel(allSessionID)
    currentData = phase_data_nsig(phase_data_nsig.sessionID == allSessionID(sID), :);
    dataT1 = currentData(currentData.condition == 16, :);
    dataT2 = currentData(currentData.condition ~= 16, :);
    commonCells = intersect(dataT1.cell, dataT2.cell);

    for cID = 1:numel(commonCells)
        mean_phaseT1 = dataT1.meanPhase(dataT1.cell == commonCells(cID));
        mean_phaseT2 = dataT2.meanPhase(dataT2.cell == commonCells(cID));
        mean_phaseDiff = mean_phaseT1 - mean_phaseT2;

        if mean_phaseDiff > pi
            mean_phaseDiff = mean_phaseDiff - 2*pi;
        elseif mean_phaseDiff < -pi
            mean_phaseDiff = mean_phaseDiff + 2*pi;
        end

        allDifferencesPhaseNRep = [allDifferencesPhaseNRep; mean_phaseDiff];

        mean_lockingT1 = dataT1.phaseLocking(dataT1.cell == commonCells(cID));
        mean_lockingT2 = dataT2.phaseLocking(dataT2.cell == commonCells(cID));
        mean_lockingDiff = mean_lockingT1 - mean_lockingT2;
        allDifferencesLockingNRep = [allDifferencesLockingNRep; mean_lockingDiff];

        mean_sigT1 = dataT1.significance(dataT1.cell == commonCells(cID));
        mean_sigT2 = dataT2.significance(dataT2.cell == commonCells(cID));
        allDifferencesSigNRep = [allDifferencesSigNRep; mean_sigT1 mean_sigT2];

    end
end

figure;
t = tiledlayout(3, 2);

nexttile([1 2]);

histogram(allDifferencesPhase);
hold on;
histogram(allDifferencesPhaseNRep);
hold off;

L = legend({"Replay", "Non-replay"});
L.Location = "eastoutside";
L.Orientation = "vertical";

xlabel("Phase difference");
ylabel("Count")

nexttile([1 2]);
h1 = histogram(allDifferencesLocking);
hold on;
h2 = histogram(allDifferencesLockingNRep);
hold off;

L = legend({"Replay", "Non-replay"});
L.Location = "eastoutside";
L.Orientation = "vertical";

xlabel("Phase locking difference");
ylabel("Count")

nexttile;
p1 = plotQuadrant(allDifferencesSig(:, 1), allDifferencesSig(:, 2));
p1.MarkerFaceColor = [0.8500 0.3250 0.0980];
xlabel("Phase Locking T1");
ylabel("Phase Locking T2");

nexttile;
p2 = plotQuadrant(allDifferencesSigNRep(:, 1), allDifferencesSigNRep(:, 2));
p2.MarkerFaceColor = [0 0.4470 0.7410];
xlabel("Phase Locking T1");
ylabel("Phase Locking T2");

L = legend([p2, p1], {"Replay", "Non-replay"});
L.Location = "eastoutside";
L.Orientation = "vertical";
