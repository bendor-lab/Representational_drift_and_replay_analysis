function practice_copy_axes_to_new_fig

%input figures
% could either load (or create) with handle 

fig1 = figure;
pcolor(rand(10)) % want this in axn(3)
xlabel('hello')
ylabel('marta')

fig2 = figure;
subplot(121)
plot(1:10,rand(10,1)) % want this in axn(2)
legend('yo')
subplot(122,'next','add')
plot(rand(8))   % want this in axn(4)

fig3 = figure;
subplot(311)
plot(rand(100,1))
subplot(312)
scatter(rand(15,1),rand(15,1)) % want this is axn(1)
subplot(313)
pcolor(rand(5,20))% want this is axn(5)
colorbar

figs = [fig1; fig2; fig3];

% OR use findobj to get figure handles (which figure is which will depend
% on order loaded I think)

figs = flip(findobj('type','figure')); % flip to get in order of fig1,2,3 as above

% the numbers of the axes we want to copy and where they want to go
ax_to_copy     = {1,[1 2],[2 3]};
ax_destination = {3,[2 4],[1 5]};

% output figure
axn = practice_copy_axes_to_new_fig_makeFigure;

for n = 1:size(figs,1)
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
