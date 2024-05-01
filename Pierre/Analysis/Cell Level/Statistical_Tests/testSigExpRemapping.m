% Test the significativity of the experience remapping

clear 

data = load("timeSeries.mat");
data = data.data;
data = data(data.label == "Stable", :);
data.logConditionC = log2(data.condition) - mean(log2(data.condition));
data.lapC = data.lap - mean(data.lap);
dataRUN1 = data(data.exposure == 1, :);
dataRUN2 = data(data.exposure == 2, :);


%% CM

lme = fitlme(dataRUN1, "CMdiff ~ lapC*logConditionC + (1|animal) + (1|cell:sessionID)");
disp(lme)

lme = fitlme(dataRUN2, "CMdiff ~ lapC*logConditionC + (1|animal) + (1|cell:sessionID)");
disp(lme)

%% FR

lme = fitlme(dataRUN1, "FRdiff ~ lapC*logConditionC + (1|animal) + (1|cell:sessionID)");
disp(lme)

lme = fitlme(dataRUN2, "FRdiff ~ lapC*logConditionC + (1|animal) + (1|cell:sessionID)");
disp(lme)

%% Peak location

lme = fitlme(dataRUN1, "PeakDiff ~ lapC*logConditionC + (1|animal) + (1|cell:sessionID)");
disp(lme)

lme = fitlme(dataRUN2, "PeakDiff ~ lapC*logConditionC + (1|animal) + (1|cell:sessionID)");
disp(lme)
