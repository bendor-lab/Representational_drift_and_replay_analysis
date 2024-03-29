% Script to generate the data used for the statistical tests.

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl_legacy; % We fetch all the sessions folders paths

animal = [];
condition = [];
track = [];
cell = [];

refinCM = [];
refinFR = [];
refinPeak = [];

meanPhase = [];
label = [];

%% Extraction & computation

for fileID = 1:length(sessions)

    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);

    conditionT2 = split(conditionOI, 'x');
    conditionT2 = str2double(conditionT2{2});
    
    conditionOI = string(conditionOI);

    ident = fileID * 1000; % We get the identifier for the session

    %% We load the files we need

    CSC = load(file + "\extracted_CSC");
    CSC = CSC.CSC;
    disp("Loaded CSC");

    sleep_state = load(file + "\extracted_sleep_state");
    sleep_state = sleep_state.sleep_state;

    decoded_replay_events = load(file + "\decoded_replay_events");
    decoded_replay_events = decoded_replay_events.decoded_replay_events;

    place_fields = load(file + "\extracted_place_fields");
    place_fields = place_fields.place_fields;

    data = load("D:\Representational_drift_and_replay_analysis\Pierre\Analysis\Cell Level\Statistical_Tests\dataRegression.mat");
    data = data.data;


    %% We get the phase matrix for each cell

    [resultMat, meanPhaseVector, allCells] = extract_phase(CSC, sleep_state, decoded_replay_events);

    % Now we can z-score the resultMat
    resultMatZ = normalize(resultMat, 2, "zscore");

    for trackOI = 1:2

        %% We find the label of the cell (appearing, disappearing, stable)

        pcExp = place_fields.track(trackOI).good_cells;
        pcReexp = place_fields.track(trackOI + 2).good_cells;

        isPCExp = ismember(allCells, pcExp);
        isPCReexp = ismember(allCells, pcReexp);

        labels = repelem("Unstable", numel(meanPhaseVector));

        labels(isPCExp & isPCReexp) = "Stable";
        labels(isPCExp & ~isPCReexp) = "Disappear";
        labels(~isPCExp & isPCReexp) = "Appears";

        allLabels = unique(labels);

        %% Retrieve refinement information

        if trackOI == 1
            matching_data = data(floor(data.cell/1000) == fileID & data.condition == 16, :);
        else
            matching_data = data(floor(data.cell/1000) == fileID & data.condition == conditionT2, :);
        end

        % We remove the unique identifier for each session
        unique_cells_refin = matching_data.cell - ident;

        common_cells = intersect(allCells, unique_cells_refin);

        current_refinCM = matching_data.refinCM(ismember(unique_cells_refin, common_cells));
        current_refinPeak = matching_data.refinPeak(ismember(unique_cells_refin, common_cells));
        current_refinFR = matching_data.refinFR(ismember(unique_cells_refin, common_cells));

        meanPhaseVectorFilt = meanPhaseVector(ismember(allCells, common_cells));
        labelsFilt = labels(ismember(allCells, common_cells));

        % We save the data

        animal = [animal; repelem(animalOI, numel(common_cells))'];
        condition = [condition; repelem(conditionOI, numel(common_cells))'];
        track = [track; repelem(trackOI, numel(common_cells))'];
        cell = [cell; common_cells];
        
        refinCM = [refinCM; current_refinCM];
        refinFR = [refinFR; current_refinFR];
        refinPeak = [refinPeak; current_refinPeak];
        
        meanPhase = [meanPhase; meanPhaseVectorFilt'];
        label = [label; labelsFilt'];

    end
end

% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

phase_data = table(animal, condition, track, cell, refinCM, refinFR, refinPeak, meanPhase, label);