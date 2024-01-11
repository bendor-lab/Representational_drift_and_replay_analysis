function global_shuffle_population_vector_analysis(computer,bayesian_option,num_shuffles,save_option)
% Marta Huelin_February 2020
% Computes population vectors between shuffled matrices for the same type of comparisons used in the population_vector_analysis.m code (meaning,
% between same track exposures and between different tracks). One type of shuffle: 
    % cellID shuffle of the ratemaps to simulate global remapping
% INPUT:
    % Bayesian_option: 1 for using bayesian place fields (x_bin = 10cm), 0 for using high resolution place fields (x_bin = 2cm)
    % num_shuffles: number of shuffles to run (e.g. 1000)
    % Save_option: 'Y' for saving the data, else for not saving


% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
else
    sessions = data_folders;
    session_names = fieldnames(sessions);
end
if isempty(num_shuffles)
    num_shuffles = 1000;
end

% Parameters
comparisons = {[1,3],[2,4],[1,2],[2,3],[1,4],[3,4]}; %track comparisons to test
PP = plotting_parameters;

for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    protocol_shuffle(p).session_ID = cell2mat(session_names(p));
    
    for s = 1: length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        
        if exist(strcat(pwd,'\extracted_place_fields.mat'),'file')
            if bayesian_option == 1
                load('extracted_place_fields_BAYESIAN.mat')
                place_fields = place_fields_BAYESIAN;
                clear place_fields_BAYESIAN
            else
                load('extracted_place_fields.mat')
            end
            load('extracted_laps.mat')
            
            % Find max peak FR for each cell across tracks
            good_peakFR = []; max_peakFR = [];
            for t = 1 : length(place_fields.track)
                good_peakFR(t,:) = place_fields.track(t).peak(place_fields.good_place_cells); % finds peak FR for each cell across tracks
            end
            max_peakFR = max(good_peakFR,[],1); %max peak FR per cell between all the tracks
            
            % Create a normalized matrix for each track
            track = [];
            for t = 1 : length(place_fields.track)
                if bayesian_option == 1
                    good_ratemaps = place_fields.track(t).raw(place_fields.good_place_cells); % finds sorted ratemaps of good cells across all tracks
                else
                    good_ratemaps = place_fields.track(t).smooth(place_fields.good_place_cells); % finds sorted ratemaps of good cells across all tracks
                end
                ratemaps_matrix = reshape(cell2mat(good_ratemaps),[length(good_ratemaps),length(good_ratemaps{1,1})]); % create a matrix with ratemaps
                track(t).norm_ratemaps = ratemaps_matrix./max_peakFR'; % normalize to the max peak firing rate of the pertinent cell
            end
            
            % Calculate cell population vector for each track comparison by correlating each position bin between tracks
            shuffled_globalRemap_PPvector.population_vector = [];
            shuffled_globalRemap_PPvector.pval = [];
            for sh = 1 : num_shuffles
                cellID_shuffled_matrix = []; 
                % Create shuffled matrix for global remapping: shuffle cell ID 
                for tt = 1 : length(track)
                    cellID_shuffled_matrix(tt).norm_ratemaps = track(tt).norm_ratemaps(randperm(size(track(tt).norm_ratemaps,1)),:); %shuffle cell ID
                end
                curr_size = size(shuffled_globalRemap_PPvector.population_vector,1);
                for i = 1 : length(comparisons)
                    comp = cell2mat(comparisons(i));
                    for j = 1 : size(track(1).norm_ratemaps,2)
                        % Correlation to global remapping shuffle
                        [Grho,Gpval] = corr(track(comp(1)).norm_ratemaps(:,j), cellID_shuffled_matrix(comp(2)).norm_ratemaps(:,j)); %corr between position bins across cells
                        shuffled_globalRemap_PPvector.population_vector(curr_size+j,i) = Grho; %each column is a comparison, each row a position bin
                        shuffled_globalRemap_PPvector.pval(curr_size+j,i) = Gpval;
                    end
                end
            end
            
            %save
            protocol_shuffle(p).session(s).shuffled_globalRemap_PPvector = shuffled_globalRemap_PPvector.population_vector;
            protocol_shuffle(p).session(s).shuffled_globalRemap_PPvector_pval = shuffled_globalRemap_PPvector.pval;
            protocol_shuffle(p).session(s).shuffle_population_vector = folders(s);
            
            
            %%%%%%%%%%%% Repeat previous steps using only section of laps for T1
            
            % For better comparison, compare same amount of laps in T1 and T2. For that, extract the place fields for the pertinent amount of laps
            lap_start = 1;
            lap_end = str2num(protocol_shuffle(p).session_ID(end)); %number of laps of this protocol
            section_place_fields = get_lap_place_fields(1,lap_start,lap_end,bayesian_option,'complete');
            
            % Replace peakFR of T1 by the lap section
            section_peakFT = good_peakFR;
            section_peakFT(1,:) = section_place_fields.peak(place_fields.good_place_cells); % finds peak FR for each cell across tracks
            section_maxPeakFr = max(section_peakFT,[],1); %max peak FR per cell between all the tracks
            
            % Create a normalized matrix for each track
            track_section = [];
            for t = 1 : length(place_fields.track)
                 if t ==1
                    if bayesian_option == 1
                        good_ratemaps = section_place_fields.raw(place_fields.good_place_cells); % finds sorted ratemaps of good cells across all tracks
                    else
                        good_ratemaps = section_place_fields.smooth(place_fields.good_place_cells); % finds sorted ratemaps of good cells across all tracks
                    end
                else
                    if bayesian_option == 1
                        good_ratemaps = place_fields.track(t).raw(place_fields.good_place_cells); % finds sorted ratemaps of good cells across all tracks
                    else
                        good_ratemaps = place_fields.track(t).smooth(place_fields.good_place_cells); % finds sorted ratemaps of good cells across all tracks
                    end
                end
                ratemaps_matrix = reshape(cell2mat(good_ratemaps),[length(good_ratemaps),length(good_ratemaps{1,1})]); % create a matrix with sorted ratemaps
                track_section(t).norm_ratemaps = ratemaps_matrix./section_maxPeakFr'; % normalize to the max peak firing rate of the pertinent cell
            end
            
            % Calculate cell population vector for each track comparison by correlating each position bin between tracks
            shuffled_globalRemap_PPvector.section_population_vector = [];
            shuffled_globalRemap_PPvector.section_ppvector_pval = [];
            for sh = 1 : num_shuffles
                cellID_shuffled_matrix = [];
                % Create shuffled matrix for global remapping: shuffle cell ID 
                for tt = 1 : length(track_section)
                    cellID_shuffled_matrix(tt).norm_ratemaps = track_section(tt).norm_ratemaps(randperm(size(track_section(tt).norm_ratemaps,1)),:); %shuffle cell ID
                end
                
                % Calculate cell population vector for each track comparison by correlating each position bin between tracks
                curr_size = size(shuffled_globalRemap_PPvector.section_population_vector,1);
                for i = 1 : length(comparisons)-3 %only run first 3 comparisons
                    comp = cell2mat(comparisons(i));
                    for j = 1 : size(track_section(1).norm_ratemaps,2)
                        % Correlation to global remapping shuffle
                        [Grho,Gpval] = corr(track_section(comp(1)).norm_ratemaps(:,j), cellID_shuffled_matrix(comp(2)).norm_ratemaps(:,j)); %corr between position bins across cells
                        shuffled_globalRemap_PPvector.section_population_vector(curr_size+j,i) = Grho; %each column is a comparison, each row a position bin
                        shuffled_globalRemap_PPvector.section_ppvector_pval(curr_size+j,i) = Gpval;
                    end
                end
            end
            
            %save
            protocol_shuffle(p).session(s).shuffled_globalRemap_PPvector_SECTION = shuffled_globalRemap_PPvector.section_population_vector;
            protocol_shuffle(p).session(s).shuffled_globalRemap_PPvector_pval_SECTION = shuffled_globalRemap_PPvector.section_ppvector_pval;
            
        end
    end
    %%%%%%%%% Now, for each protocol, concatenate all rats shuffled population vectors together (for both whole session and sections)
    
    all_PPvectors_GR = [];   all_section_PPvectors_GR = [];
    for jj = 1 : length(protocol_shuffle(p).session)
        all_PPvectors_GR = [all_PPvectors_GR; protocol_shuffle(p).session(jj).shuffled_globalRemap_PPvector];
        all_section_PPvectors_GR = [all_section_PPvectors_GR; protocol_shuffle(p).session(jj).shuffled_globalRemap_PPvector_SECTION];
    end
    protocol_shuffle(p).all_PPvectors_globalRemap = all_PPvectors_GR;
    protocol_shuffle(p).all_section_PPvectors_globalRemap = all_section_PPvectors_GR;
end

protocol_global_shuffle = protocol_shuffle;
save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\';
if strcmp(save_option,'Y')
    if bayesian_option == 1
        save(sprintf('%s',save_path,'\global_shuffle_population_vector_data_bayesian.mat'),'protocol_global_shuffle','-v7.3');
    else
        save(sprintf('%s',save_path,'\global_shuffle_population_vector_data.mat'),'protocol_global_shuffle','-v7.3');        
    end
end


end








