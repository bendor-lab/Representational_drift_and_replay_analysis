%% 1. Place field variable + directionality

x = linspace(-5, 5, 100);
y1 = normpdf(x, 0, 1.2);
y2 = 0.3 *normpdf(x, 0, 1.2);

figure;
hold on;
area(x, y1, 'FaceColor', '#4789bb', 'EdgeColor', 'none');
area(x, y2, 'FaceColor', '#e15e4e', 'EdgeColor', 'none');
hold off;
axis off;
axis square;