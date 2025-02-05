% In previous analysis, the refinement is calculated
% between last lap of RUN1 and first lap of RUN2, which
% is dependent on the number laps
% The question here is : is the improvement between lap 1 and 2
% for 16 laps LESS than for 1 lap condition
% PV 2025

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Martha's recordings

% Order of the tracks : first line is exposure, second line is re-exposure
track_list = repelem({[1 2; 3 4]}, 1, numel(sessions)); % For Marta's data

% Arrays to hold all the data
sessionID = [];
animal = [];
condition = [];
track_order = {};
track = [];
exposure = [];
lap = [];
pvCorr = [];
speed = [];

%% First, we determine the minimum number of laps ran in TOTAL for each track
% to know where the FPF is gonna be calculated

nbLapT1 = [];
nbLapT2 = [];

for fileID = 1:length(sessions)

    file = sessions{fileID}; % We get the current session

    temp = load(file + "\extracted_laps"); % load lap information
    lap_times = temp.lap_times;
    cur_nb = [lap_times.number_completeLaps];

    current_nb_lap_T1 = cur_nb(1) + cur_nb(3);
    current_nb_lap_T2 = cur_nb(2) + cur_nb(4);

    nbLapT1(fileID) = current_nb_lap_T1;
    nbLapT2(fileID) = current_nb_lap_T2;
end

min_nb_laps = min([nbLapT1 nbLapT2]);

fpf_size = 6; % Set the size of the final place field (for calculation)
fpf_laps = (min_nb_laps - (fpf_size - 1)):min_nb_laps;


%% Extraction & computation

for fileID = 1:length(sessions)

    disp("Current session : " + fileID);
    file = sessions{fileID}; % We get the current session

    %     % For MARTHA's data : fetch animal name + condition :
    [animalOI, conditionOI] = parseNameFile(file);
    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    cur_track_order = track_list{fileID};

    % Load the needed variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;

    temp = load(file + "\extracted_position");
    position = temp.position;

    temp = load(file + "\extracted_laps");
    lap_times = temp.lap_times;

    % Iterate over each track

    for trackOI = 1:2

        % Get the index of the other track (1 -> 2, 2 -> 1)
        other_track = mod(trackOI + 1, 2) + 2*mod(trackOI, 2);

        % Good cells : Cells that where good place cells during RUN1 and RUN2
        % (no appearing / disappearing cells).
        goodCells = intersect(place_fields.track(trackOI).good_cells, ...
            place_fields.track(trackOI + 2).good_cells);

        % Find the number of laps during RUN1
        nbLapRun1 = lap_times(trackOI).number_completeLaps;

        % Concatenate all the place fields from exposure + re-exposure
        % and crop to get the good number of laps
        concat_laps = [lap_place_fields(trackOI).Complete_Lap, ...
            lap_place_fields(trackOI + 2).Complete_Lap];
        concat_laps = concat_laps(1:fpf_laps(end));

        % We compute the final place field based on previous lap selection

        finalPlaceField = {};

        %         For each cell, we create the final place field

        for cellID = 1:length(place_fields.track(trackOI + 2).smooth)

            temp = [];

            for clap = fpf_laps
                temp = [temp; concat_laps{clap}.smooth{cellID}];
            end

            finalPlaceField(end + 1) = {mean(temp, 'omitnan')};
        end

        % Iterate over laps (till the beggining of the FPF range)
        for lapOI = 1:(fpf_laps(1) - 1)

            % Get the PV correlation between current lap and FPF
            % (make sure the folder "util" is in your PATH)

            current_lap_data = concat_laps{lapOI};
            current_place_fields = current_lap_data.smooth;
            current_pvCorr = getPVCor(goodCells, current_place_fields, finalPlaceField, "pvCorrelation");
            current_pvCorr = median(current_pvCorr, 'omitnan');

            % get the exposure of the current lap selected
            if lapOI > nbLapRun1
                exposureOI = 2;
            else
                exposureOI = 1;
            end

            % Save the data

            sessionID = [sessionID; fileID];
            animal = [animal; animalOI];
            condition = [condition; conditionOI];
            track_order = [track_order; {cur_track_order}];
            track = [track; trackOI];
            exposure = [exposure; exposureOI];
            lap = [lap; lapOI];
            pvCorr = [pvCorr; current_pvCorr];

        end
    end
end

data = table(sessionID, animal, condition, track_order, track, exposure, lap, pvCorr);

save("../data/distance_control_TS.mat", "data")