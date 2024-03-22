function [] = timeSeriesOverLap(data, var, varName)

allConditions = unique(data.condition);
colors = lines(length(allConditions));

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
    color = colors(allConditions == condition, :);

    % We get the lap data of the exposure
    dataByLapExp1 = data(data.condition == condition & data.exposure == 1, :);
    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:condition, :);

    % We get the lap data of the reexposure
    dataByLapExp2 = data(data.condition == condition & data.exposure == 2, :);

    % Number of NaNs to fill
    nbNan = 17 - condition;

    Y = [dataByLapExp1.(var)' repelem(NaN, nbNan) dataByLapExp2.(var)'];
    X = 1:numel(Y);

    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter

    plot(X, Y, 'Color', color, 'LineWidth', 2);

    if condition == 1
        hold on;
        scatter(1, Y(1), 30, color, "filled");
    end

    hold on;

end

xline(17, '-', 'Sleep', 'LineWidth', 2, 'LabelOrientation', 'horizontal', 'FontSize', 12);

hold off;

limitUp = max(data.(var)) + 0.125 * max(data.(var));

% Set the legend
ylim([0, limitUp])
legend({' 1 lap', '', ' 2 laps', ' 3 laps', ' 4 laps', ' 8 laps', ' 16 laps'}, 'Location','southoutside','NumColumns', 6, 'FontSize', 12);
legend('show');
xlabel("Lap")
ylabel("Median " + varName + " difference with the FPF", 'FontSize', 12)
title("1^{st} exposure" + repelem(' ', 80) + "2^{nd} exposure")

grid on;

xticks([1 4 7 10 13 16 18 21 24 27 30 33]);
xticklabels({"1", "3", "7", "10", "13", "16", "1", "3", "7", "10", "13", "16"})


end

