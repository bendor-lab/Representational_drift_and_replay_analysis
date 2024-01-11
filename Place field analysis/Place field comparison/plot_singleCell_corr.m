% Plot single cell correlation between laps
% Marta Huelin
% Loads extracted data for each protocol session and for all rats
% INPUT:
    % 'parameter' is a string and defines the information you are analysing and that is a field in singleCell_LAPScorr structure.
        % Can be norm_centreMass_diff, centreMass_diff, peakFR_diff, meanFR_diff
    % 'comparison_type' is a string that defines which type of comparison is being analysed, and it's a field in singleCell_LAPScorr structure.
        % Can be 'within_track-consecutive_laps','within_track-ends_laps'

function session_data = plot_singleCell_corr(parameter,comparison_type,save_option)

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\extracted_data'
plot_indx = 1;
plot_indx1 = 1;

% Extract information for each protocol (aka, session or 16x1 etc)
if exist(strcat('plotting_data_4lastLaps_',parameter,'.mat') ,'file')
    load(strcat('plotting_data_4lastLaps_',parameter,'.mat'))
else
    session_data = extract_lap_data(parameter,comparison_type,save_option);
end

for t = 1 : length(session_data(1).track_data) % 4 tracks
 
 keep('session_data','t','parameter','plot_indx','plot_indx1','P25_12thLap_16runs','P50_12thLap_16runs','P75_12thLap_16runs','f1','f2','pl','f10','f20','PL2','comparison_type') % clears workspace variables, except for input variables

 if t == 1 || t == 3
        % For track 1 and track3 (aka, re-exposure to 1), merge the data of all sessions
        protocol.allSessions_parameters = [];
        protocol.all_missing_laps = [];
        protocol.missing_lap_indxs = [];
        for s = 1 : length(session_data) %i when merging matrices, correct the number of the indices 
            cell_lap_idx = [];
            laps_indxs = [];
            if ~isempty(session_data(s).track_data(t).all_missing_laps)
                cell_lap_idx(:,1) = session_data(s).track_data(t).all_missing_laps(:,1) + size(protocol.allSessions_parameters,1);
                cell_lap_idx(:,2) = session_data(s).track_data(t).all_missing_laps(:,2);
                laps_indxs(:,1) = cell2mat(session_data(s).track_data(t).missing_lap_indxs(:,1));
                laps_indxs(:,2) = cell2mat(session_data(s).track_data(t).missing_lap_indxs(:,2)) + size(protocol.allSessions_parameters,1) ;
                laps_indxs(:,3) = cell2mat(session_data(s).track_data(t).missing_lap_indxs(:,3)) + size(protocol.allSessions_parameters,1);
            end
            protocol.all_missing_laps = [protocol.all_missing_laps; cell_lap_idx];
            protocol.missing_lap_indxs = [protocol.missing_lap_indxs; laps_indxs];
            protocol.allSessions_parameters = [protocol.allSessions_parameters; session_data(s).track_data(t).(sprintf('%s',parameter))];
        end
        
    elseif t == 2 || t == 4
        % For track 2 and track3 (aka, re-exposure to 2), keep matrices separate as each session is a different amount of experience
        for s = 1 : length(session_data)            
            protocol(s).allSessions_parameters = session_data(s).track_data(t).(sprintf('%s',parameter));
            protocol(s).all_missing_laps = session_data(s).track_data(t).all_missing_laps;
            protocol(s).missing_lap_indxs = cell2mat(session_data(s).track_data(t).missing_lap_indxs);
        end
 end
 
    % Process each centre_mass_diff matrix 
    for p = 1 : length(protocol)
        
        if exist('P25_12thLap_16runs','var')
            keep('session_data','t','parameter','p','protocol','plot_indx','plot_indx1','P25_12thLap_16runs','P50_12thLap_16runs','P75_12thLap_16runs','f1','f2','pl','f10','f20','PL2','comparison_type') % clears workspace variables, except for input variables
        else
            keep('session_data','t','parameter','p','protocol','plot_indx','plot_indx1','f1','f2','pl','f10','f20','PL2','comparison_type') % clears workspace variables, except for input variables
        end
            
        if isempty(protocol(p).allSessions_parameters)
            continue
        end
        
        missing_lap_indxs = protocol(p).missing_lap_indxs;
        all_missing_laps = protocol(p).all_missing_laps;
        allSessions_parameters = protocol(p).allSessions_parameters;
        
        % Delete rows with inactive cells (all zeros rows & all NaNs rows)
        if ~isempty(all_missing_laps)
            for i = 1 : length(unique(missing_lap_indxs(:,1))) % first create struct with missing lap indices for each lap
                this_lap_indices = find(all_missing_laps(:,2) == missing_lap_indxs(i,1));
                missingLaps_idx(i).lap_indx = zeros(size(allSessions_parameters,1),2);
                missingLaps_idx(i).lap_indx(all_missing_laps(this_lap_indices,1),1) = 1;
                missingLaps_idx(i).lap_indx(all_missing_laps(this_lap_indices,1),2) = all_missing_laps(this_lap_indices,2);
            end
        end
        zeros_rows = ~all(allSessions_parameters,2); % find rows with all zeros
        allSessions_parameters(zeros_rows,:) = [];
        
        if ~isempty(all_missing_laps)
            for i = 1 : length(missingLaps_idx)
                missingLaps_idx(i).lap_indx(zeros_rows,:) = []; %correct missing_lap_indices now that some rows have been deleted
            end
        end
        
        nans_rows = all(isnan(allSessions_parameters),2); % find rows with all nans
        allSessions_parameters(nans_rows,:) = [];
        
        if ~isempty(all_missing_laps)
            for i = 1 : length(missingLaps_idx)
                missingLaps_idx(i).lap_indx(nans_rows,:) = []; %correct missing_lap_indices now that some other rows have been deleted
                new_missingLaps_indices(i).lap_indx(:,1) =  find(missingLaps_idx(i).lap_indx == 1);
                new_missingLaps_indices(i).lap_indx(:,2) =  missingLaps_idx(i).lap_indx(find(missingLaps_idx(i).lap_indx == 1),2);
            end
        else
            new_missingLaps_indices = [];
        end
        
        % Calculate mean of each row to use it for sorting
        for i = 1 : size(allSessions_parameters,1)
            mean_parameter_perCell(i) = mean(allSessions_parameters(i,~isnan(allSessions_parameters(i,:))),2);
        end
        max_val = max(max(allSessions_parameters)); %find max value
        min_val = min(min(allSessions_parameters)); %find min value
        
        % Classify cells in low (aka, high values), low-medium, medium & high (aka, low values) similarity to last lap, across laps
        cell_stability_quantification = [];
        cell_stability_percentage = [];
        ratio = [];
        for lap = 1 : size(allSessions_parameters,2)
            num_cells_P25 = length(find(allSessions_parameters(:,lap) < prctile(allSessions_parameters(:),25))); % find number of cells within the 25 perctile of the distribution of all values (e.g. all centre of mass diff values)
            num_cells_P50 = length(find(allSessions_parameters(:,lap) >= prctile(allSessions_parameters(:),25) & allSessions_parameters(:,lap) < prctile(allSessions_parameters(:),50))); %between 25 and 50 perctile
            num_cells_P75 = length(find(allSessions_parameters(:,lap) >= prctile(allSessions_parameters(:),50) & allSessions_parameters(:,lap) < prctile(allSessions_parameters(:),75))); % between 50 and 75 prctile
            num_cells_P100 = length(find(allSessions_parameters(:,lap) >= prctile(allSessions_parameters(:),75))); % above 75 prctile- high values - low stability
            total_cells = num_cells_P25 + num_cells_P50 + num_cells_P75 + num_cells_P100;
            cell_stability_quantification = [cell_stability_quantification; num_cells_P100 num_cells_P75 num_cells_P50 num_cells_P25];
            cell_stability_percentage = [cell_stability_percentage; num_cells_P100/total_cells*100 num_cells_P75/total_cells*100 num_cells_P50/total_cells*100 num_cells_P25/total_cells*100];
            ratio = [ratio; (num_cells_P100/total_cells*100)-(num_cells_P25/total_cells*100)]; %  %unstable - % stable cells
        end
        
        %%%% NORMALIZE DATA TO 12th LAP OF 16 RUNS - ASSUMES THAT AT THAT POINT THERE'S STABILITY
        % Take the 12th last lap of the 16run session and Classify cells in low (aka, high values), low-medium, medium & high (aka, low values) similarity to last lap
        if t==1 % for 16 runs session
            P25_12thLap_16runs = prctile(allSessions_parameters(:,12),25); % find 25 percentile of the distribution of all values in the 12th lap
            P50_12thLap_16runs = prctile(allSessions_parameters(:,12),50); % 50 percentile
            P75_12thLap_16runs = prctile(allSessions_parameters(:,12),75); % 75 percentile 
        end
        norm_cell_stability_quantification = []; %normalize all sessions to the 12th lap of 16 runs
        norm_cell_stability_percentage = [];
        norm_ratio = [];
        for lap = 1 : size(allSessions_parameters,2) 
            norm_num_cells_P25 = length(find(allSessions_parameters(:,lap) < P25_12thLap_16runs)); % find number of cells within the 25 perctile of the distribution of all values (e.g. all centre of mass diff values)
            norm_num_cells_P50 = length(find(allSessions_parameters(:,lap) >= P25_12thLap_16runs & allSessions_parameters(:,lap) < P50_12thLap_16runs)); %between 25 and 50 perctile
            norm_num_cells_P75 = length(find(allSessions_parameters(:,lap) >= P50_12thLap_16runs & allSessions_parameters(:,lap) < P75_12thLap_16runs)); % between 50 and 75 prctile
            norm_num_cells_P100 = length(find(allSessions_parameters(:,lap) >= P75_12thLap_16runs)); % above 75 prctile - high vlaues - low stability
            norm_total_cells = norm_num_cells_P25 + norm_num_cells_P50 + norm_num_cells_P75 + norm_num_cells_P100;
            norm_cell_stability_quantification = [norm_cell_stability_quantification; norm_num_cells_P100 norm_num_cells_P75 norm_num_cells_P50 norm_num_cells_P25];
            norm_cell_stability_percentage = [norm_cell_stability_percentage; norm_num_cells_P100/norm_total_cells*100 norm_num_cells_P75/norm_total_cells*100 norm_num_cells_P50/norm_total_cells*100 norm_num_cells_P25/norm_total_cells*100];
            norm_ratio = [norm_ratio; (norm_num_cells_P100/norm_total_cells*100)-(norm_num_cells_P25/norm_total_cells*100)];
        end
        
        % Sanity check figure - plot distribution
        %figure; histogram(allSessions_parameters) %plot distribution of centre-mass_diff values

        %% Plot amount of cell stability across laps
        f = figure('units','normalized','OuterPosition',[0 0 1 1]);
        
        % Get rid of underscore in the name
        name = parameter;
        if contains(name,'_') 
            name(strfind(name,'_')) = ' ';
        end
        col = copper(4); % set color
        
        ax1 = axes('next','add','Position',[0.05 0.55 0.35 0.4]);
            if size(cell_stability_quantification,1) == 1 % For track 2 - 1 LAP
                b1 = bar(1,cell_stability_quantification(1)); b1.FaceColor = col(4,:);
                b2 = bar(2,cell_stability_quantification(2)); b2.FaceColor = col(3,:);
                b3 = bar(3,cell_stability_quantification(3)); b3.FaceColor = col(2,:);
                b4 = bar(4,cell_stability_quantification(4)); b4.FaceColor = col(1,:);
                xlabel('Laps'); ylabel('Number of place cells')
                title(strcat('Place cell stability across laps - ',name))
            else
                p1= bar(cell_stability_quantification);
                p1(1).FaceColor = col(4,:); p1(1).EdgeColor = col(4,:); %low stability
                p1(2).FaceColor = col(3,:); p1(2).EdgeColor = col(3,:);
                p1(3).FaceColor = col(2,:); p1(3).EdgeColor = col(2,:);
                p1(4).FaceColor = col(1,:); p1(4).EdgeColor = col(1,:); %high stability
                xlabel('Laps'); ylabel('Number of place cells')
                title(strcat('Place cell stability across laps - ',name))
            end
            
        ax2 = axes('next','add','Position',[0.545 0.55 0.33 0.4]);
            p2 = plot(cell_stability_percentage(:,1),'LineWidth',4,'Color',col(4,:),'LineWidth',4);
            hold on
            p3 = plot(cell_stability_percentage(:,2),'LineWidth',4,'Color',col(3,:),'LineWidth',4);
            p4 = plot(cell_stability_percentage(:,3),'LineWidth',4,'Color',col(2,:),'LineWidth',4);
            p5 = plot(cell_stability_percentage(:,4),'LineWidth',4,'Color',col(1,:),'LineWidth',4);
            xlabel('Laps'); ylabel('Proportion of place cells')
            legend([p5 p4 p3 p2],{'<25 Percentile','>25 & <50 Percentile','>50 & <75 Percentile','>75 Percentile'},'Position',[0.915 0.88 0.05 0.05],'FontSize',8,'Orientation','Vertical');
            title(strcat('Place cell stability across laps - ',name))
            xticks(1:1:size(cell_stability_percentage,1))
            if size(cell_stability_percentage,1)>1
                xlim([1 size(cell_stability_percentage,1)])
            end
        
        % Replace NaNs - for visualization purposes, fill with values equivalent to white for 'missing cell activity for this lap' & blue for 'missing lap'
        modified_parameters_matrix = allSessions_parameters;
        if ~isempty(new_missingLaps_indices)
            colormap_bin_size = (max_val - min_val)/62;
            for i = 1 : length(new_missingLaps_indices)
                for j = 1 : size(new_missingLaps_indices(i).lap_indx,1)
                    modified_parameters_matrix(new_missingLaps_indices(i).lap_indx(j,1),new_missingLaps_indices(i).lap_indx(j,2)) = max_val + colormap_bin_size*2; %to set colormap row 64 to gray
                end
            end
            nan_idx = isnan(modified_parameters_matrix);
            modified_parameters_matrix(nan_idx) = max_val + colormap_bin_size; %to set colormap row 63 to white
        else
            nan_idx = isnan(modified_parameters_matrix);
            colormap_bin_size = (max_val - min_val)/63;
            modified_parameters_matrix(nan_idx) = max_val+colormap_bin_size; %to set colormap row 64 to white
        end
        
        
        % Sort matrix by mean centre of mass difference
        [~,sorted_centreMas_indx]=sort(mean_parameter_perCell,'descend');  % sort mean values by descending order
        
        % Plot sorted centre of mass difference per lap for each cell (from more to less estability across laps)
        ax3 = axes('next','add','Position',[0.05 0.08 0.38 0.36]);
            imagesc(modified_parameters_matrix(sorted_centreMas_indx,:))
            modified_pink = colormap(pink);
            if isempty(all_missing_laps)
                modified_pink(64,:)=[1 1 1];
            else
                modified_pink(63,:)=[1 1 1];
                modified_pink(64,:)=[0 0 1];
            end
            colormap(modified_pink);
            xlabel('Laps')
            ylabel('Place cell ID')
            title(strcat('Single cell stability across laps - sorted by mean -',name))
            xticks(1:1:size(modified_parameters_matrix,2))
            axis([0.5 size(modified_parameters_matrix,2)+0.5 1 size(modified_parameters_matrix,1)])

        % Sort each matrix column (each lap) independently for visualization purposes
        lap_sorted_matrix = modified_parameters_matrix;
        for ii = 1 : size(lap_sorted_matrix,2)
            [~,sorted_indx]=sort(lap_sorted_matrix(:,ii),'descend');  % sort mean values by descending order
            lap_sorted_matrix(:,ii) = lap_sorted_matrix(sorted_indx,ii);
        end
        
        ax4 = axes('next','add','Position',[0.52 0.08 0.38 0.36]);
            imagesc(lap_sorted_matrix)
            modified_pink = colormap(pink);
            if isempty(all_missing_laps)
                modified_pink(64,:)=[1 1 1];
            else
                modified_pink(63,:)=[1 1 1];
                modified_pink(64,:)=[0 0 1];
            end
            colormap(modified_pink);
            xlabel('Laps')
            ylabel('Place cells')
            title('Single cell stability across laps - sorted by ascendent similarity within laps')
            xticks(1:1:size(lap_sorted_matrix,2))
            axis([0.5 size(lap_sorted_matrix,2)+0.5 1 size(lap_sorted_matrix,1)])
        
        % Figure title
        if p >= 1 && t == 2
            if p ==5
                p = 8; % since last p is the 8 laps protocol
            end
            annotation('textbox',[0 0.9 1 0.1],'String',strcat('Track ',num2str(t),'-',num2str(p),' Laps exposure'),'EdgeColor', 'none','HorizontalAlignment', 'center');
            filename = strcat('SingleCell_',parameter,'_',comparison_type,'_T2_',num2str(p),'Laps');
            f.Name = filename;
        elseif p >= 1 && t == 4
            if p ==5
                p = 8;
            end
            annotation('textbox',[0 0.9 1 0.1],'String',strcat('Track ',num2str(t),'-',num2str(p),' Laps re-exposure'),'EdgeColor', 'none','HorizontalAlignment', 'center');
            filename = strcat('SingleCell_',parameter,'_',comparison_type,'_T4_',num2str(p),'Laps');
            f.Name = filename;
        elseif t == 1
            annotation('textbox',[0 0.9 1 0.1],'String',strcat('Track ',num2str(t),'- 16 Laps exposure'),'EdgeColor', 'none','HorizontalAlignment', 'center');
            filename = strcat('SingleCell_',parameter,'_',comparison_type,'_T1');
            f.Name = filename;
        else
            annotation('textbox',[0 0.9 1 0.1],'String',strcat('Track ',num2str(t),'- 16 Laps re-exposure'),'EdgeColor', 'none','HorizontalAlignment', 'center');
            filename = strcat('SingleCell_',parameter,'_',comparison_type,'_T3');
            f.Name = filename;
        end
        %save_all_figures(pwd,filename) 
        %close(f)
        
        %% Plot single cell estability of all sessions (normalized to the 12th lap of 16 runs)        
        
        PP = plotting_parameters; % load plotting parameters

        if t == 1
            f1 = figure('units','normalized','OuterPosition',[0 0 1 1]);
            f1.Name = strcat('Single pl cell stability First Exposure- All sessions normalized to 12th lap 16 runs-',parameter);
            num_subplots = 5;
        elseif t == 3
            f10 = figure('units','normalized','OuterPosition',[0 0 1 1]);
            f10.Name = strcat('Single pl cell stability Second Exposure- All sessions normalized to 12th lap 16 runs-',parameter);
            plot_indx = 1;
            num_subplots = 6;
        elseif t == 2
            figure(f1)
            num_subplots = 5;
        elseif t == 4
            figure(f10)
            num_subplots = 6;
        end        
        if ~strcmp(filename,strcat('SingleCell_',parameter,'_',comparison_type,'_T2_1Lap'))
            ax(plot_indx) = subplot(num_subplots,1,plot_indx);
            hold on
            p2 = plot(norm_cell_stability_percentage(:,1),'LineWidth',3,'Color',col(4,:));
            plot(norm_cell_stability_percentage(:,1),'o','MarkerFaceColor',col(4,:),'MarkerEdgeColor',col(4,:),'MarkerSize',4);
            p3 = plot(norm_cell_stability_percentage(:,2),'LineWidth',3,'Color',col(3,:));
            plot(norm_cell_stability_percentage(:,2),'o','MarkerFaceColor',col(3,:),'MarkerEdgeColor',col(3,:),'MarkerSize',4);
            p4 = plot(norm_cell_stability_percentage(:,3),'LineWidth',3,'Color',col(2,:));
            plot(norm_cell_stability_percentage(:,3),'o','MarkerFaceColor',col(2,:),'MarkerEdgeColor',col(2,:),'MarkerSize',4);
            p5 = plot(norm_cell_stability_percentage(:,4),'LineWidth',3,'Color',col(1,:));
            plot(norm_cell_stability_percentage(:,4),'o','MarkerFaceColor',col(1,:),'MarkerEdgeColor',col(1,:),'MarkerSize',4);
            xlabel('Laps'); ylabel('% place cells')
            xticks(1:1:size(norm_cell_stability_percentage,1))
            if size(norm_cell_stability_percentage,1)>1
                xlim([1 size(norm_cell_stability_percentage,1)])
            end
            ylim(ax(plot_indx),[0 60])
            yticks(0:10:60)
            box off;set(gca,'FontSize',10)
            track = strsplit(filename,'T');
            title(strcat('Track', cell2mat(track(2))),'FontSize',12)
            
            if plot_indx == 1
                legend([p5 p4 p3 p2],{'<25 Percentile','>25 & <50 Percentile','>50 & <75 Percentile','>75 Percentile'},'Position',[0.93 0.88 0.05 0.05],'FontSize',8,'Orientation','Vertical');
            end
        end  
        
     %%%%%%%%% FIGURE - high to low stability ratio normalized to 12th lap of 16 runs for each protocol, first and second exposure
        if t == 1
            f2 = figure('units','normalized','OuterPosition',[0 0 1 1]);
            f2.Name = strcat('Single pl cell stability - high to low stability ratio normalized to 12th lap 16 runs-',parameter);
            pl=struct;
        end
        figure(f2)
        if t == 1
            linecolor = PP.T1;
        elseif t ==3; linecolor = PP.T1;
        elseif t == 4 && p == 1 || t == 2 && p == 1; linecolor = PP.T2(5,:); 
        elseif t == 4 && p == 2 || t == 2 && p == 2; linecolor = PP.T2(4,:); 
        elseif t == 4 && p == 3 || t == 2 && p == 3; linecolor = PP.T2(3,:); 
        elseif t == 4 && p == 4 || t == 2 && p == 4; linecolor = PP.T2(2,:); 
        elseif t == 4 && p == 8 || t == 2 && p == 8; linecolor = PP.T2(1,:); 
        end

        hold on
        if t ==1 || t == 2
            plot(norm_ratio,'LineWidth',4,'Color',linecolor);
            plot(norm_ratio,'o','MarkerFaceColor',linecolor,'MarkerEdgeColor',linecolor);
        else
            pl.(sprintf('%s','P',num2str(plot_indx1))) = plot([14:1:14+11],norm_ratio,'LineWidth',4,'Color',linecolor);
            plot([14:1:14+11],norm_ratio,'o','MarkerFaceColor',linecolor,'MarkerEdgeColor',linecolor);
        end
        xlabel('Laps'); ylabel('Low/High similarity ratio')
        xticks(1:1:size(norm_ratio,1)*2+2)
        box off;set(gca,'FontSize',10)
        title('Single pl cell stability - T1 and Re-exposures normalized ratio','FontSize',12)
        if t == 4 && p == 8 % after having plot all the lines
            line([0 25],[0 0],'Color','k','LineStyle','--')
            lne = line([13 13],[min(ylim) max(ylim)],'Color',[0.8 0.8 0.8],'LineWidth',5);
            legend([pl.P7 pl.P8 pl.P9 pl.P10 pl.P11 pl.P6 lne],{'1 Lap','2 Laps','3 Laps','4 Laps','8 Laps','16 Laps','Start Re-Exposure'},'Position',[0.82 0.8 0.07 0.1],'FontSize',9,'Orientation','Vertical');
            annotation('textbox',[0.4,0.8,0.05,0.1],'String','Low similarity','FitBoxToText','on','EdgeColor','none','FontSize',20);
            annotation('textbox',[0.4,0.1,0.05,0.1],'String','High similarity','FitBoxToText','on','EdgeColor','none','FontSize',20);
            yl = ylim;
            ylim([yl(1) yl(2)])
            yticks(yl(1):5:yl(2))
        end
        
    %%%%%%%%%% FIGURE - high to low stability ratio for each protocol, first and second exposure
        if t == 1
            f20 = figure('units','normalized','OuterPosition',[0 0 1 1]);
            f20.Name = strcat('Single pl cell stability - high to low stability ratio - ',parameter);
            PL2=struct;
        end
        figure(f20)
        hold on
        if t ==1 || t == 2
            plot(ratio,'LineWidth',4,'Color',linecolor);
            plot(ratio,'o','MarkerFaceColor',linecolor,'MarkerEdgeColor',linecolor);
        else
            PL2.(sprintf('%s','P',num2str(plot_indx1))) = plot([14:1:14+11],ratio,'LineWidth',4,'Color',linecolor);
            plot([14:1:14+11],ratio,'o','MarkerFaceColor',linecolor,'MarkerEdgeColor',linecolor);
        end
        xlabel('Laps'); ylabel('Low/High similarity ratio')
        xticks(1:1:size(norm_ratio,1)*2+2)
        box off;set(gca,'FontSize',10)
        title('Single pl cell stability - T1 and Re-exposures ratio','FontSize',12)
        if t == 4 && p == 8 % after having plot all the lines                       
            line([0 25],[0 0],'Color','k','LineStyle','--')
            lne = line([13 13],[min(ylim) max(ylim)],'Color',[0.8 0.8 0.8],'LineWidth',5);
            legend([PL2.P7 PL2.P8 PL2.P9 PL2.P10 PL2.P11 PL2.P6 lne],{'1 Lap','2 Laps','3 Laps','4 Laps','8 Laps','16 Laps','Re-Exposure'},'Position',[0.82 0.8 0.07 0.1],'FontSize',9,'Orientation','Vertical');
            annotation('textbox',[0.4,0.8,0.05,0.1],'String','Low similarity','FitBoxToText','on','EdgeColor','none','FontSize',20);
            annotation('textbox',[0.4,0.1,0.05,0.1],'String','High similarity','FitBoxToText','on','EdgeColor','none','FontSize',20);
            yl = ylim;
            ylim([yl(1) yl(2)])
            yticks(yl(1):5:yl(2))
        end
        
        
        plot_indx1 = plot_indx1 + 1;
        plot_indx = plot_indx + 1; % indx of the next subplot
    end
