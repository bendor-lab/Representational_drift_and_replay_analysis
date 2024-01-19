sessions = data_folders_excl; % Use the function to get all the file paths

finalData = struct("condition", {}, "session", {}, "lap", {}, "PV_cor", {});

% Mode of calculation : 
% "LAST" : last lap re-exposure
% "FIRST" : first lap exposure
% "ALL" : all laps re-exposure
% "NEXT" : next lap

mode = "NEXT";

% We iterate through all the sessions

for cfile = sessions
    disp(cfile);
    file = cfile{1};

    [animalOI, conditionOI, dayOI] = parseNameFile(file); % We get the informations about the current data

    % We load the place fields computed per lap for each animal - lap_place_fields
    load(file + "\extracted_lap_place_fields");

    % We iterate through tracks
    for track = 1:2
        % If mode == "NEXT", we use half laps for all the analysis
        if mode == "NEXT"
            currentPFData = lap_place_fields(track).half_Lap;
            concurrentPFData = lap_place_fields(track + 2).half_Lap;
        end
    end

end

function [pvCorrelationVector] = getPVCor(pfData1, pfData2)
end