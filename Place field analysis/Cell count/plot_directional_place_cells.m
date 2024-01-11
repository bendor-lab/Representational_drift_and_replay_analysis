function plot_directional_place_cells

% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
else
    sessions = data_folders;
    session_names = fieldnames(sessions);
end

c = 1;
[track_lap_cells(1:4).unidirect] = deal(nan(20,16));
[track_lap_cells(1:4).non_unidirect] = deal(nan(20,16));

for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        
        % Extract undirectional cells for each track
        this_sess = extract_unidirectional_place_cells;
        
        [unidirect(1:size(this_sess,2),c)]= deal(cell2mat(arrayfun(@(x) length(this_sess(x).dir1_unidirectional_cells) + length(this_sess(x).dir2_unidirectional_cells) + length(this_sess(x).unidirectional_multi_peak),...
            1:size(this_sess,2),'UniformOutput',0)));
        [NON_unidirect(1:size(this_sess,2),c)]= deal(cell2mat(arrayfun(@(x) length(this_sess(x).bidirectional_cells),1:size(this_sess,2),'UniformOutput',0)));
        [unidirect_ID(1:size(this_sess,2),c)]= deal(arrayfun(@(x) unique([this_sess(x).dir1_unidirectional_cells this_sess(x).dir2_unidirectional_cells this_sess(x).unidirectional_multi_peak]),1:size(this_sess,2),'UniformOutput',0));
        [NON_unidirect_ID(1:size(this_sess,2),c)]= deal(arrayfun(@(x) unique([this_sess(x).bidirectional_cells]),1:size(this_sess,2),'UniformOutput',0));

        % Extract unidirectional cells per lap
         load('extracted_directional_lap_place_fields.mat')
        for t = 1 : length(lap_directional_place_fields)
            ct = 1;
            temp_uni_dir1 = NaN(100,ceil(length(lap_directional_place_fields(t).dir1.half_Lap)/2));
            temp_uni_dir2 = NaN(100,ceil(length(lap_directional_place_fields(t).dir1.half_Lap)/2));
            temp_nonuni_dir1 = NaN(100,ceil(length(lap_directional_place_fields(t).dir1.half_Lap)/2));
            temp_nonuni_dir2 = NaN(100,ceil(length(lap_directional_place_fields(t).dir1.half_Lap)/2));
            for lp = 1 :2: length(lap_directional_place_fields(t).dir1.half_Lap)
                
                if lp > size(track_lap_cells(1).unidirect,2)*2
                    break
                end
                dir1 = lap_directional_place_fields(t).dir1.half_Lap{1,lp};
                if length(lap_directional_place_fields(t).dir2.half_Lap) >= lp+1 % if there are two half laps for this lap
                    dir2 = lap_directional_place_fields(t).dir2.half_Lap{1,lp+1};
                    
                    % Find directional and bidirectional cells
                    [unidirect_cells,non_unidirect_cells] = lap_directional_place_cells(dir1,dir2);         
                    track_lap_cells(t).unidirect(c,ct) = unidirect_cells.num;
                    track_lap_cells(t).unidirect_IDs{c,ct} = unidirect_cells.IDs;
                    track_lap_cells(t).non_unidirect(c,ct) = non_unidirect_cells.num;
                    track_lap_cells(t).non_unidirect_IDs{c,ct} = non_unidirect_cells.IDs;
                    
                    % Check that a classified unidirectional cell won't be
                    % a bidirectional cell at the end of running
                    cell_idx = intersect(track_lap_cells(t).unidirect_IDs{c,ct},NON_unidirect_ID{t,c});
                    
                    % track_lap_cells_2(t).unidirect(c,ct) = length(find(ismember(track_lap_cells(t).unidirect_IDs{c,ct},unidirect_ID{t,c})));
                    % track_lap_cells_2(t).non_unidirect(c,ct) = length(find(ismember(track_lap_cells(t).non_unidirect_IDs{c,ct},NON_unidirect_ID{t,c})));
                    track_lap_cells_2(t).unidirect(c,ct) = length(find(~ismember(track_lap_cells(t).unidirect_IDs{c,ct},cell_idx)));
                    track_lap_cells_2(t).non_unidirect(c,ct) = length([track_lap_cells(t).non_unidirect_IDs{c,ct} cell_idx]);
                    track_lap_cells_2(t).unidirect_ID{c,ct} = track_lap_cells(t).unidirect_IDs{c,ct}(~ismember(track_lap_cells(t).unidirect_IDs{c,ct},cell_idx));
                    track_lap_cells_2(t).non_unidirect_ID{c,ct} = sort([track_lap_cells(t).non_unidirect_IDs{c,ct} cell_idx]);
                    
                    % Calculate "directionality index", as the difference in number of spikes fired in each running
                    % direction divided by the total spikes in both directions in that lap.
                    % From Navratilova et al. 2012, Frontiers in Neural Circuits
                    total_lap_spikes = cell2mat(arrayfun(@(x) sum([sum([dir1.spike_hist{1,x}]) sum([dir2.spike_hist{1,x}])]), track_lap_cells_2(t).unidirect_ID{c,ct},'UniformOutput',0)); %sum of both directions
                    dir1_lap_spikes = cell2mat(arrayfun(@(x) sum([dir1.spike_hist{1,x}]), track_lap_cells_2(t).unidirect_ID{c,ct},'UniformOutput',0));
                    dir2_lap_spikes = cell2mat(arrayfun(@(x) sum([dir2.spike_hist{1,x}]), track_lap_cells_2(t).unidirect_ID{c,ct},'UniformOutput',0));
                    track_lap_cells_2(t).unidirect_Directionality_Index{c,ct} = (dir1_lap_spikes-dir2_lap_spikes)./total_lap_spikes;
                    
                    temp_uni_dir1(track_lap_cells_2(t).unidirect_ID{c,ct},ct) = dir1_lap_spikes; %fill number of spikes to the corresponding cell indx 
                    temp_uni_dir2(track_lap_cells_2(t).unidirect_ID{c,ct},ct) = dir2_lap_spikes;

                    clear total_lap_spikes dir1_lap_spikes dir2_lap_spikes
                    total_lap_spikes = cell2mat(arrayfun(@(x) sum([sum([dir1.spike_hist{1,x}]) sum([dir2.spike_hist{1,x}])]), track_lap_cells_2(t).non_unidirect_ID{c,ct},'UniformOutput',0));
                    dir1_lap_spikes = cell2mat(arrayfun(@(x) sum([dir1.spike_hist{1,x}]), track_lap_cells_2(t).non_unidirect_ID{c,ct},'UniformOutput',0));
                    dir2_lap_spikes = cell2mat(arrayfun(@(x) sum([dir2.spike_hist{1,x}]), track_lap_cells_2(t).non_unidirect_ID{c,ct},'UniformOutput',0));
                    track_lap_cells_2(t).non_unidirect_Directionality_Index{c,ct} = (dir1_lap_spikes-dir2_lap_spikes)./total_lap_spikes;                    
                    
                    temp_nonuni_dir1(track_lap_cells_2(t).non_unidirect_ID{c,ct},ct) = dir1_lap_spikes;
                    temp_nonuni_dir2(track_lap_cells_2(t).non_unidirect_ID{c,ct},ct) = dir2_lap_spikes;
                    clear total_lap_spikes dir1_lap_spikes dir2_lap_spikes
                    ct = ct+1;
                else
                    ct = ct+1;
                    continue %if it's only half a lap
                end

            end
            [max_dir_FR,max_dir_uni] = max([max(temp_uni_dir1,[],2) max(temp_uni_dir2,[],2)]);
        end
        
      c=c+1;  
    end 
