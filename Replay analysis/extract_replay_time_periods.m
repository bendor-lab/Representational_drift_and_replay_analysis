
function period_time = extract_replay_time_periods(computer,data_folder,data_type,replay_control)
% Marta Huelin, 2020
% Code to extract sleep and awake epochs within each time period of the session (pre sleep,inter-track sleep pot rest(s), and post sleep(s)).
% Also loads, 'extracted_position.mat', and 'extracted_sleep_state.mat'
% INPUT
    %computer: GPU for supercomputer, for office computer input empty [];and if running just one folder enter the path to that raw data folder 
    %data_type: 'main' for analysis of replay of main data; 'ctrl' for analysis of replay in control data, 'speed' for analysis in speed data

% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
elseif isempty(computer) & strcmp(data_type,'main')%normal computer
    if strcmp(replay_control,'short_first')
        sessions = data_folder('short_first');
    elseif strcmp(replay_control,'stability_first')
        sessions = data_folder('stability_first');
    elseif strcmp(replay_control,'short_last')
        sessions = data_folder('short_last');
    elseif strcmp(replay_control,'stability_last')
        sessions = data_folder('stability_last');
    else 
        sessions = data_folders; %main data
    end
    session_names = fieldnames(sessions);
elseif isempty(computer) & strcmp(data_type,'speed')
    sessions = speed_data_folders;
    session_names = fieldnames(sessions);
elseif isempty(computer) & strcmp(data_type,'ctrl')
    sessions = ctrl_data_folders;
    session_names = fieldnames(sessions);
elseif isempty(computer) & strcmp(data_type,'onelap_ctrl')
    sessions = data_folders_oneLap_control;
    session_names = fieldnames(sessions);
else %if entering a single folder 
    folders = {computer};
    session_names = folders;
end

i = 1; % session count

