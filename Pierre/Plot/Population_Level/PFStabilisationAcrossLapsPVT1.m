% Reproduction of one of Martha / Masa's plot - PF stabilisation across
% laps ONLY FOR T1 / T3 (cause PFP)

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

listFilesToTest = ["\..\..\Data\population_vector_laps.mat", "\..\..\Data\population_vector_lapsLap16RUN1.mat", ...
    "\..\..\Data\population_vector_lapsLap16RUN2.mat"];

for path = listFilesToTest(1)
    for norm = 1:2 % 1 - no, 2 - yes
        for computToUse = 1:3 % 1 - mean, 2 - median, 3 - max
            % We get the PV file
            load(PATH.SCRIPT + path);
            
            % For all animals and conditions, we mean all laps of T1 and all laps of T2
            % 3 vectors for our 3 variables.
            % We finally cut T1 laps to 16, same for T2
            
            matCorrT1 = repelem(NaN, length(population_vector_laps), 20); % We overshot the size to be sure
            matEuclidianT1 = repelem(NaN, length(population_vector_laps), 20);
            matCosSimT1 = repelem(NaN, length(population_vector_laps), 20);
            
            matCorrT3 = repelem(NaN, length(population_vector_laps), 20); % We overshot the size to be sure
            matEuclidianT3 = repelem(NaN, length(population_vector_laps), 20);
            matCosSimT3 = repelem(NaN, length(population_vector_laps), 20);
            
            count_T1 = 1;
            count_T3 = 1;
            
            for i = 1:length(population_vector_laps)
                line = population_vector_laps(i);
                track = line.track;
                
                nbLaps = length(line.allLaps);
                
                if norm == 1
                    synthData = struct("pvCorrelation", {line.allLaps.pvCorrelation}, ...
                                       "euclidianDistance", {line.allLaps.euclidianDistance}, ...
                                       "cosineSim", {line.allLaps.cosineSim});
                else
                    synthData = struct("pvCorrelation", {line.allLaps.pvCorrelationNorm}, ...
                                       "euclidianDistance", {line.allLaps.euclidianDistanceNorm}, ...
                                       "cosineSim", {line.allLaps.cosineSimNorm});
                end
                
                if computToUse == 1
                    vectorCorrelation = cellfun(@(x) mean(x, "omitnan"), {synthData.pvCorrelation})';
                    vectorEuclidian = cellfun(@(x) mean(x, "omitnan"), {synthData.euclidianDistance})';
                    vectorCosSim = cellfun(@(x) mean(x, "omitnan"), {synthData.cosineSim})';
                elseif computToUse == 2
                    vectorCorrelation = cellfun(@(x) median(x, "omitnan"), {synthData.pvCorrelation})';
                    vectorEuclidian = cellfun(@(x) median(x, "omitnan"), {synthData.euclidianDistance})';
                    vectorCosSim = cellfun(@(x) median(x, "omitnan"), {synthData.cosineSim})';
                else
                    vectorCorrelation = cellfun(@(x) max(x), {synthData.pvCorrelation})';
                    vectorEuclidian = cellfun(@(x) max(x), {synthData.euclidianDistance})';
                    vectorCosSim = cellfun(@(x) max(x), {synthData.cosineSim})';
                end
                
                if track == 1
                    matCorrT1(count_T1, 1:nbLaps) = vectorCorrelation;
                    matEuclidianT1(count_T1, 1:nbLaps) = vectorEuclidian;
                    matCosSimT1(count_T1, 1:nbLaps) = vectorCosSim;
                    count_T1 = count_T1 + 1;
                else
                    matCorrT3(count_T3, 1:nbLaps) = vectorCorrelation;
                    matEuclidianT3(count_T3, 1:nbLaps) = vectorEuclidian;
                    matCosSimT3(count_T3, 1:nbLaps) = vectorCosSim;
                    count_T3 = count_T3 + 1;
                end
            end
            
            % Now we can crop the matrices at lap 16
            
            matCorrT1 = matCorrT1(1:count_T1, 1:16);
            matEuclidianT1 = matEuclidianT1(1:count_T1, 1:16);
            matEuclidianT1(isinf(matEuclidianT1)) = NaN;
            matCosSimT1 = matCosSimT1(1:count_T1, 1:16);
            matCorrT3 = matCorrT3(1:count_T3, 1:16);
            matEuclidianT3 = matEuclidianT3(1:count_T3, 1:16);
            matCosSimT3 = matCosSimT3(1:count_T3, 1:16);
            
            % Now we compute the column mean and std of each one, then plot it
            
            if path == "\..\..\Data\population_vector_laps.mat"
                compared = "FPF";
            elseif path == "\..\..\Data\population_vector_lapsLap16RUN1.mat"
                compared = "R1 - L16";
            else
                compared = "R2 - L16";
            end
            
            %% Plotting -----------------------------------------------------------
            
            figure;
            
            t = tiledlayout(3, 2);
            
            ax1 = plotEvolution(matCorrT1, "r", "corr(RUN1, " + compared + ")");
            ax2 = plotEvolution(matCorrT3, "r", "corr(RUN2, " + compared + ")");
            
            ax3 = plotEvolution(matEuclidianT1, "b", "EuclDist(RUN1, " + compared + ")");
            ax4 = plotEvolution(matEuclidianT3, "b", "EuclDist(RUN2, " + compared + ")");
            
            ax5 = plotEvolution(matCosSimT1, "g", "CosSim(RUN1, " + compared + ")");
            ax6 = plotEvolution(matCosSimT3, "g", "CosSim(RUN2, " + compared + ")");
            
            linkaxes([ax1 ax2],'xy')
            linkaxes([ax3 ax4],'xy')
            linkaxes([ax5 ax6],'xy')
            
            if norm == 1
                labelNorm = "PF not normalised";
            else
                labelNorm = "PF normalised";
            end
            if computToUse == 1
                title(t, "PV Mean Metrics Evolution - " + labelNorm);
            elseif computToUse == 2
                title(t, "PV Median Metrics Evolution - " + labelNorm);
            else
                title(t, "PV Max Metrics Evolution - " + labelNorm);
            end
            
        end
    end
    
end

function [ax] = plotEvolution(xMat, color, label)
ax = nexttile;
xMean = mean(xMat, "omitnan");
xStd = std(xMat, "omitnan");
plot(1:16, xMean, color);
title(label)
xlabel(ax, 'Lap');
ylabel(ax, 'Metric');

hold on;
x = 1:length(xMean);
shade1 = xMean + xStd;
shade2 = xMean - xStd;
x2 = [x,fliplr(x)];
inBetween = [shade1,fliplr(shade2)];
h=fill(x2,inBetween,color);
set(h,'facealpha',0.1,'LineStyle','none')
hold off;

end