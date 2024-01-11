
function population_vector_analysis(computer,bayesian_option,plotting_option,save_option)
% Marta Huelin_January 2020
% Computes population vectors for each track exposure (taking raw firing rate from bayesian place fields) and computes correlation between
% different tracks. Plots correlations as cumulative frequency distribution plots and violin plots. Plots correlations for individual rats and protocols, all rats
% together for each protocol, and all rats and protocols together
% INPUT:
    % Computer: [] for running in normal CPU, 'GPU' for running in GPU computer
    % Bayesian_option: 1 for using bayesian place fields (x_bin = 10cm), 0 for using high resolution place fields (x_bin = 2cm)
    % Plotting_option: 1 for plotting, 0 for not
    % Save_option: 'Y' for saving the data, else for not saving


% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
else
    sessions = data_folders;
    session_names = fieldnames(sessions);
end

% Parameters
comparisons = {[1,3],[2,4],[1,2],[2,3],[1,4],[3,4]}; %track comparisons to test
PP = plotting_parameters;

for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    protocol(p).protocol_ID = cell2mat(session_names(p));
    
    f(p) = figure('units','normalized','outerposition',[0 0 1 1]);   
    f(p*10) = figure('units','normalized','outerposition',[0 0 1 1]);
    
    if bayesian_option == 1
        f(p).Name = strcat('Cummulative frequency distribution raw BAYESIAN PlFlds - ',cell2mat(session_names(p)));
        f(p*10).Name = strcat('Cummulative frequency distribution raw BAYESIAN PlFlds - Lap section - ',cell2mat(session_names(p)));
    else
        f(p).Name = strcat('Cummulative frequency distribution smooth PlFlds - ',cell2mat(session_names(p)));
        f(p*10).Name = strcat('Cummulative frequency distribution smooth PlFlds - Lap section - ',cell2mat(session_names(p)));
    end
                    
    for s = 1: length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        
        if exist(strcat(pwd,'\extracted_place_fields.mat'),'file')
            if bayesian_option == 1
                load('extracted_place_fields_BAYESIAN.mat')
                place_fields = place_fields_BAYESIAN;
                clear place_fields_BAYESIAN
            else
                load('extracted_place_fields.mat')
            end
            load('extracted_laps.mat')
            
            % Find max peak FR for each cell across tracks
            good_peakFR = []; max_peakFR = [];
            for t = 1 : length(place_fields.track)
                good_peakFR(t,:) = place_fields.track(t).peak(place_fields.good_place_cells); % finds peak FR for each cell across tracks
            end
            max_peakFR = max(good_peakFR,[],1); %max peak FR per cell between all the tracks
            
            % Create a normalized matrix for each track
            track = [];
            for t = 1 : length(place_fields.track)
                if bayesian_option == 1
                    good_ratemaps = place_fields.track(t).raw(place_fields.good_place_cells); % finds sorted ratemaps of good cells across all tracks
                else
                    good_ratemaps = place_fields.track(t).smooth(place_fields.good_place_cells); % finds sorted ratemaps of good cells across all tracks
                end
                ratemaps_matrix = reshape(cell2mat(good_ratemaps),[length(good_ratemaps),length(good_ratemaps{1,1})]); % create a matrix with sorted ratemaps
                track(t).norm_ratemaps = ratemaps_matrix./max_peakFR'; % normalize to the max peak firing rate of the pertinent cell
            end
            
            % Calculate cell population vector for each track comparison by correlating each position bin between tracks
            population_vector = []; ppvector_pval = [];
            for i = 1 : length(comparisons)
                comp = cell2mat(comparisons(i));
                for j = 1 : size(track(1).norm_ratemaps,2)
                    [rho,pval] = corr(track(comp(1)).norm_ratemaps(:,j), track(comp(2)).norm_ratemaps(:,j)); % Default is Pearson
                    population_vector(j,i) = rho; %each column is a comparison, each row a position bin
                    ppvector_pval(j,i) = pval;
                end
            end
            
            %save
            protocol(p).session(s).population_vector = population_vector;
            protocol(p).session(s).ppvector_pval = ppvector_pval;
            protocol(p).session(s).session_ID = folders(s);
            
            % STATS: Three ways:
            % One-way anova: find if there's a mean sig different between all groups. If so, run multiple comparisons to test all the possible combinations.
            % Use kruskal-Wallis test for non-parametric distributions (which is the case).
            % T-test: to compare the mean between pairs
            % Two-sample Kolmogorov-Smirnov test: for pair comparisons if you want to know how different is the shape of each
            % distribution line. If there's more than two samples, initially you can run Anderson-Darling test, which will tell you if there's any difference between all the lines.
            
            % Run Kruskal-Wallis
            sig_diff_idx = [];
            [pv,tbl,stats1]=kruskalwallis(population_vector,[],'off');
            protocol(p).session(s).KW_pv = pv;
            protocol(p).session(s).KW_table = tbl;
            if pv < 0.05
                [c,~,~,~] = multcompare(stats1,'ctype','dunn-sidak','Display','off'); % if anova pval is < 0.05, run multiple comparisons
                protocol(p).session(s).multiple_comparisons = c;
                sig_diff_idx = find(c(:,6)<0.05);
            end
            
            % FIGURE
            if plotting_option == 1

            figure(f(p))
            coord = {[0.05 0.55 0.25 0.4],[0.53 0.55 0.25 0.4],[0.05 0.05 0.25 0.4],[0.53 0.05 0.25 0.4],[0.33 0.55 0.17 0.4],[0.81 0.55 0.17 0.4],[0.33 0.05 0.17 0.4],[0.81 0.05 0.17 0.4]};
            ax(s) = axes('Position',cell2mat(coord(s)));
            hold on
            for i = 1 : length(comparisons)
                hh = cdfplot(population_vector(:,i));
                hh.Color = PP.comp(p).colorT(i,:);
                hh.LineWidth = 2;
            end
            xlabel('PV correlation','Fontsize',16); ylabel('Cumulative frequency','Fontsize',16)
            a = get(gca,'XTickLabel');
            set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
            box off; grid off; title('')
            
            ax(4+s) = axes('Position',cell2mat(coord(4+s)));
            
            [fighandle,Legendhandle,~,~,~] = violin(population_vector,'medc',[0.3 0.3 0.3]);
            for i = 1 : length(fighandle)
                fighandle(i).FaceColor = PP.comp(p).colorT(i,:);
                fighandle(i).EdgeColor = [0.2 0.2 0.2];
                fighandle(i).LineWidth = 1;
                fighandle(i).FaceAlpha = 0.8;
                %plot(i,population_vector(i,:),'o','MarkerEdgeColor',PP.comp(i).MarkerEdgeColor,'MarkerFaceColor',PP.comp(i).MarkerFaceColor)   %%plots data points
            end
            
            xticklabels({'T1 vs R-T1','T2 vs R-T2','T2 vs T1','T2 vs R-T1','R-T2 vs T1','R-T2 vs R-T1'})
            a = get(gca,'XTickLabel');
            set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
            Legendhandle.Visible = 'off';
            xtickangle(45)
            ylabel('PV correlation','Fontsize',16)
            box off;
            
            if ~isempty(sig_diff_idx)
                maxy = max(ylim);
                miny = min(ylim);
                ylim([miny,maxy+(length(sig_diff_idx)*0.17)])
                
                % Add sig bars
                for ii = 1 : length(sig_diff_idx)
                    dist = maxy+0.1 + (0.17*(ii-1));
                    dist_s = dist + 0.06;
                    hold on
                    plot([c(sig_diff_idx(ii),1) c(sig_diff_idx(ii),2)], [dist dist], '-k', 'LineWidth',1.7)
                    plot([(c(sig_diff_idx(ii),1)+c(sig_diff_idx(ii),2))/2 (c(sig_diff_idx(ii),1)+c(sig_diff_idx(ii),2))/2], [dist_s dist_s], '*k')
                end
            end
            
            end
            %%%%%%%%%%%% Repeat previous steps using only section of laps for T1
            
            % For better comparison, compare same amount of laps in T1 and T2. For that, extract the place fields for the pertinent amount of laps
            lap_start = 1;
            ID = cell2mat(protocol(p).session(s).session_ID);
            lap_end = str2num(ID(end)); %number of laps of this protocol
            section_place_fields = get_lap_place_fields(1,lap_start,lap_end,bayesian_option,'complete');
            
            % Replace peakFR of T1 by the lap section
            section_peakFT = good_peakFR;
            section_peakFT(1,:) = section_place_fields.peak(place_fields.good_place_cells); % finds peak FR for each cell across tracks
            section_maxPeakFr = max(section_peakFT,[],1); %max peak FR per cell between all the tracks
            
            % Create a normalized matrix for each track
            track_section = [];
            for t = 1 : length(place_fields.track)
                if t ==1
                    if bayesian_option == 1
                        good_ratemaps = section_place_fields.raw(place_fields.good_place_cells); % finds sorted ratemaps of good cells across all tracks
                    else
                        good_ratemaps = section_place_fields.smooth(place_fields.good_place_cells); % finds sorted ratemaps of good cells across all tracks
                    end
                else
                    if bayesian_option == 1
                        good_ratemaps = place_fields.track(t).raw(place_fields.good_place_cells); % finds sorted ratemaps of good cells across all tracks
                    else
                        good_ratemaps = place_fields.track(t).smooth(place_fields.good_place_cells); % finds sorted ratemaps of good cells across all tracks
                    end
                end
                ratemaps_matrix = reshape(cell2mat(good_ratemaps),[length(good_ratemaps),length(good_ratemaps{1,1})]); % create a matrix with sorted ratemaps
                track_section(t).norm_ratemaps = ratemaps_matrix./section_maxPeakFr'; % normalize to the max peak firing rate of the pertinent cell
            end
            
            % Calculate cell population vector for each track comparison by correlating each position bin between tracks
            section_population_vector = []; section_ppvector_pval = [];
            for i = 1 : length(comparisons)-3 %only run first 3 comparisons
                comp = cell2mat(comparisons(i));
                for j = 1 : size(track_section(1).norm_ratemaps,2)
                    [rho,pval] = corr(track_section(comp(1)).norm_ratemaps(:,j), track_section(comp(2)).norm_ratemaps(:,j));
                    section_population_vector(j,i) = rho; % columns = comparisons; rows = position bins
                    section_ppvector_pval(j,i) = pval;
                end
            end
            
            % Run Kruskal-Wallis
            sig_diff_idx = [];
            [pv1,tbl2,stats2] = kruskalwallis(section_population_vector,[],'off');
            protocol(p).session(s).section_KW_pv = pv1;
            protocol(p).session(s).section_KW_table = tbl2;
            if pv1 < 0.05
                [s_c,~,~,~] = multcompare(stats2,'ctype','dunn-sidak','Display','off'); % if anova pval is < 0.05, run multiple comparisons
                protocol(p).session(s).section_multiple_comparisons = s_c;
                sig_diff_idx = find(s_c(:,6)<0.05);
            end
            
            %save
            protocol(p).session(s).section_population_vector = section_population_vector;
            protocol(p).session(s).section_ppvector_pval = section_ppvector_pval;
            
            % FIGURE
            if plotting_option == 1

            figure(f(p*10))
            coord = {[0.05 0.55 0.25 0.4],[0.53 0.55 0.25 0.4],[0.05 0.05 0.25 0.4],[0.53 0.05 0.25 0.4],[0.33 0.55 0.17 0.4],[0.81 0.55 0.17 0.4],[0.33 0.05 0.17 0.4],[0.81 0.05 0.17 0.4]};
            ax(s) = axes('Position',cell2mat(coord(s)));
            hold on
            for i = 1 : length(comparisons)-3
                hh = cdfplot(section_population_vector(:,i));
                hh.Color = PP.comp(p).colorT(i,:);
                hh.LineWidth = 2;
            end
            xlabel('PV correlation','Fontsize',16); ylabel('Cumulative frequency','Fontsize',16)
            a = get(gca,'XTickLabel');
            set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
            box off; grid off; title('')
            
            ax(4+s) = axes('Position',cell2mat(coord(4+s)));
            
            [fighandle,Legendhandle,~,~,~] = violin(section_population_vector,'medc',[0.3 0.3 0.3]);
            for i = 1 : length(fighandle)
                fighandle(i).FaceColor = PP.comp(p).colorT(i,:);
                fighandle(i).EdgeColor = [0.2 0.2 0.2];
                fighandle(i).LineWidth = 1;
                fighandle(i).FaceAlpha = 0.8;
                %plot(i,population_vector(i,:),'o','MarkerEdgeColor',PP.comp(i).MarkerEdgeColor,'MarkerFaceColor',PP.comp(i).MarkerFaceColor)   %%plots data points
            end
            
            xticks([1:1:size(section_population_vector,2)])
            xticklabels({'T1 vs T1-R','T2 vs T2-R','T2 vs T1'})
            a = get(gca,'XTickLabel');
            set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
            Legendhandle.Visible = 'off';
            xtickangle(45)
            ylabel('PV correlation','Fontsize',16)
            box off;
            
            if ~isempty(sig_diff_idx)
                maxy = max(ylim);
                miny = min(ylim);
                ylim([miny,maxy+(length(sig_diff_idx)*0.17)])
                
                % Add sig bars
                for ii = 1 : length(sig_diff_idx)
                    dist = maxy+0.1 + (0.17*(ii-1));
                    dist_s = dist + 0.06;
                    hold on
                    plot([s_c(sig_diff_idx(ii),1) s_c(sig_diff_idx(ii),2)], [dist dist], '-k', 'LineWidth',1.7)
                    plot([(s_c(sig_diff_idx(ii),1)+s_c(sig_diff_idx(ii),2))/2 (s_c(sig_diff_idx(ii),1)+s_c(sig_diff_idx(ii),2))/2], [dist_s dist_s], '*k')
                end
            end
            end
        end
    end
    
    % Add information to figures once all subplots are done
    if  plotting_option == 1
        figure(f(p))
        s_name = cell2mat(session_names(p));
        s_name(strfind(s_name,'_')) = '-';
        annotation('textbox',[0.5, 0.9, 0.1, 0.1],'String',(strcat('Cummulative frequency distribution - ',s_name)),'EdgeColor', 'none','HorizontalAlignment', 'center','FontSize',14);
        figure(f(p*10))
        annotation('textbox',[0.5, 0.9, 0.1, 0.1],'String',(strcat('Cummulative frequency distribution - Lap Section - ',s_name)),'EdgeColor', 'none','HorizontalAlignment', 'center','FontSize',14);
    end
    %%%%%%%%% Now, for each protocol, concatenate all rats population vectors together
    
    all_PPvectors = [];   all_section_PPvectors = [];
    for jj = 1 : length(protocol(p).session)
        all_PPvectors = [all_PPvectors; protocol(p).session(jj).population_vector];
        all_section_PPvectors = [all_section_PPvectors; protocol(p).session(jj).section_population_vector];
    end
    protocol(p).all_PPvectors = all_PPvectors;
    protocol(p).all_section_PPvectors = all_section_PPvectors;
    
    % Run Kruskal-Wallis
    all_sig_diff_idx = []; sig_diff_idx= [];
    [pv3,tbl3,stats3] = kruskalwallis(all_PPvectors,[],'off');
    [pv4,tbl4,stats4] = kruskalwallis(all_section_PPvectors,[],'off');
    protocol(p).KW_pv = pv3;
    protocol(p).KW_table = tbl3;
    protocol(p).section_KW_pv = pv4;
    protocol(p).section_KW_table = tbl4;
    if pv3 < 0.05
        [all_c,~,~,~] = multcompare(stats3,'ctype','dunn-sidak','Display','off'); % if anova pval is < 0.05, run multiple comparisons
        protocol(p).all_multiple_comparisons = all_c;
        all_sig_diff_idx = find(all_c(:,6)<0.05);
    end
    if pv4 < 0.05
        [all_s_c,~,~,~] = multcompare(stats4,'ctype','dunn-sidak','Display','off'); % if anova pval is < 0.05, run multiple comparisons
        protocol(p).all_section_multiple_comparisons = all_s_c;
        sig_diff_idx = find(all_s_c(:,6)<0.05);
    end
    
    if plotting_option == 1
    
    f(p*10) = figure('units','normalized','outerposition',[0 0 1 1]);
    if bayesian_option == 1
        f(p*10).Name =  strcat('Cummulative frequency distribution raw BAYESIAN PlFlds - ALL RATS - ',cell2mat(session_names(p)));
    else
        f(p*10).Name =  strcat('Cummulative frequency distribution smooth PlFlds - ALL RATS - ',cell2mat(session_names(p)));
    end
    coord = {[0.05 0.55 0.40 0.38],[0.05 0.1 0.40 0.38],[0.50 0.55 0.40 0.38],[0.5 0.1 0.40 0.38]};
    ax(1) = axes('Position',cell2mat(coord(1)));
        hold on
        for i = 1 : length(comparisons)
            hh = cdfplot(all_PPvectors(:,i));
            hh.Color =  PP.comp(p).colorT(i,:);
            hh.LineWidth = 2;
        end
        xlabel('PV correlation','Fontsize',16); ylabel('Cumulative frequency','Fontsize',16)
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
        box off; grid off; title('')
    
    ax(2) = axes('Position',cell2mat(coord(2)));
        [fighandle,Legendhandle,~,~,~] = violin(all_PPvectors,'medc',[0.3 0.3 0.3]);
        for i = 1 : length(fighandle)
            fighandle(i).FaceColor =  PP.comp(p).colorT(i,:);
            fighandle(i).EdgeColor = [0.2 0.2 0.2];
            fighandle(i).LineWidth = 1;
            fighandle(i).FaceAlpha = 0.8;
            %plot(i,population_vector(i,:),'o','MarkerEdgeColor',PP.comp(i).MarkerEdgeColor,'MarkerFaceColor',PP.comp(i).MarkerFaceColor)   %%plots data points
        end
        xticks([1:1:size(all_PPvectors,2)])
        xticklabels({'T1 vs T1-R','T2 vs T2-R','T2 vs T1','T2 vs T1-R','T2-R vs T1','T2-R vs T1-R'})
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
        Legendhandle.Visible = 'off';
        xtickangle(45)
        ylabel('PV correlation','Fontsize',16)
        box off;

        if ~isempty(all_sig_diff_idx)
            maxy = max(ylim);
            miny = min(ylim);
            ylim([miny,maxy+(length(all_sig_diff_idx)*0.17)])
            % Add sig bars
            for ii = 1 : length(all_sig_diff_idx)
                dist = maxy+0.1 + (0.17*(ii-1));
                dist_s = dist + 0.06;
                hold on
                plot([all_c(all_sig_diff_idx(ii),1) all_c(all_sig_diff_idx(ii),2)], [dist dist], '-k', 'LineWidth',1.7)
                plot([(all_c(all_sig_diff_idx(ii),1)+all_c(all_sig_diff_idx(ii),2))/2 (all_c(all_sig_diff_idx(ii),1)+all_c(all_sig_diff_idx(ii),2))/2], [dist_s dist_s], '*k')
            end
        end
    
    ax(3) = axes('Position',cell2mat(coord(3)));
        hold on
        for i = 1 : length(comparisons)-3
            hh = cdfplot(all_section_PPvectors(:,i));
            hh.Color =  PP.comp(p).colorT(i,:);
            hh.LineWidth = 2;
        end
        xlabel('PV correlation','Fontsize',16); ylabel('Cumulative frequency','Fontsize',16)
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
        box off; grid off; title('')
        title('Same number of laps comparison')
    
    ax(4) = axes('Position',cell2mat(coord(4)));
        [fighandle1,Legendhandle,~,~,~] = violin(all_section_PPvectors,'medc',[0.3 0.3 0.3]);
        for i = 1 : length(fighandle1)
            fighandle1(i).FaceColor =  PP.comp(p).colorT(i,:);
            fighandle1(i).EdgeColor = [0.2 0.2 0.2];
            fighandle1(i).LineWidth = 1;
            fighandle1(i).FaceAlpha = 0.8;
            %plot(i,population_vector(i,:),'o','MarkerEdgeColor',PP.comp(i).MarkerEdgeColor,'MarkerFaceColor',PP.comp(i).MarkerFaceColor)   %%plots data points
        end
        xticks([1:1:size(all_section_PPvectors,2)])
        xticklabels({'T1 vs T1-R','T2 vs T2-R','T2 vs T1'})
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
        Legendhandle.Visible = 'off';
        xtickangle(45)
        ylabel('PV correlation','Fontsize',16)
        box off;

        if ~isempty(sig_diff_idx)
            maxy = max(ylim);
            miny = min(ylim);
            ylim([miny,maxy+(length(sig_diff_idx)*0.17)])
            % Add sig bars
            for ii = 1 : length(sig_diff_idx)
                dist = maxy+0.1 + (0.17*(ii-1));
                dist_s = dist + 0.06;
                hold on
                plot([all_s_c(sig_diff_idx(ii),1) all_s_c(sig_diff_idx(ii),2)], [dist dist], '-k', 'LineWidth',1.7)
                plot([(all_s_c(sig_diff_idx(ii),1)+all_s_c(sig_diff_idx(ii),2))/2 (all_s_c(sig_diff_idx(ii),1)+all_s_c(sig_diff_idx(ii),2))/2], [dist_s dist_s], '*k')
            end
        end
        
        legend([fighandle(1),fighandle(2),fighandle(3),fighandle(4),fighandle(5),fighandle(6)],{'16 Laps',strcat(s_name(end),' Laps'),'T2 vs T1','T2 vs T1-R','T2-R vs T1','T2-R vs T1-R'},...
            'Position',[0.92, 0.82, 0.05, 0.05], 'FontSize',16);
    end

