clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl_legacy; % Use the function to get all the file paths

% (and the clean number of laps)

% Arrays to hold all the data
animalV = [];
conditionV = [];
trackV = [];
cellV = [];
isDirectionnalV = [];
directionV = [];

savingsPOST1V = []; % Metric diff between last lap RUN1 and first lap RUN2
dirChangeRUN1V = []; % Metric diff between last and first lap RUN1
dirChangeRUN2V = []; % Same for RUN2
dirChangeRUN1RUN2V = [];

partP1RepV = [];
replayDirBiasV = []; % Bias in the replay detection, mean of all the directions

isPCBothTracksV = [];

% Define the metric we want to use

% Diffsum
diffsum = @(pf1, pf2) abs(max(pf1) - max(pf2)) / (max(pf1) + max(pf2));

% Diffsum integral PF
diffsumInt = @(pf1, pf2) abs(sum(pf1) - sum(pf2)) / (sum(pf1) + sum(pf2));


% Earth Moving Distance
earthMoversDistance = @(p1, p2) sum(abs(cumsum(p1) - cumsum(p2)));

% Assign the function
metric = diffsumInt;

% Choose if you include only directional cells (1), all cells (0), no directional cells
% (-1)
inclusionMode = 0;


%% Extraction & computation

parfor fileID = 1:length(sessions)
    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string

    % Exception, need to recalculate

    if fileID == 5
        continue;
    end

    % Load variables

    temp = load(file + "\extracted_directional_lap_place_fields.mat");
    temp2 = load(file + "\extracted_directional_place_fields.mat");

    lap_directional_place_fields = temp.lap_directional_place_fields;
    directional_place_fields = temp2.directional_place_fields;

    % Track loop

    for track = 1:2
        
        % Get the cells we want to work with for the analysis

        [directionalCellsRUN1, dirOPRUN1] = getDirectionalCells(directional_place_fields(1).place_fields.track(track).smooth, ...
            directional_place_fields(2).place_fields.track(track).smooth);

        [directionalCellsRUN2, dirOPRUN2] = getDirectionalCells(directional_place_fields(1).place_fields.track(track + 2).smooth, ...
            directional_place_fields(2).place_fields.track(track + 2).smooth);

        % directionalCells = union(directionalCellsRUN1, directionalCellsRUN2);
        directionalCells = directionalCellsRUN2;

        
        % Good Cells are good place cells on RUN1 OR RUN2
        goodCellsRUN1 = union(directional_place_fields(1).place_fields.track(track).good_cells, ...
                          directional_place_fields(2).place_fields.track(track).good_cells);

        goodCellsRUN2 = union(directional_place_fields(1).place_fields.track(track + 2).good_cells, ...
                          directional_place_fields(2).place_fields.track(track + 2).good_cells);

        goodCells = union(goodCellsRUN1, goodCellsRUN2);

        if inclusionMode == 1
            goodDirCells = intersect(goodCells, directionalCells);
        elseif inclusionMode == -1
            removeIdx = ismember(goodCells, directionalCells);
            goodDirCells = goodCells;
            goodDirCells(removeIdx) = []; % To test only non-directional cells
        else
            goodDirCells = goodCells; % Test with all cells, not just directional
        end
        
        % Vector to store the direction of each cell (if directionnal)
        dirVector = [];

        % Match the good cells with their direction
        for cellID = 1:length(goodDirCells)
            cell = goodDirCells(cellID);
            idRUN2 = find(directionalCellsRUN2 == cell);
            idRUN1 = find(directionalCellsRUN1 == cell);
            if ~isempty(idRUN2)
                dirVector = [dirVector dirOPRUN2(idRUN2)];
            elseif ~isempty(idRUN1)
                dirVector = [dirVector dirOPRUN1(idRUN1)];
            else
                dirVector = [dirVector NaN];
            end
        end

        % Get the directional lap data

        dataDir1RUN1 = lap_directional_place_fields(track).dir1.half_Lap;
        dataDir2RUN1 = lap_directional_place_fields(track).dir2.half_Lap;
        dataDir1RUN2 = lap_directional_place_fields(track + 2).dir1.half_Lap;
        dataDir2RUN2 = lap_directional_place_fields(track + 2).dir2.half_Lap;

        % Always a pair number of half laps
        if mod(length(dataDir1RUN1), 2) == 1
            dataDir1RUN1 = dataDir1RUN1(1:end-1);
            dataDir2RUN1 = dataDir2RUN1(1:end-1);
        end

        if mod(length(dataDir1RUN2), 2) == 1
            dataDir1RUN2 = dataDir1RUN2(1:end-1);
            dataDir2RUN2 = dataDir2RUN2(1:end-1);
        end

        % We get the replay participation

        % Fetch the significant replay events
        temp = load(file + "\Bayesian controls\Only first exposure\significant_replay_events_wcorr");
        significant_replay_events = temp.significant_replay_events;
        RE_current_track = significant_replay_events.track(track);

        % Fetch the sleep times to filter POST1 replay events
        temp = load(file +  "/extracted_sleep_state");
        sleep_state = temp.sleep_state;
        startTime = sleep_state.state_time.INTER_post_start;
        endTime = sleep_state.state_time.INTER_post_end;

        % Bool mat of the valid times
        subsetReplayBool = RE_current_track.event_times <= endTime & RE_current_track.event_times >= startTime;

        filteredReplayEventsSpikes = RE_current_track.spikes(subsetReplayBool);

        % We get the direction of each replay event
        allBayesianDecodings = RE_current_track.decoded_position(subsetReplayBool);
        replayDirectionArray = [];

        for decID = 1:length(allBayesianDecodings)
            decoded_position = allBayesianDecodings{decID};

            % Apply weighted correlation
            if any(isnan(decoded_position)) | size(decoded_position, 2) < 5
                replayDirectionArray = [replayDirectionArray NaN];
            else
                weighted_corr_score = weighted_correlation(decoded_position, false);
                replayDirectionArray = [replayDirectionArray sign(weighted_corr_score)];
            end
        end

        % Cell loop

        for cellID = 1:length(goodDirCells)

            cell = goodDirCells(cellID);

            % We get the metric variables

            savingsPOST1 = metric(dataDir1RUN2{1}.smooth{cell}, dataDir2RUN2{2}.smooth{cell}) - ...
                           metric(dataDir1RUN1{end - 1}.smooth{cell}, dataDir2RUN1{end}.smooth{cell});

            dirChangeRUN1 = metric(dataDir1RUN1{end - 1}.smooth{cell}, dataDir2RUN1{end}.smooth{cell}) - ...
                             metric(dataDir1RUN1{1}.smooth{cell}, dataDir2RUN1{2}.smooth{cell});

            dirChangeRUN2 = metric(dataDir1RUN2{end - 1}.smooth{cell}, dataDir2RUN2{end}.smooth{cell}) - ...
                            metric(dataDir1RUN2{1}.smooth{cell}, dataDir2RUN2{2}.smooth{cell});

            dirChangeRUN1RUN2 = metric(dataDir1RUN2{end - 1}.smooth{cell}, dataDir2RUN2{end}.smooth{cell}) - ...
                                metric(dataDir1RUN1{end - 1}.smooth{cell}, dataDir2RUN1{end}.smooth{cell});

            if conditionOI == "1"
                dirChangeRUN1 = NaN;
            end

            
            % We get the replay participation of the cell
            replayInvolved = cellfun(@(ev) any(ev(:, 1) == cell), filteredReplayEventsSpikes);

            partP1Rep = sum(replayInvolved);
            replayDirBias = abs(mean(replayDirectionArray(replayInvolved), 'omitnan'));
            
            % We get if it's a good place cell on both tracks - T1 or T3
            % and T2 or T4
            % (by definition, it's a good PC on the current track)

            adverseTrack = mod(track + 1, 2) + mod(track, 2)*2; % Get the other track ID

            goodCellsTAd = union(directional_place_fields(1).place_fields.track(adverseTrack).good_cells, ...
                           directional_place_fields(2).place_fields.track(adverseTrack).good_cells);

            goodCellsTAd2 = union(directional_place_fields(1).place_fields.track(adverseTrack + 2).good_cells, ...
                           directional_place_fields(2).place_fields.track(adverseTrack + 2).good_cells);

            isPCBothTracks = ismember(cell, union(goodCellsTAd, goodCellsTAd2));

            % Save the data

            animalV = [animalV; animalOI];
            conditionV = [conditionV; conditionOI];
            trackV = [trackV; track];
            cellV = [cellV; cell];
            isDirectionnalV = [isDirectionnalV; ismember(cell, directionalCells)];
            directionV = [directionV; dirVector(cellID)];
            savingsPOST1V = [savingsPOST1V; savingsPOST1];
            dirChangeRUN1V = [dirChangeRUN1V; dirChangeRUN1];
            dirChangeRUN2V = [dirChangeRUN2V; dirChangeRUN2];
            dirChangeRUN1RUN2V = [dirChangeRUN1RUN2V; dirChangeRUN1RUN2];
            partP1RepV = [partP1RepV; partP1Rep];
            replayDirBiasV = [replayDirBiasV; replayDirBias];
            isPCBothTracksV = [isPCBothTracksV; isPCBothTracks];

        end
    end
end



% We mutate to only have the condition, not 16x...
conditionV(trackV == 1) = 16;
newConditions = split(conditionV(trackV ~= 1), 'x');
conditionV(trackV ~= 1) = newConditions(:, 2);


data = table(animalV, conditionV, trackV, cellV, isDirectionnalV, directionV, savingsPOST1V, ...
             dirChangeRUN1V, dirChangeRUN2V, dirChangeRUN1RUN2V, partP1RepV, replayDirBiasV, isPCBothTracksV);

%% From there we can test

%% Group by directionality and commonality

G = groupsummary(data, ["isDirectionnalV", "isPCBothTracksV", "trackV"], ...
                        ["median", "std"], ["partP1RepV", "savingsPOST1V", "dirChangeRUN1V", "dirChangeRUN2V"]);

name = ["NoDir-NoBoth", "NoDir-Both", "Dir-NoBoth", "Dir-Both"];

count = reshape(G.GroupCount, [2, 4]);
replayPart = reshape(G.median_savingsPOST1V, [2, 4]);

tiledlayout(1, 2);
nexttile;
bar([1, 2, 3, 4], count);
nexttile;
bar([1, 2, 3, 4], replayPart);



%% Look at the distribution of directionality variation depending on the
% directionality of the cell at different times

t = tiledlayout(3, 2);


ax2 = nexttile;

histogram(dirChangeRUN1V(logical(isDirectionnalV) & trackV == 1), 20, 'Normalization','probability');
hold on;
histogram(dirChangeRUN1V(logical(isDirectionnalV) & trackV == 2), 20, 'Normalization','probability');
hold off;

title("Directional cells, change over RUN1");
ax3 = nexttile;

histogram(dirChangeRUN1V(~logical(isDirectionnalV) & trackV == 1), 20, 'Normalization','probability');
hold on;
histogram(dirChangeRUN1V(~logical(isDirectionnalV) & trackV == 2), 20, 'Normalization','probability');
hold off;

title("Non-directional cells, change over RUN1");

ax0 = nexttile;

histogram(savingsPOST1V(logical(isDirectionnalV) & trackV == 1), 20, 'Normalization','probability');
hold on;
histogram(savingsPOST1V(logical(isDirectionnalV) & trackV == 2), 20, 'Normalization','probability');
hold off;

title("Directional cells, change over POST1 sleep");
ax1 = nexttile;

histogram(savingsPOST1V(~logical(isDirectionnalV) & trackV == 1), 20, 'Normalization','probability');
hold on;
histogram(savingsPOST1V(~logical(isDirectionnalV) & trackV == 2), 20, 'Normalization','probability');hold off;

title("Non-directional cells, change over POST1 sleep");
ax4 = nexttile;

histogram(dirChangeRUN2V(logical(isDirectionnalV) & trackV == 1), 20, 'Normalization','probability');
hold on;
histogram(dirChangeRUN2V(logical(isDirectionnalV) & trackV == 2), 20, 'Normalization','probability');
hold off;

title("Directional cells, change over RUN2");
ax5 = nexttile;

histogram(dirChangeRUN2V(~logical(isDirectionnalV) & trackV == 1), 20, 'Normalization','probability');
hold on;
histogram(dirChangeRUN2V(~logical(isDirectionnalV) & trackV == 2), 20, 'Normalization','probability');
hold off;

title("Non-directional cells, change over RUN2");

linkaxes([ax0, ax1, ax2, ax3, ax4, ax5], 'xy');


%% Functions

% Function to get directional place cells based on Foster 2008 criteria
% Note : does not filters out bad place cells / non-pyramidal pc

function [directionalCells, dirOP] = getDirectionalCells(pfDir1, pfDir2)
peakDir1 = cellfun(@(x) max(x), pfDir1);
peakDir2 = cellfun(@(x) max(x), pfDir2);

directionalCells = find(peakDir1./peakDir2 >= 2 | peakDir1./peakDir2 <= 0.5);
dirOP = (peakDir1./peakDir2 >= 2)*1 + (peakDir1./peakDir2 <= 0.5)*2;
dirOP = dirOP(directionalCells);
end