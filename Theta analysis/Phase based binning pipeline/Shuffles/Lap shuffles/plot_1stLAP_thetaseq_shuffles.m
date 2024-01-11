% PLOT SHUFFLE DISTRIBUTIONS FOR AVERAGE THETA SEQUENCES
%MH 2020
% INPUT:
% method: either 'quadrant_ratio' or 'weighted_corr'

function plot_1stLAP_thetaseq_shuffles(method)


sessions = data_folders;
session_names = fieldnames(sessions);
PP = plotting_parameters;
 f1 = figure;
yn1 = [240,220,200,180,160];
yn34 = [280,260,240,220,200];
yn84 = [110,100,90,80];
yn123 = [80,70,60,50];

for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        
        
        load Theta\lap_theta_sequence_quantification_SMOOTHED.mat
        load Theta\lap_thetaseq_phase_shuffle_SMOOTHED.mat
        load Theta\lap_thetaseq_position_shuffle_SMOOTHED.mat
        load Theta\lap_thetaSeq_PREspikeTrain_circ_shuffle_SMOOTHED.mat
        
        for t = 1 : 2%length(phase_shuffle.unidirectional)
            
            if t == 1
                
                figure(f1)
                subplot(2,4,1);
                yn = yn1(p);
            elseif t == 3
                figure(f1)
                subplot(2,4,7);
                yn = yn34(p);
            elseif t == 4
                figure(f1)
                subplot(2,4,8);
                yn = yn34(p);
            end
            
           
            hold on
            
            if t ~= 2
            
            [N,edges] = histcounts(lap_phase_shuffle(t).Lap{1,1}.unidirectional.(sprintf('%s',method)), 'Normalization','pdf');
            edges = edges(2:end) - (edges(2)-edges(1))/2;
            plot(edges, N,'Color',[0.7 0.7 0.7]);
            area(edges,N,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.5,'EdgeAlpha',0.5)
            [N,edges] = histcounts(lap_PREspike_train_circ_shuffle_scores(t).Lap{1,1}.unidirectional.(sprintf('%s',method)), 'Normalization','pdf');
            edges = edges(2:end) - (edges(2)-edges(1))/2;
            plot(edges, N,'Color',[0.7 0.7 0.7]);
            area(edges,N,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.5,'EdgeAlpha',0.5)
            [N,edges] = histcounts(lap_position_shuffle(t).Lap{1,1}.unidirectional.(sprintf('%s',method)), 'Normalization','pdf');
            edges = edges(2:end) - (edges(2)-edges(1))/2;
            plot(edges, N,'Color',[0.7 0.7 0.7]);
            area(edges,N,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.5,'EdgeAlpha',0.5)

            limit1 = prctile([lap_phase_shuffle(t).Lap{1,1}.unidirectional.(sprintf('%s',method))],95);
            limit2 = prctile([lap_PREspike_train_circ_shuffle_scores(t).Lap{1,1}.unidirectional.(sprintf('%s',method))],95);
            limit3 = prctile([lap_position_shuffle(t).Lap{1,1}.unidirectional.(sprintf('%s',method))],95);
            axis tight
 
            if directional_lap_thetaseq(t).Lap{1,1}.unidirectional(t).WC_theta_sig == 1
                plot(abs(directional_lap_thetaseq(t).Lap{1,1}.unidirectional(t).(sprintf('%s',method))),yn,'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',PP.T1,'LineWidth',1.5)
            else 
                plot(abs(directional_lap_thetaseq(t).Lap{1,1}.unidirectional(t).(sprintf('%s',method))),yn,'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1)
            end
            ylabel('Histogram');
            title(['Track ' num2str(t)])
            ax = gca;
            ax.FontSize = 10;
            end
            
            if t == 2
                if p == 1 %8 laps
                    figure(f1)
                    subplot(2,4,2);
                    laps =8;
                    yn = yn84(s);
                elseif p == 2 % 4 laps
                    figure(f1)
                    subplot(2,4,3);
                    laps =4;
                    yn = yn84(s);
                elseif p == 3 %3 laps
                    figure(f1)
                    subplot(2,4,4);
                    laps =3;
                    yn = yn123(s);
                elseif p == 4 % 2 laps
                    figure(f1)
                    subplot(2,4,5);
                    laps =2;
                    yn = yn123(s);
                elseif p == 5 % 1 lap
                    figure(f1)
                    subplot(2,4,6);
                    laps =1;
                    yn = yn123(s);
                end
                hold on
             
                %[N,edges] = histcounts(lap_phase_shuffle(t).Lap{1,1}.unidirectional.(sprintf('%s',method)), 'Normalization','pdf');
                %edges = edges(2:end) - (edges(2)-edges(1))/2;
                %plot(edges, N,'Color',[0.7 0.7 0.7]);
                %area(edges,N,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.5,'EdgeAlpha',0.5)
                [N,edges] = histcounts(lap_PREspike_train_circ_shuffle_scores(t).Lap{1,1}.unidirectional.(sprintf('%s',method)), 'Normalization','pdf');
                edges = edges(2:end) - (edges(2)-edges(1))/2;
                plot(edges, N,'Color',[0.7 0.7 0.7]);
                area(edges,N,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.5,'EdgeAlpha',0.5)
                %[N,edges] = histcounts(lap_position_shuffle(t).Lap{1,1}.unidirectional.(sprintf('%s',method)), 'Normalization','pdf');
                %edges = edges(2:end) - (edges(2)-edges(1))/2;
                %plot(edges, N,'Color',[0.7 0.7 0.7]);
                %area(edges,N,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7],'FaceAlpha',0.5,'EdgeAlpha',0.5)

                %limit1 = prctile([lap_phase_shuffle(t).Lap{1,1}.unidirectional.(sprintf('%s',method))],95);
                limit2 = prctile([lap_PREspike_train_circ_shuffle_scores(t).Lap{1,1}.unidirectional.(sprintf('%s',method))],95);
                %limit3 = prctile([lap_position_shuffle(t).Lap{1,1}.unidirectional.(sprintf('%s',method))],95);
                axis tight
                if directional_lap_thetaseq(t).Lap{1,1}.unidirectional(t).WC_theta_sig == 1
                    plot(abs(directional_lap_thetaseq(t).Lap{1,1}.unidirectional(t).(sprintf('%s',method))),yn,'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',PP.T2(p,:),'LineWidth',1.5)
                else
                    plot(abs(directional_lap_thetaseq(t).Lap{1,1}.unidirectional(t).(sprintf('%s',method))),yn,'o','MarkerFaceColor',PP.T2(p,:),'MarkerEdgeColor',PP.T2(p,:))
                end

                ylabel('Histogram');
                title(['Track ' num2str(t) '-' num2str(laps) ' laps'])
                ax = gca;
                ax.FontSize = 10;
                
            end
            
            
        end
    end
end


f1.Name = 'Shuffle distributions lap theta sequences';
ax = f1.Children;
for i = 1 : length(ax)
    ax(i).FontSize = 15;
    ax(i).XLim = [0 max(xlim(ax(i)))];
end

sessions = data_folders;
session_names = fieldnames(sessions);
for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        load Theta\lap_theta_sequence_quantification_SMOOTHED.mat
        for t = 3 : 4
            if directional_lap_thetaseq(t).Lap{1,1}.unidirectional(t).WC_theta_sig == 1
                disp(1)
            end
        end
    end
end

end