function create_decError_between_exposures_figure

% CH1: DECODING ERROR BETWEEN EXPOSURES
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\figures\Decoding error between exposures'
figs = openfig('Median decoding error using same track other exposure.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = Median_decError_between_exposures_makeFigure;

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {1,2};
ax_destination = {1,2};


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
    
    if a == 1
        title(axn(a),'');
        ylabel(axn(a),'Median decoding error (cm)','FontSize',12)
        xticks(axn(a),1:12)
        set(axn(a),'XTickLabel',{'16 Laps','16 Laps-Ctrl','8 Laps','8 Laps-Ctrl','4 Lap','4 Laps-Ctrl','3 Laps','3 Laps-Ctrl',...
            '2 Laps','2 Laps-Ctrl','1 Lap','1 Lap-Ctrl'})
        set(axn(a),'XTickLabel',{'16','16-Ctrl','8','8-Ctrl','4','4-Ctrl','3','3-Ctrl',...
            '2','2-Ctrl','1','1-Ctrl'})
        xlh = xlabel(axn(a),'Laps','FontSize',12);
        xlh.Position(2) = xlh.Position(2) - 4;
        axn(a).FontSize = 12;
    elseif a == 2
        title(axn(a),'');
        ylabel(axn(a),'Median decoding error (cm)','FontSize',12)
        xticks(axn(a),1:12)
        set(axn(a),'XTickLabel',{'16 Laps','16 Laps-Ctrl','8 Laps','8 Laps-Ctrl','4 Lap','4 Laps-Ctrl','3 Laps','3 Laps-Ctrl',...
            '2 Laps','2 Laps-Ctrl','1 Lap','1 Lap-Ctrl'})
        set(axn(a),'XTickLabel',{'16','16-Ctrl','8','8-Ctrl','4','4-Ctrl','3','3-Ctrl',...
            '2','2-Ctrl','1','1-Ctrl'})
        xlh = xlabel(axn(a),'Laps','FontSize',12);
        xlh.Position(2) = xlh.Position(2) - 4;
        axn(a).FontSize = 12;  
    end
end

save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);




end
