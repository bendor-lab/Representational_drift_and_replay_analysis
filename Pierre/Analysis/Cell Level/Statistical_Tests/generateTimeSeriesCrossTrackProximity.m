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
exposure = [];
lap = [];
cell = [];
trackDiffCM = [];
trackDiffFR = [];
trackDiffPeak = [];

% We take the absolute value of the difference over sum to get the relative
% distance with the FPF, independently of the direction
diffSum = @(x1, x2) abs(x1 - x2)/(x1 + x2);

%% Extraction & computation

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
    %temp = load(file + "\extracted_directional_lap_place_fields");
    lap_place_fields = temp.lap_place_fields;
    
    for exposureOI = 0:2:2
        
        t1 = 1 + exposureOI;
        t2 = 2 + exposureOI;
        
        
        % We get the minimum amount of laps
        nbLapsT1 = (numel(lap_place_fields(t1).half_Lap) - ...
            mod(numel(lap_place_fields(t1).half_Lap), 2))/2;
        
        nbLapsT2 = (numel(lap_place_fields(t2).half_Lap) - ...
            mod(numel(lap_place_fields(t2).half_Lap), 2))/2;
        
        current_nb_laps = min(nbLapsT1, nbLapsT2);
        
        
        if current_nb_laps > 16
            current_nb_laps = 16;
        end
        
        for lapOI = 1:current_nb_laps
            
            lapDataT1 = lap_place_fields(t1).Complete_Lap{lapOI};
            lapDataT2 = lap_place_fields(t2).Complete_Lap{lapOI};
            goodCells = intersect(lapDataT1.good_cells, lapDataT2.good_cells);
            
            current_place_fields_T1 = lapDataT1.smooth;
            current_place_fields_T2 = lapDataT2.smooth;
            
            currentCMT1 = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), current_place_fields_T1);
            currentFRT1 = cellfun(@max, current_place_fields_T1);
            currentPeakLocT1 = cellfun(@(x) find(x == max(x), 1), current_place_fields_T1);
            
            currentCMT2 = cellfun(@(x) sum(x.*(1:2:200)/sum(x)), current_place_fields_T2);
            currentFRT2 = cellfun(@max, current_place_fields_T2);
            currentPeakLocT2 = cellfun(@(x) find(x == max(x), 1), current_place_fields_T2);
            
            % We take the CM and peak FR difference based on the DISTANCE
            % WITH THE MIDDLE
            
            currentTrackCMDiff = abs(abs(100 - currentCMT1) - abs(100 - currentCMT2));
            currentTrackPeakDiff = abs(abs(100 - currentPeakLocT1) - abs(100 - currentPeakLocT2));
            currentTrackFRDiff = abs(currentFRT1 - currentFRT2);
            
            currentTrackCMDiff = currentTrackCMDiff(goodCells)';
            currentTrackPeakDiff = currentTrackPeakDiff(goodCells)';
            currentTrackFRDiff = currentTrackFRDiff(goodCells)';
            
            nbGoodCells = numel(goodCells);
            
            % Save the data
            sessionID = [sessionID; repelem(fileID, nbGoodCells)']
            animal = [animal; repelem(animalOI, nbGoodCells)'];
            condition = [condition; repelem(conditionOI, nbGoodCells)'];
            exposure = [exposure; repelem(exposureOI, nbGoodCells)'];
            lap = [lap; repelem(lapOI, nbGoodCells)'];
            cell = [cell; (goodCells + ident)'];
            trackDiffCM = [trackDiffCM; currentTrackCMDiff];
            trackDiffFR = [trackDiffFR; currentTrackFRDiff];
            trackDiffPeak = [trackDiffPeak; currentTrackFRDiff];
            
        end
    end
end



% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

newConditions = split(condition, 'x');
condition = newConditions(:, 2);
condition = str2double(condition);


data = table(sessionID, animal, condition, exposure, lap, cell, trackDiffCM, trackDiffFR, trackDiffPeak);

save("timeSeries_cross_track_distance.mat", "data")

