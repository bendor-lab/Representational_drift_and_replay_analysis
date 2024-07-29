% Look at the link between FR at the end of RUN1 and refinement variance

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
track = [];
cell = [];
meanFiringRateRUN1 = [];
maxFiringRateRUN1 = [];

cmRUN1 = [];
cmRUN2 = [];

refinCM = [];
refinFR = [];
refinPeak = [];

isDoublePeak = [];
pfWidthRUN1 = [];
pfWidthRUN2 = [];

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
    lap_place_fields = temp.lap_place_fields;

    % Track loop

    for trackOI = 1:2

        % Control : Cells that where good place cells during RUN1 and RUN2
        % (no appearing / disappearing cells).
        goodCells = intersect(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);

        %% We get the final place field : mean of the 6 laps following the
        % 16th lap of RUN2

        RUN1LapPFData = lap_place_fields(trackOI).Complete_Lap;
        RUN2LapPFData = lap_place_fields(trackOI + 2).Complete_Lap;

        numberLapsRUN2 = length(RUN2LapPFData);

        finalPlaceField = {};

        % For each cell (good or not), we create the final place field
        for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
            temp = [];

            for lap = 1:6
                temp = [temp; RUN2LapPFData{16 + lap}.smooth{cellID}];
            end

            finalPlaceField(end + 1) = {mean(temp, 'omitnan')};
        end

        cmFPF = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), finalPlaceField);
        frFPF = cellfun(@max, finalPlaceField);
        peakFPF = cellfun(@(x) find(x == max(x), 1), finalPlaceField);

        % If the firing rate is 0 on the whole track, the CM calculation
        % will return NaN. In that case, max firing rate and peak don't
        % have sense, we can NaN  everything.

        frFPF(isnan(cmFPF)) = NaN;
        peakFPF(isnan(cmFPF)) = NaN;


        % Cell loop
        for cellID = 1:length(goodCells)

            cellOI = goodCells(cellID);

            endRUN1PF = RUN1LapPFData{end}.smooth{cellOI};
            startRUN2PF = RUN2LapPFData{1}.smooth{cellOI};

            endRUN1CM = sum(endRUN1PF.*(1:2:200)/sum(endRUN1PF));
            startRUN2CM = sum(startRUN2PF.*(1:2:200)/sum(startRUN2PF));

            endRUN1MaxFR = max(endRUN1PF);
            startRUN2MaxFR = max(startRUN2PF);

            endRUN1MeanFR = RUN1LapPFData{end}.mean_rate(cellOI);

            endRUN1PeakLoc = find(endRUN1PF == max(endRUN1PF), 1);
            startRUN2PeakLoc = find(startRUN2PF == max(startRUN2PF), 1);

            % Like for the FPF, we NaN everything if the CM is NaN
            % Here we can NaN every variables because the metric will be
            % NaN anyway

            if isnan(endRUN1CM) | isnan(startRUN2CM)
                endRUN1MaxFR = NaN;
                startRUN2MaxFR = NaN;
                endRUN1PeakLoc = NaN;
                startRUN2PeakLoc = NaN;
                isCurrentDoublePeak = NaN;
            else
                % We determine if the cell is double peak at the end of RUN1
                TF = islocalmax(endRUN1PF);
                TF(endRUN1PeakLoc) = 0; % remove the main peak
                fr_at_maxs = endRUN1PF(TF);
                loc_at_max = find(TF);

                % If at least 70% of the other max, 
                % and separated by at least 40 cm, considered double peak

                isBig = fr_at_maxs/endRUN1MaxFR >= 0.7;
                isFarFromOther = abs(loc_at_max - endRUN1PeakLoc) >= 20;
                isCurrentDoublePeak = any(isBig & isFarFromOther);
            end

            % We compute the metrics we're interested in

            current_refinCM = abs(cmFPF(cellOI) - endRUN1CM) - abs(cmFPF(cellOI) - startRUN2CM);

            current_refinFR = diffSum(frFPF(cellOI), endRUN1MaxFR) ...
                - diffSum(frFPF(cellOI), startRUN2MaxFR);

            current_refinPeak = abs(peakFPF(cellOI) - endRUN1PeakLoc) - ...
                abs(peakFPF(cellOI) - startRUN2PeakLoc);

            current_width_RUN1 = RUN1LapPFData{end}.half_max_width(cellOI);
            current_width_RUN2 = RUN2LapPFData{1}.half_max_width(cellOI);
            
            % Save the data

            sessionID = [sessionID; fileID];
            animal = [animal; animalOI];
            condition = [condition; conditionOI];
            track = [track; trackOI];
            cell = [cell; ident + cellOI];
            maxFiringRateRUN1 = [maxFiringRateRUN1; endRUN1MaxFR];
            meanFiringRateRUN1 = [meanFiringRateRUN1; endRUN1MeanFR];
            
            cmRUN1 = [cmRUN1; endRUN1PeakLoc];
            cmRUN2 = [cmRUN2; startRUN2PeakLoc];
            refinCM = [refinCM; current_refinPeak];
            refinFR = [refinFR; current_refinFR];
            refinPeak = [refinPeak; current_refinPeak];
            isDoublePeak = [isDoublePeak; isCurrentDoublePeak];
            pfWidthRUN1 = [pfWidthRUN1; current_width_RUN1];
            pfWidthRUN2 = [pfWidthRUN2; current_width_RUN2];

        end
    end
