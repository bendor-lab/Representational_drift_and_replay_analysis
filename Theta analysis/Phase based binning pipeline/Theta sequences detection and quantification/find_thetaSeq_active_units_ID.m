
function thetaSeq_units_properties = find_thetaSeq_active_units_ID

load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Cell_count\cell_classification.mat')
load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\thetaseq_scores_individual_laps.mat')

if ~exist('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\thetaSeq_units_properties.mat','file')
sessions = data_folders;
session_names = fieldnames(sessions);
c = 1;

for p = 1 : length(session_names)
    
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    
    for s = 1 : length(folders)
        cd(cell2mat(folders(s)))
        
        theta_windows = extract_theta_window([],'Y');
        load('Theta\decoded_theta_sequences.mat')
        load('Theta\theta_sequence_quantification.mat')
        
        for t = 1 : 2
            dir1_idx = [centered_averaged_thetaSeq.direction1(t).thetaseq(:).theta_window_index];
            dir2_idx = [centered_averaged_thetaSeq.direction2(t).thetaseq(:).theta_window_index];
            
            for ts = 1 : length(centered_averaged_thetaSeq.unidirectional(t).thetaseq)
                
                idx = centered_averaged_thetaSeq.unidirectional(t).thetaseq(ts).theta_window_index;
                if any(ismember(dir1_idx, idx))
                    if max(theta_windows.track(t).thetaseq_idx_active_units{idx}) > length(decoded_thetaSeq.direction1(t).track_active_units_ID)
                        continue 
                    end
                    thetaSeq_units_ID = decoded_thetaSeq.direction1(t).track_active_units_ID(theta_windows.track(t).thetaseq_idx_active_units{idx});
                elseif any(ismember(dir2_idx, idx))
                     if max(theta_windows.track(t).thetaseq_idx_active_units{idx}) > length(decoded_thetaSeq.direction2(t).track_active_units_ID)
                        continue 
                    end
                    thetaSeq_units_ID = decoded_thetaSeq.direction2(t).track_active_units_ID(theta_windows.track(t).thetaseq_idx_active_units{idx});
                else
                    disp(['Cannot find index in any direction for theta seq number ' num2str(ts)])
                    continue
                end
                centered_averaged_thetaSeq.unidirectional(t).thetaseq(ts).thetaSeq_units_ID = thetaSeq_units_ID;
                
                % Find to which lap belongs each theta seq
                
                for jj = 1 : length(lap_theta_window_indx(c).track(t).undir_idx)
                    if any(ismember(lap_theta_window_indx(c).track(t).undir_idx{1,jj},idx))
                        lap = jj;
                        lapID(lap).unique_cells(ts) = length(find(ismember(cell_class(c).(sprintf('%s','T',num2str(t),'_unique_cells')),thetaSeq_units_ID)));
                        lapID(lap).non_remap_exposures(ts) = length(find(ismember(cell_class(c).(sprintf('%s','T',num2str(t),'_T',num2str(t+2),'_common_cells')),thetaSeq_units_ID)));
                        lapID(lap).non_remap_tracks(ts) = length(find(ismember(cell_class(c).T1_T2_common_cells,thetaSeq_units_ID)));
                        lapID(lap).remap_tracks(ts) = length(find(ismember(cell_class(c).T1_T2_diff_cells,thetaSeq_units_ID)));
                        lapID(lap).all_tracks_common(ts) = length(find(ismember(cell_class(c).all_tracks_common_cells,thetaSeq_units_ID)));
                        break 
                    end                    
                end
                
            end
            
            for lap = 1 : length(lapID)
                
                total = sum(lapID(lap).unique_cells)+sum(lapID(lap).non_remap_exposures)+sum(lapID(lap).non_remap_tracks)+sum(lapID(lap).remap_tracks)+sum(lapID(lap).all_tracks_common);
                
                thetaSeq_units_properties(t).lapID(lap).unique_cells(c)= sum(lapID(lap).unique_cells);
                thetaSeq_units_properties(t).lapID(lap).non_remap_exposures(c) = sum(lapID(lap).non_remap_exposures);
                thetaSeq_units_properties(t).lapID(lap).non_remap_tracks(c)= sum(lapID(lap).non_remap_tracks);
                thetaSeq_units_properties(t).lapID(lap).remap_tracks(c) = sum(lapID(lap).remap_tracks);
                thetaSeq_units_properties(t).lapID(lap).all_tracks_common(c) = sum(lapID(lap).all_tracks_common);
                
                thetaSeq_units_properties(t).lapID(lap).prop_unique_cells(c)= sum(lapID(lap).unique_cells)/total;
                thetaSeq_units_properties(t).lapID(lap).prop_non_remap_exposures(c) = sum(lapID(lap).non_remap_exposures)/total;
                thetaSeq_units_properties(t).lapID(lap).prop_non_remap_tracks(c)= sum(lapID(lap).non_remap_tracks)/total;
                thetaSeq_units_properties(t).lapID(lap).prop_remap_tracks(c) = sum(lapID(lap).remap_tracks)/total;
                thetaSeq_units_properties(t).lapID(lap).prop_all_tracks_common(c) = sum(lapID(lap).all_tracks_common)/total;
            end
            
            clear lapID
            
        end
        c = c+1;
    end
    
