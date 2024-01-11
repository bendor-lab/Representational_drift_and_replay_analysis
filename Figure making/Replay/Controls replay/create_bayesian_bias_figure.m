
function create_bayesian_bias_figure

%PLOT REPLAY BAYESIAN BIAS
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures'\'Controls comparion'
inter = openfig('Bayesian Bias PRE vs INTER per protocol2.fig');
final = openfig('Bayesian Bias PRE vs FINAL per protocol2.fig');
% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures'
axn = replay_bayesian_bias_makeFigure;


figs = [inter;final];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2,3,4,5],[1,2,3,4,5]};
ax_destination = {[1,2,3,4,5],[6,7,8,9,10]};


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
    view(axn(a),[-90 90])        
    axn(a).FontSize = 14;
    axn(a).YAxis.Visible = 'off';
    xlim(axn(a),[-0.2 1.2])
    xticks(axn(a),[0:0.2:1])
    %ylim(axn(a),[min(ylim(axn(a)))+1 3])
    if a == 1 | a == 6               
        xlabel(axn(a),'Bayesian bias','FontSize',14)
        ylim(axn(a),[min(ylim(axn(a))) 3])
    else
        axn(a).XAxis.Visible = 'off';
    end
end


end