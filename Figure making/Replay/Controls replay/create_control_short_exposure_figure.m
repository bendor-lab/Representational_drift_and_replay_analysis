
function create_control_short_exposure_figure

%PLOT REPLAY BAYESIAN BIAS
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Controls comparion'
all = openfig('Cntrl  vs Real - Mean number of INTER events per protocol.fig');
lap = openfig('One_lap - Proportio and mean number of INTER events per protocol.fig');
% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures'
axn = Short_exposure_controls_makeFigure;

figs = [all;lap];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[3],[5,6]};
ax_destination = {[1],[2,3]};


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
    if a == 1
        xticks(axn(a),[])
        ylabel(axn(a),'Number replay events','FontSize',14)        
        axn(a).FontSize = 14;
    elseif a == 2
        ylabel(axn(a),'Proportion sig.events','FontSize',14)    
        axn(a).FontSize = 14;
        xticks(axn(a),[3:18])
        xticklabels(axn(a),[1:16])        
    else 
        ylabel(axn(a),'Number replay events','FontSize',14)        
        axn(a).FontSize = 14;        
        xlim(axn(a),[0 16])
        ylim(axn(a),[0 125])            
end


end