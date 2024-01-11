% Plot correlation across laps at a population level
% Marta Huelin                    
% Compare 4 last laps of first exposure to each lap in second expoure
% INPUT:
    % 'parameter' is a string and defines the information you are analysing and that is a field in singleCell_LAPScorr structure.
                    % Can be centremass_r, peak_r, normcentremass_r
               

function plot_plField_LAPcorr_first_to_second_exposure(parameter)

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\extracted_data'
files = dir('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\extracted_data');
all_16Laps_ReEXP_CtrOfMss = []; % re-exposures to track 1 (16 laps) - aka track4 or track 21
PP = plotting_parameters;
files = flipud(files);%re-organize 
all_sessions_16laps = [];
all_sessions_T4laps = [];
for i = 1: length(files)-3
    if contains(files(i).name,'4lastLaps.mat')
        load(files(i).name)
        clear singleCell_LAPScorr
        lap_CtrOfMss3 = []; lap_CtrOfMss4 = [];
        average_lap_CtrOfMss3 = [];  average_lap_CtrOfMss4 = []; 
        T3_num_cells_lap = [];  T4_num_cells_lap = [];
        p2= 0;
        
        % Find indices of tracks 1 & 2 for a specific type of comparison
        track3 = find(strcmp({cellPopulation_LAPScorr.comparison_type}, 'between_exposures_FULLT1-ends_laps') &  strcmp({cellPopulation_LAPScorr.tracks_compared},'[1 3]')==1); % Track 1 & re-exposure
        track4 = find(strcmp({cellPopulation_LAPScorr.comparison_type}, 'between_exposures_FULLT1-ends_laps') &  strcmp({cellPopulation_LAPScorr.tracks_compared},'[2 4]')==1); % Track 2 & re-exposure
                
        % Extract average centre of mass and number of cells per lap for all the re-exposures (track 3 & 4, aka track11 & track21)
        for j = 1: 16 % comparing to the first 16 laps of the second exposure
            for k = 1 : length(track3)
                if j > length([cellPopulation_LAPScorr(track3(k)).(sprintf('%s',parameter))]) 
                    lap_CtrOfMss3(j,k) = NaN;
                    lap_CtrOfMss4(j,k) = NaN;
                    if p2==0
                        T3_num_cells_lap(j,k) = length(cell2mat(cellPopulation_LAPScorr(track3(k)).pyr_cells_Laps2(1))); % re-exp to track1
                        T4_num_cells_lap(j,k) = length(cell2mat(cellPopulation_LAPScorr(track4(k)).pyr_cells_Laps2(1))); % re-exp to track 2
                        p2=1;
                    else
                        T3_num_cells_lap(j,k) = NaN;
                        T4_num_cells_lap(j,k) = NaN;
                    end
                else % K columns are rats, J rows are correlation values per lap
                    lap_CtrOfMss3(j,k) = cellPopulation_LAPScorr(track3(k)).(sprintf('%s',parameter))(j);
                    lap_CtrOfMss4(j,k) = cellPopulation_LAPScorr(track4(k)).(sprintf('%s',parameter))(j);
                    T3_num_cells_lap(j,k) = length(cell2mat(cellPopulation_LAPScorr(track3(k)).pyr_cells_Laps2(j)));
                    T4_num_cells_lap(j,k) = length(cell2mat(cellPopulation_LAPScorr(track4(k)).pyr_cells_Laps2(j)));
                end
            end
            average_lap_CtrOfMss3(1,j) = mean(lap_CtrOfMss3(j,~isnan(lap_CtrOfMss3(j,:))));
            average_lap_CtrOfMss3(2,j) = std(lap_CtrOfMss3(j,~isnan(lap_CtrOfMss3(j,:))));
            average_lap_CtrOfMss4(1,j) = mean(lap_CtrOfMss4(j,~isnan(lap_CtrOfMss4(j,:))));
            average_lap_CtrOfMss4(2,j) = std(lap_CtrOfMss4(j,~isnan(lap_CtrOfMss4(j,:))));
        end
        all_sessions_T4laps = [all_sessions_T4laps lap_CtrOfMss4];
        
        % Save centres of mass/peak FR  of 16 laps and re-exposure for all types of sessions
        if isempty(all_16Laps_ReEXP_CtrOfMss)
            all_16Laps_ReEXP_CtrOfMss(1,:) = average_lap_CtrOfMss3(1,:);
        else
            all_16Laps_ReEXP_CtrOfMss = cat(1,all_16Laps_ReEXP_CtrOfMss,average_lap_CtrOfMss3(1,:));
        end
        all_sessions_16laps = [all_sessions_16laps lap_CtrOfMss3];

        % Save info for later plotting
        track4_laps = cellPopulation_LAPScorr(track4(1)).protocol(4);
        track4_allProtocols.(sprintf('%s','P16x',track4_laps)) = average_lap_CtrOfMss4;

        
        f=figure('units','normalized','outerposition',[0 0 1 1]);
        if strcmp(parameter,'centremass_r')
            correlation_type = 'Centre of mass ';
        elseif strcmp(parameter,'normcentremass_r')
            correlation_type = 'Normalized centre of mass ';
        else
            correlation_type = 'Peak FR ';
        end
            f.Name = strcat(correlation_type,' correlation at cell population level - 1 Lap Jump - Compare last laps 1st EXP to Re-EXP_',PP.titles.protocols{i});
        ax(1) = subplot(3,2,1);
            x = 1:numel(average_lap_CtrOfMss3(1,:));
            shade1 = sum(average_lap_CtrOfMss3,1);
            shade2 = average_lap_CtrOfMss3(1,:)-average_lap_CtrOfMss3(2,:);
            x2 = [x,fliplr(x)];
            inBetween = [shade1,fliplr(shade2)];
            h=fill(x2,inBetween,[0.8, 0.8, 0.8]);
            set(h,'facealpha',0.2,'LineStyle','none')
            hold on
            plot(average_lap_CtrOfMss3(1,:),'Color',PP.T1,'LineWidth',4)
            plot(average_lap_CtrOfMss3(1,:),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',6)
            title('Re-exposure to 16 laps')
            xlabel('Laps'); ylabel('Average correlation')
            xticks(1:2:16)
            
         ax(2) = subplot(3,2,3);
            plot(lap_CtrOfMss3(:,1),'Color',PP.MBLU,'LineWidth',3) %M-BLU
            hold on
            plot(lap_CtrOfMss3(:,2),'Color',PP.NBLU,'LineWidth',3) % N-BLU
            plot(lap_CtrOfMss3(:,3),'Color',PP.PORA,'LineWidth',3) % P-ORA
            plot(lap_CtrOfMss3(:,4),'Color',PP.QBLU,'LineWidth',3) % Q-BLU
            plot(lap_CtrOfMss3(:,1),'o','MarkerFaceColor',PP.MBLU,'MarkerEdgeColor',PP.MBLU,'MarkerSize',5) %M-BLU
            plot(lap_CtrOfMss3(:,2),'o','MarkerFaceColor',PP.NBLU,'MarkerEdgeColor',PP.NBLU,'MarkerSize',5) % N-BLU
            plot(lap_CtrOfMss3(:,3),'o','MarkerFaceColor',PP.PORA,'MarkerEdgeColor',PP.PORA,'MarkerSize',5) % P-ORA
            plot(lap_CtrOfMss3(:,4),'o','MarkerFaceColor',PP.QBLU,'MarkerEdgeColor',PP.QBLU,'MarkerSize',5) % P-ORA
            xlabel('Laps'); ylabel('Correlation per rat')
            xticks(1:2:16)
       
         ax(3) = subplot(3,2,5);
            b = bar(T3_num_cells_lap);
            b(1).FaceColor = PP.MBLU; b(1).EdgeColor = PP.MBLU; %MBLU
            b(2).FaceColor = PP.NBLU; b(2).EdgeColor = PP.NBLU; %NBLU
            b(3).FaceColor = PP.PORA; b(3).EdgeColor = PP.PORA;%PORA
            b(4).FaceColor = PP.QBLU; b(4).EdgeColor = PP.QBLU;%QBLU
            xlabel('Laps'); ylabel('Number of active place cells')
            xticks(1:16)
            
        if ~isempty(average_lap_CtrOfMss4)
            ax(4) = subplot(3,2,2);
                x3 = 1:numel(average_lap_CtrOfMss4(1,:));
                shade3 = sum(average_lap_CtrOfMss4,1);
                shade4 = average_lap_CtrOfMss4(1,:)-average_lap_CtrOfMss4(2,:);
                x4 = [x3,fliplr(x3)];
                inBetween1 = [shade3,fliplr(shade4)];
                h=fill(x4,inBetween1,[0.8, 0.8, 0.8]);
                set(h,'facealpha',0.2,'LineStyle','none')
                hold on
                plot(average_lap_CtrOfMss4(1,:),'Color',PP.T2(i,:),'LineWidth',3)
                plot(average_lap_CtrOfMss4(1,:),'o','MarkerFaceColor',PP.T2(i,:),'MarkerEdgeColor',PP.T2(i,:),'MarkerSize',6)
                xlabel('Laps'); ylabel('Average correlation')
                xticks(1:2:16)
                title(strcat('Re-exposure to ',num2str(track4_laps),' laps'))
                
            ax(5) = subplot(3,2,4);
                plot(lap_CtrOfMss4(:,1),'Color',PP.MBLU,'LineWidth',3) %M-BLU
                hold on
                plot(lap_CtrOfMss4(:,2),'Color',PP.NBLU,'LineWidth',3) % N-BLU
                plot(lap_CtrOfMss4(:,3),'Color',PP.PORA,'LineWidth',3) % P-ORA
                plot(lap_CtrOfMss4(:,4),'Color',PP.QBLU,'LineWidth',3) % Q-BLU
                plot(lap_CtrOfMss4(:,1),'o','MarkerFaceColor',PP.MBLU,'MarkerEdgeColor',PP.MBLU,'MarkerSize',5) %M-BLU
                plot(lap_CtrOfMss4(:,2),'o','MarkerFaceColor',PP.NBLU,'MarkerEdgeColor',PP.NBLU,'MarkerSize',5) % N-BLU
                plot(lap_CtrOfMss4(:,3),'o','MarkerFaceColor',PP.PORA,'MarkerEdgeColor',PP.PORA,'MarkerSize',5) % P-ORA
                plot(lap_CtrOfMss4(:,4),'o','MarkerFaceColor',PP.QBLU,'MarkerEdgeColor',PP.QBLU,'MarkerSize',5) % P-ORA
                xlabel('Laps'); ylabel('Correlation per rat')
                xticks(1:2:16)

            ax(6) = subplot(3,2,6);
                b1 = bar(T4_num_cells_lap);
                b1(1).FaceColor = PP.MBLU; b1(1).EdgeColor = PP.MBLU; %MBLU
                b1(2).FaceColor = PP.NBLU; b1(2).EdgeColor = PP.NBLU; %NBLU
                b1(3).FaceColor = PP.PORA; b1(3).EdgeColor = PP.PORA;%PORA
                b1(4).FaceColor = PP.QBLU; b1(4).EdgeColor = PP.QBLU;%QBLU
                xlabel('Laps'); ylabel('Number of active place cells')
                xticks(1:16)
                
                linkaxes([ax(1) ax(4)],'y'); linkaxes([ax(2) ax(5)],'y');linkaxes([ax(3) ax(6)],'y');
        end
        linkaxes(ax,'x')
    end 
end

% Calculate average and standard deviation for all the 16 laps sessions
all_RE16Laps_average_CtrOfMss(1,:) = mean(all_16Laps_ReEXP_CtrOfMss,1);
all_RE16Laps_average_CtrOfMss(2,:) = std(all_16Laps_ReEXP_CtrOfMss,1);

% FIGURE - 16 LAPS - correlation lap by lap to last 4 laps (for all sessions and rats together)
f2 = figure('units','normalized','outerposition',[0 0 1 1]);
f2.Name =  strcat(correlation_type,' correlation at cell population level for all RE-16 Laps runs - 1 Lap Jump - Compare last laps 1st EXP to Re-EXP_ALL16Laps');
x = 1:numel(all_RE16Laps_average_CtrOfMss(1,:));
shade1 = sum(all_RE16Laps_average_CtrOfMss,1);
shade2 = all_RE16Laps_average_CtrOfMss(1,:)-all_RE16Laps_average_CtrOfMss(2,:);
x2 = [x,fliplr(x)];
inBetween = [shade1,fliplr(shade2)];
h=fill(x2,inBetween,[0.8 0.8 0.8]);
set(h,'facealpha',0.2,'LineStyle','none')
hold on
plot(all_RE16Laps_average_CtrOfMss(1,:),'Color',PP.T1,'LineWidth',4)
plot(all_RE16Laps_average_CtrOfMss(1,:),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',6)
title('Re-exposure to 16 laps')
xlabel('Laps'); ylabel('Correlation')

% FIGURE - ALL PROTOCOLS - correlation lap by lap to last 4 laps for first and second exposure (for all sessions and rats together)

f3 = figure('units','normalized','outerposition',[0 0 1 1]);
f3.Name =  strcat(correlation_type,' correlation at cell population level for 2nd exposure - 1 Lap Jump - Compare last laps 1st EXP to Re-EXP_ALLprotocols');
x = 1:numel(all_RE16Laps_average_CtrOfMss(1,1:5));
shade1 = all_RE16Laps_average_CtrOfMss(1,1:5) + all_RE16Laps_average_CtrOfMss(2,1:5);
shade2 = all_RE16Laps_average_CtrOfMss(1,1:5) - all_RE16Laps_average_CtrOfMss(2,1:5);
x2 = [x,fliplr(x)];
inBetween = [shade1,fliplr(shade2)];
h=fill(x2,inBetween,PP.T1);
set(h,'facealpha',0.2,'LineStyle','none')
hold on
p1 = plot(all_RE16Laps_average_CtrOfMss(1,1:5),'Color',PP.T1,'LineWidth',4);
hold on
plot(all_RE16Laps_average_CtrOfMss(1,1:5),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',6)
fname = fieldnames(track4_allProtocols);
for ii = 1 : length(fname)
    x = 1:numel(track4_allProtocols.(sprintf('%s',fname{ii}))(1,1:5));
    shade1 = track4_allProtocols.(sprintf('%s',fname{ii}))(1,1:5) + track4_allProtocols.(sprintf('%s',fname{ii}))(2,1:5);
    shade2 = track4_allProtocols.(sprintf('%s',fname{ii}))(1,1:5) - track4_allProtocols.(sprintf('%s',fname{ii}))(2,1:5);
    x2 = [x,fliplr(x)];
    inBetween = [shade1,fliplr(shade2)];
    h=fill(x2,inBetween,PP.T2(ii,:));
    set(h,'facealpha',0.2,'LineStyle','none')
    hold on
    p.(sprintf('%s','P',num2str(ii+10))) = plot(track4_allProtocols.(sprintf('%s',fname{ii}))(1,1:5),'Color',PP.T2(ii,:),'LineWidth',4);
    plot(track4_allProtocols.(sprintf('%s',fname{ii}))(1,1:5),'o','MarkerFaceColor',PP.T2(ii,:),'MarkerEdgeColor',PP.T2(ii,:),'MarkerSize',6)
    
end

xlabel('Laps','FontSize',15); ylabel(strcat(correlation_type,' correlation'),'FontSize',15)
legend([p1(1),p.P11(1),p.P12(1),p.P13(1),p.P14(1),p.P15(1)],{'16 Laps','8 Laps','4 Laps','3 Laps','2 Laps','1 Lap'},'Position',[0.82,0.17,0.05,0.1],'FontSize',15)
title('Similarity between last laps from first exposure and re-exposure')
set(gca,'FontSize',15)
box off
ylim([0 1])

f4 = figure;
f4.Name = 'CenterOfMass_1stLap_ReEXp_compared_to_FULL_1stEXP_ratemap';
temp = nan(20,6);
temp(:,1) = all_sessions_16laps(1,:)';
c =1;
for ii = 1 : length(fieldnames(track4_allProtocols))
    temp(1:4,ii+1) = all_sessions_T4laps(1,c:c+3);
    c = c+4;
end
% temp(:,1) = all_RE16Laps_average_CtrOfMss(1,:)';
% for ii = 1 : length(fieldnames(track4_allProtocols))
%     all_fnames = fieldnames(track4_allProtocols);
%     fname = cell2mat(all_fnames(ii));
%     temp(:,ii+1) = track4_allProtocols.(sprintf('%s',fname))(1,:);
% end
col = [PP.T1; PP.T2(1,:); PP.T2(2,:); PP.T2(3,:); PP.T2(4,:); PP.T2(5,:)]; %set colors
boxplot(temp,'PlotStyle','traditional','Color',col,'LabelOrientation','horizontal','Widths',0.5,'symbol','',...
    'labels',{'R-16','R-8','R-4','R-3','R-2','R-1'});%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',3); % Set width
hold on
for ii = 1 : size(temp,2)
    plot(ii,temp(:,ii),'o','MarkerSize',6,'MarkerEdgeColor',[0.5 0.5 0.5],'MarkerFaceColor',[0.5 0.5 0.5])
end
c = 1;
for ii = 1 : length(all_sessions_16laps(1,:))
    plot(1,all_sessions_16laps(1,c:c+3),'o','MarkerSize',6,'MarkerEdgeColor',col(ii+1,:),'MarkerFaceColor',col(ii+1,:))
    c=c+4;
end

% RUN STATS: KRUSKALL-WALLIS
[pv1,tbl2,stats2]=kruskalwallis(temp,[],'off');
if pv1 < 0.05
    [cc,~,~,~] = multcompare(stats2,'ctype','dunn-sidak','Display','off'); % if anova pval is < 0.05, run multiple comparisons
    sig_diff_idx = find(cc(:,6) <= 0.05);
    if ~isempty(sig_diff_idx)
        maxy = max(ylim);
        miny = min(ylim);
        ylim([miny,maxy+(length(sig_diff_idx)*0.02)])
        % Add sig bars
        rev = [10,11,7,8,9,3,4,5];
        for ii = 1 : length(sig_diff_idx)
            dist = maxy+0.02 + (0.02*(ii-1));
            dist_s = dist + 0.01;
            hold on
            plot([cc(rev(ii),1) cc(rev(ii),2)], [dist dist], '-k', 'LineWidth',0.5)
            plot([(cc(rev(ii),1)+cc(rev(ii),2))/2 (cc(rev(ii),1)+cc(rev(ii),2))/2], [dist_s dist_s], '*k','MarkerSize',1)
            if cc(rev(ii),6) < 0.001
                plot([(cc(rev(ii),1)+cc(rev(ii),2))/2+0.05 (cc(rev(ii),1)+cc(rev(ii),2))/2+0.05], [dist_s dist_s], '*k','MarkerSize',1) 
                plot([(cc(rev(ii),1)+cc(rev(ii),2))/2+0.05 (cc(rev(ii),1)+cc(rev(ii),2))/2-0.05], [dist_s dist_s], '*k','MarkerSize',1)
            elseif cc(rev(ii),6) < 0.01
                plot([(cc(rev(ii),1)+cc(rev(ii),2))/2-0.05 (cc(rev(ii),1)+cc(rev(ii),2))/2-0.05], [dist_s dist_s], '*k','MarkerSize',1)
            end
        end
    end
end
box off
ylim([0 1])
title('First lap of re-exp compared to full rate map first exposure')
ylabel('correlation coefficient')


end