end

% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

data = table(sessionID, animal, condition, cell, ...
    maxFiringRateRUN1, meanFiringRateRUN1, refinCM, refinFR, refinPeak, ...
    cmRUN1, cmRUN2, isDoublePeak, pfWidthRUN1, pfWidthRUN2);

%% Basic stats

figure;
tiledlayout(1, 2);
nexttile;
histogram(cmRUN1, 30);
title("End RUN1 CM")
xlabel("Position (cm)");
ylabel("Count");
nexttile;
histogram(cmRUN2, 30);
xlabel("Position (cm)");
ylabel("Count");
title("Start RUN2 CM")

% CM mostly in the middle because a lot of double peak PC at the reward
% location

figure;
tiledlayout(1, 3);
nexttile;
histogram(maxFiringRateRUN1, 30);
xlabel("Firing rate - End RUN1");
ylabel("Count");

nexttile;
scatter(maxFiringRateRUN1, refinCM);
xlabel("Firing rate - End RUN1");
ylabel("CM refinement");

nexttile;
filtered_data = data(data.maxFiringRateRUN1 > 1 & data.meanFiringRateRUN1 < 5, :);
scatter(filtered_data.meanFiringRateRUN1, filtered_data.refinCM);
xlabel("Firing rate - End RUN1");
ylabel("CM refinement");

% More variance in the refinement with less firing rate

% figure;
% discreteFR = discretize(maxFiringRateRUN1, min(maxFiringRateRUN1):5:max(maxFiringRateRUN1));
% boxchart(discreteFR, data.refinCM)

%% Sucessive removal of center of mass refinement to see which one
% participate in the effect

data.logCondC = log2(data.condition) - mean(log2(data.condition));
variable = data.maxFiringRateRUN1;
Q = quantile(variable, 0.995);
step = Q/200;
cutoff = 0:step:Q;

p_values = [];
b = [];
number_obs = [];

for cID = 1:numel(cutoff)
    if mod(cID, 50) == 0
        disp(cID);
    end

    subset_data = data(variable >= cutoff(cID), :);
    lme = fitlme(subset_data, "refinCM ~ logCondC + (1|animal) + (1|cell:animal)");
    p_value = lme.Coefficients(2, 6).pValue;
    b_value = lme.Coefficients(2, 2).Estimate;
    p_values(end + 1) = p_value;
    number_obs(end + 1) = numel(subset_data.cell);
    b(end + 1) = b_value;
end

