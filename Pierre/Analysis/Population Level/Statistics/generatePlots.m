% Script to generate plots for the population-level results

data = load("dataRegressionPop.mat");
data = data.data;
data.conditionC = data.condition;

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

%% 

fig = figure;
ax = gca;

old_values = [1, 2, 3, 4, 8, 16];
new_values = [1, 3, 5, 7, 9, 11];

x = changem(data.condition, new_values, old_values);
x = x + randn(numel(x), 1)/10;

y = data.refinCorr;

meanY = [];

for v = 1:numel(old_values)
    scatter(x(data.condition == old_values(v)), ...
             y(data.condition == old_values(v)), ...
             "filled")
    meanY(end + 1) = mean(y(data.condition == old_values(v)), 'omitnan');
    hold on;
end

grid on;
xticks(new_values)
xticklabels(old_values)

xlabel('Laps ran during the 1st exposure', 'FontSize', 12);
ylabel('Correlation improvement over sleep', 'FontSize', 12);

%%

plot((1:16) - 1, log10(1:16), 'LineWidth', 2);
xticks(0:2:15)
xticklabels([])
yticks([])
grid on;

%% 

scatter(data.amountSleep, data.refinCorr, "filled");

xlabel('Amount of sleep during POST1 (m)', 'FontSize', 12);
ylabel('Correlation improvement over sleep', 'FontSize', 12);
grid on;
p = polyfit(data.amountSleep, data.refinCorr, 1);
hold on;
plot(data.amountSleep, polyval(p, data.amountSleep), 'r')

%% 

scatter(data.partP1Rep, data.refinCorr, "filled");

xlabel('Number of POST1 sleep replay', 'FontSize', 12);
ylabel('Correlation improvement over sleep', 'FontSize', 12);
grid on;
p = polyfit(data.partP1Rep, data.refinCorr, 1);
hold on;
plot(data.partP1Rep, polyval(p, data.partP1Rep), 'r')

