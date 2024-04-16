clear

% Load the data

phase_data_sig = load("../phase_data_SIG.mat");
phase_data_sig = phase_data_sig.phase_data;

phase_data_nsig = load("../phase_data_NSIG.mat");
phase_data_nsig = phase_data_nsig.phase_data;

load("../phase_data.mat");

% For now, as a filter for 1-spike cells, we remove all cells with 1 phase
% lock

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

uniqueAnimals = 

