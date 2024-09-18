clear
load("timeSeries_consecutive")

summaryLapDataPop = groupsummary(data, ["condition", "exposure", "lap"], ["median", "std"], ...
    ["pvCorr"]);

summaryLapDataPop(summaryLapDataPop.condition == 1, :) = [];

for exposure = 1:2
    subplot(1, 2, exposure)
    
    subset = summaryLapDataPop(summaryLapDataPop.exposure == exposure, :);
    all_conditions = unique(subset.condition);
    for c = all_conditions'
        subsub = subset(subset.condition == c, :);
        if (height(subsub) == 1)
            scatter(subsub.lap, subsub.median_pvCorr)
        else
            plot(subsub.lap, subsub.median_pvCorr, "LineWidth", 2)
        end
        
        hold on;
    end
    
    xlim([0 30])
    ylim([0.4 1])
    grid on;
    title("Exposure " + exposure)
    xlabel("Lap number")
    ylabel("PV correlation with tne previous lap")
    
    if exposure == 2
        legend({"2 laps", "3 laps", "4 laps", "8 laps", "16 laps"}, ...
               'Location','southeast')
    end
end