function last_lap_POST1_replay_analysis

% Code for quntifying replay decoded using place cell template from the
% single final lap
% Marta Huelin Gorriz and Masahiro Takigawa 2023


sessions = data_folders_excl;

% Decoding replay events based on finial lap place cell template from RUN1
% Track 1 and Track 2
for nfolder = 1:length(sessions)
    tic
    cd([sessions{nfolder}])
    current_dir = pwd;

    if ~exist([current_dir,'/replay_control_final_lap'], 'dir')
        mkdir([current_dir,'/replay_control_final_lap'])
    end
    
    final_lap_POST1_replay_decoding(); %extract and decodes replay events
      
    % SCORING METHODS: TEST SIGNIFICANCE ON REPLAY EVENTS
    disp('scoring replay events')
    load([current_dir,'/replay_control_final_lap/decoded_replay_events.mat'])
    scored_replay = replay_scoring(decoded_replay_events,[0 1 0 0]); % can run line fitting, weighterd corr, pacman & spearman corr (select = 1)
    save('replay_control_final_lap/scored_replay.mat','scored_replay','-v7.3')
    
    % RUN SHUFFLES
    
    disp('running shuffles')
    % Select parameters
    num_shuffles  = 1000;
    analysis_type = [0 1 0 0];  % can run line fitting, weighterd corr, pacman & spearman corr (select = 1)
    % analysis_type= [0 0 0 0]; % if you want to just save the shuffles, not score them
    
    p = gcp; % Starting new parallel pool
    shuffle_choice={'PRE spike_train_circular_shift','PRE place_field_circular_shift', 'POST place bin circular shift'};
    
    if ~isempty(p)
        for shuffle_id=1:length(shuffle_choice)
            [shuffle_type{shuffle_id}.shuffled_track,shuffled_struct{shuffle_id,1}] = parallel_shuffles_final_lap(shuffle_choice{shuffle_id},analysis_type,num_shuffles,decoded_replay_events);
        end
    else
        disp('parallel processing not possible');
        for shuffle_id=1:length(shuffle_choice)
            [shuffle_type{shuffle_id}.shuffled_track, shuffled_struct{shuffle_id,1}] = run_shuffles_final_lap(shuffle_choice{shuffle_id},analysis_type,num_shuffles,decoded_replay_events);
        end
    end
    toc
%     shuffled_struct(:,2)= shuffle_choice';
%     save('replay_control_final_lap/shuffled_decoded_events.mat','shuffled_struct','-v7.3');
    save('replay_control_final_lap/shuffle_scores.mat','shuffle_type','-v7.3');
    
    %save('shuffled_tracks.mat','shuffle_type','-v7.3');
    clear shuffled_struct
    
    disp('time to run shuffles was...');
    toc
    
    
    % EVALUATE REPLAY SIGNIFICANCE
    %     load('replay_control_final_lap/scored_replay.mat'); %scores for real replay events
    %     load('replay_control_final_lap/shuffle_scores.mat'); %scores for shuffled replay events
    scored_replay  = replay_significance(scored_replay, shuffle_type); %p-value for each event, for each shuffle
    save('replay_control_final_lap/scored_replay.mat','scored_replay','-v7.3')
    clear scored_replay shuffle_type
    
    
    % SECOND ROUND OF REPLAY ANALYSIS: REPLAY EVENT SEGMENTS
    % Split replay events
    replay_decoding_split_events_final_lap();
    
    % Score replay segments
    load('replay_control_final_lap/decoded_replay_events_segments.mat')
    scored_replay1 = replay_scoring(decoded_replay_events1,[0 1 0 0]);
    scored_replay2 = replay_scoring(decoded_replay_events2,[0 1 0 0]);
    save('replay_control_final_lap/scored_replay_segments.mat','scored_replay1','scored_replay2','-v7.3')
    
    % Run shuffles on both replay segments
    num_shuffles=1000;
    analysis_type=[0 1 0 0];  %just weighted correlation and pacman
    % analysis_type= [0 0 0 0]; % if you want to just save the shuffles, not score them

    p = gcp; % Starting new parallel pool
    if ~isempty(p)
        for shuffle_id=1:length(shuffle_choice)
            [shuffle_type1{shuffle_id}.shuffled_track, shuffled_struct1{shuffle_id,1}] = parallel_shuffles_final_lap(shuffle_choice{shuffle_id},analysis_type,num_shuffles,decoded_replay_events1);
            [shuffle_type2{shuffle_id}.shuffled_track, shuffled_struct2{shuffle_id,1}] = parallel_shuffles_final_lap(shuffle_choice{shuffle_id},analysis_type,num_shuffles,decoded_replay_events2);
        end
    else
        disp('parallel processing not possible');
        for shuffle_id=1:length(shuffle_choice)
            [shuffle_type1{shuffle_id}.shuffled_track, shuffled_struct1{shuffle_id,1}] = run_shuffles_final_lap(shuffle_choice{shuffle_id},analysis_type,num_shuffles,decoded_replay_events1);
            [shuffle_type2{shuffle_id}.shuffled_track, shuffled_struct2{shuffle_id,1}] = run_shuffles_final_lap(shuffle_choice{shuffle_id},analysis_type,num_shuffles,decoded_replay_events2);
        end
    end
