%% Function to plot randomly points in a cadrant depending on two bool vectors

function [f] = plotQuadrant(x, y)
    newX = x + 0.8*(rand(size(x)) - 0.5);
    newY = y + 0.8*(rand(size(y)) - 0.5);
    f = scatter(newX, newY, 20, "filled");
    hold on;
    xline(0.5, "k", "LineWidth", 1.5)
    yline(0.5, "k", "LineWidth", 1.5)
    hold off;
    xlim([-0.5 1.5])
    xticks([0, 1])
    xticklabels(["Non Sig.", "Sig."])
    ylim([-0.5 1.5])
    yticks([0, 1])
    yticklabels(["Non Sig.", "Sig."])

end
