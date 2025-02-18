clear

load("../timeSeries.mat");
% load("../new_data_2_last_lapT1R1.mat");

% Now we merge RUN1 and RUN2

merged_data = data([], :);

for sID = 1:19
    subset = data(data.sessionID == sID, :);
    all_conditions = unique(subset.condition);
    for c = all_conditions'
        nb_lap_RUN1 = max(subset.lap(subset.exposure == 1 & ...
            subset.condition == c, :));

        subset.lap(subset.exposure == 2 & subset.condition == c, :) = ...
            subset.lap(subset.exposure == 2 & subset.condition == c, :) + nb_lap_RUN1;

    end

    merged_data = [merged_data; subset];
end

%%

summ = groupsummary(merged_data, ["condition", "lap"], ["median", "std"], ...
    ["pvCorr", "speed"]);

h = [];

for c = [1 2 3 4 8 16]
    subset = summ(summ.condition == c, :);

    p = plot(subset.lap, subset.median_pvCorr, "LineWidth", 2);
    hold on;

    h(end + 1) = p;

    scatter(c + 1, subset.median_pvCorr(subset.lap == c+1), "filled", ...
        MarkerEdgeColor = p.Color, MarkerFaceColor = [1 1 1]);

    hold on;
    grid on;
end

legend(h, {"1", "2", "3", "4", "8", "16"})

% Stabilisation seems to be acquired way faster for few laps

%% ---

h = [];
all_animals = unique(merged_data.animal)';

for anim = all_animals

    figure;
    sub = merged_data(merged_data.animal == anim, :);
    all_sID = unique(sub.sessionID);

    for sID_n = 1:numel(all_sID)

        sID = all_sID(sID_n);
        subplot(1, numel(all_sID), sID_n)

        subset = sub(sub.sessionID == sID, :);
        sub_t1 = subset(subset.condition == 16, :);
        sub_t2 = subset(subset.condition ~= 16, :);

        current_condition = sub_t2.condition(1);

        p1 = plot(sub_t1.lap(1:end-1), diff(sub_t1.pvCorr), "LineWidth", 2);
        hold on;
        p2 = plot(sub_t2.lap(1:end-1), diff(sub_t2.pvCorr), "LineWidth", 2);
        
        d1 = diff(sub_t1.pvCorr);
        d2 = diff(sub_t2.pvCorr);

        scatter(17, d1(17), ...
            "filled", MarkerEdgeColor = p1.Color, MarkerFaceColor = [1 1 1]);

        scatter(current_condition + 1, d2(current_condition + 1), ...
            "filled", MarkerEdgeColor = p2.Color, MarkerFaceColor = [1 1 1]);

        title(current_condition + " laps");

        if sID_n == numel(all_sID)
            legend([p1, p2], {"Track 1", "Track 2"});
        end

        grid on;
    end

    linkaxes();

    sgtitle(anim);
end

% Stabilisation seems to be acquired way faster for few laps

%% Analysis of savings

sID = [];
condition = [];
jump_T1 = [];
jump_T2 = [];

for curr_sID = 1:19
    subset = data(data.sessionID == curr_sID, :);
    curr_condition = unique(subset.condition);
    curr_condition = curr_condition(1);

    % We want to see if the jump induced by rest is bigger in condition
    % non-16 than 16

    nb_lap_RUN1_T2 = max(subset.lap(subset.exposure == 1 & ...
        subset.condition ~= 16));

    curr_jump_T2 = subset.pvCorr(subset.exposure == 2 & ...
        subset.condition ~= 16 & ...
        subset.lap == 1) - ...
        subset.pvCorr(subset.exposure == 1 & ...
        subset.condition ~= 16 & ...
        subset.lap == nb_lap_RUN1_T2);

    curr_jump_T1 = subset.pvCorr(subset.exposure == 1 & ...
        subset.condition == 16 & ...
        subset.lap == nb_lap_RUN1_T2+1) - ...
        subset.pvCorr(subset.exposure == 1 & ...
        subset.condition == 16 & ...
        subset.lap == nb_lap_RUN1_T2);



    sID(end + 1, 1) = curr_sID;
    condition(end + 1, 1) = curr_condition;
    jump_T1(end + 1, 1) = curr_jump_T1;
    jump_T2(end + 1, 1) = curr_jump_T2;

end

savings = table(sID, condition, jump_T1, jump_T2);

conditions = [1 2 3 4 8 16];
cmap = [255,128,134;
    255,128,72;
    240,128,23;
    229,77,0;
    182,0,0;
    0,0,0]/255;

figure;

leg = [];

for i = 1:6
    c = conditions(i);
    subset_T1 = savings.jump_T1(savings.condition == c);
    subset_T2 = savings.jump_T2(savings.condition == c);

    x1 = repelem(3*i-0.5, numel(subset_T1), 1);
    x2 = repelem(3*i+0.5, numel(subset_T1), 1);

    scatter(x1, subset_T1, [], cmap(i, :));

    hold on;
    s = scatter(x2, subset_T2, [], cmap(i, :), "filled");
    leg(end + 1) = s;
    grid on;

end

legend(leg, {"1", "2", "3", "4", "8", "16"})
xlabel("Condition")
ylabel("Savings between lap c and c+1")

%% Analysis

savings.compairson = savings.jump_T1 - savings.jump_T2;

fitlm(savings, "compairson ~ condition")

% Results : The rest does not get you FURTHER from  the original
% representation, but it make you CLOSER

