% Given a place field structure, returns the width of the place field of
% each cell
% Threshold : 50%

function [widthPFVector] = getWidthPlaceField(place_field)

rawsPFEachCell = place_field.raw;

widthPFVector = [];

% We iterate through place fields
for cPF = rawsPFEachCell

    PF = cPF{1};
    % Normalize the vector
    pfNorm = rescale(PF);
    
    % Find the index of the peak
    [~, peak_index] = max(pfNorm);
    
    isInThresh = pfNorm >= .50;
    
    % We find the theorical max width of the PF to the right and to the
    % left
    
    thMaxLeft = peak_index - 1; % -1 cause index starts at 1
    thMaxRight = length(PF) - peak_index;
    
    % Now we iterate on both sides
    
    for i = 1:thMaxLeft
        portion = isInThresh((peak_index - i):(peak_index - 1));
        if sum(portion) == length(portion) && i ~= thMaxLeft
            continue;
        elseif sum(portion) == length(portion)
            widthLeft = i;
        else
            widthLeft = i - 1;
            break
        end
    end
    
    for j = 1:thMaxRight
        portion = isInThresh((peak_index + 1):(peak_index + j));
        if sum(portion) == length(portion) && j ~= thMaxRight
            continue;
        elseif sum(portion) == length(portion)
            widthRight = j;
            break
        else
            widthRight = j - 1;
            break
        end
    end
    
    width = widthLeft + widthRight + 1;

    widthPFVector = [widthPFVector, width];
end

end

