%% Script to analyze the learning curves of the representation
% at the cell level

clear
load("cell_data_learning.mat")

subset = data(data.condition == 16 & data.exposure == 1, :);
all_cells = unique(subset.cell);

subsub = subset(subset.cell == all_cells(3), :);

figure;

t = tiledlayout(5, 5);

for i = 76:100
    subsub = subset(subset.cell == all_cells(i), :);
    nexttile;
    plot(subsub.lap, subsub.PeakDiff)
    % set(gca,'XColor', 'none','YColor','none')
end

linkaxes()