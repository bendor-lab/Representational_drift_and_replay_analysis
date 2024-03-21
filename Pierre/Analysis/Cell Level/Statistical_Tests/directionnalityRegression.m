% Same analysis than in metricRegressions, but for directionnality

clear 

data = load("dataRegressionDirectionality.mat");
data = data.data;

data.logConditionC = log2(data.condition) - mean(log2(data.condition));
data.conditionC = data.condition - mean(data.condition);
data.replayPartC = data.partP1Rep - mean(data.partP1Rep, "omitnan");
data.propPartRepC = data.propPartRep - mean(data.propPartRep);

%% Effect of the ABSOLUTE number of replay

%% Regressions - Interaction & Log Condition

lme = fitlme(data, "refinDir ~ logConditionC * replayPartC + (1|animal)");
disp(lme)

% No significant interaction

%% Regressions - Log condition

lme = fitlme(data, "refinDir ~ logConditionC + replayPartC + (1|animal)");
disp(lme)

%% Regressions - Non-logged conditon

lme = fitlme(data, "refinDir ~ conditionC + replayPartC + (1|animal)");
disp(lme)

%% Animal-wise, interaction

% Here, we take the mean of our metrics for each animal and condition
summaryData = groupsummary(data, ["animal", "condition"], "median", ["partP1Rep", "refinDir", "propPartRep"]);
summaryData.logConditionC = log2(summaryData.condition) - mean(log2(summaryData.condition));
summaryData.conditionC = summaryData.condition - mean(summaryData.condition);
summaryData.replayPartC = summaryData.median_partP1Rep - mean(summaryData.median_partP1Rep, "omitnan");
summaryData.propPartRepC = summaryData.median_propPartRep - mean(summaryData.median_propPartRep, "omitnan");

lme = fitlme(summaryData, "median_refinDir ~ logConditionC * replayPartC + (1|animal)");
disp(lme)

% No interaction

%% Animal-wise, no interaction

lme = fitlme(summaryData, "median_refinDir ~ logConditionC + replayPartC + (1|animal)");
disp(lme)

% Intercept, condition & replay N.S

%% Animal-wise, no interaction, non logged

lme = fitlme(summaryData, "median_refinDir ~ conditionC + replayPartC + (1|animal)");
disp(lme)

% Same results.

%% Effect of the RELATIVE amount of replay -------------------------------

%% Regressions - Interaction & Log Condition

lme = fitlme(data, "refinDir ~ logConditionC * propPartRepC + (1|animal)");
disp(lme)

% No significant interaction

%% Regressions - Log condition

lme = fitlme(data, "refinDir ~ logConditionC + propPartRepC + (1|animal)");
disp(lme)

%% Regressions - Non-logged conditon

lme = fitlme(data, "refinDir ~ conditionC + propPartRepC + (1|animal)");
disp(lme)

%% Animal-wise, interaction

lme = fitlme(summaryData, "median_refinDir ~ logConditionC * propPartRepC + (1|animal)");
disp(lme)

% No interaction

%% Animal-wise, no interaction

lme = fitlme(summaryData, "median_refinDir ~ logConditionC + propPartRepC + (1|animal)");
disp(lme)

% Intercept, condition & replay N.S

%% Animal-wise, no interaction, non logged

lme = fitlme(summaryData, "median_refinDir ~ conditionC + propPartRepC + (1|animal)");
disp(lme)

% Same results.

