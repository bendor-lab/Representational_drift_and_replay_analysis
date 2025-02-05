%% This function plots lap-to-lap PV traces for individual sessions
% Ben's data ! 

clear
load("../data/time_serie_control.mat");

unique_sessions = unique(data.sessionID);
col = ['b', 'r'];

for sID = unique_sessions'

    figure;

    cur_data = data(data.sessionID == sID, :);
    
    for trackOI = 1:2

        subdata = cur_data(cur_data.track == trackOI, :);
        sub_1 = subdata(subdata.exposure == 1, :);
        sub_2 = subdata(subdata.exposure == 2, :);
        sub_2(end, :) = []; % remove the last lap
        
        nbNan = 17 - height(sub_1);
        Y = [sub_1.pvCorr' repelem(NaN, nbNan) sub_2.pvCorr'];
        X = 1:numel(Y);

        plot(X, Y, col(trackOI));
        hold on;
        scatter(X, Y, col(trackOI), 'filled');
    end

    grid on;
    title("Condition : " + cur_data.condition(1))
    xline(17, '--k');
    legend({"Track 1", "", "Track 2", "", ""});
    

end