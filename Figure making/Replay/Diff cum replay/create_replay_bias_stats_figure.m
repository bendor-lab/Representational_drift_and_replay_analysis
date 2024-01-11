
function create_replay_bias_stats_figure

%PLOT REPLAY BAYESIAN BIAS
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures'
sleep = openfig('Sleep_replay_pval.fig');
rest = openfig('Rest_replay_pval.fig');
% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures'
axn = replay_bias_stats_makeFigure;

figs = [sleep;rest];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2,4,5],[1,2,4,5]};
ax_destination = {[1,7,3,6],[2,8,4,5]};


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
    title(axn(a),''); 
    l = findobj(axn(a),'type','line');
    l(1).XData = [0 max(xlim(axn(a)))];
    plot(axn(a),[0 max(xlim(axn(a)))],[0.01 0.01],':','Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2)
    if a >= 1 & a <5   
        axn(a).FontSize = 14;            
        ylabel(axn(a),'p-value','FontSize',14)
    end
end


end