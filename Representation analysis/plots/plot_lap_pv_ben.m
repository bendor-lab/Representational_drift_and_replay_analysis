%% This code generate a plot of the mean pv-correlation evolution 
% across laps - New data !
% PV 2025

dataLapCorr = load("../data/time_serie_control.mat"); % load the data
dataLapCorr = dataLapCorr.data;

sum = groupsummary(dataLapCorr, ...
                     ["condition", "exposure", "lap", "track"], ...
                     ["median", "std"], ["pvCorr"]); % calculate the mean pv correlation across sessions
sum.se_pvCorr = sum.std_pvCorr./sqrt(sum.GroupCount);

var = "median_pvCorr";
varName = "PV correlation";
std_var = "se_pvCorr";

allConditions = unique(sum.condition);
colors = lines(length(allConditions));

for cond = allConditions'
    
    f1 = figure;
    f1.Position = [0,0,964,542];
    
    cur_data = sum(sum.condition == cond, :);

end


for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
    color = colors(allConditions == condition, :);

    % We get the lap data of the exposure
    dataByLapExp1 = sum(sum.condition_num == condition & sum.exposure == 1, :);
    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:condition, :);

    % We get the lap data of the reexposure
    dataByLapExp2 = sum(sum.condition_num == condition & sum.exposure == 2, :);

    % Filling with NaN to have padding + shading areas
    nbNan = 17 - condition;
    Y = [dataByLapExp1.(var)' repelem(NaN, nbNan) dataByLapExp2.(var)'];
    Y1_shade = dataByLapExp1.(var)';
    std1_data = dataByLapExp1.(std_var)';
    Y2_shade = dataByLapExp2.(var)';
    std2_data = dataByLapExp2.(std_var)';
    X = 1:numel(Y);
    X1_shade = 1:numel(Y1_shade);
    X2_shade = (numel([dataByLapExp1.(var)' repelem(NaN, nbNan)])+1):numel(Y);
    % Shading the std
    f1 = fill([X1_shade, flip(X1_shade)], [Y1_shade + std1_data, flip(Y1_shade - std1_data)], color, ...
         'FaceAlpha', 0.1);
    f1.LineStyle = "none";
    hold on;
    f2 = fill([X2_shade, flip(X2_shade)], [Y2_shade + std2_data, flip(Y2_shade - std2_data)], color, ...
         'FaceAlpha', 0.1);
    f2.LineStyle = "none";

    % Main plot
    plot(X, Y, 'Color', color, 'LineWidth', 2);
    
    % if condition 1 lap, scatter instead of plotting
    if condition == 1
        hold on;
        errorbar(1, Y(1), std1_data(1), "-s", "MarkerSize", 5, "Color", color, "CapSize", 6, ...
            "LineWidth", 1.5, "MarkerFaceColor", color);
    end

    hold on;

end

xline(17, '-', 'Sleep', 'LineWidth', 2, 'LabelOrientation', 'horizontal', 'FontSize', 12);

hold off;

limitUp = max(sum.(var)) + 0.125 * max(sum.(var));

% Set the legend
ylim([0, limitUp])
legend({'', '', ' 1 lap', '', ...
        '', '', ' 2 laps', ...
        '', '', ' 3 laps', ...
        '', '', ' 4 laps', ...
        '', '', ' 8 laps', ...
        '', '', ' 16 laps'}, 'Location','southoutside','NumColumns', 6, 'FontSize', 12);

legend('show');
xlabel("Lap")
ylabel("Median " + varName, 'FontSize', 12)
title("1^{st} exposure" + repelem(' ', 80) + "2^{nd} exposure")


grid on;

xticks([1 4 7 10 13 16 18 21 24 27 30 33]);
xticklabels({"1", "3", "7", "10", "13", "16", "1", "3", "7", "10", "13", "16"})

%% Repeat the same plot per animal

all_animals = unique(dataLapCorr.animal);

for an = all_animals'

    f = figure;
    hold on;

    cur_subdata = dataLapCorr(dataLapCorr.animal == an, :);
    all_conditions = unique(cur_subdata.condition);

    for cond_id = 1:numel(all_conditions)

        cur_cond = all_conditions(cond_id);

        cond_data_e1 = cur_subdata(cur_subdata.condition == cur_cond & cur_subdata.exposure == 1 & cur_subdata.track == 2, :);
        cond_data_e2 = cur_subdata(cur_subdata.condition == cur_cond & cur_subdata.exposure == 2 & cur_subdata.track == 2, :);

        plot(cond_data_e1.lap, cond_data_e1.pvCorr, 'Color', colors(cond_id, :), 'LineWidth', 2)
        plot(cond_data_e2.lap + 16, cond_data_e2.pvCorr, 'Color', colors(cond_id, :), 'LineWidth', 2)

        if cond_id == 1
            scatter(cond_data_e1.lap, cond_data_e1.pvCorr, 20, 'filled', "MarkerFaceColor", colors(cond_id, :));
        end

    end

    % We can take the mean of 16 laps
    mean_t1 = groupsummary(cur_subdata(cur_subdata.track == 1, :), ...
                 ["exposure", "lap"], ...
                 ["median", "std"], ["pvCorr"]); % calculate the mean pv correlation across sessions
    
    t1_e1 = mean_t1(mean_t1.exposure == 1, :);
    t1_e2 = mean_t1(mean_t1.exposure == 2, :);
    plot(t1_e1.lap, t1_e1.median_pvCorr, 'Color', colors(end, :), 'LineWidth', 2)
    plot(t1_e2.lap + 16, t1_e2.median_pvCorr, 'Color', colors(end, :), 'LineWidth', 2)
end