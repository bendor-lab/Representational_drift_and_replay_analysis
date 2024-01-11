% PLOT DECODING ERROR IN CONSECUTIVE LAPS
% Uses information extracted with
% 'bayesian_decoding_error_consecutive_laps.mat' to plot median decoding error across laps (each lap compared to the next
% lap within a exposure. Plots for each rat, for each protocol, and a figure with all protocols overlapped (showing both first and second exposure). Also plots
% a figure with the median of all the medians. 
% MH_02.2020


function plotting_data = plot_track_decodingError_consecutive_laps(save_option)

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\extracted_data'
files = dir('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\extracted_data');
files = flipud(files);

PP = plotting_parameters;

% Start figures
f10 = figure('units','normalized','outerposition',[0 0 1 1]);
f20 = figure('units','normalized','outerposition',[0 0 1 1]);

all_T1.median_trackDecodingError = [];
all_T3.median_trackDecodingError = [];

fi = 1; %keep track of files
for t = 1: length(files)-2 % for each protocol
   
   if contains(files(t).name,'Consecutive')

    load(files(t).name)
    
    % Find indices of each type of track (1 to 4)
    if strcmp(ConsecutiveLaps_DecodingError(1).protocol,'16x1')
        for ii = 1 : length(ConsecutiveLaps_DecodingError)
            if isempty(ConsecutiveLaps_DecodingError(ii).laps_jump)
                ConsecutiveLaps_DecodingError(ii).laps_jump = 0;
            end
        end
    end
    T_idx= [];
    T_idx(1,:) = intersect(find(strcmp({ConsecutiveLaps_DecodingError.tracks_compared},'[1 1]')==1),find([ConsecutiveLaps_DecodingError(:).laps_jump] ==1));
    if ~isempty(find(strcmp({ConsecutiveLaps_DecodingError.tracks_compared},'[2 2]')==1,1))
        T_idx(2,:) = intersect(find(strcmp({ConsecutiveLaps_DecodingError.tracks_compared},'[2 2]')==1),find([ConsecutiveLaps_DecodingError(:).laps_jump] ==1));
    end
    T_idx(3,:) = intersect(find(strcmp({ConsecutiveLaps_DecodingError.tracks_compared},'[3 3]')==1), find([ConsecutiveLaps_DecodingError(:).laps_jump] ==1));
    T_idx(4,:) = intersect(find(strcmp({ConsecutiveLaps_DecodingError.tracks_compared},'[4 4]')==1), find([ConsecutiveLaps_DecodingError(:).laps_jump] ==1));
      
    for i = 1 : size(T_idx,1) % for each track
        if any(T_idx(i)) == 0 %if it's 1 Lap session, skip
            continue
        end
        
        % Find biggest size from all the sessions within a track
        sizes =[];
        for ses = 1 : length(T_idx(i,:))
            sizes = [sizes; length(ConsecutiveLaps_DecodingError(T_idx(i,ses)).median_trackDecodingError)];
        end
        [~,idx] = max(sizes); %max session length
        prot(fi).track(i).median_trackDecodingError = NaN(length(ConsecutiveLaps_DecodingError(T_idx(i,idx)).median_trackDecodingError),length(T_idx(i,:))); % create NaN matrix to allocate all sessions together even if they have different sizes        
        for j = 1 : length(T_idx(i,:)) % for each session of this track           
            prot(fi).track(i).median_trackDecodingError(1:length(ConsecutiveLaps_DecodingError(T_idx(i,j)).median_trackDecodingError),j) = ConsecutiveLaps_DecodingError(T_idx(i,j)).median_trackDecodingError;
        end
        
        % Save all T1 and T3 of all protocols together
        if i == 1 %if it's track 1
            if isempty(all_T1.median_trackDecodingError)
                all_T1.median_trackDecodingError = [all_T1.median_trackDecodingError, prot(fi).track(i).median_trackDecodingError];
            else
                % if sizes are different, add NaNs to be able to concatenate
                diff_size = size(all_T1.median_trackDecodingError,1) - size(prot(fi).track(i).median_trackDecodingError,1);
                if diff_size > 0 %if all_T1 is bigger
                    for j = 1 : diff_size
                        prot(fi).track(i).median_trackDecodingError(size(prot(fi).track(i).median_trackDecodingError,1)+j,:) = NaN;
                    end
                elseif diff_size < 0 % if prot.track.median... is bigger
                    for j = 1 : abs(diff_size)
                        all_T1.median_trackDecodingError(size(all_T1.median_trackDecodingError,1)+j,:) = NaN;
                    end
                end
                all_T1.median_trackDecodingError = [all_T1.median_trackDecodingError, prot(fi).track(i).median_trackDecodingError];
            end
        elseif i == 3
            if isempty(all_T3.median_trackDecodingError)
                all_T3.median_trackDecodingError = [all_T3.median_trackDecodingError, prot(fi).track(i).median_trackDecodingError];
            else
                % if sizes are different, add NaNs to be able to concatenate
                diff_size = size(all_T3.median_trackDecodingError,1) - size(prot(fi).track(i).median_trackDecodingError,1);
                if diff_size > 0 %if all_T3 is bigger
                    curr_size = size(prot(fi).track(i).median_trackDecodingError,1);
                    for j = 1 : diff_size
                        prot(fi).track(i).median_trackDecodingError(curr_size+j,:) = NaN;
                    end
                elseif diff_size < 0 % if prot.track.median... is bigger
                    curr_size = size(all_T3.median_trackDecodingError,1);
                    for j = 1 : abs(diff_size)
                        all_T3.median_trackDecodingError(curr_size+j,:) = NaN;
                    end
                end
                all_T3.median_trackDecodingError = [all_T3.median_trackDecodingError, prot(fi).track(i).median_trackDecodingError];
            end
        end
        
    end
    

    %%%%%%% FIGURE - DECODING ERROR OVER TIME FOR EACH RAT WITHIN A PROTOCOL
    f(fi) = figure('units','normalized','outerposition',[0 0 1 1]);
    f(fi).Name = strcat('Median decoding error of consecutive laps within same exposure_Protocol_',ConsecutiveLaps_DecodingError(1).protocol);
    for k = 1 : size(prot(fi).track(1).median_trackDecodingError,2) %for each rat
        ax1(k) = subplot(size(prot(fi).track(1).median_trackDecodingError,2),1,k);
        for ii = 1 : length(prot(fi).track)%for each track
            if isempty(prot(fi).track(ii).median_trackDecodingError)
                continue
            end
            hold on
            p4(ii) = plot(prot(fi).track(ii).median_trackDecodingError(:,k),'Color',PP.P(fi).colorT(ii,:),'LineWidth',3,'LineStyle',PP.Linestyle{ii});    
            xlabel('Time (sec)')
            ylabel('Median decoding error (cm)')
            box off
        end
    end
    legend([p4(1) p4(2) p4(3) p4(4)],{'T1', 'T2', 'T1-Re', 'T2-Re'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
    %linkaxes([ax1(1) ax1(2) ax1(3) ax1(4)],'y')
    annotation('textbox',[0 0.9 1 0.1],'String',(strcat('Decoding error using last laps from same exposure - Protocol - ',ConsecutiveLaps_DecodingError(1).protocol)),...
        'EdgeColor', 'none','HorizontalAlignment', 'center','FontSize',14);

    
    %%%%%% FIGURE - DECODING ERROR OVER TIME MEAN ALL RATS (EACH PROTOCOL A SUBPLOT) 
    figure(f10)
    f10.Name = 'Median decoding error of consecutive laps within same exposure_ALLProtocol_ALL RATS';
    ax(fi) = subplot(5,1,fi);
    for ii = 1 : length(prot(fi).track)
        if isempty(prot(fi).track(ii).median_trackDecodingError)
            continue
        end
        hold on
        p2(ii) = plot(mean(prot(fi).track(ii).median_trackDecodingError,2),'Color',PP.P(fi).colorT(ii,:),'LineWidth',3,'LineStyle',PP.Linestyle{ii});
        xlabel('Time (sec)')
        ylabel('Median decoding error (cm)')
        title(strcat('Protocol - ',ConsecutiveLaps_DecodingError(1).protocol),'FontSize',12)
        box off
    end
    if fi == 5
        legend([p2(1) p2(2) p2(3) p2(4)],{'T1', 'T2', 'T1-Re', 'T2-Re'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
        annotation('textbox',[0 0.9 1 0.1],'String','Decoding error using last laps from same exposure ',...
            'EdgeColor', 'none','HorizontalAlignment', 'center','FontSize',14);
    end
    
    fi = fi + 1; %next file
  end
end


    %%% KRUSKAL WALLIS
    [p,tbl,stats] = kruskalwallis(all_T3.median_trackDecodingError(1:15,:)');
    c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
    sig_idx = find(c(:,6)<0.05);
    [p,tbl,stats] = kruskalwallis(all_T1.median_trackDecodingError(1:15,:)');
    c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
    sig_idx = find(c(:,6)<0.05);
    ptt = [8,4,3,2,1];
    for ii = 1 : length(ptt)
        [p,tbl,stats] = kruskalwallis(prot(ii).track(2).median_trackDecodingError');
        c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
        sig_idx = find(c(:,6)<0.05);
        [p,tbl,stats] = kruskalwallis(prot(ii).track(4).median_trackDecodingError(1:15,:)');
        c = multcompare(stats,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
        sig_idx = find(c(:,6)<0.05);
    end
    

%%%%%%% FIGURE - MEDIAN DECODING ERROR OVER TIME MEAN ALL RATS FOR EACH PROTOCOL ALL TOGETHER (16 laps mean of all protocols)
figure(f20)
f20.Name = 'Median decoding error  of consecutive laps within same exposure_all protocols_1st and 2nd Exposure';

% T1 first exposure
mean_temp = mean(all_T1.median_trackDecodingError,2,'omitnan')';
std_temp = std(all_T1.median_trackDecodingError,[],2,'omitnan')';
p31 = plot(mean_temp(1:15),'Color',PP.T1,'LineWidth',4);
hold on
x = 1:numel(mean_temp(1:15));
shade1 = mean_temp(1:15) + std_temp(1:15);
shade2 = mean_temp(1:15) - std_temp(1:15);
x2 = [x,fliplr(x)];
inBetween = [shade1,fliplr(shade2)];
h=fill(x2,inBetween,[0.8 0.8 0.8]);
set(h,'facealpha',0.1,'LineStyle','none')
hold on
plot(mean(all_T1.median_trackDecodingError,2),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',5)
% Re-exposure
mean_temp2 = mean(all_T3.median_trackDecodingError,2,'omitnan')';
std_temp2 = std(all_T3.median_trackDecodingError,[],2,'omitnan')';
x = 17:16+numel(mean_temp2(1:16));
shade1 = mean_temp2(1:16) + std_temp2(1:16);
shade2 = mean_temp2(1:16) - std_temp2(1:16);
x2 = [x,fliplr(x)];
inBetween = [shade1,fliplr(shade2)];
h=fill(x2,inBetween,[0.8 0.8 0.8]);
set(h,'facealpha',0.1,'LineStyle','none')
plot(17:1:16+length(mean_temp2(1:16)),mean_temp2(1:16),'Color',PP.T1,'LineWidth',4);
plot(17:1:16+length(mean_temp2(1:16)),mean_temp2(1:16),'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1,'MarkerSize',5)
% T2
for jj = 1 : length(prot)
    if isempty(prot(jj).track(2).median_trackDecodingError)
        mean_temp4 = mean(prot(jj).track(4).median_trackDecodingError,2,'omitnan')';
        std_temp4 = std(prot(jj).track(4).median_trackDecodingError,[],2,'omitnan')';
        x = 17:16+numel(mean_temp4(1:16));
        shade1 = mean_temp4(1:16) + std_temp4(1:16);
        shade2 = mean_temp4(1:16) - std_temp4(1:16);
        x2 = [x,fliplr(x)];
        inBetween = [shade1,fliplr(shade2)];
        h=fill(x2,inBetween,PP.T2(jj,:));
        set(h,'facealpha',0.05,'LineStyle','none')
        p3(jj) = plot(17:1:16+size(mean_temp4(1:16),2),mean_temp4(1:16),'Color',PP.T2(jj,:),'LineWidth',4);
        plot(17:1:16+size(mean_temp4(1:16),2),mean_temp4(1:16),'o','MarkerFaceColor',PP.T2(jj,:),'MarkerEdgeColor',PP.T2(jj,:),'MarkerSize',6)
        clear mean_temp4 std_temp4        
        continue
    end
    mean_temp3 = mean(prot(jj).track(2).median_trackDecodingError,2,'omitnan')';
    std_temp3 = std(prot(jj).track(2).median_trackDecodingError,[],2,'omitnan')';
    x = 1:numel(mean_temp3);
    shade1 = mean_temp3 + std_temp3;
    shade2 = mean_temp3 - std_temp3;
    x2 = [x,fliplr(x)];
    inBetween = [shade1,fliplr(shade2)];
    h=fill(x2,inBetween,PP.T2(jj,:));
    set(h,'facealpha',0.05,'LineStyle','none')
    plot(mean_temp3,'Color',PP.T2(jj,:),'LineWidth',4);
    plot(mean_temp3,'o','MarkerFaceColor',PP.T2(jj,:),'MarkerEdgeColor',PP.T2(jj,:),'MarkerSize',5)
    
    mean_temp4 = mean(prot(jj).track(4).median_trackDecodingError,2,'omitnan')';
    std_temp4 = std(prot(jj).track(4).median_trackDecodingError,[],2,'omitnan')';
    x = 17:16+numel(mean_temp4(1:16));
    shade1 = mean_temp4(1:16) + std_temp4(1:16);
    shade2 = mean_temp4(1:16) - std_temp4(1:16);
    x2 = [x,fliplr(x)];
    inBetween = [shade1,fliplr(shade2)];
    h=fill(x2,inBetween,PP.T2(jj,:));
    set(h,'facealpha',0.05,'LineStyle','none')
    p3(jj) = plot(17:1:16+size(mean_temp4(1:16),2),mean_temp4(1:16),'Color',PP.T2(jj,:),'LineWidth',4);
    plot(17:1:16+size(mean_temp4(1:16),2),mean_temp4(1:16),'o','MarkerFaceColor',PP.T2(jj,:),'MarkerEdgeColor',PP.T2(jj,:),'MarkerSize',6)
    clear mean_temp3 mean_temp4 std_temp3 std_temp4
end

xlabel('Time (sec)')
ylabel('Median decoding error (cm)')
box off
title('Median decoding error per lap using last laps from same exposure - all protocols - 1st & 2nd Exposure');
p5 = line([16 16],[min(ylim) max(ylim)],'Color',[0.8 0.8 0.8],'LineWidth',5);
legend([p31 p3(1) p3(2) p3(3) p3(4) p3(5) p5],{'16Laps','8 Laps', '4 Laps', '3 Laps', '2 Laps', '1 Lap','Re-exposure'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)

% SAVE
    
    save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error';
    cd(save_path)
    if strcmp(save_option,'Y')
        save(sprintf('%s',save_path,'\plotting_median_decoding_error_consecutive_laps.mat'),'prot','-v7.3');
    end
end 