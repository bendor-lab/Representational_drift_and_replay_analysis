function all_tracks_decoding_error = extract_decoding_error_info
% Extract track decoding error stored in each data folder 

% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
else
    sessions = data_folders;
    session_names = fieldnames(sessions);
end

c = 1;
for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        
        folder_name = strsplit(pwd,'\');
        session = folder_name{end};
        
        load track_decoding_error.mat
        all_tracks_decoding_error(c).session = session;
        for i = 1 : length(track_decoding_error)
            all_tracks_decoding_error(c).(strcat('T',num2str(i))) = track_decoding_error(i).track_MEDIAN_decoding_error;
        end
        
        mean_decoding_error(c).session = session;
        for i = 1 : length(track_decoding_error)
            mean_decoding_error(c).(strcat('T',num2str(i))) = track_decoding_error(i).track_mean_MedianDecodingError;
        end
        
        c = c+1;
    end
end

cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error' 
save all_tracks_decoding_error.mat all_tracks_decoding_error mean_decoding_error

end