figure;
plot(cutoff, smooth(1./p_values), "LineWidth", 2)
hold on;
plot(cutoff, number_obs, "Color", "#7E2F8E", "LineWidth", 1.3)
plot(cutoff, abs(b), "Color", "#EDB120", "LineWidth", 1.3)
set(gca, 'YScale', 'log')
yline(1/0.05, 'r', 'p < .05');
xlabel("Mean firing rate hi-pass cutoff")
ylabel("1/p-value");
legend({"p-value", "nb. obs.", "estimate"})
title("Successive filtering of data based on FR");

% Seems like we don't really care about what's under 1.2 Hz

%% Removing part of the neurons

data.logCondC = log2(data.condition) - mean(log2(data.condition));
variable = data.maxFiringRateRUN1;
Q = quantile(variable, 0.995);
step = Q/20;
cutoff = 0:step:Q;

p_values = [];
b = [];
number_obs = [];

for cID = 1:numel(cutoff)-1
    if mod(cID, 50) == 0
        disp(cID);
    end

    subset_data = data;
    subset_data(variable >= cutoff(cID) & ...
                variable < cutoff(cID + 1), :) = [];

    lme = fitlme(subset_data, "refinCM ~ logCondC + (1|animal) + (1|cell:animal)");
    p_value = lme.Coefficients(2, 6).pValue;
    b_value = lme.Coefficients(2, 2).Estimate;
    p_values(end + 1) = p_value;
    number_obs(end + 1) = numel(subset_data.cell);
    b(end + 1) = b_value;
end

figure;
plot(cutoff(1:end-1), smooth(1./p_values), "LineWidth", 2)
hold on;
plot(cutoff(1:end-1), number_obs, "Color", "#7E2F8E", "LineWidth", 1.3)
plot(cutoff(1:end-1), abs(b), "Color", "#EDB120", "LineWidth", 1.3)
set(gca, 'YScale', 'log')
yline(1/0.05, 'r', 'p < .05');
xlabel("Mean firing rate hi-pass cutoff")
ylabel("1/p-value");
legend({"p-value", "nb. obs.", "estimate"})
title("Successive removal of slices of data based on RF")

% Removing max FR < 5 Hz seems to decrease the p-value significantly

%% Same analysis directly on center of mass

data.logCondC = log2(data.condition) - mean(log2(data.condition));
variable = abs(data.refinCM);
Q = quantile(variable, 0.995);
step = Q/200;
cutoff = 0:step:Q;

p_values_inc = [];
p_values_dec = [];
b_inc = [];
b_dec = [];
number_obs_inc = [];
number_obs_dec = [];

for cID = 1:numel(cutoff)
    if mod(cID, 50) == 0
        disp(cID);
    end
    
    % Increasing
    subset_data = data(variable >= cutoff(cID), :);
    lme = fitlme(subset_data, "refinCM ~ logCondC + (1|animal) + (1|cell:animal)");
    p_value = lme.Coefficients(2, 6).pValue;
    b_value = lme.Coefficients(2, 2).Estimate;

    p_values_inc(end + 1) = p_value;
    number_obs_inc(end + 1) = numel(subset_data.cell);
    b_inc(end + 1) = b_value;
    
    % Decreasing
    subset_data = data(variable < cutoff(numel(cutoff) + 1 - cID), :);
    lme = fitlme(subset_data, "refinCM ~ logCondC + (1|animal) + (1|cell:animal)");
    p_value = lme.Coefficients(2, 6).pValue;
    b_value = lme.Coefficients(2, 2).Estimate;

    p_values_dec(end + 1) = p_value;
    number_obs_dec(end + 1) = numel(subset_data.cell);
    b_dec(end + 1) = b_value;

end

figure;
tiledlayout(1, 2);
nexttile;
plot(cutoff, smooth(1./p_values_inc), "LineWidth", 2)
hold on;
plot(cutoff, number_obs_inc, "Color", "#7E2F8E", "LineWidth", 1.3)
plot(cutoff, abs(b_inc), "Color", "#EDB120", "LineWidth", 1.3)
set(gca, 'YScale', 'log')
yline(1/0.05, 'r', 'p < .05');
xlabel("CM refin. hi-pass cutoff")
ylabel("1/p-value");
legend({"p-value", "nb. obs.", "estimate"})
title("Successive filtering of data based on refinement - increasing");

