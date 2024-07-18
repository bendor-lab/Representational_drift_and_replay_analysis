clear

load("pv_correlation_fluc.mat");

%% Looking at the mean correlation increase depending on laps

mean_data = groupsummary(data, ["exposure", "lap"], ["mean", "std"], "corrDelta");

figure;
subplot(1, 2, 1)
% s1 = boxplot(data.corrDelta(data.exposure == 1), data.lap(data.exposure == 1));
s1 = bar(mean_data.lap(mean_data.exposure == 1), ...
         mean_data.mean_corrDelta(mean_data.exposure == 1));
     
hold on;
st1 = errorbar(mean_data.lap(mean_data.exposure == 1), ...
               mean_data.mean_corrDelta(mean_data.exposure == 1), ...
               mean_data.std_corrDelta(mean_data.exposure == 1));

grid on;

xlabel("Lap number")
ylabel("PV-correlation fluctuation between l and l+1")
title("First exposure")

subplot(1, 2, 2)
% s2 = boxplot(data.corrDelta(data.exposure == 2), data.lap(data.exposure == 2));
s2 = bar(mean_data.lap(mean_data.exposure == 2), ...
         mean_data.mean_corrDelta(mean_data.exposure == 2));
     
xlabel("Lap number")
title("Re-exposure")

hold on;

st1 = errorbar(mean_data.lap(mean_data.exposure == 2), ...
               mean_data.mean_corrDelta(mean_data.exposure == 2), ...
               mean_data.std_corrDelta(mean_data.exposure == 2));
linkaxes()
grid on;

%% Looking at the difference between conditions

m2_data = groupsummary(data, ["condition", "exposure", "lap"], ["mean", "std"], "corrDelta");

allConditions = [2, 3, 4, 8, 16];
for c = allConditions
    subset_data = m2_data(m2_data.condition == c, :);
    
    figure;
    subplot(1, 2, 1)
    s1 = bar(subset_data.lap(subset_data.exposure == 1), ...
             subset_data.mean_corrDelta(subset_data.exposure == 1));

    hold on;
    st1 = errorbar(subset_data.lap(subset_data.exposure == 1), ...
                   subset_data.mean_corrDelta(subset_data.exposure == 1), ...
                   subset_data.std_corrDelta(subset_data.exposure == 1));

    grid on;

    xlabel("Lap number")
    ylabel("PV-correlation fluctuation between l and l+1")
    title("First exposure - condition " + c + " laps")

    subplot(1, 2, 2)
    s2 = bar(subset_data.lap(subset_data.exposure == 2), ...
             subset_data.mean_corrDelta(subset_data.exposure == 2));

    xlabel("Lap number")
    title("Re-exposure")

    hold on;

    st1 = errorbar(subset_data.lap(subset_data.exposure == 2), ...
                   subset_data.mean_corrDelta(subset_data.exposure == 2), ...
                   subset_data.std_corrDelta(subset_data.exposure == 2));
    linkaxes()
    grid on;
end

%% Looking at variables that could explain PV-correlation improvements
% We only look at 16 laps

% Idle TIME
subdata = data(data.condition == 8, :);

figure;
subplot(1, 2, 1)
boxplot(subdata.idlePeriod(subdata.exposure == 1), ...
        subdata.lap(subdata.exposure == 1))
grid on;
xlabel("Lap number")
ylabel("Idle duration at the end of track")
title("First exposure - 16 laps only")

subplot(1, 2, 2)
boxplot(subdata.idlePeriod(subdata.exposure == 2), ...
        subdata.lap(subdata.exposure == 2))
grid on;
xlabel("Lap number")
title("Re-exposure - 16 laps only")

linkaxes()

% Number of Idle SWR ---------------------

figure;
subplot(1, 2, 1)
boxplot(subdata.idleSWR(subdata.exposure == 1), ...
        subdata.lap(subdata.exposure == 1))
grid on;
xlabel("Lap number")
ylabel("Number of idle SWR")
title("First exposure - 16 laps only")

subplot(1, 2, 2)
boxplot(subdata.idleSWR(subdata.exposure == 2), ...
        subdata.lap(subdata.exposure == 2))
grid on;
xlabel("Lap number")
title("Re-exposure - 16 laps only")

linkaxes()

% Number of idle replay --------------------------

figure;
subplot(1, 2, 1)
boxplot(subdata.idleReplay(subdata.exposure == 1), ...
        subdata.lap(subdata.exposure == 1))
grid on;
xlabel("Lap number")
ylabel("Number of Idle replay")
title("First exposure - 16 laps only")

subplot(1, 2, 2)
boxplot(subdata.idleReplay(subdata.exposure == 2), ...
        subdata.lap(subdata.exposure == 2))
grid on;
xlabel("Lap number")
title("Re-exposure - 16 laps only")

linkaxes()

% Everything seems to go down

figure;
scatter(subdata.corrDelta(subdata.lap == 1 & subdata.exposure == 1), ...
        subdata.idleReplay(subdata.lap == 1 & subdata.exposure == 1)./...
        subdata.idlePeriod(subdata.lap == 1 & subdata.exposure == 1))
    
%% 8 laps weird shape

