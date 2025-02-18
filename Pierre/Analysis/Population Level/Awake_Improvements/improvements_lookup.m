% Looking at the lap to lap correlation improvement and correlate with
% parameters

clear
load("pv_correlation_fluc");

%% We get the mean across each pair of half-lap

mean_data = data([], :);

for cID = 1:19
    for track = 1:2
        for cur_exposure = 1:2
        
        if track == 1
            current_data = data(data.sessionID == cID & ...
                            data.exposure == cur_exposure & ...
                            data.condition == 16, :);
        else
            current_data = data(data.sessionID == cID & ...
                            data.exposure == cur_exposure & ...
                            data.condition ~= 16, :);
        end

        data_even = current_data(2:2:end, :);
        data_odd = current_data(1:2:end, :);

        % crop to right size if odd number of laps
        if numel(data_even.lap) ~= numel(data_odd.lap)
            smaller = min([numel(data_even.lap), numel(data_odd.lap)]);
            data_even = data_even(1:smaller, :);
            data_odd = data_odd(1:smaller, :);
        end

        % Get all the metrics we need
        snippet = data_odd;

        snippet.pvCorr = mean([data_even.pvCorr'; data_odd.pvCorr'], 'omitnan')';
        snippet.idlePeriod = sum([data_even.idlePeriod'; data_odd.idlePeriod'], 'omitnan')';
        snippet.idleSWR = sum([data_even.idleSWR'; data_odd.idleSWR'], 'omitnan')';
        snippet.idleReplayFor = sum([data_even.idleReplayFor'; data_odd.idleReplayFor'], 'omitnan')';
        snippet.idleReplayBack = sum([data_even.idleReplayBack'; data_odd.idleReplayBack'], 'omitnan')';
        snippet.thetaCycles = sum([data_even.thetaCycles'; data_odd.thetaCycles'], 'omitnan')';
        snippet.totalTime = max([data_even.totalTime'; data_odd.totalTime'])';
        snippet.runningTime = sum([data_even.runningTime'; data_odd.runningTime'])';
        snippet.lap = (1:numel(snippet.lap))';
        
        
        mean_data = [mean_data; snippet];
    
        end
    end
end

mean_data.pvCorrExp = 10.^mean_data.pvCorr;

time_ser = mean_data([], :);

% Calculate the derivative of the pv-correlation across laps

for cID = 1:19
    for track = 1:2
        for cur_exposure = 1:2
        
        if track == 1
            current_data = mean_data(mean_data.sessionID == cID & ...
                            mean_data.exposure == cur_exposure & ...
                            mean_data.condition == 16, :);
        else
            current_data = mean_data(mean_data.sessionID == cID & ...
                            mean_data.exposure == cur_exposure & ...
                            mean_data.condition ~= 16, :);
        end

        pv_cor = current_data.pvCorr;
        pv_cor_exp = current_data.pvCorrExp;

        pv_evolution = diff(pv_cor);
        pv_exp_evolution = diff(pv_cor_exp);

        snippet = current_data(1:end-1, :);
        snippet.pvCorr = pv_evolution; %pvCorr now refer to delta pv
        snippet.pvCorrExp = pv_exp_evolution;

        time_ser = [time_ser; snippet];
    
        end
    end
end

%%

isFirstLap = time_ser.lap == 1 & time_ser.exposure == 1 & time_ser.condition == 16;

foo = time_ser(isFirstLap, 7:end-1);

corrplot(foo)

fitlme(mean_data(mean_data.exposure == 1 & mean_data.condition == 16, :), ...
       "pvCorr ~ lap*thetaCycles + (1|animal)")



%%

cor_dur = [];
cor_idleDur = [];
cor_swr = [];
cor_replay_for = [];
cor_replay_back = [];
cor_theta = [];
cor_time = [];


