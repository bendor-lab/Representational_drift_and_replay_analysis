% Script that tranfer the extracted data from Drobbo to the current repo

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl_legacy; % Use the function to get all the file paths
goodPathsServer = data_folders_excl; % Path for the new server location

% filesToExtract = ["extracted_laps.mat", 'extracted_clusters.mat', 'extracted_position.mat', ...
%                   'extracted_waveforms.mat', "extracted_place_fields_BAYESIAN.mat", ...
%                   "extracted_place_fields.mat", "extracted_directional_clusters.mat", ...
%                   "extracted_directional_place_fields.mat", "replayEvents_bayesian_spike_count.mat", "extracted_sleep_state.mat", ...
%                   "extracted_replay_events.mat", "extracted_directional_lap_place_fields.mat", "extracted_place_fields_BAYESIAN.mat"];

% For each good session
% for i = 1:length(sessions)
%     file = sessions{i};
%     disp(file);
% 
%     dirNameServer = goodPathsServer{i};
% 
%     splitted_path = split(file, '\');
%     infos = splitted_path(end);
%     splitted_infos = split(infos, '_');
%     animalOI = splitted_infos{1};
%     conditionOI = splitted_infos{end};
% 
%     % If no dir, we create it
% 
%     dirName = PATH.SCRIPT + "/../ExpData/" + animalOI + "_" + conditionOI;
% 
%     if ~exist(dirName, 'dir')
%       mkdir(dirName);
%     end
% 
%     if ~exist(dirNameServer, 'dir')
%       mkdir(dirNameServer);
%     end
% 
%     for variable = filesToExtract
% 
%         x = load(file + "/" + variable); % We get the variable
%         field = fieldnames(x);
%         field = field{1}; % We find its name
%         x = x.(field); % we retrieve it
%         eval([field '= x;']); % we asign it to its right name
%         save(dirName + "/" + variable, field); % We save it
%         save(dirNameServer + "/" + variable, field); % We save it
% 
%         clear x
%         eval(['clear ' field]); % we clear the variables
% 
%     end
% end

%% FILES TO EXTRACT IN SUBFOLDERS

filesToGet = ["\Bayesian controls\Only first exposure\decoded_replay_events.mat", ...
              "\Bayesian controls\Only first exposure\significant_replay_events_wcorr.mat", ...
              "\Bayesian controls\Only re-exposure\decoded_replay_events.mat", ...
              "\Bayesian controls\Only re-exposure\significant_replay_events_wcorr.mat"];

paths_to_save = ["/Replay/RUN1_Decoding/", "/Replay/RUN1_Decoding/", ...
                "/Replay/RUN2_Decoding/", "/Replay/RUN2_Decoding/"];


% For each good session
for i = 1:length(sessions)
    file = sessions{i};
    disp(file);

    dirNameServerRoot = goodPathsServer{i};

    % We get the informations about the current data

    splitted_path = split(file, '\');
    infos = splitted_path(end);
    splitted_infos = split(infos, '_');
    animalOI = splitted_infos{1};
    conditionOI = splitted_infos{end};

    for j = 1:length(filesToGet)
        variable = filesToGet(j);
        pathToSave = paths_to_save(j);

        % Get the proper name of the variable without the path
        properVariableName = split(variable, '\');
        properVariableName = properVariableName{end};

        % If no dir, we create it

        dirName = PATH.SCRIPT + "/../ExpData/" + animalOI + "_" + conditionOI + pathToSave;
        dirNameServer = dirNameServerRoot + "/" + pathToSave;

        if ~exist(dirName, 'dir')
          mkdir(dirName);
        end

        if ~exist(dirNameServer, 'dir')
          mkdir(dirNameServer);
        end

        x = load(file + "/" + variable); % We get the variable
        field = fieldnames(x);
        field = field{1}; % We find its name
        x = x.(field); % we retrieve it
        eval([field '= x;']); % we asign it to its right name
        save(dirName + "/" + properVariableName, field); % We save it
        save(dirNameServer + "/" + properVariableName, field); % We save it

        clear x
        eval(['clear ' field]); % we clear the variables

    end
end           