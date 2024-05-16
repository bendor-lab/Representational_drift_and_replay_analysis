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

sessionID = [];
animal = [];
condition = [];
exposure = [];
lap = [];
cell = [];
trackDiffCM = [];
trackDiffFR = [];
trackDiffPeak = [];

% We take the absolute value of the difference over sum to get the relative
% distance with the FPF, independently of the direction
diffSum = @(x1, x2) abs(x1 - x2)/(x1 + x2);

%% Extraction & computation

for fileID = 1:length(sessions)
    
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
    %temp = load(file + "\extracted_directional_lap_place_fields");
    lap_place_fields = temp.lap_place_fields;
    
    for exposureOI = 0:2:2
        
        t1 = 1 + exposureOI;
        t2 = 2 + exposureOI;
        
        
        % We get the minimum amount of laps
        nbLapsT1 = (numel(lap_place_fields(t1).half_Lap) - ...
            mod(numel(lap_place_fields(t1).half_Lap), 2))/2;
        
        nbLapsT2 = (numel(lap_place_fields(t2).half_Lap) - ...
            mod(numel(lap_place_fields(t2).half_Lap), 2))/2;
        
        current_nb_laps = min(nbLapsT1, nbLapsT2);
        
        
        if current_nb_laps > 16
            current_nb_laps = 16;
        end

        % Good cells : cells that were at one point good place cells on
        % both tracks

        goodCells = intersect(place_fields.track(t1).good_cells, place_fields.track(t1).good_cells);
        
        for lapOI = 1:current_nb_laps
            
            lapDataT1 = lap_place_fields(t1).Complete_Lap{lapOI};
            lapDataT2 = lap_place_fields(t2).Complete_Lap{lapOI};
            
            current_place_fields_T1 = lapDataT1.smooth;
            current_place_fields_T2 = lapDataT2.smooth;
            
            currentCMT1 = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), current_place_fields_T1);
            currentFRT1 = cellfun(@max, current_place_fields_T1);
            currentPeakLocT1 = cellfun(@(x) find(x == max(x), 1), current_place_fields_T1);
            
            currentCMT2 = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), current_place_fields_T2);
            currentFRT2 = cellfun(@max, current_place_fields_T2);
            currentPeakLocT2 = cellfun(@(x) find(x == max(x), 1), current_place_fields_T2);
            
            % We take the CM and peak FR difference based on the DISTANCE
            % WITH THE MIDDLE
            
            currentTrackCMDiff = abs(abs(100 - currentCMT1) - abs(100 - currentCMT2));
            currentTrackPeakDiff = abs(abs(100 - currentPeakLocT1) - abs(100 - currentPeakLocT2));
            currentTrackFRDiff = abs(currentFRT1 - currentFRT2);
            
            currentTrackCMDiff = currentTrackCMDiff(goodCells)';
            currentTrackPeakDiff = currentTrackPeakDiff(goodCells)';
            currentTrackFRDiff = currentTrackFRDiff(goodCells)';
            
            nbGoodCells = numel(goodCells);
            
            % Save the data
            sessionID = [sessionID; repelem(fileID, nbGoodCells)']
            animal = [animal; repelem(animalOI, nbGoodCells)'];
            condition = [condition; repelem(conditionOI, nbGoodCells)'];
            exposure = [exposure; repelem(exposureOI, nbGoodCells)'];
            lap = [lap; repelem(lapOI, nbGoodCells)'];
            cell = [cell; (goodCells + ident)'];
            trackDiffCM = [trackDiffCM; currentTrackCMDiff];
            trackDiffFR = [trackDiffFR; currentTrackFRDiff];
            trackDiffPeak = [trackDiffPeak; currentTrackPeakDiff];
            
        end
    end
end



% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

newConditions = split(condition, 'x');
condition = newConditions(:, 2);
condition = str2double(condition);


data = table(sessionID, animal, condition, exposure, lap, cell, trackDiffCM, trackDiffFR, trackDiffPeak);

save("timeSeries_cross_track_distance.mat", "data")

%% 

clear

load("timeSeries_cross_track_distance.mat");

summary = groupsummary(data, ["condition", "exposure", "lap"], ["mean", "std"], ["trackDiffPeak", "trackDiffFR", "trackDiffCM"]);

var = "mean_trackDiffPeak";
var_std = "std_trackDiffPeak";


allConditions = unique(summary.condition);
colors = lines(length(allConditions));

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
    color = colors(allConditions == condition, :);

    % We get the lap data of the exposure
    dataByLapExp1 = summary(summary.condition == condition & summary.exposure == 0, :);

    % We get the lap data of the reexposure
    dataByLapExp2 = summary(summary.condition == condition & summary.exposure == 2, :);

    % Number of NaNs to fill
    nbNan = 17 - condition;

    Y = [dataByLapExp1.(var)' repelem(NaN, nbNan) dataByLapExp2.(var)'];

    Y1_shade = dataByLapExp1.(var)';
    std1_data = dataByLapExp1.(var_std)';

    Y2_shade = dataByLapExp2.(var)';
    std2_data = dataByLapExp2.(var_std)';

    X = 1:numel(Y);

    X1_shade = 1:numel(Y1_shade);
    X2_shade = (numel([dataByLapExp1.(var)' repelem(NaN, nbNan)])+1):numel(Y);

    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter

    % Shading the std
    f1 = fill([X1_shade, flip(X1_shade)], [Y1_shade + std1_data, flip(Y1_shade - std1_data)], color, ...
         'FaceAlpha', 0.1);
    f1.LineStyle = "none";
    hold on;

    f2 = fill([X2_shade, flip(X2_shade)], [Y2_shade + std2_data, flip(Y2_shade - std2_data)], color, ...
         'FaceAlpha', 0.1);
    f2.LineStyle = "none";

    plot(X, Y, 'Color', color, 'LineWidth', 2);

    if condition == 1
        hold on;
        errorbar(1, Y(1), std1_data(1), "-s", "MarkerSize", 5, "Color", color, "CapSize", 6, ...
            "LineWidth", 1.5, "MarkerFaceColor", color);
    end

    hold on;

end

xline(17, '-', 'Sleep', 'LineWidth', 2, 'LabelOrientation', 'horizontal', 'FontSize', 12);

hold off;

limitUp = max(summary.(var)) + 0.125 * max(summary.(var));

% Set the legend
ylim([0, limitUp])
legend({'', '', ' 1 lap', '', ...
        '', '', ' 2 laps', ...
        '', '', ' 3 laps', ...
        '', '', ' 4 laps', ...
        '', '', ' 8 laps'}, 'Location','southoutside','NumColumns', 6, 'FontSize', 12);

legend('show');
xlabel("Lap")
ylabel("Median peak distance from middle between tracks", 'FontSize', 12)
title("1^{st} exposure" + repelem(' ', 80) + "2^{nd} exposure")

grid on;

xticks([1 4 7 10 13 16 18 21 24 27 30 33]);
xticklabels({"1", "3", "7", "10", "13", "16", "1", "3", "7", "10", "13", "16"})


