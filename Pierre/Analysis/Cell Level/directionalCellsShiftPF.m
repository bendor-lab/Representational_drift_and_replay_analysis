clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

% (and the clean number of laps)

% Arrays to hold all the data
animalV = [];
conditionV = [];
trackV = [];
lapV = [];
cellV = [];
directionV = [];
expositionV = [];
deltaPeakPosV = [];


%% Extraction & computation

for cFile = sessions
    disp(cFile);
    file = cFile{1}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    
    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    
    load(file + "\extracted_directional_lap_place_fields.mat");
    load(file + "\extracted_directional_place_fields.mat");
    
    for track = 1:2
        for exposition = 1:2
            vTrack = track + exposition - mod(exposition, 2); % Map parameters to 1, 2, 3, 4
            
            % Get the directional cells for the current Track
            
            pfDir1 = directional_place_fields(1).place_fields.track(vTrack).smooth;
            pfDir2 = directional_place_fields(2).place_fields.track(vTrack).smooth;
            
            [directionalCells, dirOP] = getDirectionalCells(pfDir1, pfDir2);
            
            goodCells = union(directional_place_fields(1).place_fields.good_place_cells, ...
            directional_place_fields(2).place_fields.good_place_cells);
            
            goodDirCells = intersect(goodCells, directionalCells);
            isAGoodPC = arrayfun(@(x) ismember(x, goodCells), directionalCells);
            dirOP = dirOP(isAGoodPC);
            
            % For each directional cell
            for cellID = 1:length(goodDirCells)
                cell = goodDirCells(cellID);
                direction = dirOP(cellID);
                if direction == 1
                    lapData = lap_directional_place_fields(vTrack).dir1.Complete_Lap;
                else
                    lapData = lap_directional_place_fields(vTrack).dir2.Complete_Lap;
                end
                
                nbLaps = length(lapData);
                
                for lap = 1:nbLaps
                    currentData = lapData{lap};
                    
                    % We get the main variables we need
                    % We first take all the pyramidal cells then all the good
                    % place cells on the track

                    [~, posMaxDir1] = max(currentData.centre_of_mass(cell));
                    
                    deltaPeakPos = currentData.centre_of_mass(cell) - ...
                              directional_place_fields(direction).place_fields.track(vTrack).centre_of_mass(cell);
                             %lapData{1}.centre_of_mass(cell);
                             
                    
                    % We add the data
                    
                    animalV = [animalV; animalOI];
                    conditionV = [conditionV; conditionOI];
                    trackV = [trackV; track];
                    directionV = [directionV; direction];
                    expositionV = [expositionV; exposition];
                    lapV = [lapV; lap];
                    cellV = [cellV; cell];
                    deltaPeakPosV = [deltaPeakPosV; deltaPeakPos];
                end
                
            end
        end
    end
end


% We mutate to only have the condition, not 16x...
conditionV(trackV == 1) = 16;
newConditions = split(conditionV(trackV ~= 1), 'x');
conditionV(trackV ~= 1) = newConditions(:, 2);

data = table(animalV, conditionV, trackV, lapV, expositionV, directionV, cellV, deltaPeakPos);

%%

% We reverse the score for the other direction
data.deltaCMV(data.directionV == 2) = (-1)* data.deltaCMV(data.directionV == 2);

% We mean by condition, exopsition and lap
G = groupsummary(data, ["conditionV", "expositionV", "lapV"], ...
                        "median", ["deltaCMV"]);

allConditions = unique(conditionV);
allConditions = allConditions([1, 3, 4, 5, 6, 2]); % Re-order the condition
colors = lines(length(allConditions));

