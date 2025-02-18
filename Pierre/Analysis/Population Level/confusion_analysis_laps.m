%% Look at the track confusion across laps
clear

load("confusion_file_reexp.mat");

confusion = confusion(2:end, :);

allData_concat = [repelem({NaN(40, 40)}, 8)];

for fID = 1:numel([confusion.fID])
    all_laps = numel(confusion(fID).exposure);
    for l = 1:all_laps
        current_mat = confusion(fID).exposure{l};
        % We change the matrix to make the long diagonal
        current_mat = [current_mat(21:40, :); current_mat(1:20, :)];
        % Concat the NaN matrix with the new matrix
        allData_concat{l} = cat(3, allData_concat{l}, current_mat);
    end
end

number_obs = cell2mat(cellfun(@(x) size(x, 3), allData_concat, 'UniformOutput', false)) - 1;
allData_concat = cellfun(@(x) mean(x, 3, 'omitnan'), allData_concat, 'UniformOutput', false);

figure;
tiledlayout(2, 4);

for el = 1:numel(allData_concat)
    nexttile;
    clims = [0 1];
    imagesc(allData_concat{el}, clims);
    xline(20.5, 'w');
    yline(20.5, 'w');
    axis on;
    xticks([10.5, 30.5])
    xticklabels(["T1", "T2"]);
    yticks([10.5, 30.5])
    yticklabels(["T2", "T1"]);
    title("Lap " + el + " (n = " + number_obs(el) + ")");

    if el == 1
        xlabel("Real position");
        ylabel("Decoded position")
    end
end

h = colorbar;
h.Limits = [0, 1];

%% Plot the track confusion for track 1 and track 2 across laps

figure;

fID = [];
animal = [];
condition = [];
exposure = [];
lap = [];
T1_error_ratio = []; % T1 decoded as T2
T2_error_ratio = []; % T2 decoded as T1

for file = 1:19

    % Exposure
    nbLapsExp = numel(confusion(file).exposure);
    for l = 1:nbLapsExp
        currT1conf = confusion(file).exposure{l}(21:40, 1:20);
        currT1conf = mean(sum(currT1conf, 'omitnan'), 'omitnan');

        currT2conf = confusion(file).exposure{l}(1:20, 21:40);
        currT2conf = mean(sum(currT2conf, 'omitnan'), 'omitnan');

        fID = [fID; file];
        animal = [animal; confusion(file).animal];
        condition = [condition; confusion(file).condition];
        exposure = [exposure; 1];
        lap = [lap; l];
        T1_error_ratio = [T1_error_ratio; currT1conf]; % T1 decoded as T2
        T2_error_ratio = [T2_error_ratio; currT2conf]; % T2 decoded as T1
    end
    
    % Re-exposure
    nbLapsReexp = 16;
    for l = 1:nbLapsReexp
        currT1conf = confusion(file).reexposure{l}(21:40, 1:20);
        currT1conf = mean(sum(currT1conf, 'omitnan'), 'omitnan');

        currT2conf = confusion(file).reexposure{l}(1:20, 21:40);
        currT2conf = mean(sum(currT2conf, 'omitnan'), 'omitnan');

        fID = [fID; file];
        animal = [animal; confusion(file).animal];
        condition = [condition; confusion(file).condition];
        exposure = [exposure; 2];
        lap = [lap; l];
        T1_error_ratio = [T1_error_ratio; currT1conf]; % T1 decoded as T2
        T2_error_ratio = [T2_error_ratio; currT2conf]; % T2 decoded as T1
    end
end

data_lap = table(fID, animal, condition, exposure, lap, T1_error_ratio, T2_error_ratio);
summary = groupsummary(data_lap, ["condition", "exposure", "lap"], ["mean", "std"], ["T1_error_ratio", "T2_error_ratio"]);

%% Plot T1 -----

var = "mean_T1_error_ratio";
var_std = "std_T1_error_ratio";


