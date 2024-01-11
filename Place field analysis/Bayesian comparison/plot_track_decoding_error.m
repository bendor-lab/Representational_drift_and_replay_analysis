% Plot track decoding error
% MH, 05.2020
% Plots confusion matrix for each track
% Plots cumulative frequency of median decoding error 


function plot_track_decoding_error

PP = plotting_parameters;
% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
else
    sessions = data_folders;
    session_names = fieldnames(sessions);
end

protocols = [8,4,3,2,1];
f3 = figure('units','normalized','outerposition',[0 0 1 1]);
f3.Name = 'All sessions mean cumulative decoding error';
    
for p = 1 : length(session_names) % for each protocol
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));

    c = 1;

    for s = 1: length(folders) % for each session
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        
        folder_name = strsplit(pwd,'\');
        session = folder_name{end};
        
        load track_decoding_error.mat
        
        if s == 1
            curr_folder = pwd;
            cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\figures\Track decoding error')
            fig_axes = confusion_matrices_makeFigure;
            f1 = gcf;
            f1.Name = ['Confusion_matrices_protocol_' num2str(protocols(p))];
            cd(curr_folder)
        end
        
%         f1 = figure('units','normalized','outerposition',[0 0 1 1]);
%         f1.Name = [session '_confusion_matrices'];
        f2 = figure('units','normalized','outerposition',[0 0 1 1]);
        f2.Name = [session '_cumulative decoding error'];
        
        for i = 1 : length(track_decoding_error) % for each track
            
            % Plot confusion matrices for each track
            true_pos = [track_decoding_error(i).true_positions{:}];
            decoded_pos =[track_decoding_error(i).decoded_positions{:}];
            
            figure(f1)
            hold on
            % count all decoded positions in each true position (e.g. for position 5, which values has given the decoder)
            n = hist3([true_pos' decoded_pos'],'Ctrs',{5:10:195 5:10:195});
            sum_prob = sum(n,2); % sum of all values in the true position
            %subplot(2,2,i)
            imagesc(fig_axes(c),n./sum_prob); % probability of each decoded position for that true position
            set(gca,'YDir','Normal');
            colormap gray
            map= colormap;
            colormap(flipud(map));
            xlim(fig_axes(c),[0 20]); ylim(fig_axes(c),[0 20]);
            box off
            if s == 4
                xlabel(fig_axes(c),'Decoded position')
            end
            if i ==4
                h = colorbar('units','centimeters');
                set(h,'ylim',[0 1])
                set_colorbar_position(h,get(fig_axes(c),'position'),'right')
            elseif i == 1
                ylabel(fig_axes(c),'True position')
            end
            if s == 1
                title(fig_axes(c),['Track ' num2str(i)],'Position', [0.5, 1]);
            else
                title(fig_axes(c),'');
            end
            
            % Plot cumulative distribution of the decoding error
            figure(f2)
            hold on
            hh = cdfplot([track_decoding_error(i).decoded_errors{:}]);
            hh.Color = PP.P(p).colorT(i,:);
            hh.LineStyle = PP.Linestyle{i};
            hh.LineWidth = PP.Linewidth{i};   
            
            % Save the decoded errors for each track of this protocol
            this_track_errors{s,i} = [track_decoding_error(i).decoded_errors{:}];                        
            
            c = c +1;
            mean_median_decoding_Error(s,i) = track_decoding_error(i).track_MEDIAN_decoding_error;
        end
        
        figure(f2)
        xlabel('median decoding error(cm)'); ylabel('Cumulative frequency')
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'fontsize',9,'FontWeight','bold')
        box off; grid off; title('')
        title('Median decoding error')
        legend({['T1, median: ' num2str(track_decoding_error(1).track_MEDIAN_decoding_error)], ['T2, median: ' num2str(track_decoding_error(2).track_MEDIAN_decoding_error)],...
            ['R-T1, median: ' num2str(track_decoding_error(3).track_MEDIAN_decoding_error)],['R-T2, median: ' num2str(track_decoding_error(4).track_MEDIAN_decoding_error)]},...
            'Location','best','FontSize',12)
        
        
    end
    
    
    % Find max lenghts to be able to calculate the mean
    for tt = 1 : size(this_track_errors,2) % for each track
        for jj = 1 : size(this_track_errors,1) % for each session
            lengths(jj,tt) =  length(this_track_errors{jj,tt});
        end
    end
    max_lengths = max(lengths,[],1);
    
    for tt = 1 : size(this_track_errors,2) % for each track       
        track_matrix = nan(4,max_lengths(tt));    % Put all sessions in same matrix
        % Normalize event count based on the length of longest cell with decoding errors,by looking how many sessions contribute to each time bin
        bins_with_active_period = ones(1,max_lengths(tt))*length(folders); % Set the count as if all periods had the same length
        for t = 1 : length(folders)
            if lengths(t,tt) < max_lengths(tt) % if this sessions is shorter than the longest period
                diff_idx = max_lengths(tt) - lengths(t,tt);
                bins_with_active_period(end-diff_idx-1:end) = bins_with_active_period(end-diff_idx-1:end) - 1;
            end
            % add track in matrix
            track_matrix(t,1:lengths(t,tt)) = this_track_errors{t,tt};
        end
        % Calculate mean decoding error for each track across same protocol
        nan_idx = isnan(track_matrix);
        track_matrix(nan_idx) = 0;
        mean_error{tt} = sum(track_matrix,1)./bins_with_active_period;
        std_error{tt} = std(track_matrix,1);
    end
    
    figure(f3)
    subplot(3,2,p)
    % Plot all sessions within protocol together
    for tt = 1 : size(this_track_errors,2) % for each track
        hold on
        hh = cdfplot(mean_error{tt});
        hh.Color = PP.P(p).colorT(tt,:);
        hh.LineStyle = PP.Linestyle{tt};
        hh.LineWidth = PP.Linewidth{tt};
        %          % Add standard deviation as shade
        %          x = 1:numel(mean_error{tt});
        %          shade1 = mean_error{tt} + std_error{tt};
        %          shade2 = mean_error{tt} - std_error{tt};
        %          x2 = [x,fliplr(x)];
        %          inBetween = [shade1,fliplr(shade2)];
        %          h=fill(x2,inBetween,PP.T2(tt,:));
        %          set(h,'facealpha',0.2,'LineStyle','none')
    end
    xlabel('median decoding error(cm)'); ylabel('Cumulative frequency')
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',12,'FontWeight','bold')
    box off; grid off;
    title(['Protocol 16x' num2str(protocols(p))])
    legend({['T1, mean: ' num2str(mean(mean_median_decoding_Error(:,1)))], ['T2, mean: '  num2str(mean(mean_median_decoding_Error(:,2)))],...
        ['R-T1, mean: '  num2str(mean(mean_median_decoding_Error(:,3)))],['R-T2, mean: ' num2str(mean(mean_median_decoding_Error(:,4)))]},...
        'Location','best','FontSize',12)
    
