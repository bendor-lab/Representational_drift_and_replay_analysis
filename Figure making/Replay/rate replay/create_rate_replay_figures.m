


function create_rate_replay_figures

% PLOT RATE REPLAY FOR 1+3 vs 2+4
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Replay rate'
awake = openfig('awake Replay - Difference in T1+T3 vs T2+T4 replay rate during first 30min between PRE and INTER on periods of -awake.fig');
sleep = openfig('sleep Replay - Difference in T1+T3 vs T2+T4 replay rate during first 30min between PRE and INTER on periods of -sleep.fig' );

figs = [awake; sleep];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[2,4],[2,4]};
ax_destination = {[3,4],[1,2]};

% output figure
axn = rate_replay_1234_makeFigure;

for n = 1:size(figs,1) % for each figure
    % Get axes info of first fig
    axIn = findall(figs(n),'type','axes');
    axIn = flip(axIn);
    ax2copy = ax_to_copy{n};
    ax_dest = ax_destination{n};
    
    axIn = axIn(ax2copy);
    axOut = axn(ax_dest);
    
    for nax = 1:size(axIn,1)
        hIn  = allchild(axIn(nax));
        [~] = copyobj(hIn,axOut(nax));
    end
end

% Add information in each axes
for a = 1 : length(axn)
    ylim(axn(a),[-1 1])
    xticks(axn(a),[1 2 3 4 5])
    b = get(axn(a),'XTickLabel');
    set(axn(a),'XTickLabel',{'16x8','16x4','16x3','16x2','16x1'},'fontsize',14)
    if a == 1
        title(axn(a),'PRE sleep','Fontsize',18,'Position',[0.5 1]);
        ylabel(axn(a),'Bias in sleep replay rate (events/min)','FontSize',14)
    elseif a == 2
        title(axn(a),'INTER sleep','Fontsize',18,'Position',[0.5 1]);
        annotation('textbox',[0.9,0.7,0.05,0.1],'String','T1+R-T1','FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.9,0.47,0.05,0.1],'String','T2+R-T2','FitBoxToText','on','EdgeColor','none','FontSize',17);
        yticks(axn(a),'')
    elseif a == 3
        title(axn(a),'');
        ylabel(axn(a),'Bias in awake replay rate (events/min)','FontSize',14)
    elseif a == 4
        title(axn(a),'');
        yticks(axn(a),'')
        annotation('textbox',[0.9,0.32,0.05,0.1],'String','T1+R-T1','FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.9,0.11,0.05,0.1],'String','T2+R-T2','FitBoxToText','on','EdgeColor','none','FontSize',17);
    end
end

%%%%%%%%%%%%%%%%%%%%%% 
%PLOT REPLAY DURING FINAL SLEEP

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Diff cumulative replay'
sleep_34 = openfig('Cumulative replay events difference between tracks -3  4 during INTER and FINAL sleep -sleep.fig');
awake_34 = openfig('Cumulative replay events difference between tracks -3  4 during INTER and FINAL sleep -awake.fig');
% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures'
axn = FINAL_replay_makeFigure;

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Replay rate'
replay_rate_sleep = openfig('sleep Replay - Normalized replay rate during first 30min on periods of -sleep.fig');
replay_rate_awake = openfig('awake Replay - Normalized replay rate during first 30min on periods of -awake.fig');

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Sleep bias correlation'
bias_corr_sleep = openfig('Sleep replay - Difference replay bias INTER vs FINAL sleep.fig');
bias_corr_awake= openfig('awake replay - Difference replay bias INTER vs FINAL sleep.fig');


figs = [sleep_34; awake_34; replay_rate_sleep; replay_rate_awake; bias_corr_sleep; bias_corr_awake];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {4,4,[1,2,3],[1,2,3],1,1};
ax_destination = {1,2,[3,5,7],[4,6,8,],9,10};


for n = 1:size(figs,1) % for each figure
    % Get axes info of first fig
    axIn = findall(figs(n),'type','axes');
    axIn = flip(axIn);
    ax2copy = ax_to_copy{n};
    ax_dest = ax_destination{n};
    
    axIn = axIn(ax2copy);
    axOut = axn(ax_dest);
    
    for nax = 1: size(axIn,1)
        hIn  = allchild(axIn(nax));
        [~] = copyobj(hIn,axOut(nax));
    end
end

%% Add information in each axes
for a = 1 : length(axn)
    
    if a == 1
        title(axn(a),'INTER sleep','Fontsize',18,'Position',[0.5 1]);        
        ylabel(axn(a),'Cum. sleep replay bias','FontSize',14)
        annotation('textbox',[0.25,0.79,0.05,0.1],'String','R-T1','FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.25,0.76,0.05,0.1],'String','R-T2','FitBoxToText','on','EdgeColor','none','FontSize',17);
        axn(a).FontSize = 14;
    elseif a == 2
        title(axn(a),'');
        annotation('textbox',[0.25,0.41,0.05,0.1],'String','R-T1','FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.25,0.38,0.05,0.1],'String','R-T2','FitBoxToText','on','EdgeColor','none','FontSize',17);
        ylabel(axn(a),'Cum. rest replay bias','FontSize',14)
        xlabel(axn(a),'Binned time (min)','FontSize',14)
        axn(a).FontSize = 14;
        xlim(axn(a),[0 35])
    elseif a == 3
        title(axn(a),'Pre Sleep','Position',[0.5 1],'FontSize',14);
        ylh = ylabel(axn(a),'T1/T2 replay rate bias','FontSize',14);
        set(ylh,'Units','normalized','Position',[-0.1 0.5 0])
        axn(a).FontSize = 14;
        xticks(axn(a),[])
        ylim(axn(a),[-1 1])
    elseif a == 5
        title(axn(a),'Post Sleep 1','Position',[0.5 1],'FontSize',14);
        yhl= ylabel(axn(a),'T1/T2 replay rate bias','FontSize',14);
        axn(a).FontSize = 14;
        set(yhl,'Units','normalized','Position',[-0.12 0.5 0])
        xticks(axn(a),[])
        ylim(axn(a),[-1 1])
    elseif a == 7
       title(axn(a),'Post Sleep 2','Position',[0.5 1],'FontSize',14);
        yhl=ylabel(axn(a),'R-T1/R-T2 replay rate bias','FontSize',14);
        axn(a).FontSize = 14;
        set(yhl,'Units','normalized','Position',[-0.12 0.5 0])
        xticks(axn(a),[])
    elseif a == 4
        title(axn(a),'');
        ylim(axn(a),[-1 1])
        xticks(axn(a),[1 2 3 4 5])
        b = get(axn(a),'XTickLabel');
        set(axn(a),'XTickLabel',{'8','4','3','2','1'},'fontsize',14)
        ylh = ylabel(axn(a),'T1/T2 replay rate bias','FontSize',14);
        xlabel(axn(a),'Protocols','FontSize',14)
        set(ylh,'Units','normalized','Position',[-0.1 0.5 0])
        axn(a).FontSize = 14;
    elseif a == 6
        title(axn(a),'');
        ylim(axn(a),[-1 1])
        xticks(axn(a),[1 2 3 4 5])
        b = get(axn(a),'XTickLabel');
        set(axn(a),'XTickLabel',{'8','4','3','2','1'},'fontsize',14)
        ylh = ylabel(axn(a),'T1/T2 replay rate bias','FontSize',14);
        set(ylh,'Units','normalized','Position',[-0.1 0.5 0])
        xlabel(axn(a),'Protocols','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 8
        title(axn(a),'');
        ylim(axn(a),[-1 1])
        xticks(axn(a),[1 2 3 4 5])
        b = get(axn(a),'XTickLabel');
        set(axn(a),'XTickLabel',{'8','4','3','2','1'},'fontsize',14)
        ylh = ylabel(axn(a),'R-T1/R-T2 bias','FontSize',14);
        xlabel(axn(a),'Protocols','FontSize',14)
        set(ylh,'Units','normalized','Position',[-0.12 0.5 0])
        axn(a).FontSize = 14;
    elseif a == 9
        title(axn(a),'');
        xlabel(axn(a),'T1/T2 sleep replay bias - Sleep Post 1 ','FontSize',14)
        ylabel(axn(a),'R-T1/R-T2 sleep replay bias - Sleep Post 2','FontSize',14)
        axn(a).FontSize = 14;
        xlim(axn(a),[-40 max(xlim(axn(a)))]);
        xticks(axn(a),-40:20:100);
        ylim(axn(a),[-70 50]);
        chil = axn(a).Children;
        chil(1).YData = [-70 50];
        text(axn(a),79,5,0.7,'p-val: 0.011')
    elseif a == 10
        title(axn(a),'');
        xlabel(axn(a),'T1/T2 rest replay bias - Post Sleep 1 ','FontSize',14)
        ylabel(axn(a),'R-T1/R-T2 rest replay bias - Post Sleep 2','FontSize',14)
        axn(a).FontSize = 14;
        xticks(axn(a),-50:25:50);
        ylim(axn(a),[-30 30]);
        chil = axn(a).Children;
        chil(1).YData = [-30 30];
        text(axn(a),32,2,0.7,'p-val: 0.4617')
    end
end
%%

save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis',[]);





end