end

% BAR PLOT PER TRACK
prop_unidirect = unidirect./(unidirect+NON_unidirect);
prop_NONunidirect = NON_unidirect./(unidirect+NON_unidirect);


all_tracks = []; %number of cells
all_tracks = [all_tracks mean(unidirect(2,17:20)) mean(NON_unidirect(2,17:20)); mean(unidirect(2,13:16)) mean(NON_unidirect(2,13:16));mean(unidirect(2,9:12)) mean(NON_unidirect(2,9:12));...
    mean(unidirect(2,5:8)) mean(NON_unidirect(2,5:8)); mean(unidirect(2,1:4)) mean(NON_unidirect(2,1:4)); mean(unidirect(1,:)) mean(NON_unidirect(1,:));NaN NaN;...
    mean(unidirect(4,17:20)) mean(NON_unidirect(4,17:20)); mean(unidirect(4,13:16)) mean(NON_unidirect(4,13:16));mean(unidirect(4,9:12)) mean(NON_unidirect(4,9:12));...
    mean(unidirect(4,5:8)) mean(NON_unidirect(4,5:8)); mean(unidirect(4,1:4)) mean(NON_unidirect(4,1:4));mean(unidirect(3,:)) mean(NON_unidirect(3,:))];

all_tracks2 = []; %proportion of cells
all_tracks2 = [all_tracks2 mean(prop_unidirect(2,17:20)) mean(prop_NONunidirect(2,17:20)); mean(prop_unidirect(2,13:16)) mean(prop_NONunidirect(2,13:16));mean(prop_unidirect(2,9:12)) mean(prop_NONunidirect(2,9:12));...
    mean(prop_unidirect(2,5:8)) mean(prop_NONunidirect(2,5:8)); mean(prop_unidirect(2,1:4)) mean(prop_NONunidirect(2,1:4)); mean(prop_unidirect(1,:)) mean(prop_NONunidirect(1,:));NaN NaN;...
    mean(prop_unidirect(4,17:20)) mean(prop_NONunidirect(4,17:20)); mean(prop_unidirect(4,13:16)) mean(prop_NONunidirect(4,13:16));mean(prop_unidirect(4,9:12)) mean(prop_NONunidirect(4,9:12));...
    mean(prop_unidirect(4,5:8)) mean(prop_NONunidirect(4,5:8)); mean(prop_unidirect(4,1:4)) mean(prop_NONunidirect(4,1:4));mean(prop_unidirect(3,:)) mean(prop_NONunidirect(3,:))];


