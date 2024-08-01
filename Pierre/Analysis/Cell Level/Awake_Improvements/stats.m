clear
load("stabilisation_fluc.mat");

current_variables = string(data.Properties.VariableNames(8:end));

sum1 = groupsummary(data, ["condition", "exposure", "lap"], ...
                          ["mean", "std"], current_variables);

% Compute the standard error

for v = current_variables
    goal_name = "se_" + v;
    target_name = "std_" + v;
    sum1.(goal_name) = sum1.(target_name)./sqrt(sum1.GroupCount);
end