end
save('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\thetaSeq_units_properties.mat','thetaSeq_units_properties','-v7.3')
end

for t = 1 : 2
    for lap = 1 : length(thetaSeq_units_properties(t).lapID)
        if t == 1
            T1_median_prop_unique_cells(lap) = median(thetaSeq_units_properties(t).lapID(lap).prop_unique_cells,'omitnan');
            T1_mean_prop_unique_cells(lap) = mean(thetaSeq_units_properties(t).lapID(lap).prop_unique_cells,'omitnan');
            
            T1_median_prop_all_tracks_common(lap) = median(thetaSeq_units_properties(t).lapID(lap).prop_all_tracks_common,'omitnan');
            T1_mean_prop_all_tracks_common(lap) = mean(thetaSeq_units_properties(t).lapID(lap).prop_all_tracks_common,'omitnan');
            
            T1_median_prop_non_remap_exposures(lap) = median(thetaSeq_units_properties(t).lapID(lap).prop_non_remap_exposures,'omitnan');
            T1_mean_prop_non_remap_exposures(lap) = mean(thetaSeq_units_properties(t).lapID(lap).prop_non_remap_exposures,'omitnan');
            
            T1_median_prop_non_remap_tracks(lap) = median(thetaSeq_units_properties(t).lapID(lap).prop_non_remap_tracks,'omitnan');
            T1_mean_prop_non_remap_tracks(lap) = mean(thetaSeq_units_properties(t).lapID(lap).prop_non_remap_tracks,'omitnan');
            
            T1_median_prop_remap_tracks(lap) = median(thetaSeq_units_properties(t).lapID(lap).prop_remap_tracks,'omitnan');
            T1_mean_prop_remap_tracks(lap) = mean(thetaSeq_units_properties(t).lapID(lap).prop_remap_tracks,'omitnan');
        else
            T2_median_prop_unique_cells(lap) = median(thetaSeq_units_properties(t).lapID(lap).prop_unique_cells,'omitnan');
            T2_mean_prop_unique_cells(lap) = mean(thetaSeq_units_properties(t).lapID(lap).prop_unique_cells,'omitnan');
            
            T2_median_prop_all_tracks_common(lap) = median(thetaSeq_units_properties(t).lapID(lap).prop_all_tracks_common,'omitnan');
            T2_mean_prop_all_tracks_common(lap) = mean(thetaSeq_units_properties(t).lapID(lap).prop_all_tracks_common,'omitnan');
            
            T2_median_prop_non_remap_exposures(lap) = median(thetaSeq_units_properties(t).lapID(lap).prop_non_remap_exposures,'omitnan');
            T2_mean_prop_non_remap_exposures(lap) = mean(thetaSeq_units_properties(t).lapID(lap).prop_non_remap_exposures,'omitnan');
            
            T2_median_prop_non_remap_tracks(lap) = median(thetaSeq_units_properties(t).lapID(lap).prop_non_remap_tracks,'omitnan');
            T2_mean_prop_non_remap_tracks(lap) = mean(thetaSeq_units_properties(t).lapID(lap).prop_non_remap_tracks,'omitnan');
            
            T2_median_prop_remap_tracks(lap) = median(thetaSeq_units_properties(t).lapID(lap).prop_remap_tracks,'omitnan');
            T2_mean_prop_remap_tracks(lap) = mean(thetaSeq_units_properties(t).lapID(lap).prop_remap_tracks,'omitnan');
        end
    end
end
     
figure;
plot(T1_median_prop_all_tracks_common(1:16))
hold on
plot(T1_median_prop_non_remap_exposures(1:16))
plot(T1_median_prop_non_remap_tracks(1:16))
plot(T1_median_prop_remap_tracks(1:16))
plot(T1_median_prop_unique_cells(1:16))

figure;
plot(T1_mean_prop_all_tracks_common(1:16))
hold on
plot(T1_mean_prop_non_remap_exposures(1:16))
plot(T1_mean_prop_non_remap_tracks(1:16))
plot(T1_mean_prop_remap_tracks(1:16))
plot(T1_mean_prop_unique_cells(1:16))

figure;
plot(T2_median_prop_all_tracks_common)
hold on
plot(T2_median_prop_non_remap_exposures)
plot(T2_median_prop_non_remap_tracks)
plot(T2_median_prop_remap_tracks)
plot(T2_median_prop_unique_cells)

figure;
plot(T2_mean_prop_all_tracks_common)
hold on
plot(T2_mean_prop_non_remap_exposures)
plot(T2_mean_prop_non_remap_tracks)
plot(T2_mean_prop_remap_tracks)
plot(T2_mean_prop_unique_cells)

figure;
plot(diff(T1_median_prop_all_tracks_common(1:16)))
hold on
plot(diff(T1_median_prop_non_remap_exposures(1:16)))
plot(diff(T1_median_prop_non_remap_tracks(1:16)))
plot(diff(T1_median_prop_remap_tracks(1:16)))
plot(diff(T1_median_prop_unique_cells(1:16)))



end