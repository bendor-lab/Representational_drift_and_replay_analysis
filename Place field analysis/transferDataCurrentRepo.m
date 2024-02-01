% Script that tranfer the extracted data from Drobbo to the current repo

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

filesToExtract = ["extracted_laps.mat", 'extracted_clusters.mat', 'extracted_position.mat', ...
                  'extracted_waveforms.mat', "extracted_place_fields_BAYESIAN.mat", ...
                  "extracted_place_fields.mat", "extracted_directional_clusters.mat", ...
                  "extracted_directional_place_fields.mat"];
              
% For each good session
for cFile = sessions
    file = cFile{1};
    disp(file);
    
    [animalOI, conditionOI, ~] = parseNameFile(file); % We get the informations about the current data
    
    % If no dir, we create it
    
    dirName = PATH.SCRIPT + "/../ExpData/" + animalOI + "_" + conditionOI;

    if ~exist(dirName, 'dir')
      mkdir(dirName);
    end
    
    for variable = filesToExtract
        
        x = load(file + "/" + variable); % We get the variable
        field = fieldnames(x);
        field = field{1}; % We find its name
        x = x.(field); % we retrieve it
        eval([field '= x;']); % we asign it to its right name
        save(dirName + "/" + variable, field); % We save it
        
        clear x
        eval(['clear ' field]); % we clear the variables
        
    end
end