end


end

function session_data = extract_lap_data(parameter,comparison_type,save_option)

files = dir('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\extracted_data');

for i = 3: length(files)
    if contains(files(i).name,'4lastLaps.mat')
        load(files(i).name)
        
        % Find indices of each type of tracks & for a specific type of comparison
        track(1).indices = find(strcmp({cellPopulation_LAPScorr.comparison_type},comparison_type) &  strcmp({cellPopulation_LAPScorr.tracks_compared},'[1 1]')==1); % Track 1 - Ctrl 16 laps
        track(2).indices = find(strcmp({cellPopulation_LAPScorr.comparison_type},comparison_type) &  strcmp({cellPopulation_LAPScorr.tracks_compared},'[2 2]')==1); % Track 2 - 1/2/3/4/8 laps
        track(3).indices = find(strcmp({cellPopulation_LAPScorr.comparison_type},comparison_type) &  strcmp({cellPopulation_LAPScorr.tracks_compared},'[3 3]')==1); % Track 1 re-exposure
        track(4).indices = find(strcmp({cellPopulation_LAPScorr.comparison_type},comparison_type) &  strcmp({cellPopulation_LAPScorr.tracks_compared},'[4 4]')==1); % Track 2 re-exposure
        
        % Find number of laps for each track
        if length(cellPopulation_LAPScorr(track(1).indices(1)).LapsID_1) == 12 % if only using the 12 first laps to compare to the end laps
            track(1).laps = ones(1,length(track(1).indices))*12;
        else
            track(1).laps = ones(1,length(track(1).indices))*15; %from 16 laps (excluding last lap compared to itself)
        end
        if ~isempty(track(2).indices)
            track(2).laps = ones(1,length(track(2).indices))*(str2num(cellPopulation_LAPScorr(track(2).indices(1)).protocol(4))-1); %excluded comparison last lap to itself
        end
        laps_T3 = []; laps_T4 = [];
        for r = 1 : length(track(3).indices)
            laps_T3 = [laps_T3 length(cellPopulation_LAPScorr(track(3).indices(r)).LapsID_1)];
            laps_T4 = [laps_T4 length(cellPopulation_LAPScorr(track(4).indices(r)).LapsID_1)];
        end
        track(3).laps = laps_T3;
        track(4).laps = laps_T4;
        
        %Find cells active on those tracks across all laps
        for t = 1 : length(track)
            for k = 1 : length(track(t).indices)
                active_cells(t).rat{k,:} = unique(cell2mat([cellPopulation_LAPScorr(track(t).indices(k)).pyr_cells_Laps1]));
            end
        end
        
        % Looping through each lap (of each track), save input parameter for each cell active on that track
        
        for t = 1 : length(track) %for each track
            track_allSessions_parameters = []; % all sessions for this type of track run (e.g. all 16 laps runs)
            all_missing_laps = [];
            missing_lap_indxs = [];
            if ~isempty(track(t))
                for k = 1 : length(track(t).indices) % for each session(rat) for this track
                    this_session_parameters = []; % a session for this track run (e.g. 16 laps run of rat1)
                    missingLap_lap_indices = [];
                    missingLap_cell_indices = [];
                    lap_indices = [];
                    num_laps = track(t).laps(k);
                    for j = 1: num_laps
                        if ~isempty(singleCell_LAPScorr(track(t).indices(k)).(sprintf('%s','Laps_',num2str(j)))) %if there's info for this lap
                            for c = 1 : length(cell2mat(active_cells(t).rat(k)))
                                thisLap_active_cells = cell2mat(active_cells(t).rat(k));
                                if any([singleCell_LAPScorr(track(t).indices(k)).(sprintf('%s','Laps_',num2str(j))).cell] == thisLap_active_cells(c)) %if this cell was active in this lap
                                    cell_indx = find([singleCell_LAPScorr(track(t).indices(k)).(sprintf('%s','Laps_',num2str(j))).cell] == thisLap_active_cells(c));
                                    this_session_parameters(thisLap_active_cells(c),j) = abs(singleCell_LAPScorr(track(t).indices(k)).(sprintf('%s','Laps_',num2str(j)))(cell_indx).(sprintf('%s',parameter))); %save info for this cell & this lap
                                else
                                    this_session_parameters(thisLap_active_cells(c),j) = NaN; %if cell not active, NaN
                                end
                            end
                        else
                            this_session_parameters(:,j)= NaN; % if missing this lap, fill with NaN and keep indices
                            missingLap_cell_indices = [missingLap_cell_indices, 1+size(track_allSessions_parameters,1):1:length(this_session_parameters(:,1))+size(track_allSessions_parameters,1)];
                            missingLap_lap_indices = [missingLap_lap_indices; ones(length(1+size(track_allSessions_parameters,1):1:length(this_session_parameters(:,1))+size(track_allSessions_parameters,1)),1)*j];
                            lap_indices = [lap_indices; {j,1+size(track_allSessions_parameters,1),length(this_session_parameters(:,1))+size(track_allSessions_parameters,1)}]; % missing lap indx, start cell indx and end cell indx
                        end
                    end
                    
                    % Merge rat matrix information, correcting the indices for missing laps. If there's different number of laps in each matrix add NaN columns for the empty laps
                    if ~isempty(track_allSessions_parameters) && size(this_session_parameters,2) > size(track_allSessions_parameters,2)
                        size_diff = size(this_session_parameters,2) - size(track_allSessions_parameters,2);
                        for sd = 1 : size_diff
                            missingLap_lap_indices = [missingLap_lap_indices; ones(length(track_allSessions_parameters(:,1)),1)*(sd+size(track_allSessions_parameters,2))];
                            missingLap_cell_indices = [missingLap_cell_indices, 1:1:length(track_allSessions_parameters(:,1))];
                            lap_indices = [lap_indices; {(sd+size(track_allSessions_parameters,2)),1,length(track_allSessions_parameters(:,1))}];
                        end
                        track_allSessions_parameters(:,end+1:end+size_diff) = NaN;
                        track_allSessions_parameters = [track_allSessions_parameters; this_session_parameters];
                    elseif ~isempty(track_allSessions_parameters) && size(this_session_parameters,2) < size(track_allSessions_parameters,2)
                        size_diff =  size(track_allSessions_parameters,2) - size(this_session_parameters,2);
                        for sd = 1 : size_diff
                            missingLap_lap_indices = [missingLap_lap_indices; ones(length(this_session_parameters(:,1)),1)*(sd+size(this_session_parameters,2))];
                            missingLap_cell_indices = [missingLap_cell_indices, 1+size(track_allSessions_parameters,1):1:length(this_session_parameters(:,1))+size(track_allSessions_parameters,1)];
                            lap_indices = [lap_indices; {(sd+size(this_session_parameters,2)),1+size(track_allSessions_parameters,1),length(this_session_parameters(:,1))+size(track_allSessions_parameters,1)}];
                        end
                        this_session_parameters(:,end+1:end+size_diff) = NaN;
                        track_allSessions_parameters = [track_allSessions_parameters; this_session_parameters];
                    else
                        track_allSessions_parameters = [track_allSessions_parameters; this_session_parameters]; %if no need to correct indices and matrix sizes are the same
                        
                    end
                    all_missing_laps = [all_missing_laps; missingLap_cell_indices',missingLap_lap_indices];
                    missing_lap_indxs = [missing_lap_indxs; lap_indices];
                end
                % Save independently for each protocol (16x1, 16x2, etc.)
                session_data(i-2).track_data(t).(sprintf('%s',parameter)) = track_allSessions_parameters;
                session_data(i-2).track_data(t).all_missing_laps = all_missing_laps;
                session_data(i-2).track_data(t).missing_lap_indxs = missing_lap_indxs;
                if ~isempty(track(t).indices(k))
                    session_data(i-2).protocol = cellPopulation_LAPScorr(track(t).indices(k)).protocol;
                end
            end
        end
    end
end

% Checks if there are empty fields in the structure and then deletes them
emptyIndex = find(arrayfun(@(session_data) isempty(session_data.track_data),session_data));
session_data(emptyIndex)= [];

% Save data
if strcmp(save_option,'Y')
    save(strcat('plotting_data_4lastLaps_',parameter),'session_data')
end

end