% These regressions assess whether or not, on the population level, 
% we see an increase in stability over sleep, and if that refinement is 
% linked with the previous experience and with the amount of replay.
% We also look at the link between the stability during the last lap 
% and the amount of replay

% We will use mixed models with a random intercept for the animal.
% Cells included are good place cells.
% refinement is corr(1st lap RUN2, FPF) - corr(Last lap RUN1, FPF).

% FPF is the mean of the place fields (smoothed) from the 6 laps following
% the 16 laps during RUN2

% We will test the interactions. If no interaction, we will use a model
% without. 
% The condition will be center logged. The replay will be centered.

clear

data = load("dataRegressionPop.mat");
data = data.data;
data.replayPartC = data.partP1Rep - mean(data.partP1Rep, 'omitnan');
data.logCondC = log(data.condition) - mean(log(data.condition));
data.amountSleepC = data.amountSleep - mean(data.amountSleep);
data.numberSWRC = data.numberSWR - mean(data.numberSWR);

%% Replay participation --------------------------------------------------

%% Interaction, condition logged

lme = fitlme(data, "refinCorr ~ logCondC * replayPartC * amountSleepC + (1|animal)");
disp(lme)

% No interaction.

%% Without interaction, condition logged

lme = fitlme(data, "refinCorr ~ logCondC + replayPartC + amountSleepC + (1|animal)");
disp(lme)

% Significant intercept and effect of condition. No effect of replay /
% sleep


%% Without interaction, without logged condition

lme = fitlme(data, "refinCorr ~ condition + replayPartC + amountSleepC + (1|animal)");
disp(lme)

% Significant intercept and effect of condition. No effect of amount of
% sleep or replay.

%% Number of SWR ---------------------------------------------------------

%% Interaction, condition logged

lme = fitlme(data, "refinCorr ~ logCondC * numberSWRC * amountSleepC + (1|animal)");
disp(lme)

% No interaction.

%% Without interaction, condition logged

lme = fitlme(data, "refinCorr ~ logCondC + numberSWRC + amountSleepC + (1|animal)");
disp(lme)

% Significant intercept and effect of condition. No effect of sleep.
% Weak effect of the number of SWR - 0.03. Seems to be due to outliers.

%% Without interaction, without logged condition

lme = fitlme(data, "refinCorr ~ condition + numberSWRC + amountSleepC + (1|animal)");
disp(lme)

% Significant intercept and effect of condition. Small effect of SWR. No
% effect of sleep. 