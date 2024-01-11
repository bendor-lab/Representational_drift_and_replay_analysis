
function create_theta_scores_figures

phase = openfig('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Phase_precession\Figures\Proportion of precessing place cells per protocol.fig');
thetaseq = openfig('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\figures\Thetaseq scores all protocols.fig');

figs = [thetaseq;phase];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,3,2,4],[1]};
ax_destination = {[1,2,5,4],[3]};

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Combined figures'
axn = theta_scores_makeFigure;

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
    xticks(axn(a),[])
    xlabels = {'1', '2', '3', '4', '8', '16','RT1','RT2'};
    if a == 1 || a == 5
        l = findobj(axn(a),'type','line');
        set(l,'LineWidth',1)
        set(l,'MarkerSize',5)
        tt = get(l,'tag');   % List the names of all the objects
        idx = find(strcmpi(tt,'box')==1);  % Find Box objects
        boxes = l(idx);  % Get the children you need (boxes for first exposure)
        set(boxes,'LineWidth',2.5); % Set width
        ylabel(axn(a),'Score','FontSize',14)
        ylim(axn(a),[-0.1 0.3])
    elseif a == 2 || a == 4
         l = findobj(axn(a),'type','line');
        set(l,'LineWidth',1)
        set(l,'MarkerSize',5)
        tt = get(l,'tag');   % List the names of all the objects
        idx = find(strcmpi(tt,'box')==1);  % Find Box objects
        boxes = l(idx);  % Get the children you need (boxes for first exposure)
        set(boxes,'LineWidth',2); % Set width
        ylabel(axn(a),'P-value','FontSize',14) 
        ylim(axn(a),[-0.02 0.6])
        yticks(axn(a),0:0.05:0.3)
    elseif a == 3
        title(axn(a),'');
        ylabel(axn(a),'Proportion sig. place cells','FontSize',14)
        ylim(axn(a),[0 1])
    end
    axn(a).FontSize = 14;
end


end