for lap = 1:15
    current_sub = time_ser.lap == lap & time_ser.exposure == 1 ...
                  & time_ser.condition == 16;

    subset = time_ser(current_sub, :);

    c_cor_dur = corrcoef(subset.pvCorr, subset.runningTime);
    c_cor_idleDur = corrcoef(subset.pvCorr, subset.idlePeriod);
    c_cor_swr = corrcoef(subset.pvCorr, subset.idleSWR);
    c_cor_replay_for = corrcoef(subset.pvCorr, subset.idleReplayFor);
    c_cor_replay_back = corrcoef(subset.pvCorr, subset.idleReplayBack);
    c_cor_theta = corrcoef(subset.pvCorr, subset.thetaCycles);
    c_cor_time = corrcoef(subset.pvCorr, subset.totalTime);

    cor_dur(end + 1) = c_cor_dur(1, 2);
    cor_idleDur(end + 1) = c_cor_idleDur(1, 2);
    cor_swr(end + 1) = c_cor_swr(1, 2);
    cor_replay_for(end + 1) = c_cor_replay_for(1, 2);
    cor_replay_back(end + 1) = c_cor_replay_back(1, 2);
    cor_theta(end + 1) = c_cor_theta(1, 2);
    cor_time(end + 1) = c_cor_time(1, 2);
end

plot(1:15, cor_dur)
hold on;
plot(1:15, cor_idleDur)
plot(1:15, cor_swr)
plot(1:15, cor_replay_for)
plot(1:15, cor_replay_back)
plot(1:15, cor_theta)
plot(1:15, cor_time)

%%

plot(all_cor)
grid on;

scatter(mean_data.runningTime(mean_data.exposure == 1 & mean_data.condition == 16), ...
        mean_data.pvCorr(mean_data.exposure == 1 & mean_data.condition == 16))

fitlme(time_ser(time_ser.exposure == 1 & time_ser.condition == 16, :), ...
       "pvCorr ~ lap")

%%

sum_data = groupsummary(mean_data, ["lap", "exposure"], "median", ...
      ["pvCorr", "idlePeriod", "idleReplayFor", "idleReplayBack", "idleSWR", "thetaCycles"]);

cExp = 2;

subplot(2, 2, 1)
boxchart(mean_data.lap(mean_data.exposure == cExp), ...
         mean_data.idlePeriod(mean_data.exposure == cExp))
grid on;
title("Idle period after lap - RUN2")
ylabel("Seconds")
xlabel("Lap")

hold on;
plot(sum_data.lap(sum_data.exposure == cExp), sum_data.median_idlePeriod(sum_data.exposure == cExp), 'r')

subplot(2, 2, 2)
boxchart(mean_data.lap(mean_data.exposure == cExp), ...
         mean_data.idleSWR(mean_data.exposure == cExp))
grid on;

title("Number of SWR - RUN2")
ylabel("n° of SWR")
xlabel("Lap")

hold on;
plot(sum_data.lap(sum_data.exposure == cExp), sum_data.median_idleSWR(sum_data.exposure == cExp), 'r')


subplot(2, 2, 3)
boxchart(mean_data.lap(mean_data.exposure == cExp), ...
         mean_data.idleReplayBack(mean_data.exposure == cExp))
grid on;

title("Number of awake replay - RUN2")
ylabel("n° of replay")
xlabel("Lap")

hold on;
plot(sum_data.lap(sum_data.exposure == cExp), sum_data.median_idleReplayFor(sum_data.exposure == cExp), 'r')


subplot(2, 2, 4)
boxchart(mean_data.lap(mean_data.exposure == cExp), ...
         mean_data.thetaCycles(mean_data.exposure == cExp))
grid on;

title("Number of theta cycles - RUN2")
ylabel("n° of theta cycles")
xlabel("Lap")

hold on;
plot(sum_data.lap(sum_data.exposure == cExp), sum_data.median_thetaCycles(sum_data.exposure == cExp), 'r')

%%

subplot(2, 2, 1)
boxchart(mean_data.lap(mean_data.exposure == 1), mean_data.pvCorr(mean_data.exposure == 1))
title("Raw")
xlabel("Laps")
ylabel("PV correlation")

subplot(2, 2, 2)
boxchart(mean_data.lap(mean_data.exposure == 1), mean_data.pvCorr(mean_data.exposure == 1))
title("Logged axis")
xlabel("Log 10 Laps")
ylabel("PV correlation")
xscale log

subplot(2, 2, 3)
boxchart(mean_data.lap(mean_data.exposure == 1), 10.^mean_data.pvCorr(mean_data.exposure == 1))
title("Exponentiated PV cor")
xlabel("Laps")
ylabel("10^(PV correlation)")

%%

corrplot(time_ser(:, time_ser.Properties.VariableNames(7:end-1)))