clear

phase_data_sig = load("phase_data_sig.mat");
phase_data_sig = phase_data_sig.phase_data;

load("phase_data.mat");


% For now, as a filter for 1-spike cells, we remove all cells with 1 phase
% lock

phase_data(phase_data.phaseLocking > 0.95, :) = [];
phase_data_sig(phase_data_sig.phaseLocking > 0.95, :) = [];

%% Look at the tuning
load("tuning_curves.mat");

tuningMat = allTuningMat(2).tuningMat;
tuningMat = normalize(tuningMat, 2, "zscore");
[~, allPeaks] = max(tuningMat, [], 2);
[sortedPeaks, order] = sort(allPeaks);
tuningMat = tuningMat(order, :);
imagesc(tuningMat);


%% Analysis : difference in mean phase between appearing / disappearing cells / stable cells / unstable ?

allLabels = unique(phase_data.label);

figure;
tiledlayout(1, 3);
nexttile;
circ_plot(phase_data.meanPhase(phase_data.label == "Appears"), "pretty");
title("Appears cells")
nexttile;
circ_plot(phase_data.meanPhase(phase_data.label == "Disappear"), "pretty");
title("Disappear cells")
nexttile;
circ_plot(phase_data.meanPhase(phase_data.label == "Stable"), "pretty");
title("Stable cells")

%% Look at the link with refinement

figure;
for i = 1:numel(allLabels)
    current_label = allLabels(i);
    s = scatter(phase_data.meanPhase(phase_data.label == current_label), ...
        phase_data.refinCM(phase_data.label == current_label), 'filled');
    hold on;
end

legend(allLabels);

%%

figure;
tiledlayout(1, 3);
nexttile;
histogram(phase_data.meanPhase(phase_data.label == "Stable"), 20);
nexttile;
histogram(phase_data.meanPhase(phase_data.label == "Appears"), 20);
nexttile;
histogram(phase_data.meanPhase(phase_data.label == "Disappear"), 20);

%%

figure;
tiledlayout(2, 3);
nexttile;
histogram(phase_data.phaseLocking(phase_data.label == "Appears"), 20);
title("Appears")
ylabel("Count")

nexttile;
histogram(phase_data.phaseLocking(phase_data.label == "Disappear"), 20);
title("Disappear")
xlabel("Phase locking")

nexttile;
histogram(phase_data.phaseLocking(phase_data.label == "Stable"), 20);
title("Stable")

nexttile([1, 3])
boxchart(categorical(phase_data.label), phase_data.phaseLocking);
ylabel("Phase locking")

% Slight difference

%% To do inferential stats, we bootstrap

clc

p_values = zeros(1, 1000);
stable_vs_dis = zeros(1, 1000);
stable_vs_app = zeros(1, 1000);
dis_vs_app = zeros(1, 1000);

allStable = phase_data_sig.phaseLocking(phase_data_sig.label == "Stable");
allApp = phase_data_sig.phaseLocking(phase_data_sig.label == "Appears");
allDis = phase_data_sig.phaseLocking(phase_data_sig.label == "Disappear");

for iter = 1:1000
    if mod(iter, 100) == 0
        disp(iter);
    end

    subset_stable = allStable(randperm(numel(allStable), numel(allApp)));
    subset_dis = allDis(randperm(numel(allDis), numel(allApp)));

    data_concat = [subset_stable subset_dis allApp];

    p = anova1(data_concat, [], 'off');
    svd = ranksum(subset_stable, subset_dis);
    sva = ranksum(subset_stable, allApp);
    dva = ranksum(subset_dis, allApp);

    p_values(iter) = p;
    stable_vs_dis(iter) = svd;
    stable_vs_app(iter) = sva;
    dis_vs_app(iter) = dva;
end

p_under_05 = sum(p_values <= 0.005)/1000;
svd_under_05 = sum(stable_vs_dis <= 0.005)/1000;
sva_under_05 = sum(stable_vs_app <= 0.005)/1000;
dva_under_05 = sum(dis_vs_app <= 0.005)/1000;

disp("Overall model (prop. p-values under .001) : " + p_under_05);
disp("Stable vs. Disappear : " + svd_under_05);
disp("Stable vs. Appear : " + sva_under_05);
disp("Disappear vs. Appear : " + dva_under_05);


%% Animal-wise, for the plot

sumData = groupsummary(phase_data_sig, ["sessionID", "animal", "condition", "label"], ["median", "std"], ...
    ["meanPhase", "phaseLocking", "refinCM", "refinFR", "refinPeak"]);

allLabels = ["Appears", "Disappear", "Stable"];
[~, sumData.labelNum] = ismember(sumData.label, allLabels);

figure;
violinplot(sumData.median_phaseLocking, sumData.label)
xticks([1, 2, 3]);
xticklabels(allLabels);
ylabel("SWR phase locking");
xlabel("Cell type");

%% Scatter by condition with lines

figure;

allAnimals = unique(sumData.animal);
allConditions = unique(sumData.condition);

t = tiledlayout(2, 3);

for condID = 1:numel(allConditions)
    nexttile;
    for anID = 1:numel(allAnimals)
        matchingData = sumData(sumData.animal == allAnimals(anID) & ...
            sumData.condition == allConditions(condID), :);

        plot(matchingData.labelNum, matchingData.median_phaseLocking, '-o', ...
            'MarkerSize', 8, 'MarkerFaceColor', "auto");
        hold on;
    end

    hold off;
    xlim([0.25, 3.75])
    ylim([0 1])
    xticks([1 2 3])
    xticklabels(allLabels)
    title("Condition " + string(allConditions(condID)) + " laps")

