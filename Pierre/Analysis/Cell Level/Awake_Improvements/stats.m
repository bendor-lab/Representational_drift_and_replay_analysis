clear
load("stabilisation_fluc.mat");

current_variables = string(data.Properties.VariableNames(8:end));
data.deltaFR(isnan(data.deltaCM)) = NaN;
% We concatenate each half lap
data.lap = floor((data.lap + 1)/2);

%%

sum1 = groupsummary(data, ["condition", "exposure", "lap"], ...
    ["mean", "std"], current_variables);

% Compute the standard error

for v = current_variables
    goal_name = "se_" + v;
    target_name = "std_" + v;
    sum1.(goal_name) = sum1.(target_name)./sqrt(sum1.GroupCount);
end

%% Plot the evolution of metrics across laps

for v = current_variables
    mean_name = "mean_" + v;
    se_name = "se_" + v;
    figure;
    timeSeriesOverLap(sum1, mean_name, se_name, v);
end

%% We get the lap-to-lap variation

% Concatenate half-laps
mean_data = groupsummary(data, ["sessionID", "animal", "cell", ...
    "condition", "exposure", "lap"], ...
    "mean", current_variables);
mean_data.GroupCount = [];
mean_data.Properties.VariableNames(7:end) = data.Properties.VariableNames(8:end);

time_ser = mean_data([], :);

% Get cross laps variations
for cID = 1:19
    for track = 1:2
        for cur_exposure = 1:2

            if track == 1
                subset_data = mean_data(mean_data.sessionID == cID & ...
                    mean_data.exposure == cur_exposure & ...
                    mean_data.condition == 16, :);
            else
                subset_data = mean_data(mean_data.sessionID == cID & ...
                    mean_data.exposure == cur_exposure & ...
                    mean_data.condition ~= 16, :);
            end

            allCells = unique(subset_data.cell)';

            for c = allCells
                current_data = subset_data(subset_data.cell == c, :);

                deltFR = current_data.deltaFR;
                deltCM = current_data.deltaCM;

                FR_evolution = diff(deltFR);
                CM_evolution = diff(deltCM);

                snippet = current_data(1:end-1, :);
                snippet.deltaFR = FR_evolution;
                snippet.deltaCM = CM_evolution;

                time_ser = [time_ser; snippet];

            end

        end
    end
end

%%

boxchart(time_ser.lap(time_ser.exposure == 1 & time_ser.condition == 16), ...
         time_ser.deltaFR(time_ser.exposure == 1 & time_ser.condition == 16))

%%


% First half-lap
subset = time_ser(time_ser.condition == 16 & ...
    time_ser.lap == 1 & ...
    time_ser.exposure == 1, :);

corrplot(subset(:, 7:end))

% No correlation with any of the metrics !

fitlme(time_ser(time_ser.condition == 16 & time_ser.exposure == 1, :), ...
    "deltaCM ~ lap*idleSWR")

%% Correlation between distance and swr

corr_CM_1 = NaN(19, 16);
corr_CM_2 = NaN(19, 16);
corr_FR_1 = NaN(19, 16);
corr_FR_2 = NaN(19, 16);

