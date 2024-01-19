% Function to get the start and end timestamps of the lap N on the track N.

% INPUTS : 
% lap_times : extracted_laps file 
% TrackOI : track of interest for the analysis
% LapN : Index of the lap we're interested in

% OUTPUTS :
% startTime : start of the lap timestamp
% endTime : end of the lap timestamp

function [startTime,endTime] = getTimeLapN(lap_times, TrackOI,LapN)

% We find the time-stamps of the first lap on track 1
startTime = lap_times(TrackOI).completeLaps_start(LapN);
endTime = lap_times(TrackOI).completeLaps_stop(LapN);

end
