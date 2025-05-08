% Script to generate a time serie of PV-correlation during each lap with
% final lap (without controls for the total number of laps !)
% PV 2025

clear

sessions = data_folders_excl; % Martha's recordings
% sessions = data_folders_deprivation; % Ben's recordings

% Order of the tracks : first line is exposure, second line is re-exposure
track_list = repelem({[1 2; 3 4]}, 1, numel(sessions)); % For Marta's data

% track_list = {[1 2; 3 4], ...
%                [1 2; 4 3], ...
%                [1 2; 4 3], ...
%                [1 2; 3 4], ...
%                [1 2; 4 3], ...
%                [1 2; 4 3], ...
%                [1 2; 4 3], ...
%                [1 2; 3 4], ...
%                [1 2; 4 3], ...
%                [1 2; 4 3], ...
%                [1 2; 4 3], ...
%                [1 2; 4 3]}; % For Ben's data (manual)
%
%  condition_list = ["no_rest", ...
%                    "no_rest", ...
%                    "no_sleep_15m", ...
%                    "sleep_2h", ...
%                    "sleep_15m", ...
%                    "sleep_30s", ...
%                    "pick_up", ...
%                    "interval", ...
%                    "barrier", ...
%                    "pred_error", ...
%                    "sleep_10s", ...
%                    "barrier"];
%
% animal_list = ["R908", "R908", "R908", "R908", ...
%                "R913", "R913", "R913", "R913", ...
%                "R913", "R913", "R913", "R913"];
%
% % This removes sessions without pipeline ran
% has_data = [1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0];
% has_data = logical(has_data);
%
% sessions = sessions(has_data);
% track_list = track_list(has_data);
% condition_list = condition_list(has_data);
% animal_list = animal_list(has_data);
%
% Arrays to hold all the data
sessionID = [];
animal = [];
condition = [];
track_order = {};
track = [];
exposure = [];
lap = [];
cell = [];
cmDist = [];
frDist = [];
firingCorr = [];

%% Extraction & computation

for fileID = 1:length(sessions)

    disp("Current session : " + fileID);
    file = sessions{fileID}; % We get the current session

    %     % For MARTHA's data : fetch animal name + condition :
    [animalOI, conditionOI] = parseNameFile(file);
    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    cur_track_order = track_list{fileID};

    % For BEN's data : manual naming and condition
    % animalOI = string(animal_list{fileID});
    % conditionOI = string(condition_list{fileID});
    % cur_track_order = track_list{fileID};

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

        if numel(goodCells) < 10
            disp("Excluding (< 10 cells) : " + fileID);
            continue;
        end

        % We compute the final place field :
        % For Marta's data : mean of the 6 laps following the
        % 16th lap of RUN2 (commented out)
        % For Ben's data : last lap of RUN2

        RUN1LapPFData = lap_place_fields(trackOI).Complete_Lap;
        RUN2LapPFData = lap_place_fields(trackOI + 2).Complete_Lap;
        numberLapsRUN2 = length(RUN2LapPFData);
        finalPlaceField = {};

        % For each cell, we create the final place field
        for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
            temp = [];

            for clap = 1:6
                temp = [temp; RUN2LapPFData{16 + clap}.smooth{cellID}];
            end

            finalPlaceField(end + 1) = {mean(temp, 'omitnan')};
        end

        fpfCM = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), finalPlaceField(goodCells));
        fpfFR = cellfun(@max, finalPlaceField(goodCells));

        firstLapFPF = 17;

        %
        %         If working with less laps (new data), just take the last
        %         lap

        % for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
        %     finalPlaceField(end + 1) = {RUN2LapPFData{end}.smooth{cellID}};
        % end
        % firstLapFPF = numel(RUN2LapPFData); % Define the first lap used for FPF calculation

        % Iterate over exposures (RUN1, RUN2)

        for exposureOI = 1:2

            % Get the "virtual track" (1, 2, 3, 4)
            vTrack = trackOI + 2*(exposureOI - 1);

            current_numberLaps = numel(lap_place_fields(vTrack).Complete_Lap);

            % Set the number of laps for RUN2 to the last one before FPF
            % starts
            if exposureOI == 2
                current_numberLaps = firstLapFPF - 1;
            end

            % Iterate over laps
            for lapOI = 1:current_numberLaps

                % Iterate over cells
                current_lap_data = lap_place_fields(vTrack).Complete_Lap{lapOI};
                current_place_fields = current_lap_data.smooth;

                currentCM = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), current_place_fields(goodCells));
                currentFR = cellfun(@max, current_place_fields(goodCells));

                cm_diff = abs(currentCM - fpfCM);
                fr_diff = abs(currentFR - fpfFR);
                fpf_corr = cellfun(@(x, y) corrcoef(x, y), current_place_fields(goodCells), finalPlaceField(goodCells), 'UniformOutput', false);
                fpf_corr = cellfun(@(x) x(1, 2), fpf_corr);


                % Save the data

                for c = 1:numel(cm_diff)

                    sessionID = [sessionID; fileID];
                    animal = [animal; animalOI];
                    condition = [condition; conditionOI];
                    track_order = [track_order; {cur_track_order}];
                    track = [track; trackOI];
                    exposure = [exposure; exposureOI];
                    lap = [lap; lapOI];
                    cell = [cell; goodCells(c)];
                    cmDist = [cmDist; cm_diff(c)];
                    frDist = [frDist; fr_diff(c)];
                    firingCorr = [firingCorr; fpf_corr(c)];

                end


            end
        end
    end
