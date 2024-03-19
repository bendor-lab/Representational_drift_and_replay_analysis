clear

allPaths = data_folders_excl_legacy;

animal = [];
condition = [];
ratioBothTrackOneTrackRUN1 = [];
ratioBothTrackOneTrackRUN2 = [];

for i = 1:numel(allPaths)
    currentPath = allPaths{i};
    disp(i);

    [animalOI, conditionOI] = parseNameFile(currentPath); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI);

    % Load the data

    place_fields_BAYESIAN = load(currentPath + "/extracted_place_fields_BAYESIAN");
    place_fields_BAYESIAN = place_fields_BAYESIAN.place_fields_BAYESIAN;

    allCells = 1:numel(place_fields_BAYESIAN.mean_rate);

    for cExposition = 1:2

        goodPCT1R1 = place_fields_BAYESIAN.track(1).good_cells;
        goodPCT1R2 = place_fields_BAYESIAN.track(3).good_cells;
        goodPCT2R1 = place_fields_BAYESIAN.track(2).good_cells;
        goodPCT2R2 = place_fields_BAYESIAN.track(4).good_cells;

        % goodCells = union(place_fields_BAYESIAN.track(cTrack + 2).good_cells, ...
        %                 place_fields_BAYESIAN.track(opposite_track + 2).good_cells);

        goodCells = xor(ismember(allCells, place_fields_BAYESIAN.track(cTrack + 2).good_cells), ...
            ismember(allCells, place_fields_BAYESIAN.track(opposite_track + 2).good_cells));



        % We save everything

        animal = [animal; animalOI];
        condition = [condition; conditionOI];
        track = [track; cTrack];
        exposition = [exposition; cExposition];
        lap = [lap; lapOI];
        spikePerS = [spikePerS; spike_per_second];

    end
end

% We mutate to only have the condition, not 16x...
old_condition = condition;
condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);
condition = str2double(condition);

data = table(animal, old_condition, condition, track, exposition, lap, spikePerS);

% We median by condition, exopsition and lap
G = groupsummary(data, ["condition", "exposition", "lap"], ...
    "median", ["spikePerS"]);

allConditions = unique(condition);
colors = lines(length(allConditions));
