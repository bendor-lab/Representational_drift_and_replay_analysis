
% DATA FROM:
% PORA 1 lap; PORA 2 laps; PORA 3 laps; PORA 4 laps; QBLU 8 laps
% PORA 16x3 T1; QBLU 16x8 T3 T4



function create_average_thetaseq_figures

cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Averaged theta sequences\figures')
lap_1 = openfig('Smoothed concat average theta seq_P-ORA_16x1.fig');
lap_2 = openfig('Smoothed concat average theta seq_P-ORA_16x2.fig');
lap_3 = openfig('Smoothed concat average theta seq_P-ORA_16x3.fig');
lap_4 = openfig('Smoothed concat average theta seq_P-ORA_16x4.fig');
lap_8 = openfig('Smoothed concat average theta seq_Q-BLU_16x8.fig');

figs = [lap_1; lap_2; lap_3; lap_4; lap_8];

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {10,10,[9,10],10,[10,11,12]};
ax_destination = {1,2,[6,3],4,[5,7,8]};

% output figure
axn = average_thetaSeq_figureAxes_makeFigure;

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

heads = {'1 Lap','2 Laps','3 Laps','4 Laps','8 Laps', '16 Laps', 'R-T1','R-T2'};        
colormap(jet)


% Add information in each axes
for a = 1 : length(axn)
    set(axn(a),'ydir','reverse','XTick',[2,7,12,17,22,27], 'XTickLabel',{'-2\pi','-\pi','0','\pi','2\pi','5\pi/2'},...
        'YTick',[1 20 40],'YTickLabel',{'40','0','-40'})
    axis(axn(a),'tight')
    title(axn(a),heads{a},'Fontsize',18,'Position',[0.5 1]);
    
    if a == 1 || a == 5
        ylabel(axn(a),'Position (cm)','FontSize',16)
    elseif a == 4
        annotation('textbox',[0.9,0.83,0.05,0.1],'String','Ahead','FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.9,0.52,0.05,0.1],'String','Behind','FitBoxToText','on','EdgeColor','none','FontSize',17);
    elseif a == 8
        annotation('textbox',[0.9,0.36,0.05,0.1],'String','Ahead','FitBoxToText','on','EdgeColor','none','FontSize',17);
        annotation('textbox',[0.9,0.04,0.05,0.1],'String','Behind','FitBoxToText','on','EdgeColor','none','FontSize',17);
    elseif a > 4
        xlabel(axn(a),'Phase','FontSize',16)
    end
end
axes('Position',axn(1).Position,'XColor',[1 1 1],'YColor',[1 1 1],'Color','none')

close Figure 1 Figure 2 Figure 3 Figure 4

save_all_figures(pwd,[])







end