for l = 1:16
    for sID = 1:19 
        subset = data(data.condition == 16 & data.lap == l & ...
                      data.sessionID == sID, :);
    
        % c_CM_1 = corrcoef(subset.deltaCM(subset.exposure == 1), ...
        %     subset.idleSWR(subset.exposure == 1), 'Rows', 'complete');
        % 
        % c_CM_2 = corrcoef(subset.deltaCM(subset.exposure == 2), ...
        %     subset.idleSWR(subset.exposure == 2), 'Rows', 'complete');
    
        % c_FR_1 = corrcoef(subset.deltaFR(subset.exposure == 1), ...
        %     subset.idleSWR(subset.exposure == 1), 'Rows', 'complete');
        % 
        % c_FR_2 = corrcoef(subset.deltaFR(subset.exposure == 2), ...
        %     subset.idleSWR(subset.exposure == 2), 'Rows', 'complete');

        med_err_RUN1_CM = median(subset.deltaCM(subset.exposure == 1), "omitnan");
        med_err_RUN2_CM = median(subset.deltaCM(subset.exposure == 2), "omitnan");
        med_err_RUN1_FR = median(subset.deltaFR(subset.exposure == 1), "omitnan");
        med_err_RUN2_FR = median(subset.deltaFR(subset.exposure == 2), "omitnan");

        c_CM_1 = mean(subset.idleSWR(subset.exposure == 1 & ...
                      subset.deltaCM <= med_err_RUN1_CM), "omitnan") ...
               - mean(subset.idleSWR(subset.exposure == 1 & ...
                      subset.deltaCM > med_err_RUN1_CM), "omitnan");

        c_CM_2 = mean(subset.idleSWR(subset.exposure == 2 & ...
                      subset.deltaCM <= med_err_RUN2_CM), "omitnan") ...
               - mean(subset.idleSWR(subset.exposure == 2 & ...
                      subset.deltaCM > med_err_RUN2_CM), "omitnan");

        c_FR_1 = mean(subset.idleSWR(subset.exposure == 1 & ...
                      subset.deltaFR <= med_err_RUN1_FR), "omitnan") ...
               - mean(subset.idleSWR(subset.exposure == 1 & ...
                      subset.deltaFR > med_err_RUN1_FR), "omitnan");

        c_FR_2 = mean(subset.idleSWR(subset.exposure == 2 & ...
                      subset.deltaFR <= med_err_RUN2_FR), "omitnan") ...
               - mean(subset.idleSWR(subset.exposure == 2 & ...
                      subset.deltaFR > med_err_RUN2_FR), "omitnan");
    
        corr_CM_1(sID, l) = c_CM_1;
        corr_CM_2(sID, l) = c_CM_2;
        corr_FR_1(sID, l) = c_FR_1;
        corr_FR_2(sID, l) = c_FR_2;

    end

end

%%
f = figure;
tl = tiledlayout(2,2);
title(tl, "Cells with large distance to FPF are less actives during awake SWR")

nexttile;
se = std(corr_CM_1, "omitnan")./sqrt(19 - sum(isnan(corr_CM_1)));
e1 = errorbar(1:16, mean(corr_CM_1, "omitnan"), se, "-s", "MarkerSize",4,...
              "MarkerEdgeColor","blue","MarkerFaceColor",[0.65 0.85 0.90]);
e1.CapSize = 0;
hold on;
yline(0, "--r", "LineWidth", 2)
grid on;

% ylabel("CM distance x nb of SWR")
ylabel("Diff. in SWR for stable-unstable CMs")

title("Exposure");

nexttile;
se = std(corr_CM_2, "omitnan")./sqrt(19 - sum(isnan(corr_CM_2)));
e3 = errorbar(1:16, mean(corr_CM_2, "omitnan"), se, "-s", "MarkerSize",4,...
              "MarkerEdgeColor","blue","MarkerFaceColor",[0.65 0.85 0.90]);
e3.CapSize = 0;
hold on;
yline(0, "--r", "LineWidth", 2)
grid on;

title("Re-exposure");

nexttile;
se = std(corr_FR_1, "omitnan")./sqrt(19 - sum(isnan(corr_FR_1)));
e2 = errorbar(1:16, mean(corr_FR_1, "omitnan"), se, "-s", "MarkerSize",4,...
              "MarkerEdgeColor","blue","MarkerFaceColor",[0.65 0.85 0.90]);
e2.CapSize = 0;
hold on;
yline(0, "--r", "LineWidth", 2)
grid on;

xlabel("Laps")
%ylabel("FR distance x nb of SWR")
ylabel("Diff. in SWR for stable-unstable FRs")


