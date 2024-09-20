%% Script to analyze the learning curves of the representation

clear
load("data_learning.mat")


%% Examples of slopes in pv-correlation time serie

sID = 10;
figure;
subplot(1, 2, 1)
subset = data(data.sessionID == sID & data.condition == 16 ...
    & data.exposure == 1, :);

getSlopes(subset, 0, true);
title("First exposure - 16 laps")

subplot(1, 2, 2)
subset = data(data.sessionID == sID & data.condition == 16 ...
    & data.exposure == 2, :);

getSlopes(subset, 0, true);
title("Second exposure - 16 laps")

legend({"PV-correlation", "Early linear fit", "Late linear fit"}, ...
    "Location", "southeast");

linkaxes()

%% First plot - First 4 > Last 4 RUN1

slopes_start = [];
slopes_end = [];

for sID = 1:19
    subset = data(data.sessionID == sID & data.condition == 16 ...
        & data.exposure == 1, :);
    
    if height(subset) == 0
        continue;
    end
    
    [coef_start, coef_end] = getSlopes(subset, 0, false);
    
    slopes_start(end + 1) = coef_start(2);
    slopes_end(end + 1) = coef_end(2);
end

figure;

x = [repelem(1, 1, numel(slopes_end)) ...
    repelem(2, 1, numel(slopes_end)), ...
    repelem(3, 1, numel(slopes_end))];


difference_R1 = slopes_start - slopes_end;

y = [slopes_start slopes_end difference_R1];

x = x';
y = y';

beeswarm(x, y);
grid on;
ylabel("Slope of PV corr.")
xticks([1 2 3])
xticklabels(["First 4 laps", "Last 4 laps", "Difference"])

[~, p, ~, ~] = ttest(difference_R1) % Sig. p < 1e-6

%% Second plot - This difference reduces with experience

% We want to go from 1 to 15 - 4 = 11

lap = [];
slope_diff = [];

for lapOI = 0:10
    
    for sID = 1:19
        subset = data(data.sessionID == sID & data.condition == 16 ...
            & data.exposure == 1, :);
        
        if height(subset) == 0
            continue;
        end
        
        [coef_start, coef_end] = getSlopes(subset, lapOI, false);
        
        difference = coef_start(2) - coef_end(2);
        
        lap(end + 1) = lapOI + 1; % (to avoid starting at 0)
        slope_diff(end + 1) = difference;
        
    end
end

lap = lap';
slope_diff = slope_diff';

% We shuffle to get a distribution
shuffled = [];

for sID = 1:19
    subset = data(data.sessionID == sID & data.condition == 16 ...
        & data.exposure == 1, :);
    
    if height(subset) == 0
        continue;
    end
    
    for i = 1:100
        
        shuffled_subset = subset;
        shuffled_subset.pvCorr = subset.pvCorr(randperm(height(subset)));
        
        [coef_start_shuff, coef_end_shuff] = getSlopes(shuffled_subset, lapOI, false);
        
        difference_shuff = coef_start_shuff(2) - coef_end_shuff(2);
        
        shuffled(end + 1) = difference_shuff;
        
    end
end

% get the mean and se for plotting
mean_values = arrayfun(@(x) mean(slope_diff(lap == x)), 1:11);

f = figure;
f.Position = [360.3333  198.3333  763.3333  420.0000];

