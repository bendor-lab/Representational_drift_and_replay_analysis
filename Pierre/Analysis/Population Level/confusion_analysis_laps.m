% Look at the track confusion across laps
clear

load("confusion_file.mat");

allData_concat = [repelem({NaN(40, 40)}, 8)];

for fID = 1:numel([confusion.fID])
    all_laps = numel(confusion(fID).exposure);
    for l = 1:all_laps
        current_mat = confusion(fID).exposure{l};
        % We change the matrix to make the long diagonal
        current_mat = [current_mat(21:40, :); current_mat(1:20, :)];
        % Concat the NaN matrix with the new matrix
        allData_concat{l} = cat(3, allData_concat{l}, current_mat);
    end
end

number_obs = cell2mat(cellfun(@(x) size(x, 3), allData_concat, 'UniformOutput', false)) - 1;
allData_concat = cellfun(@(x) mean(x, 3, 'omitnan'), allData_concat, 'UniformOutput', false);

figure;
tiledlayout(2, 4);

for el = 1:numel(allData_concat)
    nexttile;
    clims = [0 1];
    imagesc(allData_concat{el}, clims);
    xline(20.5, 'w');
    yline(20.5, 'w');
    axis on;
    xticks([10.5, 30.5])
    xticklabels(["T1", "T2"]);
    yticks([10.5, 30.5])
    yticklabels(["T2", "T1"]);
    title("Lap " + el + " (n = " + number_obs(el) + ")");

    if el == 1
        xlabel("Real position");
        ylabel("Decoded position")
    end
end

h = colorbar;
h.Limits = [0, 1];