%     % RUN STATS
%            matr = [ ones(1,length(mean_error{1,1}))' mean_error{1,1}'; ones(1,length(mean_error{1,2}))'*2 mean_error{1,2}';...
%               ones(1,length(mean_error{1,3}))'*3 mean_error{1,3}'; ones(1,length(mean_error{1,4}))'*4 mean_error{1,4}'];
%           matr(matr(:,2) == 0,:) = [];
%          [AD_stats] = AnDarksamtest(matr2,0.05);
%             dunn(matr(:,2)',matr(:,1)',0)
%             
%             AnDartest1 = AnDartest(mean_error{1,1},0.05);
%             AnDartest2 = AnDartest(mean_error{1,2},0.05);
%             AnDartest3 = AnDartest(mean_error{1,3},0.05);
%             AnDartest4 = AnDartest(mean_error{1,4},0.05);
%             
    % Save all figures
    %     save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error',[])
    
end



% Plot position vs events, color coding probability or amplitude
ids = [9,11,33,41,69];
real_id = [14,18,51,65,110];
col = flipud(bone);
for i = 1 : length(ids)
    figure
    subplot(1,3,1)
    imagesc(trial_estimated_place_field.units(i).replay_OneTrack);
    colormap(col)
    colorbar
    title('new analysis')
    
    subplot(1,3,2)
    imagesc(estimated_place_field(1).units(ids(i)).replay_OneTrack);
    colormap(col)
    colorbar
    title('old analysis')
    
    idx = find(place_fields_BAYESIAN.track(1).good_cells == real_id(i));
    
    subplot(1,3,3)
    plot(place_fields_BAYESIAN.track(1).smooth{idx},'Color','k','LineWidth',3)
