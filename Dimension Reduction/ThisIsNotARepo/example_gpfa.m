% ====
% GPFA DEMO
% ====
% Section 1 provides an example where GPFA is used to extract neural
% trajectories for a specified latent dimensionality.
%
% Section 2 shows how to select the optimal dimensionality (and kernel
% width for two-stage methods) using cross-validation to compare
% leave-neuron-out prediction errors for GPFA, FA, PPCA and PCA.

% =====
% TIPS
% =====
% - For exploratory analysis using GPFA, we often run only Section 1
%   below, and not Section 2 (which finds the optimal latent
%   dimensionality).  This can provide a substantial savings in running
%   time, since running Section 2 takes roughly K times as long as
%   Section 1, where K is the number of cross-validation folds.  As long
%   as we use a latent dimensionality that is 'large enough' in Section 1,
%   we can roughly estimate the latent dimensionality by looking at
%   the plot produced by plotEachDimVsTime.m.  The optimal latent
%   dimensionality is approximately the number of top dimensions that
%   have 'meaningful' temporal structure.  For visualization purposes,
%   this rough dimensionality estimate is usually sufficient.
%
% - For exploratory analysis with the two-stage methods, we MUST run
%   Section 2 to obtain the optimal smoothing kernel width.  There is
%   no easy way estimate the optimal smoothing kernel width from the
%   results of Section 1.

% ===========================================
% 1) Basic extraction of neural trajectories
% ===========================================
% load('mat_sample/sample_dat');

% Test : replay of animals
clear

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
good_indicesAllSign = intersect(good_indices, intersect(goodIdT1, goodIdT2));

seq = [];

for i = 1:length(good_indicesAllSign)
    id = good_indices(i);
    seq(i).trialId = i;
    seq(i).y = replayEvents_bayesian_spike_count.n.replay(:, replayEvents_bayesian_spike_count.replay_events_indices == id);
    seq(i).T = size(seq(i).y, 2);
end

x = struct("seq", {seq});

% datFormat is set to 'spikes' for 0/1 spiking activity (see neuralTraj.m)
datFormat = 'seq';

% Results will be saved in mat_results/runXXX/, where XXX is runIdx.
% Use a new runIdx for each dataset.
runIdx = 1;

% Select method to extract neural trajectories:
% 'gpfa'   -- Gaussian-process factor analysis
% 'fa'     -- Smooth and factor analysis
% 'ppca'   -- Smooth and probabilistic principal components analysis
% 'pca'    -- Smooth and principal components analysis
method = 'gpfa';

% Select number of latent dimensions
xDim = 6;
% NOTE: The optimal dimensionality should be found using 
%       cross-validation (Section 2) below.

% If using a two-stage method ('fa', 'ppca', or 'pca'), select
% standard deviation (in msec) of Gaussian smoothing kernel.
kernSD = 30;
% NOTE: The optimal kernel width should be found using 
%       cross-validation (Section 2) below.

% Extract neural trajectories
result = neuralTraj(runIdx, x,'datFormat', datFormat, ...
    'method', method, 'xDims', xDim, 'kernSDList', kernSD, 'segLength', Inf);
% NOTE: This function does most of the heavy lifting.

% Orthonormalize neural trajectories
[estParams, seqTrain] = postprocess(result, 'kernSD', kernSD);
% NOTE: The importance of orthnormalization is described on 
%       pp.621-622 of Yu et al., J Neurophysiol, 2009.

% Plot neural trajectories in 3D space
plot3D(seqTrain, 'xorth', 'dimsToPlot', 1:3);
% NOTES:
% - This figure shows the time-evolution of neural population
%   activity on a single-trial basis.  Each trajectory is extracted from
%   the activity of all units on a single trial.
% - This particular example is based on multi-electrode recordings
%   in premotor and motor cortices within a 400 ms period starting 300 ms 
%   before movement onset.  The extracted trajectories appear to
%   follow the same general path, but there are clear trial-to-trial
%   differences that can be related to the physical arm movement. 
% - Analogous to Figure 8 in Yu et al., J Neurophysiol, 2009.
% WARNING:
% - If the optimal dimensionality (as assessed by cross-validation in 
%   Section 2) is greater than 3, then this plot may mask important 
%   features of the neural trajectories in the dimensions not plotted.  
%   This motivates looking at the next plot, which shows all latent 
%   dimensions.

