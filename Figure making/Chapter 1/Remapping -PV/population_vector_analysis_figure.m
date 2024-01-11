function population_vector_analysis_figure


% POPULATION VECTOR ANALYSIS FOR OVERALL PROTOCOLS AND FOR PROTOCOL SEPARATE

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\figures\PPV_shuffles_RAW-PlField_BAYESIAN'
overall = openfig('Shuffle vs Real Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS - ALL PROTOCOLS.fig');
rats8 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS -S16_8.fig');
rats4 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS -S16_4.fig');
rats3 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS -S16_3.fig');
rats2 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS -S16_2.fig');
rats1 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS -S16_1.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = Population_vector_analysis_makeFigure;

figs = [overall; rats8; rats4; rats3; rats2; rats1];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2],[1,3],[1,3],[1,3],[1,3],[1,3]};
ax_destination = {[1,12],[2,7],[3,8],[4,9],[5,10],[6,11]};


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
tt = {'','16 vs 8','16 vs 2','16 vs 3','16 vs 2','16 vs 1','16 vs 8','16 vs 2','16 vs 3','16 vs 2','16 vs 1',''};
% Add information in each axes
for a = 1 : length(axn)
    if a == 1
        title(axn(a),'');
        ylabel(axn(a),'Cumulative frequency','FontSize',11)
        xlabel(axn(a),'PV correlation','FontSize',11)
        xlim(axn(a), [-0.2 1]);
        axn(a).FontSize =11;
    elseif a == 12
        title(axn(a),'');
        ylabel(axn(a),'PV correlation','FontSize',11)
        xticks(axn(a),[1 2 3 4 5 6])
        xlim(axn(a), [0.5 6.5]);
        xticklabels(axn(a),{'T1 vs R-T1','T2 vs R-T2','T1 vs T2','T2 vs R-T1','T1 vs R-T2','R-T1 vs R-T2'});
        axn(a).FontSize =11;
    elseif a > 7 && a <12
        title(axn(a),'');
        xlabel(axn(a),'PV correlation','FontSize',11)
        axn(a).FontSize = 11;
    elseif a >2 && a <7
        title(axn(a),'');
        title(axn(a),tt{a},'Position',[0.6 1.1 0])
        axn(a).FontSize = 11;
    elseif a == 2
        title(axn(a),'');
        title(axn(a),tt{a},'Position',[0.6 1.1 0])
        ylabel(axn(a),'Cumulative frequency','FontSize',11)
        axn(a).FontSize = 11;
    elseif a == 7
        title(axn(a),'');
        xlabel(axn(a),'PV correlation','FontSize',11)
        ylabel(axn(a),'Cumulative frequency','FontSize',11)
        axn(a).FontSize = 11;
    end
end

save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);


%%%%%% FOR FIRING RATE PV
% NUMBER OF PLACE FIELDS WITH FINE RESOLUTION

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\figures\Firing_Rate_PPV_Shuffle_RAW-PlField_BAYESIAN'
overall = openfig('Shuffle vs Real Cummulative frequency distribution BAYESIAN RAW PlFlds - ALL RATS - ALL PROTOCOLS.fig');
rats8 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS -S16_8.fig');
rats4 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS -S16_4.fig');
rats3 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS -S16_3.fig');
rats2 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS -S16_2.fig');
rats1 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - ALL RATS -S16_1.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = Population_vector_analysis_makeFigure;

figs = [overall; rats8; rats4; rats3; rats2; rats1];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2],[1,3],[1,3],[1,3],[1,3],[1,3]};
ax_destination = {[1,12],[2,7],[3,8],[4,9],[5,10],[6,11]};


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
tt = {'','16 vs 8','16 vs 2','16 vs 3','16 vs 2','16 vs 1','16 vs 8','16 vs 2','16 vs 3','16 vs 2','16 vs 1',''};
% Add information in each axes
for a = 1 : length(axn)
    if a == 1
        title(axn(a),'');
        ylabel(axn(a),'Cumulative frequency','FontSize',11)
        xlh = xlabel(axn(a),'\Delta Firing Rate','FontSize',11);
        xlim(axn(a),[0 100])
        axn(a).FontSize =11;
    elseif a == 12
        title(axn(a),'');
        ylabel(axn(a),'\Delta Firing Rate','FontSize',11)
        xticks(axn(a),[1 2 3 4 5 6])
        xlim(axn(a), [0.5 6.5]);
        xticklabels(axn(a),{'T1 vs R-T1','T2 vs R-T2','T1 vs T2','T2 vs R-T1','T1 vs R-T2','R-T1 vs R-T2'});
        axn(a).FontSize =11;
    elseif a > 7 && a <12
        title(axn(a),'');
        xlabel(axn(a),'\Delta Firing Rate','FontSize',11)
        axn(a).FontSize = 11;
    elseif a >2 && a <7
        title(axn(a),'');
        title(axn(a),tt{a},'Position',[0.6 1.1 0])
        axn(a).FontSize = 11;
    elseif a == 2
        title(axn(a),'');
        title(axn(a),tt{a},'Position',[0.6 1.1 0])
        ylabel(axn(a),'Cumulative frequency','FontSize',11)
        axn(a).FontSize = 11;
    elseif a == 7
        title(axn(a),'');
        xlabel(axn(a),'\Delta Firing Rate','FontSize',11)
        ylabel(axn(a),'Cumulative frequency','FontSize',11)
        axn(a).FontSize = 11;
    end
end


figu = gcf;
figu.Name = 'FR_population_vector_analysis';
save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);




end