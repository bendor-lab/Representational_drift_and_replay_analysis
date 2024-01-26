% Script that plot the CM change N / N - 1 RUN1 
% against the width of place fields

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

% Load the cell data
load(PATH.SCRIPT + "/../../Data/extracted_activity_mat_lap.mat");
sessions = data_folders_excl; % Use the function to get all the file paths

% Define the comparaison of interest

trackOI = 1; % One or two

% conditionOI = "16x2";
% 
% activity_mat_laps = activity_mat_laps(string({activity_mat_laps.condition}) == conditionOI);

allCMNEndM1Run1 = [];
allCMNEndRun1 = [];

for i = trackOI:4:length(activity_mat_laps)
    
    disp(i);
    
    lineRUN1 = activity_mat_laps(i);
    animalOI = lineRUN1.animal;
    conditionOI = lineRUN1.condition;
    
    matchingFile = sessions(contains(cell2mat(sessions), animalOI) & contains(cell2mat(sessions), conditionOI));
    matchingFile = matchingFile{1};
    
    load(matchingFile + "\extracted_lap_place_fields");

    
    allCMNEndM1Run1 = [allCMNEndM1Run1, lineRUN1.allLaps(end-1).cellsData.pfCenterMass];
    allCMNEndRun1 = [allCMNEndRun1, lineRUN1.allLaps(end).cellsData.pfCenterMass];
    
    % We get the PF width of each neuron
    
    currentPF = lap_place_fields(trackOI).Complete_Lap{end};
    
    % We only take the good cells on the track
    
    widthPFVector = getWidthPlaceField(currentPF);
    
    
    
    
end