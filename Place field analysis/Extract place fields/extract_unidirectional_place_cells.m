% EXTRACT UNIDIRECTIONAL PLACE CELLS
% Classify cells in unidirectional, bidirectional or multiple peaks (where each peak location is different for each direction)
% MH,2020

function track = extract_unidirectional_place_cells

load extracted_directional_place_fields.mat
dir1 = directional_place_fields(1).place_fields;
dir2 = directional_place_fields(2).place_fields;

for i = 1 : length(dir1.track)
    
    % Find unidirectional cells
    track(i).dir1_unidirectional_cells = setdiff(dir1.track(i).good_cells,dir2.track(i).good_cells); % cells only in direction 1
    track(i).dir2_unidirectional_cells = setdiff(dir2.track(i).good_cells,dir1.track(i).good_cells); % cells only in direction 2
    
    % From cells that appear in both directions, check if their centre of mass is close
    common_cells = intersect(dir1.track(i).good_cells,dir2.track(i).good_cells);
    
    track(i).unidirectional_multi_peak = [];
    track(i).bidirectional_cells = [];
    for j = 1 : length(common_cells)
        %disp(num2str(dir1.track(i).centre(common_cells(j))))
        %disp(num2str(dir2.track(i).centre(common_cells(j))))
        centre_mass_diff = dir1.track(i).centre(common_cells(j)) - dir2.track(i).centre(common_cells(j));
        R_overlap = corr(dir1.track(i).smooth{common_cells(j)}',dir2.track(i).smooth{common_cells(j)}');
        if abs(centre_mass_diff) <= 30 & abs(R_overlap) > .14
            track(i).bidirectional_cells = [track(i).bidirectional_cells, common_cells(j)]; %if place fields overlap
            %disp(['Same peak ' num2str(centre_mass_diff) ' / ' num2str(R_overlap)])
        else
            track(i).unidirectional_multi_peak = [track(i).unidirectional_multi_peak, common_cells(j)];
            %disp(['Different peak ' num2str(centre_mass_diff) ' / ' num2str(R_overlap)])
        end
%         figure
%         plot(dir1.track(i).smooth{common_cells(j)})
%         hold on
%         plot(dir2.track(i).smooth{common_cells(j)})
%         pause
%         close all
    end
    % Save number of total spikes in both directions for each cell
    all_cells = sort(unique([track(i).unidirectional_multi_peak track(i).bidirectional_cells track(i).dir1_unidirectional_cells ...
        track(i).dir2_unidirectional_cells]));
    track(i).total_num_spikes(:,1) = all_cells;
    [track(i).total_num_spikes(:,2)] = cell2mat(arrayfun(@(x) sum([sum([dir1.track(i).spike_hist{1,x}]) sum([dir2.track(i).spike_hist{1,x}])]), all_cells,'UniformOutput',0));
    
    
end



end