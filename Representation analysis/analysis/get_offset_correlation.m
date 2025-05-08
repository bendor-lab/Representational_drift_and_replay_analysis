%% Look at the correlation with the representation at the beginning and end of
% exposure on T1 vs; re-exposure of T2

clear
% sessions = data_folders_excl; % Martha's recordings
sessions = data_folders_deprivation; % Ben's recordings

% Order of the tracks : first line is exposure, second line is re-exposure
track_list = repelem({[1 2; 3 4]}, 1, numel(sessions)); % For Marta's data

track_list = {[1 2; 3 4], ...
    [1 2; 4 3], ...
    [1 2; 4 3], ...
    [1 2; 3 4], ...
    [1 2; 4 3], ...
    [1 2; 4 3], ...
    [1 2; 4 3], ...
    [1 2; 3 4], ...
    [1 2; 4 3], ...
    [1 2; 4 3], ...
    [1 2; 4 3], ...
    [1 2; 4 3]}; % For Ben's data (manual)

condition_list = ["no_rest", ...
    "no_rest", ...
    "no_sleep_15m", ...
    "sleep_2h", ...
    "sleep_15m", ...
    "sleep_30s", ...
    "pick_up", ...
    "interval", ...
    "barrier", ...
    "pred_error", ...
    "sleep_10s", ...
    "barrier"];

animal_list = ["R908", "R908", "R908", "R908", ...
    "R913", "R913", "R913", "R913", ...
    "R913", "R913", "R913", "R913"];

% This removes sessions without pipeline ran
has_data = [1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0];
has_data = logical(has_data);

% sessions = sessions(has_data);
track_list = track_list(has_data);
condition_list = condition_list(has_data);
animal_list = animal_list(has_data);

% Arrays to hold all the data
sessionID = [];
animal = [];
condition = [];
track_order = {};
track = [];
exposure = [];
first_offset = [];
second_offset = [];
third_offset = [];
pvCorr = [];
speed = [];

offsets = {};

%% Extraction & computation

for fileID = 1:length(sessions)

    disp("Current session : " + fileID);
    file = sessions{fileID}; % We get the current session

    %     % For MARTHA's data : fetch animal name + condition :
    % [animalOI, conditionOI] = parseNameFile(file);
    % animalOI = string(animalOI);
    % conditionOI = string(conditionOI); % We convert everything to string
    % cur_track_order = track_list{fileID};

    % For BEN's data : manual naming and condition
    animalOI = string(animal_list{fileID});
    conditionOI = string(condition_list{fileID});
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

    % We get the three correlation values for each cell - T1

    t1_corr = [];
    t2_corr = [];

    for offset = 1:3

        laps_start = (1:3) + (offset - 1);
        laps_end = (12:14) + (offset - 1);

        good_cells_T1 = place_fields.track(1).good_cells;

        t1_pf_start = cellfun(@(x) x.smooth(good_cells_T1), lap_place_fields(1).Complete_Lap(laps_start), 'UniformOutput', false);
        t1_pf_start = cellfun(@(x) cell2mat(x'), t1_pf_start, 'UniformOutput', false);
        t1_pf_start = mean(cell2mat(reshape(t1_pf_start, [1 1 numel(laps_start)])), 3, 'omitnan');

        t1_pf_end = cellfun(@(x) x.smooth(good_cells_T1), lap_place_fields(1).Complete_Lap(laps_end), 'UniformOutput', false);
        t1_pf_end = cellfun(@(x) cell2mat(x'), t1_pf_end, 'UniformOutput', false);
        t1_pf_end = mean(cell2mat(reshape(t1_pf_end, [1 1 numel(laps_end)])), 3, 'omitnan');

        cur_corr_t1 = diag(corr(t1_pf_start', t1_pf_end'))';
        t1_corr = [t1_corr; cur_corr_t1];

        good_cells_T2 = place_fields.track(4).good_cells;

        t2_pf_start = cellfun(@(x) x.smooth(good_cells_T2), lap_place_fields(4).Complete_Lap(laps_start), 'UniformOutput', false);
        t2_pf_start = cellfun(@(x) cell2mat(x'), t2_pf_start, 'UniformOutput', false);
        t2_pf_start = mean(cell2mat(reshape(t2_pf_start, [1 1 numel(laps_start)])), 3, 'omitnan');

        t2_pf_end = cellfun(@(x) x.smooth(good_cells_T2), lap_place_fields(4).Complete_Lap(laps_end), 'UniformOutput', false);
        t2_pf_end = cellfun(@(x) cell2mat(x'), t2_pf_end, 'UniformOutput', false);
        t2_pf_end = mean(cell2mat(reshape(t2_pf_end, [1 1 numel(laps_end)])), 3, 'omitnan');

        cur_corr_t2 = diag(corr(t2_pf_start', t2_pf_end'))';
        t2_corr = [t2_corr; cur_corr_t2];
    end

    offsets{end + 1} = {t1_corr, t2_corr};
end

%% Analysis

all_conditions = unique(condition_list);

for c = all_conditions

    to_fetch = condition_list == c;

    f1 = figure;
    hold on;

    cur_vec_t1 = cellfun(@(x) x{1}, offsets(to_fetch), 'UniformOutput', false);
    cur_vec_t1 = cell2mat(cellfun(@(x) mean(x, 2, 'omitnan')', cur_vec_t1, 'UniformOutput', false)');
    cur_vec_t2 = cellfun(@(x) x{2}, offsets(to_fetch), 'UniformOutput', false);
    cur_vec_t2 = cell2mat(cellfun(@(x) mean(x, 2, 'omitnan')', cur_vec_t2, 'UniformOutput', false)');

    plot(1:3, mean(cur_vec_t1, 1), "Marker", "o");
    hold on;
    plot(1:3, mean(cur_vec_t2, 1), "Marker", "o");
    grid on;
    legend({"T1 - RUN1", "T2 - RUN2"});
    xlim([0 4]);
    xlabel("Laps");
    xticks(1:3);
    xticklabels({"1 - 3", "2 - 4", "3 - 5"});
    ylabel("Mean PF correlation with L+11")

    title("Condition " + c);
end