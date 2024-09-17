%% Generate the place field file (nb of cells x 20 space bins) necessary
% for bayesian decoding (with exclusion argument to remove cell of interest)

% ARGUMENTS : 
% - place_fields_BAYESIAN : place field standard file with 10 cm bins
% - trackOI : track of interest (1 / 2)
% - cellsToAdd : [cells from which to add place fields]

function [fieldsFile] = genFieldsFile(place_fields_BAYESIAN, ...
                                         trackOI, cellsToAdd)

% Initialize the file                        
fieldsFile = zeros(length(cellsToAdd), 20);

for k = 1:length(cellsToAdd)
    % Get the raw place field
    single_place_field = place_fields_BAYESIAN.track(trackOI)...
                         .raw{cellsToAdd(k)};
                     
    % Remove NaNs in place field and replace by 0
    single_place_field(isnan(single_place_field)) = 0;

    % We add to the array
    fieldsFile(k,:) = single_place_field;
end

end

