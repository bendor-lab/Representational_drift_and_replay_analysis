clear

allPaths = data_folders_excl_legacy;

timeBin = 0.020;

goalVariance = 80;

% Vectors to store our data
dimensionality = [];
direction = [];
lap = [];
track = [];
condition = [];
animal = [];

% Through all the data paths

for cID = 1:length(allPaths)
    currentPath = allPaths{cID};
    disp(currentPath);

    [animalOI, conditionOI] = parseNameFile(currentPath); % We get the informations about the current data

    conditionOI = split(conditionOI, 'x');

    % Parse the data
    data = getParsedLapData(currentPath, timeBin);
    dataHalf = data.dataHalf.seq;

    for halfLap = 1:length(dataHalf)
        
        currentlap = dataHalf(halfLap).lap;

        spikeCount = dataHalf(halfLap).y;
        
        if mod(dataHalf(halfLap).track, 2) == 0
            currentCondition = str2double(conditionOI{end});
        else
            currentCondition = str2double(conditionOI{1});
        end

        % We find the first dimension that explains 80% of the variance
        [~, ~, ~, ~, explained, ~] = pca(spikeCount');

        for dim = 1:length(explained)
            if sum(explained(1:dim)) > goalVariance
                break
            end
        end

        % We store the data
        dimensionality = [dimensionality; dim];
        lap = [lap; currentlap];
        direction = [direction; dataHalf(halfLap).direction];
        track = [track; dataHalf(halfLap).track];
        condition = [condition; currentCondition];
        animal = [animal; convertCharsToStrings(animalOI)];
    end

end

exposition = (track > 2)*2 + (track <= 2)*1;
track(exposition == 2) = track(exposition == 2) - 2;

% We store the data in a table
data = table(animal, condition, track, exposition, lap, direction, dimensionality);

% We mean the dimensionality across animals, laps and directions
G = groupsummary(data, ["condition", "exposition", "lap"], ...
                 "mean", ["dimensionality"]);

allConditions = unique(condition);
% allConditions = allConditions([1, 3, 4, 5, 6, 2]); % Re-order the condition
colors = lines(length(allConditions));

%% Plotting loop - Center of mass
figure; 

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
    color = colors(allConditions == condition, :);
    
    % We get the lap data of the exposure
    dataByLapExp1 = G(G.condition == condition & G.exposition == 1, :);

    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:condition, :);
    
    % We plot
    subplot(1, 2, 1)
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if str2double(condition) == 1
        scatter(1, dataByLapExp1.mean_dimensionality, 30, color, "filled");
    else
        plot(dataByLapExp1.lap, dataByLapExp1.mean_dimensionality, 'Color', color, 'LineWidth', 2);
    end
        
    hold on;
    
    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.condition == condition & G.exposition == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);
    
    % We plot
    subplot(1, 2, 2)
    plot(dataByLapExp2.lap, dataByLapExp2.mean_dimensionality, 'Color', color, 'LineWidth', 2);
    
    hold on;
    
end

% Set the legend for each subplot
subplot(1, 2, 1);
legend({'1 lap', '2 laps', '3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Lap")
ylabel("Mean dimensionality to get 80 EV")
title("First exposure")

subplot(1, 2, 2);
xlabel("Lap")
ylabel("Mean dimensionality to get 80 EV")
title("Re-exposure")

hold off;