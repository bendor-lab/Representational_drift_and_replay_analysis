%% Function to compute the population vector correlation

function [result, resultNorm] = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, mode)

    % Subsample the cell arrays based on the good cells that are in
    % currentPFCellArray
    currentPFCellArray = currentPFCellArray(goodCells);
    concurrentCellArray = concurrentCellArray(goodCells);
    
    % We normalise the place field of each cell, to return our metric
    % normalised
    
    currentPFCellArrayNorm = cellfun(@(x) rescale(x), currentPFCellArray, 'UniformOutput', false);
    concurrentPFCellArrayNorm = cellfun(@(x) rescale(x), concurrentCellArray, 'UniformOutput', false);
    
    % We reverse the data XBIN -> cells for population vector
    % Classic
    currentPFXBins = repelem({0}, length(currentPFCellArray{1}));
    concurrentPFYBins = repelem({0}, length(concurrentCellArray{1}));
    % Normalised
    currentPFXBinsNorm = repelem({0}, length(currentPFCellArrayNorm{1}));
    concurrentPFYBinsNorm = repelem({0}, length(concurrentPFCellArrayNorm{1}));
    
    for xbin = 1:length(currentPFCellArray{1})
        allCurrentCellAct = cellfun(@(x) x(xbin), currentPFCellArray, 'UniformOutput', false);
        allConcurrentCellAct = cellfun(@(x) x(xbin), concurrentCellArray, 'UniformOutput', false);
        
        allCurrentCellActNorm = cellfun(@(x) x(xbin), currentPFCellArrayNorm, 'UniformOutput', false);
        allConcurrentCellActNorm = cellfun(@(x) x(xbin), concurrentPFCellArrayNorm, 'UniformOutput', false);
        
        currentPFXBins(xbin) = {allCurrentCellAct};
        concurrentPFYBins(xbin) = {allConcurrentCellAct};
        
        currentPFXBinsNorm(xbin) = {allCurrentCellActNorm};
        concurrentPFYBinsNorm(xbin) = {allConcurrentCellActNorm};
    end
    
    if mode == "pvCorrelation"
        % Classic
        corVector = cellfun(@(x, y) corrcoef(x, y), currentPFXBins, concurrentPFYBins, 'UniformOutput', false);
        corVector = cellfun(@(x) x(2, 1), corVector);
        result = corVector;
        % Normalised
        corVectorNorm = cellfun(@(x, y) corrcoef(x, y), currentPFXBinsNorm, concurrentPFYBinsNorm, 'UniformOutput', false);
        corVectorNorm = cellfun(@(x) x(2, 1), corVectorNorm);
        resultNorm = corVectorNorm;
        
        
    elseif mode == "euclidianDistance"
        % Classic
        result = cellfun(@(x, y) norm(x - y), currentPFXBins, concurrentPFYBins, 'UniformOutput', false);
        result = cell2mat(result);
        % Normalised
        resultNorm = cellfun(@(x, y) norm(x - y), currentPFXBinsNorm, concurrentPFYBinsNorm, 'UniformOutput', false);
        resultNorm = cell2mat(resultNorm);
    else
        % We compute the cosine similarity
        % Classic
        cosine_similarity = cellfun(@(x, y) dot(x, y)/(norm(x)*norm(y)), currentPFXBins, concurrentPFYBins, 'UniformOutput', false);
        result = cell2mat(cosine_similarity);
        % Normalised
        cosine_similarityNorm = cellfun(@(x, y) dot(x, y)/(norm(x)*norm(y)), currentPFXBinsNorm, concurrentPFYBinsNorm, 'UniformOutput', false);
        resultNorm = cell2mat(cosine_similarityNorm);
        
    end

end