nexttile;
se = std(corr_FR_2, "omitnan")./sqrt(19 - sum(isnan(corr_FR_2)));
e4 = errorbar(1:16, mean(corr_FR_2, "omitnan"), se, "-s", "MarkerSize",4,...
              "MarkerEdgeColor","blue","MarkerFaceColor",[0.65 0.85 0.90]);
e4.CapSize = 0;
hold on;
yline(0, "--r", "LineWidth", 2)
grid on;

linkaxes()

%%

subset = data(data.condition == 16 & data.lap == 2 & ...
              data.sessionID == 14 & data.exposure == 1, :);

scatter(subset.idleSWR, subset.deltaCM)
h1 = lsline;
h1.Color = "r";
h1.LineWidth = 1.2;

title("Corr. example - Lap 2 / Condition 16 / Exposure")
xlabel("Number of SWR after the lap")
ylabel("CM distance with FPF during the lap")
grid on;

xlim([-1 9]);

%% -----------------

f = figure;
tl = tiledlayout(1, 2);

subset = mean_data(mean_data.condition == 16 & ...
         mean_data.lap == 1 & mean_data.exposure == 1, :);

current_median = median(subset.deltaCM, "omitnan");

nexttile;
n1 = subset.deltaCM(subset.deltaCM <= current_median);
n2 = subset.deltaCM(subset.deltaCM > current_median);
h1 = histogram(n1, 0:2:max(n1));
hold on;
h2 = histogram(n2, n1:2:max(n2));
xline(current_median - 2, ":r", string(current_median))
legend({"< to median, n = " + string(numel(n1)), ...
        "> to median, n = " + string(numel(n2))})

xlabel("CM distance with FPF")
ylabel("Count")

nexttile;

boxchart((subset.deltaCM <= current_median) + 1, subset.idleSWR);
grid on;
xlabel("Stability of the cell")
ylabel("Number of SWR")
xticks([1 2])
xticklabels({"Far from FPF", "Close to FPF"})

title(tl, "Condition 16, RUN1, lap N°1")

%%
is_less_med = zeros(numel(mean_data.lap), 1);

for l = 1:16
    bool = mean_data.exposure == 1 & ...
           mean_data.condition == 16 & ...
           mean_data.lap == l;

    subset = mean_data(bool, :);
    curr_med = median(subset.deltaCM, "omitnan");
    filter = bool & mean_data.deltaCM <= curr_med;
    is_less_med = is_less_med + filter;
end

mean_data.is_less_med = is_less_med - 0.5;

fitlme(mean_data(mean_data.exposure == 1 & mean_data.condition == 16, :), "idleSWR ~ deltaCM*lap + (1|animal)")

% Same thing for back / forward replay

fitlme(mean_data(mean_data.exposure == 1 & mean_data.condition == 16, :), ...
       "deltaCM ~ idleSWR*lap + spikesRUN + (1|animal)")


%% -----------------

f = figure;
tl = tiledlayout(1, 2);

subset = mean_data(mean_data.condition == 16 & ...
         mean_data.lap == 1 & mean_data.exposure == 1, :);

current_median = median(subset.deltaCM, "omitnan");

nexttile;
n1 = subset.deltaCM(subset.deltaCM <= current_median);
n2 = subset.deltaCM(subset.deltaCM > current_median);
h1 = histogram(n1, 0:2:max(n1));
hold on;
h2 = histogram(n2, n1:2:max(n2));
xline(current_median - 2, ":r", string(current_median))
legend({"< to median, n = " + string(numel(n1)), ...
        "> to median, n = " + string(numel(n2))})

xlabel("CM distance with FPF")
ylabel("Count")

nexttile;

boxchart((subset.deltaCM <= current_median) + 1, subset.ReplayDir);
grid on;
xlabel("Stability of the cell")
ylabel("Bias of Replay")
xticks([1 2])
xticklabels({"Far from FPF", "Close to FPF"})

title(tl, "Condition 16, RUN1, lap N°1")

fitlme(subset, "idleReplay ~ is_less_med*ReplayDir + (1|animal)")