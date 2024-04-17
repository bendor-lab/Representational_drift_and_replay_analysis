% Script to compute the balanced place fields in the new repository
% Pierre Varichon - 2024

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

addpath("Extract place fields", "Place field comparison");

% We get the list of session folder

allFolders = data_folders_excl; % We look for all the directorys with right name

% We iterate through folders

parfor direcInd = 1:19
    direc = allFolders{direcInd};
    disp(direc);

    % We go into that folder
    cd(direc);

    % We create a folder for balanced place fields

    if ~exist("balanced_analysis/one_lap_all", 'dir')
        mkdir("balanced_analysis/one_lap_all");
    end

    temp = load(direc + "\extracted_laps");
    lap_times = temp.lap_times;

    timingMat = [];

    % For each unique track, find the minimim number of laps and then the
    % timing for each track

    % for track = 1:2
    %     nbLapsExp = numel(lap_times(track).halfLaps_start);
    %     nbLapsReexp = numel(lap_times(track + 2).halfLaps_start);
    %
    %     if nbLapsReexp >= nbLapsExp
    %         startTimeExp = lap_times(track).halfLaps_start(1);
    %         stopTimeExp = lap_times(track).halfLaps_stop(end);
    %
    %         startTimeReexp = lap_times(track + 2).halfLaps_start(1);
    %         stopTimeReexp = lap_times(track + 2).halfLaps_stop(nbLapsExp);
    %
    %     else
    %         startTimeExp = lap_times(track).halfLaps_start(nbLapsExp - nbLapsReexp);
    %         stopTimeExp = lap_times(track).halfLaps_stop(end);
    %
    %         startTimeReexp = lap_times(track + 2).halfLaps_start(1);
    %         stopTimeReexp = lap_times(track + 2).halfLaps_stop(end);
    %     end
    %
    %     timingMat = [timingMat; [startTimeExp stopTimeExp ; startTimeReexp stopTimeReexp]];
    % end

    % For one_lap_all, always takes the last lap of RUN1 and the firstlap
    % of RUN2

    for track = 1:2

        startTimeExp = lap_times(track).halfLaps_start(end);
        stopTimeExp = lap_times(track).halfLaps_stop(end);

        startTimeReexp = lap_times(track + 2).halfLaps_start(1);
        stopTimeReexp = lap_times(track + 2).halfLaps_stop(1);

        timingMat = [timingMat; [startTimeExp stopTimeExp ; startTimeReexp stopTimeReexp]];
    end

    % We can run the function
    calculate_place_fields(10, [], "balanced_analysis/one_lap_all", timingMat)

end
