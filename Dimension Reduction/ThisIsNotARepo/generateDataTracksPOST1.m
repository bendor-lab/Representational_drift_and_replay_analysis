load("X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day4_16x8\replayEvents_bayesian_spike_count")
load("X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day4_16x8\Bayesian controls\Only first exposure\significant_replay_events_wcorr")
load("X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day4_16x8\extracted_sleep_state")

timePOST1Start = sleep_state.state_time.INTER_post_start;
timePOST1Stop = sleep_state.state_time.INTER_post_end;

subsetPOST1Bool = cellfun(@(x) x(1) > timePOST1Start && x(end) < timePOST1Stop, {replayEvents_bayesian_spike_count.replay_events(:).replay_time_edges});

good_indices = 1:length(replayEvents_bayesian_spike_count.replay_events);

good_indices = good_indices(subsetPOST1Bool);
goodIdT1 = intersect(good_indices, significant_replay_events.track(1).index);
goodIdT2 = intersect(good_indices, significant_replay_events.track(2).index);
good_indicesAllSign = intersect(good_indices, unique([goodIdT1, goodIdT2]));

seq = [];

for i = 1:length(good_indicesAllSign)
    id = good_indices(i);
    seq(i).trialId = id;
    seq(i).y = replayEvents_bayesian_spike_count.n.replay(:, replayEvents_bayesian_spike_count.replay_events_indices == id);
    seq(i).T = size(seq(i).y, 2);
end

x = struct("seq", {seq});

datFormat = 'seq';
runIdx = 1;
method = 'gpfa';
xDim = 6;
kernSD = 30;

result = neuralTraj(runIdx, x,'datFormat', datFormat, ...
    'method', method, 'xDims', xDim, 'kernSDList', kernSD, 'segLength', Inf);

% Orthonormalize neural trajectories
[estParams, seqTrain] = postprocess(result, 'kernSD', kernSD);
% NOTE: The importance of orthnormalization is described on
%       pp.621-622 of Yu et al., J Neurophysiol, 2009.

cd("D:\Representational_drift_and_replay_analysis\Dimension Reduction\NeuralTraj");
%% PLOTTING

% firstLast = 30;
%
% % Tiled plot, 30 events per 30 events
% figure;
%
% tiledlayout(1, 2);
%
% for i = 1:2
%     nexttile
%     for trackRep = 1:2
%
%         if trackRep == 1
%             goodId = goodIdT1;
%             colorPlot = "r";
%         else
%             goodId = goodIdT2;
%             colorPlot = "b";
%         end
%
%         if i == 1
%             subData = seqTrain(ismember([seqTrain.trialId], goodId));
%             subData = subData(1:firstLast);
%         else
%             subData = seqTrain(ismember([seqTrain.trialId], goodId));
%             subData = subData((end - firstLast):end);
%         end
%
%         for j = 1:length(subData)
%             xOrth = subData(j).xorth;
%             currentId = subData(j).trialId;
%
%             p = plot3(xOrth(1, :), xOrth(2, :), xOrth(3, :), colorPlot);
%             hold on;
%         end
%
%     end
%
%     xlabel('X1')
%     ylabel('X2')
%     zlabel('X3')
% %     xlim([-1, 1])
%       ylim([-1.5, 0.5])
%       zlim([-1.5, 0.5])
%     grid on
%     hold off;
% end


figure;

tiledlayout(1, 2);

axArray = [];

for track = 1:2
    eval("ax" + track +  "= nexttile");
    
    if track == 1
        subData = seqTrain(ismember([seqTrain.trialId], goodIdT1));
    else
        subData = seqTrain(ismember([seqTrain.trialId], goodIdT2));
    end
    
    % We get a random line to be the example
    
    showReplayID = randi([1 length(subData)]);
    
    for j = 1:length(subData)
       
        xOrth = subData(j).xorth;
        currentId = subData(j).trialId;
        
        if j == showReplayID
            p = plot(xOrth(1, :), xOrth(2, :), "r", 'LineWidth', 4);
            hold on;
        else
            p = plot(xOrth(1, :), xOrth(2, :), "k");
            hold on;
        end
    end
    
    xlabel('X1')
    ylabel('X2')
    grid on
    hold off;
end

linkprop([ax1 ax2], "YLim")
linkprop([ax1 ax2], "XLim")

%% 

figure;

tiledlayout(1, 2);

axArray = [];

for track = 1:2
    eval("ax" + track +  "= nexttile");
    
    X1 = [];
    X2 = [];
    
    if track == 1
        subData = seqTrain(ismember([seqTrain.trialId], goodIdT1));
    else
        subData = seqTrain(ismember([seqTrain.trialId], goodIdT2));
    end
    
    
    for j = 1:length(subData)
       
        xOrth = subData(j).xorth;        
        X1 = [X1 xOrth(1, :)];
        X2 = [X2 xOrth(2, :)];
        
    end
    
    pts = linspace(-5, 5, 500);
    
    N = histcounts2(X1(:), X2(:), pts, pts);
    
    
    % Plot heatmap:
    imagesc(pts, pts, N);
    colorbar;
    axis equal;
    set(gca, 'XLim', [-0.25 0.25], 'YLim', [-0.25 0.25], 'YDir', 'normal');
    
    xlabel('X1')
    ylabel('X2')
    grid on
    hold off;
end