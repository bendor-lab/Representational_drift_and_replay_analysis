function PV_corr_leave_one_lap_out
% MH 2021
% Runs population vector analysis comparing within a track, each lap's ratemap to the remaining laps ratemap. E.g. Track 1 lap 2 compared to
% laps 1 to 16, but excluding lap 2.


% Load name of data folders
sessions = data_folders;
session_names = fieldnames(sessions);

ses = 1;
for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',session_names{p}));
    for s = 1: length(folders)
        path = folders{s};
        cd(path)
        disp(path)
        load([path '\extracted_lap_place_fields.mat'])
        load([path '\extracted_laps.mat'])

        % For each track, run Pearson's correlation between each lap's ratemap and the ratemap of the rest of laps (e.g. ratemap lap 1
        % vs ratemap laps 2 to 8)
        num_tracks = size(lap_place_fields,2);
        for t = 1 : num_tracks
            if t == 1 & lap_times(t).number_completeLaps > 16 | t > 2
                num_laps = 16;
            else
                num_laps = lap_times(t).number_completeLaps;
            end
            for lap = 1 : num_laps
                
                if num_laps > 1
                    % Calculate ratemap of remaining laps on the track together
                    laps_idx = 1 : num_laps;
                    previous_laps = laps_idx(laps_idx<lap);
                    next_laps = laps_idx(laps_idx>lap);
                    if isempty(previous_laps) %when analysing first lap
                        previous_laps = [next_laps(1) next_laps(end)];%the get_place_fields_lap_exclusion code will only consider the previous_laps
                        next_laps = [];
                    else
                        previous_laps = [previous_laps(1) previous_laps(end)];
                    end
                    if ~isempty(next_laps)
                        next_laps = [next_laps(1) next_laps(end)];
                    end
                    remaining_laps_place_fields = get_place_fields_lap_exclusion(t,previous_laps,next_laps,0,0);
                    lap_selection = 'Complete_Lap';
                else % if 1 Lap track
                    remaining_laps_place_fields = get_place_fields_lap_exclusion(t,[],[],0,1);
                    lap_selection = 'half_Lap';
                end
                % Find max peak FR for each cell across both ratemaps
                common_good_cells = intersect(remaining_laps_place_fields.good_cells,lap_place_fields(t).(sprintf('%s',lap_selection)){1,lap}.good_cells);
                PV_vals.num_of_common_good_cells(t,ses,lap) = length(common_good_cells);
                PV_vals.num_of_remapped_cells(t,ses,lap) = length(setxor(remaining_laps_place_fields.good_cells,lap_place_fields(t).(sprintf('%s',lap_selection)){1,lap}.good_cells));
                good_peakFR =  [remaining_laps_place_fields.peak(common_good_cells);lap_place_fields(t).(sprintf('%s',lap_selection)){1,lap}.peak(common_good_cells)]; % finds peak FR for each cell across ratemaps                
                max_peakFR = max(good_peakFR,[],1); %max peak FR per cell between both ratemaps

                % Create a normalized matrix for each ratemap
                remaining_laps_ratemap = remaining_laps_place_fields.smooth(common_good_cells); % finds sorted ratemaps of good cells
                remaining_laps_ratemap_matrix = reshape(cell2mat(remaining_laps_ratemap),[length(remaining_laps_ratemap),length(remaining_laps_ratemap{1,1})]); % create a matrix with sorted ratemaps
                remaining_laps_NORM_ratemap = remaining_laps_ratemap_matrix./max_peakFR'; % normalize to the max peak firing rate of the pertinent cell

                curr_lap_ratemap = lap_place_fields(t).(sprintf('%s',lap_selection)){1,lap}.smooth(common_good_cells);
                curr_laps_ratemap_matrix = reshape(cell2mat(curr_lap_ratemap),[length(curr_lap_ratemap),length(curr_lap_ratemap{1,1})]); % create a matrix with sorted ratemaps
                curr_laps_NORM_ratemap = curr_laps_ratemap_matrix./max_peakFR'; % normalize to the max peak firing rate of the pertinent cell

                % Calculate cell population vector for each ratemap comparison by correlating each position bin between
                % tracks
                for j = 1 : size(remaining_laps_NORM_ratemap,2)
                    [rho,pval] = corr(remaining_laps_NORM_ratemap(:,j), curr_laps_NORM_ratemap(:,j)); % Default is Pearson
                    population_vector(j) = rho; % each row a position bin
                    ppvector_pval(j) = pval;
                end
                PV_vals.population_vector{t,ses,lap} = population_vector; % track, session, lap number
                PV_vals.ppvector_pval{t,ses,lap} = ppvector_pval;
                PV_vals.average_lap_population_vector(t,ses,lap) = mean(PV_vals.population_vector{t,ses,lap},'omitnan');
                PV_vals.average_lap_ppvector_pval(t,ses,lap) = mean(PV_vals.ppvector_pval{t,ses,lap},'omitnan');
            end
            PV_vals.averaged_track_PVcorr(t,ses) = mean(PV_vals.average_lap_population_vector(t,ses,:),'omitnan');
            PV_vals.std_track_PVcorr(t,ses) = std(PV_vals.average_lap_population_vector(t,ses,:),[],'omitnan');
            PV_vals.averaged_track_PVpval(t,ses) =  mean(PV_vals.average_lap_ppvector_pval(t,ses,:),'omitnan');

            clear population_vector ppvector_pval remaining_laps_ratemap_matrix remaining_laps_NORM_ratemap remaining_laps_ratemap ...
               curr_laps_NORM_ratemap curr_laps_ratemap_matrix curr_lap_ratemap remaining_laps_place_fields
        end
        ses = ses +1; %next session


    end
end
save('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\lap_PV_comparison.mat','PV_vals','-v7.3')

end
        
