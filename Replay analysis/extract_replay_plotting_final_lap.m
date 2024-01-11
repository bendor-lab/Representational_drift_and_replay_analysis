function track_replay_events = extract_replay_plotting_final_lap()
% Code to extract and organize replay information from 'significant_events.mat' in order to plot it
% Also loads, 'extracted_position.mat', and 'extracted_sleep_state.mat'
% INPUT
        %computer: GPU for supercomputer, for office computer input empty [];and if running just one folder enter the path to that folder
        %data_type: 'main' for analysis of replay of main data; 'ctrl' for analysis of replay in control data, 'speed' for analysis in speed data
        %replay_control: if not empty means that is running data of replay control for short exposures, which involved other folders

% Load name of data folders
folders = data_folders_excl; %main data

% Load extracted time periods
path ='X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
load([path '\extracted_time_periods_replay_excl.mat'])

i = 1; % session count


for s = 1: length(folders) % where 's' is a recorded session
    cd(folders{s})
    curr_folder = pwd;

    if exist(strcat(pwd,'\replay_control_final_lap\significant_replay_events_wcorr.mat'),'file')
        load([pwd,'\replay_control_final_lap\significant_replay_events_wcorr.mat'])
        load([pwd,'\replay_control_final_lap\decoded_replay_events.mat'])

        load('extracted_position.mat')
        % Save ID conversion (value to actual folder name (= protocol name)
        folder_name = strsplit(pwd,'\');
        track_replay_events(i).session = [folder_name(end) i];



        % Find information relative to each track
        for t = 1 : length(significant_replay_events.track)
            % Find significant events for the selected track
            track_replay_events(i).(sprintf('%s','T',num2str(t))).all_sig_event_indices = significant_replay_events.track(t).index; % indices of sig events for this track, and for this session
            track_replay_events(i).(sprintf('%s','T',num2str(t))).all_sig_event_times = significant_replay_events.track(t).event_times; % sig event times for this track, and for this session
            track_replay_events(i).(sprintf('%s','T',num2str(t))).hist_all_events = significant_replay_events.track(t).HIST; % histogram of events for this track, and for this session (1 or 0)
            track_replay_events(i).(sprintf('%s','T',num2str(t))).score_all_sig_events = significant_replay_events.track(t).replay_score; %get score of significant events
            track_replay_events(i).(sprintf('%s','T',num2str(t))).pval_all_sig_events = significant_replay_events.track(t).p_value; %get pval of significant events
            track_replay_events(i).(sprintf('%s','T',num2str(t))).bayesian_bias_all_sig_events = significant_replay_events.track(t).bayesian_bias; %get pval of significant events
            track_replay_events(i).(sprintf('%s','T',num2str(t))).norm_all_event_times = significant_replay_events.track(t).event_times - min(position.t); % Normalize replay events to start of track

            % Depending on how many exposures, set name of session periods
            if  isfield(period_time,'T3') & ~isempty(period_time(i).T3)% if there's re-exposure
                session_periods = {'PRE','T1','sleep_pot1','T2','INTER_post','T3','sleep_pot2','T4','FINAL_post'};
            else % if there's only 2 exposures
                session_periods = {'PRE','T1','sleep_pot1','T2','FINAL_post'};
            end

            % Allocate variables
            for sp = 1 : length(session_periods)
                if strfind(session_periods{sp},'T') == 1
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_index')) = [];
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_REAL_index')) = [];
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_times')) = [];
                else
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_awake_index')) = [];
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_awake_REAL_index')) = [];
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_awake_times')) = [];
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_sleep_index')) = [];
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_sleep_REAL_index')) = [];
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_sleep_times')) = [];
                end
            end

            % From these events find in which period is happening (pre, track, post...) and if it's during awake or sleep epoch
            for this_event = 1 : length(significant_replay_events.track(t).event_times)
                [session_period,state] = find_event_in_time_period(track_replay_events(i).session,significant_replay_events.track(t).event_times(this_event),period_time(i));
                if isempty(session_period)
                    continue
                end
                if strfind(session_period,'T') == 1
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_period,'_index')) = ...
                        [track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_period,'_index')), this_event]; %index of sig event of this track
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_period,'_REAL_index')) = ...
                        [track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_period,'_REAL_index')), significant_replay_events.track(t).index(this_event)]; % real index (ID) of event back to main structure
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_period,'_times')) = ...
                        [track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_period,'_times')), significant_replay_events.track(t).event_times(this_event)]; %this event timestamp
                else
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_period,'_',state,'_index')) = ...
                        [track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_period,'_',state,'_index')), this_event];
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_period,'_',state,'_REAL_index')) = ...
                        [track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_period,'_',state,'_REAL_index')), significant_replay_events.track(t).index(this_event)];
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_period,'_',state,'_times')) = ...
                        [track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_period,'_',state,'_times')), significant_replay_events.track(t).event_times(this_event)];
                end
            end

            % From all the events extracted, for each session period (awake and sleep), interpolate times to cumulative_times
            for sp = 1 : length(session_periods)
                if length(session_periods{sp}) > 2 %if it's not track (T) period
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_awake_cumulative_times')) = interpolate_cumulative_time(period_time(i).(sprintf('%s',session_periods{sp})).awake_cumulative_time,...
                        period_time(i).(sprintf('%s',session_periods{sp})).awake, track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_awake_times')));
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_sleep_cumulative_times')) = interpolate_cumulative_time(period_time(i).(sprintf('%s',session_periods{sp})).sleep_cumulative_time,...
                        period_time(i).(sprintf('%s',session_periods{sp})).sleep, track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_sleep_times')));
                else
                    track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_awake_cumulative_times')) = interpolate_cumulative_time(period_time(i).(sprintf('%s',session_periods{sp})).cumulative_times,...
                        period_time(i).(sprintf('%s',session_periods{sp})).time_limits, track_replay_events(i).(sprintf('%s','T',num2str(t))).(sprintf('%s',session_periods{sp},'_times')));

                end
            end
        end
        % For each track, gather the relevant sleep & track data together
        % First normalize timestamps to the start of each track
        for t = 1 : length(significant_replay_events.track)
            t1_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_times - period_time(i).T1.time_limits(1); %find events during  track 1 and substract time(1) in track to normalize to 0
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T1_norm_times = t1_events;
            t2_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_times - period_time(i).T2.time_limits(1); %find events during  track 1 and substract time(1) in track to normalize to 0
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T2_norm_times = t2_events;
            if isfield(track_replay_events(i),'T3') | ~isempty(period_time(i).T3)% if there's re-exposure
                t3_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).T3_times - period_time(i).T3.time_limits(1); %find events during  track 1 and substract time(1) in track to normalize to 0
                track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T3_norm_times = t3_events;
                t4_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).T4_times - period_time(i).T4.time_limits(1); %find events during  track 1 and substract time(1) in track to normalize to 0
                track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T4_norm_times = t4_events;
            else %if 2 tracks only
                track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T3_norm_times = [];
                track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T4_norm_times = [];
            end
        end

        % Then continue with sleep
        for t = 1 : length(significant_replay_events.track)

            % Divide events in sleep periods & tracks, and normalize to zero to compare to other sessions
            pre_sleep_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).PRE_sleep_times - period_time(i).PRE.time_limits(1); %find sleep events during PRE sleep and substract time(1) in PRE to normalize to 0
            pre_awake_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).PRE_awake_times - period_time(i).PRE.time_limits(1); %find awake events during PRE sleep and substract time(1) in PRE to normalize to 0
            pre_ALL_events = (sort([track_replay_events(i).(sprintf('%s','T',num2str(t))).PRE_sleep_times track_replay_events(i).(sprintf('%s','T',num2str(t))).PRE_awake_times]))- period_time(i).PRE.time_limits(1); %find all events during PRE sleep and substract time(1) in PRE to normalize to 0
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).PRE_norm_sleep_times = pre_sleep_events;
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).PRE_norm_awake_times = pre_awake_events;
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).PRE_norm_ALL_times = pre_ALL_events;

            sleep_pot1_sleep_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot1_sleep_times - period_time(i).sleep_pot1.time_limits(1);
            sleep_pot1_awake_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot1_awake_times - period_time(i).sleep_pot1.time_limits(1);
            sleep_pot1_ALL_events = (sort([track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot1_sleep_times track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot1_awake_times]))- period_time(i).sleep_pot1.time_limits(1);
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).sleep_pot1_norm_sleep_times = sleep_pot1_sleep_events;
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).sleep_pot1_norm_awake_times = sleep_pot1_awake_events;
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).sleep_pot1_norm_ALL_times = sleep_pot1_ALL_events;

            if isfield(period_time, 'INTER_post') & ~isempty(period_time(i).INTER_post)
                INTER_post_sleep_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).INTER_post_sleep_times - period_time(i).INTER_post.time_limits(1);
                INTER_post_awake_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).INTER_post_awake_times - period_time(i).INTER_post.time_limits(1);
                INTER_post_ALL_events = (sort([track_replay_events(i).(sprintf('%s','T',num2str(t))).INTER_post_sleep_times track_replay_events(i).(sprintf('%s','T',num2str(t))).INTER_post_awake_times]))- period_time(i).INTER_post.time_limits(1);
                track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).INTER_post_norm_sleep_times = INTER_post_sleep_events;
                track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).INTER_post_norm_awake_times = INTER_post_awake_events;
                track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).INTER_post_norm_ALL_times = INTER_post_ALL_events;

                sleep_pot2_sleep_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot2_sleep_times - period_time(i).sleep_pot2.time_limits(1);
                sleep_pot2_awake_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot2_awake_times - period_time(i).sleep_pot2.time_limits(1);
                sleep_pot2_ALL_events = (sort([track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot2_sleep_times track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot2_awake_times]))- period_time(i).sleep_pot2.time_limits(1);
                track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).sleep_pot2_norm_sleep_times = sleep_pot2_sleep_events;
                track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).sleep_pot2_norm_awake_times = sleep_pot2_awake_events;
                track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).sleep_pot2_norm_ALL_times = sleep_pot2_ALL_events;
            else %if 2 tracks only
                INTER_post_sleep_events = [];
                INTER_post_awake_events = [];
                INTER_post_ALL_events = [];
                track_replay_events(i).(sprintf('%s','T',num2str(t))).INTER_post_sleep_index = [];
                track_replay_events(i).(sprintf('%s','T',num2str(t))).INTER_post_awake_index = [];

                sleep_pot2_sleep_events = [];
                sleep_pot2_awake_events = [];
                sleep_pot2_ALL_events = [];
                track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot2_sleep_index = [];
                track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot2_awake_index = [];

                track_replay_events(i).(sprintf('%s','T',num2str(t))).T3_index = [];
                track_replay_events(i).(sprintf('%s','T',num2str(t))).T4_index = [];
            end

            FINAL_post_sleep_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).FINAL_post_sleep_times - period_time(i).FINAL_post.time_limits(1);
            FINAL_post_awake_events = track_replay_events(i).(sprintf('%s','T',num2str(t))).FINAL_post_awake_times - period_time(i).FINAL_post.time_limits(1);
            FINAL_post_ALL_events = (sort([track_replay_events(i).(sprintf('%s','T',num2str(t))).FINAL_post_sleep_times track_replay_events(i).(sprintf('%s','T',num2str(t))).FINAL_post_awake_times]))- period_time(i).FINAL_post.time_limits(1);
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).FINAL_post_norm_sleep_times = FINAL_post_sleep_events;
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).FINAL_post_norm_awake_times = FINAL_post_awake_events;
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).FINAL_post_norm_ALL_times = FINAL_post_ALL_events;


            % FOR PLOTTING ONLY SLEEP PERIODS:
            %Saves all sleep period events in an array & saves the indices of start of each sleep period
            scores = significant_replay_events.track(t).replay_score;
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).score_sig_events_sleep= [scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).PRE_sleep_index),...
                scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot1_sleep_index),scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).INTER_post_sleep_index),...
                scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot2_sleep_index),scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).FINAL_post_sleep_index)];  %get score of significant events

            pval = significant_replay_events.track(t).p_value;
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).pval_sig_events_sleep= [pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).PRE_sleep_index),...
                pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot1_sleep_index),pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).INTER_post_sleep_index),...
                pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot2_sleep_index),pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).FINAL_post_sleep_index)]; %get pvalue of significant events

            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).norm_sleep_event_times = [pre_sleep_events sleep_pot1_sleep_events INTER_post_sleep_events ...
                sleep_pot2_sleep_events FINAL_post_sleep_events]; %concat all sleep event times together
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).sleep_period_start_indices = [1, length(pre_sleep_events)+1,...
                length(pre_sleep_events)+length(sleep_pot1_sleep_events)+1,length(pre_sleep_events)+length(sleep_pot1_sleep_events)+length(INTER_post_sleep_events)+1,...
                length(pre_sleep_events)+length(sleep_pot1_sleep_events)+length(INTER_post_sleep_events)+length(sleep_pot2_sleep_events)+1]; %keep indices of when each period starts (e.g. first num means indx when pre-sleep starts)

            % Give a value as session_iD
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).sleep_session_id = ones(1,length(track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).norm_sleep_event_times))*i;


            % FOR PLOTTING ONLY AWAKE PERIODS:
            %Saves all sleep period events in an array & saves the indices of start of each sleep period
            scores = significant_replay_events.track(t).replay_score;
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).score_sig_events_awake= [scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).PRE_awake_index),...
                scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index),scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot1_awake_index),...
                scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_index),scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).INTER_post_awake_index),...
                scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).T3_index),scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot2_awake_index),...
                scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).T4_index),scores(track_replay_events(i).(sprintf('%s','T',num2str(t))).FINAL_post_awake_index)];  %get score of significant events

            pval = significant_replay_events.track(t).p_value;
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).pval_sig_events_awake= [pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).PRE_awake_index),...
                pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index),pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot1_awake_index),...
                pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_index),pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).INTER_post_awake_index),...
                pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).T3_index),pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).sleep_pot2_awake_index),...
                pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).T4_index),pval(track_replay_events(i).(sprintf('%s','T',num2str(t))).FINAL_post_awake_index)]; %get pvalue of significant events

            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).norm_awake_event_times = [pre_awake_events track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T1_norm_times...
                sleep_pot1_awake_events track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T2_norm_times INTER_post_awake_events ...
                track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T3_norm_times sleep_pot2_awake_events track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T4_norm_times ...
                FINAL_post_awake_events];

            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).awake_period_start_indices = [1, length(pre_awake_events)+1,length(pre_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+1,...
                length(pre_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+length(sleep_pot1_awake_events)+1,...
                length(pre_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+length(sleep_pot1_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_index)+1,...
                length(pre_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+length(sleep_pot1_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_index)+length(INTER_post_awake_events)+1,...
                length(pre_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+length(sleep_pot1_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_index)+...
                length(INTER_post_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T3_index)+1,...
                length(pre_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+length(sleep_pot1_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_index)+...
                length(INTER_post_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T3_index)+ length(sleep_pot2_awake_events) + 1,...
                length(pre_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+length(sleep_pot1_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_index)+...
                length(INTER_post_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T3_index)+ length(sleep_pot2_awake_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T4_index)+1];

            % Give a value as session_iD
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).awake_session_id = ones(1,length(track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).norm_awake_event_times))*i;


            % FOR PLOTTING THE WHOLE SESSION
            %Saves all periods events (sleep & runs) in an array & saves the indices of start of each period
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).norm_ALL_event_times =  [pre_ALL_events track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T1_norm_times...
                sleep_pot1_ALL_events track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T2_norm_times INTER_post_ALL_events ...
                track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T3_norm_times sleep_pot2_ALL_events track_replay_events(i).(sprintf('%s','T',num2str(t),'_normalized')).T4_norm_times ...
                FINAL_post_ALL_events];

            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).ALL_period_start_indices = [1, length(pre_ALL_events)+1,...
                length(pre_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+1,length(pre_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+length(sleep_pot1_ALL_events)+1,...
                length(pre_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+length(sleep_pot1_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_index)+1,...
                length(pre_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+length(sleep_pot1_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_index)+...
                length(INTER_post_ALL_events)+1,...
                length(pre_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+length(sleep_pot1_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_index)+...
                length(INTER_post_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T3_index)+1,...
                length(pre_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+length(sleep_pot1_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_index)+...
                length(INTER_post_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T3_index)+length(sleep_pot2_ALL_events)+1,...
                length(pre_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T1_index)+length(sleep_pot1_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T2_index)+...
                length(INTER_post_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T3_index)+length(sleep_pot2_ALL_events)+length(track_replay_events(i).(sprintf('%s','T',num2str(t))).T4_index)+1];

            % Give a value as session_iD
            track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).ALL_session_id = ones(1,length(track_replay_events(i).(sprintf('%s','T',num2str(t),'_concat')).norm_ALL_event_times))*i;
        end


        i = i + 1;
        keep i s track_replay_events period_time folders path
    end
end


% SAVE
save([path '\Bayesian Controls\replay_control_final_lap\extracted_replay_plotting_info_final_lap.mat'],'track_replay_events','-v7.3');
end


function  [session_period,state] = find_event_in_time_period(session,event_time,period_time)
% Find where each time events is happening (time period - pre,track1, post, etc) and if it's during awake or sleep
session_period = [];

% Find index of the corresponding session
for i = 1 : size(period_time,2)
    if strcmp(session(1),period_time(i).sessions_order)
        indx = i;
    end
end

% Depending on how many exposures, set name of session periods
if  isfield(period_time,'T3') & ~isempty(period_time.T3)% if there's re-exposure
    session_periods = {'PRE','T1','sleep_pot1','T2','INTER_post','T3','sleep_pot2','T4','FINAL_post'};
else % if there's only 2 exposures
    session_periods = {'PRE','T1','sleep_pot1','T2','FINAL_post'};
end

% Check when the event is happening (within which session period)
for sp = 1 : length(session_periods)
    time_window = period_time(indx).(sprintf('%s',cell2mat(session_periods(sp)))).time_limits;
    if event_time >= time_window(1) && event_time < time_window(2)
        session_period = cell2mat(session_periods(sp)); %save in which period the event is happening
        if strfind(cell2mat(session_periods(sp)),'T') == 1
            state = [];
        else
            % Check if it happens during sleep epoch
            for i = 1 : size(period_time(indx).(sprintf('%s',cell2mat(session_periods(sp)))).sleep,1)
                if event_time >= period_time(indx).(sprintf('%s',cell2mat(session_periods(sp)))).sleep(i,1) && event_time < period_time(indx).(sprintf('%s',cell2mat(session_periods(sp)))).sleep(i,2)
                    state = 'sleep';
                end
            end
            % Check if it happens during awake epoch
            if ~exist('state','var')
                for i = 1 : size(period_time(indx).(sprintf('%s',cell2mat(session_periods(sp)))).awake,1)
                    if event_time >= period_time(indx).(sprintf('%s',cell2mat(session_periods(sp)))).awake(i,1) && event_time < period_time(indx).(sprintf('%s',cell2mat(session_periods(sp)))).awake(i,2)
                        state = 'awake';
                    end
                end
            end
            if ~exist('state','var') %if the event doesn't happen between any sleep or awake epoch
                disp('ERROR: Replay not found in sleep or awake states')
            end
        end
    end
end
if ~exist('state','var')
    state = [];
end
end 

function cumulative_event_times = interpolate_cumulative_time(cumulative_time,time, event_times)
% Interpolate replay event times to cumulative time

    if isempty(time)
        cumulative_event_times = NaN;
    else
        time(2:end,1) = time(2:end,1)+1e-10;
        cumulative_time(2:end,1) = cumulative_time(2:end,1)+1e-10;
        t = NaN(1,size(time,1)*size(time,2));
        t_c = NaN(1,size(time,1)*size(time,2));
        t(1:2:end) = time(:,1);
        t(2:2:end) = time(:,2);
        t_c(1:2:end) = cumulative_time(:,1);
        t_c(2:2:end) = cumulative_time(:,2);
        cumulative_event_times = interp1(t,t_c,event_times,'linear');
    end
end