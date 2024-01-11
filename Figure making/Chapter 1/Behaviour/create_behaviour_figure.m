function create_behaviour_figure


% CH1: BEHAVIOURAL PLOTS:speed,time immobile, time running

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\figures'
figs = openfig('Behaviour plots.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = behaviour_makeFigure;

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {1,2,3,4};
ax_destination = {1,2,3,4};


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
        ylabel(axn(a),'Mean speed (cm/s)','FontSize',11)
        xticks(axn(a),[1 2 3 4])
        xticklabels(axn(a),{'T1','T2','R-T1','R-T2'});
        xlim(axn(a),[0.5 4.5])
        ylim(axn(a),[9 25])
        axn(a).FontSize = 11;
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'MarkerSize',4.5)
    elseif a == 2
        title(axn(a),'');
        ylabel(axn(a),'\Delta mean speed (cm/s)','FontSize',11)
        xticks(axn(a),[1 2 3])
        xlim(axn(a),[0.75 3.25])       
        xticklabels(axn(a),{'\Delta(T2,T1)','\Delta(T2,R-T1)','\Delta(R-T1,R-T2)'});
        ylim(axn(a),[-10 15])
        axn(a).FontSize = 11;     
        axn(a).XAxis.FontSize = 10;
    elseif a == 4
        title(axn(a),'');
        ylabel(axn(a),'Immobile time (min)','FontSize',11)
        xticks(axn(a),1:8)
        xlim(axn(a),[0.25 8.25])
        axn(a).FontSize = 11;
        set(axn(a),'XTickLabel',{'1 Lap','2 Laps','3 Laps','4 Laps','8 Laps','16 Laps','R-T1','R-T2'})
        xtickangle(axn(a),45)
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'MarkerSize',4)
    elseif a == 3
        title(axn(a),'');
        ylabel(axn(a),'Running time (min)','FontSize',11)
        xticks(axn(a),1:8)
        xlim(axn(a),[0.25 8.25])
        axn(a).FontSize = 11;
        set(axn(a),'XTickLabel',{'1 Lap','2 Laps','3 Laps','4 Laps','8 Laps','16 Laps','R-T1','R-T2'})
        xtickangle(axn(a),45)
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'MarkerSize',4)
    end
end
cf = gcf;
cf.Name = 'Behavioural plots';

save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);




end