% Compare tracks 1st and 2nd exp separately for each UNI and BID cells
% separately
data = [{prop_unidirect},{prop_NONunidirect}];
tr = {[1,2],[3,4]};
for i = 1 : 2
    curr_data = data{i}; 
    for j = 1 : 2       
        mat = nan(20,6);
        mat(:,1) = curr_data(tr{j}(1),:);
        mat(1:4,2) = curr_data(tr{j}(2),1:4);
        mat(1:4,3) = curr_data(tr{j}(2),5:8);
        mat(1:4,4) = curr_data(tr{j}(2),9:12);
        mat(1:4,5) = curr_data(tr{j}(2),13:16);
        mat(1:4,6) = curr_data(tr{j}(2),17:20);
        [pval{i,j},~,stats] = kruskalwallis(mat,[]);
        c = multcompare(stats);
        sig_id = [c((c(:,6)<.05),1) c((c(:,6)<.05),2)];
    end
end
mean_unidir_first = mean(all_tracks2(1:6,1));
std_unidir_first = std(all_tracks2(1:6,1));
mean_unidir_first = mean(all_tracks2(8:12,1));
std_unidir_first = std(all_tracks2(8:12,1));

pp = plotting_parameters;
f1 = figure('units','normalized','Color','w');
b = bar(all_tracks2,'stacked');
b(1).FaceColor = 'flat';
b(1).CData = [flipud(pp.T2); pp.T1;[NaN NaN NaN];flipud(pp.T2); pp.T1];
b(2).FaceColor = 'flat';
b(2).CData = [flipud(pp.T2); pp.T1;[NaN NaN NaN];flipud(pp.T2); pp.T1];
b(2).FaceAlpha = 0.4;
b(1).EdgeColor = 'w';
b(2).EdgeColor = 'w';
run_format_settings(gcf)
set(gca,'XTick',[1:6,8:13],'XTickLabel',[],'YTick',[0,0.5,1],'YLim',[0 1])
ylabel('Proportion place cells')

