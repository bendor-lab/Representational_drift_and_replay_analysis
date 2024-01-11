


function histogram_replay_figures

% PLOT RATE REPLAY FOR 1+3 vs 2+4
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Histogram num replay events'
histo = openfig('sum-Proportion of normalized replay events across time for all tracks -ALL.fig');

figs = [histo];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2,3,4,5]};
ax_destination = {[1,2,3,4,5]};

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures'
axn = histogram_replayEvents_makeFigure;

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
    ylim(axn(a),[0 0.025])
    if a < 5
        if a == 1
            xlim(axn(a),[0 340])
        elseif a == 2
            xlim(axn(a),[0 325])
        else
            xlim(axn(a),[0 350])
        end
        title(axn(a),'');
        axn(a).FontSize = 14;
        ob = findobj(axn(a),'type','line');
        for j = 4 :11
            set(ob(j),'LineWidth',1.5)
            ob(j).YData = [0 max(ylim(axn(a)))];
        end
        set(ob(1),'LineWidth',2)
        set(ob(1),'LineStyle','--')
        set(ob(2),'LineWidth',2)
        set(ob(2),'LineStyle','--')
        set(ob(3),'LineWidth',1.5)
        set(ob(12),'LineWidth',1.5)
    else
        xlim(axn(a),[0 325])
        title(axn(a),'');
        xlabel(axn(a),'Binned time (min)','FontSize',14)
        axn(a).FontSize = 14;
        ob = findobj(axn(a),'type','line');
        for j = 4 :11
            set(ob(j),'LineWidth',1.5)
            ob(j).YData = [0 max(ylim(axn(a)))];
        end
        set(ob(1),'LineWidth',1.5)
        set(ob(1),'LineStyle','--')
        set(ob(2),'LineWidth',1.5)
        set(ob(2),'LineStyle','--')
        set(ob(3),'LineWidth',1.5)
        set(ob(12),'LineWidth',1.5)
    end
end



save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures',[]);



end