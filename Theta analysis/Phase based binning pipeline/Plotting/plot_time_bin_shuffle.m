% PLOT TIME BIN SHUFFLES AGAINST REAL THETA SEQUENCE SCORE
% MH, 2020
% Plots both quadrant ratio and weighted correlation Loads shuffled distribution and plots it as histogram, and marks with a
% dashed line the 95% percentile. Marks with red solid line the real score for the average theta sequence
% INPUT - thresholded_decoded_thetaSeq_option: 1 if using theta sequences that have passed the position threshold (not happening neither at the
% start or end of track)


function plot_time_bin_shuffle(thresholded_decoded_thetaSeq_option)

cd([pwd '\Theta'])
if thresholded_decoded_thetaSeq_option == 1
    load averaged_thetaSeq_time_shuffle_thresholded.mat
    load theta_sequence_quantification_thresholded.mat
else
    load averaged_thetaSeq_time_shuffle.mat
    load theta_sequence_quantification.mat
end
cd ..

fields = fieldnames(centered_averaged_thetaSeq);
for i = 1 : length(fields)
    f(i) = figure;
    f(i*10) =  figure;
    f(i*100) =  figure;
end

for d = 1 : length(fields)
    
    thetaseq =  centered_averaged_thetaSeq.(strcat(fields{d}));
    shuffle =  time_shuffle.(strcat(fields{d}));

    for t = 1 : length(thetaseq)
        
        figure(f(d))
        
        ax(t) = subplot(2,2,t);
        histogram(shuffle(t).quadrant_ratio,'EdgeColor',[0.4 0.4 0.4],'FaceColor',[0.6 0.6 0.6])
        limit = prctile([shuffle(t).quadrant_ratio],95);
        hold on
        plot([limit limit],[min(ylim) max(ylim)],'k--','LineWidth',2)
        plot([abs(thetaseq(t).quadrant_ratio) abs(thetaseq(t).quadrant_ratio)],[min(ylim) max(ylim)],'Color',[0.8 0 0],'LineWidth',3)
        ylabel('Quadrant probability');
        title(['Quadrant ratio shuffle distribution - Track ' num2str(t)])
        ax(t).FontSize = 14;
    end
end



for d = 1 : length(fieldnames(centered_averaged_thetaSeq))
    
    thetaseq =  centered_averaged_thetaSeq.(strcat(fields{d}));
    shuffle =  time_shuffle.(strcat(fields{d}));

    for t = 1 : length(thetaseq)
      
        figure(f(d*10))

        ax(t) = subplot(2,2,t);
        histogram(shuffle(t).weighted_corr,'EdgeColor',[0.4 0.4 0.4],'FaceColor',[0.6 0.6 0.6])
        limit = prctile([shuffle(t).weighted_corr],95);
        hold on
        plot([limit limit],[min(ylim) max(ylim)],'k--','LineWidth',2)
        plot([thetaseq(t).weighted_corr thetaseq(t).weighted_corr],[min(ylim) max(ylim)],'Color',[0.8 0 0],'LineWidth',3)
        ylabel('Weighted correlation');
        title(['Weighted correlation shuffle distribution - Track ' num2str(t)])
        ax(t).FontSize = 14;
    end
end

for d = 1 : length(fieldnames(centered_averaged_thetaSeq))
    
    thetaseq =  centered_averaged_thetaSeq.(strcat(fields{d}));
    shuffle =  time_shuffle.(strcat(fields{d}));

    for t = 1 : length(thetaseq)
      
        figure(f(d*100))

        ax(t) = subplot(2,2,t);
        histogram(shuffle(t).linear_score,'EdgeColor',[0.4 0.4 0.4],'FaceColor',[0.6 0.6 0.6])
        limit = prctile([shuffle(t).linear_score],95);
        hold on
        plot([limit limit],[min(ylim) max(ylim)],'k--','LineWidth',2)
        plot([thetaseq(t).linear_score thetaseq(t).linear_score],[min(ylim) max(ylim)],'Color',[0.8 0 0],'LineWidth',3)
        ylabel('Linear fitting');
        title(['Linear fitting shuffle distribution - Track ' num2str(t)])
        ax(t).FontSize = 14;
    end
end



end