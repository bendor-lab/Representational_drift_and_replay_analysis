% PLOT THETA SEQUENCE SCORES PER LAP
% MH 2020
% Load extracted averaged theta sequence scores per lap and session. Uses only unidirectional laps scores (so, merged both directions).
% Each subplot is a different quantification method, where x axis represent laps and y axis are scores
% Scores per lap are calculated using the whole session place fields.


function plot_lap_thetaseq(data_type,bayesian_control)

if strcmp(data_type,'main') & isempty(bayesian_control)
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Lap theta sequences\';
elseif strcmp(data_type,'speed')
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Speed\Lap theta sequences\';
elseif strcmp(data_type,'main') & ~isempty(bayesian_control)
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Lap theta sequences\Bayesian controls';
end
load([path 'lap_thetaseq.mat'])
PP = plotting_parameters;

t1_idx = find([lap_thetaseq(:).track] == 1 & [lap_thetaseq(:).dir] == 3); % track 1 unidirectional
t3_idx = find([lap_thetaseq(:).track] == 3 & [lap_thetaseq(:).dir] == 3); % track 3 unidirectional

%Separate T2 in protocols (num laps)
protocols = [8,4,3,2,1];
for p = 1 : length(protocols)
    t4_idx{p} = find([lap_thetaseq(:).protocol] == protocols(p) & [lap_thetaseq(:).track] == 4 & [lap_thetaseq(:).dir] == 3); % track 4 unidirectional
    t2_idx{p} = find([lap_thetaseq(:).protocol] == protocols(p) & [lap_thetaseq(:).track] == 2 & [lap_thetaseq(:).dir] == 3); % track 2 unidirectional
end
indices = [{t1_idx},t2_idx,{t3_idx},t4_idx];

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
f1.Name = 'Lap_thetaseq_scores';

col = {PP.T1,PP.T2(1,:),PP.T2(2,:),PP.T2(3,:),PP.T2(4,:),PP.T2(5,:),PP.T1,PP.T2(1,:),PP.T2(2,:),PP.T2(3,:),PP.T2(4,:),PP.T2(5,:)};
for t =  1 : length(indices) % for each track
    idx =  indices{t};
    track_struct = lap_thetaseq(idx);
    if t >= 2 & t <= 6
        num_laps = track_struct(1).protocol;
    else
        num_laps = 16;
    end
    
    % Get averaged scores for eah lap and for each quantification method
    for lap = 1 : num_laps 
        lap_struct = [track_struct(:).(strcat('Lap_',num2str(lap)))];
        all_wc_scores{lap} = [lap_struct(:).weighted_corr];
        all_qr_scores{lap} = [lap_struct(:).quadrant_ratio];  
        %all_lf_scores{lap} = [lap_struct(:).linear_slope];
        %slopes = [lap_struct(:).linear_slope];
        %all_lf_slopes{lap} = abs(slopes(2:2:end));
    end
    
    if t <= 6
        x = 1 : size(all_wc_scores,2);
    else
        x = (1 : size(all_wc_scores,2)) + 17;
    end
    
    ax(1) = subplot(2,1,1);
    mean_qr_scores = cellfun(@mean, all_qr_scores);
    std_qr_scores = cellfun(@std, all_qr_scores);
    hold on
    a(t) = plot(x, mean_qr_scores,'LineWidth',4,'Color',col{t});
    if t==6
            a(t) = plot(x, mean_qr_scores,'o','MarkerSize',5,'MarkerFaceColor',col{t},'MarkerEdgeColor',col{t});
    end
    % plot(x, mean_qr_scores,'o','MarkerEdgeColor',col{t},'MarkerFaceColor',col{t},'MarkerSize',4.5)
    % Add standard deviation as shade
    shade1 = mean_qr_scores + std_qr_scores;
    shade2 = mean_qr_scores - std_qr_scores;
    x2 = [x,fliplr(x)];
    inBetween = [shade1,fliplr(shade2)];
    h = fill(x2,inBetween,col{t});
    set(h,'facealpha',0.05,'LineStyle','none')
    title('Quadrant Ratio')
    ylabel('Scores')
    xlabel('Lap number')
    ax(1).FontSize = 14;
    
    
    ax(2) = subplot(2,1,2);
    mean_wc_scores = cellfun(@mean, all_wc_scores);
    std_wc_scores = cellfun(@std, all_wc_scores);
    hold on
    plot(x, mean_wc_scores,'LineWidth',3,'Color',col{t})
    if t==6
            a(t) = plot(x, mean_wc_scores,'o','MarkerSize',5,'MarkerFaceColor',col{t},'MarkerEdgeColor',col{t});
    end
    %errorbar(1:length(mean_wc_scores),mean_wc_scores,std_wc_scores,'Color',col{t},'CapSize',3,'LineWidth',1.5)
    % Add standard deviation as shade
    shade1 = mean_wc_scores + std_wc_scores;
    shade2 = mean_wc_scores - std_wc_scores;
    x2 = [x,fliplr(x)];
    inBetween = [shade1,fliplr(shade2)];
    h = fill(x2,inBetween,col{t});
    set(h,'facealpha',0.05,'LineStyle','none')
    title('Weighted Correlation')
    ylabel('Scores')
    xlabel('Lap number')
    ax(2).FontSize = 14;