yyaxis right
plot(all_tracks(:,1),'k','LineWidth',2)
hold on
plot(all_tracks(:,2),'k','LineWidth',2,'LineStyle','--')
set(gca,'YColor',[0.4 .4 .4])
ylabel('Number of place cells','Rotation',-90,'Color',[0.4 .4 .4])
yh = get(gca,'ylabel'); % handle to the label object
p = get(yh,'position'); % get the current position property
p(1) = p(1)+.5;        % double the distance, 
                       % negative values put the label below the axis
set(yh,'position',p);
box off


% Plot lap unidirectional cells
% for t = 1 : length(track_lap_cells)
%     track_lap_cells(t).prop_unidirect = track_lap_cells(t).unidirect ./(track_lap_cells(t).unidirect+track_lap_cells(t).non_unidirect);
%     track_lap_cells(t).prop_NONunidirect = track_lap_cells(t).non_unidirect ./(track_lap_cells(t).unidirect+track_lap_cells(t).non_unidirect);
% end
% 
% mat_mean = nan(16,12);
% mat_std = nan(16,12);
% mat_mean(:,1) = mean(track_lap_cells(1).prop_unidirect,1,'omitnan');
% mat_std(:,1) = std(track_lap_cells(1).prop_unidirect,[],1,'omitnan');
% c = 1;
% for p = 1 : 5
%     mat_mean(:,p+1) = mean(track_lap_cells(2).prop_unidirect(c:c+3,:),1,'omitnan');
%     mat_std(:,p+1) = std(track_lap_cells(2).prop_unidirect(c:c+3,:),[],1,'omitnan');
%     c=c+4;
% end
% mat_mean(:,7) = mean(track_lap_cells(3).prop_unidirect,1,'omitnan');
% mat_std(:,7) = std(track_lap_cells(3).prop_unidirect,[],1,'omitnan');
% c = 1;
% for p = 1 : 5
%     mat_mean(:,p+7) = mean(track_lap_cells(4).prop_unidirect(c:c+3,:),1,'omitnan');
%     mat_std(:,p+7) = std(track_lap_cells(4).prop_unidirect(c:c+3,:),[],1,'omitnan');
%     c=c+4;
% end

%%%%%%%%
for t = 1 : length(track_lap_cells_2)
    track_lap_cells_2(t).prop_unidirect = track_lap_cells_2(t).unidirect ./(track_lap_cells_2(t).unidirect+track_lap_cells_2(t).non_unidirect);
    track_lap_cells_2(t).prop_NONunidirect = track_lap_cells_2(t).non_unidirect ./(track_lap_cells_2(t).unidirect+track_lap_cells_2(t).non_unidirect);
end

mat_mean = nan(16,12);
mat_std = nan(16,12);
mat_mean(:,1) = mean(track_lap_cells_2(1).prop_unidirect,1,'omitnan');
mat_std(:,1) = std(track_lap_cells_2(1).prop_unidirect,[],1,'omitnan');
c = 1;
for p = 1 : 5
    mat_mean(1:length(track_lap_cells_2(2).prop_unidirect(c:c+3,:)),p+1) = mean(track_lap_cells_2(2).prop_unidirect(c:c+3,:),1,'omitnan');
    mat_std(1:length(track_lap_cells_2(2).prop_unidirect(c:c+3,:)),p+1) = std(track_lap_cells_2(2).prop_unidirect(c:c+3,:),[],1,'omitnan');
    c=c+4;
end
mat_mean(:,7) = mean(track_lap_cells_2(3).prop_unidirect,1,'omitnan');
mat_std(:,7) = std(track_lap_cells_2(3).prop_unidirect,[],1,'omitnan');
c = 1;
for p = 1 : 5
    mat_mean(:,p+7) = mean(track_lap_cells_2(4).prop_unidirect(c:c+3,:),1,'omitnan');
    mat_std(:,p+7) = std(track_lap_cells_2(4).prop_unidirect(c:c+3,:),[],1,'omitnan');
    c=c+4;
