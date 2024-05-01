% Script to generate plots for the population-level results

data = load("dataRegressionPopIntersect.mat");
data = data.data;
data.conditionC = categorical(data.condition);

%% Define the colors used

colorMatrix = [255, 215, 0;
               255, 177, 78;
               250, 135, 117;
               234, 95, 148;
               205, 52, 181;
               157, 2, 215;
               0, 0, 255];

% Convert to values between 0 and 1
colorMatrix = colorMatrix / 255;

%% Refinement over sleep x Condition
fig = figure;
ax = gca;
b = boxchart(data.conditionC, data.refinCorr, "BoxFaceAlpha", 0.7);
b.BoxMedianLineColor = "k";
b.LineWidth = 1.5;
b.BoxEdgeColor = "k";

ax.LineWidth = 1.5;

xlabel('Laps ran during the exposure', 'FontSize', 12);
ylabel('Correlation improvement over sleep', 'FontSize', 12);

grid on
ax.XGrid = "off";
