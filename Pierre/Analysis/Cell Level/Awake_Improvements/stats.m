clear
load("stabilisation_fluc.mat");

current_variables = string(data.Properties.VariableNames(8:end));
data.deltaFR(isnan(data.deltaCM)) = NaN;

% We concatenate each half lap
data.lap = floor((data.lap + 1)/2);

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


% First half-lap
subset = time_ser(time_ser.condition == 16 & ...
                  time_ser.lap == 1 & ...
                  time_ser.exposure == 1, :);

corrplot(subset(:, 8:end))

% No correlation with any of the metrics !