nexttile;
plot(cutoff(1:end-1), smooth(1./p_values_dec), "LineWidth", 2)
hold on;
plot(cutoff(1:end-1), number_obs_dec, "Color", "#7E2F8E", "LineWidth", 1.3)
plot(cutoff(1:end-1), abs(b_dec), "Color", "#EDB120", "LineWidth", 1.3)
set(gca, 'YScale', 'log')
yline(1/0.05, 'r', 'p < .05');
xlabel("CM refin. low-pass cutoff")
ylabel("1/p-value");
legend({"p-value", "nb. obs.", "estimate"})
title("Decreasing");
xticks(0:10:floor(Q));
xticklabels(floor(Q):-10:0);

% Refinement between 0 and 30 seems to be the most important for the effect

%% With pooling back

data.logCondC = log2(data.condition) - mean(log2(data.condition));
variable = abs(data.refinCM);
Q = quantile(variable, 0.995);
step = Q/10;
cutoff = 0:step:Q;

p_values_inc = [];
b_inc = [];
number_obs_inc = [];

for cID = 1:numel(cutoff) - 1
    if mod(cID, 50) == 0
        disp(cID);
    end
    
    % Increasing
    subset_data = data;
    subset_data(variable >= cutoff(cID) & variable < cutoff(cID + 1), :) = [];
    lme = fitlme(subset_data, "refinCM ~ logCondC + (1|animal) + (1|cell:animal)");
    p_value = lme.Coefficients(2, 6).pValue;
    b_value = lme.Coefficients(2, 2).Estimate;

    p_values_inc(end + 1) = p_value;
    number_obs_inc(end + 1) = numel(subset_data.cell);
    b_inc(end + 1) = b_value;
    

end

figure;
plot(cutoff(1:end-1), smooth(1./p_values_inc), "LineWidth", 2)
hold on;
plot(cutoff(1:end-1), number_obs_inc, "Color", "#7E2F8E", "LineWidth", 1.3)
plot(cutoff(1:end-1), abs(b_inc), "Color", "#EDB120", "LineWidth", 1.3)
set(gca, 'YScale', 'log')
yline(1/0.05, 'r', 'p < .05');
xlabel("CM refin. range pooled")
ylabel("1/p-value");
legend({"p-value", "nb. obs.", "estimate"})
title("Successive pooling of data based on refinement");

% Coherent, plateau after 30 cm of CM refinement. 

%% Is it a distribution shift ?

sub_data = data(data.cell == 18, :);
bins = min(sub_data.refinCM):5:max(sub_data.refinCM);
figure;
tiledlayout(1, 2);
nexttile;
histogram(sub_data.refinCM(sub_data.condition == 16), bins);
xlabel("CM refinement");
ylabel("Count")
title("16 laps");
nexttile;
histogram(sub_data.refinCM(sub_data.condition ~= 16), bins);
xlabel("CM refinement");
ylabel("Count")
title("1 laps");
linkaxes;

% Seems to be an overall SHIFT rather that an effect confined to some cells. 

%% Are double peak cells subject to this effect ?

% 10 % of all cells.

% 1. CM Negative refinement for those cells, Peak positive refinement
data.logCondC = log2(data.condition) - mean(log2(data.condition));
data.isDoubleC = data.isDoublePeak - 0.5;
lme = fitlme(data, "refinCM ~ logCondC + isDoubleC + (1|animal) + (1|cell:animal)");
disp(lme)

% 2. When only using those, no significant for CM but sig. for Peak
lme = fitlme(data(data.isDoublePeak == 1, :), "refinCM ~ logCondC + (1|animal) + (1|cell:animal)");
disp(lme)

% 3. When excluding those, effect is slightly stronger with CM/ not with
% Peak
lme = fitlme(data(data.isDoublePeak ~= 1, :), "refinCM ~ logCondC + (1|animal) + (1|cell:animal)");
disp(lme)


%% Testing criterias

% filt_data = data(data.refinCM >= 0 & data.refinCM < 30, :); % This filter
% lower the estimate

