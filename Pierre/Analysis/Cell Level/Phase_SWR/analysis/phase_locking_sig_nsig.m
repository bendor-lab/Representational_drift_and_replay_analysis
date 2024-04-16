% Difference in phase-locking between replay and non-replay SWR

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

%% 1. Visual inspection between replay and non replay SWR

figure;
t = tiledlayout(3, 1);

nexttile;
histogram(phase_data_sig.meanPhase, 0:pi/4:2*pi + (pi/4));
hold on;
histogram(phase_data_nsig.meanPhase, 0:pi/4:2*pi + (pi/4));
hold off;

L = legend({"Replay", "Non-replay"});
L.Location = "eastoutside";
L.Orientation = "vertical";

xlabel("Mean phase");
xticks([0, pi, 2*pi]);
xticklabels(["0", "\pi", "2\pi"])
xlim([-0.5, 2*pi + 0.5])
ylabel("Count")

nexttile;

histogram(phase_data_sig.phaseLocking);
hold on;
histogram(phase_data_nsig.phaseLocking);
hold off;

L = legend({"Replay", "Non-replay"});
L.Location = "eastoutside";
L.Orientation = "vertical";

xlabel("Mean vector strength");
xlim([-0.1, 1.1])
ylabel("Count")

nexttile;

bar([1 2], [mean(phase_data_sig.significance) mean(phase_data_nsig.significance)])
ylabel("Proportion of sig. tuned cells");
xticklabels(["Replay", "Non-replay"])
ylim([0 0.35])