% Function that gives the participation in nb of spikes of 
% a vector of cell, given a track, a lap, lap_times and clusters of spikes

function [activation_vector] = getParticipationDuringLap(cellVector, track, lap, lap_times, clusters, varargin)
    
    % Last special arg : full laps or half-laps (for 16x1)
    if nargin == 5
        LapStart = lap_times(track).completeLaps_start(lap); % Beginning of the target lap
        LapStop = lap_times(track).completeLaps_stop(lap); % End of the last lap
        
    elseif nargin == 6
        
        LapStart = lap_times(track).halfLaps_start(lap); % Beginning of the target lap
        LapStop = lap_times(track).halfLaps_stop(lap); % End of the last lap
    end
    
    boolMatIsSpikePeriod = clusters.spike_times <= LapStop & clusters.spike_times >= LapStart;
    
    [nbSpikesPeriod, cellPeriod] = groupcounts(clusters.spike_id(boolMatIsSpikePeriod));
    
    nbSpikesPeriod = nbSpikesPeriod(ismember(cellPeriod, cellVector));
    
    cellPeriod = cellPeriod(ismember(cellPeriod, cellVector));
    
    [~, position] = ismember(cellPeriod, cellVector);
    
    activation_vector = repelem(0, length(cellVector));
    
    activation_vector(position) = nbSpikesPeriod;
    
   
end

