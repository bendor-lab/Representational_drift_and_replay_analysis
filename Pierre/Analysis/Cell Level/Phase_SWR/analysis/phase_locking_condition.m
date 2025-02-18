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

allAnimals = unique(phase_data_sig.animal);

%% 1. Visual inspection of the number of sig. tuned cells and the phase locking

phase_data_sig.conditionBin = phase_data_sig.condition - ...
                              (phase_data_sig.condition == 8)*3 - ...
                              (phase_data_sig.condition == 16)*10;

figure;
t = tiledlayout(1, 2)

nexttile;
boxchart(phase_data_sig.conditionBin, phase_data_sig.phaseLocking)
xticks([1 2 3 4 5 6])
xticklabels([1 2 3 4 8 16])
xlabel("Number of laps")
ylabel("Phase locking")
grid on;

sumDataSig = groupsummary(phase_data_sig, ["animal", "conditionBin"], "mean", ["phaseLocking", "significance"]);

nexttile;
for aID = 1:numel(allAnimals)
    current_animal = allAnimals(aID); 
    all_conditions = sumDataSig(sumDataSig.animal == current_animal, :).conditionBin;
    all_meanSig = sumDataSig(sumDataSig.animal == current_animal, :).mean_significance;
    missing_cond = find(diff(all_conditions) ~= 1);
    if ~isempty(missing_cond)
        all_meanSig = [all_meanSig(1:missing_cond); NaN; ...
                       all_meanSig(missing_cond+1:end)];
        all_conditions = [all_conditions(1:missing_cond); all_conditions(missing_cond) + 1; ...
                          all_conditions(missing_cond+1:end)];
    end

    plot(all_conditions, ...
         all_meanSig, ...
         "Marker", "o", "MarkerSize", 8, "MarkerFaceColor", "auto");
    hold on;
end

xticks([1 2 3 4 5 6])
xticklabels([1 2 3 4 8 16])
xlabel("Number of laps")
ylabel("Prop. of sig.tuned cells (p < .05)")
grid on;
title(t, "Replay SWR")

%% Control : compairson with non-significant SWR

phase_data_nsig.conditionBin = phase_data_nsig.condition - ...
                              (phase_data_nsig.condition == 8)*3 - ...
                              (phase_data_nsig.condition == 16)*10;

f = figure;
t = tiledlayout(1, 2);

nexttile;
boxchart(phase_data_nsig.conditionBin, phase_data_nsig.phaseLocking)
xticks([1 2 3 4 5 6])
xticklabels([1 2 3 4 8 16])
xlabel("Number of laps")
ylabel("Phase locking")
grid on;

sumDataNsig = groupsummary(phase_data_nsig, ["animal", "conditionBin"], "mean", ["phaseLocking", "significance"]);

nexttile;
for aID = 1:numel(allAnimals)
    current_animal = allAnimals(aID); 
    all_conditions = sumDataNsig(sumDataNsig.animal == current_animal, :).conditionBin;
    all_meanSig = sumDataNsig(sumDataNsig.animal == current_animal, :).mean_significance;
    missing_cond = find(diff(all_conditions) ~= 1);
    if ~isempty(missing_cond)
        all_meanSig = [all_meanSig(1:missing_cond); NaN; ...
                       all_meanSig(missing_cond+1:end)];
        all_conditions = [all_conditions(1:missing_cond); all_conditions(missing_cond) + 1; ...
                          all_conditions(missing_cond+1:end)];
    end

    plot(all_conditions, ...
         all_meanSig, ...
         "Marker", "o", "MarkerSize", 8, "MarkerFaceColor", "auto");
    hold on;
end

xticks([1 2 3 4 5 6])
xticklabels([1 2 3 4 8 16])
xlabel("Number of laps")
ylabel("Prop. of sig.tuned cells (p < .05)")
grid on;

title(t, "Non-replay SWR")