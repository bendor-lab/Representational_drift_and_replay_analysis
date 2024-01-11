% PLOT SHUFFLE DISTRIBUTIONS FOR AVERAGE THETA SEQUENCES
%MH 2020
% INPUT:
% method: either 'quadrant_ratio' or 'weighted_corr'

function plot_average_thetaseq_shuffles(method)


sessions = data_folders;
session_names = fieldnames(sessions);
PP = plotting_parameters;
% yn34 = [280,260,240,220,200];
% yn84 = [110,100,90,80];
% yn123 = [80,70,60,50];
ynT1= [220,200,180,160,140];
ynR3 = [260,240,220,200,180];
ynR4 = [165,150,135,110,95];
yn8 = ones(1,4)*110;
yn4 = ones(1,4)*58;
yn3 = ones(1,4)*40;
yn2 = ones(1,4)*38;
yn1 = ones(1,4)*25;

j=1;

% Create figure
f1 = figure;
saxT21 = subplot(2,4,1);
saxT22 = subplot(2,4,2);
saxT23 = subplot(2,4,3);
saxT24 = subplot(2,4,4);
saxT28 = subplot(2,4,5);
saxT1 = subplot(2,4,6);
saxT3 = subplot(2,4,7);
saxT4 = subplot(2,4,8);


