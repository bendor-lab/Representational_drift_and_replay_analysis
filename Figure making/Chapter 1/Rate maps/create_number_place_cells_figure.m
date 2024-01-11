function create_number_place_cells_figure


% NUMBER OF PLACE FIELDS WITH FINE RESOLUTION

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Cell_count\figures'
trackcells = openfig('Number of place cells all protocols -fine resolution.fig');
mean_trackcells = openfig('Fine resolution- Mean number of place cells per track.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = Number_of_place_cells_makeFigure;


figs = [trackcells; mean_trackcells];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2,3,4,5],1};
ax_destination = {[2,3,4,5,6],1};


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

cnt = {[],'Protocol A_1_6_-_8','Protocol B_1_6_-_4','Protocol C_1_6_-_3','Protocol D_1_6_-_2','Protocol E_1_6_-_1'};

% Add information in each axes
for a = 1 : length(axn)
    if a == 1
        title(axn(a),'');
        ylabel(axn(a),'Mean # place cells','FontSize',11)
        xticks(axn(a),[1 2 3 4])
        xticklabels(axn(a),{'T1','T2','R-T1','R-T2'});
        xlim(axn(a), [0.25 5]);
        annotation(gcf,'textbox',[0.26,0.8,0.05,0.05],'String','ns','EdgeColor','none','FontSize',10)
        axn(a).FontSize =11;
    elseif a > 1 && a <5
        title(axn(a),cnt{a},'Position',[0.5 1],'FontSize',11);
        ylh = ylabel(axn(a),'# place cells','FontSize',11);
        xticks(axn(a),[1 2 3 4])
        xticklabels(axn(a),{'T1','T2','R-T1','R-T2'});
        axn(a).FontSize =11;
        ylim(axn(a), [0 max(ylim(axn(a)))]);
        ylh.Position(1) = ylh.Position(1) + 0.1;  % move the label 0.1 data-units further down
    elseif a == 5
        title(axn(a),cnt{a},'Position',[0.5 1],'FontSize',11);
        xticks(axn(a),[1 2 3 4])
        xticklabels(axn(a),{'T1','T2','R-T1','R-T2'});
        ylh = ylabel(axn(a),'# place cells','FontSize',11);
        ylh.Position(1) = ylh.Position(1) + 0.1;  % move the label 0.1 data-units further down
        axn(a).FontSize = 11;
    elseif a == 6
        title(axn(a),cnt{a},'Position',[0.5 1],'FontSize',11);
        xticks(axn(a),[1 2 3 4])
        xticklabels(axn(a),{'T1','T2','R-T1','R-T2'});
        ylim(axn(a),[0  max(ylim(axn(a)))]);
        ylh = ylabel(axn(a),'# place cells','FontSize',11);
        ylh.Position(1) = ylh.Position(1) + 0.1;  % move the label 0.1 data-units further down
        axn(a).FontSize = 11;
        
    end
end


save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);




end