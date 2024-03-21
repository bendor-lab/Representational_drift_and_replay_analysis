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

data = load("dataRegressionXor.mat");
data = data.data;

data.logConditionC = log2(data.condition) - mean(log2(data.condition));
data.conditionC = data.condition - mean(data.condition);
data.replayPartC = data.partP1Rep - mean(data.partP1Rep, "omitnan");
data.propPartRepC = data.propPartRep - mean(data.propPartRep);

%% Effect of condition and the ABSOLUTE quantity of replay

%% Regressions - Interactions & log condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ logConditionC * replayPartC + (1|animal)");
disp(lme)

% RESULTS : No significant interaction.

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ logConditionC * replayPartC + (1|animal)");
disp(lme)

% RESULTS : No significant interaction.

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ logConditionC * replayPartC + (1|animal)");
disp(lme)

% RESULTS : No significant interaction.

%% Regressions - Log condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ logConditionC + replayPartC + (1|animal)");
disp(lme)

% RESULTS : Significant effect of condition, no effect of replay.

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ logConditionC + replayPartC + (1|animal)");
disp(lme)

% RESULTS : Significant effect of condition (.03), no effect of replay.

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ logConditionC + replayPartC + (1|animal)");
disp(lme)

% RESULTS : Effect of condition. No effect of replay.
%% Regressions - Non logged condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ conditionC + replayPartC + (1|animal)");
disp(lme)

% RESULTS : Condition is still significant, no effect of replay

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ conditionC + replayPartC + (1|animal)");
disp(lme)

% RESULTS : NS

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ conditionC + replayPartC + (1|animal)");
disp(lme)

% RESULTS : Condition is still significant, replay NS.

%% Regressions - Interaction, Log Condition & animal-wise
% Here, we take the mean of our metrics for each animal and condition
summaryData = groupsummary(data, ["animal", "condition"], "median", ["partP1Rep", "refinCM", "refinFR", "refinPeak", "propPartRep"]);
summaryData.logConditionC = log2(summaryData.condition) - mean(log2(summaryData.condition));
summaryData.conditionC = summaryData.condition - mean(summaryData.condition);
summaryData.replayPartC = summaryData.median_partP1Rep - mean(summaryData.median_partP1Rep, "omitnan");
summaryData.propPartRepC = summaryData.median_propPartRep - mean(summaryData.median_propPartRep, "omitnan");


% Center of mass refinement
lme = fitlme(summaryData, "median_refinCM ~ logConditionC * replayPartC + (1|animal)");
disp(lme)

% RESULTS : No significant interaction.

% Max firing rate refinement
lme = fitlme(summaryData, "median_refinFR ~ logConditionC * replayPartC + (1|animal)");
disp(lme)

% RESULTS : No significant interaction.

% Peak firing rate 
lme = fitlme(summaryData, "median_refinPeak ~ logConditionC * replayPartC + (1|animal)");
disp(lme)

% RESULTS : No significant interaction

%% Regressions - Log Condition & animal-wise

% Center of mass refinement
lme = fitlme(summaryData, "median_refinCM ~ logConditionC + replayPartC + (1|animal)");
disp(lme)

% RESULTS : Condition is significant, not replay.

% Max firing rate refinement
lme = fitlme(summaryData, "median_refinFR ~ logConditionC + replayPartC + (1|animal)");
disp(lme)

% RESULTS : Nothing is significant

% Peak firing rate 
lme = fitlme(summaryData, "median_refinPeak ~ logConditionC + replayPartC + (1|animal)");
disp(lme)

% RESULTS : Condition is not significant anymore, replay N.S

%% Regressions - Condition non logged & animal-wise

% Center of mass refinement
lme = fitlme(summaryData, "median_refinCM ~ conditionC + replayPartC + (1|animal)");
disp(lme)

% RESULTS : Condition not significant

% Max firing rate refinement
lme = fitlme(summaryData, "median_refinFR ~ conditionC + replayPartC + (1|animal)");
disp(lme)

% Same as with logged condition.

% Peak firing rate 
lme = fitlme(summaryData, "median_refinPeak ~ conditionC + replayPartC + (1|animal)");
disp(lme)

% Replay NS, condition is still non-significant.


%% Effect of condition and the RELATIVE quantity of replay
% (replay participation / total number of replay)

%% Regressions - Interactions & log condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ logConditionC * propPartRepC + (1|animal)");
disp(lme)

% RESULTS : No sig interaction, effect of condition.

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ logConditionC * propPartRepC + (1|animal)");
disp(lme)

% RESULTS : No significant interaction.

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ logConditionC * propPartRepC + (1|animal)");
disp(lme)

% RESULTS : No significant interaction.

%% Regressions - Log condition

% Center of mass refinement
lme = fitlme(data, "refinCM ~ logConditionC + propPartRepC + (1|animal)");
disp(lme)

% Max firing rate refinement
lme = fitlme(data, "refinFR ~ logConditionC + propPartRepC + (1|animal)");
disp(lme)

% RESULTS : Significant effect of condition, no effect of replay.

% Peak firing rate 
lme = fitlme(data, "refinPeak ~ logConditionC + propPartRepC + (1|animal)");
disp(lme)

% RESULTS : Effect of condition. No effect of replay.



