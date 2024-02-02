% Script to compute the place fields for each lap in the new repository
% Pierre Varichon - 2024

% Uses the extract_place_field_lap function, which needs all the Extract
% place fields" and "Place field comparison" folder to be in the path

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

addpath("Extract place fields", "Place field comparison");

% We get the list of session folder

path2Data = PATH.SCRIPT + "\..\ExpData\";

allFolders = string(ls(path2Data + "*_*")); % We look for all the directoris with right name

% We iterate through folders

parfor direcInd = 11:19
    direc = allFolders(direcInd);
    disp(direc);
    
    % We go into that folder
    cd(path2Data + direc);
    
    % We can run the function
    extract_place_field_lap(0); % We set the bayesian option to 0, to have 2 cm bins
    
end
