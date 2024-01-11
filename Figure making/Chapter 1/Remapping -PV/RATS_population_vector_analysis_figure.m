function RATS_population_vector_analysis_figure


% POPULATION VECTOR ANALYSIS FOR RATS INDIVIDUALLY

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\figures\PPV_shuffles_RAW-PlField_BAYESIAN'
rats8 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds -S16_8.fig');
rats4 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds -S16_4.fig');
rats3 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds -S16_3.fig');
rats2 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds -S16_2.fig');
rats1 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds -S16_1.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = RATS_Population_vector_analysis_makeFigure;

figs = [rats8; rats4; rats3; rats2; rats1];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8]};
ax_destination = {[1,2,3,4,5,6,7,8],[9,10,11,12,13,14,15,16],[17,18,19,20,21,22,23,24],[25,26,27,28,29,30,31,32],[33,34,35,36,37,38,39,40]};


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

tt = {'M-BLU','','N-BLU','','P-ORA','','Q-BLU'};
% Add information in each axes
for a = 1 : length(axn)
    if mod(a,2) == 1 %if odd
        title(axn(a),'');
        ylh = ylabel(axn(a),'Cumulative frequency','FontSize',11);
       ylh.Position(1) = ylh.Position(1) + 0.02;  % move the label 0.1 data-units further down
        axn(a).FontSize = 10;
    elseif mod(a,2) == 0 %if even
        title(axn(a),'');
        ylh = ylabel(axn(a),'PV correlation','FontSize',11);
        ylh.Position(1) = ylh.Position(1) + 0.3;  % move the label 0.1 data-units further down
        xticks(axn(a),[1 2 3 4 5 6])
        %xticklabels(axn(a),{'T1 vs R-T1','T2 vs R-T2','T1 vs T2','T2 vs R-T1','T1 vs R-T2','R-T1 vs R-T2'});
        %xtickangle(axn(a),45)
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'MarkerSize',1)
        set(L,'LineWidth',0.5)
        axn(a).FontSize = 10;
    end
    if a == 1 || a == 3 || a == 5 || a == 7 
        title(axn(a),'');
        title(axn(a),tt{a},'Position',[1.5 1.1 0])
        axn(a).FontSize = 10;
    elseif a ==33 || a == 35 || a == 37 || a == 39 
        xlabel(axn(a),'PV correlation','FontSize',10)
   
    end
end

aa = gcf;
aa.Name = 'RATS_population_vector_analysis';
save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);


%%%%%% FOR FIRING RATE PV _RATS

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\figures\Firing_Rate_PPV_Shuffle_RAW-PlField_BAYESIAN'
rats8 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds -S16_8.fig');
rats4 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds -S16_4.fig');
rats3 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds -S16_3.fig');
rats2 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds -S16_2.fig');
rats1 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds -S16_1.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = RATS_Population_vector_analysis_makeFigure;

figs = [rats8; rats4; rats3; rats2; rats1];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8]};
ax_destination = {[1,2,3,4,5,6,7,8],[9,10,11,12,13,14,15,16],[17,18,19,20,21,22,23,24],[25,26,27,28,29,30,31,32],[33,34,35,36,37,38,39,40]};


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

tt = {'M-BLU','','N-BLU','','P-ORA','','Q-BLU'};
% Add information in each axes
for a = 1 : length(axn)
    if mod(a,2) == 1 & a~=3 %if odd 
        title(axn(a),'');
        ylh = ylabel(axn(a),'\Delta Firing Rate','FontSize',11);
       %ylh.Position(1) = ylh.Position(1) + 0.5;  % move the label 0.1 data-units further down
        axn(a).FontSize = 10;
    elseif mod(a,2) == 0 %if even
        title(axn(a),'');
        ylh = ylabel(axn(a),'\Delta Firing Rate','FontSize',11);
        ylh.Position(1) = ylh.Position(1) + 0.1;  % move the label 0.1 data-units further down
        xticks(axn(a),[1 2 3 4 5 6])
        %xticklabels(axn(a),{'T1 vs R-T1','T2 vs R-T2','T1 vs T2','T2 vs R-T1','T1 vs R-T2','R-T1 vs R-T2'});
        %xtickangle(axn(a),45)
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'MarkerSize',1)
        set(L,'LineWidth',0.5)
        axn(a).FontSize = 10;
    end
    if a == 1 || a == 3 || a == 5 || a == 7 
        title(axn(a),'');
        title(axn(a),tt{a},'Position',[1.5 1.1 0])
        axn(a).FontSize = 10;
    elseif a ==33 || a == 35 || a == 37 || a == 39 
        xlabel(axn(a),'\Delta Firing Rate','FontSize',10)
   
    end
end

aa = gcf;
aa.Name = 'RATS_Firing_rate_PV';
save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);


%% REPEAT FOR SECTIONS

