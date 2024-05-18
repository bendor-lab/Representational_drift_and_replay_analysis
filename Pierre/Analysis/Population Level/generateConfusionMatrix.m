% Look at the evolution of confusion between T1 / T2 across laps
clear

PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

parameters = list_of_parameters;
sessions = data_folders_excl;

confusion.fID = {};
confusion.animal = {};
confusion.condition = {};
confusion.exposure = {};
confusion.reexposure = {};

parfor fID = 1:numel(sessions)

    current_conf = struct;
    file = sessions{fID};
    disp("session : " + fID);

    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    current_conf.fID = fID;
    current_conf.animal = string(animalOI);
    current_conf.condition = string(conditionOI);


    % Loading the data needed
    temp = load(file + "\extracted_clusters");
    clusters = temp.clusters;
    temp = load(file + "\extracted_laps");
    lap_times = temp.lap_times;
    temp = load(file + "\extracted_position");
    position = temp.position;
    temp = load(file + "\extracted_place_fields_BAYESIAN");
    place_fields_BAYESIAN = temp.place_fields_BAYESIAN;
    % clear temp;

    cd(file);

    for exposure = 0:2:2
        
        disp("exposure : " + exposure);

        % Create the confusion matrix based on the smaller number of laps
        % between the two tracks

        targetNumberLaps = min([(lap_times(1 + exposure).number_halfLaps - ...
            mod(lap_times(1 + exposure).number_halfLaps, 2))/2, ...
            (lap_times(2 + exposure).number_halfLaps - ...
            mod(lap_times(2 + exposure).number_halfLaps, 2))/2]);

        confusion_matrix = {zeros(20, 20), zeros(20, 20); zeros(20, 20), zeros(20, 20)}; % T1-T1, T1-T2, T2-T1, T2-T2
        all_confusion_matrix = repelem({confusion_matrix}, 1, targetNumberLaps);

        % We get the spike count of all good neurons during that session (at least one of the two tracks)
        % during consecutive 200 ms.

        for t = 1:2

            otherTrack = mod(t, 2)*2 + mod(t + 1, 2);

            trackOI = t + exposure;
            otherTrackv = mod(trackOI, 2)*2 + mod(trackOI + 1, 2) + exposure;

            % tracks_compared = [trackOI otherTrackv];
            tracks_compared = [t + 2 otherTrack + 2]; % We use the final templates

            sampling_f = parameters.run_bin_width;
            currentNumberLaps = (lap_times(trackOI).number_halfLaps - mod(lap_times(trackOI).number_halfLaps, 2)) ...
                /2;

            goodCells = union(place_fields_BAYESIAN.track(tracks_compared).good_cells);
            nbCells = numel(place_fields_BAYESIAN.mean_rate);

            % Iterate through laps
            for l = 1:targetNumberLaps

                disp("Track " + trackOI + " - Lap " + l);

                % We get the duration and the number of slices
                current_lap_start = lap_times(trackOI).completeLaps_start(l);
                current_lap_stop = lap_times(trackOI).completeLaps_stop(l);
                lap_duration = current_lap_stop - current_lap_start;
                number_slices = ceil(lap_duration/sampling_f);

                % We sample the position every 250 ms
                samples_position = NaN(number_slices, 1);

                for s = 1:number_slices
                    current_slice_start = current_lap_start + (s-1)*sampling_f;
                    current_slice_stop = current_lap_start + s*sampling_f;

                    % We get all the position and spikes during that window
                    subset_positions = position.linear(trackOI).linear(position.t >= current_slice_start ...
                        & position.t <= current_slice_stop);
                    mean_position = mean(subset_positions, 'omitnan');
                    samples_position(s) = mean_position;

                end

                samples_position = discretize(samples_position, 0:10:200);

                % We get the spike count for our lap
                run_bayesian_spike_count = spike_count(place_fields_BAYESIAN, current_lap_start, current_lap_stop);

                % We filter the spike count to keep only spikes from good cells on either track
                run_bayesian_spike_count.n.run(setdiff(1:nbCells, goodCells), :) = [];

                % We get all the place fields for current track and other track
                all_place_fields_T = vertcat(place_fields_BAYESIAN.track(t + 2).raw{goodCells});
                all_place_fields_T(isnan(all_place_fields_T)) = 0;

                all_place_fields_O = vertcat(place_fields_BAYESIAN.track(otherTrack + 2).raw{goodCells});
                all_place_fields_O(isnan(all_place_fields_O)) = 0;

                % Now we can decode the position during each time
                estimated_position_T = reconstruct(run_bayesian_spike_count.n.run, all_place_fields_T, sampling_f);
                estimated_position_O = reconstruct(run_bayesian_spike_count.n.run, all_place_fields_O, sampling_f);

                % We normalize each column (time) across tracks
                estimated_position_concat = [estimated_position_T; estimated_position_O];
                sum_concat = sum(estimated_position_concat);
                norm_matrix = repmat(sum_concat, numel(estimated_position_concat(:, 1)), 1);

                estimated_position_concat = estimated_position_concat ./ norm_matrix;

                % Now, we can find the errors for each position
                [~, idx] = max(estimated_position_concat);

                % If the idx of the max is > 20, other track -> error
                isTrackError = idx > 20;
                decoded_position = idx;
                decoded_position(isTrackError) = decoded_position(isTrackError) - 20;

                % We flip the position vectors to have a raising diagonal
                samples_position = 21 - samples_position;

                % We add the errors to the good track matrix and the bad track matrix

                for p = 1:numel(samples_position)
                    if isTrackError(p)
                        all_confusion_matrix{l}{t, otherTrack}(samples_position(p), decoded_position(p)) = ...
                            all_confusion_matrix{l}{t, otherTrack}(samples_position(p), decoded_position(p)) + 1;
                    else
                        all_confusion_matrix{l}{t, t}(samples_position(p), decoded_position(p)) = ...
                            all_confusion_matrix{l}{t, t}(samples_position(p), decoded_position(p)) + 1;
                    end
                end
            end
        end
        %% Now we can concatenate each cell array, and normalize across rows
        all_confusion_concat = cellfun(@cell2mat, all_confusion_matrix, 'UniformOutput', false);

        for m = 1:numel(all_confusion_concat)

            current_mat = all_confusion_concat{m};
            normalization_matrix = repmat(sum(current_mat), numel(current_mat(:, 1)), 1);

            all_confusion_concat{m} = all_confusion_concat{m}./normalization_matrix;
        end

        % Now we save in a struct
        if exposure == 0
            current_conf.exposure = all_confusion_concat;
        else
            current_conf.reexposure = all_confusion_concat;
        end
    end

    % Save the sub-struct in the main struct
    confusion = [confusion; current_conf];



    %%

    % figure;
    % tiledlayout(2, ceil(numel(all_confusion_concat)/2));
    % for f = 1:numel(all_confusion_concat)
    %     nexttile;
    %     imagesc(all_confusion_concat{f})
    %     axis square
    %     title(f);
    %     axis on;
    %     xticks([10, 30]);
    %     xticklabels(["T1", "T2"]);
    %     yticks([10, 30]);
    %     yticklabels(["T1", "T2"]);
    %     set(gca, 'XAxisLocation', 'top')
    %     xline(20.5, 'Color', 'w');
    %     yline(20.5, 'Color', 'w');
    % end

