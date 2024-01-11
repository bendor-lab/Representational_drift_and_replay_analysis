function track_cell_count = count_cells_track(computer,method)

% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
else
    sessions = data_folders;
    session_names = fieldnames(sessions);
end

PP =  plotting_parameters;

i = 1; % session count
idcs = 1;
f1 =  figure('units','normalized','outerposition',[0 0 1 1]);
f1.Name = strcat('Number of place cells all protocols - ', method);

for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        if exist(strcat(pwd,'\extracted_place_fields.mat'),'file')
            load('extracted_place_fields.mat')
            load('extracted_place_fields_BAYESIAN.mat')
            
            for t = 1 : length(place_fields.track)
                % Rows are rats, columns are tracks
                good_cells(i,t) = length(place_fields.track(t).sorted_good_cells);
                bayesian_good_cells(i,t) = length(place_fields_BAYESIAN.track(t).sorted_good_cells);
                
            end             
        end
        i = i +1;
    end
    % Save variables
    track_cell_count(p).good_cells = good_cells(idcs:idcs+3,1:4);
    track_cell_count(p).BAYESIAN_good_cells = bayesian_good_cells(idcs:idcs+3,1:4);
    
    
    %[p1,tb1,stats1] = anova1(good_cells(idcs:idcs+3,1:4));
    %[p2,tb2,stats2] = anova1(bayesian_good_cells(idcs:idcs+3,1:4));

    
    % PLOT CELLS PER TRACK PER PROTOCOL
    name = session_names{p};
    name(strfind(name,'_')) = 'x';
    subplot(3,2,p)
    col = [PP.P(p).colorT(1,:);PP.P(p).colorT(2,:);PP.P(p).colorT(3,:);PP.P(p).colorT(4,:)];
    x_labels = {'T1','T2','R-T1','R-T2'}; %set labels for X axis
    if strcmp(method,'bayesian')
        boxplot(bayesian_good_cells(idcs:idcs+3,1:4),'PlotStyle','traditional','Colors',col,'labels',x_labels,...
            'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
    else
        boxplot(good_cells(idcs:idcs+3,1:4),'PlotStyle','traditional','Colors',col,'labels',x_labels,...
            'LabelOrientation','horizontal','Widths',0.5);%,'BoxStyle','filled'
    end
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([3,4]));  % Get the children you need (boxes for first exposure)
    boxes2 = a(idx([1,2])); % Get the children you need (boxes for second exposure)
    set(boxes,'LineWidth',2); % Set width
    set(boxes2,'LineStyle',':'); % Set line style for re-exposure plots
    set(boxes2,'LineWidth',2); % Set width
    box off
    ylabel('# place cells','FontSize',16)
    title(strcat(name(2:end)),'FontSize',18);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    hold on
    for ii = 1 : 4
        if strcmp(method,'bayesian')
            for jj = 1 : 4
                plot(ii,bayesian_good_cells(idcs+jj-1,ii),'Marker',PP.rat_markers{jj},'MarkerEdgeColor',PP.P(p).colorT(ii,:),...
                  'MarkerFaceColor',PP.P(p).colorT(ii,:),'MarkerSize',PP.rat_markers_size{jj})
            end
        else
            for jj = 1 : 4
                plot(ii,good_cells(idcs+jj-1,ii),'Marker',PP.rat_markers{jj},'MarkerEdgeColor',PP.P(p).colorT(ii,:),...
                  'MarkerFaceColor',PP.P(p).colorT(ii,:),'MarkerSize',PP.rat_markers_size{jj})
            end
        end
    end
    idcs = idcs + 4;

end


% Calculate mean and standard deviation for each track
mean_t = mean(good_cells,1);
std_t = std(good_cells,1);
bayesian_mean_t = mean(bayesian_good_cells,1);
bayesian_std_t = std(bayesian_good_cells,1);

% COMPARISON BETWEEN BAYESIAN AND RAW PLACE FIELDS
for jj = 1 : size(good_cells,2)
  [track_cell_count(jj).ttest(1),track_cell_count(jj).ttest(2),track_cell_count(jj).ttest_stats] =  ttest2(good_cells(:,jj),bayesian_good_cells(:,jj));
end

% PLOT
PP = plotting_parameters;
cols = [PP.P(1).colorT(1,:); [0.6 0.6 0.6]; PP.P(1).colorT(3,:) ; [0.6 0.6 0.6]];
f1 = figure;
f1.Name = 'Fine resolution: Mean number of place cells per track';
for ii = 1 : 4
    hold on
    b(ii) = bar(ii, mean_t(ii),0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
    e = errorbar(ii,mean_t(ii),std_t(ii),'.');
    e.Color = [0 0 0];
    plot(ii,good_cells(:,ii),'o','MarkerEdgeColor','k','MarkerFaceColor','w')
end

% Stats: Anova - Finds if the means of the groups are sig different
[p,tb1,stats] = anova1(good_cells);

figure(f1)
ctr1 = bsxfun(@plus,  b(1).XData, [b(1).XOffset]');
ctr2 = bsxfun(@plus,  b(4).XData, [b(4).XOffset]');
hold on
plot([ctr1 ctr2], [max(ylim)+10 max(ylim)+10], '-k', 'LineWidth',2)
if p < 0.05
    plot(mean(ctr1:ctr2), [(max(ylim)+10)*1.15 (max(ylim)+10)*1.15],'*k')
else
    annotation('textbox',[0.5,0.87,0.05,0.05],'String','NS','EdgeColor','none','FontSize',16)
end
box off
ylabel('Mean number of cells','Fontsize',18)
xticks([1:1:4]); xticklabels({'T1','T2','R-T1','R-T2'});
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',16)

legend([b(1),b(2),b(3),b(4)],{'T1','T2','R-T1','R-T2'});


f2 = figure;
f2.Name = 'Bayesian resolution: Mean number of place cells per track';
for ii = 1 : 4
    hold on
    c(ii) = bar(ii, bayesian_mean_t(ii),0.5,'facecolor',cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
    e = errorbar(ii,bayesian_mean_t(ii),bayesian_std_t(ii),'.');
    e.Color = [0 0 0];
    plot(ii,bayesian_good_cells(:,ii),'o','MarkerEdgeColor','k','MarkerFaceColor','w')
end

% Stats: Anova - Finds if the means of the groups are sig different
[p1,tb2,stats2] = anova1(bayesian_good_cells);
figure(f2)
ctr1 = bsxfun(@plus,  b(1).XData, [b(1).XOffset]');
ctr2 = bsxfun(@plus,  b(4).XData, [b(4).XOffset]');
hold on
plot([ctr1 ctr2], [max(ylim)+10 max(ylim)+10], '-k', 'LineWidth',2)
if p1 < 0.05
    plot(mean(ctr1:ctr2), [(max(ylim)+10)*1.15 (max(ylim)+10)*1.15],'*k')
else
    annotation('textbox',[0.5,0.87,0.05,0.05],'String','NS','EdgeColor','none','FontSize',16)
end
box off
ylabel('Mean number of cells','Fontsize',18)
xticks([1:1:4]); xticklabels({'T1','T2','R-T1','R-T2'});
a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'fontsize',16)

legend([c(1),c(2),c(3),c(4)],{'T1','T2','R-T1','R-T2'});

save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Cell_count',[]);

end 