% Function to crop the positions available for place fields decoding.

% INPUTS : 
% position : extracted_positions file
% TrackOI : track recodring subject to the cropping (1 -> 4)
% startTime : time when starting to consider position 
% endTime : time when finishing to consider position

% OUTPUTS :
% croppedPosition : position object, cropped with respect to the times
% given

function [croppedPosition] = cropPositionsAtTime(position,TrackOI, startTime, endTime)

croppedPosition = position; % Copy of position

% We reduce the positions available for the place field calculation
allTimesPosition = position.t;
boolValidTimes = (allTimesPosition > startTime & allTimesPosition < endTime);
croppedPosition.linear(TrackOI).linear(~boolValidTimes) = false;

end

