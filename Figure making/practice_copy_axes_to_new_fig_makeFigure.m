
function axn = practice_copy_axes_to_new_fig_makeFigure
% function to make figure: 

fig = figure('units','centimeters','position',[5.5          1.5         36.5           20]);
fig.Name = '' ;

axn(1) = axes('next','add','units','centimeters','Position',[2  12   7   7],'View', [0  90]);
title('axes1','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(2) = axes('next','add','units','centimeters','Position',[10  12  20   7],'View', [0  90]);
title('axes2','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(3) = axes('next','add','units','centimeters','Position',[3  5  4  4],'View', [0  90]);
title('axes3','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(4) = axes('next','add','units','centimeters','Position',[10   4  20   7],'View', [0  90]);
title('axes4','Units', 'normalized', 'Position', [0.5, 0.5]);

axn(5) = axes('next','add','units','centimeters','Position',[32   4   4  15],'View', [0  90]);
title('axes5','Units', 'normalized', 'Position', [0.5, 0.5]);


