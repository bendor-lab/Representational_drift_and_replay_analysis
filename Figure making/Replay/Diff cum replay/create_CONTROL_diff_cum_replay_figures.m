


function create_CONTROL_diff_cum_replay_figures


%%%%%%%%%%%%%%%%%%%%%% 
%PLOT REPLAY DURING INTER SLEEP

% cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Spearman\figures\Diff cumulative replay'
% sleep_12 = openfig('Cumulative replay events difference between tracks -1  3  2  4 during INTER and FINAL sleep -sleep.fig');
% awake_12 = openfig('Cumulative replay events difference between tracks -1  3  2  4 during INTER and FINAL sleep -awake.fig');
%
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Spearman\figures\Diff cumulative replay'
sleep_12 = openfig('Cumulative replay events difference between tracks -1  3  2  4 during INTER and FINAL sleep -sleep.fig');
awake_12 = openfig('Cumulative replay events difference between tracks -1  3  2  4 during INTER and FINAL sleep -awake.fig');

% cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Controls\Combined figures\figures'
% control_sleep = openfig('control_sleep_cum_diff.fig');
% control_awake = openfig('control_rest_cum_diff.fig');
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures'
sleep = openfig('Sleep_replay_pval.fig');
rest = openfig('Rest_replay_pval.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures'
axn = CONTROL_diff_cum_replay_makeFigure;



%figs = [sleep_12; awake_12; control_sleep;control_awake];
figs = [sleep_12; awake_12;sleep];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[2,4],[2,4]};
ax_destination = {[1,3],[2,4]};


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
        title(axn(a),'');        
        ylabel(axn(a),'Cum. sleep replay bias','FontSize',14)
        xlabel(axn(a),'Binned time (min)','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 2
        title(axn(a),'');
        ylabel(axn(a),'Cum. rest replay bias','FontSize',14)
        xlabel(axn(a),'Binned time (min)','FontSize',14)
        xlim(axn(a),[0 110])
        xticks(axn(a),[0:20:125])
        axn(a).FontSize = 14;
    elseif a == 3
        title(axn(a),'');        
        ylabel(axn(a),'Cum. sleep replay bias','FontSize',14)
        xlabel(axn(a),'Binned time (min)','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 4
        title(axn(a),'');
        ylabel(axn(a),'Cum. rest replay bias','FontSize',14)
        xlabel(axn(a),'Binned time (min)','FontSize',14)
        xlim(axn(a),[0 35])
        xticks(axn(a),[0:10:40])
        axn(a).FontSize = 14;
    end
end
%%
close sleep_12
close awake_12

save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Spearman',[]);


end