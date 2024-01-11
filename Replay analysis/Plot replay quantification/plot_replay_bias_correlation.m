% Plot replay bias correlation between INTER sleep and FINAL sleep
% MH, 05.2020
% Calculates bias T1 and T2 in INTER sleep and bias for R-T1 and R-T2 in FINAL sleep (and also in the first 30min of FINAL sleep)
% Then calculate correlation between INTER and FINAL sleep

function plot_replay_bias_correlation(epoch)

PP = plotting_parameters;
% Parameters
load('extracted_replay_plotting_info.mat')
load('extracted_time_periods_replay.mat')
if strcmp(epoch,'sleep')
    load('rate_sleep_replay.mat')
elseif strcmp(epoch,'awake')
    load('rate_awake_replay.mat')
end

% Extract number of INTER and FINAL sleep replay events for T1 and T2
for s = 1 : length(track_replay_events)
    INTER_T1(s) = length(track_replay_events(s).T1.(strcat('INTER_post_',epoch,'_cumulative_times')));
    INTER_T2(s) = length(track_replay_events(s).T2.(strcat('INTER_post_',epoch,'_cumulative_times')));
    FINAL_T3(s) = length(track_replay_events(s).T3.(strcat('FINAL_post_',epoch,'_cumulative_times')));
    FINAL_T4(s) = length(track_replay_events(s).T4.(strcat('FINAL_post_',epoch,'_cumulative_times')));
end    
% Calculate the difference between T1 and T2
diff_INTER_T1_T2 = INTER_T1 - INTER_T2;
diff_FINAL_T3_T4= FINAL_T3 - FINAL_T4;

% Extract number of FINAL sleep events for T3 and T4 during the first
% cummulative 30 min of sleep
% (doing the first 30min in case the rebound effect disapears after that)
FINAL_T3_30min = [];
FINAL_T4_30min = [];
for p = 1 : length(rate_replay(3).P) % for each protocol
        FINAL_T3_30min = [FINAL_T3_30min, [rate_replay(3).P(p).(strcat('FINAL_post_',epoch)).Rat_num_events{:,1}]];
        FINAL_T4_30min = [FINAL_T4_30min, [rate_replay(4).P(p).(strcat('FINAL_post_',epoch)).Rat_num_events{:,1}]];
end
diff_FINAL_T3_T4_30min = FINAL_T3_30min - FINAL_T4_30min;


% SCATTER PLOT
c = 1;
f1 = figure('units','normalized','outerposition',[0 0 1 1]);
f1.Name = [epoch ' replay - Difference replay bias INTER vs FINAL sleep'];
for ii = 1 : 5 % for each protocol
    s = scatter(diff_INTER_T1_T2(c:c+3),diff_FINAL_T3_T4(c:c+3),50,PP.T2(ii,:),'filled');
    hold on
    c = c+4;
end

% Fit line
lm = fitlm(diff_INTER_T1_T2,diff_FINAL_T3_T4,'linear');
[pp,~,~] = coefTest(lm);
annotation('textbox',[0.2,0.8,0.05,0.1],'String',strcat('p-val : ',num2str(pp)),'FitBoxToText','on','EdgeColor','none','FontSize',14);
x = [min(diff_INTER_T1_T2) max(diff_INTER_T1_T2)];
b = lm.Coefficients.Estimate';
hold on;
plot(x,polyval(fliplr(b),x),'LineStyle','-','LineWidth',2,'Color',[0.6 0.6 0.6])

line([min(xlim) max(xlim)],[0 0],'LineStyle','--','Color',[0.8 0.8 0.8],'LineWidth',1)
line([0 0],[min(ylim) max(ylim)],'LineStyle','--','Color',[0.8 0.8 0.8],'LineWidth',1)

xlabel('T1 vs T2 replay bias in INTER sleep','FontSize',16)
ylabel('R-T1 vs R-T2 replay bias in FINAL sleep','FontSize',16)
b = get(gca,'XTickLabel');
set(gca,'XTickLabel',b,'fontsize',16)
title([epoch ' replay - Difference replay bias INTER vs FINAL sleep'])

end
