% Generate descriptive data (number of sessions, number of cells)

sessions = data_folders_excl; % We fetch all the sessions folders paths

animal = [];
condition = [];
track = [];

numberCells = [];
numberGoodCellsRUN1 = [];
numberGoodCellsRUN2 = []; % Number of common good cells between RUN1 and RUN2
numberLapsRUN1 = [];
numberLapsRUN2 = [];
amountSleep = [];
numberCommonCellsRUN1 = [];
numberCommonCellsRUN2 = [];
numberApp = [];
numberDis = [];
numberStable = [];
numberUnstable = [];

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

    temp = load(file + "\extracted_sleep_state");
    sleep_state = temp.sleep_state;

    % Get session wise variables
    current_POST1_sleep = sleep_state.time >= sleep_state.state_time.INTER_post_start & ...
                          sleep_state.time <= sleep_state.state_time.INTER_post_end;
    current_amount_sleep = sum(sleep_state.state_binned(current_POST1_sleep) == 1);

    % Track loop

    for trackOI = 1:2

        other_track = mod(trackOI + 1, 2) + 2*mod(trackOI, 2);
        
        current_nb_cells = numel(place_fields.track(trackOI).smooth);
        allCells = 1:current_nb_cells;

        % Good cells : Cells that where good place cells during RUN1 / RUN2
        % Be careful about appearing / disappearing DURING SLEEP and IN
        % GENERAL

        goodCellsRUN1 = place_fields.track(trackOI).good_cells;
        goodCellsRUN2 = place_fields.track(trackOI + 2).good_cells;

        goodCellsRUN1Other = place_fields.track(other_track).good_cells;
        goodCellsRUN2Other = place_fields.track(other_track + 2).good_cells;

        current_nb_good_RUN1 = numel(union(goodCellsRUN1, goodCellsRUN1Other));
        current_nb_good_RUN2 = numel(union(goodCellsRUN2, goodCellsRUN2Other));

        current_nb_common_RUN1 = numel(intersect(goodCellsRUN1, goodCellsRUN1Other));
        current_nb_common_RUN2 = numel(intersect(goodCellsRUN2, goodCellsRUN2Other));

        isGoodPCRUN1 = ismember(allCells, goodPCRUN1);
        isGoodPCRUN2 = ismember(allCells, goodPCRUN2);
        isGoodPCRUN1Other = ismember(allCells, goodPCRUN1Other);
        isGoodPCRUN2Other = ismember(allCells, goodPCRUN2Other);

        current_label = repelem("Unstable", 1, current_nb_cells);
        current_label(isGoodPCRUN1 & isGoodPCRUN2)= "Stable";
        current_label(isGoodPCRUN1 & ~isGoodPCRUN2 & isGoodPCRUN2Other)= "Disappear";
        current_label(~isGoodPCRUN1 & isGoodPCRUN2 & isGoodPCRUN1Other)= "Appear";

        % VERIFICATIONS :

        % 2. If number of half lap is odd, we remove one and we
        % cut the data we just registered

        nbHalfLapsRUN1 = numel(lap_times(trackOI).halfLaps_start);
        nbHalfLapsRUN2 = numel(lap_times(trackOI + 2).halfLaps_start);

        nbHalfLapsRUN1 = nbHalfLapsRUN1 - mod(nbHalfLapsRUN1, 2);
        nbHalfLapsRUN2 = nbHalfLapsRUN2 - mod(nbHalfLapsRUN2, 2);
        
        current_numberLapsRUN1 = nbHalfLapsRUN1/2;
        current_numberLapsRUN2 = nbHalfLapsRUN2/2;

        current_nb_app = sum(current_label == "Appear");
        current_nb_dis = sum(current_label == "Disappear");
        current_nb_stable = sum(current_label == "Stable");
        current_nb_unstable = sum(current_label == "Unstable");


        % Get the amount of sleep

        % Save the data

        animal = [animal; animalOI];
        condition = [condition; conditionOI];
        track = [track; trackOI];
        numberCells = [numberCells; numel(place_fields.mean_rate)];
        numberGoodCellsRUN1 = [numberGoodCellsRUN1; current_nb_good_RUN1'];
        numberGoodCellsRUN2 = [numberGoodCellsRUN2; current_nb_good_RUN2'];
        numberLapsRUN1 = [numberLapsRUN1; current_numberLapsRUN1];
        numberLapsRUN2 = [numberLapsRUN2; current_numberLapsRUN2];
        amountSleep = [amountSleep; current_amount_sleep];
        numberCommonCellsRUN1 = [numberCommonCellsRUN1; current_nb_common_RUN1];
        numberCommonCellsRUN2 = [numberCommonCellsRUN2; current_nb_common_RUN2];
        numberApp = [numberApp; current_nb_app];
        numberDis = [numberDis; current_nb_dis];
        numberStable = [numberStable; current_nb_stable];
        numberUnstable = [numberUnstable; current_nb_unstable];

    end
end

data = table(animal, condition, track, numberCells, numberGoodCellsRUN1, ...
             numberGoodCellsRUN2, numberLapsRUN1, numberLapsRUN2, ...
             amountSleep, numberCommonCellsRUN1, numberCommonCellsRUN2, ...
             numberApp, numberDis, numberStable, numberUnstable);

save("allDescriptiveData.mat", "data");

%% Print the data

uniqueDataRUN1 = data(data.track == 1, :);
uniqueDataRUN2 = data(data.track == 2, :);

clc;
disp("Total nb of cells recorded : " + sum(uniqueDataRUN1.numberCells) + ". M = " + ...
     mean(uniqueDataRUN1.numberCells) + ", STD = " + std(uniqueDataRUN1.numberCells));

disp("Total nb of place cells recorded RUN 1: " + sum(uniqueDataRUN1.numberGoodCellsRUN1) + ". M = " + ...
     mean(uniqueDataRUN1.numberGoodCellsRUN1) + ", STD = " + std(uniqueDataRUN1.numberGoodCellsRUN1));

disp("Total nb of place cells recorded RUN 2: " + sum(uniqueDataRUN1.numberGoodCellsRUN2) + ". M = " + ...
     mean(uniqueDataRUN1.numberGoodCellsRUN2) + ", STD = " + std(uniqueDataRUN1.numberGoodCellsRUN2));

disp("Mean sleep time : " + mean(uniqueDataRUN1.amountSleep) + ", STD = " + std(uniqueDataRUN1.amountSleep));

disp("Mean proportion of common cells RUN1 : " + mean(uniqueDataRUN1.numberCommonCellsRUN1./uniqueDataRUN1.numberGoodCellsRUN1) + ...
     ", STD : " + std(uniqueDataRUN1.numberCommonCellsRUN1./uniqueDataRUN1.numberGoodCellsRUN1))

disp("Mean proportion of common cells RUN2 : " + mean(uniqueDataRUN1.numberCommonCellsRUN2./uniqueDataRUN1.numberGoodCellsRUN2) + ...
     ", STD : " + std(uniqueDataRUN1.numberCommonCellsRUN2./uniqueDataRUN1.numberGoodCellsRUN2))

%% Animal x Condition / Track - number of laps / Number of cells

fig = uifigure;
uit = uitable(fig,"Data", data);
uit.ColumnName = ["Animal", "Condition", "Track", "nb-cells", "nb-place-cells", "nb-laps-RUN1", "nb-laps-RUN2"];
uit.Position = [20 20 1000 500];
s = uistyle('HorizontalAlignment','center');
addStyle(uit,s,'table','');