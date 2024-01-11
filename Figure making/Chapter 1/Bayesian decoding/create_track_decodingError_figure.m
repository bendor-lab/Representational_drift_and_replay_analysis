function create_track_decodingError_figure


% CH1: DECODING ERROR - confusion matrices

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\figures\Track decoding error'
PORA8 = openfig('P-ORA_Day5_16x8_confusion_matrices.fig');
PORA4 = openfig('P-ORA_Day4_16x4_confusion_matrices.fig');
PORA3 = openfig('P-ORA_Day2_16x3_confusion_matrices.fig');
PORA2 = openfig('P-ORA_Day3_16x2_confusion_matrices.fig');
PORA1 = openfig('Confusion_matrices_protocol_1.fig'); %N-BLU_Day3_16x1_confusion_matrices.fig');

figs = [PORA8; PORA4; PORA3; PORA2; PORA1];

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = DecError_confusion_matrices_PORAexample_makeFigure;

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {[1,2,3,4],[1,2,3,4],[1,2,3,4],[1,2,3,4],[5,6,7,8]};
ax_destination = {[1,2,3,4],[5:8],[9:12],[13:16],[17:20]};

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

tt = {'T1','T2','R-T1','R-T2'};
% Add information in each axes
for a = 1 : length(axn)
    
    title(axn(a),'');
    colormap(flipud(bone))
    ylim(axn(a),[0 20])
    xlim(axn(a),[0 20])
    xticklabels(axn(a),{'0','50','100','150','200'});
    yticklabels(axn(a),{'0','50','100','150','200'});

    if a >= 1 && a <5
        title(axn(a),tt{a},'Position',[0.5 1 0]);
    end
    axn(a).FontSize = 11;

    if a == 4 || a== 8 || a == 12 || a == 16 || a ==20
        cbl = colorbar;
        set_colorbar_position(cbl,get(axn(a),'position'),'right')
    end
    if a == 17 || a== 18 || a == 19 || a ==20
        xlabel(axn(a),'Decoded position (cm)','FontSize',11)
    end
    if a == 1 || a== 5 || a == 9 || a == 13 || a ==17
        ylabel(axn(a),'True position (cm)','FontSize',11)
    end
end

save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);


%%%%%%%%%%%% MEAN DECODING ERROR

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\figures\Track decoding error'
dec = openfig('All sessions mean cumulative decoding error.fig');
hLegend = findobj(gcf, 'Type', 'Legend'); %get legends
figs = [dec];

% output figure
cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
axn = Median_decoding_error_makeFigure;

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

tt = {'16 vs 8','16 vs 4','16 vs 3','16 vs 2','16 vs 1'};
% Add information in each axes
for a = 1 : length(axn)
    
    title(axn(a),'');
    if a == 2 | a == 4
        ylabel(axn(a),'Cumulative frequency','FontSize',11)
    end
    if a == 5 || a == 4
        xlabel(axn(a),'Median decoding error (cm)','FontSize',11)
    end
    if a == 1 | a == 2
        title(axn(a),tt{a},'Position',[0.5 1.1 0]);
    else
        title(axn(a),tt{a},'Position',[0.5 1.03 0]);
    end
    legend(axn(a),{hLegend(a).String{1},hLegend(a).String{2},hLegend(a).String{3},hLegend(a).String{4}},'Location','southeast')
    axn(a).FontSize = 11;

end

save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);

%%%%%%%%%%%% ALL RATS - CONFUSION MATRICES
%%
prot = [8,4,3,2,1];
for ii = 1 : 5 % for each protocol
    
    cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\figures\Track decoding error'
    figs = openfig(strcat('confusion_matrices_protocol_',num2str(prot(ii)),'.fig'));
        
    % output figure
    cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
    axn = DecError_confusion_mat_SUB_makeFigure;
    
    % the numbers of the axes we want to copy and where they want to go
    ax_to_copy     = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
    ax_destination = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
    
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
    
    tt = {'T1','T2','R-T1','R-T2'};
    % Add information in each axes
    for a = 1 : length(axn)
        
        title(axn(a),'');
        colormap(flipud(bone))
        ylim(axn(a),[0 20])
        xlim(axn(a),[0 20])
        xticklabels(axn(a),{'0','50','100','150','200'});
        yticklabels(axn(a),{'0','50','100','150','200'});
        axn(a).FontSize = 11;
        if a >= 1 && a <5
            title(axn(a),tt{a},'Position',[0.5 1 0],'FontSize',14);
        end

        
        if a == 4 || a== 8 || a == 12 || a == 16 
            cbl = colorbar;
            set_colorbar_position(cbl,get(axn(a),'position'),'right')
        end
        if a == 13 || a== 14 || a == 15|| a ==16
            xlabel(axn(a),'Decoded position (cm)','FontSize',13)
        end
        if a == 1 || a== 5 || a == 9 || a == 13
            ylabel(axn(a),'True position (cm)','FontSize',13)
        end
    end
    aa=gcf;
    aa.Name = strcat('16x',num2str(prot(ii)),'_DecError_confusion_mat_SUB');
    save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);
end

