% CHAPTER 1 PIPELINE
% Marta Huelin and Masahiro Takigawa, 2023

function place_field_analysis_pipeline(section,computer)

if isempty(section)
    section = 1:1:4;
end

%%%%%%%%%% REMAPPING
if any(ismember(section,1))        
    
    % Population vector analysis with shuffle for global remapping (there's code for rate remapping shuffle not being used currently)
    population_vector_analysis('GPU',1,1,'Y');
    save_all_figures('Z:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis',[])
    population_vector_analysis('GPU',0,1,'Y');
    save_all_figures('Z:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis',[])
    global_shuffle_population_vector_analysis('GPU',1,1000,'Y')
    global_shuffle_population_vector_analysis('GPU',0,1000,'Y')
    
    % Variation of population vector analysis to calculate firing rate difference
    firing_rate_population_vector_analysis('GPU',1,'Y')
    firing_rate_population_vector_analysis([],0,'Y')
    firing_rate_shuffle_population_vector_analysis('GPU',1,1000,'Y') % rate remapping shuffle
    firing_rate_shuffle_population_vector_analysis([],0,1000,'Y') % rate remapping shuffle

    cell_class = cell_classification(computer); % classifies cells based on remapping
end

% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
else
    sessions = data_folders;
    session_names = fieldnames(sessions);
end

for s = 1 : length(session_names)
    disp(s)
    rat_folders = getfield(sessions,cell2mat(session_names(s)));
    
    % Alocate variables
    cellPopulation_LAPScorr = [];
    singleCell_LAPScorr =[];
    sameExposure_DecodingError = [];
    betweenExposures_DecodingError = [];
    ConsecutiveLaps_DecodingError = [];
    
    for f = 1 : length(rat_folders)
        cd(cell2mat(rat_folders(f)))
        session_info = extractAfter(cell2mat(rat_folders(f)),'HIPP\');
        rat_ID = session_info(1:5);
        session_day = session_info(13:16);
        protocol = session_info(18:21);
        disp(f)
        disp(cell2mat(rat_folders(f)))
    
   %%%%%%%%%% DECODING ERROR FOR EACH TRACK
        if any(ismember(section,2))
            disp('track decoding error')
         track_decoding_error = lap_decoding_error([]);
         save('track_decoding_error','track_decoding_error','-v7.3');
        end

   %%%%%%%%%% BAYESIAN DECODING AND DECODING ERROR        
       if any(ismember(section,3))

           tracks_DecodingError = [];
           tracks_DecodingError = bayesian_decoding_error_stability; %decoding error using last 4/1 Laps from the same exposure

           exposure_DecodingError = [];
           exposure_DecodingError = bayesian_decoding_error_exposures; %decoding error using same or other track's exposure
            
           consecutive_laps_DecodingError=[];
           consecutive_laps_DecodingError = bayesian_decoding_error_consecutive_laps(1); %decoding error of consecutive laps within exposure

           %%% SAVES STRUCTURES
           cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\extracted_data')

           % Adds rat and session info to the structure if it exists
           if ~isempty(tracks_DecodingError)

               for i = 1 : length(tracks_DecodingError) % add information about the session being analysed
                   tracks_DecodingError(i).rat = rat_ID;
                   tracks_DecodingError(i).protocol = protocol;
                   tracks_DecodingError(i).session_day = session_day;
               end
               DE_fields = length(fieldnames(tracks_DecodingError));
               tracks_DecodingError = orderfields(tracks_DecodingError,[DE_fields(end)-2:DE_fields(end),1:1:DE_fields(end)-3]); % reorganizes fields in structure

               % Check if the structure already exists
               if exist(strcat('SameExposure_DecodingError_',protocol,'.mat'),'file') == 2 && isempty(sameExposure_DecodingError) == 1
                   load(strcat('SameExposure_DecodingError_',protocol,'.mat'))
               end

               % Save in structure, or if already exists, concatenate them
               if isempty(sameExposure_DecodingError)
                   sameExposure_DecodingError = tracks_DecodingError;
               else
                   sameExposure_DecodingError = [sameExposure_DecodingError tracks_DecodingError]; % concatenate structures
               end
           end

           if ~isempty(exposure_DecodingError)
               for i = 1 : length(exposure_DecodingError)
                   exposure_DecodingError(i).rat = rat_ID;
                   exposure_DecodingError(i).protocol = protocol;
                   exposure_DecodingError(i).session_day = session_day;
               end
               DE_fields = length(fieldnames(exposure_DecodingError));
               exposure_DecodingError = orderfields(exposure_DecodingError,[DE_fields(end)-2:DE_fields(end),1:1:DE_fields(end)-3]); % reorganizes fields

               % Check if the structure already exists
               if exist(strcat('BetweenExposures_DecodingError_',protocol,'.mat'),'file') == 2 && isempty(betweenExposures_DecodingError) == 1
                   load(strcat('BetweenExposures_DecodingError_',protocol,'.mat'))
               end

               % Save in structure, or if already exists, concatenate them
               if isempty(betweenExposures_DecodingError)
                   betweenExposures_DecodingError = exposure_DecodingError;
               else
                   %betweenExposures_DecodingError = [betweenExposures_DecodingError exposure_DecodingError]; % concatenate structures
                   betweenExposures_DecodingError(f).comparison =  exposure_DecodingError.comparison; % concatenate structures
               end
           end
           
           if ~isempty(consecutive_laps_DecodingError)
               for i = 1 : length(consecutive_laps_DecodingError)
                   consecutive_laps_DecodingError(i).rat = rat_ID;
                   consecutive_laps_DecodingError(i).protocol = protocol;
                   consecutive_laps_DecodingError(i).session_day = session_day;
               end
               DE_fields = length(fieldnames(consecutive_laps_DecodingError));
               consecutive_laps_DecodingError = orderfields(consecutive_laps_DecodingError,[DE_fields(end)-2:DE_fields(end),1:1:DE_fields(end)-3]); % reorganizes fields
               
               % Check if the structure already exists
               if exist(strcat('ConsecutiveLaps_DecodingError_',protocol,'.mat'),'file') == 2 && isempty(ConsecutiveLaps_DecodingError) == 1
                   load(strcat('ConsecutiveLaps_DecodingError_',protocol,'.mat'))
               end
               
               % Save in structure, or if already exists, concatenate them
               if isempty(ConsecutiveLaps_DecodingError)
                   ConsecutiveLaps_DecodingError = consecutive_laps_DecodingError;
               else
                   ConsecutiveLaps_DecodingError = [ConsecutiveLaps_DecodingError consecutive_laps_DecodingError]; % concatenate structures
               end
           end
           
       end
       
       %%%%%%%%%% SINGLE CELL & POPULATION STABILITY
       if any(ismember(section,4))
           
           comparisons = {'between_exposures_FULLT1'};
           % within_track: compare laps within the same track exposure
           % between_exposures:compare laps between first and second exposure to the tracks
           % between_exposures_REexp:compare the last laps from second exposure to laps in first exposure
           % between_exposures_FULLT1: compares full ratemap of first exposure (T1/T2) to each lap of second exposure

           for comp = 1 : length(comparisons)
               cd(cell2mat(rat_folders(f)))
               % Looks at stability of place field (how similar are place fields between laps)
               laps_corr = [];
               singleCell_corr = [];
               [laps_corr,singleCell_corr] = plfield_LAPScomparison(comparisons{comp},1);
               
               cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\extracted_data')
               
               % Adds rat and session info to the structure
               for i = 1 : length(laps_corr)
                   laps_corr(i).rat = rat_ID;
                   singleCell_corr(i).rat = rat_ID;
                   laps_corr(i).protocol = protocol;
                   singleCell_corr(i).protocol = protocol;
                   laps_corr(i).session_day = session_day;
                   singleCell_corr(i).session_day = session_day;
               end
               lapcorr_fields = length(fieldnames(laps_corr));
               laps_corr = orderfields(laps_corr,[lapcorr_fields(end)-2:lapcorr_fields(end),1:1:lapcorr_fields(end)-3]); % reorganizes fields
               singcell_fields = length(fieldnames(singleCell_corr));
               singleCell_corr = orderfields(singleCell_corr,[singcell_fields(end)-2:singcell_fields(end),1:1:singcell_fields(end)-3]); % reorganizes fields
               
               % Check if the structure already exists in folder (but it's not open in the workspace)
               if exist(strcat('plCell_corr_',protocol,'_4lastLaps.mat'),'file') == 2 && isempty(cellPopulation_LAPScorr) == 1
                   load(strcat('plCell_corr_',protocol,'_4lastLaps.mat'))
               end
               
               % Save in structure, or if already exists, concatenate them
               if isempty(cellPopulation_LAPScorr)
                   cellPopulation_LAPScorr = laps_corr;
                   singleCell_LAPScorr = singleCell_corr;
               else
                   cellPopulation_LAPScorr = [cellPopulation_LAPScorr laps_corr]; % concatenate structures
                   
                   % For singleCell struct, if sizes are different, add empty fields to be able to concatenate
                   diff_size = length(fieldnames(singleCell_LAPScorr)) - length(fieldnames(singleCell_corr));
                   if diff_size > 0
                       for j = 1 : diff_size
                           fields = fieldnames(singleCell_LAPScorr);
                           extra_fieldname = fields(length(fieldnames(singleCell_LAPScorr))-diff_size+j);
                           singleCell_corr(1).(sprintf('%s',cell2mat(extra_fieldname))) = [];
                       end
                   elseif diff_size < 0
                       for j = 1 : abs(diff_size)
                           fields = fieldnames(singleCell_corr);
                           extra_fieldname = fields(length(fieldnames(singleCell_corr))-abs(diff_size)+j);
                           singleCell_LAPScorr(1).(sprintf('%s',cell2mat(extra_fieldname))) = [];
                       end
                   end
                   singleCell_LAPScorr = [singleCell_LAPScorr singleCell_corr];
               end
               
           end
       end
    end
    % Save accordingly to what has been run
    if any(ismember(section,1))
    end
    if any(ismember(section,3))
        if ~isempty(sameExposure_DecodingError)
            save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\extracted_data';
            save(sprintf('%s',save_path,'\',strcat('SameExposure_DecodingError_',protocol,'.mat')),'sameExposure_DecodingError','-v7.3');
        end
        if ~isempty(betweenExposures_DecodingError)
            save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\extracted_data';
            save(sprintf('%s',save_path,'\',strcat('BetweenExposures_DecodingError_',protocol,'.mat')),'betweenExposures_DecodingError','-v7.3');
            
        end
        if ~isempty(ConsecutiveLaps_DecodingError)
            save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\extracted_data';
            save(sprintf('%s',save_path,'\',strcat('ConsecutiveLaps_DecodingError_',protocol,'.mat')),'ConsecutiveLaps_DecodingError','-v7.3');
            
        end
    end
    if any(ismember(section,4))
        save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\extracted_data';
        save(sprintf('%s',save_path,'\',strcat('plCell_corr_',protocol,'_4lastLaps.mat')),'singleCell_LAPScorr','cellPopulation_LAPScorr','-v7.3');
    end
    
end

end