% Plot each dimension of neural trajectories versus time
plotEachDimVsTime(seqTrain, 'xorth', result.binWidth);
% NOTES:
% - These are the same neural trajectories as in the previous figure.
%   The advantage of this figure is that we can see all latent
%   dimensions (one per panel), not just three selected dimensions.  
%   As with the previous figure, each trajectory is extracted from the 
%   population activity on a single trial.  The activity of each unit 
%   is some linear combination of each of the panels.  The panels are
%   ordered, starting with the dimension of greatest covariance
%   (in the case of 'gpfa' and 'fa') or variance (in the case of
%   'ppca' and 'pca').
% - From this figure, we can roughly estimate the optimal
%   dimensionality by counting the number of top dimensions that have
%   'meaningful' temporal structure.   In this example, the optimal 
%   dimensionality appears to be about 5.  This can be assessed
%   quantitatively using cross-validation in Section 2.
% - Analogous to Figure 7 in Yu et al., J Neurophysiol, 2009.

fprintf('\n');
fprintf('Basic extraction and plotting of neural trajectories is complete.\n');
fprintf('Press any key to start cross-validation...\n');
fprintf('[Depending on the dataset, this can take many minutes to hours.]\n');
pause;


% ========================================================
% 2) Full cross-validation to find:
%  - optimal state dimensionality for all methods
%  - optimal smoothing kernel width for two-stage methods
% ========================================================

% Select number of cross-validation folds
numFolds = 4;

% Perform cross-validation for different state dimensionalities.
% Results are saved in mat_results/runXXX/, where XXX is runIdx.
xDims = [2 5 8];

% If 'parallelize' is true, all folds will be run in parallel using 
% Matlab's parfor construct. If you have access to multiple cores, this 
% provides significant speedup. 

parallelize = true;
neuralTraj(runIdx, dat, 'datFormat', datFormat, 'method',  'pca', ...
    'xDims', xDims, 'numFolds', numFolds, 'parallelize', parallelize);
neuralTraj(runIdx, dat, 'datFormat', datFormat, 'method', 'ppca', ...
    'xDims', xDims, 'numFolds', numFolds, 'parallelize', parallelize);
neuralTraj(runIdx, dat, 'datFormat', datFormat, 'method',   'fa', ...
    'xDims', xDims, 'numFolds', numFolds, 'parallelize', parallelize);
neuralTraj(runIdx, dat, 'datFormat', datFormat, 'method', 'gpfa', ...
    'xDims', xDims, 'numFolds', numFolds, 'parallelize', parallelize);

fprintf('\n');
% NOTES:
% - These function calls are computationally demanding.  Cross-validation 
%   takes a long time because a separate model has to be fit for each 
%   state dimensionality and each cross-validation fold.

% Plot prediction error versus state dimensionality.
% Results files are loaded from mat_results/runXXX/, where XXX is runIdx.
kernSD = 30; % select kernSD for two-stage methods
plotPredErrorVsDim(runIdx, kernSD);
% NOTES:
% - Using this figure, we i) compare the performance (i.e,,
%   predictive ability) of different methods for extracting neural
%   trajectories, and ii) find the optimal latent dimensionality for
%   each method.  The optimal dimensionality is that which gives the
%   lowest prediction error.  For the two-stage methods, the latent
%   dimensionality and smoothing kernel width must be jointly
%   optimized, which requires looking at the next figure.
% - In this particular example, the optimal dimensionality is 5. This
%   implies that, even though the raw data are evolving in a
%   53-dimensional space (i.e., there are 53 units), the system
%   appears to be using only 5 degrees of freedom due to firing rate
%   correlations across the neural population.
% - Analogous to Figure 5A in Yu et al., J Neurophysiol, 2009.

% Plot prediction error versus kernelSD.
% Results files are loaded from mat_results/runXXX/, where XXX is runIdx.
xDim = 5; % select state dimensionality
plotPredErrorVsKernSD(runIdx, xDim);
% NOTES:
% - This figure is used to find the optimal smoothing kernel for the
%   two-stage methods.  The same smoothing kernel is used for all units.
% - In this particular example, the optimal standard deviation of a
%   Gaussian smoothing kernel with FA is 30 ms.
% - Analogous to Figures 5B and 5C in Yu et al., J Neurophysiol, 2009.