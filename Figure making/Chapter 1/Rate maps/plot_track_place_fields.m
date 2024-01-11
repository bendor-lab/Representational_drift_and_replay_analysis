% Plots ratemaps from 16 to 1 laps for the best and worst rat

function plot_track_place_fields
cd ' X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Cell_count'
axes = Place_fields_examples_makeFigure;
sessions = [{'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day5_16x8'},...
    {'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day4_16x4'},...
    {'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day2_16x3'},...
    {'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day3_16x2'},...
    {'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day7_16x1'},...
    {'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day4_16x8'},...    
    {'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day2_16x4'},...
    {'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day6_16x3'},...
    {'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day5_16x2'},...
    {'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day3_16x1'}];


% Plot track 2 for P-ORA and M-BLU
protocols = [16,4,3,2,1,16,4,3,2,1];
PL = [1:12];
c= 1;
for s = 1 : length(sessions)
    cd(sessions{s})
    load extracted_place_fields.mat
    
    
    matrix=[];
    normalized_matrix=[];
    
    if s == 1 || s == 6 % plot 16 laps
        for k = 1:length(place_fields.track(1).sorted_good_cells)
            matrix(k,:) = place_fields.track(1).smooth{place_fields.track(1).sorted_good_cells(k)};
            normalized_matrix(k,:) = (matrix(k,:)-min(matrix(k,:)))/(max(matrix(k,:))-min(matrix(k,:)));
        end
        
        %y_vector= [y_vector, 1.5*1-1];
        imagesc(axes(PL(c)),normalized_matrix);
        colormap(jet)
        hold on
        ylabel(axes(PL(c)),'Cell ID','FontSize',12);
        yt=place_fields.track(1).sorted_good_cells;
        set(axes(PL(c)),'yticklabel',yt);
        xticks(axes(PL(c)),[20:20:100]);
        set(axes(PL(c)),'xticklabel',40:40:200);
        if s < 6
            title(axes(PL(c)),[num2str(protocols(s)) ' Laps'],'Position',[0.5 1],'FontSize',14);
        else
            xlabel(axes(PL(c)),'Linearized position (cm)','FontSize',12);
            title(axes(PL(c)),'')
        end
        axis(axes(PL(c)),'tight')
        c=c+1;
        
        matrix=[];
        normalized_matrix=[];
        for k = 1:length(place_fields.track(2).sorted_good_cells)
            matrix(k,:) = place_fields.track(2).smooth{place_fields.track(2).sorted_good_cells(k)};
            normalized_matrix(k,:) = (matrix(k,:)-min(matrix(k,:)))/(max(matrix(k,:))-min(matrix(k,:)));
        end
        
        imagesc(axes(PL(c)),normalized_matrix);
        colormap(jet)
        hold on
        yt=place_fields.track(2).sorted_good_cells;
        set(axes(PL(c)),'yticklabel',yt);
        xticks(axes(PL(c)),[20:20:100]);
        set(axes(PL(c)),'xticklabel',40:40:200);
        if s < 6
            title(axes(PL(c)),'8 Laps','Position',[0.5 1],'FontSize',14);
        else
            xlabel(axes(PL(c)),'Linearized position (cm)','FontSize',12);
            title(axes(PL(c)),'')
        end
        axis(axes(PL(c)),'tight')
        c=c+1;
        
    else % plot track 2
        matrix=[];
        normalized_matrix=[];
        for k = 1:length(place_fields.track(2).sorted_good_cells)
            matrix(k,:) = place_fields.track(2).smooth{place_fields.track(2).sorted_good_cells(k)};
            normalized_matrix(k,:) = (matrix(k,:)-min(matrix(k,:)))/(max(matrix(k,:))-min(matrix(k,:)));
        end
        
        imagesc(axes(PL(c)),normalized_matrix);
        colormap(jet)
        hold on
        yt=place_fields.track(2).sorted_good_cells;
        set(axes(PL(c)),'yticklabel',yt);
        xticks(axes(PL(c)),[20:20:100]);
        set(axes(PL(c)),'xticklabel',40:40:200);
        if s < 6
            title(axes(PL(c)),[num2str(protocols(s)) ' Laps'],'Position',[0.5 1],'FontSize',14);
        else
            xlabel(axes(PL(c)),'Linearized position (cm)','FontSize',12);
            title(axes(PL(c)),'')
        end
        axis(axes(PL(c)),'tight')
        c=c+1;
        
    end
    
end
end