%     shuffled_struct1(:,2)= shuffle_choice';
%     shuffled_struct2(:,2)= shuffle_choice';
    
    save('replay_control_final_lap/shuffle_scores_segments.mat','shuffle_type1','shuffle_type2','-v7.3');
%     save('replay_control_final_lap/shuffled_decoded_events_segments.mat','shuffled_struct1','shuffled_struct2','-v7.3');
    clear shuffled_struct1 shuffled_struct2
    
%     shuffle_type1= shuffle_scoring(shuffled_struct1,[1 1 0 1],'segments');
%     shuffle_type2= shuffle_scoring(shuffled_struct2,[1 1 0 1],'segments');
%     %save shuffled_tracks_segments shuffle_type1 shuffle_type2;
%     clear shuffle_type1 shuffle_type2
%     clear shuffled_struct1 shuffled_struct2
    
    % Test significance
%     load scored_replay_segments; load shuffle_scores_segments
    scored_replay1 = replay_significance(scored_replay1, shuffle_type1);
    scored_replay2 = replay_significance(scored_replay2, shuffle_type2);
    save('replay_control_final_lap/scored_replay_segments.mat','scored_replay1','scored_replay2','-v7.3');
    
    clear scored_replay1 scored_replay2 shuffle_type1 shuffle_type2
    number_of_significant_replays_final_lap(0.05,3,'wcorr',1); %second input is to only use replay events passing set threshold for ripple power
    toc
end


%% Quantification of Replay rates over times during sleep and awake
track_replay_events = extract_replay_plotting_final_lap();
load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\extracted_time_periods_replay_excl.mat');

PP =  plotting_parameters;
bin_width = 1; % 60 = 1 min
time_chunk_size = 1800; % 1800 = 30min
periods = [{'PRE'},{'INTER_post'},{'FINAL_post'}];% Set periods to be analysed
epoch = 'sleep';

% Find indices for each type of protocol
t2 = [];
for s = 1 : length(track_replay_events)
    name = cell2mat(track_replay_events(s).session(1));
    if strfind(name,'Ctrl')
        t2 = [t2 str2num(name(end-1:end))];
    else
        t2 = [t2 str2num(name(end))];
    end
end
protocols = unique(t2,'stable');

% Find number of tracks in the session
if isfield(track_replay_events,'T4')
    num_tracks = 4;
else
    num_tracks = 2;
end

