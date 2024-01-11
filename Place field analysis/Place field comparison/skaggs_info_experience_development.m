
function skaggs_info_experience_development
% Gets skagg information for each place cell and for each track. Compares
% across exposures and protocols, and then across consecutive laps

% Load name of data folders
sessions = data_folders;
session_names = fieldnames(sessions);

skaggs_track = nan(5000,13);
[skaggs_lap(1:13).track] = deal(nan(5000,16));

for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        
        load extracted_place_fields.mat
        load extracted_lap_place_fields.mat
        
        for t = 1 : length(place_fields.track)
            
            % Extract skagg info from good cells for each track
            cells  = place_fields.track(t).skaggs_info(place_fields.track(t).good_cells);
            if t == 2 % organise such that matrix is T2-1Lap to 8Laps, T1, T4-1 Lap to 8 Laps, and T3
                tc = 6-p;
            elseif t == 4
                tc = 13-p;
            elseif t == 3
                tc = 13;
            else
                tc = 6;
            end
            non_nan = find(isnan(skaggs_track(:,tc)));
            if isempty(non_nan)
                non_nan = 1;
            end
            skaggs_track(non_nan(1):non_nan(1)+length(cells)-1,tc) = cells;
            
            % Extract skagg info from good cells for each lap
            if length(lap_place_fields(t).Complete_Lap) < 16
                num_laps = length(lap_place_fields(t).Complete_Lap);
            else
                num_laps = 16;
            end
            for lap = 1 : num_laps
                cells_lap  = lap_place_fields(t).Complete_Lap{1,lap}.skaggs_info(lap_place_fields(t).Complete_Lap{1,lap}.good_cells);
                non_nan = find(isnan(skaggs_lap(tc).track(:,lap)));
                if isempty(non_nan)
                    non_nan = 1;
                end
                skaggs_lap(tc).track(non_nan(1):non_nan(1)+length(cells_lap)-1,lap) = cells_lap;
            end
        end
    end
end

% Plot track Skagg info per track
pp = plotting_parameters;
cols = [flipud(pp.T2); pp.T1;flipud(pp.T2); pp.T1];
figure
boxplot(skaggs_track,'PlotStyle','traditional','Color',cols,'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
a = get(get(gca,'children'),'children');   % Get the handles of all the objects
tt = get(a,'tag');   % List the names of all the objects
idx = find(strcmpi(tt,'box')==1);  % Find Box objects
boxes =a(idx);
set(boxes,'LineWidth',3); % Set width
box off
idx1 = find(strcmp(tt,'Outliers'));
delete(a(idx1))
idx2 = [find(strcmp(tt,'Upper Whisker')) find(strcmp(tt,'Lower Whisker'))];
set(a(idx2),'LineStyle','-'); % Set width
set(a(idx2),'LineWidth',0.5); % Set width
idx3 = [find(strcmp(tt,'Upper Adjacent Value')) find(strcmp(tt,'Lower Adjacent Value'))];
set(a(idx3),'LineWidth',0.5); % Set width

% hold on
% for ii = 1 : size(skaggs_track,2)
%     h = plot(ii,skaggs_track(:,ii),'o','MarkerEdgeColor',[.6 .6 .6],'MarkerFaceColor','w','MarkerSize',5);
% end
run_format_settings(gcf)
yticks(0:2); ylim([0 2])
xticks([1:6,8:13]); 
ylabel({'Skagg information'})
set(gca,'FontSize',16);

  [p1,tbl,stats] = kruskalwallis([skaggs_track(:,1:6) skaggs_track(:,8:13)]);
     c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons

% figure;
% for j =1 : 6
%     ax(j) =subplot(1,6,j);
%     h1 = raincloud_plot(skaggs_track(:,j), 'box_on', 1, 'color', cols(j,:),'box_col_match', 0);
%     h1{1,1}.EdgeColor ='None';
%     set(h1{1,3},'FaceColor','none')
%     h1{1,2}.SizeData = 5;
% 
%     set(gca,'YLim',[-3.5 3])
%     box off
%     view([-90 90])
%     if j > 1
%         ax(j).XAxis.Visible = 'off';
%     end
% end

%%% PLOT LAP SKAGGS
order = [6:-1:1,12:-1:7];
cols =  [pp.T1;(pp.T2); pp.T1;(pp.T2)];
figure
for k = 1 : length(skaggs_lap)
    if k > 6
        xt = 18:18+15;
    else
        xt = 1: 16;
    end
    mean_lap = mean(skaggs_lap(order(k)).track,1,'omitnan');
    std_lap = std(skaggs_lap(order(k)).track,[],1,'omitnan');
    
    hold on
    plot(xt,mean_lap,'Color',cols(k,:),'LineWidth',3)
    hold on
    plot(xt,mean_lap,'o','MarkerFaceColor',cols(k,:),'MarkerEdgeColor',cols(k,:),'MarkerSize',3)
    if k > 6
        x = 18:18+15;
    else
        mean_lap(isnan(mean_lap)) = [];
        std_lap(isnan(std_lap)) = [];
        x =1: length(mean_lap);
    end

    shade1 = mean_lap + std_lap;
    shade2 = mean_lap - std_lap;
    x2 = [x,fliplr(x)];
    inBetween = [shade1,fliplr(shade2)];
    h=fill(x2,inBetween,cols(k,:));
    set(h,'facealpha',0.1,'LineStyle','none')
    
end
run_format_settings(gcf)
yticks(0:.5:1.5); ylim([0 1.5])
xticks([1:2:16,18:2:33]); xticklabels([1:2:16,1:2:16]);
xlim([0 33]); ylim([0 1.5])
ylabel({'Skagg information'})
set(gca,'FontSize',16);
f=gcf;
f.Color = 'w';
f.Name = 'Skagg info per lap';

for k = 2 : length(skaggs_lap)
    [p,~,stats] = kruskalwallis(skaggs_lap(k).track);
    c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
    find(c(:,6) < .05)
end

end

        
        
        
        
       
       
        