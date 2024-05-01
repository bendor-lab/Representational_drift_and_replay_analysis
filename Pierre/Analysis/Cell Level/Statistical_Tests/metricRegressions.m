% Final regressions performed on the cell-level metrics :
% Over sleep CM stabilisation (difference between 1st lap of RUN1 and 1st lap of RUN2
% in CM with the Final Place Field)
% Over sleep Peak Firing Rate stabilisation (normalised as the difference / sum)
% Over sleep Peak Location stabilisation

% The FPF is the mean place field of each cell during the 6 laps following
% the 16th lap of RUN2.

% The cells included are good place cells during RUN2 (criteria : )
% The place fields used are all smoothed place fields.

% Here, the measures on track 1 / track 2 are repeated measures, but will
% be treated as independent, as the track is co-dependent with the
% condition. 

% The condition will be logged, to linearise the variable "number of laps ran 
% during RUN1 - Track 2" (1, 2, 3, 4, 8, 16).

% The same analysis will be conducted without this log, to make sure it
% doesn't change radically the results.

% The models used will be mixed-models, with a random intercept for the
% factor "animal".
% Each model will first be tested with an interaction. If
% N.S, the interaction will be removed.

clear 

data = load("dataRegression.mat");
data = data.data;

% We filter toget only STABLE CELLS
data(data.label ~= "Stable", :) = [];

data.logConditionC = log2(data.condition) - mean(log2(data.condition));
data.conditionC = data.condition - mean(data.condition);
data.replayPartC = data.partP1Rep - mean(data.partP1Rep, "omitnan");
data.propPartRepC = data.propPartRep - mean(data.propPartRep);
data.partSWRC = data.partSWR - mean(data.partSWR);
data.expReexpBiasC = data.expReexpBias - mean(data.expReexpBias, 'omitnan');

%% Do we see remapping over laps ?  ---------------------------------------

dataLaps = load("timeSeries.mat");
dataLaps = dataLaps.data;

dataLaps.logConditionC = log2(dataLaps.condition) - mean(log2(dataLaps.condition));

% We use a mixed model with animal as a random factor
% Here we use the cell because a LOT of different measures.

lme = fitlme(dataLaps, "CMdiff ~ logConditionC + lap + exposure + (1|animal) + (1|cell)");
disp(lme);

lme = fitlme(dataLaps, "FRdiff ~ logConditionC + lap + exposure + (1|animal) + (1|cell)");
disp(lme);

lme = fitlme(dataLaps, "PeakDiff ~ logConditionC + lap + exposure + (1|animal) + (1|cell)");
disp(lme);

% Lap is very significant, negative coefficient. Stabilisation.

%% Effect of condition and the ABSOLUTE quantity of replay ----------------

%% Regressions - Interactions & log condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ logConditionC * replayPartC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : No significant interaction.

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ logConditionC * replayPartC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : No significant interaction.

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ logConditionC * replayPartC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : No significant interaction.

%% Regressions - Log condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ logConditionC + replayPartC + (1|animal) + (1|cell:animal)");
disp(lme)
disp("Eta2 = " + getEta2(lme, data.refinCM))

grpstats(data, "condition", "mean", "DataVars", ["refinCM"])

grpstats(data, "condition", "std", "DataVars", ["refinCM"])


% RESULTS : Significant effect of condition, no effect of replay.

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ logConditionC + replayPartC + (1|animal) + (1|cell:animal)");
disp(lme)
disp("Eta2 = " + getEta2(lme, data.refinFR))


% RESULTS : Significant effect of condition (.03), no effect of replay.

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ logConditionC + replayPartC + (1|animal) + (1|cell:animal)");
disp(lme)
disp("Eta2 = " + getEta2(lme, data.refinPeak))

% RESULTS : Effect of condition. No effect of replay.
%% Regressions - Non logged condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ conditionC + replayPartC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : Condition is still significant, no effect of replay

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ conditionC + replayPartC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : NS

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ conditionC + replayPartC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : Condition is still significant, replay NS.


%% Effect of condition and the RELATIVE quantity of replay ----------------
% (replay participation / total number of replay)

%% Regressions - Interactions & log condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ logConditionC * propPartRepC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : No sig interaction, effect of condition.

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ logConditionC * propPartRepC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : No significant interaction.

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ logConditionC * propPartRepC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : No significant interaction.

%% Regressions - Log condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ logConditionC + propPartRepC + (1|animal) + (1|cell:animal)");
disp(lme)

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ logConditionC + propPartRepC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : Significant effect of condition, no effect of replay.

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ logConditionC + propPartRepC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : Effect of condition. No effect of replay.

%% Regressions - Non-logged condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ conditionC + propPartRepC + (1|animal) + (1|cell:animal)");
disp(lme)

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ conditionC + propPartRepC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : Significant effect of condition, no effect of replay.

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ conditionC + propPartRepC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : Effect of condition. No effect of replay.


%% Effect of condition and the ABSOLUTE quantity of SWR -------------------

%% Interaction - Log condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ logConditionC * partSWRC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : No significant interaction.

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ logConditionC * partSWRC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : No significant interaction.

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ logConditionC * partSWRC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : No significant interaction.

%% No interaction - log condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ logConditionC + partSWRC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : No effect of SWR participation.

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ logConditionC + partSWRC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : No effect of SWR participation.

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ logConditionC + partSWRC + (1|animal) + (1|cell:animal)");
disp(lme)

% RESULTS : No effect of SWR participation.

%% Effect of condition and the relative amount of exp / re-exp replay

lme = fitlme(data, "expReexpBiasC ~ logConditionC + (1|animal) + (1|cell:animal)");
disp(lme)

lme = fitlme(data, "refinCM ~ expReexpBiasC + (1|animal) + (1|cell:animal)");
disp(lme)

% No effect of exp / re-exp on CM (tendential)

lme = fitlme(data, "refinFR ~ expReexpBiasC + (1|animal) + (1|cell:animal)");
disp(lme)

% No effect of exp / re-exp on FR

lme = fitlme(data, "refinPeak ~ expReexpBiasC + (1|animal) + (1|cell:animal)");
disp(lme)

% Significant effect on peak (p = .02) - not when common events are removed