% POPULATION VECTOR ANALYSIS FOR RATS INDIVIDUALLY

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\figures\PPV_shuffles_RAW-PlField_BAYESIAN'
rats8 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - Lap section -S16_8.fig');
rats4 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - Lap section -S16_4.fig');
rats3 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - Lap section -S16_3.fig');
rats2 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - Lap section -S16_2.fig');
rats1 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - Lap section -S16_1.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = RATS_Population_vector_analysis_makeFigure;

figs = [rats8; rats4; rats3; rats2; rats1];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8]};
ax_destination = {[1,2,3,4,5,6,7,8],[9,10,11,12,13,14,15,16],[17,18,19,20,21,22,23,24],[25,26,27,28,29,30,31,32],[33,34,35,36,37,38,39,40]};


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

tt = {'M-BLU','','N-BLU','','P-ORA','','Q-BLU'};
% Add information in each axes
for a = 1 : length(axn)
    if mod(a,2) == 1 %if odd
        title(axn(a),'');
        ylh = ylabel(axn(a),'Cumulative frequency','FontSize',11);
      % ylh.Position(1) = ylh.Position(1) + 0.02;  % move the label 0.1 data-units further down
        axn(a).FontSize = 10;
    elseif mod(a,2) == 0 %if even
        title(axn(a),'');
        ylh = ylabel(axn(a),'PV correlation','FontSize',11);
        %ylh.Position(1) = ylh.Position(1) + 0.3;  % move the label 0.1 data-units further down
        xticks(axn(a),[1 2 3])
        %xticklabels(axn(a),{'T1 vs R-T1','T2 vs R-T2','T1 vs T2'});
        %xtickangle(axn(a),45)
        xlim(axn(a),[0.5 3.5])
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'MarkerSize',1)
        set(L,'LineWidth',0.5)
        axn(a).FontSize = 10;
    end
    if a == 1 || a == 3 || a == 5 || a == 7 
        title(axn(a),'');
        title(axn(a),tt{a},'Position',[1.5 1.1 0])
        axn(a).FontSize = 10;
    elseif a ==33 || a == 35 || a == 37 || a == 39 
        xlh = xlabel(axn(a),'PV correlation','FontSize',10);
        xlh.Position(2) = xlh.Position(2) + 0.02; 
   
    end
end

aa = gcf;
aa.Name = 'RATS_population_vector_analysis_SECTION';
save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);


%%%%%% FOR FIRING RATE PV _RATS

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Population_vector_analysis\figures\Firing_Rate_PPV_Shuffle_RAW-PlField_BAYESIAN'
rats8 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - Lap section -S16_8.fig');
rats4 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - Lap section -S16_4.fig');
rats3 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - Lap section -S16_3.fig');
rats2 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - Lap section -S16_2.fig');
rats1 = openfig('Cummulative frequency distribution RAW BAYESIAN PlFlds - Lap section -S16_1.fig');

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = RATS_Population_vector_analysis_makeFigure;

figs = [rats8; rats4; rats3; rats2; rats1];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8],[1,2,3,4,5,6,7,8]};
ax_destination = {[1,2,3,4,5,6,7,8],[9,10,11,12,13,14,15,16],[17,18,19,20,21,22,23,24],[25,26,27,28,29,30,31,32],[33,34,35,36,37,38,39,40]};


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

tt = {'M-BLU','','N-BLU','','P-ORA','','Q-BLU'};
% Add information in each axes
for a = 1 : length(axn)
    if mod(a,2) == 1 & a~=3 %if odd 
        title(axn(a),'');
        ylh = ylabel(axn(a),'\Delta Firing Rate','FontSize',11);
       %ylh.Position(1) = ylh.Position(1) + 0.5;  % move the label 0.1 data-units further down
        axn(a).FontSize = 10;
    elseif mod(a,2) == 0 %if even
        title(axn(a),'');
        ylh = ylabel(axn(a),'\Delta Firing Rate','FontSize',11);
        %ylh.Position(1) = ylh.Position(1) + 0.1;  % move the label 0.1 data-units further down
        xticks(axn(a),[1 2 3])
        %xticklabels(axn(a),{'T1 vs R-T1','T2 vs R-T2','T1 vs T2','T2 vs R-T1','T1 vs R-T2','R-T1 vs R-T2'});
        %xtickangle(axn(a),45)
        xlim(axn(a),[0.5 3.5])
        h = findall(gcf,'Type','axes');
        L = findobj(axn(a),'type','line');
        set(L,'MarkerSize',1)
        set(L,'LineWidth',0.5)
        axn(a).FontSize = 10;
    end
    if a == 1 || a == 3 || a == 5 || a == 7 
        title(axn(a),'');
        title(axn(a),tt{a},'Position',[1.5 1.1 0])
        axn(a).FontSize = 10;
    elseif a ==33 || a == 35 || a == 37 || a == 39 
        xlh = xlabel(axn(a),'\Delta Firing Rate','FontSize',10);
        xlh.Position(2) = xlh.Position(2) + 0.02;    
    end
end

aa = gcf;
aa.Name = 'RATS_Firing_rate_PV_SECTION';
save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);


end