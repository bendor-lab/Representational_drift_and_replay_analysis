% Script that :
% - for each session, compute the lap - per - lap max peak remapping for T1
% - plot all the dynamics of good place cells
% - for T1 % T3

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

load(PATH.SCRIPT + "\..\..\Data\extracted_activity_mat_lap.mat")

final_data = [];

for sessionID = 3:3
    
    data = activity_mat_laps(sessionID).allLaps;
    
    for lap = 1:(length(data) - 1)
        pfPeakPositionN = data(lap).cellsData.pfPeakPosition;
        pfPeakPositionNP1 = data(lap + 1).cellsData.pfPeakPosition;
        
        change = (pfPeakPositionNP1 - pfPeakPositionN);
        % We limit to good place cells on the whole track
        change = change(data(lap).cellsData.isGoodPCCurrentTrack)';
        
        if isempty(final_data)
            final_data = [change];
        else
            final_data = [final_data, change];
        end
    end
end

for i = 9:9
    subplot(2, 1, 1)
    plot(1:(length(data) - 1), final_data(i, :))
    hold on;
    
    subplot(2, 1, 2)
    y = fft(final_data(i, :));
    f = (0:length(y) - 1)*1/length(y);
    
    plot(f, abs(y))
    xlabel("Frequency (Hz)")
    ylabel("Magnitude")
    hold on;
end

hold off;