filt_data = data(data.maxFiringRateRUN1 >= 10 & data.maxFiringRateRUN1 < 25, :); % This filter raise the estimate for CM
fitlme(filt_data, "refinCM ~ logCondC + (1|animal) + (1|cell:animal)")

%% Looking at common cells vs. unique cells

unique_cells = unique(data.cell);
counts = histcounts(categorical(data.cell));
common_cells = unique_cells(counts == 2);
specific_cells = unique_cells(counts == 1); 
data.isCommon = ismember(data.cell, common_cells) - 0.5;

fitlme(data, "refinCM ~ logCondC + isCommon + (1|animal) + (1|cell:animal)")


%% II - Why are the cells remapping ? 

%% 1. Testing the homogeneity of refinement

allPositions = 0:5:200;
discreteCMRUN1ID = discretize(data.cmRUN1, allPositions);
discreteCMRUN2ID = discretize(data.cmRUN2, allPositions);
isNanOne = isnan(discreteCMRUN1ID) | isnan(discreteCMRUN2ID);
discreteCMRUN1ID(isNanOne) = [];
discreteCMRUN2ID(isNanOne) = [];
discreteCMRUN1 = allPositions(discreteCMRUN1ID);
discreteCMRUN2 = allPositions(discreteCMRUN2ID);

figure;
tiledlayout(2, 2);
nexttile;
boxchart(discreteCMRUN1ID, data.refinCM(~isNanOne));
xlabel("CM position (cm)");
ylabel("CM refinement (cm)");
title("End RUN1")
xticks(1:2:41);
xticklabels(allPositions(1:2:end))
grid on;

nexttile;
boxchart(discreteCMRUN2ID, data.refinCM(~isNanOne));
xlabel("CM position (cm)");
ylabel("CM refinement (cm)");
title("Start RUN2")
xticks(1:2:41);
xticklabels(allPositions(1:2:end))
grid on;

nexttile;
[counts, edgesRUN1, edgesRUN2] = histcounts2(discreteCMRUN1, discreteCMRUN2, 5:5:196, 5:5:196);

imagesc(imgaussfilt(counts, 1))
colorbar
xlabel('End RUN1 CM')
ylabel('Start RUN2 CM')
title('CM change over sleep probability matrix')

% Refinement seems homogeneous

%% 1.5. Is it linked with place field width ?

% aa. Do we see difference in place field width depending on the condition
% ?
data.logCondC = log2(data.condition) - mean(log2(data.condition));
lme = fitlme(data, "pfWidthRUN1 ~ logCondC + (1|animal) + (1|cell:animal)")
% Yes, the more experience you have, wider is your PF (coherent with litt.)


% a. do we see place field width refinement ? 
data.diffWidth = data.pfWidthRUN2 - pfWidthRUN1;
data.diffWidth(abs(data.diffWidth) > 150) = NaN; % Remove abherent values

lme = fitlme(data, "diffWidth ~ logCondC + (1|animal) + (1|cell:animal)")
% Seems that place field is reduced with more experience. Quite small
% effect.

% b. Is refinement predicted by place field width ? 
lme = fitlme(data, "refinPeak ~ logCondC + pfWidthRUN1 + (1|animal) + (1|cell:animal)")
% WIDER place fields are less refined (CM, Peak).

%% 2. Is there a link between redudancy of coding and refinement ?

% Redudancy = minimum distance with another cell CM

redudancy_RUN1 = [];
redudancy_RUN2 = [];

for sID = 1:19
    for trackOI = 1:2
        sub_data = data(data.sessionID == sID & track == trackOI, :);
        allRedudancyR1 = arrayfun(@(a) min(abs(a - sub_data.cmRUN1(sub_data.cmRUN1 ~= a))), sub_data.cmRUN1);
        allRedudancyR2 = arrayfun(@(a) min(abs(a - sub_data.cmRUN2(sub_data.cmRUN2 ~= a))), sub_data.cmRUN2);
        redudancy_RUN1 = [redudancy_RUN1; allRedudancyR1];
        redudancy_RUN2 = [redudancy_RUN2; allRedudancyR2];
    end
