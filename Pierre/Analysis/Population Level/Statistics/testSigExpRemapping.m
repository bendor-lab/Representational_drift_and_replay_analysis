clear 

data = load("timeSeriesStable.mat");
data = data.data;

data.logConditionC = log2(data.condition) - mean(log2(data.condition));
data.lapC = data.lap - mean(data.lap);

dataRUN1 = data(data.exposure == 1, :);
dataRUN2 = data(data.exposure == 2, :);

dataDir = load("timeSeriesDirectionalityStable.mat");
dataDir = dataDir.data;
dataDir.logConditionC = log2(data.condition) - mean(log2(data.condition));
dataDir.lapC = data.lap - mean(data.lap);

.....................................................................................................................................................................................................................................................................
dataDirRUN1 = dataDir(dataDir.exposure == 1, :);
dataDirRUN2 = dataDir(dataDir.exposure == 2, :);

%% PV - Correlation


lme = fitlme(dataRUN1, "pvCorr ~ lapC * logConditionC + (1|animal) + (1|sessionID:animal)");
disp(lme);

lmeR = fitlme(dataRUN1, "pvCorr ~ logConditionC + (1|animal) + (1|sessionID:animal)");
disp("R2 : " + (lme.SSR - lmeR.SSR)/lme.SST)

lme = fitlme(dataRUN2, "pvCorr ~ lap * logConditionC + (1|animal) + (1|sessionID:animal)");
disp(lme)

lmeR = fitlme(dataRUN2, "pvCorr ~ logConditionC + (1|animal) + (1|sessionID:animal)");
disp("R2 : " + (lme.SSR - lmeR.SSR)/lme.SST)

%% Directionnality


lme = fitlme(dataDirRUN1, "pvCorr ~ lapC * logConditionC + (1|animal) + (1|sessionID:animal)");
disp(lme);

lmeR = fitlme(dataDirRUN1, "pvCorr ~ logConditionC + (1|animal) + (1|sessionID:animal)");
disp("R2 : " + (lme.SSR - lmeR.SSR)/lme.SST)



lme = fitlme(dataDirRUN2, "pvCorr ~ lap * logConditionC + (1|animal) + (1|sessionID:animal)");
disp(lme)

lmeR = fitlme(dataDirRUN2, "pvCorr ~ logConditionC + (1|animal) + (1|sessionID:animal)");
disp("R2 : " + (lme.SSR - lmeR.SSR)/lme.SST)
