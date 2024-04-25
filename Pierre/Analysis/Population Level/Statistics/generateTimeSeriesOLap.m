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
pvCorr = [];

% We take the absolute value of the difference over sum to get the relative
% distance with the FPF, independently of the direction
diffSum = @(x1, x2) abs(x1 - x2)/(x1 + x2);

%% Extraction & computation

parfor fileID = 1:length(sessions)

    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string

    % Load the variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    % temp = load(file + "\extracted_lap_place_fields.mat");
    % lap_place_fields = temp.lap_place_fields;

    temp = load(file + "\extracted_directional_lap_place_fields");
    lap_directional_place_fields = temp.lap_directional_place_fields;

    % Track loop

    for trackOI = 1:2

        % Good cells : Cells that where good place cells during RUN1 or RUN2
        goodCells = union(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);

        % Control : Cells that where good place cells during RUN1 and RUN2
        % (no appearing / disappearing cells).
        % goodCells = intersect(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);

        % Control : Cells that were good place cells during RUN1 xor RUN2
        % (only appearing / disappearing cells).
        % goodCells = setxor(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);

        % We get the final place field : mean of the 6 laps following the
        % 16th lap of RUN2

        % RUN1LapPFData = lap_place_fields(trackOI).Complete_Lap;
        % RUN2LapPFData = lap_place_fields(trackOI + 2).Complete_Lap;

        % numberLapsRUN2 = length(RUN2LapPFData);
        % 
        % finalPlaceField = {};
        % 
        % % For each cell, we create the final place field
        % for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
        %     temp = [];
        % 
        %     for clap = 1:6
        %         temp = [temp; RUN2LapPFData{16 + clap}.smooth{cellID}];
        %     end
        % 
        %     finalPlaceField(end + 1) = {mean(temp, 'omitnan')};
        % end

        for exposureOI = 1:2

            vTrack = trackOI + mod(exposureOI + 1, 2)*2;

            % current_numberLaps = numel(lap_directional_place_fields.dir1(vTrack).Complete_Lap);
            current_numberLaps = numel(lap_directional_place_fields(vTrack).dir1.Complete_Lap);

            if current_numberLaps > 16
                current_numberLaps = 16;
            end

            for lapOI = 1:current_numberLaps

                % current_lap_data = lap_place_fields(vTrack).Complete_Lap{lapOI};
                % current_place_fields = current_lap_data.smooth;

                current_lap_data_DIR1 = lap_directional_place_fields(vTrack).dir1.Complete_Lap{lapOI};
                current_place_fields_DIR1 = current_lap_data_DIR1.smooth;

                current_lap_data_DIR2 = lap_directional_place_fields(vTrack).dir2.Complete_Lap{lapOI};
                current_place_fields_DIR2 = current_lap_data_DIR2.smooth;

                % current_pvCorr = getPVCor(goodCells, current_place_fields, finalPlaceField, "pvCorrelation");
                current_pvCorr = getPVCor(goodCells, current_place_fields_DIR1, current_place_fields_DIR2, "pvCorrelation");
                current_pvCorr = median(current_pvCorr, 'omitnan');

                % Save the data

                animal = [animal; animalOI];
                condition = [condition; conditionOI];
                track = [track; trackOI];
                exposure = [exposure; exposureOI];
                lap = [lap; lapOI];
                pvCorr = [pvCorr; current_pvCorr];


            end
        end
    end
end



% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

data = table(animal, condition, exposure, lap, pvCorr);

save("timeSeriesDirectionnality.mat", "data")