end

data = table(sessionID, animal, condition, track_order, track, exposure, lap, cell, cmDist, frDist, firingCorr);

% save("../data/time_serie_main.mat", "data")

save("../data/time_serie_cell.mat", "data")

%% Plot the analysis

dataLapCorr = load("../data/time_serie_cell.mat"); % load the data
dataLapCorr = dataLapCorr.data;

dataLapCorr.condition_num = split(dataLapCorr.condition, 'x');
dataLapCorr.condition_num(:, 1) = [];
dataLapCorr.condition_num(dataLapCorr.track == 1) = "16";
dataLapCorr.condition_num = str2double(dataLapCorr.condition_num);

%% 1. Show that representation is going further and further away from 1st lap

mean_cells = groupsummary(dataLapCorr, ...
    ["sessionID", "condition_num", "exposure", "lap"], ...
    ["median", "std"], ["cmDist", "frDist", "firingCorr"]); % calculate the mean pv correlation across sessions

mean_cells.se_cmDist = mean_cells.std_cmDist ./ sqrt(mean_cells.GroupCount);
mean_cells.se_frDist = mean_cells.std_frDist ./ sqrt(mean_cells.GroupCount);
mean_cells.se_firingCorr = mean_cells.std_firingCorr ./ sqrt(mean_cells.GroupCount);

max_to_plot = 6;
all_points = mean_cells(mean_cells.exposure == 1 & mean_cells.condition_num == 16 & mean_cells.lap <= max_to_plot, :);

f1 = figure;
t = tiledlayout(1, 3);

nexttile;
hold on;

for l = 1:max_to_plot
    cur_points = all_points.median_cmDist(all_points.lap == l);
    swarmchart(repelem(l*2, 1, numel(cur_points)), cur_points, 'filled');
end

xticks((1:max_to_plot)*2);
xticklabels((1:max_to_plot));
grid on;
xlabel("Lap pair");
ylabel("Center of mass distance with FPF (cm)");

p1 = signrank(all_points.median_cmDist(all_points.lap == 1), all_points.median_cmDist(all_points.lap == 2));
p2 = signrank(all_points.median_cmDist(all_points.lap == 2), all_points.median_cmDist(all_points.lap == 3));
p3 = signrank(all_points.median_cmDist(all_points.lap == 3), all_points.median_cmDist(all_points.lap == 4));

nexttile;
hold on;

for l = 1:max_to_plot
    cur_points = all_points.median_frDist(all_points.lap == l);
    swarmchart(repelem(l*2, 1, numel(cur_points)), cur_points, 'filled');
end

xticks((1:max_to_plot)*2);
xticklabels((1:max_to_plot));
grid on;
xlabel("Lap pair");
ylabel("Max. firing rate difference with FPF (Hz)");

nexttile;
hold on;

