% Script to find at which value a cell can be considered unstable
% between N-1 and N of Lap1 / lap 1 and 2 of RUN2

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

% Load the cell data
load(PATH.SCRIPT + "/../../Data/extracted_activity_mat_lap.mat");

% Define the comparaison of interest

trackOI = 2; % One or two

conditionOI = "16x2";

targetQuart = 5;

activity_mat_laps = activity_mat_laps(string({activity_mat_laps.condition}) == conditionOI);

allCMNEndM1Run1 = [];
allCMNEndRun1 = [];

allCML1Run2 = [];
allCML2Run2 = [];

participationReplayPOST1 = [];

for i = trackOI:4:length(activity_mat_laps)
    lineRUN1 = activity_mat_laps(i);
    lineRUN2 = activity_mat_laps(i+2);
    
    allCMNEndM1Run1 = [allCMNEndM1Run1, lineRUN1.allLaps(end-1).cellsData.pfCenterMass];
    allCMNEndRun1 = [allCMNEndRun1, lineRUN1.allLaps(end).cellsData.pfCenterMass];
    
    allCML1Run2 = [allCML1Run2, lineRUN2.allLaps(1).cellsData.pfCenterMass];
    allCML2Run2 = [allCML2Run2, lineRUN2.allLaps(2).cellsData.pfCenterMass];
    
    participationReplayPOST1 = [participationReplayPOST1 lineRUN1.cellsReplayData.partPOST1];
end

%% Test of End - End-1 threshold for RUN1


% 1000 permutations of lap N CM

allShuffledMeans = [];

for i = 1:1000
    allCMNEndRun1Shuffled = allCMNEndRun1;
    allCMNEndM1Run1Shuffled = allCMNEndM1Run1;
    
    allCMNEndRun1Shuffled = allCMNEndRun1Shuffled(randperm(length(allCMNEndRun1Shuffled)));
    allCMNEndM1Run1Shuffled = allCMNEndM1Run1Shuffled(randperm(length(allCMNEndM1Run1Shuffled)));
    
    deltaCM = abs(allCMNEndRun1Shuffled - allCMNEndM1Run1Shuffled);
    allShuffledMeans = [allShuffledMeans, deltaCM];
    
end

% We get the 95% quantile
threshRUN1 = prctile(allShuffledMeans, 100 - targetQuart);

%% Test of L2 - L1 threshold for RUN2

% We want to find the threshold to be considered stable - CM variations
% less than 5% of observations found in random

% 1000 permutations of lap 2 CM

allShuffledMeans = [];

for i = 1:1000
    allCML2Run2Shuffled = allCML2Run2;
    allCML1Run2Shuffled = allCML1Run2;
    allCML1Run2Shuffled = allCML1Run2Shuffled(randperm(length(allCML1Run2Shuffled)));
    deltaCM = abs(allCML2Run2Shuffled - allCML1Run2Shuffled);
    allShuffledMeans = [allShuffledMeans, deltaCM];
    
end

% We get the 5% quantile
threshRUN2 = prctile(allShuffledMeans, targetQuart);

%% CLUSTERING OF THE CELLS

deltaCMRUN1 = abs(allCMNEndRun1 - allCMNEndM1Run1);
isSignUnstableRUN1 = deltaCMRUN1 >= threshRUN1;

deltaCMRUN2 = abs(allCML2Run2 - allCML1Run2);
isSignStableRUN2 = deltaCMRUN2 <= threshRUN2;

% We get the deltaCMRUN2 of matching cells (switcher) and non matching
% cells

matchingCMRUN2 = deltaCMRUN2(isSignUnstableRUN1 & isSignStableRUN2);
matchingPOST1Part = participationReplayPOST1(isSignUnstableRUN1 & isSignStableRUN2);

notMatchingCMRUN2 = deltaCMRUN2(~(isSignUnstableRUN1 & isSignStableRUN2));
notMatchingPOST1Part = participationReplayPOST1(~(isSignUnstableRUN1 & isSignStableRUN2));

scatter(matchingCMRUN2, matchingPOST1Part, "r");
corr = corrcoef(matchingCMRUN2, matchingPOST1Part, 'rows','complete');
corr = corr(2, 1);
disp(corr);
hold on;

scatter(notMatchingCMRUN2, notMatchingPOST1Part, "b");
corr = corrcoef(notMatchingCMRUN2, notMatchingPOST1Part, 'rows','complete');
corr = corr(2, 1);
disp(corr);