function plot_population_vector_shuffles(bayesian)
% Marta Huelin _ February 2020
% Plot comparison between global and rate remapping, and real data.


save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\';
cd(save_path)
load('global_shuffle_population_vector_data_excl.mat')
load('population_vector_data_excl.mat')

% Parameters
comparisons = {[1,3],[2,4],[1,2],[2,3],[1,4],[3,4]}; %track comparisons to test
PP = plotting_parameters;

for p = 1 : length(protocol_global_shuffle)
    
    f(p*10) = figure('units','normalized','outerposition',[0 0 1 1]);
    if bayesian == 1
        f(p*10).Name =  strcat('Shuffle vs Real Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS - ',protocol_global_shuffle(p).session_ID);
    else
        f(p*10).Name =  strcat('Shuffle vs Real Cummulative frequency distribution smooth PlFlds - ALL RATS - ',protocol_global_shuffle(p).session_ID);
    end
    coord = {[0.05 0.55 0.40 0.38],[0.05 0.1 0.40 0.38],[0.50 0.55 0.40 0.38],[0.5 0.1 0.40 0.38]};
    
    ax(1) = axes('Position',cell2mat(coord(1)));
    hold on
    for i = 1 : length(comparisons)
        hh = cdfplot(protocol_global_shuffle(p).all_PPvectors_globalRemap(:,i));
        hh.Color =  PP.comp(p).colorT(i,:);
        hh.LineWidth = 2;
    end
    hold on
    if exist('protocol_rate_shuffle','var')        
        for i = 1 : length(comparisons)
            hh = cdfplot(protocol_shuffle(p).all_PPvectors_rateRemap(:,i));
            hh.Color =  PP.comp(p).colorT(i,:);
            hh.LineWidth = 2;
        end
    end
    xlabel('PV correlation','FontSize',16); ylabel('Cumulative frequency','FontSize',16)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
    box off; grid off; title('')
    title('Shuffle raw laps comparison','FontSize',16)
    
    ax(2) = axes('Position',cell2mat(coord(2)));
     hold on
    for i = 1 : length(comparisons)-3
        hh = cdfplot(protocol_global_shuffle(p).all_section_PPvectors_globalRemap(:,i));
        hh.Color =  PP.comp(p).colorT(i,:);
        hh.LineWidth = 2;
    end
    hold on
    if exist('protocol_rate_shuffle','var')
        for i = 1 : length(comparisons)-3
            hh = cdfplot(protocol_shuffle(p).all_section_PPvectors_rateRemap(:,i));
            hh.Color =  PP.comp(p).colorT(i,:);
            hh.LineWidth = 2;
        end
    end
    xlabel('PV correlation','FontSize',16); ylabel('Cumulative frequency','FontSize',16)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
    box off; grid off; title('')
    title('Shuffle section laps comparison','FontSize',16)
   
    ax(3) = axes('Position',cell2mat(coord(3)));
      hold on
    for i = 1 : length(comparisons)
        hh = cdfplot(protocol(p).all_PPvectors(:,i));
        hh.Color =  PP.comp(p).colorT(i,:);
        hh.LineWidth = 2;
    end
    xlabel('PV correlation','FontSize',16); ylabel('Cumulative frequency','FontSize',16)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
    box off; grid off; title('')
    title('Raw laps comparison','FontSize',16)
    legend({'T1 vs T1-R','T2 vs T2-R','T2 vs T1','T2 vs T1-R','T2-R vs T1','T2-R vs T1-R'},'Position',[0.92, 0.82, 0.05, 0.05], 'FontSize',14,'box','off');
    
    ax(4) = axes('Position',cell2mat(coord(4))); 
    hold on
    for i = 1 : length(comparisons)-3
        hh = cdfplot(protocol(p).all_section_PPvectors(:,i));
        hh.Color =  PP.comp(p).colorT(i,:);
        hh.LineWidth = 2;
    end
    xlabel('PV correlation','FontSize',16); ylabel('Cumulative frequency','FontSize',16)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
    box off; grid off; title('')
    title('Section laps comparison','FontSize',16)
    legend({'T1 vs T1-R','T2 vs T2-R','T2 vs T1'},'Position',[0.92, 0.42, 0.05, 0.05], 'FontSize',14,'box','off');
    
 
%     legend([fighandle(1),fighandle(2),fighandle(3),fighandle(4),fighandle(5),fighandle(6)],{'16 Laps',strcat(s_name(end),' Laps'),'T2 vs T1','T2 vs T1-R','T2-R vs T1','T2-R vs T1-R'},...
%         'Position',[0.92, 0.82, 0.05, 0.05], 'FontSize',12);
end


% FIGURE: Plot 1st vs 2nd exposures for all protocols together. For 16 laps tracks (T1 vs T3), concatenate them together

