clear

sessions = data_folders_excl_legacy;
file = sessions{7};
[animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
conditionT2 = split(conditionOI, 'x');
conditionT2 = str2double(conditionT2{2});

%% We load the files we need

CSC = load(file + "\extracted_CSC");
CSC = CSC.CSC;
disp("Loaded CSC");

sleep_state = load(file + "\extracted_sleep_state");
sleep_state = sleep_state.sleep_state;

decoded_replay_events = load(file + "\decoded_replay_events");
decoded_replay_events = decoded_replay_events.decoded_replay_events;

%% We get the phase matrix for each cell

[resultMat, meanPhaseVector, allCells] = extract_phase(CSC, sleep_state, decoded_replay_events);

% Now we can z-score the resultMat
resultMatZ = normalize(resultMat, 2, "zscore");

[~, orderPhase] = sort(meanPhaseVector);

figure;
imshow(resultMatZ(orderPhase, :));

%% Analysis : difference in mean phase between appearing / disappearing cells / stable cells / unstable ?

trackOI = 2;

% Only consider appearing or disappearing cells

load(file + "\extracted_place_fields")
pcExp = place_fields.track(trackOI).good_cells;
pcReexp = place_fields.track(trackOI + 2).good_cells;

isPCExp = ismember(allCells, pcExp);
isPCReexp = ismember(allCells, pcReexp);

labels = repelem("Unstable", numel(meanPhaseVector));

labels(isPCExp & isPCReexp) = "Stable";
labels(isPCExp & ~isPCReexp) = "Disappear";
labels(~isPCExp & isPCReexp) = "Appears";

allLabels = unique(labels);

figure;
tiledlayout(1, 4);
nexttile;
circ_plot(meanPhaseVector(labels == "Appears"), "pretty");
title("Appears cells")
nexttile;
circ_plot(meanPhaseVector(labels == "Disappear"), "pretty");
title("Disappear cells")
nexttile;
circ_plot(meanPhaseVector(labels == "Stable"), "pretty");
title("Stable cells")
nexttile;
circ_plot(meanPhaseVector(labels == "Unstable"), "pretty");
title("Unstable cells")

%% Look at the link with refinement

load("D:\Representational_drift_and_replay_analysis\Pierre\Analysis\Cell Level\Statistical_Tests\dataRegression.mat");

matching_data = data(data.animal == animalOI & data.condition == conditionT2, :);

% We remove the unique identifier for each session
ident = floor(matching_data.cell(1)/1000)*1000;
unique_cells_refin = matching_data.cell - ident;

common_cells = intersect(allCells, unique_cells_refin);

refin = matching_data.refinCM(ismember(unique_cells_refin, common_cells));
meanPhaseVectorFilt = meanPhaseVector(ismember(allCells, common_cells));
labelsFilt = labels(ismember(allCells, common_cells));

figure;
for i = 1:numel(allLabels)
    current_label = allLabels(i);
    s = scatter(meanPhaseVectorFilt(labelsFilt == current_label), ...
                 refin(labelsFilt == current_label), 'filled');
    hold on;
end

legend(allLabels);

%% Look at the ponderated participation matrix
% We exclude disappearing / appearing cells

common_cells_stable = intersect(allCells(labels == "Stable"), unique_cells_refin);

subPhaseMat = resultMatZ(ismember(allCells, common_cells_stable), :);

for line = 1:numel(subPhaseMat(:, 1))
    subPhaseMat(line, :) = subPhaseMat(line, :) * refin(line);
end

subPhaseVec = mean(subPhaseMat, 'omitnan');
sunPhaseStd = std(subPhaseMat, 'omitnan');

figure;
bar(1:numel(subPhaseVec), subPhaseVec)
hold on;
errorbar(subPhaseVec, sunPhaseStd)
hold off;
xlim([0, numel(subPhaseVec) + 1]);
xticks(0.5:1:numel(subPhaseVec) + 0.5)
labelsForPlot = string(0:numel(subPhaseVec)) + "π/4";
xticklabels(labelsForPlot)