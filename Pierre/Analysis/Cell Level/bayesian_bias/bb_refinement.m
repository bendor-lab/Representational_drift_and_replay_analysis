clear

load("bayesian_bias_cell.mat")
load("../Statistical_Tests/dataRegression.mat")

common_cells_T1 = intersect(bb_data(bb_data.condition == 16, :).cell, ...
                            data(data.condition == 16, :).cell);
common_cells_T2 = intersect(bb_data(bb_data.condition ~= 16, :).cell, ...
                            data(data.condition ~= 16, :).cell);

isInBBData = (ismember(bb_data.cell, common_cells_T1) & bb_data.condition == 16) ...
             | (ismember(bb_data.cell, common_cells_T2) & bb_data.condition ~= 16);

isInData = (ismember(data.cell, common_cells_T1) & data.condition == 16) ...
           | (ismember(data.cell, common_cells_T2) & data.condition ~= 16);

bb_data_com = bb_data(isInBBData, :);
data_com = data(isInData, :);

% Now we merge the two 

mergedData = horzcat(data_com, bb_data_com(:, end-4:end));
mergedData.refinCMabs = abs(mergedData.refinCM);
mergedData.logCondC = log2(mergedData.condition) - mean(log2(mergedData.condition), 'omitnan');

%% 

lme = fitlme(mergedData, "expReexpBias ~ refinCMabs + (1|animal)");
disp(lme);
% Effect of condition on exp/re-exp bias

lme = fitlme(mergedData, "refinCMabs ~ bayesian_bias_sig + (1|animal)");
disp(lme);

lme = fitlme(mergedData, "expReexpBias ~ propPartRep + (1|animal)");
disp(lme);
% Effect of condition on exp/re-exp bayesian bias (weeeeak)

lme = fitlme(mergedData, "bayesian_bias_nsig ~ logCondC + (1|animal)");
disp(lme);
% Same for bias during non-replay bb

lme = fitlme(mergedData, "bayesian_slope_sig ~ logCondC + (1|animal)");
disp(lme);

% No effect on the slope of the bb across time

lme = fitlme(mergedData, "expReexpBias ~ bayesian_bias_sig + (1|animal)");
disp(lme);

%%

uniqueCond = [1 2 3 4 8 16];
figure;
tiledlayout(6, 1);
h = [];
for cID = 1:numel(uniqueCond)
    n = nexttile;
    h(end + 1) = n;
    current_cond = uniqueCond(cID);
    histogram(data.refinCM(data.condition == current_cond), 100);
    hold on;
    xline(mean(data.refinCM(data.condition == current_cond), 'omitnan'), "LineWidth", 3, "Color", "r")
end

linkaxes(h, 'x')

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 