end

% FIGURE: Plot 1st vs 2nd exposures for all protocols together. For 16 laps tracks (T1 vs T3), concatenate them together

% For each protocol, get population vectors for T1 vs T3 (2nd column) and T2 vs T4 (3rd column), for both all laps and sections
T2 = NaN(length(protocol(1).all_PPvectors(:,2)),length(protocol));
all_protocol_sections = NaN(length(protocol(1).all_PPvectors(:,2)),length(protocol));
T1=[]; 
ct = 1;
for jj = 1 : length(protocol)
    T1 = [T1; protocol(jj).all_PPvectors(:,1)]; % concatenate all 16runs together
    T2(1:length(protocol(jj).all_PPvectors(:,2)),jj) =  protocol(jj).all_PPvectors(:,2);
    all_protocol_sections(1:length(protocol(jj).all_section_PPvectors(:,2:3)),ct:ct+1) = protocol(jj).all_section_PPvectors(:,2:3);
    ct = ct+2;
end

% For all laps, merge T1 and T2 into one matrix
joined_matrix = NaN(size(T1,1),1+size(T2,2));
joined_matrix(:,1) = T1;
joined_matrix(1:size(T2,1),2:size(joined_matrix,2)) = T2;

% Run Kruskal-Wallis
all_sig_diff_idx = []; sig_diff_idx= [];
[pv3,tbl5,stats3] = kruskalwallis(joined_matrix,[],'off');
overallfig.KW_pv = pv3;
overallfig.KW_tble = tbl5;
if pv3 < 0.05
    [all_c,~,~,~] = multcompare(stats3,'ctype','dunn-sidak','Display','off'); % if anova pval is < 0.05, run multiple comparisons
    overallfig.multiple_comparisons = all_c;
    all_sig_diff_idx = find(all_c(:,6)<0.05);
