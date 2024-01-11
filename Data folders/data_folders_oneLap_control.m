% DATA FOLDERS FOR ANALYSE ORGANIZED BY SESSIONS

function sessions = data_folders_oneLap_control


% 16x1
     S16_1 = [{'x:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\M-BLU\M-BLU_Day3_16x1\replay_control_1LAP'},...
        {'x:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\N-BLU\N-BLU_Day3_16x1\replay_control_1LAP'},...
        {'x:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\P-ORA\P-ORA_Day7_16x1\replay_control_1LAP'},...
        {'x:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Q-BLU\Q-BLU_Day7_16x1\replay_control_1LAP'}];
   
    for j = 1 : length(S16_1)
        path = S16_1{j};
        folders = dir(path);
        folders = folders(3:end);
        for k = 1 : length(folders)
            sp = strfind(folders(k).name,' ');
            id = str2num(folders(k).name(sp(end)+1:end));
            sessions.(sprintf('%s','LAP_',num2str(id))){1,j} = [path '/' folders(k).name];
        end
    end
    
    sessions = orderfields(sessions,[1,9:16,2:8]);

end 