for p = 1 : length(session_names)
    if length(session_names) > 1 | length(sessions.(strcat(cell2mat(session_names))))>1 %more than one folder
        folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    end
    for s = 1: length(folders) % where 's' is a recorded session
        cd(folders{s})
            idx = strfind(folders{s},'\');
            path = folders{s};
            if length(idx) > 8 %if working in subfolder within main data folder (e.g. P-ORA/replay_control1Lap/...)
                path = path(1:idx(end)-1);
            end
        if exist(strcat(path,'\extracted_sleep_state.mat'),'file')
            load([path '\extracted_sleep_state.mat'])
            load([path '\extracted_position.mat'])
            load('extracted_place_fields_BAYESIAN.mat')
            
            if ~isempty(replay_control)
                cd ..\
                folder_name = strsplit(pwd,'\');
                period_time(i).sessions_order = folder_name(end); % save order of sessions being analysed
                cd ..
            else
                folder_name = strsplit(pwd,'\');
                period_time(i).sessions_order = folder_name(end); % save order of sessions being analysed
            end
            
            % Find information relative to each track            
            if ~exist('place_fields_BAYESIAN','var')
                for t = 1 : size(position.linear,2)
                    %Save run periods length and start and end times
                    period_time(i).(strcat('T',num2str(t))).length = max(position.linear(t).timestamps) - min(position.linear(t).timestamps); % length
                    period_time(i).(strcat('T',num2str(t))).time_limits = [min(position.linear(t).timestamps) max(position.linear(t).timestamps)]; % start and end time
                    period_time(i).(strcat('T',num2str(t))).cumulative_times = [0, period_time(i).(strcat('T',num2str(t))).length];
                end
            else
                for t = 1 : size(place_fields_BAYESIAN.track,2)
                    %Save run periods length and start and end times
                    period_time(i).(strcat('T',num2str(t))).length = max(place_fields_BAYESIAN.track(t).time_window(2)) - min(place_fields_BAYESIAN.track(t).time_window(1)); % length
                    period_time(i).(strcat('T',num2str(t))).time_limits = [place_fields_BAYESIAN.track(t).time_window(1) place_fields_BAYESIAN.track(t).time_window(2)]; % start and end time
                    period_time(i).(strcat('T',num2str(t))).cumulative_times = [0, period_time(i).(strcat('T',num2str(t))).length];
                end
            end
            
        % Back to for each session:
        
        % Get start and end times for sleep and awake epochs
        period_time(i).sleep_times(:,1) = position.t(sleep_state.sleep_indices.start); %get start times for each sleep moment throughout the session
            period_time(i).sleep_times(:,2) = position.t(sleep_state.sleep_indices.stop); %stop sleep times
            period_time(i).awake_times(:,1) = [sleep_state.state_time.PRE_start; period_time(i).sleep_times(:,2)];%get start times for each awake moment throughout the session
            period_time(i).awake_times(:,2) = [period_time(i).sleep_times(:,1); max(position.t)]; %stop awake times
            period_time(i).total_time_asleep = sum(period_time(i).sleep_times(:,2)-period_time(i).sleep_times(:,1))/60;
            period_time(i).total_time_awake = sum(period_time(i).awake_times(:,2)-period_time(i).awake_times(:,1))/60;
            
            % Depending on how many exposures, set name of sleep periods
            if size(position.linear,2) == 4 % if there's re-exposure
                sleep_periods = {'PRE','sleep_pot1','INTER_post','sleep_pot2','FINAL_post'};
            elseif size(position.linear,2) == 2 % if there's only 2 exposures
                sleep_periods = {'PRE','sleep_pot1','FINAL_post'};
            end
            
            for sp = 1 : length(sleep_periods)
                % Save sleep periods length and their start and end timestamps
                period_time(i).(sprintf('%s',sleep_periods{sp})).length = sleep_state.state_time.(sprintf('%s',sleep_periods{sp},'_end')) - sleep_state.state_time.(sprintf('%s',sleep_periods{sp},'_start')); % length
                period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits = [sleep_state.state_time.(sprintf('%s',sleep_periods{sp},'_start')),sleep_state.state_time.(sprintf('%s',sleep_periods{sp},'_end'))]; % start and end time
                period_time(i).(sprintf('%s',sleep_periods{sp})).sleep = period_time(i).sleep_times(period_time(i).sleep_times(:,1) >= period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1) & period_time(i).sleep_times(:,1) < period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(2),:); % sleep start and end times inside 
                period_time(i).(sprintf('%s',sleep_periods{sp})).awake = period_time(i).awake_times(period_time(i).awake_times(:,1) >= period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1) & period_time(i).awake_times(:,1) < period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(2),:); % awake start and end times inside 
               
                if  isempty(period_time(i).(sprintf('%s',sleep_periods{sp})).awake) && isempty(period_time(i).(sprintf('%s',sleep_periods{sp})).sleep)
                    period_time(i).(sprintf('%s',sleep_periods{sp})).awake = period_time(i).awake_times(period_time(i).awake_times(:,1) <= period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1) & period_time(i).awake_times(:,2) > period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(2),:); 
                    period_time(i).(sprintf('%s',sleep_periods{sp})).sleep = period_time(i).sleep_times(period_time(i).sleep_times(:,1) <= period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1) & period_time(i).sleep_times(:,2) > period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(2),:); 
                end
                
                %adjust for final time when animal is put on track
                period_time(i).(sprintf('%s',sleep_periods{sp})).sleep(period_time(i).(sprintf('%s',sleep_periods{sp})).sleep > period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(2)) = period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(2);
                period_time(i).(sprintf('%s',sleep_periods{sp})).awake(period_time(i).(sprintf('%s',sleep_periods{sp})).awake > period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(2)) = period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(2);
                
                if sp > 1 % if it's not pre-sleep
                    % add first awake time when animal is taken off track
                    period_time(i).(sprintf('%s',sleep_periods{sp})).awake(period_time(i).(sprintf('%s',sleep_periods{sp})).awake < period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1)) = period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1);
                    period_time(i).(sprintf('%s',sleep_periods{sp})).sleep(period_time(i).(sprintf('%s',sleep_periods{sp})).sleep < period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1)) = period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1);
                    if ~isempty(period_time(i).(sprintf('%s',sleep_periods{sp})).awake) && ~isempty(period_time(i).(sprintf('%s',sleep_periods{sp})).sleep)
                        if period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1) < period_time(i).(sprintf('%s',sleep_periods{sp})).sleep(1) || period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1) < period_time(i).(sprintf('%s',sleep_periods{sp})).awake(1)
                            if period_time(i).(sprintf('%s',sleep_periods{sp})).sleep(1) < period_time(i).(sprintf('%s',sleep_periods{sp})).awake(1)
                                period_time(i).(sprintf('%s',sleep_periods{sp})).awake = sort([period_time(i).(sprintf('%s',sleep_periods{sp})).awake; period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1),period_time(i).(sprintf('%s',sleep_periods{sp})).sleep(1)]);
                            else
                                period_time(i).(sprintf('%s',sleep_periods{sp})).sleep = sort([period_time(i).(sprintf('%s',sleep_periods{sp})).sleep; period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1),period_time(i).(sprintf('%s',sleep_periods{sp})).awake(1)]);
                            end
                        end
                    end
                end
                
                % Final check: if neither the start of awake or sleep does not match with the time limit start
                if isempty(period_time(i).(sprintf('%s',sleep_periods{sp})).awake) && period_time(i).(sprintf('%s',sleep_periods{sp})).sleep(1) ~= period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1)
                    period_time(i).(sprintf('%s',sleep_periods{sp})).awake = period_time(i).awake_times(period_time(i).awake_times(:,1) <= period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(2) & period_time(i).awake_times(:,2) > period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1),:);
                elseif isempty(period_time(i).(sprintf('%s',sleep_periods{sp})).sleep) && period_time(i).(sprintf('%s',sleep_periods{sp})).awake(1) ~= period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1)
                    period_time(i).(sprintf('%s',sleep_periods{sp})).sleep = period_time(i).sleep_times(period_time(i).sleep_times(:,1) <= period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(2) & period_time(i).sleep_times(:,2) > period_time(i).(sprintf('%s',sleep_periods{sp})).time_limits(1),:);
                end
                
                % Calculate cummulative time (stack all epochs together)
                period_time(i).(sprintf('%s',sleep_periods{sp})).awake_cumulative_time = compute_cumulative_time(period_time(i).(sprintf('%s',sleep_periods{sp})).awake);
                period_time(i).(sprintf('%s',sleep_periods{sp})).sleep_cumulative_time = compute_cumulative_time(period_time(i).(sprintf('%s',sleep_periods{sp})).sleep);
            end
            
             % Get sleep indices
            period_time(i).sleep_indices = sleep_state.state; % -1 for awake, 1 for sleep - length of position.t
            
            i = i + 1;
        end
    end
end

% SAVE

if strcmp(data_type,'main')
    if ~isempty(replay_control) %if replay control for same number of laps between tracks
        path = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Short_exposures_control_' replay_control '_laps'];
    else
        path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis'; %main data
    end   
elseif strcmp(data_type,'speed')
    path ='X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Speed';
elseif strcmp(data_type,'ctrl') & isempty(computer)
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Controls\All_controls';
elseif strcmp(data_type,'ctrl') & ~isempty(computer)
    path = strcat('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Controls\',folder_name{end});
elseif strcmp(data_type,'onelap_ctrl') & isempty(computer)
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Short_exposures_control_ONE_lap';
end
    save([path '\extracted_time_periods_replay.mat'],'period_time','-v7.3');

end


function cumulative_time = compute_cumulative_time(time)
% Takes start and end times for a specific period (e.g. PRE sleep), normalized it to the start of the sleep epoch within the sleep period and 
% then calculates cummulative sum for the start and end timestamps (stacks all epochs together)

cumulative_time = time - time(:,1); %normalize by epoch start - start times to 0
cumulative_time(:,2) = cumsum(cumulative_time(:,2)); %cummulative sum of stop times
cumulative_time(2:end,1) = cumulative_time(1:(end-1),2);
end