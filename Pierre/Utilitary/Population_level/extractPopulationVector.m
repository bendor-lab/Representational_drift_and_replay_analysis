function [populationVector] = extractPopulationVector(animalOI, conditionOI, track, lap, mode)

sessions = data_folders_excl; % Use the function to get all the file paths

% Find elements that contain both animalOI and conditionOI
matchingSession = sessions(contains(sessions, animalOI) & contains(sessions, conditionOI));
load(matchingSession + "\extracted_lap_place_fields.mat")

% If lap = "last", we take the final lap, if "beforeLast", we take ...
if isa(lap,'string')
    if lap == "last"
        goodPFData = lap_place_fields(track).Complete_Lap{end};
    elseif lap == "beforeLast"
        goodPFData = lap_place_fields(track).Complete_Lap{end-1};
    end
else
    goodPFData = lap_place_fields(track).Complete_Lap{lap};
end

currentPFCellArray = goodPFData.raw;

% We normalize the PF
if mode == "norm"
    currentPFCellArray = cellfun(@(x) rescale(x), currentPFCellArray, 'UniformOutput', false);
end

% We reverse the data XBIN -> cells for population vector

currentPFXBins = repelem({0}, length(currentPFCellArray{1}));

for xbin = 1:length(currentPFCellArray{1})
    allCurrentCellAct = cellfun(@(x) x(xbin), currentPFCellArray, 'UniformOutput', false);       
    currentPFXBins(xbin) = {allCurrentCellAct};
end

populationVector = currentPFXBins;

end