% For each protocol (8,4,3,2 or 1)
for i = 1 : length(protocols)
    
    this_protocol_idxs = find(t2 == protocols(i)); %find indices of sessions from the current protocol
    
    for p = 1 : length(periods) %for each time period (sleep or run) within the protocol

        for s = 1 : length(this_protocol_idxs) %for each session/rat in this protocol
            curr_folder = strsplit(track_replay_events(this_protocol_idxs(s)).session{1},'_');

            % Divide current period in 30min chunks

            if isempty(period_time(this_protocol_idxs(s)).(strcat(periods{p})).(strcat(epoch,'_cumulative_time'))) %if this period exists
                continue
            else
                curr_time = period_time(this_protocol_idxs(s)).(strcat(periods{p})).(strcat(epoch,'_cumulative_time'));
            end

            time_chunks = curr_time(1,1) : time_chunk_size : curr_time(end,2);
            chunks_duration = ones(1,length(time_chunks)-1)*time_chunk_size;
            if time_chunks(end) ~= curr_time(end,2) %if the duration of last chunk was < or > 30min
                time_chunks = [time_chunks, curr_time(end,2)];
                chunks_duration = [chunks_duration, abs(curr_time(end,2) - time_chunks(end-1))]; %save the actual duration of the last chunk
            end

            for tc = 2: length(time_chunks) % for each time chunk within this period, find replay events per minute (replay rate)

                this_chunk_bin_edges = time_chunks(tc-1) : bin_width : time_chunks(tc);

                for track = 1 : num_tracks % For each track in this time chunk

                    %Find indices of replay within the chunk
                    replay_indcs = find(track_replay_events(this_protocol_idxs(s)).(strcat('T',num2str(track))).(strcat(periods{p},'_',epoch,'_cumulative_times')) > time_chunks(tc-1) & track_replay_events(this_protocol_idxs(s)).(strcat('T',num2str(track))).(strcat(periods{p},'_',epoch,'_cumulative_times')) <= time_chunks(tc)-1);
                    % Save in structure Track.Protocol.Period-epoch.Rat{time_chunk}
                    T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_num_events{s,tc-1} = length(replay_indcs); %number of events per chunk
%                     T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{s,tc-1} = length(replay_indcs)/(length(this_chunk_bin_edges)-1); % replay per minute (rate) in each chunk
                    T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{s,tc-1} = length(replay_indcs)/(length(this_chunk_bin_edges)); % replay per second (rate) in each chunk
                    T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_time_chunks{s,tc-1} = time_chunks(tc-1); % start timestamp for each chunk
                    T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_chunk_duration{s,tc-1} = chunks_duration(tc-1); % duration of each chunk (should be 30min, except if the last one is shorter)
                end
            end
        end
        % Check if there are empty cells on chunk periods (due to shorter time chunks), and zero them
        for track = 1 : num_tracks % For each track
            if length(find(cellfun(@isempty,T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_num_events))) > 0
                T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_num_events(cellfun(@isempty,T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_num_events)) = {0};
                T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate(cellfun(@isempty,T(track).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate)) = {0};
            end
        end
    end
end

rate_replay = T;
params.bin_size = bin_width;
params.time_chunk_size = time_chunk_size; % 30min
params.epoch = epoch;
path ='X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';

if bin_width == 1  %add _per_second_ if bin_width is 1 sec
    save([path '\Bayesian Controls\replay_control_final_lap\rate_per_second_',epoch,'_replay_' num2str(time_chunk_size/60) 'min_excl_final_lap.mat'],'rate_replay','params','-v7.3')
else
    save([path '\rate_',epoch,'_replay_' num2str(time_chunk_size/60) 'min_excl_final_lap.mat'],'rate_replay','params','-v7.3')
end


%% T1 vs T2 sleep replay rate during first 30 mins of cumulative POST1 sleep
clear all
path ='X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
load([path,'\Bayesian Controls\replay_control_final_lap\extracted_replay_plotting_info_final_lap.mat']);

% SLEEP REPLAY
load([path,'\Bayesian Controls\replay_control_final_lap\rate_per_second_sleep_replay_30min_excl_final_lap.mat']);

time_window = 1;
time_chunk_size = 1800;
num_sess = length(track_replay_events);
rest_option = 'sleep';
cnt = 1;
ses = 1;

% for each session gather and calculate replay info

folders = data_folders_excl;

