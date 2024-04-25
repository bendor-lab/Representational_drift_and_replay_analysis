% Function to make a stacked raster plot.
% INPUT : matrix with first column cell ID and second column time

function [] = makeRaster(spikeData, time_size)

uniqueCells = unique(spikeData(:, 1));
timeVecEl = (spikeData(1, 2) - 0.005):0.001:(spikeData(1, 2) + time_size*0.020 + 0.001);
timeVec = (spikeData(1, 2) - 0.005):0.001:(spikeData(1, 2) + time_size*0.020);

for cID = 1:numel(uniqueCells)
    current_cell = uniqueCells(cID);
    allSpikeTimes = spikeData(spikeData(:, 1) == current_cell, 2);
    boolMatSpike = histcounts(allSpikeTimes, timeVecEl);
    boolMatSpike(boolMatSpike == 1) = numel(uniqueCells) - (cID - 1);
    boolMatSpike(boolMatSpike == 0) = numel(uniqueCells) - cID;

    plot([timeVec; timeVec], [repelem(numel(uniqueCells) - cID, 1, numel(timeVec)); boolMatSpike], ...
         "Color", "k");

    hold on;
end

ylim([-1, numel(uniqueCells) + 1])
xlim([timeVec(1) timeVec(end)])

labelVector = (spikeData(1, 2) - 0.005):0.040:(spikeData(1, 2) + time_size*0.020);
labelVector = labelVector - (spikeData(1, 2) - 0.005);
xticks((spikeData(1, 2) - 0.005):0.040:(spikeData(1, 2) + time_size*0.020))
xticklabels(labelVector)

yticks([0.5 numel(uniqueCells) - 0.5]);
yticklabels({"Cell 1", "Cell " + numel(uniqueCells)});

xlabel("Time (s)");
ylabel("Participating cells #");

end