end
% Compare tracks first exp
[pval,~,stats] = kruskalwallis(mat_mean(:,1:6),[],'off');
c = multcompare(stats);
sig_id = [c((c(:,6)<.05),1) c((c(:,6)<.05),2)];

% Compare tracks Second exp
[pval,~,stats] = kruskalwallis(mat_mean(:,7:12),[]);
c = multcompare(stats,[],'off');
sig_id = [c((c(:,6)<.05),1) c((c(:,6)<.05),2)];

f2 = figure('units','normalized','Color','w');
clr = [pp.T1;pp.T2;pp.T1;pp.T2];
for k = 1 : size(mat_mean,2)
    if k > 6
        xt = 18:18+15;
    else
        xt = 1: 16;
    end
    
    plot(xt,mat_mean(:,k),'Color',clr(k,:),'LineWidth',2)    
    hold on    
    plot(xt,mat_mean(:,k),'o','MarkerFaceColor',clr(k,:),'MarkerEdgeColor',clr(k,:),'MarkerSize',3)
    if k > 6
        x = 18:18+15;
    else
        x =1: length(mat_mean(~isnan(mat_mean(:,k)),k));
    end
    
    shade1 = (mat_mean(~isnan(mat_mean(:,k)),k) + mat_std(~isnan(mat_std(:,k)),k));
    shade2 = (mat_mean(~isnan(mat_mean(:,k)),k) - mat_std(~isnan(mat_std(:,k)),k));
    x2 = [x,fliplr(x)];
    inBetween = [shade1',fliplr(shade2')];
    h=fill(x2,inBetween,clr(k,:));
    set(h,'facealpha',0.2,'LineStyle','none')
end
run_format_settings(gcf)
set(gca,'XTick',[2:2:36],'XTickLabel',{'2','4','6','8','10','12','14','16','','2','4','6','8','10','12','14','16'},...
    'YTick',[0,0.5,1],'YLim',[0 1])
xlabel('Laps'); ylabel('Proportion of unidirectional cells')

% Check lap by lap for each track
data = {'prop_unidirect','non_unidirect','unidirect'};
for j = 1 : 3
    [pval,~,stats] = kruskalwallis(track_lap_cells_2(1).(strcat(data{j})),[]);
    c = 1;
    for p = 1 : 5
        [pval,~,stats] = kruskalwallis(track_lap_cells_2(2).(strcat(data{j}))(c:c+3,:),[]);
        c=c+4;
    end
    [pval,~,stats] = kruskalwallis(track_lap_cells_2(3).(strcat(data{j})),[]);
    c = 1;
    for p = 1 : 5
        [pval,~,stats] = kruskalwallis(track_lap_cells_2(4).(strcat(data{j}))(c:c+3,:),[]);
        c=c+4;
    end
end

[p,~,stats] = signrank(track_lap_cells_2(1).unidirect(:,1),track_lap_cells_2(1).unidirect(:,16))

%%% Plot number of unidirectional place cells
mat_mean = nan(16,12);
mat_std = nan(16,12);
mat_mean(:,1) = mean(track_lap_cells_2(1).unidirect,1,'omitnan');
mat_std(:,1) = std(track_lap_cells_2(1).unidirect,[],1,'omitnan');
c = 1;
for p = 1 : 5
    mat_mean(1:length(track_lap_cells_2(2).unidirect(c:c+3,:)),p+1) = mean(track_lap_cells_2(2).unidirect(c:c+3,:),1,'omitnan');
    mat_std(1:length(track_lap_cells_2(2).unidirect(c:c+3,:)),p+1) = std(track_lap_cells_2(2).unidirect(c:c+3,:),[],1,'omitnan');
    c=c+4;
