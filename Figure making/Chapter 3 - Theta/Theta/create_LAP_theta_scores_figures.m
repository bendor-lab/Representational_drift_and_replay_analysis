
function create_LAP_theta_scores_figures

path ='X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Lap theta sequences\figures\Lap theta seq - same lap place fields';
QR = openfig([path '\Individual_Lap_thetaseq_scores_Quadrant Ratio.fig']);
WC = openfig([path '\Individual_Lap_thetaseq_scores_Weighted Correlation.fig']);
laps = openfig([path '\Figure_5.fig']);

figs = [WC;QR;laps];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1],[1],[1]};
ax_destination = {[1],[2],[3]};

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Combined figures'
axn = lap_thetaSeq_scores_makeFigure;

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
    title(axn(a),'');
    if a < 3
        xticks(axn(a),[2:2:16,18:2:32])
        xticklabels(axn(a),{2:2:16,2:2:16});
        xlabel(axn(a),'Laps','FontSize',12)
        ylabel(axn(a),'Scores','FontSize',12)
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'LineWidth',2.5)
        set(L,'MarkerSize',2)
        set(L(1),'LineWidth',2)
    end
    if a == 1
        ylim(axn(a),[-0.03 0.27])
        L(1).YData = [-0.03 0.27];
    elseif a == 2
        ylim(axn(a),[-0.12 0.2])
        L(1).YData = [-0.12 0.2];
    end
    if a == 3
        xticks(axn(a),[1:1:5,7:1:11])
        xticklabels(axn(a),{1:1:5,1:1:5});
        xlabel(axn(a),'Laps','FontSize',12)
        ylabel(axn(a),'Scores','FontSize',12)
    end
    
    axn(a).FontSize = 14;
end


save_all_figures(pwd,[])

end

