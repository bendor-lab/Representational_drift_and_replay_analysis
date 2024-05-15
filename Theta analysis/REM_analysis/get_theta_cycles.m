% For each session, get theta peak and troughs using min max value
% Pierre VARICHON 2024

% Create the file "theta_peak_trough.mat" in the folder Theta of ExpData

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl_legacy; % Use the function to get all the file paths
goodPathsServer = data_folders_excl; % Path for the new server location

% We iterate through sessions
for sID = 1:numel(sessions)
    disp(sID);
    currentFile = sessions{sID};

    % We load the data
    temp = load(currentFile + "/extracted_CSC.mat");
    CSC = temp.CSC;
    temp = load(currentFile + "/extracted_position.mat");
    position = temp.position;

    % We get the LFP / z-scored theta power
    best_theta_lower_ripple_CSC =  find(strcmp({CSC.channel_label},'best_theta_low_ripple')==1);
    lfp   = CSC(best_theta_lower_ripple_CSC).CSCraw;
    theta = CSC(best_theta_lower_ripple_CSC).theta;
    t     = CSC(best_theta_lower_ripple_CSC).CSCtime;

    % using local extrema detection over sliding window
    [pks,trs,minChange] = findMinMax(theta, 0.25);

    % clean both with 2 conditions:
    % - peaks must be positive, troughs negative
    % - it has to go peak-trough-peak etc
    extrema = clean_peaks_and_troughs(theta,pks,trs);

    % separate back into peaks and troughs
    theta_peaks  = extrema(extrema(:,3) == 1,:);
    theta_troughs = extrema(extrema(:,3) == -1,:);
    theta_peaks(:,4)  = t(theta_peaks(:,1));
    theta_troughs(:,4) = t(theta_troughs(:,1));

    % We save
    path2save = goodPathsServer{sID};

    if ~exist(path2save + "\REM", 'dir')
        mkdir(path2save + "\REM");
    end

    save(path2save + "\REM\theta_peak_trough.mat",'theta_peaks','theta_troughs','-v7.3')


end