end

ylabel("SWR phase locking")
xlabel("Cell type");

figure;
for condID = 1:numel(allConditions)
    for anID = 1:numel(allAnimals)
        matchingData = sumData(sumData.animal == allAnimals(anID) & ...
            sumData.condition == allConditions(condID), :);

        plot(matchingData.labelNum, matchingData.median_phaseLocking, '-o', ...
            'MarkerSize', 8, 'MarkerFaceColor', "auto");
        hold on;
    end

end

hold off;
xlim([0.25, 3.75])
xticks([1 2 3])
xticklabels(allLabels)
title("Condition " + string(allConditions(condID)) + " laps")

%% Effect of condition on phase-locking

sumData2 = groupsummary(phase_data_sig, ["animal", "condition"], ["median", "std"], ...
    ["meanPhase", "phaseLocking", "refinCM", "refinFR", "refinPeak"]);

figure;
subplot(1, 2, 1)
boxchart(phase_data_sig.condition, phase_data_sig.phaseLocking)
grid on;

subplot(1, 2, 2)

scatter(sumData2.condition, sumData2.median_phaseLocking);

%% Difference in phase-locking between all SWR and significant SWR

allCommon = [];
allCommonSig = [];

for line = 1:length(phase_data_sig.sessionID)
    current_line = phase_data_sig(line, :);
    hasAMatch = find(phase_data.sessionID == current_line.sessionID & ...
                     phase_data.animal == current_line.animal & ...
                     phase_data.condition == current_line.condition & ...
                     phase_data.cell == current_line.cell);

    if ~isempty(hasAMatch)
        allCommon(end + 1) = hasAMatch;
        allCommonSig(end + 1) = line;
    end
end

phase_com = phase_data(allCommon, :);
phase_sig_com = phase_data_sig(allCommonSig, :);

%% Now we can look at the difference in locking/phase between the two

id = [repelem(0, numel(phase_com.phaseLocking))'; repelem(1, numel(phase_com.phaseLocking))'];
locking = [phase_com.phaseLocking; phase_sig_com.phaseLocking];

figure;
tiledlayout(2, 2)

n1 = nexttile;
histogram(phase_com.phaseLocking, 100);
hold on;
histogram(phase_sig_com.phaseLocking, 100)
xlabel("Phase locking")
ylabel("Count")
title("Same cell locking during sig. / all SWR")
legend({"All SWR", "Sig. SWR"})

n2 = nexttile;
histogram(phase_com.meanPhase, 100);
hold on;
histogram(phase_sig_com.meanPhase, 100)
xlabel("Mean phase")
ylabel("Count")
title("Same cell mean phase during sig. / all SWR")
legend({"All SWR", "Sig. SWR"})

n3 = nexttile;
% Population level plot of the diff between sig. replay and all SWR tuning
sumLockSig = groupsummary(phase_sig_com, ["sessionID", "animal"], "median", "phaseLocking");
sumLock = groupsummary(phase_com, ["sessionID", "animal"], "median", "phaseLocking");

scatter(1, sumLock.median_phaseLocking, "filled");
hold on;
scatter(2, sumLockSig.median_phaseLocking, "filled");

for p = 1:numel(sumLock.median_phaseLocking)
    plot([1 2], [sumLock.median_phaseLocking(p) sumLockSig.median_phaseLocking(p)]);
end

hold off;
xlim([0.33 2.77])
xticks([1 2])
xticklabels(["All SWR", "Sig. SWR"])
ylabel("Phase locking")

%% 

boxchart(phase_com.condition, phase_sig_com.phaseLocking - phase_com.phaseLocking)
grid on;

%% Locking depending on the context ? 

sigT1 = phase_data_sig(phase_data_sig.condition == 16, :);
sigT2 = phase_data_sig(phase_data_sig.condition ~= 16, :);

allCommonT1 = [];
allCommonT2 = [];

for line = 1:length(sigT1.sessionID)
    current_line = sigT1(line, :);
    hasAMatch = find(sigT2.sessionID == current_line.sessionID & ...
                     sigT2.animal == current_line.animal & ...
                     sigT2.cell == current_line.cell);

    if ~isempty(hasAMatch)
        allCommonT2(end + 1) = hasAMatch;
        allCommonT1(end + 1) = line;
    end
end

sigT1 = sigT1(allCommonT1, :);
sigT2 = sigT2(allCommonT2, :);

%% 

figure;
subplot(1, 2, 1)
histogram(sigT1.phaseLocking, 100);
hold on;
histogram(sigT2.phaseLocking, 100)
xlabel("Phase locking")
ylabel("Count")
title("Same cell locking during T1 / T2 replay")
legend({"Track 1", "Track 2"})

subplot(1, 2, 2)
histogram(sigT1.meanPhase, 100);
hold on;
histogram(sigT2.meanPhase, 100)
xlabel("Phase locking")
ylabel("Count")
title("Same cell locking during T1 / T2 replay")
legend({"Track 1", "Track 2"})

figure;
subplot(1, 2, 1)
scatter(sigT1.phaseLocking, sigT2.phaseLocking)
xlabel("Track 1 phase locking");
ylabel("Track 2 phase locking")
subplot(1, 2, 2)
scatter(sigT1.meanPhase, sigT2.meanPhase)
xlabel("Track 1 mean phase");
ylabel("Track 2 mean phase")

% Seem to be independant !



