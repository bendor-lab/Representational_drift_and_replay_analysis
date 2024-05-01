% File to generate the metric data over laps

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths

% We create identifiers for cells from each session.
% Format is : IDENT-00-XXX
identifiers = 1:numel(sessions);
identifiers = identifiers* 1000;

% Arrays to hold all the data

animal = [];
condition = [];
track = [];
exposure = [];
lap = [];
cell = [];
label = [];
CMdiff = [];
FRdiff = [];
PeakDiff = [];
meanFR = [];

% We take the absolute value of the difference over sum to get the relative
% distance with the FPF, independently of the direction
diffSum = @(x1, x2) abs(x1 - x2)/(x1 + x2);

%% Extraction & computation

for fileID = 16:16 %length(sessions)

    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    ident = identifiers(fileID); % We get the identifier for the session

    % Load the variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_lap_place_fields.mat");
    %temp = load(file + "\extracted_directional_lap_place_fields");
    lap_place_fields = temp.lap_place_fields;

    % Track loop

    for trackOI = 1:2

        goodPCRUN1 = lap_place_fields(trackOI).Complete_Lap{end}.good_cells;
        goodPCRUN2 = lap_place_fields(trackOI + 2).Complete_Lap{1}.good_cells;

        other_track = mod(trackOI + 1, 2) + mod(trackOI, 2)*2;

        goodPCRUN1Other = lap_place_fields(other_track).Complete_Lap{end}.good_cells;
        goodPCRUN2Other = lap_place_fields(other_track + 2).Complete_Lap{1}.good_cells;

        % Good cells : Cells that where good place cells during RUN1 or RUN2
        goodCells = union(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);

        isGoodPCRUN1 = ismember(goodCells, goodPCRUN1);
        isGoodPCRUN2 = ismember(goodCells, goodPCRUN2);
        isGoodPCRUN1Other = ismember(goodCells, goodPCRUN1Other);
        isGoodPCRUN2Other = ismember(goodCells, goodPCRUN2Other);

        current_label = repelem("Unstable", 1, numel(goodCells));
        current_label(isGoodPCRUN1 & isGoodPCRUN2)= "Stable";
        current_label(isGoodPCRUN1 & ~isGoodPCRUN2 & isGoodPCRUN2Other)= "Disappear";
        current_label(~isGoodPCRUN1 & isGoodPCRUN2 & isGoodPCRUN1Other)= "Appear";
        
        targetCells = goodCells(current_label == "Appear");

        for tID = 1:5 %numel(targetCells)
            current_cell = targetCells(tID);
            placeFieldRUN1 = place_fields.track(trackOI).smooth{current_cell};
            placeFieldRUN1LapEnd = lap_place_fields(trackOI).Complete_Lap{end}.smooth{current_cell};

            placeFieldRUN2Lap1 = lap_place_fields(trackOI + 2).Complete_Lap{2}.smooth{current_cell};
            placeFieldRUN2 = place_fields.track(trackOI + 2).smooth{current_cell};
            figure;
            tiledlayout(1, 4);
            
            nexttile;
            bar(placeFieldRUN1);
            title("C" + current_cell + " - RUN1 Track " + trackOI);
            nexttile;
            bar(placeFieldRUN1LapEnd);
            title("C" + current_cell + " - RUN1 Lap End Track " + trackOI);
            nexttile;
            bar(placeFieldRUN2Lap1);
            title("C" + current_cell + " - RUN2 Lap 1 Track " + trackOI);
            nexttile;
            bar(placeFieldRUN2);
            title("C" + current_cell + " - RUN2 Track " + trackOI);

            linkaxes;

        end
    end
end

