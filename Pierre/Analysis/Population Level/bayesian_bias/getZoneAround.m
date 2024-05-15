function [left, right] = getZoneAround(v, index)

    left = index;
    right = index;
    
    while left > 1 && v(left - 1) == 1
        left = left - 1;
    end
    
    while right < length(v) && v(right + 1) == 1
        right = right + 1;
    end
    
end