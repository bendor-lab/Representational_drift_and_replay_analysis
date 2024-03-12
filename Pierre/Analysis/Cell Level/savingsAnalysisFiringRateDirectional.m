clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

% (and the clean number of laps)

% Arrays to hold all the data
animalV = [];
conditionV = [];
trackV = [];
cellV = [];
emdSavingsV = [];
diffSumSavingsV = [];

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

    temp = load(file + "\extracted_directional_lap_place_fields.mat");
    temp2 = load(file + "\extracted_directional_place_fields.mat");

    lap_directional_place_fields = temp.lap_directional_place_fields;
    directional_place_fields = temp2.directional_place_fields;

    for track = 1:2

        % Good Cells are good place cells on RUN2
        goodCells = union(directional_place_fields(1).place_fields.track(track + 2).good_cells, ...
            directional_place_fields(2).place_fields.track(track + 2).good_cells);

        % Get the directional lap data

        dataDir1RUN1 = lap_directional_place_fields(track).dir1.half_Lap;
        dataDir2RUN1 = lap_directional_place_fields(track).dir2.half_Lap;

        dataDir1RUN2 = lap_directional_place_fields(track + 2).dir1.half_Lap;
        dataDir2RUN2 = lap_directional_place_fields(track + 2).dir2.half_Lap;

        % Always a pair number of half laps
        if mod(length(dataDir1RUN1), 2) == 1
            dataDir1 = dataDir1RUN1(1:end-1);
            dataDir2 = dataDir2RUN1(1:end-1);
        end

        % We get the directional place field of the last lap of RUN1 and
        % the first one of RUN2

        pfDir1RUN1 = dataDir1RUN1{end - 1}.smooth;
        pfDir2RUN1 = dataDir2RUN1{end}.smooth;

        pfDir1RUN2 = dataDir1RUN2{1}.smooth;
        pfDir2RUN2 = dataDir2RUN2{2}.smooth;


        for cellID = 1:length(goodCells)

            cell = goodCells(cellID);

            % We get the Wasserstein distance between our place
            % fields

            emdDirecRUN1 = earthMoversDistance(pfDir1RUN1{cell}, pfDir2RUN1{cell});
            emdDirecRUN2 = earthMoversDistance(pfDir1RUN2{cell}, pfDir2RUN2{cell});

            emdSavings = emdDirecRUN2 - emdDirecRUN1;

            diffSumRUN1 = (sum(pfDir1RUN1{cell}) - sum(pfDir2RUN1{cell}))/...
                          (sum(pfDir1RUN1{cell}) + sum(pfDir2RUN1{cell}));

            diffSumRUN2 = (sum(pfDir1RUN2{cell}) - sum(pfDir2RUN2{cell}))/...
                          (sum(pfDir1RUN2{cell}) + sum(pfDir2RUN2{cell}));

            diffSumSavings = diffSumRUN2 - diffSumRUN1;

            % Save the data

            animalV = [animalV; animalOI];
            conditionV = [conditionV; conditionOI];
            trackV = [trackV; track];
            cellV = [cellV; cell];
            emdSavingsV = [emdSavingsV; emdSavings];
            diffSumSavingsV = [diffSumSavingsV; diffSumSavings];

        end
    end
end


% We mutate to only have the condition, not 16x...
conditionV(trackV == 1) = 16;
newConditions = split(conditionV(trackV ~= 1), 'x');
conditionV(trackV ~= 1) = newConditions(:, 2);

conditionV = str2double(conditionV);

data = table(animalV, conditionV, cellV, emdSavingsV, diffSumSavingsV);


% We mean by condition and animal (session)
G = groupsummary(data, ["animalV", "conditionV"], ...
    "median", ["emdSavingsV", "diffSumSavingsV"]);

allConditions = unique(conditionV);
allConditions = allConditions([1, 3, 4, 5, 6, 2]); % Re-order the condition


%% Inferential tests

% We center the condition
G.log_condition_centered = log(G.conditionV);
G.log_condition_centered = G.log_condition_centered - mean(G.log_condition_centered);

lm = fitlm(G,'median_diffSumSavingsV ~ log_condition_centered');
disp(lm);

figure;
plot(lm)


%% Functions

function emd = earthMoversDistance(p1, p2)
cdf1 = cumsum(p1);
cdf2 = cumsum(p2);
emd = sum(abs(cdf1 - cdf2));
end