% File to generate the metric data over laps

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths

% We create identifiers for cells from each session.
% Format is : IDENT-00-XXX
identifiers = 1:numel(sessions);
identifiers = identifiers* 1000;

% Arrays to hold all the data

sessionID = [];
animal = [];
condition = [];
track = [];
exposure = [];
lap = [];
cell = [];
CM = [];
maxFR = [];
meanFR = [];
Peak = [];
width = [];
skaggs = [];

% Extraction & computation

for fileID = 1:length(sessions)

    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data

    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
    ident = identifiers(fileID); % We get the identifier for the session

    % Load the variables

    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;

    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;

    % Track loop

    for trackOI = 1:2


        other_track = mod(trackOI + 1, 2) + mod(trackOI, 2)*2;

        % Good cells : Cells that where good place cells during RUN1 and RUN2
        goodCells = intersect(place_fields.track(trackOI).good_cells, place_fields.track(trackOI + 2).good_cells);

        for exposureOI = 1:2

            vTrack = trackOI + mod(exposureOI + 1, 2)*2;

            current_numberLaps = numel(lap_place_fields(vTrack).Complete_Lap);

            if current_numberLaps > 16
                current_numberLaps = 16;
            end

            for lapOI = 1:current_numberLaps

                current_lap_data = lap_place_fields(vTrack).Complete_Lap{lapOI};
                current_place_fields = current_lap_data.smooth;

                currentCM = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), current_place_fields);
                currentFR = cellfun(@max, current_place_fields);
                currentPeakLoc = cellfun(@(x) find(x == max(x), 1), current_place_fields);
                current_meanFR = current_lap_data.mean_rate_lap;

                currentFR(isnan(currentCM)) = NaN;
                currentPeakLoc(isnan(currentCM)) = NaN;
                
                currentCM = currentCM(goodCells);
                currentFR = currentFR(goodCells);
                currentPeakLoc = currentPeakLoc(goodCells);
                current_meanFR = current_meanFR(goodCells);
                
                current_skaggs = current_lap_data.skaggs_info(goodCells);
                
                nbGoodCells = numel(currentPeakLoc);

                % Save the data
                sessionID = [sessionID; repelem(fileID, nbGoodCells)'];
                animal = [animal; repelem(animalOI, nbGoodCells)'];
                condition = [condition; repelem(conditionOI, nbGoodCells)'];
                track = [track; repelem(trackOI, nbGoodCells)'];
                exposure = [exposure; repelem(exposureOI, nbGoodCells)'];
                lap = [lap; repelem(lapOI, nbGoodCells)'];
                cell = [cell; (goodCells + ident)'];
                CM = [CM; currentCM'];
                maxFR = [maxFR; currentFR'];
                Peak = [Peak; currentPeakLoc'];
                meanFR = [meanFR; current_meanFR'];
                skaggs = [skaggs; current_skaggs'];

            end
        end
    end
end



% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);


data = table(sessionID, animal, condition, exposure, lap, ...
             cell, CM, maxFR, Peak, meanFR, skaggs);

save("timeSeries.mat", "data")

%%

% clear
load("timeSeries.mat");

%% 1. Looking at the evolution of every metric across laps

sum1 = groupsummary(data, ["condition", "exposure", "lap"], ["mean", "std"], ...
                          ["CM", "maxFR", "Peak", "meanFR", "skaggs"]);
                      

timeSeriesOverLap(sum1, 'mean_maxFR', 'std_maxFR', "x")
                      