end


%%%%%%%%%%%%%%%%
%%
    cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error'
    load('all_tracks_decoding_error.mat')
    % Organize the data in a matrix, where each column will be box plot.
    % The two exposures will be separated by a column of NaNs
    
    % T1
    all_data_matrix = [all_tracks_decoding_error(:).T1]'; %T1
    groups = [repmat({'16Laps'},(size([all_tracks_decoding_error(:).T1],1)*size([all_tracks_decoding_error(:).T1],2)),1)]; %set the label for each value
    
    % T2
    cnt=1;
    for jj = 1 : 5
        all_data_matrix = [all_data_matrix; [all_tracks_decoding_error(cnt:cnt+3).T2]'];
        groups = [groups; repmat(PP.titles.protocols(jj),4,1)];
        cnt = cnt+4;
    end 
     % Run Kruskal-Wallis
    sig_diff_idx = [];
    [pv,tbl,stats1]=kruskalwallis(all_data_matrix,groups,'off');
    if pv < 0.05
        [c,~,~,~] = multcompare(stats1,'ctype','dunn-sidak','Display','off');  % if anova pval is < 0.05, run multiple comparisons
        sig_diff_idx = find(c(:,6) <= 0.05);
    end
    [p,h,stats] = signrank([all_tracks_decoding_error(17:20).T1], [all_tracks_decoding_error(17:20).T2])
    [p,h,stats] = signrank([all_tracks_decoding_error(:).T1],[nan(1,16) [all_tracks_decoding_error(13:16).T2]])
    [p,h,stats] = signrank([all_tracks_decoding_error(:).T1],all_tracks_decoding_error(9:12).T2)

    
    all_data_matrix = [all_data_matrix;[NaN,NaN,NaN]'; [all_tracks_decoding_error(:).T3]'];
    groups = [groups; repmat({'2'},3,1); repmat({'R-T1'},(size([all_tracks_decoding_error(:).T3],1)*size([all_tracks_decoding_error(:).T3],2)),1)];
    % T4
    cnt=1;
    for jj = 1 : 5
        all_data_matrix = [all_data_matrix; [all_tracks_decoding_error(cnt:cnt+3).T4]'];
        groups = [groups; repmat({strcat(['R-T2-' PP.titles.protocols{jj}])},4,1)];
        cnt = cnt+4;
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
    ylabel('Median decoding error (cm)','FontSize',12);
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
        
        rev = flipud(sig_diff_idx);
        % Add sig bars
        for ii = 1 : length(sig_diff_idx)
            dist = 33+0.1 + (2*(ii-1));
            dist_s = dist + 1;
            hold on
            if c(rev(ii),2) == 7 % because 6 is the NaN column in the plot, but is skipped in the stats
                c2 = 8;
            else
                c2=  c(rev(ii),2);
            end
            if c(rev(ii),1) == 7
                c1 = 8;
            else
                c1 = c(rev(ii),1);
            end
            plot([c1 c2], [dist dist], '-k', 'LineWidth',1)
            plot([(c1+c2)/2 (c1+c2)/2], [dist_s dist_s], '*k','MarkerSize',2)
        end
    end
    
    legend([h(12),h(5),h(4),h(3),h(2),h(1),b1],{'16Laps','8 Laps', '4 Laps', '3 Laps', '2 Laps', '1 Lap','Re-exposure'},'FontSize',12);  
   
end


