% Test the significativity of the experience remapping

clear 

data = load("timeSeries.mat");
data = data.data;

data.logConditionC = log2(data.condition) - mean(log2(data.condition));

dataRUN1 = data(data.exposure == 1, :);
dataRUN2 = data(data.exposure == 2, :);


%% CM

lme = fitlme(dataRUN1, "CMdiff ~ lap + (1|animal)");
disp(lme)

lme = fitlme(dataRUN2, "CMdiff ~ lap + (1|animal)");
disp(lme)

%% FR

lme = fitlme(dataRUN1, "FRdiff ~ lap + (1|animal)");
disp(lme)

lme = fitlme(dataRUN2, "FRdiff ~ lap + (1|animal)");
disp(lme)

%% Peak location

lme = fitlme(dataRUN1, "PeakDiff ~ lap + (1|animal)");
disp(lme)

lme = fitlme(dataRUN2, "PeakDiff ~ lap + (1|animal)");
disp(lme)
