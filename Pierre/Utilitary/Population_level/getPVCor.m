%% Function to compute the population vector correlation

function [result] = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, mode)

    % Subsample the cell arrays based on the good cells that are in
    % currentPFCellArray
    currentPFCellArray = currentPFCellArray(goodCells);
    concurrentCellArray = concurrentCellArray(goodCells);
        

    % We reverse the data XBIN -> cells for population vector

    currentPFXBins = repelem({0}, length(currentPFCellArray{1}));
    concurrentPFYBins = repelem({0}, length(concurrentCellArray{1}));
    
    for xbin = 1:length(currentPFCellArray{1})
        allCurrentCellAct = cellfun(@(x) x(xbin), currentPFCellArray, 'UniformOutput', false);
        allConcurrentCellAct = cellfun(@(x) x(xbin), concurrentCellArray, 'UniformOutput', false);
                
        currentPFXBins(xbin) = {allCurrentCellAct};
        concurrentPFYBins(xbin) = {allConcurrentCellAct};
        
    end
    
    if mode == "populationVector" % We just return the population vector
        result = currentPFXBins;
        
    elseif mode == "pvCorrelation"

        corVector = cellfun(@(x, y) corrcoef(cell2mat(x), cell2mat(y), 'rows','complete'), currentPFXBins, concurrentPFYBins, 'UniformOutput', false);
        corVector = cellfun(@(x) x(2, 1), corVector);
        result = corVector;        
        
    elseif mode == "euclidianDistance"

        result = cellfun(@(x, y) norm(cell2mat(x) - cell2mat(y)), currentPFXBins, concurrentPFYBins, 'UniformOutput', false);
        result = cell2mat(result);
    else
        % We compute the cosine similarity

        cosine_similarity = cellfun(@(x, y) dot(cell2mat(x), cell2mat(y))/(norm(cell2mat(x))*norm(cell2mat(y))), currentPFXBins, concurrentPFYBins, 'UniformOutput', false);
        result = cell2mat(cosine_similarity);
        
    end

end
