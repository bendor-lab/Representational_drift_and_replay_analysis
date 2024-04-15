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

data = load("dataRegressionPopBalanced.mat");
data = data.data;
data.replayPartC = data.partP1Rep - mean(data.partP1Rep, 'omitnan');
data.logCondC = log(data.condition) - mean(log(data.condition));
data.amountSleepC = data.amountSleep - mean(data.amountSleep);
data.numberSWRC = data.numberSWR - mean(data.numberSWR);
data.expReexpBiasC = data.expReexpBias - mean(data.expReexpBias);

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

lme = fitlme(data, "refinCorr ~ logCondC * numberSWRC * numberSWRC + (1|animal)");
disp(lme)

% No interaction.

%% Without interaction, condition logged

lme = fitlme(data, "refinCorr ~ logCondC + numberSWRC + numberSWRC + (1|animal)");
disp(lme)

% Significant intercept and effect of condition. No effect of sleep.
% Weak effect of the number of SWR - 0.03. Seems to be due to outliers.

%% Without interaction, without logged condition

lme = fitlme(data, "refinCorr ~ condition + numberSWRC + (1|animal)");
disp(lme)

% Significant intercept and effect of condition. Small effect of SWR. No
% effect of sleep. 


%% Proportion of re-exposure replay vs. exposure replay

lme = fitlme(data, "expReexpBiasC ~ logCondC + (1|animal)");
disp(lme)

% Significant negative effect of the condition on the expression / re-expression
% bias (p = .005).

lme = fitlme(data, "refinCorr ~ expReexpBiasC + (1|animal)");
disp(lme)

% Tendencial effect of the exp / re-exp bias on the refinement.

beeswarm(data.condition, data.expReexpBias)
xlabel("Number of laps");
ylabel("Replay bias (-1 : Exposure ; 1 : Re-exposure)")
xticks([1, 2, 3, 4, 8, 16])

gscatter(data.expReexpBias(data.condition ~= 16), data.refinCorr(data.condition ~= 16), data.condition(data.condition ~= 16))