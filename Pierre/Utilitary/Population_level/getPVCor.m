%% Function to compute the population vector correlation

function [result] = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, mode)

    % Subsample the cell arrays based on the good cells that are in
    % currentPFCellArray
    currentPFCellArray = currentPFCellArray(goodCells);
    concurrentCellArray = concurrentCellArray(goodCells);
    
    % We reverse the data XBIN -> cells for population vector
    
    currentPFXBins = repelem({0}, length(currentPFCellArray{1}));
    concurrentPFYBins = repelem({0}, length(currentPFCellArray{1}));
    
    for xbin = 1:length(currentPFCellArray{1})
        allCurrentCellAct = cellfun(@(x) x(xbin), currentPFCellArray);
        allConcurrentCellAct = cellfun(@(x) x(xbin), concurrentCellArray);
        
        currentPFXBins(xbin) = {allCurrentCellAct};
        concurrentPFYBins(xbin) = {allConcurrentCellAct};
    end
    
    if mode == "pvCorrelation"
        corVector = cellfun(@(x, y) corrcoef(x, y), currentPFXBins, concurrentPFYBins, 'UniformOutput', false);
        corVector = cellfun(@(x) x(2, 1), corVector);
        result = mean(corVector, "omitnan");
    elseif mode == "euclidianDistance"
        result = cellfun(@(x, y) norm(x - y), currentPFXBins, concurrentPFYBins, 'UniformOutput', false);
        result = mean(cell2mat(result), "omitnan");
    else
        % We compute the cosine similarity
        cosine_similarity = cellfun(@(x, y) dot(x, y)/(norm(x)*norm(y)), currentPFXBins, concurrentPFYBins, 'UniformOutput', false);
        result = mean(cell2mat(cosine_similarity), "omitnan");
    end

end