end

data.redudancy_RUN1C = redudancy_RUN1 - mean(redudancy_RUN1, 'omitnan');
data.redudancy_RUN2C = redudancy_RUN2 - mean(redudancy_RUN2, 'omitnan');
improvement_redudancy = redudancy_RUN2 - redudancy_RUN1;
data.improvement_redudancyC = improvement_redudancy - mean(improvement_redudancy, 'omitnan');

lme = fitlme(data, "refinCM ~ logCondC + pfWidthRUN1 + redudancy_RUN1C + (1|animal) + (1|cell:animal)")
% Seem that the LESS redundant you are, the MORE refinement you get
% Improvement in redudancy linked with CM refinement

lme = fitlme(data, "improvement_redudancyC ~ logCondC + (1|animal) + (1|cell:animal)")
% No significant improvement in redudancy over sleep

% Redudancy = proportion of other cells in a 20 cm perimeter around you

redudancy_RUN1 = [];
redudancy_RUN2 = [];

for sID = 1:19
    for trackOI = 1:2
        sub_data = data(data.sessionID == sID & track == trackOI, :);
        nbCells = numel(sub_data.cell);
        oneIsNan = isnan(sub_data.cmRUN1) | isnan(sub_data.cmRUN2);
        allRedudancyR1 = arrayfun(@(a) (sum(abs(a - sub_data.cmRUN1) < 10) - 1)/nbCells, sub_data.cmRUN1);
        allRedudancyR2 = arrayfun(@(a) (sum(abs(a - sub_data.cmRUN2) < 10) - 1)/nbCells, sub_data.cmRUN2);
        allRedudancyR1(oneIsNan) = NaN;
        allRedudancyR2(oneIsNan) = NaN;
        redudancy_RUN1 = [redudancy_RUN1; allRedudancyR1];
        redudancy_RUN2 = [redudancy_RUN2; allRedudancyR2];
    end
end

data.redudancy_RUN1C = redudancy_RUN1 - mean(redudancy_RUN1, 'omitnan');
data.redudancy_RUN2C = redudancy_RUN2 - mean(redudancy_RUN2, 'omitnan');
improvement_redudancy = redudancy_RUN1 - redudancy_RUN2;
data.improvement_redudancyC = improvement_redudancy - mean(improvement_redudancy, 'omitnan');

lme = fitlme(data, "refinCM ~ logCondC + pfWidthRUN1 + redudancy_RUN1C + (1|animal) + (1|cell:animal)")
% Seem that the LESS redundant you are, the MORE refinement you get (confirmation)
% Moreover, the MORE refinement you get, the MORE redundant you are on RUN2.
% -> refinCM is linked with raise in the redundancy over sleep

lme = fitlme(data, "improvement_redudancyC ~ logCondC + (1|animal) + (1|cell:animal)")
% Increase over sleep of redundancy dependent on the condition Very small
% effect (cant trust)

% Maybe redudancy is something you WANT. Interesting result but don't work
% to predict Peak. Maybe try with proximity based on peak. 
% Could be explained by wide / narrow place fields - not really

%% 3. Link between cross-track proximity and refinement ?
sub_data = data(data.isDoublePeak == 0, :);

unique_cells = unique(sub_data.cell);
counts = histcounts(categorical(sub_data.cell));
common_cells = unique_cells(counts == 2);

sub_data = data(ismember(data.cell, common_cells), :);


cell = [];
animal = [];
condition = [];
cmR1T1 = [];
cmR1T2 = [];
cmR2T1 = [];
cmR2T2 = [];
T1_refin = [];
T2_refin = [];
distanceToOtherTrackR1 = [];
distanceToOtherTrackR2 = [];

