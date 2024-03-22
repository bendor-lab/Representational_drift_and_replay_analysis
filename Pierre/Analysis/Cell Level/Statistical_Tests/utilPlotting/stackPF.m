function [] = stackPF(mat, tit, leg)

imshow(mat, "Border","tight")
title(tit)
xlabel("Position (cm)")
ylabel(leg)
axis on

% Set the locations of the ticks
xticks([1 50 100]);
yticks([1 numel(mat(:, 1))]);
% Set the labels of the ticks
xticklabels({"0", "100", "200"})
yticklabels({"Cell " + numel(mat(:, 1)), "Cell 1"});

end