end

f(p*100) = figure('units','normalized','outerposition',[0 0 1 1]);
if bayesian_option == 1
    f(p*100).Name = 'Cummulative frequency distribution raw BAYESIAN PlFlds - ALL RATS and ALL PROTOCOLS';
else
    f(p*100).Name = 'Cummulative frequency distribution smooth PlFlds - ALL RATS and ALL PROTOCOLS';
end

ax(1) = subplot(2,1,1);
    hold on
    for i = 1 : size(joined_matrix,2)
        hh = cdfplot(joined_matrix(:,i));
        hh.Color = PP.viridis_colormap(i,:);
        hh.LineWidth = 2;
    end
    xlabel('PV correlation','Fontsize',16); ylabel('Cumulative frequency','Fontsize',16)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
    box off; grid off; title('')
    legend({'T1 vs T-1R - 16 Laps','T2 vs T2-R - 8 Laps','T2 vs T2-R - 4 Laps','T2 vs T2-R - 3 Laps','T2 vs T2-R - 2 Laps','T2 vs T2-R- 1 Lap'},'Position',[0.92, 0.85, 0.05, 0.05],'FontSize',16);

ax(2) = subplot(2,1,2);
    [fighandle,Legendhandle,~,~,~] = violin(joined_matrix,'medc',[0.3 0.3 0.3]);
    hold on
    for i = 1 : size(joined_matrix,2)        
        fighandle(i).FaceColor = PP.viridis_colormap(i,:);
        fighandle(i).EdgeColor = [0.2 0.2 0.2];
        fighandle(i).LineWidth = 1;
        fighandle(i).FaceAlpha = 0.8;
        %plot(i,population_vector(i,:),'o','MarkerEdgeColor',PP.comp(i).MarkerEdgeColor,'MarkerFaceColor',PP.comp(i).MarkerFaceColor)   %%plots data points
    end
    xticks(1:1:length(comparisons))
    xticklabels({'T1 vs T1-R','T2 vs T2-R','T2 vs T2-R','T2 vs T2-R','T2 vs T2-R','T2 vs T2-R'})
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
    Legendhandle.Visible = 'off';
    xtickangle(45)
    ylabel('PV correlation','Fontsize',16)
    box off;
    
