% Script to generate the data used for the statistical tests - sig SWR

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions_leg = data_folders_excl_legacy; % We fetch all the sessions folders paths
sessions = data_folders_excl;

sessionID = [];
animal = [];
condition = [];
track = [];
cell = [];

refinCM = [];
refinFR = [];
refinPeak = [];

meanPhase = [];
phaseLocking = [];
significance = [];
label = [];

allTuningMat.sessionID = {};
allTuningMat.animal = {};
allTuningMat.condition = {};
allTuningMat.tuningMat = {};

%% Extraction & computation

for fileID = 1:length(sessions)

    disp(fileID);
    file = sessions{fileID}; % We get the current session
    file_leg = sessions_leg{fileID};
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);

    conditionT2 = split(conditionOI, 'x');
    conditionT2 = str2double(conditionT2{2});

    conditionOI = string(conditionOI);

    ident = fileID * 1000; % We get the identifier for the session

    %% We load the files we need

    CSC = load(file_leg + "\extracted_CSC");
    CSC = CSC.CSC;
    disp("Loaded CSC");

    sleep_state = load(file + "\extracted_sleep_state");
    sleep_state = sleep_state.sleep_state;

    decoded_replay_events = load(file + "\Replay\RUN1_Decoding\decoded_replay_events");
    decoded_replay_events = decoded_replay_events.decoded_replay_events;

    significant_replay_events = load(file + "\Replay\RUN1_Decoding\significant_replay_events_wcorr");
    significant_replay_events = significant_replay_events.significant_replay_events;

    place_fields = load(file + "\extracted_place_fields");
    place_fields = place_fields.place_fields;

    % data = load("C:\Users\pierre.varichon\Documents\Representational_drift_and_replay_analysis\Pierre\Analysis\Cell Level\Statistical_Tests\dataRegression.mat");
    data = load("../Statistical_Tests/dataRegression.mat");
    data = data.data;


    %% We get the phase matrix for each cell

    for trackOI = 1:2
        
        struct2add = struct;

        [resultMat, meanPhaseVector, current_phaseLocking, sig, allCells] = extract_phase_NSIG(CSC, sleep_state, decoded_replay_events, significant_replay_events, trackOI);

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
        current_phaseLockingFilt = current_phaseLocking(ismember(allCells, common_cells));
        sigFilt = sig(ismember(allCells, common_cells));

        % We save the data

        sessionID = [sessionID; repelem(fileID, numel(common_cells))'];
        animal = [animal; repelem(animalOI, numel(common_cells))'];
        condition = [condition; repelem(conditionOI, numel(common_cells))'];
        track = [track; repelem(trackOI, numel(common_cells))'];
        cell = [cell; common_cells];

        refinCM = [refinCM; current_refinCM];
        refinFR = [refinFR; current_refinFR];
        refinPeak = [refinPeak; current_refinPeak];

        meanPhase = [meanPhase; meanPhaseVectorFilt'];
        phaseLocking = [phaseLocking; current_phaseLockingFilt'];
        significance = [significance; sigFilt'];

        label = [label; labelsFilt'];

        if trackOI == 1
            
            struct2add.sessionID = fileID;
            struct2add.animal = animalOI;
            struct2add.condition = 16;
            struct2add.tuningMat = {resultMat};
            
            allTuningMat = [allTuningMat; struct2add];
        else
            condition2add = split(conditionOI, 'x');
            condition2add = str2double(condition2add(end));
            
            struct2add.sessionID = fileID;
            struct2add.animal = animalOI;
            struct2add.condition = condition2add;
            struct2add.tuningMat = {resultMat};
            
            allTuningMat = [allTuningMat; struct2add];
        end

    end
end

% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

phase_data = table(sessionID, animal, condition, track, cell, refinCM, refinFR, refinPeak, meanPhase, phaseLocking, significance, label);

save("phase_data_NSIG.mat", "phase_data");
% save("tuning_curves_sig", "allTuningMat");