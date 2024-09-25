% File to generate the metric data over laps -
% CONTROL : split track 1 condition at the same lap as track 2

clear
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % We fetch all the sessions folders paths
% sessions = data_folders_deprivation;

% We create identifiers for cells from each session.
% Format is : IDENT-00-XXX
identifiers = 1:numel(sessions);
identifiers = identifiers* 1000;

% Order of the tracks : first line is exposure, second line is re-exposure
% Note : EVEN IF order in control day 1 is T1 - T2 -> T2 - T1, the order 1
% 2 3 4 is the same as for the experimental condition (1 - 3 / 2 - 4 for exposure / re-exposure)

track_order = [1 2; 3 4];

% Arrays to hold all the data

sessionID = [];
animal = [];
condition = [];
track = [];
exposure = [];
lap = [];
pvCorr = [];
speed = [];

%% Extraction & computation

parfor fileID = 1:length(sessions)
    
    disp(fileID);
    file = sessions{fileID}; % We get the current session
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    animalOI = string(animalOI);
    conditionOI = string(conditionOI); % We convert everything to string
        
    % Load the variables
    
    temp = load(file + "\extracted_place_fields.mat");
    place_fields = temp.place_fields;
    
    temp = load(file + "\extracted_lap_place_fields.mat");
    lap_place_fields = temp.lap_place_fields;
        
    temp = load(file + "\extracted_laps");
    lap_times = temp.lap_times;
    
    % Track loop
    
    for trackOI = 1:2
        
        other_track = mod(trackOI + 1, 2) + 2*mod(trackOI, 2);
        
        % Control : Cells that where good place cells during RUN1 and RUN2
        % (no appearing / disappearing cells).
        goodCells = intersect(place_fields.track(track_order(1, trackOI)).good_cells, place_fields.track(track_order(2, trackOI)).good_cells);
        
        % We get the final place field :
        
        nb_lap_T1_R1 = numel(lap_place_fields(1).Complete_Lap);
        nb_lap_T1_R2 = numel(lap_place_fields(3).Complete_Lap);
        nb_lap_T2_R1 = numel(lap_place_fields(2).Complete_Lap);
        nb_lap_T2_R2 = numel(lap_place_fields(4).Complete_Lap);
        
        % We get the number of laps ran in T2 before FPF calculation
        total_nb_T2 = nb_lap_T2_R1 + 16;
        % This gives us when should the FPF calculation starts for track 1
        start_FPF_T1 = total_nb_T2 - nb_lap_T1_R1;
        
        if trackOI == 1
            to_start = start_FPF_T1;
        else
            to_start = 16;
        end
        
        RUN1LapPFData = lap_place_fields(trackOI).Complete_Lap;
        RUN2LapPFData = lap_place_fields(trackOI + 2).Complete_Lap;
        
        numberLapsRUN2 = length(RUN2LapPFData);
        
        finalPlaceField = {};
        
        % For each cell, we create the final place field
        for cellID = 1:length(place_fields.track(trackOI + 2).smooth)
            temp = [];
            
            for clap = 1:6
                temp = [temp; RUN2LapPFData{to_start + clap}.smooth{cellID}];
            end
            
            finalPlaceField(end + 1) = {mean(temp, 'omitnan')};
        end
        
        % We merge the laps from exposure and re-exposure
        
        all_place_fields = [lap_place_fields(trackOI).Complete_Lap, ...
            lap_place_fields(trackOI+2).Complete_Lap];
        
        all_place_fields = all_place_fields(1:total_nb_T2);
                
        current_numberLaps = numel(all_place_fields);
        
%         for good_c = goodCells
%             figure;
%             subplot(1, 2, 1);
%             bar(all_place_fields{5}.smooth{good_c});
%             subplot(1, 2, 2);
%             bar(all_place_fields{end}.smooth{good_c});
%         end
%         
%         linkaxes()
        
        for lapOI = 1:current_numberLaps
                        
            current_lap_data = all_place_fields{lapOI};
            current_place_fields = current_lap_data.smooth;
                        
            current_pvCorr = getPVCor(goodCells, current_place_fields, finalPlaceField, "cosine");
            
            current_pvCorr = median(current_pvCorr, 'omitnan');
            
            % Save the data
            
            sessionID = [sessionID; fileID];
            animal = [animal; animalOI];
            condition = [condition; conditionOI];
            track = [track; trackOI];
            lap = [lap; lapOI];
            pvCorr = [pvCorr; current_pvCorr];            
            
        end
    end
end

% We mutate to only have the number of lap run during RUN1 (assuming not intra),
% not 16x...

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);

condition = str2double(condition);

data = table(sessionID, animal, condition, lap, pvCorr);

save("control_split_TS_cosine.mat", "data")

%%

load("control_split_TS.mat")

for c = [1 2 3 4 8]
    figure;
    sub = data(data.condition == c, :);
    all_sessions = unique(sub.sessionID);
    matching_16_data = data(ismember(data.sessionID, all_sessions) & ...
                       data.condition == 16, :);
    summ_c = groupsummary(sub, "lap", "mean", "pvCorr");
    summ_16 = groupsummary(matching_16_data, "lap", "mean", "pvCorr");
    hold on;
    
    plot(summ_c.lap, summ_c.mean_pvCorr, "LineWidth", 2);
    plot(summ_16.lap, summ_16.mean_pvCorr, "LineWidth", 2);

    legend()
end