allConditions = unique(summary.condition);
allConditionsNum = [1 2 3 4 8];
colors = lines(length(allConditions));

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
    condition_num = split(condition, 'x');
    condition_num = double(condition_num(2));
    color = colors(allConditionsNum == condition_num, :);

    % We get the lap data of the exposure
    dataByLapExp1 = summary(summary.condition == condition & summary.exposure == 1, :);

    % We get the lap data of the reexposure
    dataByLapExp2 = summary(summary.condition == condition & summary.exposure == 2, :);

    % Number of NaNs to fill
    nbNan = 17 - condition_num;

    Y = [dataByLapExp1.(var)' repelem(NaN, nbNan) dataByLapExp2.(var)'];

    Y1_shade = dataByLapExp1.(var)';
    std1_data = dataByLapExp1.(var_std)';

    Y2_shade = dataByLapExp2.(var)';
    std2_data = dataByLapExp2.(var_std)';

    X = 1:numel(Y);

    X1_shade = 1:numel(Y1_shade);
    X2_shade = (numel([dataByLapExp1.(var)' repelem(NaN, nbNan)])+1):numel(Y);

    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter

    % Shading the std
    f1 = fill([X1_shade, flip(X1_shade)], [Y1_shade + std1_data, flip(Y1_shade - std1_data)], color, ...
         'FaceAlpha', 0.1);
    f1.LineStyle = "none";
    hold on;

    f2 = fill([X2_shade, flip(X2_shade)], [Y2_shade + std2_data, flip(Y2_shade - std2_data)], color, ...
         'FaceAlpha', 0.1);
    f2.LineStyle = "none";

    plot(X, Y, 'Color', color, 'LineWidth', 2);

    if condition_num == 1
        hold on;
        errorbar(1, Y(1), std1_data(1), "-s", "MarkerSize", 5, "Color", color, "CapSize", 6, ...
            "LineWidth", 1.5, "MarkerFaceColor", color);
    end

    hold on;

end

xline(17, '-', 'Sleep', 'LineWidth', 2, 'LabelOrientation', 'horizontal', 'FontSize', 12);

hold off;

limitUp = max(summary.(var)) + 0.125 * max(summary.(var));

% Set the legend
ylim([0, limitUp])
legend({'', '', ' 1 lap', '', ...
        '', '', ' 2 laps', ...
        '', '', ' 3 laps', ...
        '', '', ' 4 laps', ...
        '', '', ' 8 laps'}, 'Location','southoutside','NumColumns', 6, 'FontSize', 12);

legend('show');
xlabel("Lap")
ylabel("% of T1 decoded as T2", 'FontSize', 12)
title("1^{st} exposure" + repelem(' ', 80) + "2^{nd} exposure")

grid on;

xticks([1 4 7 10 13 16 18 21 24 27 30 33]);
xticklabels({"1", "3", "7", "10", "13", "16", "1", "3", "7", "10", "13", "16"})

%% Plot T2 -----

var = "mean_T2_error_ratio";
var_std = "std_T2_error_ratio";


allConditions = unique(summary.condition);
allConditionsNum = [1 2 3 4 8];
colors = lines(length(allConditions));

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
    condition_num = split(condition, 'x');
    condition_num = double(condition_num(2));
    color = colors(allConditionsNum == condition_num, :);

    % We get the lap data of the exposure
    dataByLapExp1 = summary(summary.condition == condition & summary.exposure == 1, :);

    % We get the lap data of the reexposure
    dataByLapExp2 = summary(summary.condition == condition & summary.exposure == 2, :);

    % Number of NaNs to fill
    nbNan = 17 - condition_num;

    Y = [dataByLapExp1.(var)' repelem(NaN, nbNan) dataByLapExp2.(var)'];

    Y1_shade = dataByLapExp1.(var)';
    std1_data = dataByLapExp1.(var_std)';

    Y2_shade = dataByLapExp2.(var)';
    std2_data = dataByLapExp2.(var_std)';

    X = 1:numel(Y);

    X1_shade = 1:numel(Y1_shade);
    X2_shade = (numel([dataByLapExp1.(var)' repelem(NaN, nbNan)])+1):numel(Y);

    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter

    % Shading the std
    f1 = fill([X1_shade, flip(X1_shade)], [Y1_shade + std1_data, flip(Y1_shade - std1_data)], color, ...
         'FaceAlpha', 0.1);
    f1.LineStyle = "none";
    hold on;

    f2 = fill([X2_shade, flip(X2_shade)], [Y2_shade + std2_data, flip(Y2_shade - std2_data)], color, ...
         'FaceAlpha', 0.1);
    f2.LineStyle = "none";

    plot(X, Y, 'Color', color, 'LineWidth', 2);

    if condition_num == 1
        hold on;
        errorbar(1, Y(1), std1_data(1), "-s", "MarkerSize", 5, "Color", color, "CapSize", 6, ...
            "LineWidth", 1.5, "MarkerFaceColor", color);
    end

    hold on;

end

xline(17, '-', 'Sleep', 'LineWidth', 2, 'LabelOrientation', 'horizontal', 'FontSize', 12);

hold off;

limitUp = max(summary.(var)) + 0.125 * max(summary.(var));

% Set the legend
ylim([0, limitUp])
legend({'', '', ' 1 lap', '', ...
        '', '', ' 2 laps', ...
        '', '', ' 3 laps', ...
        '', '', ' 4 laps', ...
        '', '', ' 8 laps'}, 'Location','southoutside','NumColumns', 6, 'FontSize', 12);

legend('show');
xlabel("Lap")
ylabel("% of T2 decoded as T1", 'FontSize', 12)
title("1^{st} exposure" + repelem(' ', 80) + "2^{nd} exposure")

grid on;

xticks([1 4 7 10 13 16 18 21 24 27 30 33]);
xticklabels({"1", "3", "7", "10", "13", "16", "1", "3", "7", "10", "13", "16"})