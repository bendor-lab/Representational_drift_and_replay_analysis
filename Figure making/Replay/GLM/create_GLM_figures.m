


function create_GLM_figures

% PLOT INTER SLEEP GLM 
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\GLM'
bar_ind = openfig('GLM_INTER_explained_deviance_individual.fig');
bar_diff = openfig('GLM_INTER_explained_deviance_difference.fig' );
prob_ind = openfig('GLM_INTER_probability_plots_individual.fig' );
prob_diff = openfig('GLM_INTER_probability_plots_difference.fig' );

figs = [bar_ind;prob_ind;bar_diff;prob_diff];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {1,[1,2,3],1,[1,2]};
ax_destination = {9,[1,2,3],8,[4,5]};

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures'
axn = GLM_INTER_sleep_makeFigure;

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
    if a == 9 || a == 8
        l = findobj(axn(a),'type','bar');
        thresh1 = l(length(l)).YData;
        thresh2 = l(length(l)-1).YData;
        ylim(axn(a),[thresh2-20 thresh1])
        xticks(axn(a),[])
        title(axn(a),'');
        ylabel(axn(a),'Deviance','FontSize',14)
        axn(a).FontSize = 14;       
    elseif a == 1
        title(axn(a),'');
        ylabel(axn(a),'Probability of replaying T2','FontSize',14)
        xlabel(axn(a),'# Laps T2','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 2
        title(axn(a),'');
        xlabel(axn(a),'# T1 Awake replay events','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 3
        title(axn(a),'');
        xlabel(axn(a),'# T2 Theta seq.','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 4
        title(axn(a),'');
        ylabel(axn(a),'Probability of replaying T2','FontSize',14)
        xlabel(axn(a),'# T1/T2 Time in track','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 5
        title(axn(a),' ');
        xlabel(axn(a),'# T1/T2 Awake replay','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 6 || a == 7
        title(axn(a),'');
        yticks(axn(a),[])
        xticks(axn(a),[])
        axn(a).FontSize = 14;
    end
end

save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures',[]);


%%%%%%%%%%%%%%%%%%%%%% 
% PLOT FINAL SLEEP GLM 

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\GLM'
bar_ind = openfig('GLM_FINAL_explained_deviance_individual.fig');
bar_diff = openfig('GLM_FINAL_explained_deviance_difference.fig' );
prob_ind = openfig('GLM_FINAL_probability_plots_individual.fig' );
prob_diff = openfig('GLM_FINAL_probability_plots_difference.fig' );

figs = [bar_diff;prob_diff;bar_ind;prob_ind];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {1,1,1,[1,2,3]};
ax_destination = {5,1,4,[2,6,3]};

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures'
axn = GLM_FINAL_sleep_makeFigure;

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
    if a == 4 || a == 5
        l = findobj(axn(a),'type','bar');
        thresh1 = l(length(l)).YData;
        thresh2 = l(length(l)-1).YData;
        ylim(axn(a),[thresh2-5 thresh1])
        xticks(axn(a),[])
        title(axn(a),'');
        ylabel(axn(a),'Deviance','FontSize',14)
        axn(a).FontSize = 14;       
    elseif a == 1
        title(axn(a),'');
        ylabel(axn(a),'Probability of replaying R-T2','FontSize',14)
        xlabel(axn(a),'R-T1/R-T2 Awake replay','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 2
        title(axn(a),'');
        xlabel(axn(a),'# R-T1 Awake replay events','FontSize',14)
        ylabel(axn(a),'Probability of replaying R-T2','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 6
        title(axn(a),'');
        xlabel(axn(a),'# R-T2 Awake replay events.','FontSize',14)
        axn(a).FontSize = 14;
    elseif a == 3
        title(axn(a),'');
        xlabel(axn(a),'T2/R-T2 Remapping','FontSize',14)
        axn(a).FontSize = 14;
    end
end

save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\figures\Combined figures',[]);






end