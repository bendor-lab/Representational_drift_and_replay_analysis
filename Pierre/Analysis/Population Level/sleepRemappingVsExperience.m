% Analysis : try to fit an curve to the representation
% stabilisation during RUN1, for each animal (we use 16 laps trials).

% After that, we fit the function to the other conditions to try to get the
% stabilizing effect of one supplementary lap (without sleep).

% We can then compare if one other lap of experience gives the same savings
% as sleep.

% This analysis is population wise

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

load(PATH.SCRIPT + "/../../Data/population_vector_laps.mat");

sessions = data_folders_excl; % Use the function to get all the file paths
allAnimals = unique(string({population_vector_laps.animal}));
allConditions = unique(string({population_vector_laps.condition}));

condition = [];
animal = [];
day = [];
track = [];
refinPOST1 = [];
refinExtraRUN1 = [];

% Function we want to fit the data with

% Here, we take a classical exponential decay function, that starts at 0
% and finishes at 1

% fitfun = fittype( @(a,b, x) a + log(x)*b);
% fitfun = fittype( @(a, b, c, x) a*exp(-b*x)+c);
fitfun = fittype( @(a, b, x) a*exp(-b*x)+1); % seenms to best fit all the data


%% We fit the log function to the RUN1 - 16 laps data 

paramFitted = dictionary();

for anID = 1:numel(allAnimals)
    currentAnimal = allAnimals(anID);

    % We get all the RUN1 - Track 1 data
    matchingData = population_vector_laps(string({population_vector_laps.animal}) == currentAnimal & ...
                   [population_vector_laps.track] == 1);

    matchingDataR2 = population_vector_laps(string({population_vector_laps.animal}) == currentAnimal & ...
                   [population_vector_laps.track] == 3);

    % We get the mean trajectory of the correlation across laps

    meanTrajR1 = NaN(numel(matchingData), 20);

    for i = 1:numel(matchingData)
        corrTraj = cellfun(@(x) median(x, 'omitnan'), {matchingData(i).allLaps(:).pvCorrelation});
        meanTrajR1(i, 1:numel(corrTraj)) = corrTraj;
    end

    meanTrajR1 = mean(meanTrajR1(:, 1:16), 'omitnan')';

    meanTrajR2 = NaN(numel(matchingDataR2), 20);

    for i = 1:numel(matchingDataR2)
        corrTraj = cellfun(@(x) median(x, 'omitnan'), {matchingDataR2(i).allLaps(:).pvCorrelation});
        meanTrajR2(i, 1:numel(corrTraj)) = corrTraj;
    end

    meanTrajR2 = mean(meanTrajR2(:, 1:16), 'omitnan')';

    meanTraj = [meanTrajR1; meanTrajR2];

    X = 1:32;
    X = X';

    % Now that we have our learning curve, we can fit a log to it
    f = fit(X, meanTraj, fitfun, 'StartPoint', [-1, 2]);

    figure;
    plot(f, X, meanTraj)

    paramFitted{currentAnimal} = [f.a, f.b]; % We only save the b parameter, the a will be
    % individually re-fitted

end

%% We get the savings for each session

for cID = 1:numel(sessions)
    disp(cID);
    file = sessions(cID);
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    matchingLineDataBool = string({population_vector_laps.animal}) == animalOI & string({population_vector_laps.condition}) == conditionOI;
    matchingLinesData = population_vector_laps(matchingLineDataBool);

    fitting_param = paramFitted{animalOI}; % Retrieve the fitting parameter

    % We declare the function to only fit the intercept
    fitfunIntercept = fittype( @(a, x) a*exp(-fitting_param(2)*x) + 1);

    for trackOI = 1:2

        % We get the matching data for RUN1 / RUN2
        dataRUN1 = matchingLinesData([matchingLinesData.track] == trackOI);
        dataRUN2 = matchingLinesData([matchingLinesData.track] == trackOI + 2);

        realRefin = median(dataRUN2.allLaps(1).pvCorrelation, 'omitnan') - ...
                    median(dataRUN1.allLaps(end).pvCorrelation, 'omitnan');

        % We get the theorical experience refinement with 1 more lap
        corrTraj = cellfun(@(x) median(x, 'omitnan'), {dataRUN1.allLaps(:).pvCorrelation});

        % We fit the intercept
        X = 1:numel(corrTraj);
        X = X';
        corrTraj = corrTraj';
        
        fittedFunc = fit(X, corrTraj, fitfunIntercept);

        % Now we can calculate the value of the function for lap + 1
        extraValue = fittedFunc(numel(X) + 1);

        fittedRefin = extraValue - corrTraj(end);

        % We add the data

        condition = [condition; string(conditionOI)];
        animal = [animal; animalOI];
        track = [track; trackOI];
        refinPOST1 = [refinPOST1; realRefin];
        refinExtraRUN1 = [refinExtraRUN1; fittedRefin];
    end
end

% We mutate to only have the condition, not 16x...
condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

animal = string(animal);
condition = str2double(condition);

data = table(animal, condition, refinPOST1, refinExtraRUN1);

% We then can do a statistical test to see if we have a greater sleep
% improvement that only due to experience
% Mixed-model

% We log and center the condition
data.log_condition_centered = log(data.condition) - mean(log(data.condition));

% 1. Check if we have significant refinement across sleep, and if
% effet of condition

lm = fitlme(data,'refinPOST1 ~ log_condition_centered + (1|animal)');
disp(lm);

figure;
scatter(data.log_condition_centered, data.refinPOST1)
xlabel("Centered Condition (log)");
ylabel("Over sleep refinement");


% 2. Check if we have significant refinement with 1 more lap, and if
% effet of condition

lm = fitlme(data,'refinExtraRUN1 ~ log_condition_centered + (1|animal)');
disp(lm);

figure;
scatter(data.log_condition_centered, data.refinExtraRUN1)
xlabel("Centered Condition (log)");
ylabel("One more lap refinement");

% 3. Check if the sleep effect is bigger than the 1 more lap effect, and if
% effet of condition

data.Wdiff = data.refinPOST1 - data.refinExtraRUN1;

lm = fitlme(data,'Wdiff ~ log_condition_centered + (1|animal)');
disp(lm);

figure;
scatter(data.log_condition_centered, data.Wdiff)
xlabel("Centered Condition (log)");
ylabel("Refinment difference between sleep and experience");

%% Plot

Y = [data.refinPOST1; data.refinExtraRUN1];
X = [data.condition; data.condition];
L = [repelem("Sleep", numel(data.refinPOST1)) repelem("Exp", numel(data.refinPOST1))]';

t = table(X, Y, L);

boxchart(t.X, t.Y,'GroupByColor', t.L)

xlabel("Number of laps ran - RUN1")
ylabel('Refinement')
legend({"1 more lap refinement", "Sleep refinement"})
