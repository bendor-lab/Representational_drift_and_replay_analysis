% Function to get the start and end timestamps of the lap N on the track N.

% INPUTS : 
% lap_times : extracted_laps file 
% TrackOI : track of interest for the analysis

% OUTPUTS :
% N : number of laps for this track

function [N] = getNumberLaps(lap_times,TrackOI)

N = length(lap_times(TrackOI).completeLaps_start);
end

