% Script to plot the correlation at each space bin between T1 and T3
% place fields comparing first last and all laps

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));

load(PATH.SCRIPT + "/../Data/PC_Decoding_By_T1_X/place_fields_FirstLap_T1.mat")
load(PATH.SCRIPT + "/../Data/PC_Decoding_By_T1_X/place_fields_LastLap_T1.mat")
load(PATH.SCRIPT + "/../Data/PC_Decoding_By_T1_X/place_fields_AllLaps_T1.mat")

all_decoding = [place_fields_FirstLap, place_fields_LastLap, place_fields_AllLaps];
all_labels = ["First Lap", "Last Lap", "All Laps"];

for id_data = 1:length(all_decoding)

    target_decoding = all_decoding(id_data);
    
    % Tracks to compare
    trackOI1 = 1;
    trackOI2 = 3;
    
    % Vector which stores the correlations at each x_bin
    correlation_vector = repelem(0, 100);
    
    % Vector containing the good cells - Only use cells that are in both tracks
    
    allGoodCells_TOI1 = target_decoding.track(trackOI1).good_cells;
    allGoodCells_TOI2 = target_decoding.track(trackOI2).good_cells;
    
    [good_cells, ] = intersect(allGoodCells_TOI1, allGoodCells_TOI2);
    
    
    for i = 1:length(correlation_vector)
        activityCellsAtBin_TOI1 = repelem(0, length(good_cells));
        activityCellsAtBin_TOI2 = repelem(0, length(good_cells));
        
        for y = 1:length(good_cells)
            good_cell_ID = good_cells(y);
            
            currentPF_TOI1 = target_decoding.track(trackOI1).raw(good_cell_ID);
            currentPF_TOI1 = currentPF_TOI1{1};
            currentActivitiyAtBin_TOI1 = currentPF_TOI1(i);
            activityCellsAtBin_TOI1(y) = currentActivitiyAtBin_TOI1;
            
            currentPF_TOI2 = target_decoding.track(trackOI2).raw(good_cell_ID);
            currentPF_TOI2 = currentPF_TOI2{1};
            currentActivitiyAtBin_TOI2 = currentPF_TOI2(i);
            activityCellsAtBin_TOI2(y) = currentActivitiyAtBin_TOI2;
        end
        
        % We compute the correlation
        r = corrcoef(activityCellsAtBin_TOI1, activityCellsAtBin_TOI2);
        r = r(2, 1);
        correlation_vector(i) = r;
    end
    
    % We plot the correlation vector
    
    subplot(length(all_decoding), 1, id_data)
    plot(1:length(correlation_vector), correlation_vector)
    xlabel("X-bin position (2 cm)")
    ylabel("Correlation");
    
    if id_data == 1
        title("PF correlation between track " + trackOI1 + " and " + trackOI2 + " in function of the lap(s) used for PF decoding of track 1");
    end
    
    subtitle("Decoding : " + all_labels(id_data))
    
end