% For each protocol, get population vectors for T1 vs T3 (2nd column) and T2 vs T4 (3rd column), for both all laps and sections
T1 = []; 
T1_ShGR = [];
T1_ShRR = [];
T2 = NaN(length(protocol(1).all_PPvectors(:,2)),length(protocol));
T2_ShGR = NaN(length(protocol_global_shuffle(1).all_PPvectors_globalRemap(:,2)),length(protocol));
for jj = 1 : length(protocol)
    T1 = [T1; protocol(jj).all_PPvectors(:,1)]; % concatenate all 16runs together
    T2(1:length(protocol(jj).all_PPvectors(:,2)),jj) =  protocol(jj).all_PPvectors(:,2); % all T2 tracks
    % For shuffles
    T1_ShGR = [T1_ShGR; protocol_global_shuffle(jj).all_PPvectors_globalRemap(:,1)]; % concatenate all 16runs together for shuffled vectors for global remapping
    T2_ShGR(1:length(protocol_global_shuffle(jj).all_PPvectors_globalRemap(:,2)),jj) = protocol_global_shuffle(jj).all_PPvectors_globalRemap(:,2);
    if exist('protocol_rate_shuffle','var')
        T1_ShRR = [T1_ShRR; protocol_rate_shuffle(jj).all_PPvectors_rateRemap(:,1)]; % concatenate all 16runs together for shuffled vectors for rate remapping
        T2_ShRR(:,jj) = protocol_rate_shuffle(jj).all_PPvectors_rateRemap(:,2);
    end
end

% For all laps, merge T1 and T2 for both real and shuffled data into one matrix
joined_real_shuffle_matrix = NaN(size(T1_ShGR,1),(1+size(T2,2))*3);
joined_real_shuffle_matrix(1:size(T1,1),1) = T1; joined_real_shuffle_matrix(:,2) = T1_ShGR;
if exist('protocol_rate_shuffle','var')    
    joined_real_shuffle_matrix(:,3) = T1_ShRR;
end

col = 4;
for i = 1 : size(T2,2)
    joined_real_shuffle_matrix(1:size(T2,1),col) = T2(:,i);
    joined_real_shuffle_matrix(1:size(T2_ShGR,1),col+1) = T2_ShGR(:,i);
    if exist('protocol_rate_shuffle','var')
        joined_real_shuffle_matrix(1:size(T2_ShRR,1),col+2) = T2_ShRR(:,i);
    end
    col= col +3;
end

% Create another matrix with just real data
joined_matrix = NaN(size(T1,1),1+size(T2,2));
joined_matrix(:,1) = T1;
joined_matrix(1:size(T2,1),2:size(joined_matrix,2)) = T2;

% Create another matrix with shuffle for global remapping at the end
joined_real_GR_matrix =  NaN(size(T1_ShGR,1),(1+size(T2,2))*2);
joined_real_GR_matrix(1:size(T1,1),1) = T1;
joined_real_GR_matrix(1:size(T2,1),2:size(T2,2)+1) = T2;
joined_real_GR_matrix(:,7) = T1_ShGR;
joined_real_GR_matrix(1:size(T2_ShGR,1),8:size(joined_real_GR_matrix,2)) = T2_ShGR;


% Run Kruskal-Wallis
all_sig_diff_idx = []; sig_diff_idx= [];
[pv3,~,stats3] = kruskalwallis(joined_real_GR_matrix,[],'off');
if pv3 < 0.05
    [all_c,~,~,~] = multcompare(stats3,'ctype','dunn-sidak','Display','off'); % if anova pval is < 0.05, run multiple comparisons
    protocol(p).all_multiple_comparisons = all_c;
    all_sig_diff_idx = find(all_c(:,6)<0.05);
end

f100= figure('units','normalized','outerposition',[0 0 1 1]);
if bayesian == 1
    f100.Name =  'Shuffle vs Real Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS - ALL PROTOCOLS';
else
    f100.Name =  'Shuffle vs Real Cummulative frequency distribution smooth PlFlds - ALL RATS - ALL PROTOCOLS';
end

ax(1) = subplot(2,1,1);
    hold on
    grayscale = gray(10);
    gr = 1;
    for i = 1 : size(joined_real_GR_matrix,2)
        hh = cdfplot(joined_real_GR_matrix(:,i));        
        hh.LineWidth = 2;
        if i < 7
            hh.Color = PP.viridis_colormap(i,:);
        else
            hh.Color = grayscale(gr+1,:);
            gr = gr +1;
        end      
    end
    
    xlabel('PV correlation','FontSize',16); ylabel('Cumulative frequency','FontSize',16)
    xlim([-.2 max(xlim)])
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16,'FontWeight','bold')
    box off; grid off; title('')
    legend({'T1 vs T-1R - 16 Laps','T2 vs T2-R - 8 Laps','T2 vs T2-R - 4 Laps','T2 vs T2-R - 3 Laps','T2 vs T2-R - 2 Laps','T2 vs T2-R- 1 Lap'},'Position',[0.92, 0.85, 0.05, 0.05],'FontSize',12,'box','off');

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
    ylabel('PV correlation','FontSize',16)
    box off;
    
    legend([fighandle(1),fighandle(2),fighandle(3),fighandle(4),fighandle(5),fighandle(6),],{'16 Laps','8 Laps','4 Laps','3 Laps','2 Laps','1 Lap'},'Position',[0.92, 0.35, 0.05, 0.05],'FontSize',14);




end 