% 
% if ~isempty(all_sig_diff_idx)
%     maxy = max(ylim);
%     miny = min(ylim);
%     ylim([miny,maxy+(length(all_sig_diff_idx)*0.17)])
%     % Add sig bars
%     for ii = 1 : length(all_sig_diff_idx)
%         dist = maxy+0.1 + (0.17*(ii-1));
%         dist_s = dist + 0.06;
%         hold on
%         plot([all_c(all_sig_diff_idx(ii),1) all_c(all_sig_diff_idx(ii),2)], [dist dist], '-k', 'LineWidth',1.4)
%         plot([(all_c(all_sig_diff_idx(ii),1)+all_c(all_sig_diff_idx(ii),2))/2 (all_c(all_sig_diff_idx(ii),1)+all_c(all_sig_diff_idx(ii),2))/2], [dist_s dist_s], '*k')
%     end
% end

    legend([fighandle(1),fighandle(2),fighandle(3),fighandle(4),fighandle(5),fighandle(6),],{'16 Laps','8 Laps','4 Laps','3 Laps','2 Laps','1 Lap'},'Position',[0.92, 0.35, 0.05, 0.05],'Fontsize',16);

    save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\';
    if strcmp(save_option,'Y')
        if bayesian_option == 1
            save(sprintf('%s',save_path,'\population_vector_data_bayesian.mat'),'protocol','overallfig','-v7.3');
        else
            save(sprintf('%s',save_path,'\population_vector_data_excl.mat'),'protocol','overallfig','-v7.3');
        end
    end

end