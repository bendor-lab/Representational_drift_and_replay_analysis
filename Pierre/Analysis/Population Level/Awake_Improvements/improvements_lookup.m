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
        snippet.lap = (1:numel(snippet.lap))';
        
        mean_data = [mean_data; snippet];
    
        end
    end
end

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
        pv_evolution = diff(pv_cor);

        snippet = current_data(1:end-1, :);
        snippet.pvCorr = pv_evolution; %pvCorr now refer to delta pv

        time_ser = [time_ser; snippet];
    
        end
    end
end

%%

isFirstLap = (time_ser.lap == 5 | time_ser.lap == 6) & time_ser.exposure == 1 ...
              & time_ser.condition == 16;

all_pv = time_ser.pvCorr(isFirstLap);
all_SWR = time_ser.idleSWR(isFirstLap);
all_Idle = time_ser.idlePeriod(isFirstLap);
all_rep = time_ser.idleReplay(isFirstLap);
all_theta = time_ser.thetaCycles(isFirstLap);

foo = table(all_pv, all_SWR, all_Idle, all_rep, all_theta);

corrplot(foo)

%%

all_cor = [];

for lap = 2:16
    current_sub = (time_ser.lap == lap*2-1 | time_ser.lap == lap*2) & time_ser.exposure == 1 ...
                   & time_ser.condition == 16;

    all_pv = time_ser.pvCorr(current_sub);
    all_theta = time_ser.thetaCycles(current_sub);

    corr_coef = corrcoef(all_pv, all_theta);
    all_cor(end + 1) = corr_coef(2, 1);

end

plot(all_cor)
grid on;