for l = 1:max_to_plot
    cur_points = all_points.median_firingCorr(all_points.lap == l);
    swarmchart(repelem(l*2, 1, numel(cur_points)), cur_points, 'filled');
end

xticks((1:max_to_plot)*2);
xticklabels((1:max_to_plot));
grid on;
xlabel("Lap pair");
ylabel("Cell field correlation with FPF");

%% Meaned across sessions plot

sum = groupsummary(dataLapCorr, ...
    ["condition_num", "exposure", "lap"], ...
    ["median", "std"], ["cmDist", "frDist", "firingCorr"]); % calculate the mean pv correlation across sessions

sum.se_cmDist = sum.std_cmDist ./ sqrt(sum.GroupCount);
sum.se_frDist = sum.std_frDist ./ sqrt(sum.GroupCount);
sum.se_firingCorr = sum.std_firingCorr ./ sqrt(sum.GroupCount);

var_to_plot = ["cmDist", "frDist", "firingCorr"];

f1 = figure;
t2 = tiledlayout(3, 1);

for var_name = var_to_plot

    var = "median_" + var_name;
    varName = var_name;
    std_var = "se_" + var_name;

    nexttile;

    allConditions = unique(sum.condition_num);
    colors = lines(length(allConditions));

    for i = 1:length(allConditions) % We iterate through conditions
        condition = allConditions(i);
        color = colors(allConditions == condition, :);

        % We get the lap data of the exposure
        dataByLapExp1 = sum(sum.condition_num == condition & sum.exposure == 1, :);
        % We crop the data depending on the condition number
        dataByLapExp1 = dataByLapExp1(1:condition, :);

        % We get the lap data of the reexposure
        dataByLapExp2 = sum(sum.condition_num == condition & sum.exposure == 2, :);

        % Filling with NaN to have padding + shading areas
        nbNan = 17 - condition;
        Y = [dataByLapExp1.(var)' repelem(NaN, nbNan) dataByLapExp2.(var)'];
        Y1_shade = dataByLapExp1.(var)';
        std1_data = dataByLapExp1.(std_var)';
        Y2_shade = dataByLapExp2.(var)';
        std2_data = dataByLapExp2.(std_var)';
        X = 1:numel(Y);
        X1_shade = 1:numel(Y1_shade);
        X2_shade = (numel([dataByLapExp1.(var)' repelem(NaN, nbNan)])+1):numel(Y);
        % Shading the std
        f1 = fill([X1_shade, flip(X1_shade)], [Y1_shade + std1_data, flip(Y1_shade - std1_data)], color, ...
            'FaceAlpha', 0.1);
        f1.LineStyle = "none";
        hold on;
        f2 = fill([X2_shade, flip(X2_shade)], [Y2_shade + std2_data, flip(Y2_shade - std2_data)], color, ...
            'FaceAlpha', 0.1);
        f2.LineStyle = "none";

        % Main plot
        plot(X, Y, 'Color', color, 'LineWidth', 2);

        % if condition 1 lap, scatter instead of plotting
        if condition == 1
            hold on;
            errorbar(1, Y(1), std1_data(1), "-s", "MarkerSize", 5, "Color", color, "CapSize", 6, ...
                "LineWidth", 1.5, "MarkerFaceColor", color);
        end

        hold on;

    end

    xline(17, '-', 'Sleep', 'LineWidth', 2, 'LabelOrientation', 'horizontal', 'FontSize', 12);

    hold off;

    limitUp = max(sum.(var)) + 0.125 * max(sum.(var));

    % Set the legend
    ylim([0, limitUp])
   
    xlabel("Lap")
    ylabel("Median " + varName, 'FontSize', 12)
    title("1^{st} exposure" + repelem(' ', 80) + "2^{nd} exposure")


    grid on;

    xticks([1 4 7 10 13 16 18 21 24 27 30 33]);
    xticklabels({"1", "3", "7", "10", "13", "16", "1", "3", "7", "10", "13", "16"})

end

legend({'', '', ' 1 lap', '', ...
        '', '', ' 2 laps', ...
        '', '', ' 3 laps', ...
        '', '', ' 4 laps', ...
        '', '', ' 8 laps', ...
        '', '', ' 16 laps'}, 'Location','southoutside','NumColumns', 6, 'FontSize', 12);

    legend('show');
