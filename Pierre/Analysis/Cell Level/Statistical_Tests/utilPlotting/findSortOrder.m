function [sortOrder] = findSortOrder(mat)

% Sort by peak location
peakLocs = [];

for cell = 1:numel(mat(:, 1))
    peakValue = max(mat(cell, :));
    peakLoc = find(mat(cell, :) == peakValue, 1);
    peakLocs = [peakLocs, peakLoc];
end

[~, sortOrder] = sort(peakLocs, "descend");

end


