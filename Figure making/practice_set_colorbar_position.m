% practice set_colorbar_position

figure
axn(1) = subplot(221,'units','centimeters');
axpos  = get(axn(1),'position');
pcolor(rand(10))
cb1 = colorbar;
set_colorbar_position(cb1,axpos,'right')

% doesn't work if not in cm
axn(2) = subplot(222); 
pcolor(rand(30))
cb2 = colorbar('units','centimeters');
set_colorbar_position(cb2,get(axn(2),'position'),'right')
 
% weirdly works if run all together, but not line by line...
axn(3)= subplot(2,2,3:4,'units','centimeters');
pcolor(rand(20))
cb3 = colorbar;
set_colorbar_position(cb3,get(axn(3),'position'),'right-top')
