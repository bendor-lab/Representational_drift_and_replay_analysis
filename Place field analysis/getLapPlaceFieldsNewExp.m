% Help function to get the lap / directional place fields, in Z:/ 
clear
sessions = data_folders_deprivation;

addpath("Extract place fields", "Place field comparison", "Extract laps");

for fID = 2:numel(sessions)
    
    file = sessions{fID};
    cd(file)
    
    % If non existent, we get the mean waveforms
    getWaveformsFromSamples();
    
    % We need to get the laps
    % 0 cause we don't want plots
    extract_laps(0);
    
    % We can run the function
    extract_place_field_lap(0); % We set the bayesian option to 0, to have 2 cm bins

end