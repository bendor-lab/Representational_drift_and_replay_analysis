% Same analysis than in metricRegressions, but for directionnality

clear 

data = load("dataRegressionDirectionalityXor.mat");
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
