% Script to generate a time serie of PV-correlation during each lap with
% FIRST lap
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
pvCorr = [];
speed = [];

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
        
        % Iterate over exposures (RUN1, RUN2)
        
        for exposureOI = 1:2
            
            % Get the "virtual track" (1, 2, 3, 4)
            vTrack = trackOI + 2*(exposureOI - 1); 
            
            current_numberLaps = numel(lap_place_fields(vTrack).Complete_Lap);
            
            % Iterate over laps
            for lapOI = 1:current_numberLaps
                
                % Find starting / end time to get the mean speed during
                % the trial ----
                lap_start = lap_times(vTrack).completeLaps_start(lapOI);
                lap_end = lap_times(vTrack).completeLaps_stop(lapOI);
                
                all_speed = position.v(position.t <= lap_end & position.t >= lap_start);
                all_speed(all_speed < 5) = [];
                mean_speed = mean(all_speed, 'omitnan');
                
                % Get the PV correlation between current lap and FPF
                % (make sure the folder "util" is in your PATH)
                
                current_lap_data = lap_place_fields(vTrack).Complete_Lap{lapOI};
                current_place_fields = current_lap_data.smooth;
                first_lap_data = lap_place_fields(trackOI).Complete_Lap{1};
                first_place_fields = first_lap_data.smooth;
                current_pvCorr = getPVCor(goodCells, current_place_fields, first_place_fields, "cosine");                
                current_pvCorr = median(current_pvCorr, 'omitnan');
                                
                % Save the data
                
                sessionID = [sessionID; fileID];
                animal = [animal; animalOI];
                condition = [condition; conditionOI];
                track_order = [track_order; {cur_track_order}];
                track = [track; trackOI];
                exposure = [exposure; exposureOI];
                lap = [lap; lapOI];
                pvCorr = [pvCorr; current_pvCorr];
                speed = [speed; mean_speed];


            end
        end
    end
end

data = table(sessionID, animal, condition, track_order, track, exposure, lap, speed, pvCorr);

save("../../data/marta_control/first_lap.mat", "data")

%% Plot the analysis

dataLapCorr = load("../../data/marta_control/first_lap.mat"); % load the data
dataLapCorr = dataLapCorr.data;

dataLapCorr.condition_num = split(dataLapCorr.condition, 'x');
dataLapCorr.condition_num(:, 1) = [];
dataLapCorr.condition_num(dataLapCorr.track == 1) = "16";
dataLapCorr.condition_num = str2double(dataLapCorr.condition_num);

%% 1. Show that representation is going further and further away from 1st lap

max_to_plot = 6;
all_points = dataLapCorr(dataLapCorr.exposure == 1 & dataLapCorr.track == 1 & dataLapCorr.lap <= max_to_plot, :);

f1 = figure;
hold on;

for l = 1:max_to_plot
    cur_points = all_points.pvCorr(all_points.lap == l);
    swarmchart(repelem(l*2, 1, numel(cur_points)), cur_points, 'filled');
end

xticks((1:max_to_plot)*2);
xticklabels((1:max_to_plot));
grid on;
xlabel("Lap pair");
ylabel("Cosine similarity");

p1 = signrank(all_points.pvCorr(all_points.lap == 1), all_points.pvCorr(all_points.lap == 2));
p2 = signrank(all_points.pvCorr(all_points.lap == 2), all_points.pvCorr(all_points.lap == 3));
p3 = signrank(all_points.pvCorr(all_points.lap == 3), all_points.pvCorr(all_points.lap == 4));

%% 2. Look at the difference in drift between 1 - 2 lap of T1 and 1 - 2 of T2

all_conditions = unique(dataLapCorr.condition);

all_points = [];

f2 = figure;
f2.Position = [387         463        1185         420];
hold on;

colors = lines(2);

for c = 1:numel(all_conditions)
    
    lap_nb = unique(dataLapCorr.condition_num(dataLapCorr.condition == all_conditions(c) & dataLapCorr.track == 2));
    lap_T1 = dataLapCorr.pvCorr(dataLapCorr.condition == all_conditions(c) & dataLapCorr.track == 1 & ...
                                       dataLapCorr.exposure == 1 & dataLapCorr.lap == lap_nb + 1);
    lap_T2 = dataLapCorr.pvCorr(dataLapCorr.condition == all_conditions(c) & dataLapCorr.track == 2 & ...
                                       dataLapCorr.exposure == 2 & dataLapCorr.lap == 1);
    
    swarmchart(repelem(c*5, 1, numel(lap_T1)), 1 - lap_T1, 'filled', 'MarkerFaceColor', colors(1, :));
    swarmchart(repelem((c*5) + 2, 1, numel(lap_T1)), 1 - lap_T2, 'filled', 'MarkerFaceColor', colors(2, :));

end

grid on;
xticks((1:numel(all_conditions))*5 + 1);
xticklabels(all_conditions);
xlabel("Condition");
ylabel("Drift from lap 1");

legend({"Expected drift without rest", "Drift with rest"})

% We don't see more drift for the session with rest


%%

sum = groupsummary(dataLapCorr, ...
                     ["condition_num", "exposure", "lap"], ...
                     ["median", "std"], ["pvCorr"]); % calculate the mean pv correlation across sessions
sum.se_pvCorr = sum.std_pvCorr./sqrt(sum.GroupCount);

var = "median_pvCorr";
varName = "Cosine Similarity";
std_var = "se_pvCorr";

f1 = figure;
f1.Position = [0,0,964,542];

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
    dataByLapExp2 = dataByLapExp2(1:16, :);

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
legend({'', '', ' 1 laps' ...
        '', '', '', ' 2 laps', ...
        '', '', ' 3 laps', ...
        '', '', ' 4 laps', ...
        '', '', ' 8 laps', ...
        '', '', ' 16 laps'}, 'Location','southoutside','NumColumns', 6, 'FontSize', 12);

legend('show');
xlabel("Lap")
ylabel("Median " + varName, 'FontSize', 12)
title("1^{st} exposure" + repelem(' ', 80) + "2^{nd} exposure")


grid on;

xticks([1 4 7 10 13 16 18 21 24 27 30 33]);
xticklabels({"1", "3", "7", "10", "13", "16", "1", "3", "7", "10", "13", "16"})