for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        tic
        
        load Theta\thetaseq_position_shuffle.mat
        load Theta\theta_sequence_quantification.mat
        load Theta\thetaSeq_PREspikeTrain_circ_shuffle.mat
        load Theta\thetaseq_phase_shuffle.mat
        
        
        for t = 1 : length(phase_shuffle.unidirectional)
            
            if t == 1
                axes(saxT1)
                yn = ynT1(p);
            elseif t == 3
                axes(saxT3)
                yn = ynR3(p);
            elseif t == 4
                axes(saxT4)
                yn = ynR4(p);
            end
            
            if t == 1 | t== 3
                if centered_averaged_thetaSeq.unidirectional(t).WC_theta_sig == 1
                    
                    %Plot just one shuffle distribution for each sig value,choosing one that is sig
                    [~,sig_shuffle] = min(centered_averaged_thetaSeq.unidirectional(t).WC_shuffles_pvals); %struct order: PRE,phase,position
                    if sig_shuffle == 1
                        [N,edges] = histcounts(PREspike_train_circ_shuffle_scores.unidirectional(t).(sprintf('%s',method)), 'Normalization','pdf');
                        limit = prctile([PREspike_train_circ_shuffle_scores.unidirectional(t).(sprintf('%s',method))],95);
                    elseif sig_shuffle == 2
                        [N,edges] = histcounts(phase_shuffle.unidirectional(t).(sprintf('%s',method)), 'Normalization','pdf');
                        limit = prctile([phase_shuffle.unidirectional(t).(sprintf('%s',method))],95);
                    elseif sig_shuffle == 3
                        [N,edges] = histcounts(position_shuffle.unidirectional(t).(sprintf('%s',method)), 'Normalization','pdf');
                        limit = prctile([position_shuffle.unidirectional(t).(sprintf('%s',method))],95);
                    end
                    edges = edges(2:end) - (edges(2)-edges(1))/2;
                    hold on
                    plot(edges, N,'Color',[0.7 0.7 0.7]); %plot shuffle
                    area(edges,N,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.9 0.9 0.9],'FaceAlpha',0.5,'EdgeAlpha',0.8)
                    axis tight
                    box off
                    hold on
                    plot(abs(centered_averaged_thetaSeq.unidirectional(t).(sprintf('%s',method))),yn,'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',PP.T1,'LineWidth',1.5)
                else
                    hold on
                    plot(abs(centered_averaged_thetaSeq.unidirectional(t).(sprintf('%s',method))),yn,'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1)
                end
                ax1 = gca;
                ylabel(ax1,'Histogram');
                title(ax1,['Track ' num2str(t)])
                ax1.FontSize = 10;
                
            end
            
            if t == 2 | t== 4
                if t == 2 && p == 1 %8 laps
                    axes(saxT28);
                    laps =8;
                    yn = yn8(s);
                elseif t == 2 && p == 2 % 4 laps
                    axes(saxT24);
                    laps =4;
                    yn = yn4(s);
                elseif t == 2 && p == 3 %3 laps
                    axes(saxT23);
                    laps =3;
                    yn = yn3(s);
                elseif t == 2 && p == 4 % 2 laps
                    axes(saxT22);
                    laps =2;
                    yn = yn2(s);
                elseif t == 2 && p == 5 % 1 lap
                    axes(saxT21);
                    laps =1;
                    yn = yn1(s);
                    xticks(0:0.02:max(xlim))
                end
                
                %Plot just one shuffle distribution for each sig value,
                %choosing one that is sig
                if centered_averaged_thetaSeq.unidirectional(t).WC_theta_sig == 1
                    [~,sig_shuffle] = min(centered_averaged_thetaSeq.unidirectional(t).WC_shuffles_pvals); %struct order: PRE,phase,position
                    if sig_shuffle == 1
                        [N,edges] = histcounts(PREspike_train_circ_shuffle_scores.unidirectional(t).(sprintf('%s',method)), 'Normalization','pdf');
                        limit = prctile([PREspike_train_circ_shuffle_scores.unidirectional(t).(sprintf('%s',method))],95);
                    elseif sig_shuffle == 2
                        [N,edges] = histcounts(phase_shuffle.unidirectional(t).(sprintf('%s',method)), 'Normalization','pdf');
                        limit = prctile([phase_shuffle.unidirectional(t).(sprintf('%s',method))],95);
                    elseif sig_shuffle == 3
                        [N,edges] = histcounts(position_shuffle.unidirectional(t).(sprintf('%s',method)), 'Normalization','pdf');
                        limit = prctile([position_shuffle.unidirectional(t).(sprintf('%s',method))],95);
                    end
                    edges = edges(2:end) - (edges(2)-edges(1))/2;
                    hold on
                    plot(edges, N,'Color',[0.7 0.7 0.7]);
                    area(edges,N,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.9 0.9 0.9],'FaceAlpha',0.5,'EdgeAlpha',1)
                    ax1 = gca;
                    curr_pos = ax1.Position;
                    axis tight
                    box off
                    hold on
                    plot(abs(centered_averaged_thetaSeq.unidirectional(t).(sprintf('%s',method))),yn,'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',PP.T2(p,:),'LineWidth',1.5)
                else
                    % Find non-sig shuffle
                    limit1 = prctile([PREspike_train_circ_shuffle_scores.unidirectional(t).(sprintf('%s',method))],95);
                    limit2 = prctile([phase_shuffle.unidirectional(t).(sprintf('%s',method))],95);
                    limit3 = prctile([position_shuffle.unidirectional(t).(sprintf('%s',method))],95);
                    [~,max_idx] = max([limit1 limit2 limit3]-abs(centered_averaged_thetaSeq.unidirectional(t).(sprintf('%s',method))));
                    if max_idx == 1
                        [N,edges] = histcounts(PREspike_train_circ_shuffle_scores.unidirectional(t).(sprintf('%s',method)), 'Normalization','pdf');
                        limit = limit1;
                    elseif max_idx == 2
                        [N,edges] = histcounts(phase_shuffle.unidirectional(t).(sprintf('%s',method)), 'Normalization','pdf');
                        limit = limit2;
                    else
                        [N,edges] = histcounts(position_shuffle.unidirectional(t).(sprintf('%s',method)), 'Normalization','pdf');
                        limit = limit3;
                    end
                    edges = edges(2:end) - (edges(2)-edges(1))/2;
                    plot(edges, N,'Color',[0.7 0.7 0.7])
                    area(edges,N,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.9 0.9 0.9],'FaceAlpha',0.5,'EdgeAlpha',1)
                    ax1 = gca;
                    curr_pos = ax1.Position;
                    axis tight
                    box off
                    hold on
                    plot(abs(centered_averaged_thetaSeq.unidirectional(t).(sprintf('%s',method))),yn,'o','MarkerFaceColor',PP.T2(p,:),'MarkerEdgeColor',PP.T2(p,:))
                    
                    % Plot in inset
                    hold on
                    if j == 4
                        ax(j) = axes('Position',[(curr_pos(1)+.03) (curr_pos(2)+.25) .05 .1]);
                    else
                        ax(j) = axes('Position',[(curr_pos(1)+.10) (curr_pos(2)+.25) .05 .1]);
                    end
                    plot(ax(j),edges,N,'Color',[0.7 0.7 0.7])
                    area(ax(j),edges,N,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.9 0.9 0.9],'FaceAlpha',0.5,'EdgeAlpha',1)
                    hold on
                    plot(ax(j),abs(centered_averaged_thetaSeq.unidirectional(t).(sprintf('%s',method))),yn,'o','MarkerFaceColor',PP.T2(p,:),'MarkerEdgeColor',PP.T2(p,:))
                    plot(ax(j),[limit limit],[min(ylim) max(ylim)],'k','LineWidth',1)
                    box off
                    set(ax(j) ,'Layer', 'Top')
                    uistack(ax(j), 'top')
                    j=j+1;
                end
                
                ylabel(ax1,'Histogram');
                title(ax1,['Track ' num2str(t) '-' num2str(laps) ' laps'])
                ax1.FontSize = 10;
                
            end
            
            
        end
    end
end

for j = 1 : length(ax)
    uistack(ax(j), 'top')
end


f1.Name = 'Shuffle distributions average theta sequences';
ax1 = f1.Children;
for i = 1 : length(ax1)
    ax1(i).FontSize = 15;
    ax1(i).XLim = [0 max(xlim(ax(i)))-.01];
end

end