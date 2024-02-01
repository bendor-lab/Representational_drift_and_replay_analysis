% We plot the place field skewness for each condition and each exposure
% WORK IN PROGRESS

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

listFilesToTest = ["\..\..\Data\population_vector_laps.mat", "\..\..\Data\population_vector_lapsLap16RUN1.mat", ...
    "\..\..\Data\population_vector_lapsLap16RUN2.mat"];

for path = listFilesToTest(1)
    
    % We get the PV file
    load(PATH.SCRIPT + path);
    
    % Create a struct to save the data
    finalData = struct("condition", {}, "exposure", {}, "mat", {});
    
    matCorrT1 = repelem(NaN, length(population_vector_laps), 40); % We overshot the size to be sure
    matCorrT3 = repelem(NaN, length(population_vector_laps), 40); 
    
    % We iterate through conditions
    counterT1 = 1;
    counterT3 = 1;
    
    for conditionOI = unique({population_vector_laps.condition})
        matchingData = population_vector_laps(string({population_vector_laps.condition}) == conditionOI);
        
        matCorrT2 = repelem(NaN, length(matchingData), 40);
        matCorrT4 = repelem(NaN, length(matchingData), 40);
        
        counterT2 = 1;
        counterT4 = 1;
        
        for trackOI = 1:4
            matchingData2 = matchingData([matchingData.track] == trackOI);
            
            for sessionID = 1:length(matchingData2)
                currentSkewnessVector = {matchingData2(sessionID).allLaps.pvCorrelationNorm};
                currentSkewnessVector = cellfun(@(x) median(x, 'omitnan'), currentSkewnessVector);
                lenVec = length(currentCorrelationVector);

                if trackOI == 1
                    matCorrT1(counterT1, 1:lenVec) = currentCorrelationVector;
                    counterT1 = counterT1 + 1;
                elseif trackOI == 2
                    matCorrT2(counterT2, 1:lenVec) = currentCorrelationVector;
                    counterT2 = counterT2 + 1;
                elseif trackOI == 3
                    matCorrT3(counterT3, 1:lenVec) = currentCorrelationVector;
                    counterT3 = counterT3 + 1;
                else
                    matCorrT4(counterT4, 1:lenVec) = currentCorrelationVector;
                    counterT4 = counterT4 + 1;
                end
            end 
        end
        
        % We can save the data 
        condition = split(conditionOI, "x");
        condition = str2double(condition(end));
        
        finalData = [finalData ; struct("condition", {condition}, "exposure", {1}, "mat", {matCorrT2})];
        finalData = [finalData ; struct("condition", {condition}, "exposure", {2}, "mat", {matCorrT4})];
        
    end
    
    finalData = [finalData ; struct("condition", {16}, "exposure", {1}, "mat", {matCorrT1})];
    finalData = [finalData ; struct("condition", {16}, "exposure", {2}, "mat", {matCorrT3})];
end

%% Now we can mean the data and plot

% Mean

for lineNb = 1:length(finalData)
    finalData(lineNb).mat = mean(finalData(lineNb).mat, 'omitnan');
    if finalData(lineNb).exposure == 1
        finalData(lineNb).mat = finalData(lineNb).mat(1:finalData(lineNb).condition);
    else
        finalData(lineNb).mat = finalData(lineNb).mat(1:16);
    end
end

% Create a figure
figure; hold on;

% Define a colormap for the conditions
conditions = unique([finalData.condition]);
colors = lines(length(conditions));

% Loop through the structure
for i = 1:length(finalData)
    % Select the subplot based on exposure
    subplot(1, 2, finalData(i).exposure); hold on;
    
    % Assign a color based on condition
    color = colors(conditions == finalData(i).condition, :);
    
    % If we're in condition 1 lap 1st exposure, we can't plot so we scatter
    if finalData(i).condition == 1 && finalData(i).exposure == 1
        scatter([1], [finalData(i).mat], 30, color, "filled");
        continue;
    end
    
    % Plot the vector
    plot(finalData(i).mat, 'Color', color, 'LineWidth', 2);
        
end

% Set the legend for each subplot
subplot(1, 2, 1);
ylim([0, 0.5])
legend({'1 lap', '2 laps', '3 laps', '4 laps', '8 laps', '16 laps'});
legend('show');
xlabel("Lap")
ylabel("Correlation with the FPF")
title("First exposure")

subplot(1, 2, 2);
ylim([0, 0.5])
xlabel("Lap")
ylabel("Correlation with the FPF")
title("Re-exposure")