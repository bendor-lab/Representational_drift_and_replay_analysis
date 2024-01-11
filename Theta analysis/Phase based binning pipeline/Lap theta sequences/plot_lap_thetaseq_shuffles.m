function plot_lap_thetaseq_shuffles(test)


if test == 1
    load('Theta\lap_theta_sequence_quantification.mat')
    load('Theta\lap_thetaseq_phase_shuffle.mat')
    load('Theta\lap_thetaSeq_PREspikeTrain_circ_shuffle.mat')
    load('Theta\lap_thetaseq_position_shuffle.mat')
elseif test == 2
    load('Theta\lap_theta_sequence_quantification_SMOOTHED.mat')
    load('Theta\lap_thetaseq_phase_shuffle_SMOOTHED.mat')
    load('Theta\lap_thetaSeq_PREspikeTrain_circ_shuffle_SMOOTHED.mat')
    load('Theta\lap_thetaseq_position_shuffle_SMOOTHED.mat')
elseif test == 3
    load('Theta\\lap_theta_sequence_quantification_NEXTLAP.mat')
    load('Theta\lap_thetaseq_phase_shuffle_NEXTLAP.mat')
    load('Theta\lap_thetaSeq_PREspikeTrain_circ_shuffle_NEXTLAP.mat')
    load('Theta\lap_thetaseq_position_shuffle_NEXTLAP.mat')
end

for t = 1 : length(directional_lap_thetaseq)
    num_laps = size(lap_position_shuffle(t).Lap,2);
    if t ~= 1
        sp1 = 4;
        sp2 = 4;
    else
        sp1 = 2;
        sp2 = ceil(num_laps/2);
    end
    f1 = figure;
    f2 = figure;
    for lap = 1 : num_laps
        figure(f1)
        ax(lap*t) = subplot(sp1,sp2,lap);
        hold on
        %histogram(lap_phase_shuffle(t).Lap{1,lap}.unidirectional(t).quadrant_ratio,'EdgeColor',[0.4 0.4 0.4],'LineWidth',2.5,'DisplayStyle','stairs')
        histogram(lap_PREspike_train_circ_shuffle_scores(t).Lap{1,lap}.unidirectional.quadrant_ratio,'EdgeColor','b','LineWidth',2.5,'DisplayStyle','stairs')
        histogram(lap_position_shuffle(t).Lap{1,lap}.unidirectional(t).quadrant_ratio,'EdgeColor',[0 0.2 0],'LineWidth',2.5,'DisplayStyle','stairs')
        %limit1 = prctile([lap_phase_shuffle(t).Lap{1,lap}.unidirectional(t).quadrant_ratio],95);
        limit2 = prctile([lap_PREspike_train_circ_shuffle_scores(t).Lap{1,lap}.unidirectional.quadrant_ratio],95);
        limit3 = prctile([lap_position_shuffle(t).Lap{1,lap}.unidirectional(t).quadrant_ratio],95);
        axis tight
        plot([limit1 limit1],[min(ylim) max(ylim)],'k--','LineWidth',2)
        plot([limit2 limit2],[min(ylim) max(ylim)],'b--','LineWidth',2)
        plot([limit3 limit3],[min(ylim) max(ylim)],'g--','LineWidth',2)
        plot([abs(directional_lap_thetaseq(t).Lap{1,lap}.unidirectional(t).quadrant_ratio) abs(directional_lap_thetaseq(t).Lap{1,lap}.unidirectional(t).quadrant_ratio)],...
            [min(ylim) max(ylim)],'Color',[0.8 0 0],'LineWidth',3)
        ylabel('QR prob');
        title(['Track ' num2str(t) '- Lap '  num2str(lap)])
        ax(lap*t).FontSize = 10;
        
        figure(f2)
        ax(lap*t) = subplot(sp1,sp2,lap);
        hold on
        %histogram(lap_phase_shuffle(t).Lap{1,lap}.unidirectional(t).weighted_corr,'EdgeColor',[0.4 0.4 0.4],'LineWidth',2.5,'DisplayStyle','stairs')
        histogram(lap_PREspike_train_circ_shuffle_scores(t).Lap{1,lap}.unidirectional.weighted_corr,'EdgeColor','b','LineWidth',2.5,'DisplayStyle','stairs')
        histogram(lap_position_shuffle(t).Lap{1,lap}.unidirectional(t).weighted_corr,'EdgeColor',[0 0.2 0],'LineWidth',2.5,'DisplayStyle','stairs')
        %limit1 = prctile([lap_phase_shuffle(t).Lap{1,lap}.unidirectional(t).weighted_corr],95);
        limit2 = prctile([lap_PREspike_train_circ_shuffle_scores(t).Lap{1,lap}.unidirectional.weighted_corr],95);
        limit3 = prctile([lap_position_shuffle(t).Lap{1,lap}.unidirectional(t).weighted_corr],95);
        axis tight
        plot([limit1 limit1],[min(ylim) max(ylim)],'k--','LineWidth',2)
        plot([limit2 limit2],[min(ylim) max(ylim)],'b--','LineWidth',2)
        plot([limit3 limit3],[min(ylim) max(ylim)],'g--','LineWidth',2)
        plot([abs(directional_lap_thetaseq(t).Lap{1,lap}.unidirectional(t).weighted_corr) abs(directional_lap_thetaseq(t).Lap{1,lap}.unidirectional(t).weighted_corr)],...
            [min(ylim) max(ylim)],'Color',[0.8 0 0],'LineWidth',3)
        ylabel('WC prob');
        title(['Track ' num2str(t) '- Lap '  num2str(lap)])
        ax(lap*t).FontSize = 10;
    end
end



end