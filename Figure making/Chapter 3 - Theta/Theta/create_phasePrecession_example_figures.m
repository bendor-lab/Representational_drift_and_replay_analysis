
% PLOT PHASE PRECESSION EXAMPLES

function create_phasePrecession_example_figures

cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Phase_precession\Figures')
phase = openfig('Phase_precession_examples_2.fig');

% output figure
cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Combined figures')
axn = phase_precession_example_makeFigure;

figs = [phase];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {9,10,7,8,5,6,3,4,1,2,11,12};
ax_destination = {1,2,3,4,5,6,7,8,9,10,11,12};

for n = 1:size(figs,1) % for each figure
% Get axes info of first fig
    axIn = findall(figs(n),'type','axes');
    axIn = flip(axIn);
    if size(figs,1) > 2
        ax2copy = ax_to_copy{n};
        ax_dest = ax_destination{n};
        
        axIn = axIn(ax2copy);
        axOut = axn(ax_dest);
        
        for nax = 1: size(axIn,1)
            hIn  = allchild(axIn(nax));
            [~] = copyobj(hIn,axOut(nax));
        end
    else
        for nn = 1 : length(ax_to_copy)
            ax2copy = ax_to_copy{nn};
            ax_dest = ax_destination{nn};
            axIn1 = axIn(ax2copy);
            axOut1 = axn(ax_dest);
            hIn  = allchild(axIn1);
            [~] = copyobj(hIn,axOut1);
        end
    end
end


% Add information in each axes
for a = 1 : length(axn)
    axis(axn(a),'tight')
    title(axn(a),'')
    axn(a).FontSize = 14;    
    if mod(a,2) ~= 0
        ylabel(axn(a),{'Phase (degrees)'},'FontSize',14)
        xlim(axn(a),[0 200])
        ylim(axn(a),[0 800])
        xticks(axn(a),[0:50:200])
        yticks(axn(a),[0:200:800])
    elseif a == 9 || a ==11
        xlabel(axn(a),'Linearised position (cm)','FontSize',14)
    elseif mod(a,2) ==0
        axis(axn(a),'off')
    end
end


save_all_figures(pwd,[])







end