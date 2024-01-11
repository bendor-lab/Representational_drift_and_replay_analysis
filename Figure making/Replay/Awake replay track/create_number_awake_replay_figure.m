function create_number_awake_replay_figure


% NUMBER OF AWAKE REPLAY EVENTS TRACK AND PROTOCOL

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Awake replay on track'
events = openfig('Norm Number of awake replay events per track__ALL_Protocol.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures'
axn = num_awake_replay_makeFigure;


figs = [events];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {1,2,3,4,5};
ax_destination = {1,2,3,4,5};

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
    if a <5
        title(axn(a),'');
        %ylabel(axn(a),'Mean # place cells','FontSize',11)
        xticks(axn(a),[])
        %xticklabels(axn(a),{'T1','T2','R-T1','R-T2'});
        ylim(axn(a), [0 15]);

    elseif a == 5
        title(axn(a),'');
        xticks(axn(a),[1 2 3 4])
        xticklabels(axn(a),{'T1','T2','R-T1','R-T2'});
        ylim(axn(a), [0 15]);
    end
    axn(a).FontSize = 16;
    
end


save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Combined_figs',[]);

%%%%%%%%%%


%%% RATE AWAKE REPLAY PER LAP FOR ALL TRACKS

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Awake replay on track'
events = openfig('Local awake replay in track per protocol_BOXPLOT-LINE_complete laps.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures'
axn = rate_awake_replay_makeFigure;


figs = [events];

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
   
    if a == 1 | a == 3 | a ==4
        title(axn(a),'');
        ylabel(axn(a),{'Awake replay rate';'events/s'},'FontSize',11)
        xticks(axn(a),1:16)
        ylim(axn(a), [-0.05 0.25]);
        xlim(axn(a),[0 16.5])
    elseif a == 2
        title(axn(a),'');
        xticks(axn(a),1:8)
        ylabel(axn(a),{'Awake replay rate';'events/s'},'FontSize',11)
        ylim(axn(a), [-0.05 0.25]);
        xlim(axn(a),[0 8.5])
    end
    if a == 4
        xlabel(axn(a),'Laps','FontSize',16)
    end
    axn(a).FontSize = 16;
    
end



end