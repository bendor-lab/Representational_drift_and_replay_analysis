% CELL CLASSIFICATION PER TRACK
% MH, 05.2020
% Classify cells in:
    % Unique cells in each track
    % Common cells between exposures
    % Cells that remap between exposures
    % Cell that global and rate remap between tracks (both during first and second exposure)

function cell_class = cell_classification(computer)

% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
elseif isempty(computer) %normal computer
    sessions = data_folders;
    session_names = fieldnames(sessions);
else %if entering a single folder 
    folders = {computer};
    session_names = folders;
end

i = 1; % session count

for p = 1 : length(session_names)
    if length(session_names) > 1 %more than one folder
        folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    end
    for s = 1: length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        folder_name = strsplit(pwd,'\');
        load extracted_place_fields_BAYESIAN.mat
        
        cell_class(i).session = folder_name{end};
        cell_class(i).protocol = str2num(cell_class(i).session(end));
        cell_class(i).total_cells = place_fields_BAYESIAN.good_place_cells;
        
        for t = 1 : length(place_fields_BAYESIAN.track)
            cell_class(i).(strcat('T',num2str(t),'_good_cells')) = place_fields_BAYESIAN.track(t).good_cells;
            cell_class(i).(strcat('T',num2str(t),'_unique_cells')) = place_fields_BAYESIAN.track(t).unique_cells;
        end
        
        % Common cells between exposures (do not global remap)
        cell_class(i).T1_T3_common_cells = intersect(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(3).good_cells);
        cell_class(i).T2_T4_common_cells = intersect(place_fields_BAYESIAN.track(2).good_cells,place_fields_BAYESIAN.track(4).good_cells);
        
        % Common cells between track (divided by exposure) 
        cell_class(i).T1_T2_common_cells = intersect(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
        cell_class(i).T3_T4_common_cells = intersect(place_fields_BAYESIAN.track(3).good_cells,place_fields_BAYESIAN.track(4).good_cells);
        
        % Cells that are in the 4 tracks
        cell_class(i).all_tracks_common_cells = intersect(cell_class(i).T1_T2_common_cells,cell_class(i).T3_T4_common_cells);
        
        % Cells that are in both exposures of one track but only in the first exposure of the other track 
        % (so it global remaps for one track, disappears after sleep)
        T1_T2_T3_common_cells = intersect(cell_class(i).T1_T2_common_cells,place_fields_BAYESIAN.track(3).good_cells);
        T1_T2_T4_common_cells = intersect(cell_class(i).T1_T2_common_cells,place_fields_BAYESIAN.track(4).good_cells);
        cell_class(i).T1_T2_T3_common_cells = setxor(T1_T2_T3_common_cells,cell_class(i).all_tracks_common_cells);
        cell_class(i).T1_T2_T4_common_cells = setxor(T1_T2_T4_common_cells,cell_class(i).all_tracks_common_cells);
        
        % Cells that are in both exposures of one track but only in the second exposure of the other track 
        % (so it global remaps for one track, appears after sleep)
        T3_T4_T1_common_cells = intersect(cell_class(i).T3_T4_common_cells,place_fields_BAYESIAN.track(1).good_cells);
        T3_T3_T2_common_cells = intersect(cell_class(i).T3_T4_common_cells,place_fields_BAYESIAN.track(2).good_cells);
        cell_class(i).T3_T4_T1_common_cells = setxor(T3_T4_T1_common_cells,cell_class(i).all_tracks_common_cells);
        cell_class(i).T3_T3_T2_common_cells = setxor(T3_T3_T2_common_cells,cell_class(i).all_tracks_common_cells);

        % Cells that global remap between exposures
        cell_class(i).T1_T3_diff_cells = setxor(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(3).good_cells);
        cell_class(i).T2_T4_diff_cells = setxor(place_fields_BAYESIAN.track(2).good_cells,place_fields_BAYESIAN.track(4).good_cells);
        
        % Cells that global remap between tracks (divided by exposure)
        cell_class(i).T1_T2_diff_cells = setxor(place_fields_BAYESIAN.track(1).good_cells,place_fields_BAYESIAN.track(2).good_cells);
        cell_class(i).T3_T4_diff_cells = setxor(place_fields_BAYESIAN.track(3).good_cells,place_fields_BAYESIAN.track(4).good_cells);
        
        i = i + 1;
    end
end


save('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Cell_count\cell_classification.mat','cell_class')



end