% PLOT DECODING ERROR ACROSS LAPS
% Uses information extracted with 'bayesian_decoding_error_exposures.mat' to plot median decoding error for each exposure(compared to same track other exposure or to another track's exposure).
% Plots for each rat, for each protocol, and a figure with all protocols overlapped (showing both first and second exposure). Also plots
% a figure with the median of all the medians. 
% MH_20.2020


function plot_track_decodingError_between_exposures(save_option)

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\extracted_data'
files = dir('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\extracted_data');
files = flipud(files);

PP = plotting_parameters;

% Track comparisons analysed in 'bayesian_decoding_error_exposures.mat'
comparisons = {[1,3],[3,1],[2,4],[4,2],[1,2],[2,1],[3,4],[4,3],[1,4],[3,2],[2,3],[4,1]}; % first number is decoded track, second is template track

for t = 1 : length(files)-2 % for each protocol
    if contains(files(t).name,'Between')
        load(files(t).name)
    
        for c = 1 : length(comparisons) % for each comparison analysed
            prot(t).comp(c).comparison = comparisons{c};
            for r = 1 : size(betweenExposures_DecodingError,2) %for each rat     
                %for each different type of decoding template used for this comparison - templates sorted by whole session, first half and second half
                for temp = 1 : size([betweenExposures_DecodingError(r).comparison(c).template],2)
                    prot(t).comp(c).template(r,temp) = betweenExposures_DecodingError(r).comparison(c).template(temp).decoding_error.median_trackDecodingError; %each column a template used for this comparison, each row a rats value
                    %prot(t).comp(c).template{r,temp} = betweenExposures_DecodingError(r).comparison(c).template(temp).decoding_error.medianError_perLap; %each column a template used for this comparison, each row a rats value
                end
            end
        end
    end
end
% Check if there are empty fields and delete
prot = prot(find(~cellfun(@isempty,{prot.comp})));

% STATS
mat1 = [];
mat2 = [];
for t = 1 : size(prot,2) % for each protocol
    mat1= [mat1 prot(t).comp(2).template{r,1}(1:15)];
    mat2= [mat2 prot(t).comp(10).template{r,1}(1:15)];
end
[p,h,stats] = signrank(mat1,mat2)

for t = 1 : size(prot,2) % for each protocol
    mat1 = [];
    mat2 = [];
    mat1= [mat1 prot(t).comp(4).template{r,1}(1:16)];
    mat2= [mat2 prot(t).comp(12).template{r,1}(1:16)];
end
[p,h,stats] = signrank(mat1,mat2)


%%%%%% FIGURE - MEDIAN DECODING ERROR FOR EACH COMPARISON AND FOR EACH TEMPLATE USED - EACH SUBPLOT A PROTOCOL
      
    for t = 1 : size(prot,2) % for each protocol
        
        if mod(t,2) %if t is even start new figure, to have 2 subplots max per figure
            f(t) = figure('units','normalized','outerposition',[0 0 1 1]);
            f(t).Name = strcat('Median decoding error using same track or different track exposure for each template - ',num2str(t));
            sub = 1;
        end
        
        subplot(2,1,sub)
            
        % Restructure data in matrix for plotting
        all_data_matrix = []; groups = [];
        for ii = 1 : size(prot(t).comp,2)-4
            all_data_matrix = [all_data_matrix; reshape(prot(t).comp(ii).template,[size(prot(t).comp(ii).template,1)*size(prot(t).comp(ii).template,2),1])];
            groups = [groups; repmat({strcat('W-',num2str(comparisons{ii}))},size(prot(t).comp(ii).template,1),1)];
            if size(prot(t).comp(ii).template,2)>1
                groups = [groups; repmat({strcat('1H-',num2str(comparisons{ii}))},size(prot(t).comp(ii).template,1),1)];
                groups = [groups; repmat({strcat('2H-',num2str(comparisons{ii}))},size(prot(t).comp(ii).template,1),1)];
            end
        end
        
        % PLOT
        col = [PP.T1; PP.T1; PP.T1; PP.T1;PP.T1; PP.T1; PP.T2(t,:);PP.T2(t,:);PP.T2(t,:);PP.T2(t,:);[0.3 0.3 0.3];[0.3 0.3 0.3];[0.3 0.3 0.3];[0.3 0.3 0.3];...
            [0.6 0.6 0.6];[0.6 0.6 0.6];[0.6 0.6 0.6];[0.6 0.6 0.6];[0.6 0.6 0.6];[0.6 0.6 0.6]]; %set colors
        x_labels = {'W','1H','2H','W','1H','2H','W','1H','2H','W','W','W','1H','2H','W','1H','2H','W','1H','2H'}; %set labels for X axis
        boxplot(all_data_matrix,groups,'PlotStyle','traditional','BoxStyle','filled','Colors',col,'labels',x_labels,...
            'LabelOrientation','horizontal','Widths',0.5);
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        tt = get(a,'tag');   % List the names of all the objects
        idx = find(strcmpi(tt,'box')==1);  % Find Box objects
        boxes = a(idx([4,5,6,10,12,13,14,18,19,20]));  % Get the children you need (boxes for first exposure)
        boxes2 = a(idx([1,2,3,7,8,9,11,15,16,17])); % Get the children you need (boxes for second exposure)
        set(boxes,'LineWidth',10); % Set width
        set(boxes2,'LineStyle',':'); % Set line style for re-exposure plots
        set(boxes2,'LineWidth',7); % Set width
        box off
        ylabel('Median decoding error','FontSize',16); yticks(0:10:max(ylim));
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'fontsize',16)
        %xlabel('Comparisons','FontSize',12);
        title(strcat('Protocol - ',PP.titles.protocols{t}),'FontSize',16)
        h = findobj(gca,'Tag','Box');
        %plot([min(xlim) max(xlim)],[10 10],'k') % line marking 5% of track length
        legend([h(20),h(17),h(14),h(11),h(10),h(9),h(6),h(3)],{'T1 <-- T1-R','T1-R <-- T1', 'T2 <-- T2-R','T2-R <-- T2', 'T1 <-- T2', 'T2 <-- T1', 'T1-R <-- T2-R','T2-R <-- T1-R'},'FontSize',12,'Position',[0.93 0.85 0.05 0.05],'box','off');
        
        sub = sub+1;  % next subplot              
    end