%%%%%%%%%%%% ALL RATS - EXPONENTIAL DECODING ERROR
    %%
    cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error\figures\Track decoding error'
    Mdec_8 = openfig('M-BLU_Day4_16x8_cumulative decoding error.fig');
    hLegend(1) = findobj(gcf, 'Type', 'Legend'); %get legends
    Mdec_4 = openfig('M-BLU_Day2_16x4_cumulative decoding error.fig');
    hLegend(5) = findobj(gcf, 'Type', 'Legend'); %get legends
    Mdec_3 = openfig('M-BLU_Day6_16x3_cumulative decoding error.fig');
    hLegend(9) = findobj(gcf, 'Type', 'Legend'); %get legends
    Mdec_2 = openfig('M-BLU_Day5_16x2_cumulative decoding error.fig');
    hLegend(13) = findobj(gcf, 'Type', 'Legend'); %get legends
    Mdec_1 = openfig('M-BLU_Day3_16x1_cumulative decoding error.fig');
    hLegend(17) = findobj(gcf, 'Type', 'Legend'); %get legends
    Ndec_8 = openfig('N-BLU_Day2_16x8_cumulative decoding error.fig');
    hLegend(2) = findobj(gcf, 'Type', 'Legend'); %get legends
    Ndec_4 = openfig('N-BLU_Day5_16x4_cumulative decoding error.fig');
    hLegend(6) = findobj(gcf, 'Type', 'Legend'); %get legends
    Ndec_3 = openfig('N-BLU_Day4_16x3_cumulative decoding error.fig');
    hLegend(10) = findobj(gcf, 'Type', 'Legend'); %get legends
    Ndec_2 = openfig('N-BLU_Day1_16x2_cumulative decoding error.fig');
    hLegend(14) = findobj(gcf, 'Type', 'Legend'); %get legends
    Ndec_1 = openfig('N-BLU_Day3_16x1_cumulative decoding error.fig');
    hLegend(18) = findobj(gcf, 'Type', 'Legend'); %get legends
    Pdec_8 = openfig('P-ORA_Day5_16x8_cumulative decoding error.fig');
    hLegend(3) = findobj(gcf, 'Type', 'Legend'); %get legends
    Pdec_4 = openfig('P-ORA_Day4_16x4_cumulative decoding error.fig');
    hLegend(7) = findobj(gcf, 'Type', 'Legend'); %get legends
    Pdec_3 = openfig('P-ORA_Day2_16x3_cumulative decoding error.fig');
    hLegend(11) = findobj(gcf, 'Type', 'Legend'); %get legends
    Pdec_2 = openfig('P-ORA_Day3_16x2_cumulative decoding error.fig');
    hLegend(15) = findobj(gcf, 'Type', 'Legend'); %get legends
    Pdec_1 = openfig('P-ORA_Day7_16x1_cumulative decoding error.fig');
    hLegend(19) = findobj(gcf, 'Type', 'Legend'); %get legends
    Qdec_8 = openfig('Q-BLU_Day8_16x8_cumulative decoding error.fig');
    hLegend(4) = findobj(gcf, 'Type', 'Legend'); %get legends
    Qdec_4 = openfig('Q-BLU_Day5_16x4_cumulative decoding error.fig');
    hLegend(8) = findobj(gcf, 'Type', 'Legend'); %get legends
    Qdec_3 = openfig('Q-BLU_Day6_16x3_cumulative decoding error.fig');
    hLegend(12) = findobj(gcf, 'Type', 'Legend'); %get legends
    Qdec_2 = openfig('Q-BLU_Day4_16x2_cumulative decoding error.fig');
    hLegend(16) = findobj(gcf, 'Type', 'Legend'); %get legends
    Qdec_1 = openfig('Q-BLU_Day7_16x1_cumulative decoding error.fig');
    hLegend(20) = findobj(gcf, 'Type', 'Legend'); %get legends
    
    % output figure
    cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs'
    axn = DecError_rats_SUB_makeFigure;
    
    figs = [Mdec_8;Mdec_4;Mdec_3;Mdec_2;Mdec_1;Ndec_8;Ndec_4;Ndec_3;Ndec_2;Ndec_1;Pdec_8;Pdec_4;Pdec_3;Pdec_2;Pdec_1;Qdec_8;Qdec_4;Qdec_3;Qdec_2;Qdec_1];
    
    % the numbers of the axes we want to copy and where they want to go
    ax_to_copy     = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    ax_destination = {1,5,9,13,17,2,6,10,14,18,3,7,11,15,19,4,8,12,16,20};
    
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
    
    
    rats = {'M-BLU','N-BLU','P-ORA','Q-BLU'};
    % Add information in each axes
    for a = 1 : length(axn)
        
        title(axn(a),'');
        if a == 1 | a == 5 | a == 9 | a==13 | a==17
            ylabel(axn(a),'Cumulative frequency','FontSize',11)
        end
        if a == 17 | a == 18 | a == 19 | a== 20 
            xlabel(axn(a),'Median decoding error (cm)','FontSize',11)
        end
        if a == 1 | a == 2 | a == 3 | a==4
            title(axn(a),rats{a},'Position',[0.5 1.1 0]);
        end
        b = axn(ax_destination{a});
        legend(axn(a),{hLegend(a).String{1},hLegend(a).String{2},hLegend(a).String{3},hLegend(a).String{4}},'Location','southeast','box','off')
        axn(a).FontSize = 11;
        
    end
    
    save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Combined_figs',[]);




end