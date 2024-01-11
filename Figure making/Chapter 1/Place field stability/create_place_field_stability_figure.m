function create_place_field_stability_figure


% PLACE FIELD STABILITY - CENTRE OF MASS & DECODING ERROR
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\figures\Decoding error within exposure'
DecErr_lastlaps = openfig('Median decoding error per lap using last laps from same exposure_all protocols_1st and 2nd Exposure_Linear.fig');
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\figures\Comparison to 4 last laps\Population_corr_centre_mass'
CM_lastLaps = openfig('Centre of mass correlation at cell population level for 1st&2nd exposure - 1 Lap Jump -within_track-ends_laps_ALLprotocols.fig');
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\figures\Comparison to 4 last laps\Population_corr_peak_FR'
PFR_lastLaps = openfig('Peak FR correlation at cell population level for 1st&2nd exposure - 1 Lap Jump -within_track-ends_laps_ALLprotocols.fig');

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\figures\Decoding error consecutive laps'
DecErr_consec = openfig('Median decoding error  of consecutive laps within same exposure_all protocols_1st and 2nd Exposure.fig');
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\figures\Consecutive laps\Population_corr_centre_mass'
CM_consec= openfig('Centre of mass correlation at cell population level for 1st&2nd exposure - 1 Lap Jump -within_track-consecutive_laps_ALLprotocols.fig');
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr\figures\Consecutive laps\Population_corr_peak_FR'
PFR_consec = openfig('Peak FR correlation at cell population level for 1st&2nd exposure - 1 Lap Jump -within_track-consecutive_laps_ALLprotocols.fig');


% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = PlField_stability_within_track_makeFigure;


figs = [DecErr_lastlaps; CM_lastLaps;PFR_lastLaps; DecErr_consec; CM_consec;PFR_consec];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {1,1,1,1,1,1};
ax_destination = {5,1,2,6,3,4};


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
    
    if a == 1 || a==3
        title(axn(a),'');
        ylabel(axn(a),'Correlaton coefficient','FontSize',12)
        xticks(axn(a),[2:2:12,14:2:24])
        xticklabels(axn(a),{2:2:12,2:2:12});
        xlabel(axn(a),'Laps','FontSize',12)
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'LineWidth',2)
        set(L,'MarkerSize',1.5)
        L(1).YData = [0 1];
        %delete(L(1))
        axn(a).FontSize = 12;
    elseif a == 2 || a ==4
        title(axn(a),'');
        xticks(axn(a),[2:2:12,14:2:24])
        xticklabels(axn(a),{2:2:12,2:2:12});
        xlabel(axn(a),'Laps','FontSize',12)
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'LineWidth',2)
        set(L,'MarkerSize',1.5)
        L(1).YData = [0 1];
        %delete(L(1))
        axn(a).FontSize = 12;
        ylim(axn(a),[0 1])
    elseif a == 5
        title(axn(a),'');
        ylabel(axn(a),'Median decoding error (cm)','FontSize',12)
        xticks(axn(a),[1:2:12,14:2:25])
        xticklabels(axn(a),{2:2:12,2:2:12});
        %xlabel(axn(a),'Laps','FontSize',12)
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'LineWidth',2)
        set(L,'MarkerSize',1.5)
        %delete(L(1))
        axn(a).FontSize = 12;
        ylim(axn(a),[0 45])
%         xticks(axn(a),[1:6, 8:13])
%         ylim(axn(a),[0 45])
%         h = findall(gcf,'Type','axes');
%         L = findobj(axn(a),'type','line');
%         set(L(1),'LineWidth',0.8)
%         set(L(17),'LineWidth',2)
%         b = get(axn(a),'XTickLabel');
%         set(axn(a),'XTickLabel',{'16','8','4','3','2','1','16','8','4','3','2','1'},'fontsize',12)
%         xlim(axn(a),[0 14]);
        %xlabel(axn(a),'Laps','FontSize',12)
    elseif a == 6
        title(axn(a),'');
        ylabel(axn(a),'Median decoding error (cm)','FontSize',12)
        xlim(axn(a),[0 28])
        xticks(axn(a),[2:2:14,17:2:28])
        xticklabels(axn(a),{2:2:14,2:2:12});
        %xlabel(axn(a),'Laps','FontSize',12)
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'LineWidth',2)
        set(L,'MarkerSize',1.5)
        %delete(L(1))
        axn(a).FontSize = 12;
        ylim(axn(a),[0 32])
    end
end


save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);




end
