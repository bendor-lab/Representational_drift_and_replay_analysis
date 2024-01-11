% changing elements of already plotted figures

%% eg changing marker size
figure;
subplot(131)
plot(randn(10,1),rand(10,1),'LineStyle','none','marker','o','markersize',10,'MarkerFaceColor','r')
subplot(132)
scatter(rand(10,1),randn(10,1),50,'MarkerFaceColor','b')
subplot(133)
plot(randn(30,1),rand(30,1),'LineStyle','none','marker','o','markersize',15,'MarkerFaceColor','g')

% first you need the axes handle(s)
axn = gca;
axn = findall(gcf,'Type','axes');

% if you used 'plot'
l = findobj(axn,'type','line');
set(l,'MarkerSize',5)
% OR if you're only changing markers in one axis
l.MarkerSize = 5;

% you if used 'scatter'
s = findobj(axn,'type','scatter');
set(s,'SizeData',5)
% OR if you're only changing markers in one axis
s.SizeData = 5;

%% if you don't know what the specific thing you're looking for is called 
% just run:
obj = findobj(axn); % and then look whats in the obj variable 
% type "obj" in to command window and run (will give list of graphics objects found)
% can then choose a type of graphics object in script ie:
l = findobj(axn,'type','line');
% or just run eg
l = obj(4); % (if line object is the 4th on the list)
% then you can find out which properties you can edit by:
% just typing "l" in cmd and running
% or type "l." then press tab and look at the pop up list
