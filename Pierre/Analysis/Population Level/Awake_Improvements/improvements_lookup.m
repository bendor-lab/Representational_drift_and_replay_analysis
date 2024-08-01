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
        snippet.idleReplay = sum([data_even.idleReplay'; data_odd.idleReplay'], 'omitnan')';
        snippet.thetaCycles = sum([data_even.thetaCycles'; data_odd.thetaCycles'], 'omitnan')';
        snippet.totalTime = sum([data_even.totalTime'; data_odd.totalTime'], 'omitnan')';
        snippet.runningTime = sum([data_even.runningTime'; data_odd.runningTime'], 'omitnan')';
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

isFirstLap = time_ser.lap == 1 & time_ser.exposure == 1;

foo = time_ser(isFirstLap, 7:end);

corrplot(foo)

%%

all_cor = [];

for lap = 1:15
    current_sub = time_ser.lap == lap & time_ser.exposure == 1;

    all_pv = time_ser.pvCorrExp(current_sub);
    all_theta = time_ser.idleSWR(current_sub);

    corr_coef = corrcoef(all_pv, all_theta);
    all_cor(end + 1) = corr_coef(2, 1);

end

plot(all_cor)
grid on;
fitlme(time_ser(time_ser.exposure == 1, :), 'pvCorrExp ~ idleSWR + idlePeriod + idleReplay + thetaCycles')

%%

sum_data = groupsummary(mean_data, ["lap", "exposure"], "median", ["pvCorr", "idlePeriod", "idleReplay", "idleSWR", "thetaCycles"]);

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
         mean_data.idleReplay(mean_data.exposure == cExp))
grid on;

title("Number of awake replay - RUN2")
ylabel("n° of replay")
xlabel("Lap")

hold on;
plot(sum_data.lap(sum_data.exposure == cExp), sum_data.median_idleReplay(sum_data.exposure == cExp), 'r')


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