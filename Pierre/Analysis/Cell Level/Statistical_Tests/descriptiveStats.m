% Generate descriptive data (number of sessions, number of cells)

sessions = data_folders_excl; % We fetch all the sessions folders paths

animal = [];
condition = [];
track = [];

numberCells = [];
numberGoodCells = []; % Number of common good cells between RUN1 and RUN2
numberLapsRUN1 = [];
numberLapsRUN2 = [];

for fileID = 1:length(sessions)

    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string

    % Load the variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_laps.mat");
    lap_times = temp.lap_times;

    % Track loop

    for trackOI = 1:2

        % Good cells : Cells that where good place cells during RUN1 / RUN2
        goodCells = union(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);

        % VERIFICATIONS :

        % 2. If number of half lap is odd, we remove one and we
        % cut the data we just registered

        nbHalfLapsRUN1 = numel(lap_times(trackOI).halfLaps_start);
        nbHalfLapsRUN2 = numel(lap_times(trackOI + 2).halfLaps_start);

        nbHalfLapsRUN1 = nbHalfLapsRUN1 - mod(nbHalfLapsRUN1, 2);
        nbHalfLapsRUN2 = nbHalfLapsRUN2 - mod(nbHalfLapsRUN2, 2);
        
        current_numberLapsRUN1 = nbHalfLapsRUN1/2;
        current_numberLapsRUN2 = nbHalfLapsRUN2/2;

        % Save the data

        animal = [animal; animalOI];
        condition = [condition; conditionOI];
        track = [track; trackOI];
        numberCells = [numberCells; numel(place_fields.mean_rate)];
        numberGoodCells = [numberGoodCells; numel(goodCells)];
        numberLapsRUN1 = [numberLapsRUN1; current_numberLapsRUN1];
        numberLapsRUN2 = [numberLapsRUN2; current_numberLapsRUN2];

    end
end

data = table(animal, condition, track, numberCells, numberGoodCells, numberLapsRUN1, numberLapsRUN2);

%% Animal x Condition / Track - number of laps / Number of cells

fig = uifigure;
uit = uitable(fig,"Data", data);
uit.ColumnName = ["Animal", "Condition", "Track", "nb-cells", "nb-place-cells", "nb-laps-RUN1", "nb-laps-RUN2"];
uit.Position = [20 20 1000 500];
s = uistyle('HorizontalAlignment','center');
addStyle(uit,s,'table','');