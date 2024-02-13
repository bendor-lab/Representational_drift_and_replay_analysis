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
deltaCMVFirstLap = [];

%% Extraction & computation

for cFile = sessions
    disp(cFile);
    file = cFile{1}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    
    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    
    load(file + "\extracted_directional_lap_place_fields.mat");
    
    for direction = 1:2
        for track = 1:2
            for exposition = 1:2
                vTrack = track + exposition - mod(exposition, 2); % Map parameters to 1, 2, 3, 4
                
                % Get the good lap data
                if direction == 1
                    lapData = lap_directional_place_fields(vTrack).dir1.Complete_Lap;
                else
                    lapData = lap_directional_place_fields(vTrack).dir2.Complete_Lap;
                end
           
                nbLaps = length(lapData);
                
                for lap = 1:nbLaps
                    currentData = lapData{lap};
                    
                    nbCells = length(currentData.raw);
                    goodCells = currentData.good_cells;
                    nbGoodCells = length(currentData.good_cells);
                    
                    % We get the main variables we need
                    % We first take all the pyramidal cells then all the good
                    % place cells on the track
                    
                    deltaCM = currentData.centre_of_mass - lapData{1}.centre_of_mass;
                    deltaCM = deltaCM(goodCells);
                    
                    if direction == 2
                        deltaCM = - deltaCM;
                    end
                    
                    % We add the data
                    
                    animalV = [animalV; repelem(animalOI, nbGoodCells)'];
                    conditionV = [conditionV; repelem(conditionOI, nbGoodCells)'];
                    trackV = [trackV; repelem(track, nbGoodCells)'];
                    directionV = [directionV; direction];
                    expositionV = [expositionV; repelem(exposition, nbGoodCells)'];
                    lapV = [lapV; repelem(lap, nbGoodCells)'];
                    cellV = [cellV; goodCells'];
                    deltaCMVFirstLap = [deltaCMVFirstLap; deltaCM'];
                end
            end
        end
    end
end

% We mutate to only have the condition, not 16x...
conditionV(trackV == 1) = 16;
newConditions = split(conditionV(trackV ~= 1), 'x');
conditionV(trackV ~= 1) = newConditions(:, 2);

data = table(animalV, conditionV, trackV, lapV, expositionV, cellV, deltaCMVFirstLap);

% We mean by condition, exopsition and lap
G = groupsummary(data, ["conditionV", "expositionV", "lapV"], ...
    "mean", ["deltaCMVFirstLap"]);

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
        scatter(1, dataByLapExp1.mean_deltaCMVFirstLap, 30, color, "filled");
    else
        plot(dataByLapExp1.lapV, dataByLapExp1.mean_deltaCMVFirstLap, 'Color', color, 'LineWidth', 2);
    end
    
    hold on;
    
    % We get the lap data of the reexposure
    dataByLapExp2 = G(G.conditionV == condition & G.expositionV == 2, :);
    % We crop the data at lap 16
    dataByLapExp2 = dataByLapExp2(1:16, :);
    
    % We plot
    subplot(1, 2, 2)
    plot(dataByLapExp2.lapV, dataByLapExp2.mean_deltaCMVFirstLap, 'Color', color, 'LineWidth', 2);
    
    hold on;
    
end

% Set the legend for each subplot
subplot(1, 2, 1);
% ylim([15, 45])
legend({'1 lap', '2 laps', '3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Lap")
ylabel("Center of mass difference with the first Lap")
title("First exposure")

subplot(1, 2, 2);
% ylim([15, 45])
xlabel("Lap")
ylabel("Center of mass difference with the Lap")
title("Re-exposure")

hold off;