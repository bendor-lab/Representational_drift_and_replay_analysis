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

%% Interaction, condition logged

lme = fitlme(data, "refinCorr ~ logCondC * replayPartC + (1|animal)");
disp(lme)

% No interaction.

lme = fitlme(data, "corrEndRUN1 ~ logCondC * replayPartC + (1|animal)");
disp(lme)

% No interaction.

%% Without interaction, condition logged

lme = fitlme(data, "refinCorr ~ logCondC + replayPartC + (1|animal)");
disp(lme)

% Significant intercept and effect of condition.

lme = fitlme(data, "corrEndRUN1 ~ logCondC + replayPartC + (1|animal)");
disp(lme)

% Significant intercept and effect of condition (expected). No effect of
% replay.

%% Without interaction, without logged condition

lme = fitlme(data, "refinCorr ~ condition + replayPartC + (1|animal)");
disp(lme)

% Significant intercept and effect of condition.

lme = fitlme(data, "corrEndRUN1 ~ condition + replayPartC + (1|animal)");
disp(lme)

% Significant intercept and effect of condition (expected). No effect of
% replay.