%%%%%% FIGURE - MEDIAN DECODING ERROR FOR EACH COMPARISON 

    T1_matrix = []; T3_matrix = [];
    T2_matrix = []; T4_matrix = [];
    groupsT2 = []; groupsT4 = [];
    groupsT1 = []; groupsT3 = [];
    for t = 1 : size(prot,2) % for each protocol
            T1_matrix = [T1_matrix; prot(t).comp(1).template(:,1); prot(t).comp(9).template(:,1)]; %1-3 / 1-4
            groupsT1 = [groupsT1;  repmat({'16 Laps'},size(prot(t).comp(1).template,1),1);repmat({'16 Laps -Ctrl'},size(prot(t).comp(9).template,1),1)];
            T3_matrix = [T3_matrix; prot(t).comp(2).template(:,1); prot(t).comp(10).template(:,1)]; %3-1 / 3-2
            groupsT3 = [groupsT3;  repmat({'16 Laps'},size(prot(t).comp(2).template,1),1); repmat({'16 Laps -Ctrl'},size(prot(t).comp(10).template,1),1)];
            T2_matrix = [T2_matrix; prot(t).comp(3).template(:,1); prot(t).comp(11).template(:,1)]; %2-4 / 2-3 (Before 2-1)
            groupsT2 =  [groupsT2; repmat(PP.titles.protocols(t),size(prot(t).comp(3).template,1),1); repmat({strcat(PP.titles.protocols{t},'-Ctrl')},size(prot(t).comp(11).template,1),1)];
            T4_matrix = [T4_matrix; prot(t).comp(4).template(:,1); prot(t).comp(12).template(:,1)]; %4-2 / 4-1 (before 4-3)
            groupsT4 =  [groupsT4; repmat(PP.titles.protocols(t),size(prot(t).comp(4).template,1),1); repmat({strcat(PP.titles.protocols{t},'-Ctrl')},size(prot(t).comp(12).template,1),1)];
    end
    first_exposure = [T1_matrix; T2_matrix];
    %groups1 = [repmat({'16 Laps'},size(T1_matrix,1),1); groupsT2];
    groups1 = [groupsT1; groupsT2];
    second_exposure = [T3_matrix; T4_matrix];
    %groups2 = [repmat({'16 Laps'},size(T1_matrix,1),1); groupsT4];
    groups2 = [groupsT3; groupsT4];
    % Color per group
    col = [[0.6 0.6 0.6];PP.T2(1,:);[0.6 0.6 0.6]; PP.T2(2,:);[0.6 0.6 0.6]; PP.T2(3,:);[0.6 0.6 0.6]; PP.T2(4,:);[0.6 0.6 0.6]; PP.T2(5,:);[0.6 0.6 0.6]]; %set colors
    cols = [repmat(PP.T1,size(T1_matrix,1),1)];
    for i = 1 : length(col)
        cols = [cols; repmat(col(i,:),4,1)];
    end

    % Run Kruskal-Wallis
    sig_diff_idx = [];
    [pv,tbl1,stats1]=kruskalwallis(first_exposure,groups1,'off');
    if pv < 0.05
        [c,~,~,~] = multcompare(stats1,'ctype','dunn-sidak','Display','off'); % if anova pval is < 0.05, run multiple comparisons
        sig_diff_idx = find(c(:,6) <= 0.05);
    end
    
 

    % Run Kruskal-Wallis
    sig_diff_idx1 = [];
    [pv1,tbl2,stats2]=kruskalwallis(second_exposure,groups2,'off');
    if pv1 < 0.05
        [cc,~,~,~] = multcompare(stats2,'ctype','dunn-sidak','Display','off'); % if anova pval is < 0.05, run multiple comparisons
        sig_diff_idx1 = find(cc(:,6) <= 0.05);
    end
    
        
    f2 = figure('units','normalized','outerposition',[0 0 1 1]);
    f2.Name = strcat('Median decoding error using same track other exposure');
    
    subplot(2,1,1)
      % PLOT
        col = [PP.T1;[0.6 0.6 0.6]; PP.T2(1,:);[0.6 0.6 0.6]; PP.T2(2,:);[0.6 0.6 0.6]; PP.T2(3,:);[0.6 0.6 0.6]; PP.T2(4,:);[0.6 0.6 0.6]; PP.T2(5,:);[0.6 0.6 0.6]]; %set colors
        boxplot(first_exposure,groups1,'PlotStyle','compact','BoxStyle','filled','Colors',col,'LabelOrientation','horizontal','Widths',0.5,'symbol','');
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        tt = get(a,'tag');   % List the names of all the objects
        idx = strcmpi(tt,'box');  % Find Box objects
        boxes = a(idx);  % Get the children you need (boxes for first exposure)
        set(boxes,'LineWidth',25); % Set width
        box off
        ylabel('Median decoding error','FontSize',16);  yticks(0:10:max(ylim));
        %xlabel('Comparisons','FontSize',12);
        title('First exposure decoded from second exposure','FontSize',18)
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'fontsize',16)
        h = findobj(gca,'Tag','Box');
        %legend([h(11),h(10),h(8),h(6),h(4),h(2)],{'16Laps','8 Laps', '4 Laps', '3 Laps', '2 Laps', '1 Lap'},'FontSize',12,'Position',[0.92 0.71 0.05 0.2]);  
        hold on
        all_groups = unique(groups1,'stable');
        for g = 1 : length(all_groups)
            if mod(g,2) == 1
                plot(g,first_exposure(strcmp(groups1,all_groups{g})),'o','MarkerEdgeColor',[0.6 0.6 0.6],'MarkerSize',6)
            elseif mod(g,2) == 0
                plot(g,first_exposure(strcmp(groups1,all_groups{g})),'o','MarkerEdgeColor',[0.2 0.2 0.2],'MarkerSize',6)
            end
        end
        
   subplot(2,1,2)
        col = [PP.T1;[0.6 0.6 0.6]; PP.T2(1,:);[0.6 0.6 0.6]; PP.T2(2,:);[0.6 0.6 0.6]; PP.T2(3,:);[0.6 0.6 0.6]; PP.T2(4,:);[0.6 0.6 0.6]; PP.T2(5,:);[0.6 0.6 0.6]]; %set colors
        boxplot(second_exposure,groups2,'PlotStyle','compact','BoxStyle','filled','Colors',col,'LabelOrientation','horizontal','Widths',0.5,'symbol','');
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        tt = get(a,'tag');   % List the names of all the objects
        idx = strcmpi(tt,'box');  % Find Box objects
        boxes = a(idx);  % Get the children you need (boxes for first exposure)
        set(boxes,'LineWidth',25); % Set width
        %set(boxes,'LineStyle',':'); % Set line style for re-exposure plots
        box off
        ylabel('Median decoding error','FontSize',16);
        %xlabel('Comparisons','FontSize',12);  
        yticks(0:10:max(ylim));
        title('Second exposure decoded from first exposure','FontSize',18)
        h = findobj(gca,'Tag','Box');
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'fontsize',16)
        %legend([h(12),h(10),h(8),h(6),h(4),h(2)],{'16Laps','8 Laps', '4 Laps', '3 Laps', '2 Laps', '1 Lap'},'FontSize',12,'Position',[0.92 0.25 0.05 0.2]);
        hold on
        all_groups = unique(groups1,'stable');
        for g = 1 : length(all_groups)
            if mod(g,2) == 1
                plot(g,first_exposure(strcmp(groups1,all_groups{g})),'o','MarkerEdgeColor',[0.6 0.6 0.6],'MarkerSize',6)
            elseif mod(g,2) == 0
                plot(g,first_exposure(strcmp(groups1,all_groups{g})),'o','MarkerEdgeColor',[0.2 0.2 0.2],'MarkerSize',6)
            end
        end
  
    % SAVE    
    save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error';
    cd(save_path)
    if strcmp(save_option,'Y')
        save(sprintf('%s',save_path,'\plotting_median_decoding_error_exposures.mat'),'prot','-v7.3');
    end
end