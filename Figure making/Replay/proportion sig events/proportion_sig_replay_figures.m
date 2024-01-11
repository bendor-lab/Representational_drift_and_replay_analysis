function proportion_sig_replay_figures

% PLOT RATE REPLAY FOR 1+3 vs 2+4
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Controls comparion'
prop = openfig('Proportion of significant events per protocol.fig');

figs = [prop];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,4,7,10,13,2,5,8,11,14]};
ax_destination = {[1,3,5,7,9,2,4,6,8,10]};

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures'
axn = Proportion_sig_events_makeFigure;

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
        xticks(axn(a),[1 2 3 4])
        b = get(axn(a),'XTickLabel');
        set(axn(a),'XTickLabel',{'T1','T2','R-T1','R-T2'},'fontsize',14)
        ylabel(axn(a),'Sig. events (%)','FontSize',14)
        ob = findobj(axn(a),'type','line');
        set(ob,'MarkerSize',6)
        axn(a).FontSize = 14;
        ylim(axn(a),[0 15])
end


save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures',[]);



end