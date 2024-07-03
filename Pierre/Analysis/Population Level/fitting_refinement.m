% Script to fit learning curve to get the amount of experience
% equivalent of refinement
clear

load("Statistics\timeSeriesStable.mat");

subplot(1, 2, 1);
boxchart(data.lap(data.exposure == 1), data.pvCorr(data.exposure == 1))
subplot(1, 2, 2);
boxchart(data.lap(data.exposure == 2), data.pvCorr(data.exposure == 2))

%% Individual plots
id = 1;
datac = data(data.sessionID == id, :);
f = figure;
sgtitle("Projected number of laps to attain re-exposure stability")

X_T1R1 = datac.lap(datac.exposure == 1 & datac.condition == 16);
X_T1R2 = datac.lap(datac.exposure == 2 & datac.condition == 16);
X_T2R1 = datac.lap(datac.exposure == 1 & datac.condition ~= 16);
X_T2R2 = datac.lap(datac.exposure == 2 & datac.condition ~= 16);

Y_T1R1 = datac.pvCorr(datac.exposure == 1 & datac.condition == 16);
Y_T1R2 = datac.pvCorr(datac.exposure == 2 & datac.condition == 16);
Y_T2R1 = datac.pvCorr(datac.exposure == 1 & datac.condition ~= 16);
Y_T2R2 = datac.pvCorr(datac.exposure == 2 & datac.condition ~= 16);


% Plot track 1
subplot(1, 2, 1);
% We fit with a ln
fT1 = fit(X_T1R1, Y_T1R1, "log10");
meanDistance = mean(abs(Y_T1R1 - fT1(X_T1R1)), 'omitnan');
plot(X_T1R1, Y_T1R1, 'b', "LineWidth", 1.5);
hold on;
plot(X_T1R1, fT1(X_T1R1), "--b");

% Aesthetics
ylim([0 1]);
xlim([0 17]);
grid on;
hold on;

subplot(1, 2, 2);
plot(X_T1R2, Y_T1R2, 'b', "LineWidth", 1.5);
ylim([0 1]);
xlim([0 17]);
grid on;
hold on;

% Plot track 2

subplot(1, 2, 1);

% We get the same fit than track 1 but change the intercept
ft = fittype('a*log10(x) + b', 'independent', 'x', 'coefficients', {'b'}, 'problem', {'a'});
fB = fit(X_T2R1, Y_T2R1, ft, 'problem', fT1.a, 'StartPoint', [Y_T2R1(1)]);  % fit the function to B

if numel(Y_T2R1) == 1
    scatter(X_T2R1, Y_T2R1, "filled", 'r', "LineWidth", 1.5);
else
    plot(X_T2R1, Y_T2R1, 'r', "LineWidth", 1.5);
end

ylim([0 1]);
yline(Y_T2R2(1), "--m", "Level to attain")

% Determine the experience needed to get to re-exposure level
goalExp = find(fB(1:10000) >= Y_T2R2(1), 1);
plot(1:goalExp, fB(1:goalExp), '--r')
scatter(goalExp, Y_T2R2(1), "green", "filled");
title("Exposure")
xlabel("Lap");
ylabel("Correlation with FPF");

% Create the legend
legend({"Track 1", "Fit. T1", "Track 2", "Fit. T2", "", "Goal lap"})

subplot(1, 2, 2);
plot(X_T2R2, Y_T2R2, 'r', "LineWidth", 1.5);
ylim([0 1]);
title("Re-exposure")

%% We generalise to every session

session = [];
condition = [];
qualityFit = [];
lapsNeeded = [];

for sID = 1:19

    % We get the data
    datac = data(data.sessionID == sID, :);
    conditionOI = datac.condition(datac.condition ~= 16);
    conditionOI = conditionOI(1);

    X_T1R1 = datac.lap(datac.exposure == 1 & datac.condition == 16);
    X_T1R2 = datac.lap(datac.exposure == 2 & datac.condition == 16);
    X_T2R1 = datac.lap(datac.exposure == 1 & datac.condition ~= 16);
    X_T2R2 = datac.lap(datac.exposure == 2 & datac.condition ~= 16);

    Y_T1R1 = datac.pvCorr(datac.exposure == 1 & datac.condition == 16);
    Y_T1R2 = datac.pvCorr(datac.exposure == 2 & datac.condition == 16);
    Y_T2R1 = datac.pvCorr(datac.exposure == 1 & datac.condition ~= 16);
    Y_T2R2 = datac.pvCorr(datac.exposure == 2 & datac.condition ~= 16);

    % We fit a logarithm on track 1
    fT1 = fit(X_T1R1, Y_T1R1, "log10");
    % We get a fit performance metric
    meanDistance = mean(abs(Y_T1R1 - fT1(X_T1R1)), 'omitnan');

    % Determine the experience needed to get to re-exposure level
    goalExp = find(fT1(1:100) >= Y_T1R2(1), 1);
    numberLapsNeeded = goalExp - numel(Y_T1R1);
    if isempty(numberLapsNeeded)
        numberLapsNeeded = NaN;
    end

    session = [session; sID];
    condition = [condition; 16];
    qualityFit = [qualityFit; meanDistance];
    lapsNeeded = [lapsNeeded; numberLapsNeeded];

    % We get the same fit than T1 for T2 but change the intercept
    ft = fittype('a*log10(x) + b', 'independent', 'x', 'coefficients', {'b'}, 'problem', {'a'});
    fT2 = fit(X_T2R1, Y_T2R1, ft, 'problem', fT1.a, 'StartPoint', [Y_T2R1(1)]);

    % Determine the experience needed to get to re-exposure level
    goalExp = find(fT2(1:100) >= Y_T2R2(1), 1);
    numberLapsNeeded = goalExp - numel(Y_T2R1);
    if isempty(numberLapsNeeded)
        numberLapsNeeded = NaN;
    end

    session = [session; sID];
    condition = [condition; conditionOI];
    qualityFit = [qualityFit; meanDistance];
    lapsNeeded = [lapsNeeded; numberLapsNeeded];
    
end

%%
scatter(condition, lapsNeeded)
xlabel("Condition");
ylabel("Number of laps to match refinement");
xticks([1 2 3 4 8 16])

label_values = [1, 2, 3, 4, 8, 16];  % The unique label values
means = zeros(1, length(label_values));  % Initialize a vector to store the means

for i = 1:length(label_values)
    means(i) = mean(lapsNeeded(condition == label_values(i)), 'omitnan');
end

hold on;
plot(label_values, means, '--r')