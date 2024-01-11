% PLOT DECODING ERROR ACROSS LAPS
% Uses information extracted with 'bayesian_decoding_error_stability.mat' to plot median decoding error across laps (each lap compared to the last
% lap(s). Plots for each rat, for each protocol, and a figure with all protocols overlapped (showing both first and second exposure). Also plots
% a figure with the median of all the medians. 
% MH_20.2020


function plot_track_decodingError_across_laps(save_option)

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\extracted_data'
files = dir('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\extracted_data');
files = flipud(files);

PP = plotting_parameters;

% Start figures
f10 = figure('units','normalized','outerposition',[0 0 1 1]);
f20 = figure('units','normalized','outerposition',[0 0 1 1]);
f31 = figure('units','normalized','outerposition',[0 0 1 1]);

all_T1.median_trackDecodingError = [];
all_T1.medianError_perLap = [];

all_T3.median_trackDecodingError = [];
all_T3.medianError_perLap = [];

for t = 1: length(files)-2 % for each protocol
   if contains(files(t).name,'Same')

    load(files(t).name)
    
    % Find indices of each type of track (1 to 4)
    T_idx= [];
    T_idx(1,:) = find(strcmp({sameExposure_DecodingError.tracks_compared},'[1 1]')==1);
    if ~isempty(find(strcmp({sameExposure_DecodingError.tracks_compared},'[2 2]')==1,1))
        T_idx(2,:) = find(strcmp({sameExposure_DecodingError.tracks_compared},'[2 2]')==1);
    end
    T_idx(3,:) = find(strcmp({sameExposure_DecodingError.tracks_compared},'[3 3]')==1);
    T_idx(4,:) = find(strcmp({sameExposure_DecodingError.tracks_compared},'[4 4]')==1);
      
    for i = 1 : length(T_idx) % for each track
        if any(T_idx(i)) == 0 %if it's 1 Lap session, skip
            continue
        end
        for j = 1 : length(T_idx(i,:)) % for each session of this track           
            prot(t).track(i).LapStartTimes(j,:) = sameExposure_DecodingError(T_idx(i,j)).decoding_error.decoded_LapStartTimes;            
            prot(t).track(i).median_trackDecodingError(j) = sameExposure_DecodingError(T_idx(i,j)).decoding_error.median_trackDecodingError;
            if ~isempty(sameExposure_DecodingError(T_idx(i,j)).decoding_error.medianError_perLap)
                prot(t).track(i).medianError_perLap(j,:) = sameExposure_DecodingError(T_idx(i,j)).decoding_error.medianError_perLap;
            end
        end
        if i == 1 %if it's track 1
            all_T1.median_trackDecodingError = [all_T1.median_trackDecodingError; prot(t).track(i).median_trackDecodingError];
            all_T1.medianError_perLap = [all_T1.medianError_perLap; prot(t).track(i).medianError_perLap];
        elseif i == 3
            all_T3.median_trackDecodingError = [all_T3.median_trackDecodingError; prot(t).track(i).median_trackDecodingError];
            all_T3.medianError_perLap = [all_T3.medianError_perLap; prot(t).track(i).medianError_perLap];
 
        end
    end
    
    
    %%%%%%% FIGURE - DECODING ERROR OVER TIME FOR EACH RAT WITHIN A PROTOCOL
    f(t) = figure('units','normalized','outerposition',[0 0 1 1]);
    f(t).Name = strcat('Median decoding error per lap using last laps from same exposure_Protocol_',sameExposure_DecodingError(1).protocol);
    for k = 1 : size(prot(t).track(1).medianError_perLap,1) %for each rat
        ax1(k) = subplot(size(prot(t).track(1).medianError_perLap,1),1,k);
        for ii = 1 : length(prot(t).track)%for each track
            if isempty(prot(t).track(ii).medianError_perLap)
                continue
            end
            hold on
            p4(ii) = plot(prot(t).track(ii).medianError_perLap(k,:),'Color',PP.P(t).colorT(ii,:),'LineWidth',3,'LineStyle',PP.Linestyle{ii});    
            xlabel('Time (sec)')
            ylabel('Median decoding error (cm)')
            box off
        end
    end
    legend([p4(1) p4(2) p4(3) p4(4)],{'T1', 'T2', 'T1-Re', 'T2-Re'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
    %linkaxes([ax1(1) ax1(2) ax1(3) ax1(4)],'y')
    annotation('textbox',[0 0.9 1 0.1],'String',(strcat('Decoding error using last laps from same exposure - Protocol - ',sameExposure_DecodingError(1).protocol)),...
        'EdgeColor', 'none','HorizontalAlignment', 'center','FontSize',14);

    
    %%%%%% FIGURE - DECODING ERROR OVER TIME MEAN ALL RATS (EACH PROTOCOL A SUBPLOT) 
    figure(f10)
    f10.Name = 'Median decoding error per lap using last laps from same exposure_ALLprotocols_ALLRats';
    ax(t) = subplot(5,1,t);
    for ii = 1 : length(prot(t).track)
        if isempty(prot(t).track(ii).medianError_perLap)
            continue
        end
        hold on
        p2(ii) = plot(mean(prot(t).track(ii).medianError_perLap,1),'Color',PP.P(t).colorT(ii,:),'LineWidth',3,'LineStyle',PP.Linestyle{ii});
        xlabel('Time (sec)')
        ylabel('Median decoding error (cm)')
        title(strcat('Protocol - ',sameExposure_DecodingError(1).protocol),'FontSize',12)
        box off
    end
    if t == 5
        legend([p2(1) p2(2) p2(3) p2(4)],{'T1', 'T2', 'T1-Re', 'T2-Re'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
        annotation('textbox',[0 0.9 1 0.1],'String','Decoding error using last laps from same exposure ',...
            'EdgeColor', 'none','HorizontalAlignment', 'center','FontSize',14);
    end
   
end
end

  %%% KRUSKAL WALLIS
    [p,tbl,stats] = kruskalwallis(all_T3.medianError_perLap);
    c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
    sig_idx = find(c(:,6)<0.05);
    [p,tbl,stats] = kruskalwallis(all_T1.medianError_perLap);
    c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
    sig_idx = find(c(:,6)<0.05);
    ptt = [8,4,3,2,1];
    for ii = 1 : length(ptt)
        [p,tbl,stats] = kruskalwallis(prot(ii).track(2).medianError_perLap);
        c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
        sig_idx = find(c(:,6)<0.05);
        [p,tbl,stats] = kruskalwallis(prot(ii).track(4).medianError_perLap);
        c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
        sig_idx = find(c(:,6)<0.05);
    end
    
 %%%%%%% FIGURE - MEDIAN DECODING ERROR OVER TIME MEAN ALL RATS FOR EACH PROTOCOL ALL TOGETHER (16 laps mean of all protocols)
     figure(f20)
     f20.Name = 'Median decoding error per lap using last laps from same exposure_all protocols_1st and 2nd Exposure';
     % T1 first exposure
     mean_temp = mean(all_T1.medianError_perLap,1,'omitnan')';
     std_temp = std(all_T1.medianError_perLap,[],1,'omitnan')';
     p31 = plot(mean_temp,'Color',PP.T1,'LineWidth',4);
     hold on
     x = 1:numel(mean_temp);
     shade1 = mean_temp + std_temp;
     shade2 = mean_temp - std_temp;
     x2 = [x,fliplr(x)];
     inBetween = [shade1',fliplr(shade2')];
     h=fill(x2,inBetween,[0.8 0.8 0.8]);
     set(h,'facealpha',0.1,'LineStyle','none')
     hold on
     plot(mean(all_T1.medianError_perLap,1),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',5)
     % Re-exposure
     mean_temp2 = mean(all_T3.medianError_perLap,1,'omitnan')';
     std_temp2 = std(all_T3.medianError_perLap,[],1,'omitnan')';
     x = 14:13+numel(mean_temp2);
     shade1 = mean_temp2 + std_temp2;
     shade2 = mean_temp2 - std_temp2;
     x2 = [x,fliplr(x)];
     inBetween = [shade1',fliplr(shade2')];
     h=fill(x2,inBetween,[0.8 0.8 0.8]);
     set(h,'facealpha',0.1,'LineStyle','none')
     plot(14:1:13+length(mean_temp2),mean_temp2,'Color',PP.T1,'LineWidth',4);
     plot(14:1:13+length(mean_temp2),mean_temp2,'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',5)
     % T2
     for jj = 1 : length(prot)
         if isempty(prot(jj).track(2).medianError_perLap)
             mean_temp4 = mean(prot(jj).track(4).medianError_perLap,1,'omitnan')';
             std_temp4 = std(prot(jj).track(4).medianError_perLap,[],1,'omitnan')';
             x = 14:13+numel(mean_temp4);
             shade1 = mean_temp4 + std_temp4;
             shade2 = mean_temp4 - std_temp4;
             x2 = [x,fliplr(x)];
             inBetween = [shade1',fliplr(shade2')];
             h=fill(x2,inBetween,PP.T2(jj,:));
             set(h,'facealpha',0.05,'LineStyle','none')
             p3(jj) = plot(14:1:13+size(mean_temp4,1),mean_temp4,'Color',PP.T2(jj,:),'LineWidth',4);
             plot(14:1:13+size(mean_temp4,1),mean_temp4,'o','MarkerFaceColor',PP.T2(jj,:),'MarkerEdgeColor',PP.T2(jj,:),'MarkerSize',5)
             clear mean_temp4 std_temp4
             continue
         end
         mean_temp3 = mean(prot(jj).track(2).medianError_perLap,1,'omitnan')';
         std_temp3 = std(prot(jj).track(2).medianError_perLap,[],1,'omitnan')';
         x = 1:numel(mean_temp3);
         shade1 = mean_temp3 + std_temp3;
         shade2 = mean_temp3 - std_temp3;
         x2 = [x,fliplr(x)];
         inBetween = [shade1',fliplr(shade2')];
         h=fill(x2,inBetween,PP.T2(jj,:));
         set(h,'facealpha',0.05,'LineStyle','none')
         plot(mean_temp3,'Color',PP.T2(jj,:),'LineWidth',4);
         plot(mean_temp3,'o','MarkerFaceColor',PP.T2(jj,:),'MarkerEdgeColor',PP.T2(jj,:),'MarkerSize',5)

         mean_temp4 = mean(prot(jj).track(4).medianError_perLap,1,'omitnan')';
         std_temp4 = std(prot(jj).track(4).medianError_perLap,[],1,'omitnan')';
         x = 14:13+numel(mean_temp4);
         shade1 = mean_temp4 + std_temp4;
         shade2 = mean_temp4 - std_temp4;
         x2 = [x,fliplr(x)];
         inBetween = [shade1',fliplr(shade2')];
         h=fill(x2,inBetween,PP.T2(jj,:));
         set(h,'facealpha',0.05,'LineStyle','none')
         p3(jj) = plot(14:1:13+size(mean_temp4,1),mean_temp4,'Color',PP.T2(jj,:),'LineWidth',4);
         plot(14:1:13+size(mean_temp4,1),mean_temp4,'o','MarkerFaceColor',PP.T2(jj,:),'MarkerEdgeColor',PP.T2(jj,:),'MarkerSize',6)
         clear mean_temp3 mean_temp4 std_temp3 std_temp4
     end
     xlabel('Time (sec)')
     ylabel('Median decoding error (cm)')
     box off
     title('Median decoding error per lap using last laps from same exposure - all protocols - 1st & 2nd Exposure');
     p5 = line([13 13],[min(ylim) max(ylim)],'Color',[0.8 0.8 0.8],'LineWidth',5);
     legend([p31 p3(1) p3(2) p3(3) p3(4) p3(5) p5],{'16Laps','8 Laps', '4 Laps', '3 Laps', '2 Laps', '1 Lap','Re-exposure'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)

 %%%%%% FIGURE - MEDIAN DECODING ERROR PER PROTOCOL (1st and 2nd Exposure)
    f33 = figure;
    f33.Name = 'Median decoding error using last laps from same exposure_all protocols1st and 2nd Exposure';
    cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error'
    load('all_tracks_decoding_error.mat')
    % Organize the data in a matrix, where each column will be box plot.
    % The two exposures will be separated by a column of NaNs
    
    % T1
    all_data_matrix = reshape(all_T1.medianError_perLap,[size(all_T1.medianError_perLap,1)*size(all_T1.medianError_perLap,2),1]); %T1
    groups = {'16Laps'}; %set the label for each value
    for ii = 1 : 11
        all_data_matrix = [all_data_matrix, nan(size(all_data_matrix,1),1)];
    end

    % T2
    for jj = 1 : length(prot) 
        if isempty(prot(jj).track(2).medianError_perLap)
            continue
        end
        c = [];
        c = reshape(prot(jj).track(2).medianError_perLap,[size(prot(jj).track(2).medianError_perLap,1)*size(prot(jj).track(2).medianError_perLap,2),1]);
        all_data_matrix(1:length(c),jj+1) = c;
        groups = [groups; PP.titles.protocols(jj)];
    end

    % T3
    c = [];
    c = reshape(all_T3.medianError_perLap,[size(all_T3.medianError_perLap,1)*size(all_T3.medianError_perLap,2),1]);
    all_data_matrix(1:length(c),7) = c;
    groups = [groups;{'2'}; {'RE-16Laps'}];
    % T4
    for jj = 1 : length(prot)
        c = [];
        c = reshape(prot(jj).track(4).medianError_perLap,[size(prot(jj).track(4).medianError_perLap,1)*size(prot(jj).track(4).medianError_perLap,2),1]);
        all_data_matrix(1:length(c),jj+7) = c;
        groups = [groups; PP.titles.protocols(jj)];
    end
    
    % Run Kruskal-Wallis
    sig_diff_idx = [];
    [pv,tbl,stats1]=kruskalwallis(all_data_matrix,groups,'off');
    if pv < 0.05
        [c,~,~,~] = multcompare(stats1,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
        sig_diff_idx = find(c(:,6) <= 0.05);
    end
    
    
    % PLOT
    col = [PP.viridis_colormap(1:5,:); [1,1,1]; PP.viridis_colormap]; %set colors
    boxplot(all_data_matrix,unique(groups,'stable'),'PlotStyle','compact','BoxStyle','filled','Colors',col,'labels',{'','','','First Exposure','','','','','Second Exposure','','',''},...
        'LabelOrientation','horizontal','Widths',0.5,'symbol','');
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    t = get(a,'tag');   % List the names of all the objects
    idx=strcmpi(t,'box');  % Find Box objects
    boxes=a(idx);          % Get the children you need
    set(boxes,'linewidth',12); % Set width
    ylabel('Median decoding error','FontSize',12);
    xlabel('Protocols','FontSize',12);
    box off
    b1 = line([6 6],[min(ylim) max(ylim)],'Color',[0.8 0.8 0.8],'LineWidth',4);
    h = findobj(gca,'Tag','Box');
    hold on
    for ii = 1 : 12
        if ii ~= 6
            dat = all_data_matrix(:,ii);
            plot(ones(1,length(dat))*ii,dat,'o','MarkerEdgeColor',[0.6 0.6 0.6],'MarkerSize',5)
        end
    end
    
    if ~isempty(sig_diff_idx)
        maxy = max(ylim);
        miny = min(ylim);
        ylim([miny,maxy+(length(sig_diff_idx)*0.17)])
        
        % Add sig bars
        for ii = 1 : length(sig_diff_idx)
            dist = 33+0.1 + (2*(ii-1));
            dist_s = dist + 1;
            hold on
            if c(sig_diff_idx(ii),2) == 7 % because 6 is the NaN column in the plot, but is skipped in the stats
                c2 = 8;
            else
                c2=  c(sig_diff_idx(ii),2);
            end
            if c(sig_diff_idx(ii),1) == 7
                c1 = 8;
            else
                c1 = c(sig_diff_idx(ii),1);
            end
            plot([c1 c2], [dist dist], '-k', 'LineWidth',1)
            plot([(c1+c2)/2 (c1+c2)/2], [dist_s dist_s], '*k','MarkerSize',2)
        end
    end
    
    legend([h(12),h(5),h(4),h(3),h(2),h(1),b1],{'16Laps','8 Laps', '4 Laps', '3 Laps', '2 Laps', '1 Lap','Re-exposure'},'FontSize',12);  
    
     %%%%%% FIGURE - MEDIAN DECODING ERROR PER PROTOCOL (1st and 2nd Exposure)
    figure(f31)
    f31.Name = 'Median decoding error for all Tracks';
    cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error'
    load('all_tracks_decoding_error.mat')
    % Organize the data in a matrix, where each column will be box plot.
    % The two exposures will be separated by a column of NaNs
    
    % T1
    all_data_matrix = [reshape(all_T1.median_trackDecodingError,[size(all_T1.median_trackDecodingError,1)*size(all_T1.median_trackDecodingError,2),1])]; %T1
    groups = [repmat({'16Laps'},(size(all_T1.median_trackDecodingError,1)*size(all_T1.median_trackDecodingError,2)),1)]; %set the label for each value
    % T2
    for jj = 1 : length(prot) 
        if isempty(prot(jj).track(2).median_trackDecodingError)
            continue
        end
        all_data_matrix = [all_data_matrix; prot(jj).track(2).median_trackDecodingError'];
        groups = [groups; repmat(PP.titles.protocols(jj),size(prot(jj).track(2).median_trackDecodingError,2),1)];
    end
    % Add 1 lap
    T2 = [all_tracks_decoding_error.T2];
    all_data_matrix = [all_data_matrix; T2(17:20)'];
    groups = [groups; repmat(PP.titles.protocols(5),4,1)];
    % T3
    all_data_matrix = [all_data_matrix;[NaN,NaN,NaN]'; reshape(all_T3.median_trackDecodingError,[size(all_T3.median_trackDecodingError,1)*size(all_T3.median_trackDecodingError,2),1])];
    groups = [groups; repmat({'2'},3,1); repmat({'RE-16Laps'},(size(all_T3.median_trackDecodingError,1)*size(all_T3.median_trackDecodingError,2)),1)];
    % T4
    for jj = 1 : length(prot)
        all_data_matrix = [all_data_matrix; prot(jj).track(4).median_trackDecodingError'];
        groups = [groups; repmat({strcat('RE-',PP.titles.protocols{jj})},size(prot(jj).track(4).median_trackDecodingError,2),1)];
    end
    
    % Run Kruskal-Wallis
    sig_diff_idx = [];
    [pv,tbl,stats1]=kruskalwallis(all_data_matrix,groups,'off');
    if pv < 0.05
        [c,~,~,~] = multcompare(stats1,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
        sig_diff_idx = find(c(:,6) <= 0.05);
    end
    
    % PLOT
    col = [PP.viridis_colormap; [1,1,1]; PP.viridis_colormap]; %set colors
    boxplot(all_data_matrix,groups,'PlotStyle','compact','BoxStyle','filled','Colors',col,'labels',{'','','','First Exposure','','','','','','Second Exposure','','',''},...
        'LabelOrientation','horizontal','Widths',0.5,'symbol','');
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    t = get(a,'tag');   % List the names of all the objects
    idx=strcmpi(t,'box');  % Find Box objects
    boxes=a(idx);          % Get the children you need
    set(boxes,'linewidth',12); % Set width
    ylabel('Median decoding error','FontSize',12);
    xlabel('Protocols','FontSize',12);
    box off
    b1 = line([7 7],[min(ylim) max(ylim)],'Color',[0.8 0.8 0.8],'LineWidth',4);
    h = findobj(gca,'Tag','Box');
    hold on
    for ii = 1 : 13
        gr = unique(groups,'stable');
        if ~strcmp(gr{ii},'2')
            dat = all_data_matrix(strcmp(groups,gr{ii}));
            plot(ones(1,length(dat))*ii,dat,'o','MarkerEdgeColor',[0.6 0.6 0.6],'MarkerSize',5)
        end
    end
    
    if ~isempty(sig_diff_idx)
        maxy = max(ylim);
        miny = min(ylim);
        ylim([miny,maxy+(length(sig_diff_idx)*0.17)])
        
        % Add sig bars
        for ii = 1 : length(sig_diff_idx)
            dist = 33+0.1 + (2*(ii-1));
            dist_s = dist + 1;
            hold on
            if c(sig_diff_idx(ii),2) == 7 % because 6 is the NaN column in the plot, but is skipped in the stats
                c2 = 8;
            else
                c2=  c(sig_diff_idx(ii),2);
            end
            if c(sig_diff_idx(ii),1) == 7
                c1 = 8;
            else
                c1 = c(sig_diff_idx(ii),1);
            end
            plot([c1 c2], [dist dist], '-k', 'LineWidth',1)
            plot([(c1+c2)/2 (c1+c2)/2], [dist_s dist_s], '*k','MarkerSize',2)
        end
    end
    
    legend([h(12),h(5),h(4),h(3),h(2),h(1),b1],{'16Laps','8 Laps', '4 Laps', '3 Laps', '2 Laps', '1 Lap','Re-exposure'},'FontSize',12);  
    
    
    % SAVE
    
    save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error';
    cd(save_path)
    if strcmp(save_option,'Y')
        save(sprintf('%s',save_path,'\plotting_median_decoding_error_across_laps.mat'),'prot','stats1','c','-v7.3');
    end
end 