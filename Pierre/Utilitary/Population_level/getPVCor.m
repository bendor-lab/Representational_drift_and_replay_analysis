%% Function to compute the population vector correlation

function [result] = getPVCor(goodCells, currentPFCellArray, concurrentCellArray, mode)

    % Subsample the cell arrays based on the good cells that are in
    % currentPFCellArray
    currentPFCellArray = currentPFCellArray(goodCells);
    concurrentCellArray = concurrentCellArray(goodCells);
    
    if mode == "pvCorrelation"
        correlationCoefficients = cellfun(@(x, y) corrcoef(x, y), currentPFCellArray, concurrentCellArray, 'UniformOutput', false);
        % Extract the correlation coefficients and returns it
        result = mean(cellfun(@(x) x(2), correlationCoefficients), "omitnan");
    elseif mode == "euclidianDistance"
        result = cellfun(@(x, y) norm(x - y), currentPFCellArray, concurrentCellArray, 'UniformOutput', false);
        result = mean(cell2mat(result), "omitnan");
    else
        % We compute the cosine similarity
        cosine_similarity = cellfun(@(x, y) dot(x, y)/(norm(x)*norm(y)), currentPFCellArray, concurrentCellArray, 'UniformOutput', false);
        result = mean(cell2mat(cosine_similarity), "omitnan");
    end


end