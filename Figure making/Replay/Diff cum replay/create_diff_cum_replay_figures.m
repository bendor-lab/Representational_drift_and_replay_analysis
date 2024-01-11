


function create_diff_cum_replay_figures

% PLOT DIFFERENCE IN CUMULATIVE REPLAY FOR TRACKS 1+3 VS 2+4
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Diff cumulative replay'
awake = openfig('Cumulative replay events diff between tracks -1  3  2  4during all sleep periods -awake.fig');
sleep = openfig('Cumulative replay events diff between tracks -1  3  2  4during all sleep periods -sleep.fig');

figs = [awake; sleep];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {1,1};
ax_destination = {2,1};

% output figure
axn = diff_cum_replay_1234_makeFigure;

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
     axn(a).FontSize = 14;
    if a == 1
        title(axn(a),'');
        ylabel(axn(a),'Cumulative sleep replay bias','FontSize',14)
        annotation('textbox',[0.16,0.89,0.05,0.1],'String',strcat('PRE'),'FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.25,0.89,0.05,0.1],'String',strcat('Rest 1'),'FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.48,0.89,0.05,0.1],'String',strcat('INTER'),'FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.69,0.89,0.05,0.1],'String',strcat('Rest 2'),'FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.83,0.89,0.05,0.1],'String',strcat('FINAL'),'FitBoxToText','on','EdgeColor','none','FontSize',17);
        
        annotation('textbox',[0.91,0.63,0.05,0.1],'String','T1+R-T1','FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.91,0.60,0.05,0.1],'String','T2+R-T2','FitBoxToText','on','EdgeColor','none','FontSize',17);
        
        for jj = 2:5
            l = findobj(axn(a),'type','line');
            set(l(jj),'LineWidth',2)
        end
       
    else
        title(axn(a),'');
        xlabel(axn(a),'Binned time (min)','FontSize',14);
        ylabel(axn(a),'Cumulative rest replay bias','FontSize',14)
        annotation('textbox',[0.91,0.285,0.05,0.1],'String','T1+R-T1','FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.91,0.25,0.05,0.1],'String','T2+R-T2','FitBoxToText','on','EdgeColor','none','FontSize',17);
        
        for jj = 2:5
            l = findobj(axn(a),'type','line');
            set(l(jj),'LineWidth',2)
        end
        
    end
end

% if you used 'plot'
l = findobj(axn(a),'type','line');
set(l(3),'LineWidth',2)
% OR if you're only changing markers in one axis
l.MarkerSize = 5;

close sleep
close awake
save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis',[]);

%%%%%%%%%%%%%%%%%%%%%% 
%PLOT REPLAY DURING INTER SLEEP

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Diff cumulative replay'
sleep_12 = openfig('Cumulative replay events difference between tracks -1  2 during INTER and FINAL sleep -sleep.fig');
awake_12 = openfig('Cumulative replay events difference between tracks -1  2 during INTER and FINAL sleep -awake.fig');
% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures'
axn = INTER_replay_makeFigure;

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Replay rate'
inter_bias = openfig('sleep Replay -  Difference in T1-T2 bias between sleep chunks during INTER -sleep.fig');
inter_30min = openfig('sleep Replay - Difference in rate replay within between sleep chunks in INTER -sleep.fig');

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Difference Awake replay during INTER sleep'
initial_diff_awake_sleep = openfig('INTER sleep difference in awake and sleep replay between tracks -1  2.fig');
initial_diff_awake = openfig('INTER sleep difference in awake replay between tracks -1  2');

figs = [sleep_12; awake_12;initial_diff_awake;initial_diff_awake_sleep;inter_bias;inter_30min];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {2,2,1,[1,2,3,4,5],1,1};
ax_destination = {1,2,3,[5,7,4,6,8],9,10};


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
        xlabel(axn(a),'Binned time (min)','FontSize',14)
        annotation('textbox',[0.25,0.61,0.05,0.1],'String','T1','FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.25,0.58,0.05,0.1],'String','T2','FitBoxToText','on','EdgeColor','none','FontSize',17);
        axn(a).FontSize = 14;
    elseif a == 2
        title(axn(a),'');
        annotation('textbox',[0.25,0.325,0.05,0.1],'String','T1','FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.25,0.295,0.05,0.1],'String','T2','FitBoxToText','on','EdgeColor','none','FontSize',17);
        ylabel(axn(a),'Cum. rest replay bias','FontSize',14)
        xlabel(axn(a),'Binned time (min)','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 3
        title(axn(a),'');
        ylabel(axn(a),'Cum. awake replay bias','FontSize',14)
        axn(a).FontSize = 14;
        xticks(axn(a),[0 25 50])
    elseif a == 5
        title(axn(a),'');
        ylabel(axn(a),'Cum. replay bias','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 4
        title(axn(a),'');
        ylabel(axn(a),'Cum replay bias','FontSize',14)
        xlabel(axn(a),'Binned Time (30s)','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 7
        title(axn(a),'');
        axn(a).FontSize = 14;
        ylabel(axn(a),'Cum. awake replay bias','FontSize',14)
    elseif a == 6
        title(axn(a),'');
        xlabel(axn(a),'Binned Time (30s)','FontSize',14)
        ylabel(axn(a),'Cum. rest replay bias','FontSize',14)
        axn(a).FontSize = 14;
        xticks(axn(a),[0 25 50])
    elseif a == 8
        title(axn(a),'');
        ylabel(axn(a),'Cum. rest replay bias','FontSize',14)
        xlabel(axn(a),'Binned Time (30s)','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 9
        title(axn(a),'');
        xlabel(axn(a),'Sleep replay bias (events/min) - 1st half ','FontSize',14)
        ylabel(axn(a),'Sleep replay bias (events/min) - 2nd half ','FontSize',14)
        axn(a).FontSize = 14;
        chil = axn(a).Children;
        chil(2).XData = [-1 1];
        chil(1).YData = [-1 1];
        chil(3).XData = [-1 1];
        chil(3).YData = [-1 1];
    elseif a == 10
        title(axn(a),'');
        xlabel(axn(a),'T1 replay rate (events/min)','FontSize',14)
        ylabel(axn(a),'T2 replay rate (events/min)','FontSize',14)
        axn(a).FontSize = 14;
        xlim(axn(a),[-0.5 1]); xticks(axn(a),-0.5:0.5:1);
        ylim(axn(a),[-0.5 0.6]);
        chil = axn(a).Children;
        chil(2).XData = [-0.5 1];
        chil(1).YData = [-0.5 0.6];
    end
end
%%
close sleep_12
close awake_12
close initial_diff_awake
close initial_diff_awake_sleep
close inter_bias
close inter_30min
save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis',[]);


end