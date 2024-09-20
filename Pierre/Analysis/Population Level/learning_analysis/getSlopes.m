% Function to get the slopes of the two extremities of a pv
% correlation time serie

function [b_start, b_end] = getSlopes(subset, offset, plotting)

number_laps = numel(subset.lap);

laps_start = subset(subset.lap <= 4 + offset & ...
                    subset.lap >= offset+1, :);
                
laps_end = subset(subset.lap >= (number_laps - 3), :);

% We regress to find the slope of the pv-corr at the beginning vs.
% the end of the track exploration

% For starting 4 laps
X_start = [ones(length(laps_start.lap),1) laps_start.lap];
y_start = laps_start.pvCorr;
b_start = X_start\y_start; % first line is intercept, second is slope

% For end 4 laps
X_end = [ones(length(laps_end.lap),1) laps_end.lap];
y_end = laps_end.pvCorr;
b_end = X_end\y_end; % first line is intercept, second is slope

if plotting
    plot(subset.lap, subset.pvCorr, "LineWidth", 1.5);
    hold on;
    plot(laps_start.lap, b_start(1) + laps_start.lap*b_start(2), ...
        "LineWidth", 1.5);
    
    plot(laps_end.lap, b_end(1) + laps_end.lap*b_end(2), ...
        "LineWidth", 1.5);
    grid on;
    xlabel("Lap")
    ylabel("PV-correlation with 16th lap")
end

end