%     ax(3) = subplot(2,2,3);
%     mean_lf_scores = cellfun(@mean, all_lf_scores);
%     std_lf_scores = cellfun(@std, all_lf_scores);
%     hold on
%     plot(x, mean_lf_scores,'LineWidth',3,'Color',col{t})
%     % Add standard deviation as shade
%     shade1 = mean_lf_scores + std_lf_scores;
%     shade2 = mean_lf_scores - std_lf_scores;
%     x2 = [x,fliplr(x)];
%     inBetween = [shade1,fliplr(shade2)];
%     h = fill(x2,inBetween,col{t});
%     set(h,'facealpha',0.05,'LineStyle','none')
%     title('Line Fitting')
%     xlabel('Lap number')
%     ylabel('Line fitting score')
%     ax(3).FontSize = 14;
%     
%     ax(4) = subplot(2,2,4);
%     mean_lf_slopes = cellfun(@mean, all_lf_slopes);
%     std_lf_slopes = cellfun(@std, all_lf_slopes);
%     hold on
%     plot(x, mean_lf_slopes,'LineWidth',3,'Color',col{t})
%     % Add standard deviation as shade
%     shade1 = mean_lf_slopes + std_lf_slopes;
%     shade2 = mean_lf_slopes - std_lf_slopes;
%     x2 = [x,fliplr(x)];
%     inBetween = [shade1,fliplr(shade2)];
%     h = fill(x2,inBetween,col{t});
%     set(h,'facealpha',0.05,'LineStyle','none')
%     title('Line Fitting')
%     xlabel('Lap number')
%     ylabel('Line fitting score')
%     ax(4).FontSize = 14;

    clear  all_wc_scores all_qr_scores 
end

a(13) = plot(ax(1),[17 17],[max(ylim(ax(1))) min(ylim(ax(1)))],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2);
plot(ax(2),[17 17],[max(ylim(ax(2))) min(ylim(ax(2)))],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2)
%plot(ax(3),[17 17],[max(ylim(ax(3))) min(ylim(ax(3)))],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2)
%plot(ax(4),[17 17],[max(ylim(ax(4))) min(ylim(ax(4)))],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2)

% legend([a(1) a(2) a(3) a(4) a(5) a(6) a(7) a(8) a(9) a(10) a(11) a(12) a(13)] ,{'T1-16 Laps','T2-8 Laps','T2-4 Laps', 'T2-3 Laps',...
%     'T2-2 Laps', 'T2-1 Laps','RT1','RT2-8 Laps','RT2-4 Laps', 'RT2-3 Laps', 'RT2-2 Laps', 'RT2-1 Laps','Re-exposure'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
legend([a(7) a(8) a(9) a(10) a(11) a(12) a(13)] ,{'T1-16 Laps','T2-8 Laps','T2-4 Laps', 'T2-3 Laps',...
    'T2-2 Laps', 'T2-1 Laps','Re-exposure'},'Position',[0.915 0.835 0.07 0.05],'FontSize',13)
     

% SAVE
save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Lap theta sequences\',[])

end