%% Plotting loop - Center of mass
figure;

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
    color = colors(allConditions == condition, :);
    
    % We get the lap data of the exposure
    dataByLapExp1 = G(G.conditionV == condition & G.expositionV == 1, :);
    % We crop the data depending on the condition number
    dataByLapExp1 = dataByLapExp1(1:str2double(condition), :);
    
    % We plot
    subplot(1, 2, 1)
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if str2double(condition) == 1
        scatter(1, dataByLapExp1.median_deltaCMV, 30, color, "filled");
    else
        plot(dataByLapExp1.lapV, dataByLapExp1.median_deltaCMV, 'Color', color, 'LineWidth', 2);
    end
    
    hold on;
    
    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.conditionV == condition & G.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);
    
    % We plot
    subplot(1, 2, 2)
    plot(dataByLapExp2.lapV, dataByLapExp2.median_deltaCMV, 'Color', color, 'LineWidth', 2);
    
    hold on;
    
end

% Set the legend for each subplot
subplot(1, 2, 1);
% ylim([15, 45])
legend({'1 lap', '2 laps', '3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Lap")
ylabel("Center of mass difference with the mean")
title("First exposure")

subplot(1, 2, 2);
% ylim([15, 45])
xlabel("Lap")
ylabel("Center of mass difference with the mean")
title("Re-exposure")

hold off;

%% Plot the number of number of directional cells function of lap

figure;

X1 = data(data.expositionV == 1 & data.conditionV == "16" & data.directionV == 1, :);
X2 = data(data.expositionV == 1 & data.conditionV == "16" & data.directionV == 2, :);

color = ["r", "b"];

a = tiledlayout(2, 1);
nexttile;
scatter(X1.lapV, X1.deltaCMV, color(1));

nexttile;
scatter(X2.lapV, X2.deltaCMV, color(2));

%% Analysis 1st half vs. last half

% Filter out 1 lap & 2 laps cause cant split and 1st lap cause always 0 (bias)
dataWtC1 = data(data.conditionV ~= "1" & data.conditionV ~= "2" & data.lapV ~= 1, :);

dataWtC1.splitPoint = (str2double(dataWtC1.conditionV) + 1)/2;
dataWtC1.isFirstHalf = (dataWtC1.lapV <= dataWtC1.splitPoint)*0.25 + ...
                       (dataWtC1.lapV > dataWtC1.splitPoint)* 0.75;

Z = groupsummary(dataWtC1, ["conditionV", "expositionV", "isFirstHalf"], ...
    "median", ["deltaCMV"]);

figure;

for i = 1:length(allConditions) % We iterate through conditions
    condition = allConditions(i);
    color = colors(allConditions == condition, :);
    
    % We get the data of the exposure
    dataByHalfExp1 = Z(Z.conditionV == condition & Z.expositionV == 1, :);
    
    % We plot
    subplot(1, 2, 1)
    
    plot(dataByHalfExp1.isFirstHalf, dataByHalfExp1.median_deltaCMV, 'Color', color, 'LineWidth', 2);
    hold on;
    
    % We get the data of the reexposure
    dataByHalfExp2 = Z(Z.conditionV == condition & Z.expositionV == 2, :);
    
    % We plot
    subplot(1, 2, 2)
    plot(dataByHalfExp2.isFirstHalf, dataByHalfExp2.median_deltaCMV, 'Color', color, 'LineWidth', 2);
    hold on;
    
end

% Set the legend for each subplot
subplot(1, 2, 1);
ylim([-2, 2])
legend({'3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Laps (.25 - first half ; .75 - second half)")
ylabel("Center of mass difference with the mean track place field")
title("First exposure")

subplot(1, 2, 2);
ylim([-2, 2])
xlabel("Laps (.25 - first half ; .75 - second half)")
ylabel("Center of mass difference with the mean track place field")
title("Re-exposure")

hold off;



%% Functions

% Function to get directional place cells based on Foster 2008 criteria
% Note : does not filters out bad place cells / non-pyramidal pc

function [directionalCells, dirOP] = getDirectionalCells(pfDir1, pfDir2)
peakDir1 = cellfun(@(x) max(x), pfDir1);
peakDir2 = cellfun(@(x) max(x), pfDir2);

directionalCells = find(peakDir1./peakDir2 >= 2 | peakDir1./peakDir2 <= 0.5);
dirOP = (peakDir1./peakDir2 >= 2)*1 + (peakDir1./peakDir2 <= 0.5)*2;
dirOP = dirOP(directionalCells);
end