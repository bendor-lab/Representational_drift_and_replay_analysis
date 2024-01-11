function create_place_field_stability_between_tracks_figure


% PLACE FIELD STABILITY - CENTRE OF MASS & PEAK FIRING RATE
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\figures\Comparison laps 13-16 Re-Exposure to First exposure\Population_corr_centre_mass'
CM_lastLaps = openfig('Centre of mass correlation at cell population level for both exposures - 1 Lap Jump - Compare laps 13-16 Re-EXP to 1st-EXP_ALLprotocols.fig');
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\figures\Comparison laps 13-16 Re-Exposure to First exposure\Population_corr_peak_FR'
PFR_lastLaps = openfig('Peak FR correlation at cell population level for both exposures - 1 Lap Jump - Compare laps 13-16 Re-EXP to 1st-EXP_ALLprotocols.fig');

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\figures\Comparison whole first exposure to laps second exposure'
CM_full= openfig('CenterOfMass_1stLap_ReEXp_compared_to_FULL_1stEXP_ratemap.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = PlField_stability_between_tracks_makeFigure;

figs = [CM_lastLaps; PFR_lastLaps; CM_full];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {1,1,1};
ax_destination = {1,2,3};

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
%%
% Add information in each axes
for a = 1 : length(axn)
    
    if a == 1 || a==2
        title(axn(a),'');
        ylim(axn(a),[0 1])
        ylabel(axn(a),'Correlaton coefficient','FontSize',12)
        xticks(axn(a),[1:2:12,14:2:24])
        xticklabels(axn(a),{1:2:12,1:2:12});
        xlabel(axn(a),'Laps','FontSize',12)
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'LineWidth',2)
        set(L,'MarkerSize',1.5)
        delete(L(1))
        axn(a).FontSize = 12;
    elseif a == 3
        title(axn(a),'');
        ylabel(axn(a),'Correlaton coefficient','FontSize',12)
        xticks(axn(a),[1:6])
        b = get(axn(a),'XTickLabel');
        set(axn(a),'XTickLabel',{'16','8','4','3','2','1'},'fontsize',12)
        xlim(axn(a),[0.5 6.5]);
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'MarkerSize',4.5)
    end
end


save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);




end
