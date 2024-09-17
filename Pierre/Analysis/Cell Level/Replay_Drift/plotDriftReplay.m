% Function to plot the evolution of decoded positions during replay events
% MODES :
% 1) Every spike decoded from every replay from all sleep
% 2) Every replay event (diff. spikes meaned)
% 3) Replay events meaned over 5 minutes

function [f] = plotDriftReplay(fields_replay, place_fields_BAYESIAN, ...
    trackOI, cellOI, mode)

if numel(fields_replay) == 0
    disp("Not enough replay events ! ");
end

a = []; % Matrix of all decoded positions
nb_elem = [];

for i  = 1:numel(fields_replay)
    if mode == 1 % If every spike
        nb_elem(end + 1) = numel(fields_replay{i});
        for j = 1:numel(fields_replay{i})
            a = [a fields_replay{i}{j}];
        end
        
    elseif mode == 2
        nb_elem(end + 1) = 1;
        mean_dec_pos = [];
        for j = 1:numel(fields_replay{i})
            mean_dec_pos = [mean_dec_pos fields_replay{i}{j}];
        end
        
        a = [a mean(mean_dec_pos, 2)]; % Add the mean of all dec pos
    else
        continue
    end
end

nb_elem = cumsum(nb_elem);

f = figure;



% Place field before sleep
subplot(1, nb_elem(end) + 4, 1:2);
previous_pf = place_fields_BAYESIAN.track(trackOI).smooth{cellOI}';
previous_pf = previous_pf / sum(previous_pf); % Normalize
% imagesc(previous_pf);
plot(previous_pf(end:-1:1), "m", "LineWidth", 1.5);
camroll(90);
xlim([1 20]);
axis off;

% Place field during sleep
subplot(1, nb_elem(end) + 4, 3:(2+nb_elem(end)));
imagesc(a);
hold on;

for i = 1:numel(fields_replay)
    plot([nb_elem(i) + 0.5, nb_elem(i) + 0.5], [0, 20.5], "r", "LineWidth", 0.75);
end

set(gca,'ytick',[])

% Place field after sleep
subplot(1, nb_elem(end) + 4, (3+nb_elem(end)):(4+nb_elem(end)));
next_pf = place_fields_BAYESIAN.track(trackOI + 2).smooth{cellOI}';
next_pf = next_pf / sum(next_pf); % Normalize
% imagesc(next_pf);
plot(next_pf, "r", "LineWidth", 1.5);
camroll(270);
xlim([1 20]);
axis off;

% We determine the good limit for the two place fields
global_max = max([previous_pf; next_pf]);

subplot(1, nb_elem(end) + 4, 1:2);
ylim([0 global_max]);
subplot(1, nb_elem(end) + 4, (3+nb_elem(end)):(4+nb_elem(end)));
ylim([0 global_max]);

end

