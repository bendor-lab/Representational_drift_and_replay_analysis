% Function that gives the participation in nb of events of 
% a vector of cell, given a track during run, the track decoded during replay, a list of significant RE and
% decoded RE

function [activation_vector] = getReplayParticipationDuringTrack(cellVector, runningTrack, replayedTrack, ...
                                                                 lap_times, significantRE, decodedRE)

    
    
    TrackStarts = lap_times(runningTrack).halfLaps_start(1); % Beginning of the first lap
    TrackStop = lap_times(runningTrack).halfLaps_stop(end); % End of the last lap
    
    % We get the ID of the significant replay events in this period
    
    goodSignReplayData = significantRE.track(replayedTrack);
    
    boolMatIsReplayPeriod = goodSignReplayData.event_times <= TrackStop & goodSignReplayData.event_times >= TrackStarts;
    
    relevantReplayID = goodSignReplayData.index(boolMatIsReplayPeriod);
    
    % We find the corresponding cell data in decoded (more info than
    % significant file)
    
    allSpikesCells = {decodedRE(replayedTrack).replay_events(relevantReplayID).spikes};
    
    concatAllCellsInv = []; % We initiate the table with an impossible cell ID, will disappear
    
    for RE = allSpikesCells
        temp = RE{1};
        concatAllCellsInv = [concatAllCellsInv; unique(temp(:, 1))]; % Unique gives only one RE to unique cells, without you count spikes.
    end
    
    [nbSpikesPeriod, cellPeriod] = groupcounts(concatAllCellsInv);
    
    nbSpikesPeriod = nbSpikesPeriod(ismember(cellPeriod, cellVector));
    
    cellPeriod = cellPeriod(ismember(cellPeriod, cellVector));
    
    [~, position] = ismember(cellPeriod, cellVector);
    
    activation_vector = repelem(0, length(cellVector));
    
    activation_vector(position) = nbSpikesPeriod;
    
   
end

