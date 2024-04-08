clear

load("phase_data.mat");

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