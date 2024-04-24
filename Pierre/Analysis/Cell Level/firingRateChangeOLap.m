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
mean_FR = [];
mean_CM = [];
mean_Peak = [];

%% Extraction & computation

parfor fileID = 1:length(sessions)

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

        for exposureOI = 1:2

            vTrack = trackOI + mod(exposureOI + 1, 2)*2;

            current_numberLaps = numel(lap_place_fields(vTrack).Complete_Lap);

            if current_numberLaps > 16
                current_numberLaps = 16;
            end

            for lapOI = 1:current_numberLaps

                current_lap_data = lap_place_fields(vTrack).Complete_Lap{lapOI};
                current_place_fields = current_lap_data.smooth;

                currentCM = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), current_place_fields);
                currentFR = cellfun(@(x) mean(x, 'omitnan'), current_place_fields);
                currentPeakLoc = cellfun(@(x) find(x == max(x), 1), current_place_fields);

                currentFR(isnan(currentCM)) = NaN;
                currentPeakLoc(isnan(currentCM)) = NaN;

                nbGoodCells = numel(goodCells);

                % Save the data

                animal = [animal; repelem(animalOI, nbGoodCells)'];
                condition = [condition; repelem(conditionOI, nbGoodCells)'];
                track = [track; repelem(trackOI, nbGoodCells)'];
                exposure = [exposure; repelem(exposureOI, nbGoodCells)'];
                lap = [lap; repelem(lapOI, nbGoodCells)'];
                cell = [cell; (goodCells + ident)'];
                label = [label; current_label'];
                mean_FR = [mean_FR; currentFR(goodCells)'];
                mean_CM = [mean_CM; currentCM(goodCells)'];
                mean_Peak = [mean_Peak; currentPeakLoc(goodCells)'];

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

data = table(animal, condition, exposure, lap, cell, label, mean_FR, mean_CM, mean_Peak);

save("basic_variables_ts.mat", "data")

%% Time series plotting

summaryLapData = groupsummary(data, ["condition", "exposure", "lap", "label"], ["median", "std"], ["mean_FR", "mean_CM", "mean_Peak"]);

% 2. Peak Location

f6 = figure; 
f6.Position = [0, 0, 964, 542];
timeSeriesOverLap(summaryLapData(summaryLapData.label == "Stable", :), "median_mean_FR", "Max Firing Rate");
ylabel("Median max firing rate")
title("Firing rate evolution - Stable Cells")
ylim([0 1.25])

f7 = figure; 
f7.Position = [0, 0, 964, 542];
timeSeriesOverLap(summaryLapData(summaryLapData.label == "Disappear", :), "median_mean_FR", "Max Firing Rate");
ylabel("Median max firing rate")
title("Firing rate evolution - Disappearing Cells")
ylim([0 1.25])

f8 = figure; 
f8.Position = [0, 0, 964, 542];
timeSeriesOverLap(summaryLapData(summaryLapData.label == "Appear", :), "median_mean_FR", "Max Firing Rate");
ylabel("Median max firing rate")
title("Firing rate evolution - Appearing Cells")
ylim([0 1.25])
