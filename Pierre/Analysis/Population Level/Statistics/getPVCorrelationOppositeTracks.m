% Generate a table with animal, condition, stability at the end of RUN1,
% PV-correlation with the FPF and replay participation.

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths

% Arrays to hold all the data

sessionID = [];
animal = [];
condition = [];

corCrossTrackRUN1 = [];
corCrossTrackRUN2 = [];

parfor fileID = 1:length(sessions)

    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string

    % Load the variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;


    goodCells = union(place_fields.track(1).good_cells, place_fields.track(3).good_cells);

    % goodCells = intersect(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);

    goodCellsOther = union(place_fields.track(2).good_cells, place_fields.track(2 + 2).good_cells);

    goodCellsCross = union(goodCells, goodCellsOther);

    RUN1LapPFData = lap_place_fields(1).Complete_Lap;
    RUN2LapPFData = lap_place_fields(1 + 2).Complete_Lap;

    RUN1LapPFDataOther = lap_place_fields(2).Complete_Lap;
    RUN2LapPFDataOther = lap_place_fields(2 + 2).Complete_Lap;

    % We can now find the PV correlation of the last lap RUN1 and first
    % lap RUN2 with the FPF

    pvCorRUN1 = getPVCor(goodCellsCross, RUN1LapPFData{end}.smooth, RUN1LapPFDataOther{end}.smooth, "pvCorrelation");
    pvCorRUN1 = median(pvCorRUN1, 'omitnan');

    pvCorRUN2 = getPVCor(goodCellsCross, RUN2LapPFData{end}.smooth, RUN2LapPFDataOther{end}.smooth, "pvCorrelation");
    pvCorRUN2 = median(pvCorRUN2, 'omitnan');

    % Save the data

    sessionID = [sessionID; fileID];
    animal = [animal; animalOI];
    condition = [condition; conditionOI];
    corCrossTrackRUN1 = [corCrossTrackRUN1; pvCorRUN1];
    corCrossTrackRUN2 = [corCrossTrackRUN2; pvCorRUN2];

end

data = table(sessionID, animal, condition, corCrossTrackRUN1, corCrossTrackRUN2);

save("dataCrossCorrelationControl.mat", "data")

%% 

disp("Mean PF correlation across tracks RUN1 : " + mean(data.corCrossTrackRUN1) + ...
      ", STD = " + std(data.corCrossTrackRUN1));

disp("Mean PF correlation across tracks RUN2 : " + mean(data.corCrossTrackRUN2) + ...
      ", STD = " + std(data.corCrossTrackRUN2))
