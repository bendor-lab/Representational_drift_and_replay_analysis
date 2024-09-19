nb_laps_RUN1 = 2;
alpha = pi/(4*nb_laps_RUN1); % Novelty / clustering factor

nb_laps_RUN2 = 16;
x = (1:nb_laps_RUN1) + 1; % Lap vector for RUN1
x2 = (1:nb_laps_RUN2) + 1; % Lap vector for RUN2

getDist = @(x1, y1, x2, y2) ...
          sqrt((x1 - x2).^2 + (y1 - y2).^2);

learn_R1 = @(x) log(x);
learn_R2 = @(x) log(x)/4;

% Compute the coordinates of each point

run1_coor_x = learn_R1(x);
run1_coor_y = repelem(0, 1, nb_laps_RUN1);

run2_coor_x = cos(alpha)*(learn_R1(nb_laps_RUN1+1) + learn_R2(x2));
run2_coor_y = sin(alpha)*(learn_R1(nb_laps_RUN1+1) + learn_R2(x2));

% Get the coordinates of the first lap and of the final place field

B1_x = 0;
B1_y = 0;

B2_x = cos(alpha)*(run1_coor_x(end));
B2_y = sin(alpha)*(run1_coor_x(end));

base_1st_x = run1_coor_x(1);
base_1st_y = run1_coor_y(1);

FPF_x = cos(alpha)*(learn_R1(nb_laps_RUN1 + 1) + learn_R2(20.5));
FPF_y = sin(alpha)*(learn_R1(nb_laps_RUN1 + 1) + learn_R2(20.5));

% Plot the situation

figure;
scatter(run1_coor_x, run1_coor_y, "filled");
hold on;
scatter(run2_coor_x, run2_coor_y, "filled");

scatter(FPF_x, FPF_y, 100, "filled");
scatter(B1_x, B1_y, 70, "filled");
scatter(B2_x, B2_y, 70, "filled");
grid on;

% We compute the distances with the 1st lap - RUN1 and the FPF

% 1st lap

run1_dist_lap1 = getDist(base_1st_x, base_1st_y, ...
                         run1_coor_x, run1_coor_y);

run2_dist_lap1 = getDist(base_1st_x, base_1st_y, ...
                         run2_coor_x, run2_coor_y);

% FPF

run1_dist_fpf = getDist(FPF_x, FPF_y, ...
                         run1_coor_x, run1_coor_y);

run2_dist_fpf = getDist(FPF_x, FPF_y, ...
                         run2_coor_x, run2_coor_y);

% Normalize so that everything ranges from 0 to 1 (pv-correlation)

m = max([run1_dist_lap1 run2_dist_lap1]);
run1_dist_lap1 = run1_dist_lap1/m;
run2_dist_lap1 = run2_dist_lap1/m;

m2 = max([run1_dist_fpf run2_dist_fpf]);
run1_dist_fpf = run1_dist_fpf/m2;
run2_dist_fpf = run2_dist_fpf/m2;


%% 

% Plot of distance with the first lap
figure;
subplot(1, 2, 1);

if numel(x) == 1
    scatter(x, run1_dist_lap1, "filled");
else
    plot(x, run1_dist_lap1, "LineWidth", 1);
end

title("First exposure");
ylabel("Distance with 1st lap");
xlabel("Lap")
grid on;

subplot(1, 2, 2);
plot(x2, run2_dist_lap1, "LineWidth", 1);
title("2nd exposure");
ylabel("Distance with 1st lap");
xlabel("Lap")
grid on;
linkaxes();


% Plot of distance with FPF
figure;
subplot(1, 2, 1);

if numel(x) == 1
    scatter(x, run1_dist_fpf, "filled");
else
    plot(x, run1_dist_fpf, "LineWidth", 1);
end

title("First exposure");
ylabel("Distance with the FPF");
xlabel("Lap")
grid on;

subplot(1, 2, 2);
plot(x2, run2_dist_fpf, "LineWidth", 1);
title("2nd exposure");
ylabel("Distance with the FPF");
xlabel("Lap")
grid on;

linkaxes();