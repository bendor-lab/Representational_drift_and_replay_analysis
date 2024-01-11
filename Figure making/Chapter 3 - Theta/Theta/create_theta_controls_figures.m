function create_theta_controls_figures

corre = openfig('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Controls\figures\Theta control correlations_2.fig');
decerror = openfig('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Controls\figures\theta_seq_dec_error.fig');

figs = [corre;decerror];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,3,2,4,5,6],[1]};
ax_destination = {[1,3,2,4,5,6],[7]};

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Combined figures'
axn = theta_correlations_controls_makeFigure;

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

labls = {'Lap running time(s)','# Lap theta seq.','Lap running speed (cm/s)','Lap decoding error (cm)','Mean num. units','Mean Skagg info.'};
% Add information in each axes
for a = 1 : length(axn)
    title(axn(a),'');
    if a < 7
        ylabel(axn(a),'Lap theta seq. score','FontSize',14)
        xlabel(axn(a),labls{a},'FontSize',14)

    elseif a == 7
        xticks(axn(a),1:13)
        xticklabels({'T1', '8', '4', '3', '2', '1','','R-T1','8', '4', '3', '2','1'});
        ylabel(axn(a),'Theta seq. median decoding error (cm)','FontSize',14)
    end
    axn(a).FontSize = 14;
end


end