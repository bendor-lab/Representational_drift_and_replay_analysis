% Script to plot the change in median CM during each lap, compared with the
% final place field
% Should replicate same plot with FPF PV correlation

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

load(PATH.SCRIPT + "/../../Data/extracted_activity_mat_lap.mat") % To get cells center of mass
load(PATH.SCRIPT + "/../../Data/population_vector_laps.mat") % To get the FPF for each session
% (and the clean number of laps)

% Arrays to hold all the data
animalV = [];
conditionV = [];
trackV = [];
lapV = [];
cellV = [];
expositionV = [];
infoPerSpikeV = [];

%% Extraction & computation

for cFile = sessions
    disp(cFile);
    file = cFile{1}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string

    for track = 1:2

        for exposition = 1:2

            vTrack = track + exposition - mod(exposition, 2); % Map parameters to 1, 2, 3, 4

            % Get the good lap data
            currData = activity_mat_laps(string({activity_mat_laps.animal}) == animalOI & ...
                string({activity_mat_laps.condition}) == conditionOI & ...
                [activity_mat_laps.track] == vTrack);

            lapDataGoodCells = activity_mat_laps(string({activity_mat_laps.animal}) == animalOI & ...
                string({activity_mat_laps.condition}) == conditionOI & ...
                [activity_mat_laps.track] == track + 2).allLaps;

            lapData = currData.allLaps;
            nbLaps = length(lapData);

            % Good cells are good place cells on RUN2
            goodCells = lapDataGoodCells(1).cellsData.cell(lapDataGoodCells(1).cellsData.isGoodPCCurrentTrack);
            nbGoodCells = length(goodCells);

            for lap = 1:nbLaps
                currentData = lapData(lap).cellsData;

                nbCells = length(currentData.cell);

                % We get the main variables we need
                % We first take all the pyramidal cells then all the good
                % place cells on the track

                infoPerSpike = currentData.infoPerSpike;

                isGoodPCFinal = ismember(currentData.cell, goodCells);

                infoPerSpike = infoPerSpike(isGoodPCFinal);

                % We add the data

                animalV = [animalV; repelem(animalOI, nbGoodCells)'];
                conditionV = [conditionV; repelem(conditionOI, nbGoodCells)'];
                trackV = [trackV; repelem(track, nbGoodCells)'];
                expositionV = [expositionV; repelem(exposition, nbGoodCells)'];
                lapV = [lapV; repelem(lap, nbGoodCells)'];
                cellV = [cellV; goodCells'];
                infoPerSpikeV = [infoPerSpikeV; infoPerSpike'];

            end
        end
    end

end

% We mutate to only have the condition, not 16x...
conditionV(trackV == 1) = 16;
newConditions = split(conditionV(trackV ~= 1), 'x');
conditionV(trackV ~= 1) = newConditions(:, 2);
conditionV = str2double(conditionV);

data = table(animalV, conditionV, trackV, lapV, expositionV, cellV, infoPerSpikeV);

% We median by condition, exopsition and lap
G = groupsummary(data, ["conditionV", "expositionV", "lapV"], ...
    ["median", "std"], ["infoPerSpikeV"]);

allConditions = unique(conditionV);
% allConditions = allConditions([1, 3, 4, 5, 6, 2]); % Re-order the condition
colors = lines(length(allConditions));

%% Plotting loop - Info per spike
figure;

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
    color = colors(allConditions == condition, :);

    % We get the lap data of the exposure
    dataByLapExp1 = G(G.conditionV == condition & G.expositionV == 1, :);
    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:condition, :);

    % We plot
    subplot(1, 2, 1)

    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if str2double(condition) == 1
        scatter(1, dataByLapExp1.median_infoPerSpikeV, 30, color, "filled");
    else
        plot(dataByLapExp1.lapV, dataByLapExp1.median_infoPerSpikeV, 'Color', color, 'LineWidth', 2);
    end

    hold on;

    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.conditionV == condition & G.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);

    % We plot
    subplot(1, 2, 2)
    plot(dataByLapExp2.lapV, dataByLapExp2.median_infoPerSpikeV, 'Color', color, 'LineWidth', 2);

    hold on;

end

% Set the legend for each subplot
subplot(1, 2, 1);
ylim([0, 1])
legend({'1 lap', '2 laps', '3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Lap")
ylabel("Median bit/spike")
title("First exposure")

subplot(1, 2, 2);
ylim([0, 1])
xlabel("Lap")
ylabel("Median bit/spike")
title("Re-exposure")

hold off;

%% Sample plot, all cells, one session

sampleData = data(data.animalV == "M-BLU" & data.conditionV == 2, :);

figure;

for exposition = 1:2
    number_laps = 16;
    currentData = sampleData(sampleData.expositionV == exposition & sampleData.lapV <= number_laps, :);

    subplot(1, 2, exposition)

    scatter(currentData.lapV, currentData.infoPerSpikeV);
end

% Set the legend for each subplot
subplot(1, 2, 1);
ylim([0, 5])
xlabel("Lap")
ylabel("Median bit/spike")
title("First exposure")

subplot(1, 2, 2);
ylim([0, 5])
xlabel("Lap")
ylabel("Median bit/spike")
title("Re-exposure")

hold off;

%%

figure;
cond = 8;
for lap = 1:cond
    subplot(cond, 1, lap)
    sampleData = data(data.animalV == "N-BLU" & data.conditionV == cond ...
                      & data.expositionV == 1 & data.lapV == lap, :);

    hist(sampleData.infoPerSpikeV, 50);
    xlim([0 2])
    ylim([0 20])
end

%% Look at the standard deviation of info per spike

figure;

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
    color = colors(allConditions == condition, :);

    % We get the lap data of the exposure
    dataByLapExp1 = G(G.conditionV == condition & G.expositionV == 1, :);
    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:condition, :);

    % We plot
    subplot(1, 2, 1)

    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if str2double(condition) == 1
        scatter(1, dataByLapExp1.std_infoPerSpikeV, 30, color, "filled");
    else
        plot(dataByLapExp1.lapV, dataByLapExp1.std_infoPerSpikeV, 'Color', color, 'LineWidth', 2);
    end

    hold on;

    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.conditionV == condition & G.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);

    % We plot
    subplot(1, 2, 2)
    plot(dataByLapExp2.lapV, dataByLapExp2.std_infoPerSpikeV, 'Color', color, 'LineWidth', 2);

    hold on;

end

% Set the legend for each subplot
subplot(1, 2, 1);
ylim([0, 10])
legend({'1 lap', '2 laps', '3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Lap")
ylabel("Median bit/spike")
title("First exposure")

subplot(1, 2, 2);
ylim([0, 10])
xlabel("Lap")
ylabel("Median bit/spike")
title("Re-exposure")

hold off;