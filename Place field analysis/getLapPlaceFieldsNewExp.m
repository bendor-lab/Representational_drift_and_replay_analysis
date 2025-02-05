% Help function to get the lap / directional place fields, in Z:/ 
clear
sessions = data_folders_deprivation;
has_data = [1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0];
has_data = logical(has_data);
sessions = sessions(has_data);

addpath("Extract place fields", "Place field comparison", "Extract laps", ...
        "../Extract spikes, waveforms and dropped samples", "../Added code");

for fID = 1:numel(sessions)
    
    file = sessions{fID};
    cd(file)
    
    % If non existent, we get the mean waveforms
    % For now, we need to change
    % line 50 with the correct folder name
    
    getWaveformsFromSamples();
    
    % We need to get the laps
    % 0 cause we don't want plots
    extract_laps(0, true);
    
    % We can run the function
    extract_place_field_lap(0); % We set the bayesian option to 0, to have 2 cm bins

end