% Plot correlation across laps at a population level
% Marta Huelin
% INPUT:
    % 'parameter' is a string and defines the information you are analysing and that is a field in singleCell_LAPScorr structure.
                    % Can be centremass_r, peak_r, normcentremass_r
    % 'comparison_type' is a string that defines which type of comparison is being analysed, and it's a field in singleCell_LAPScorr structure.
                    % Can be 'within_track-consecutive_laps','within_track-ends_laps'
% note: in the code, many variables are called CtrOfMass_diff but it also applied to peak FR diff and normcentremass_diff

function plot_plField_LAPcorr(parameter,comparison_type,save_option)

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\extracted_data'
files = dir('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\extracted_data');
all_16Laps_CtrOfMss = [];
all_16Laps_ReEXP_CtrOfMss = []; % re-exposures to track 1 (16 laps) - aka track3 or track 11
PP = plotting_parameters;
files = flipud(files);%re-organize 
all_sessions_16laps = [];
all_sessions_16laps_ReEXP = [];
all_sessions_T4 = [];

for i = 1: length(files)-3
    if contains(files(i).name,'4lastLaps.mat')
        load(files(i).name)
        clear singleCell_LAPScorr
        average_lap_CtrOfMss1 = [];  average_lap_CtrOfMss2 = [];  lap_CtrOfMss1 = []; lap_CtrOfMss3 = [];
        average_lap_CtrOfMss3 = [];  average_lap_CtrOfMss4 = [];  lap_CtrOfMss2 = []; lap_CtrOfMss4 = [];
        T1_num_cells_lap = [];  T2_num_cells_lap = [];
        T3_num_cells_lap = [];  T4_num_cells_lap = [];
        p2= 0;
        % Find indices of tracks 1 & 2 for a specific type of comparison
        track1 = find(strcmp({cellPopulation_LAPScorr.comparison_type},comparison_type) &  strcmp({cellPopulation_LAPScorr.tracks_compared},'[1 1]')==1);
        track2 = find(strcmp({cellPopulation_LAPScorr.comparison_type},comparison_type) &  strcmp({cellPopulation_LAPScorr.tracks_compared},'[2 2]')==1);
        track3 = find(strcmp({cellPopulation_LAPScorr.comparison_type},comparison_type) &  strcmp({cellPopulation_LAPScorr.tracks_compared},'[3 3]')==1);
        track4 = find(strcmp({cellPopulation_LAPScorr.comparison_type},comparison_type) &  strcmp({cellPopulation_LAPScorr.tracks_compared},'[4 4]')==1);
                
        % Extract average centre of mass and number of cells per lap for track 1 (16 laps) and for all the re-exposures (track 3 & 4, aka track11 & track21)
        for j = 1: 12 % for each lap that's been compared to the last 4 laps (16-4=12)
            for k = 1 : length(track1)
                if j > length([cellPopulation_LAPScorr(track1(k)).(sprintf('%s',parameter))]) 
                    lap_CtrOfMss1(j,k) = NaN;
                    lap_CtrOfMss3(j,k) = NaN;
                    lap_CtrOfMss4(j,k) = NaN;
                    if p2==0
                        T1_num_cells_lap(j,k) = length(cell2mat(cellPopulation_LAPScorr(track1(k)).pyr_cells_Laps2(1))); %track 1
                        T3_num_cells_lap(j,k) = length(cell2mat(cellPopulation_LAPScorr(track3(k)).pyr_cells_Laps2(1))); % re-exp to track1
                        T4_num_cells_lap(j,k) = length(cell2mat(cellPopulation_LAPScorr(track4(k)).pyr_cells_Laps2(1))); % re-exp to track 2
                        p2=1;
                    else
                        T1_num_cells_lap(j,k) = NaN;
                        T3_num_cells_lap(j,k) = NaN;
                        T4_num_cells_lap(j,k) = NaN;
                    end
                else % K columns are rats, J rows are correlation values per lap
                    lap_CtrOfMss1(j,k) = cellPopulation_LAPScorr(track1(k)).(sprintf('%s',parameter))(j); %extract correlation parameter for that lap
                    lap_CtrOfMss3(j,k) = cellPopulation_LAPScorr(track3(k)).(sprintf('%s',parameter))(j);
                    lap_CtrOfMss4(j,k) = cellPopulation_LAPScorr(track4(k)).(sprintf('%s',parameter))(j);
                    T1_num_cells_lap(j,k) = length(cell2mat(cellPopulation_LAPScorr(track1(k)).pyr_cells_Laps1(j))); %number of cell in that lap                    
                    T3_num_cells_lap(j,k) = length(cell2mat(cellPopulation_LAPScorr(track3(k)).pyr_cells_Laps1(j)));
                    T4_num_cells_lap(j,k) = length(cell2mat(cellPopulation_LAPScorr(track4(k)).pyr_cells_Laps1(j)));
                    if j == 15
                        T1_num_cells_lap(16,k) = length(cell2mat(cellPopulation_LAPScorr(track1(k)).pyr_cells_Laps2(1))); %adds at the end, number of cells in last lap                       
                        T3_num_cells_lap(16,k) = length(cell2mat(cellPopulation_LAPScorr(track3(k)).pyr_cells_Laps2(1))); %adds at the end, number of cells in last lap
                        T3_num_cells_lap(16,k) = length(cell2mat(cellPopulation_LAPScorr(track4(k)).pyr_cells_Laps2(1)));
                    end
                end
            end
            average_lap_CtrOfMss1(1,j) = mean(lap_CtrOfMss1(j,~isnan(lap_CtrOfMss1(j,:)))); %first row mean
            average_lap_CtrOfMss1(2,j) = std(lap_CtrOfMss1(j,~isnan(lap_CtrOfMss1(j,:)))); % second row standard deviation
            average_lap_CtrOfMss3(1,j) = mean(lap_CtrOfMss3(j,~isnan(lap_CtrOfMss3(j,:))));
            average_lap_CtrOfMss3(2,j) = std(lap_CtrOfMss3(j,~isnan(lap_CtrOfMss3(j,:))));
            average_lap_CtrOfMss4(1,j) = mean(lap_CtrOfMss4(j,~isnan(lap_CtrOfMss4(j,:))));
            average_lap_CtrOfMss4(2,j) = std(lap_CtrOfMss4(j,~isnan(lap_CtrOfMss4(j,:))));
        end
        
        % Save centres of mass/peak FR  of 16 laps and re-exposure for all types of sessions
        if isempty(all_16Laps_CtrOfMss)
            all_16Laps_CtrOfMss(1,:) = average_lap_CtrOfMss1(1,:);
            all_16Laps_ReEXP_CtrOfMss(1,:) = average_lap_CtrOfMss3(1,:);
        else
            all_16Laps_CtrOfMss = cat(1,all_16Laps_CtrOfMss,average_lap_CtrOfMss1(1,:));
            all_16Laps_ReEXP_CtrOfMss = cat(1,all_16Laps_ReEXP_CtrOfMss,average_lap_CtrOfMss3(1,:));
        end
        all_sessions_16laps = [all_sessions_16laps lap_CtrOfMss1];
        all_sessions_16laps_ReEXP = [all_sessions_16laps_ReEXP lap_CtrOfMss3];
        all_sessions_T4 = [all_sessions_T4 lap_CtrOfMss4];
                   
        % Extract average centre of mass/peak FR for track 2 and re-exposures 
        p2=0;
        if ~isempty(track2)
            track2_laps = str2num(cellPopulation_LAPScorr(track2(1)).protocol(4));
            for j = 1 : track2_laps-1
                for k = 1 : length(track1)
                    if j > length([cellPopulation_LAPScorr(track2(k)).centremass_r])
                        lap_CtrOfMss2(j,k) = NaN;
                        if p2==0
                            T2_num_cells_lap(j,k) = length(cell2mat(cellPopulation_LAPScorr(track2(k)).pyr_cells_Laps2(1)));
                            p2=1;
                        else
                            T2_num_cells_lap(j,k) = NaN;
                        end
                    else
                        lap_CtrOfMss2(j,k) = cellPopulation_LAPScorr(track2(k)).(sprintf('%s',parameter))(j);
                        T2_num_cells_lap(j,k) = length(cell2mat(cellPopulation_LAPScorr(track2(k)).pyr_cells_Laps1(j)));
                        if j == track2_laps-1
                            T2_num_cells_lap(track2_laps,k) = length(cell2mat(cellPopulation_LAPScorr(track2(k)).pyr_cells_Laps2(1))); %adds at the end, number of cells in last lap
                        end
                    end
                end
                average_lap_CtrOfMss2(1,j) = mean(lap_CtrOfMss2(j,~isnan(lap_CtrOfMss2(j,:))));
                average_lap_CtrOfMss2(2,j) = std(lap_CtrOfMss2(j,~isnan(lap_CtrOfMss2(j,:))));
            end
        end
        
        % Save info for later plotting
        track4_laps = cellPopulation_LAPScorr(track4(1)).protocol(4);
        track2_allProtocols.(sprintf('%s','P16x',num2str(track2_laps))) = average_lap_CtrOfMss2;
        track2_allProtocols.(sprintf('%s','ALL_P16x',num2str(track2_laps))) = lap_CtrOfMss2;
        track4_allProtocols.(sprintf('%s','P16x',num2str(track4_laps))) = average_lap_CtrOfMss4;
        track4_allProtocols.(sprintf('%s','ALL_P16x',num2str(track4_laps))) = all_sessions_T4;

        f=figure('units','normalized','outerposition',[0 0 1 1]);
        if strcmp(parameter,'centremass_r')
            correlation_type = 'Centre of mass ';
        elseif strcmp(parameter,'normcentremass_r')
            correlation_type = 'Normalized centre of mass ';
        else
            correlation_type = 'Peak FR ';
        end
            f.Name = strcat(correlation_type,' correlation at cell population level - 1 Lap Jump -',comparison_type,'-',PP.titles.protocols{i});
        ax(1) = subplot(3,2,1);
            x = 1:numel(average_lap_CtrOfMss1(1,:));
            shade1 = sum(average_lap_CtrOfMss1,1);
            shade2 = average_lap_CtrOfMss1(1,:)-average_lap_CtrOfMss1(2,:);
            x2 = [x,fliplr(x)];
            inBetween = [shade1,fliplr(shade2)];
            h=fill(x2,inBetween,[0.8, 0.8, 0.8]);
            set(h,'facealpha',0.2,'LineStyle','none')
            hold on
            plot(average_lap_CtrOfMss1(1,:),'Color',PP.T1,'LineWidth',4)
            plot(average_lap_CtrOfMss1(1,:),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',6)
            title('16 laps')
            xlabel('Laps'); ylabel('Average correlation')
            xticks(1:2:16)
            
         ax(2) = subplot(3,2,3);
            plot(lap_CtrOfMss1(:,1),'Color',PP.MBLU,'LineWidth',3) %M-BLU
            hold on
            plot(lap_CtrOfMss1(:,2),'Color',PP.NBLU,'LineWidth',3) % N-BLU
            plot(lap_CtrOfMss1(:,3),'Color',PP.PORA,'LineWidth',3) % P-ORA
            plot(lap_CtrOfMss1(:,4),'Color',PP.QBLU,'LineWidth',3) % Q-BLU
            plot(lap_CtrOfMss1(:,1),'o','MarkerFaceColor',PP.MBLU,'MarkerEdgeColor',PP.MBLU,'MarkerSize',5) %M-BLU
            plot(lap_CtrOfMss1(:,2),'o','MarkerFaceColor',PP.NBLU,'MarkerEdgeColor',PP.NBLU,'MarkerSize',5) % N-BLU
            plot(lap_CtrOfMss1(:,3),'o','MarkerFaceColor',PP.PORA,'MarkerEdgeColor',PP.PORA,'MarkerSize',5) % P-ORA
            plot(lap_CtrOfMss1(:,4),'o','MarkerFaceColor',PP.QBLU,'MarkerEdgeColor',PP.QBLU,'MarkerSize',5) % P-ORA
            xlabel('Laps'); ylabel('Correlation per rat')
            xticks(1:2:16)
       
         ax(3) = subplot(3,2,5);
            b = bar(T1_num_cells_lap);
            b(1).FaceColor = PP.MBLU; b(1).EdgeColor = PP.MBLU; %MBLU
            b(2).FaceColor = PP.NBLU; b(2).EdgeColor = PP.NBLU; %NBLU
            b(3).FaceColor = PP.PORA; b(3).EdgeColor = PP.PORA;%PORA
            b(4).FaceColor = PP.QBLU; b(4).EdgeColor = PP.QBLU;%QBLU
            xlabel('Laps'); ylabel('Number of active place cells')
            xticks(1:16)
            
        if ~isempty(average_lap_CtrOfMss2)
            ax(4) = subplot(3,2,2);
                x3 = 1:numel(average_lap_CtrOfMss2(1,:));
                shade3 = sum(average_lap_CtrOfMss2,1);
                shade4 = average_lap_CtrOfMss2(1,:)-average_lap_CtrOfMss2(2,:);
                x4 = [x3,fliplr(x3)];
                inBetween1 = [shade3,fliplr(shade4)];
                h=fill(x4,inBetween1,[0.8, 0.8, 0.8]);
                set(h,'facealpha',0.2,'LineStyle','none')
                hold on
                plot(average_lap_CtrOfMss2(1,:),'Color',PP.T2(i,:),'LineWidth',3)
                plot(average_lap_CtrOfMss2(1,:),'o','MarkerFaceColor',PP.T2(i,:),'MarkerEdgeColor',PP.T2(i,:),'MarkerSize',6)
                xlabel('Laps'); ylabel('Average correlation')
                xticks(1:2:track2_laps)
                title(strcat(num2str(track2_laps),' laps'))
                
            ax(5) = subplot(3,2,4);
                plot(lap_CtrOfMss2(:,1),'Color',PP.MBLU,'LineWidth',3) %M-BLU
                hold on
                plot(lap_CtrOfMss2(:,2),'Color',PP.NBLU,'LineWidth',3) % N-BLU
                plot(lap_CtrOfMss2(:,3),'Color',PP.PORA,'LineWidth',3) % P-ORA
                plot(lap_CtrOfMss2(:,4),'Color',PP.QBLU,'LineWidth',3) % Q-BLU
                plot(lap_CtrOfMss2(:,1),'o','MarkerFaceColor',PP.MBLU,'MarkerEdgeColor',PP.MBLU,'MarkerSize',5) %M-BLU
                plot(lap_CtrOfMss2(:,2),'o','MarkerFaceColor',PP.NBLU,'MarkerEdgeColor',PP.NBLU,'MarkerSize',5) % N-BLU
                plot(lap_CtrOfMss2(:,3),'o','MarkerFaceColor',PP.PORA,'MarkerEdgeColor',PP.PORA,'MarkerSize',5) % P-ORA
                plot(lap_CtrOfMss2(:,4),'o','MarkerFaceColor',PP.QBLU,'MarkerEdgeColor',PP.QBLU,'MarkerSize',5) % P-ORA
                xlabel('Laps'); ylabel('Correlation per rat')
                xticks(1:2:track2_laps)

            ax(6) = subplot(3,2,6);
                b1 = bar(T2_num_cells_lap);
                b1(1).FaceColor = PP.MBLU; b1(1).EdgeColor = PP.MBLU; %MBLU
                b1(2).FaceColor = PP.NBLU; b1(2).EdgeColor = PP.NBLU; %NBLU
                b1(3).FaceColor = PP.PORA; b1(3).EdgeColor = PP.PORA;%PORA
                b1(4).FaceColor = PP.QBLU; b1(4).EdgeColor = PP.QBLU;%QBLU
                xlabel('Laps'); ylabel('Number of active place cells')
                xticks(1:track2_laps)
                
                linkaxes([ax(1) ax(4)],'y'); linkaxes([ax(2) ax(5)],'y');linkaxes([ax(3) ax(6)],'y');
        end
        linkaxes(ax,'x')
    end 
end

% Calculate average and standard deviation for all the 16 laps sessions
%all_16Laps_average_CtrOfMss(1,:) = mean(all_16Laps_CtrOfMss,1);
%all_16Laps_average_CtrOfMss(2,:) = std(all_16Laps_CtrOfMss,1);
all_16Laps_average_CtrOfMss(1,:) = mean(all_sessions_16laps,2);
all_16Laps_average_CtrOfMss(2,:) = std(all_sessions_16laps,[],2);
all_16Laps_average_CtrOfMss_ReEXP(1,:) = mean(all_sessions_16laps_ReEXP,2);
all_16Laps_average_CtrOfMss_ReEXP(2,:) = std(all_sessions_16laps_ReEXP,[],2);

%%% KRUSKAL WALLIS
%p= arrayfun(@(x) ranksum(all_sessions_16laps(x,:),all_sessions_16laps(x+1,:)),1:size(all_sessions_16laps)-1)
[p,tbl,stats] = kruskalwallis(all_sessions_16laps');
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
sig_idx = find(c(:,6)<0.05);

[p,tbl,stats] = kruskalwallis(all_sessions_16laps_ReEXP');
c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
sig_idx = find(c(:,6)<0.05);

ptt = [8,4,3,2,1];
for ii = 1 : length(ptt)
    [p,tbl,stats] = kruskalwallis(track4_allProtocols.(strcat('ALL_P16x',num2str(ptt(ii))))');
    c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
    sig_idx = find(c(:,6)<0.05);
end
for ii = 1 : length(ptt)
    [p,tbl,stats] = kruskalwallis(track2_allProtocols.(strcat('ALL_P16x',num2str(ptt(ii))))');
    c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
    sig_idx = find(c(:,6)<0.05);
end

% FIGURE - 16 LAPS - correlation lap by lap to last 4 laps (for all sessions and rats together)
f2 = figure('units','normalized','outerposition',[0 0 1 1]);
f2.Name =  strcat(correlation_type,' correlation at cell population level for all 16 Laps runs - 1 Lap Jump -',comparison_type,'_ALL16Laps');
test(1,1:12) = all_16Laps_average_CtrOfMss(1,1:12);
test(2,1:12) = all_16Laps_average_CtrOfMss(2,1:12);
x = 1:numel(test(1,:));
shade1 = test(1,:)+test(2,:);
shade2 = test(1,:)-test(2,:);
x2 = [x,fliplr(x)];
inBetween = [shade1,fliplr(shade2)];
h=fill(x2,inBetween,[0.8 0.8 0.8]);
set(h,'facealpha',0.2,'LineStyle','none')
hold on
plot(test(1,:),'Color',PP.T1,'LineWidth',4)
plot(test(1,:),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',6)
title('16 laps')
xlabel('Laps'); ylabel('Correlation')

% FIGURE - ALL PROTOCOLS - correlation lap by lap to last 4 laps for first and second exposure (for all sessions and rats together)

f3 = figure('units','normalized','outerposition',[0 0 1 1]);
f3.Name =  strcat(correlation_type,' correlation at cell population level for 1st&2nd exposure - 1 Lap Jump - ',comparison_type,'_ALLprotocols');

test(1,1:12) = all_16Laps_average_CtrOfMss(1,1:12);
test(2,1:12) = all_16Laps_average_CtrOfMss(2,1:12);
x = 1:numel(test(1,:));
shade1 = test(1,:)+test(2,:);
shade2 = test(1,:)-test(2,:);
x2 = [x,fliplr(x)];
inBetween = [shade1,fliplr(shade2)];
h=fill(x2,inBetween,[0.8 0.8 0.8]);
set(h,'facealpha',0.2,'LineStyle','none')
hold on
p1 = plot(test(1,:),'Color',PP.T1,'LineWidth',4);
hold on
plot(test(1,:),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',5)
% Re-exposure
test2(1,1:12) = all_16Laps_average_CtrOfMss_ReEXP(1,1:12);
test2(2,1:12) = all_16Laps_average_CtrOfMss_ReEXP(2,1:12);
x = 14:13+numel(test2(1,:));
shade1 = test2(1,:)+test2(2,:);
shade2 = test2(1,:)-test2(2,:);
x2 = [x,fliplr(x)];
inBetween = [shade1,fliplr(shade2)];
h=fill(x2,inBetween,[0.8 0.8 0.8]);
set(h,'facealpha',0.2,'LineStyle','none')
hold on
plot(14:1:14+11,test2(1,:),'Color',PP.T1,'LineWidth',4);
plot(14:1:14+11,test2(1,:),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',5)

for ii = 1 : length(fieldnames(track2_allProtocols))
    all_fnames = fieldnames(track2_allProtocols);
    fname = cell2mat(all_fnames(ii));
    if ~isempty(track2_allProtocols.(sprintf('%s',fname)))
        temp1(1,:) = track2_allProtocols.(sprintf('%s',fname))(1,:);
        temp1(2,:) = track2_allProtocols.(sprintf('%s',fname))(2,:);
        x = 1:numel(temp1(1,:));
        shade1 = temp1(1,:)+ temp1(2,:);
        shade2 = temp1(1,:)- temp1(2,:);
        x2 = [x,fliplr(x)];
        inBetween = [shade1,fliplr(shade2)];
        h=fill(x2,inBetween,PP.T2(ii,:));
        set(h,'facealpha',0.04,'LineStyle','none')
        hold on
        p.(sprintf('%s','P',num2str(ii+3))) = plot(temp1(1,:),'Color',PP.T2(ii,:),'LineWidth',4);
        plot(temp1(1,:),'o','MarkerFaceColor',PP.T2(ii,:),'MarkerEdgeColor',PP.T2(ii,:),'MarkerSize',5)
    end
    temp2(1,1:12) = track4_allProtocols.(sprintf('%s',fname))(1,1:12);
    temp2(2,1:12) = track4_allProtocols.(sprintf('%s',fname))(2,1:12);
    x = 14:13+numel(temp2(1,:));
    shade1 = temp2(1,:)+ temp2(2,:);
    shade2 = temp2(1,:)- temp2(2,:);
    x2 = [x,fliplr(x)];
    inBetween = [shade1,fliplr(shade2)];
    h=fill(x2,inBetween,PP.T2(ii,:));
    set(h,'facealpha',0.04,'LineStyle','none')
    hold on
    p.(sprintf('%s','P',num2str(ii+10))) = plot([14:1:14+11],temp2(1,:),'Color',PP.T2(ii,:),'LineWidth',4);
    plot([14:1:14+11],temp2(1,:),'o','MarkerFaceColor',PP.T2(ii,:),'MarkerEdgeColor',PP.T2(ii,:),'MarkerSize',5)
    clear temp1 temp2
end
hold on

p2 = line([13 13],[min(ylim) max(ylim)],'LineWidth',5,'Color',[0.8 0.8 0.8],'LineStyle','-'); % Division from first to second exposure
xlabel('Laps','FontSize',15); ylabel(strcat(correlation_type,' correlation'),'FontSize',15)
xticks(0:2:26)
legend([p1(1),p.P11(1),p.P12(1),p.P13(1),p.P14(1),p.P15(1),p2(1)],{'16 Laps','8 Laps','4 Laps','3 Laps','2 Laps','1 Lap','Re-exposure'},'Position',[0.82,0.17,0.05,0.1],'FontSize',15)
annotation('textbox',[0.25,0.87,0.05,0.1],'String','First exposure','FitBoxToText','on','EdgeColor','none','FontSize',17);
annotation('textbox',[0.65,0.87,0.05,0.1],'String','Second exposure','FitBoxToText','on','EdgeColor','none','FontSize',17);
set(gca,'FontSize',15)
box off

% Save data
cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr')
if strcmp(save_option,'Y')
    save(strcat('plotting_LAPSCORR_4lastLaps_',parameter),'track4_allProtocols','track2_allProtocols','all_16Laps_ReEXP_CtrOfMss','all_16Laps_average_CtrOfMss')
end


end