for s = 1 : num_sess
    if s < 5
        old_sess_index = s;
    else
        old_sess_index = s+1; % Skip session N-BLU_Day2_16x4
    end

    % POST 1 - ABSOLUTE NUMBER OF EVENTS
    INTER_T1_events(s) = rate_replay(1).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_num_events{cnt,time_window}; % POST1 T1 events within first 30min of sleep
    INTER_T2_events(s) = rate_replay(2).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_num_events{cnt,time_window}; % POST1 T1 events within first 30min of sleep

    % POST 1 - RATE EVENTS
    INTER_T1_rate_events(s) = rate_replay(1).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,time_window}; % POST1 T1 rate events within first 30min of sleep
    INTER_T2_rate_events(s) = rate_replay(2).P(ses).(sprintf('INTER_post_%s',rest_option)).Rat_replay_rate{cnt,time_window}; % POST1 T1 rate events within first 30min of sleep

    if cnt == 3 & ses == 2 % if last protocol session and ses = 2 (16x4)
        ses = ses+1;
        cnt = 1;
    elseif cnt == 4 % if last protocol session
        ses = ses+1;
        cnt = 1;
    else
        cnt = cnt + 1;
    end
end


PP =  plotting_parameters;
PP1.T1 = PP.T1;
PP1.T2 = PP.T2;

for n = 1:size(PP.T2,1)
    PP1.T2(6-n,:) = PP.T2(n,:);
end


[POST_replay_p(1),~] = signrank(INTER_T1_rate_events, INTER_T2_rate_events);


%% Plot POST replay rate per track, all protocols together

f11 = figure('Color','w','Name','POST replay rates');
f11.Position = [450 180 1020 720];
f11.Name = [sprintf('POST replay rate(%s) decoded by final lap representation',rest_option)];

nexttile
grp = [ones(num_sess,1);ones(num_sess,1)*2];
tst=[INTER_T1_rate_events INTER_T2_rate_events]';

% xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2;PP.RUN2T1;PP.RUN2T2],'dot_size',2,'corral_style','rand');
xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.RUN1T1;PP.RUN1T2],'dot_size',2,'overlay_style','sd','corral_style','rand');

yticks([0:0.02:0.04])
xticks([1:4])
xticklabels({'POST1 T1','POST1 T2'})
ylabel('Replay rate (events/sec)')
set(gca,'FontSize',14)
ylim([0 0.05])
hold on

tst=[INTER_T1_rate_events; INTER_T2_rate_events]';

xbe = reshape(xbe,size(tst,1),size(tst,2));
for i = 1:size(tst,1)
    plot(xbe(i,[1 2]),tst(i,[1 2]),'Color',[0,0,0,0.2])

end

axis square
title(sprintf('POST1 replay rate (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[INTER_T1_rate_events(prot_sess{1}) INTER_T1_rate_events(prot_sess{2})...
    INTER_T1_rate_events(prot_sess{3}) INTER_T1_rate_events(prot_sess{4}) INTER_T1_rate_events(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.02:0.04])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay rate (events/sec)')
set(gca,'FontSize',14)
ylim([0 0.05])
axis square
title(sprintf('POST1 T1 replay (%s)',rest_option));

nexttile
prot_sess = [{1:4} {5:8} {9:12} {13:15} {16:19}];
grp = [ones(4,1)*5;ones(3,1)*4;ones(4,1)*3;ones(4,1)*2;ones(4,1)*1];% Only three session with 16-4 laps
tst=[INTER_T2_rate_events(prot_sess{1}) INTER_T2_rate_events(prot_sess{2})...
    INTER_T2_rate_events(prot_sess{3}) INTER_T2_rate_events(prot_sess{4}) INTER_T2_rate_events(prot_sess{5})]';

xbe = beeswarm(grp,tst,'sort_style','nosort','colormap',...
    [PP1.T2(1,:);...
    PP1.T2(2,:);...
    PP1.T2(3,:);...
    PP1.T2(4,:);...
    PP1.T2(5,:);],'dot_size',2,'overlay_style','sd','corral_style','rand');
hold on

yticks([0:0.02:0.04])
xticks([1:5])
xticklabels({'16-1','16-2','16-3','16-4','16-8'})
ylabel('Replay rate (events/sec)')
set(gca,'FontSize',14)
ylim([0 0.05])
axis square
title(sprintf('POST1 T2 replay (%s)',rest_option));


%%
bayesian_control = 'RUN1 final lap'
plot_diff_cum_replay_periods('sleep',bayesian_control)

save_dir = 'X:\BendorLab\Drobo\manuscripts\Huelin and Bendor replay prioritisation\Figure revision';
save_all_figures(save_dir,[])

end