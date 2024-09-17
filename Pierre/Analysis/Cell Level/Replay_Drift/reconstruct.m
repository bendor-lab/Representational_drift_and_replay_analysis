% Apply the bayesian decoding formula to the spiking matrix - 3D vectorized

function estimated_position = reconstruct(n, all_place_fields,bin_width)

% allocate variable for speed
estimated_position = zeros(size(all_place_fields,2),size(n,2)); % size [n_cells , n_time_bins]

% Creates matrix where rows are cells and columns are position bins
bin_length = size(all_place_fields,2); %columns
number_of_cells = size(all_place_fields,1); %rows
parameters.bayesian_threshold=10.^(log2(number_of_cells)-log2(400)); % small value multiplied to all values to get rid of zeros
all_place_fields(all_place_fields < parameters.bayesian_threshold) = parameters.bayesian_threshold;
sum_of_place_fields = sum(all_place_fields,1);  % adds up spikes per bin (used later for exponential)
sumOfPlaceFields2D = repmat(sum_of_place_fields', [1, size(n,2)]);

% Repeat the number of spikes per cell per x_bin on the track (to get same dimension as pf)
n_spikes = repmat(n, [1, 1, bin_length]);

% Create a 3D matrix full of repeating place field 2D matrices
allPlaceFields3D = repmat(reshape(all_place_fields, [number_of_cells, 1, bin_length]), [1, size(n,2), 1]);

% Place field values raised to num of spikes
pre_product = allPlaceFields3D.^n_spikes;

% Apply the threshold to remove 0 values
pre_product(pre_product<parameters.bayesian_threshold) = parameters.bayesian_threshold;

% Product of place fields of each cell
product_of_place_fields = prod(pre_product, 1);
product_of_place_fields = squeeze(product_of_place_fields);
product_of_place_fields = product_of_place_fields';

if length(bin_width) > 1 % if it's running theta sequences, each bin width is different
    estimated_position(:,:) = product_of_place_fields.*(exp(-bin_width.*sumOfPlaceFields2D)); % bayesian formula
else
    estimated_position(:,:) = product_of_place_fields.*(exp(-bin_width * sumOfPlaceFields2D)); % bayesian formula
end

% NOTE- columns do not sum to 1.  this is done at a later stage to allow normalization within and across tracks

end