for sID = 1:19
    current_data = sub_data(sub_data.sessionID == sID, :);
    c_animal = current_data.animal(current_data.condition ~= 16);
    c_condition = current_data.condition(current_data.condition ~= 16);
    c_T1_refin = current_data.refinCM(current_data.condition == 16);
    c_T2_refin = current_data.refinCM(current_data.condition ~= 16);

    distMidR1T1 = abs(100 - current_data.cmRUN1(current_data.condition == 16));
    distMidR1T2 = abs(100 - current_data.cmRUN1(current_data.condition ~= 16));
    distMidR2T1 = abs(100 - current_data.cmRUN2(current_data.condition == 16));
    distMidR2T2 = abs(100 - current_data.cmRUN2(current_data.condition ~= 16));

    c_distanceToOtherTrackR1 = abs(distMidR1T1 - ...
                                   distMidR1T2);
    c_distanceToOtherTrackR2 = abs(distMidR2T1 - ...
                                   distMidR2T2);

    cell = [cell; repelem(sID, numel(c_animal), 1)];
    animal = [animal; c_condition];
    condition = [condition; c_condition];
    T1_refin = [T1_refin; c_T1_refin];
    T2_refin = [T2_refin; c_T2_refin];
    distanceToOtherTrackR1 = [distanceToOtherTrackR1; c_distanceToOtherTrackR1];
    distanceToOtherTrackR2 = [distanceToOtherTrackR2; c_distanceToOtherTrackR2];

    cmR1T1 = [cmR1T1; current_data.cmRUN1(current_data.condition == 16)];
    cmR1T2 = [cmR1T2; current_data.cmRUN1(current_data.condition ~= 16)];
    cmR2T1 = [cmR2T1; current_data.cmRUN2(current_data.condition == 16)];
    cmR2T2 = [cmR2T2; current_data.cmRUN2(current_data.condition ~= 16)];


end

crossTrack_data = table(cell, animal, condition, T1_refin, T2_refin, ...
                distanceToOtherTrackR1, distanceToOtherTrackR2, cmR1T1, cmR1T2, cmR2T1, cmR2T2);

% Is the crosstrack distance predictive of refinement in T1 / T2 ?
crossTrack_data.logCondC = log2(crossTrack_data.condition) - mean(log2(crossTrack_data.condition));
crossTrack_data.reducDist = crossTrack_data.distanceToOtherTrackR1 - crossTrack_data.distanceToOtherTrackR2;

lme = fitlme(crossTrack_data, "T1_refin ~ logCondC + distanceToOtherTrackR1 + (1|animal) + (1|cell:animal)")
% Not for track 1
lme = fitlme(crossTrack_data, "T2_refin ~ logCondC + distanceToOtherTrackR1 + (1|animal) + (1|cell:animal)")
% It is for track 2 ! The furthest from the other track you are, the more
% you refine - works also for Peak !

scatter(crossTrack_data.T2_refin, crossTrack_data.distanceToOtherTrackR1)

lme = fitlme(crossTrack_data, "T2_refin ~ logCondC + distanceToOtherTrackR2 + (1|animal) + (1|cell:animal)")
% Opposite relationship after sleep : if you refined more, you're CLOSER to
% the other track - not true for Peak

lme = fitlme(crossTrack_data, "reducDist ~ logCondC + (1|animal) + (1|cell:animal)")

% -> Really surprising. Why are the two tracks becoming similar ???
% Can you predict the CM on the other track based on CM of the other ?
% not for peak.



figure;
tiledlayout(2, 4);

nexttile;
scatter(cmR1T1, cmR2T1)
title("T1 - R1 / R2")

nexttile;
scatter(cmR1T2, cmR2T2)
title("T2 - R1 / R2")

nexttile;
scatter(cmR1T1, cmR1T2)
title("R1 - T1 / T2")

nexttile;
scatter(cmR2T1, cmR2T2)
title("R2 - T1 / T2")

nexttile([1 4]);
scatter(crossTrack_data.distanceToOtherTrackR1, crossTrack_data.distanceToOtherTrackR2)
hold on;
plot(0:max(crossTrack_data.distanceToOtherTrackR1), 0:max(crossTrack_data.distanceToOtherTrackR1), 'r')
xlabel("Distance between T1 / T2 CM before sleep (cm)")
ylabel("Distance between T1 / T2 CM after sleep (cm)")