beeswarm(lap, slope_diff);
grid on;
ylabel("Slope difference with last 4 laps")
xlabel("Lap x to x + 4")
hold on;
plot(1:11, mean_values, 'b-o', ...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor','b')

t = table(lap, slope_diff);

fitlm(t, "slope_diff ~ lap") % significant p < 3e-10

%% Looking at the same slope difference with RUN2

slopes_start = [];
slopes_end = [];

for sID = 1:19
    subset = data(data.sessionID == sID & data.condition == 16 ...
        & data.exposure == 2, :);
    
    if height(subset) == 0
        continue;
    end
    
    [coef_start, coef_end] = getSlopes(subset, 0, false);
    
    slopes_start(end + 1) = coef_start(2);
    slopes_end(end + 1) = coef_end(2);
end

x = [repelem(1, 1, numel(slopes_end)) ...
    repelem(2, 1, numel(slopes_end)), ...
    repelem(3, 1, numel(slopes_end))];

difference_R2 = slopes_start - slopes_end;

y = [slopes_start slopes_end difference_R2];

x = x';
y = y';

figure;
beeswarm(x, y);
grid on;
ylabel("Slope of PV corr.")
xticks([1 2 3])
xticklabels(["First 4 laps", "Last 4 laps", "Difference"])

[~, p, ~, ~] = ttest(difference_R2); % Not significant !

%% Sliding window : second exposure

lap = [];
slope_diff = [];

for lapOI = 0:10
    
    for sID = 1:19
        subset = data(data.sessionID == sID & data.condition == 16 ...
            & data.exposure == 2, :);
        
        if height(subset) == 0
            continue;
        end
        
        [coef_start, coef_end] = getSlopes(subset, lapOI, false);
        difference = coef_start(2) - coef_end(2);
        
        lap(end + 1) = lapOI + 1; % (to avoid starting at 0)
        slope_diff(end + 1) = difference;
        
    end
end

lap = lap';
slope_diff = slope_diff';

% get the mean and se for plotting
mean_values = arrayfun(@(x) mean(slope_diff(lap == x)), 1:11);

f = figure;
f.Position = [360.3333  198.3333  763.3333  420.0000];

beeswarm(lap, slope_diff);
grid on;
ylabel("Slope difference with last 4 laps")
xlabel("Lap x to x + 4")
hold on;
plot(1:11, mean_values, 'b-o', ...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor','b')

t = table(lap, slope_diff);

fitlm(t, "slope_diff ~ lap") % Not significant anymore !

% Based on this, we can say that the first exposure is characterised by a
% rapid increase phase in pv-correlation, which is reduced after the 5th /
% 6th lap

% But what about conditions with less previous experience ?

%% Looking at mean slope differences for RUN2 - Other conditions

conditions = [1 2 3 4 8 16];

all_cond = [];
diff = [];
cond_control = [];
diff_control = [];

for c = conditions
    subset = data(data.condition == c & data.exposure == 2, :);
    all_sID = unique(subset.sessionID);
    
    for sID = all_sID'
        subsub = subset(subset.sessionID == sID, :);
        
        subsub_control = data(data.sessionID == sID & ...
                              data.condition == 16 & ...
                              data.exposure == 1);
        
        if height(subsub) == 0
            continue;
        end
        
        [coef_start, coef_end] = getSlopes(subsub, 0, false);
        difference = coef_start(2) - coef_end(2);
        
        if c ~= 16
            [coef_start_c, coef_end_c] = getSlopes(subsub_control, c, false);
            difference_control = coef_start_c(2) - coef_end_c(2);
            diff_control(end + 1) = difference_control;
            cond_control(end + 1) = c;
        end
        
        all_cond(end + 1) = c;
        diff(end + 1) = difference;
        
    end
end

all_cond_plot = all_cond';
all_cond_plot(all_cond_plot == 8) = 5;
all_cond_plot(all_cond_plot == 16) = 6;
all_cond_plot = all_cond_plot + 1;
all_cond_plot = [repelem(1, numel(difference_R1), 1); all_cond_plot];

diff_plot = diff';
diff_plot = [difference_R1'; diff_plot];

mean_values = arrayfun(@(x) mean(diff_plot(all_cond_plot == x)), 1:7);

all_cond = all_cond';
diff = diff';

figure;
beeswarm(all_cond_plot, diff_plot);
grid on;
ylabel("Slope difference with last 4 laps")
xlabel("Previous experience (nb of laps)")
hold on;
plot(1:7, mean_values, 'b-o', ...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor','b')

xticks([1 2 3 4 5 6 7])
xticklabels(["RUN1", "1 lap", "2 laps", "3 laps", "4 laps", "8 laps", "16 laps"])

% You don't have as much difference in the slopes

%% Looking at slinding windows for all the conditions

all_cond = [];
lap = [];
diff = [];

for c = conditions
    subset = data(data.condition == c ...
                & data.exposure == 2, :);
            
    all_sID = unique(subset.sessionID)';        
            
    for lapOI = 0:10
        
        for sID = all_sID
            subset = data(data.sessionID == sID & data.condition == c ...
                        & data.exposure == 2, :);
            
            if height(subset) == 0
                continue;
            end
            
            [coef_start, coef_end] = getSlopes(subset, lapOI, false);
            difference = coef_start(2) - coef_end(2);
            
            all_cond(end + 1) = c;
            lap(end + 1) = lapOI + 1; % (to avoid starting at 0)
            diff(end + 1) = difference;
            
        end
    end
end

all_cond = all_cond';
lap = lap';
diff = diff';

t = table(all_cond, lap, diff);

sum = groupsummary(t, ["all_cond", "lap"], ["mean", "std"], "diff");

figure;
for c = conditions
    sub = sum(sum.all_cond == c, :);
    plot(sub.lap, sub.mean_diff, "LineWidth", 1.5);
    hold on;
end
grid on;