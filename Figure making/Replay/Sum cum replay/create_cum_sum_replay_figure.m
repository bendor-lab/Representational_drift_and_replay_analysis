function create_cum_sum_replay_figure

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\combined figures'
axn = replay_cum_sum_makeFigure;

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Sum cumulative replay'
sleep = openfig('Cumulative replay events during all sleep periods -sleep.fig');
awake = openfig('Cumulative replay events during all sleep periods -awake.fig'); 

figs = [sleep; awake];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2,3,4],[1,2,3,4]};
ax_destination = {[1,3,5,7],[2,4,6,8]};


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
    
    if a == 1
        title(axn(a),'');
        ylabel(axn(a),'# cum events','FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 100])
    elseif a == 2
        title(axn(a),'');
        axn(a).FontSize = 14;
        ylim(axn(a),[0 60]);
    elseif a == 3
        title(axn(a),'');
        ylabel(axn(a),'# cum events','FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 100])
    elseif a == 4
        title(axn(a),'');
        axn(a).FontSize = 14;
        ylim(axn(a),[0 60])
    elseif a == 5
        title(axn(a),'');
        ylabel(axn(a),'# cum events','FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 100])
    elseif a == 6
        title(axn(a),'');
        axn(a).FontSize = 14;
        ylim(axn(a),[0 60])
    elseif a == 7
        title(axn(a),'');
        ylabel(axn(a),'# cum events','FontSize',14)
        xlabel(axn(a),'Time (min)','FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 100])
    elseif a == 8
        title(axn(a),'');
        xlabel(axn(a),'Time (min)','FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 60])
    end
end

%% SLEEP PROPORTION OF REPLAY CUM SUM

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\combined figures'
axn = proportion_replay_cum_sum_makeFigure;

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Sum cumulative replay'
sleep = openfig('Cumulative proportion  replay events during all sleep periods -sleep.fig');

figs = sleep;

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2,3,4]};
ax_destination = {[1,2,3,4]};


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
    
    if a == 1
        title(axn(a),'');
        ylabel(axn(a),{'Proportion cum.'; 'sig. events'},'FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 10])
    elseif a == 2
        title(axn(a),'');
        ylabel(axn(a),{'Proportion cum.'; 'sig. events'},'FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 10]);
    elseif a == 3
        title(axn(a),'');
        ylabel(axn(a),{'Proportion cum.'; 'sig. events'},'FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 10])
    elseif a == 4
        title(axn(a),'');
        ylabel(axn(a),{'Proportion cum.'; 'sig. events'},'FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 10])
    end
    [axn(a).Children(1:4).YData] = deal([0 10]);
end


%% REST PROPORTION OF REPLAY CUM SUM
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\combined figures'
axn = proportion_replay_cum_sum_makeFigure;

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Sum cumulative replay'
awake = openfig('Cumulative proportion replay events during all sleep periods -awake.fig'); 

figs = [awake];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2,3,4]};
ax_destination = {[1,2,3,4]};


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
    x2 = xlim(axn(a));
    x2 = x2(2);
    axn(a).xticks = [0 x2];
    if a == 1
        title(axn(a),'');
        ylabel(axn(a),{'Proportion cum.'; 'sig. events'},'FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 10])
    elseif a == 2
        title(axn(a),'');
        ylabel(axn(a),{'Proportion cum.'; 'sig. events'},'FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 10]);
    elseif a == 3
        title(axn(a),'');
        ylabel(axn(a),{'Proportion cum.'; 'sig. events'},'FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 10])
    elseif a == 4
        title(axn(a),'');
        ylabel(axn(a),{'Proportion cum.'; 'sig. events'},'FontSize',14)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 10])
        xticks(axn(a),[0:20:xlim(end)])
    end
    [axn(a).Children(1:4).YData] = deal([0 10]);
end

end

