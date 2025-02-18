%% Script to get metrics from every lap with the last lap
% of RUN1 vs. the 16th lap of RUN2

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
CMdiff = [];
FRdiff = [];
PeakDiff = [];

% We take the absolute value of the difference over sum to get the relative
% distance with the FPF, independently of the direction
diffSum = @(x1, x2) abs(x1 - x2)/(x1 + x2);

%% Extraction & computation

parfor fileID = 1:length(sessions)

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
        
        goodPCRUN1 = place_fields.track(trackOI).good_cells;
        goodPCRUN2 = place_fields.track(trackOI + 2).good_cells;

        % Control : Cells that where good place cells during RUN1 and RUN2
        % (no appearing / disappearing cells).
        goodCells = intersect(goodPCRUN1, goodPCRUN2);
         
        for exposureOI = 1:2

            vTrack = trackOI + mod(exposureOI + 1, 2)*2;
            current_numberLaps = numel(lap_place_fields(vTrack).Complete_Lap);
            
            if current_numberLaps == 1
                continue;
            end
            
            if current_numberLaps > 16
                current_numberLaps = 16;
            end
            
            current_template = lap_place_fields(vTrack).Complete_Lap{end}.smooth;

            % Define the template (last lap)
            cmFPF = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), current_template);
            frFPF = cellfun(@max, current_template);
            peakFPF = cellfun(@(x) find(x == max(x), 1), current_template);
    
            % If the firing rate is 0 on the whole track, the CM calculation
            % will return NaN. In that case, max firing rate and peak don't
            % have sense, we can NaN everything.
    
            frFPF(isnan(cmFPF)) = NaN;
            peakFPF(isnan(cmFPF)) = NaN;

            for lapOI = 1:(current_numberLaps-1)

                current_lap_data = lap_place_fields(vTrack).Complete_Lap{lapOI};
                current_place_fields = current_lap_data.smooth;

                currentCM = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), current_place_fields);
                currentFR = cellfun(@max, current_place_fields);
                currentPeakLoc = cellfun(@(x) find(x == max(x), 1), current_place_fields);
                    
                % Take the max firing rate
                current_maxFR = cellfun(@(x) max(x), current_lap_data.smooth(:), 'UniformOutput', false);
                current_maxFR = cell2mat(current_maxFR);

                current_meanFR = current_lap_data.mean_rate_lap;

                currentFR(isnan(currentCM)) = NaN;
                currentPeakLoc(isnan(currentCM)) = NaN;

                current_CMDiff = abs(cmFPF - currentCM);
                current_FRDiff = arrayfun(@(x1, x2) abs(x1 - x2)/(x1 + x2), frFPF, currentFR);
                current_PeakLocDiff = abs(peakFPF - currentPeakLoc);

                current_CMDiff = current_CMDiff(goodCells);
                current_FRDiff = current_FRDiff(goodCells);
                current_PeakLocDiff = current_PeakLocDiff(goodCells);

                current_maxFR = current_maxFR(goodCells);

                nbGoodCells = numel(goodCells);

                % Save the data
                sessionID = [sessionID; repelem(fileID, nbGoodCells)'];
                animal = [animal; repelem(animalOI, nbGoodCells)'];
                condition = [condition; repelem(conditionOI, nbGoodCells)'];
                track = [track; repelem(trackOI, nbGoodCells)'];
                exposure = [exposure; repelem(exposureOI, nbGoodCells)'];
                lap = [lap; repelem(lapOI, nbGoodCells)'];
                cell = [cell; (goodCells + ident)'];
                CMdiff = [CMdiff; current_CMDiff'];
                FRdiff = [FRdiff; current_FRDiff'];
                PeakDiff = [PeakDiff; current_PeakLocDiff'];

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

data = table(sessionID, animal, condition, exposure, lap, cell, CMdiff, FRdiff, PeakDiff);

save("cell_data_learning.mat", "data")