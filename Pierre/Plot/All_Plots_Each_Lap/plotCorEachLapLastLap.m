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
    for track = 1:4

        % We create a variable to keep track of if the current track is
        % an exposition or a re-exposition

        expSession = 1 * (track > 2) + 1;

        %% Defining the current and concurrent PF data
        if mode == "LAST"
            currentPFData = lap_place_fields(track).Complete_Lap;
            concurrentPFData = lap_place_fields(track + expSession).Complete_Lap;
        
        % If mode == "FIRST", we use the same data for current and concurrent
        elseif mode == "FIRST"
            currentPFData = lap_place_fields(track).Complete_Lap;
            concurrentPFData = currentPFData;
        
        % If mode == "ALL", we use global place field computed on all of track 3/4
        elseif mode == "ALL"
            currentPFData = lap_place_fields(track).Complete_Lap;
            load(file + "\extracted_place_fields");
            concurrentPFData = place_fields.track(track + expSession);
        
        % If mode == "NEXT", we use half laps for all the analysis
        elseif mode == "NEXT"
            currentPFData = lap_place_fields(track).half_Lap;
            concurrentPFData = lap_place_fields(track).half_Lap;
        end

        % We define a correlation vector accross each lap
        corr_vector = repelem(0, length(currentPFData));

        % We iterate through the laps

        for lap = 1:length(currentPFData)

            currentPFCellArray = currentPFData{lap}.raw;
            concurrentCellArray = concurrentPFData{lap}.raw;

            % We find all the cells that are good place cells in track 2

            goodCells = concurrentPFData{lap}.good_cells;

            pvCorrelationVector = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, mode);
        end
    end

end

%% Function to compute the population vector correlation

function [pvCorrelationVector] = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, mode)

    % Subsample the cell arrays based on the good cells
    currentPFCellArray = currentPFCellArray(goodCells);
    concurrentCellArray = concurrentCellArray(goodCells);
    
    % Depending on MODE, we define a concurrentVector
    if mode == "LAST"
        concurrentVector = concurrentCellArray(end).raw;
    elseif mode == "FIRST"
        concurrentVector = concurrentCellArray(1).raw;
    elseif mode == "ALL"
        concurrentVector = concurrentCellArray.raw;
    end
    
    % If mode == "NEXT", we use another way

    if mode ~= "NEXT" % For all modes except NEXT

        % Compute the correlation for each pair of cells
        correlationCoefficients = cellfun(@(x) corrcoef(x, concurrentVector), currentPFCellArray, 'UniformOutput', false);

    else % For NEXT - return correlation vector length is -1 (last half-lap excluded)

        % We offset concurrentCellArray by 1 - 2 -> End
        concurrentCellArray(1) = [];
        % We offset currentPFCellArray by 1 - 1 -> End - 1
        currentPFCellArray(end) = [];

        correlationCoefficients = cellfun(@(x, y) corrcoef(x, y), currentPFCellArray, concurrentCellArray, 'UniformOutput', false);

    end

    % Extract the correlation coefficients and returns it
    pvCorrelationVector = cellfun(@(x) x(2), correlationCoefficients);


end