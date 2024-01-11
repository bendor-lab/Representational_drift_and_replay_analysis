% REMAPPED CELLS - looks at cells that appear or disappear between
% different tracks or between same track different exposures

function remapped_cells

load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Cell_count\cell_classification.mat')

for i = 1: 20
    
    T1_within_track_change(i) = (length(unique([cell_class(i).T1_unique_cells,cell_class(i).T3_unique_cells,cell_class(i).T1_T3_diff_cells])))/length(cell_class(i).total_cells);
    T2_within_track_change(i) = (length(unique([cell_class(i).T2_unique_cells,cell_class(i).T4_unique_cells,cell_class(i).T2_T4_diff_cells])))/length(cell_class(i).total_cells);
    T1_T2_change(i) = (length(unique([cell_class(i).T2_unique_cells,cell_class(i).T1_unique_cells,cell_class(i).T1_T2_diff_cells])))/length(cell_class(i).total_cells);

end

T1_within_track_change_MEAN = mean(T1_within_track_change);
T2_within_track_change_MEAN = mean(T2_within_track_change);
T1_T2_change_MEAN = mean(T1_T2_change);

T1_within_track_change_std = std(T1_within_track_change);
T2_within_track_change_std = std(T2_within_track_change);
T1_T2_change_std= std(T1_T2_change);

% T2 separate
count = 1;
for j = 1: 5
    separate_means(j) = mean(T2_within_track_change(count:count+3));
    seperate_std(j) = std(T2_within_track_change(count:count+3));
    count =  count+4;
end


end