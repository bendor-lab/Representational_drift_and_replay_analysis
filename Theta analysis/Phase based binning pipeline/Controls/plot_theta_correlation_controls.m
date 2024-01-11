     

function plot_theta_correlation_controls

load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Controls\theta_correlation_controls.mat')


f = figure;
f.Name = 'Theta control correlations';

subplot(2,3,1)
%scatter(time_moving,track_scores_lap,20,[0.3 0.3 0.3],'filled')
scatter(lap_ID,track_scores_lap,20,[0.3 0.3 0.3],'filled')
%xlabel('Lap running time (s)','FontSize',14)
xlabel('Lap ID','FontSize',14)
ylabel('Lap score','FontSize',14)
xlim([0 16])
h = lsline;
h.Color = [0 .4 .6];
h.LineWidth = 2;

subplot(2,3,2)
scatter(track_num_seq_lap,track_scores_lap,20,[0.3 0.3 0.3],'filled')
xlabel('# Lap theta seq ','FontSize',14)
ylabel('Lap score','FontSize',14)
h = lsline;
h.Color = [0 .4 .6];
h.LineWidth = 2;

subplot(2,3,3)
scatter(lap_track_speed,track_scores_lap,20,[0.3 0.3 0.3],'filled')
xlabel('Lap running speed(cm/s)','FontSize',14)
ylabel('Lap score','FontSize',14)
h = lsline;
h.Color = [0 .4 .6];
h.LineWidth = 2;

subplot(2,3,4)
scatter(lap_dec_error,track_scores_lap,20,[0.3 0.3 0.3],'filled')
xlabel('Lap decoding error (cm)','FontSize',14)
ylabel('Lap score','FontSize',14)
h = lsline;
h.Color = [0 .4 .6];
h.LineWidth = 2;

subplot(2,3,5)
scatter(mean_lap_units,track_scores_lap,20,[0.3 0.3 0.3],'filled')
xlabel('mean # units ','FontSize',14)
ylabel('Lap score','FontSize',14)
h = lsline;
h.Color = [0 .4 .6];
h.LineWidth = 2;

subplot(2,3,6)
scatter(mean_lap_skaggs,track_scores_lap,20,[0.3 0.3 0.3],'filled')
xlabel('mean Skagg info','FontSize',14)
ylabel('Lap score','FontSize',14)
h = lsline;
h.Color = [0 .4 .6];
h.LineWidth = 2;

 
[rho,pval] = partialcorr([time_moving,track_scores_lap],[track_num_seq_lap,lap_track_speed,lap_dec_error,mean_lap_units]);
 [rho,pval] = corrcoef([time_moving,track_scores_lap])
 [rho,pval] = corrcoef([lap_ID,track_scores_lap])
 
 [rho,pval] = partialcorr([lap_ID,track_scores_lap],[track_num_seq_lap,lap_track_speed,lap_dec_error,mean_lap_units]);

save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Controls',[])



     
end