end

% We save confusion

save(PATH.SCRIPT + "\confusion_file_reexp", "confusion");

%% FUNCTIONS

function estimated_position = reconstruct(n, all_place_fields, bin_width)

% allocate variable for speed
estimated_position= zeros(size(all_place_fields,2),size(n,2)); % size [n_cells , n_time_bins]
% Creates matrix where rows are cells and columns are position bins
bin_length = size(all_place_fields,2); %columns
number_of_cells = size(all_place_fields,1); %rows
parameters.bayesian_threshold=10.^(log2(number_of_cells)-log2(400)); % small value multiplied to all values to get rid of zeros
all_place_fields(find(all_place_fields<parameters.bayesian_threshold)) = parameters.bayesian_threshold;
sum_of_place_fields = sum(all_place_fields,1);  % adds up spikes per bin (used later for exponential)

for j = 1: size(n,2)
    n_spikes = n(:,j)*ones(1,bin_length); %number of spikes in time bin
    pre_product = all_place_fields.^n_spikes; % pl field values raised to num of spikes
    pre_product(find(pre_product<parameters.bayesian_threshold)) = parameters.bayesian_threshold;
    product_of_place_fields = prod(pre_product,1); %product of pl fields
    if length(bin_width) > 1 %if it's running theta sequences, each bin width is different
        estimated_position(:,j) = product_of_place_fields.*(exp(-bin_width(j)*sum_of_place_fields)); % bayesian formula
    else
        estimated_position(:,j) = product_of_place_fields.*(exp(-bin_width*sum_of_place_fields)); % bayesian formula
    end
end
%NOTE- columns do not sum to 1.  this is done at a later stage to allow normalization within a track or across tracks

end

