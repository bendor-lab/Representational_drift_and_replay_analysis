% Plot correlation of significant events with track decoding error 
% Compares both weighted correlation and spearman correlation

function plot_corr_decodingError_sigEvents

cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error');
load all_tracks_decoding_error.mat
cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Cell_count')
load track_cell_count.mat
cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis');
load proportion_sig_events.mat

PP = plotting_parameters;

% Reshape track decoding error into a column
reshaped_errors = [];
for i = 1 : length(all_tracks_decoding_error)
    reshaped_errors = [reshaped_errors; [all_tracks_decoding_error(i).T1,all_tracks_decoding_error(i).T2,all_tracks_decoding_error(i).T3,...
        all_tracks_decoding_error(i).T4]'];
end

%%%%%% Weighted Correlation
% Reshape strcture into one column
reshaped_wcorr = [];
for p = 1 : length(protocol_sig_events)
    for i = 1 : length(protocol_sig_events(p).events_wcorr)
        reshaped_wcorr = [reshaped_wcorr; [protocol_sig_events(p).events_wcorr(i,:)]'];
    end
end

f1=figure('units','normalized','outerposition',[0 0 1 1]);
f1.Name = 'Correlation significant events and track decoding error';
subplot(2,2,1)
c = 1;
for p = 1 : length(protocol_sig_events)
    scatter(reshaped_errors(c:c+15,1),reshaped_wcorr(c:c+15,1),50,PP.T2(p,:),'filled');
    hold on
    c = c + 16;
end

% Fit line
lm = fitlm(reshaped_errors,reshaped_wcorr,'linear');
[pp,~,~] = coefTest(lm);
annotation('textbox',[0.4,0.8,0.05,0.1],'String',strcat('p-val : ',num2str(pp)),'FitBoxToText','on','EdgeColor','none','FontSize',14);
x = [min(reshaped_errors) max(reshaped_errors)];
b = lm.Coefficients.Estimate';
hold on;
plot(x,polyval(fliplr(b),x),'LineStyle','-','LineWidth',2,'Color',[0.6 0.6 0.6])
    
xlabel('Track decoding error (cm)','FontSize',16)
ylabel('Proportion of significant replay events','FontSize',16)
title('Weighted Correlation - All tracks','FontSize',16)
ax = gca;
ax.FontSize = 16;

%%%%% Replot just with T2 values
% Reshape strcture into one column
T2_reshaped_wcorr = [];
for p = 1 : length(protocol_sig_events)
    T2_reshaped_wcorr = [T2_reshaped_wcorr; [protocol_sig_events(p).events_wcorr(:,2)]];
end

subplot(2,2,2)
c = 1;
for p = 1 : length(protocol_sig_events)
    scatter([all_tracks_decoding_error(c:c+3).T2],T2_reshaped_wcorr(c:c+3,1),50,PP.T2(p,:),'filled');
    hold on
    c = c + 4;
end


% Fit line
lm = fitlm([all_tracks_decoding_error.T2],T2_reshaped_wcorr,'linear');
[pp,~,~] = coefTest(lm);
annotation('textbox',[0.85,0.8,0.05,0.1],'String',strcat('p-val : ',num2str(pp)),'FitBoxToText','on','EdgeColor','none','FontSize',14);
x = [min(reshaped_errors) max(reshaped_errors)];
b = lm.Coefficients.Estimate';
hold on;
plot(x,polyval(fliplr(b),x),'LineStyle','-','LineWidth',2,'Color',[0.6 0.6 0.6])
    
xlabel('Track decoding error (cm)','FontSize',16)
ylabel('Proportion of significant replay events','FontSize',16)
title('Weighted Correlation -  Track 2','FontSize',16)
ax = gca;
ax.FontSize = 16;

%%%%%% Spearman Correlation
% Reshape strcture into one column
reshaped_spearman = [];
for p = 1 : length(protocol_sig_events)
    for i = 1 : length(protocol_sig_events(p).events_spearman)
        reshaped_spearman = [reshaped_spearman; [protocol_sig_events(p).events_spearman(i,:)]'];
    end
end

subplot(2,2,3)
c = 1;
for p = 1 : length(protocol_sig_events)
    scatter(reshaped_errors(c:c+15,1),reshaped_spearman(c:c+15,1),50,PP.T2(p,:),'filled');
    hold on
    c = c + 16;
end

% Fit line
lm = fitlm(reshaped_errors,reshaped_spearman,'linear');
[pp,~,~] = coefTest(lm);
annotation('textbox',[0.4,0.35,0.05,0.1],'String',strcat('p-val : ',num2str(pp)),'FitBoxToText','on','EdgeColor','none','FontSize',14);
x = [min(reshaped_errors) max(reshaped_errors)];
b = lm.Coefficients.Estimate';
hold on;
plot(x,polyval(fliplr(b),x),'LineStyle','-','LineWidth',2,'Color',[0.6 0.6 0.6])
    
xlabel('Track decoding error (cm)','FontSize',16)
ylabel('Proportion of significant replay events','FontSize',16)
title('Spearman Correlation - All tracks','FontSize',16)
ax = gca;
ax.FontSize = 16;

%%%%% Replot just with T2 values
% Reshape strcture into one column
T2_reshaped_spearman = [];
for p = 1 : length(protocol_sig_events)
    T2_reshaped_spearman = [T2_reshaped_spearman; [protocol_sig_events(p).events_spearman(:,2)]];
end

subplot(2,2,4)
c = 1;
for p = 1 : length(protocol_sig_events)
    scatter([all_tracks_decoding_error(c:c+3).T2],T2_reshaped_spearman(c:c+3,1),50,PP.T2(p,:),'filled');
    hold on
    c = c + 4;
end

% Fit line
lm = fitlm([all_tracks_decoding_error.T2],T2_reshaped_spearman,'linear');
[pp,~,~] = coefTest(lm);
annotation('textbox',[0.85,0.35,0.05,0.1],'String',strcat('p-val : ',num2str(pp)),'FitBoxToText','on','EdgeColor','none','FontSize',14);
x = [min(reshaped_errors) max(reshaped_errors)];
b = lm.Coefficients.Estimate';
hold on;
plot(x,polyval(fliplr(b),x),'LineStyle','-','LineWidth',2,'Color',[0.6 0.6 0.6])
    
xlabel('Track decoding error (cm)','FontSize',16)
ylabel('Proportion of significant replay events','FontSize',16)
title('Spearman Correlation -  Track 2','FontSize',16)
ax = gca;
ax.FontSize = 16;

%%% PLOT CORRELATIONS DECODING ERROR VS NUMBER OF CELLS IN TRACK
% Reshape strcture into one column
reshaped_num_cells = [];
for p = 1 : length(track_cell_count)
    for i = 1 : length(track_cell_count(p).BAYESIAN_good_cells)
        reshaped_num_cells = [reshaped_num_cells; [track_cell_count(p).BAYESIAN_good_cells(i,:)]'];
    end
end

f2 = figure;
f2.Name = 'Correlation track number of cells and track decoding error';
c = 1;
for p = 1 : length(track_cell_count)
    scatter(reshaped_errors(c:c+15,1),reshaped_num_cells(c:c+15,1),50,PP.T2(p,:),'filled');
    hold on
    c = c + 16;
end

% Fit line
lm = fitlm(reshaped_errors,reshaped_num_cells,'linear');
[pp,~,~] = coefTest(lm);
annotation('textbox',[0.4,0.8,0.05,0.1],'String',strcat('p-val : ',num2str(pp)),'FitBoxToText','on','EdgeColor','none','FontSize',14);
x = [min(reshaped_errors) max(reshaped_errors)];
b = lm.Coefficients.Estimate';
hold on;
plot(x,polyval(fliplr(b),x),'LineStyle','-','LineWidth',2,'Color',[0.6 0.6 0.6])
    
xlabel('Track decoding error (cm)','FontSize',16)
ylabel('Number of place cells','FontSize',16)
title('Correlation Track Num cells vs Track Decoding error','FontSize',16)
ax = gca;
ax.FontSize = 16;

end