end
mat_mean(:,7) = mean(track_lap_cells_2(3).unidirect,1,'omitnan');
mat_std(:,7) = std(track_lap_cells_2(3).unidirect,[],1,'omitnan');
c = 1;
for p = 1 : 5
    mat_mean(:,p+7) = mean(track_lap_cells_2(4).unidirect(c:c+3,:),1,'omitnan');
    mat_std(:,p+7) = std(track_lap_cells_2(4).unidirect(c:c+3,:),[],1,'omitnan');
    c=c+4;
end
mat_mean(mat_mean == 0) = NaN;
mat_std(mat_std == 0) = NaN;

f3 = figure('units','normalized','Color','w');
clr = [pp.T1;pp.T2;pp.T1;pp.T2];
for k = 1 : size(mat_mean,2)
    if k > 6
        xt = 18:18+15;
    else
        xt = 1: 16;
    end
    
    plot(xt,mat_mean(:,k),'Color',clr(k,:),'LineWidth',2)    
    hold on    
    plot(xt,mat_mean(:,k),'o','MarkerFaceColor',clr(k,:),'MarkerEdgeColor',clr(k,:),'MarkerSize',3)
    if k > 6
        x = 18:18+15;
    else
        x =1: length(mat_mean(~isnan(mat_mean(:,k)),k));
    end
    
    shade1 = (mat_mean(~isnan(mat_mean(:,k)),k) + mat_std(~isnan(mat_std(:,k)),k));
    shade2 = (mat_mean(~isnan(mat_mean(:,k)),k) - mat_std(~isnan(mat_std(:,k)),k));
    x2 = [x,fliplr(x)];
    inBetween = [shade1',fliplr(shade2')];
    h=fill(x2,inBetween,clr(k,:));
    set(h,'facealpha',0.2,'LineStyle','none')
end
run_format_settings(gcf)
set(gca,'XTick',[2:2:36],'XTickLabel',{'2','4','6','8','10','12','14','16','','2','4','6','8','10','12','14','16'},...
    'YTick',0:20:80)
xlabel('Laps'); ylabel('Number of unidirectional cells')

% Compare tracks first exp
[pval,~,stats] = kruskalwallis(mat_mean(:,1:6),[],'off');
c = multcompare(stats);
sig_id = [c((c(:,6)<.05),1) c((c(:,6)<.05),2)];

% Compare tracks Second exp
[pval,~,stats] = kruskalwallis(mat_mean(:,7:12),[],'off');
c = multcompare(stats);
sig_id = [c((c(:,6)<.05),1) c((c(:,6)<.05),2)];



end



function [unidirect,bidirect] = lap_directional_place_cells(dir1, dir2)

    % Find unidirectional cells
    dir1_unidirectional_cells = setdiff(dir1.good_cells,dir2.good_cells); % cells only in direction 1
    dir2_unidirectional_cells = setdiff(dir2.good_cells,dir1.good_cells); % cells only in direction 2


    % cells that appear in both directions
    common_cells = intersect(dir1.good_cells,dir2.good_cells);
    unidirectional_multi_peak = [];
    bidirectional_cells = [];
    for j = 1 : length(common_cells)
        centre_mass_diff = dir1.centre(common_cells(j)) - dir2.centre(common_cells(j));
        R_overlap = corr(dir1.smooth{common_cells(j)}',dir2.smooth{common_cells(j)}');
        if abs(centre_mass_diff) <= 30 & abs(R_overlap) > .14
            bidirectional_cells = [bidirectional_cells, common_cells(j)]; %if place fields overlap
        else
            unidirectional_multi_peak = [unidirectional_multi_peak, common_cells(j)];
        end
    end
    
    unidirect.num = length(unique([dir1_unidirectional_cells dir2_unidirectional_cells unidirectional_multi_peak]));
    bidirect.num = length(bidirectional_cells);
    unidirect.IDs = unique([dir1_unidirectional_cells dir2_unidirectional_cells unidirectional_multi_peak]);
    bidirect.IDs = bidirectional_cells;
end