% NUMBER OF LOCAL AND REMOTE AWAKE REPLAY EVENTS IN TRACKS PER PROTOCOL
% MH 2020
% Plots a figure per protocol. Each subplot is a rat. Within subplot, all tracks plotted with bar plot, each bar indicating number of replay events
% decoded during that track, for each possible track decoded.
% INPUT: 
%   Mutlievents: 1 to select. If selection, then loads multievents data and plots only 2 bars for T1 and T2. Meaning it does not take into account events
%               for re-exposure during T1 and T2.
%   Data_type: 'main' for main data set, 'speed' for control speed manipulation
%   Bayesian_control: 1 to select for data sets with bayesian separate for each exposure. Loads two data sets, one using first exposure, the other
%   using re-exposure ratemaps as a decoding template.


function plot_awake_replay_track(multievents,data_type,bayesian_control)

if strcmp(data_type,'main') & isempty(bayesian_control)
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\behavioural_data.mat')
elseif strcmp(data_type,'speed')
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Speed';
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\Speed Control\behavioural_data.mat')
elseif strcmp(data_type,'main') & ~isempty(bayesian_control)
    path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only first exposure';
    path2 = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only re-exposure';
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\behavioural_data.mat')
end

% Parameters
if multievents == 1
    load([path '\extracted_replay_plotting_info_MultiEvents.mat'])
    multievents_data = track_replay_events;
    clear track_replay_events
    load([path '\extracted_replay_plotting_info.mat'])
    alltracks_data = track_replay_events;
    if isfield(track_replay_events,'T4')
        num_tracks = 4;
    else
        num_tracks = 2;
    end
    num_sessions = length(track_replay_events);
    num_events_in_track = nan(1,num_tracks*num_tracks);
    event_times_in_track = nan(155,num_tracks*num_tracks,length(track_replay_events));
    clear track_replay_events
else
    if ~isempty(bayesian_control)
        track_replay_events_F = load([path '\extracted_replay_plotting_info_excl.mat']);
        track_replay_events_R = load([path2 '\extracted_replay_plotting_info_excl.mat']);
        track_replay_events = track_replay_events_F.track_replay_events;
    else
        load([path '\extracted_replay_plotting_info_excl.mat'])
    end
    if isfield(track_replay_events,'T4')
        num_tracks1 = 4;
        num_tracks2 = 4;
    else
        num_tracks1 = 4;
        num_tracks2 = 2;
    end
    num_sessions = length(track_replay_events);
    num_events_in_track = nan(1,num_tracks1*num_tracks2);
    event_times_in_track = nan(155,num_tracks1*num_tracks2,length(track_replay_events));
end
load([path '\extracted_time_periods_replay_excl.mat']) % for bayesian_control any of the paths works
PP =  plotting_parameters;

for s = 1 : num_sessions
    c = 1;
    % Find time spent immobile in each track
    imm_times = time_immobile(s,:);
    % For each track, find replay events occurring during the track
    for t = 1 : num_tracks1
        if multievents == 1 %if using multievents, for T1 and T2 use multievent (to not take into account the re-exposures)
            if t < 3
                track_replay_events = multievents_data;
            else
                track_replay_events = alltracks_data;
            end
        end
        if ~isempty(bayesian_control) & t > 2
            track_replay_events = track_replay_events_R.track_replay_events;
        elseif  ~isempty(bayesian_control) & t < 2
            track_replay_events = track_replay_events_F.track_replay_events;
        end
        for  track = 1 : num_tracks2
            % Each row a session. Columns e.g.T1 = col 1:4, with 1 being T1 events during T1, 2 - T2 events during T1, 3 are T3 events
            % during T1 & 4 are T4 events during T1. Next 4 columns (5:9)would be events during T2, etc
            num_events_in_track(s,c) = length(track_replay_events(s).(strcat('T',num2str(track))).(strcat('T',num2str(t),'_index')));
            norm_num_events_in_track(s,c) = length(track_replay_events(s).(strcat('T',num2str(track))).(strcat('T',num2str(t),'_index')))/imm_times(t);
            event_times_in_track(1:length(track_replay_events(s).(strcat('T',num2str(track))).(strcat('T',num2str(t),'_times'))),c,s) = ...
                track_replay_events(s).(strcat('T',num2str(track))).(strcat('T',num2str(t),'_times'));
            c = c+1;
        end
    end
end

%%%% FIGURES FOR MAIN DATA
if strcmp(data_type,'main') 

  %% 
  %%%% Plot number of events per track, all protocols together
f11 = figure('Color','w','Name','Number awake replay events - All exposures');
grp = [ones(num_sessions,1);ones(num_sessions,1)*2;ones(num_sessions,1)*3;ones(num_sessions,1)*4];
if num_tracks2 == 4
    tst=[num_events_in_track(:,1);num_events_in_track(:,6);num_events_in_track(:,11);num_events_in_track(:,16)];
else
    tst=[num_events_in_track(:,1);num_events_in_track(:,4);num_events_in_track(:,5);num_events_in_track(:,8)];
end
beeswarm(grp,tst,'sort_style','nosort','colormap',[PP.T1;[0.6 0.6 0.6];PP.T1;[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci','corral_style','rand');
yticks([0,50,100,150])
xticks([1:4])
xticklabels({'T1','T2','RT1','RT2'})
ylabel('Number local awake replay events')
set(gca,'FontSize',14)
ylim([-0.5 160])

if num_tracks2 == 4
    [p,~,stats] = kruskalwallis([num_events_in_track(:,1),num_events_in_track(:,6),num_events_in_track(:,11),num_events_in_track(:,16)],[],'off')
else
    [p,tbl,stats] = kruskalwallis([num_events_in_track(:,1),num_events_in_track(:,4),num_events_in_track(:,5),num_events_in_track(:,8)],[],'off')
    [p2,~] = ranksum(num_events_in_track(:,5),num_events_in_track(:,8))
end
if p < .05
    c = multcompare(stats);
end

%% 
%%% PLOT difference T1 and T2 events for first and second exposure  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f122 = figure('Color','w','Name','Difference in number of local track awake replay events');
tiledlayout('flow')

%1st exposure difference
if num_tracks2 == 4 % adding first and sec exposure
    grp2 = [ones(4,1);ones(4,1)*2;ones(4,1)*3;ones(4,1)*4;ones(4,1)*5];
    tst1=[sum([num_events_in_track(:,1) num_events_in_track(:,3)],2)] - [sum([num_events_in_track(1:4,6) num_events_in_track(1:4,8)],2);sum([num_events_in_track(5:8,6) num_events_in_track(5:8,8)],2);...
        sum([num_events_in_track(9:12,6) num_events_in_track(9:12,8)],2);sum([num_events_in_track(13:16,6) num_events_in_track(13:16,8)],2);...
        sum([num_events_in_track(17:20,6) num_events_in_track(17:20,8)],2)];
else   % only 2 tracks, thus no-rexposure
    grp2 = [ones(4,1);ones(3,1)*2;ones(4,1)*3;ones(4,1)*4;ones(4,1)*5];
    tst1= num_events_in_track(:,1) - num_events_in_track(:,4);
end
nexttile
beeswarm(grp2,tst1,'sort_style','nosort','colormap',[PP.T2;PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
hold on
plot([min(xlim) max(xlim)],[0 0],'Color',[0.6 0.6 0.6])
title('First exposure')

%RE- exposure difference
if num_tracks2 == 4 % adding first and sec exposure
    tst2=[sum([num_events_in_track(:,11) num_events_in_track(:,9)],2)] - [sum([num_events_in_track(1:4,16) num_events_in_track(1:4,14)],2);sum([num_events_in_track(5:8,16) num_events_in_track(5:8,14)],2);...
        sum([num_events_in_track(9:12,16) num_events_in_track(9:12,14)],2);sum([num_events_in_track(13:16,16) num_events_in_track(13:16,14)],2);...
        sum([num_events_in_track(17:20,16) num_events_in_track(17:20,14)],2)];
else
    tst2=num_events_in_track(:,5) - num_events_in_track(:,8);
end
nexttile
beeswarm(grp2,tst2,'sort_style','nosort','colormap',[PP.T2;PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
hold on
plot([min(xlim) max(xlim)],[0 0],'Color',[0.6 0.6 0.6])
title('Re-exposure')
allAxesInFigure = findall(f122,'type','axes');
ylabel(allAxesInFigure,{'Difference in number'; 'awake replay events'})
set(allAxesInFigure(:),'XTick',[1:5],'XTickLabel',[8 4 3 2 1])
set(allAxesInFigure,'FontSize',16,'TickDir','out','LineWidth',1.5,'TickLength',[.005 1])

%% 
%%%%%%%%%%%%% Difference in number of local exposure awake replay events
f155 = figure('Color','w','Name','Difference in number of local exposure awake replay events');
tiledlayout('flow')

%1st exposure difference
if num_tracks2 == 4 % adding first and sec exposure
    grp2 = [ones(4,1);ones(4,1)*2;ones(4,1)*3;ones(4,1)*4;ones(4,1)*5];
    tst1=[num_events_in_track(:,1)] - [num_events_in_track(1:4,6); num_events_in_track(5:8,6) ; num_events_in_track(9:12,6);num_events_in_track(13:16,6) ;...
        num_events_in_track(17:20,6)] ;
else   % only 2 tracks, thus no-rexposure
    grp2 = [ones(4,1);ones(3,1)*2;ones(4,1)*3;ones(4,1)*4;ones(4,1)*5];
    tst1=[num_events_in_track(:,1)] - [num_events_in_track(1:4,4); num_events_in_track(5:7,4) ; num_events_in_track(8:11,4);num_events_in_track(12:15,4) ;...
    num_events_in_track(16:19,4)] ;
end
nexttile
beeswarm(grp2,tst1,'sort_style','nosort','colormap',[PP.T2;PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
hold on
plot([min(xlim) max(xlim)],[0 0],'Color',[0.6 0.6 0.6])
title('First exposure')

 %RE- exposure difference
if num_tracks2 == 4 % adding first and sec exposure
    tst2=[num_events_in_track(:,11)] - [num_events_in_track(1:4,16);num_events_in_track(5:8,16);num_events_in_track(9:12,16);num_events_in_track(13:16,16) ;...
    num_events_in_track(17:20,16)];
else
   tst2 = [num_events_in_track(:,5)] - [num_events_in_track(1:4,8); num_events_in_track(5:7,8) ; num_events_in_track(8:11,8);num_events_in_track(12:15,8) ;...
    num_events_in_track(16:19,8)] ;
end
nexttile
beeswarm(grp2,tst2,'sort_style','nosort','colormap',[PP.T2;PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
hold on
plot([min(xlim) max(xlim)],[0 0],'Color',[0.6 0.6 0.6])
title('Re-exposure')

allAxesInFigure = findall(f155,'type','axes');
ylabel(allAxesInFigure,{'Difference in number';'awake replay events'})
set(allAxesInFigure(:),'XTick',[1:5],'XTickLabel',[8 4 3 2 1])
set(allAxesInFigure,'FontSize',16,'TickDir','out','LineWidth',1.5,'TickLength',[.005 1])

%%
%%%% Plot number of events per track during first exposure  - merges
%%%% events for first and second exposure (e.g. T2+R-T2 during running in T2)   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f12 = figure('Color','w','Name','Number awake replay events - First exposure');
tiledlayout('flow')
% Normalised number of events by time immobile
nexttile
if num_tracks2 == 4 % adding first and sec exposure
    grp2 = [ones(4,1);ones(4,1)*2;ones(4,1)*3;ones(4,1)*4;ones(4,1)*5;ones(20,1)*6];
    tst2=[sum([norm_num_events_in_track(17:20,6) norm_num_events_in_track(17:20,8)],2);sum([norm_num_events_in_track(13:16,6) norm_num_events_in_track(13:16,8)],2);...
        sum([norm_num_events_in_track(9:12,6) norm_num_events_in_track(9:12,8)],2);sum([norm_num_events_in_track(5:8,6) norm_num_events_in_track(5:8,8)],2);...
        sum([norm_num_events_in_track(1:4,6) norm_num_events_in_track(1:4,8)],2);sum([norm_num_events_in_track(:,1) norm_num_events_in_track(:,3)],2)];
else
    grp2 = [ones(4,1);ones(4,1)*2;ones(4,1)*3;ones(3,1)*4;ones(4,1)*5;ones(19,1)*6];
    tst2=[norm_num_events_in_track(16:19,4);norm_num_events_in_track(12:15,4);norm_num_events_in_track(8:11,4); norm_num_events_in_track(5:7,4);...
        norm_num_events_in_track(1:4,4);norm_num_events_in_track(:,1)];
end
beeswarm(grp2,tst2,'sort_style','nosort','colormap',[flipud(PP.T2);PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
xticks([1:6])
xticklabels({'1','2','3','4','8','16'})
xlabel('Number of laps')
ylabel({'Normalized number local';'awake replay events'})
set(gca,'FontSize',14)
    % Repeat with logarithm
nexttile
beeswarm(grp2,log(tst2),'sort_style','nosort','colormap',[flipud(PP.T2);PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
xticks([1:6])
xticklabels({'1','2','3','4','8','16'})
xlabel('Number of laps')
ylabel({'Normalized number local';'awake replay events (log)'})
set(gca,'FontSize',14)

% Number of events (repeat with not normalised)
nexttile
if num_tracks2 == 4 % adding first and sec exposure
    grp2 = [ones(4,1);ones(4,1)*2;ones(4,1)*3;ones(4,1)*4;ones(4,1)*5;ones(20,1)*6];
    tst1=[sum([num_events_in_track(17:20,6) num_events_in_track(17:20,8)],2);sum([num_events_in_track(13:16,6) num_events_in_track(13:16,8)],2);...
        sum([num_events_in_track(9:12,6) num_events_in_track(9:12,8)],2);sum([num_events_in_track(5:8,6) num_events_in_track(5:8,8)],2);...
        sum([num_events_in_track(1:4,6) num_events_in_track(1:4,8)],2);sum([num_events_in_track(:,1) num_events_in_track(:,3)],2)];
else
    grp2 = [ones(4,1);ones(4,1)*2;ones(4,1)*3;ones(3,1)*4;ones(4,1)*5;ones(19,1)*6];
    tst1=[num_events_in_track(16:19,4);num_events_in_track(12:15,4);num_events_in_track(8:11,4); num_events_in_track(5:7,4);...
        num_events_in_track(1:4,4);num_events_in_track(:,1)];
end
beeswarm(grp2,tst1,'sort_style','nosort','colormap',[flipud(PP.T2);PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
yticks([0,50,100,150])
xticks([1:6])
xticklabels({'1','2','3','4','8','16'})
xlabel('Number of laps')
ylabel({'Number local';'awake replay events'})
set(gca,'FontSize',14)
ylim([-0.5 160])
    % Repeat with logarithm
nexttile
beeswarm(grp2,log(tst1),'sort_style','nosort','colormap',[flipud(PP.T2);PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
xticks([1:6])
xticklabels({'1','2','3','4','8','16'})
xlabel('Number of laps')
ylabel({'Number local';'awake replay events (log)'})
set(gca,'FontSize',14)

if num_tracks2 == 4 % adding first and sec exposure
    [p1,~]=ranksum([num_events_in_track(17:20,6);nan(16,1)]',num_events_in_track(:,1)');
    [p2,~]=ranksum([num_events_in_track(13:16,6);nan(16,1)]',num_events_in_track(:,1)');
    [p3,~]=ranksum([num_events_in_track(9:12,6);nan(16,1)]',num_events_in_track(:,1)');
    [p4,~]=ranksum([num_events_in_track(5:8,6);nan(16,1)]',num_events_in_track(:,1)');
    [p5,~]=ranksum([num_events_in_track(1:4,6);nan(16,1)]',num_events_in_track(:,1)');
else
    [p1,~]=ranksum([num_events_in_track(16:19,4);nan(16,1)]',num_events_in_track(:,1)');
    [p2,~]=ranksum([num_events_in_track(12:15,4);nan(16,1)]',num_events_in_track(:,1)');
    [p3,~]=ranksum([num_events_in_track(8:11,4);nan(16,1)]',num_events_in_track(:,1)');
    [p4,~]=ranksum([num_events_in_track(5:7,4);nan(16,1)]',num_events_in_track(:,1)');
    [p5,~]=ranksum([num_events_in_track(1:4,4);nan(16,1)]',num_events_in_track(:,1)');
end

%%   
%%%% Plot number of events per track during re-exposure  - merges  %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% events for first and second exposure (T2+R-T2)
f13 = figure('Color','w','Name','Number awake local track replay events - Re-exposure');
tiledlayout('flow')
% Normalised number by time immobile
nexttile
if num_tracks2 == 4 % adding first and sec exposure
    grp22 = [ones(20,1);ones(4,1)*2;ones(4,1)*3;ones(4,1)*4;ones(4,1)*5;ones(4,1)*6];
    tst22=[sum([norm_num_events_in_track(:,11) norm_num_events_in_track(:,9)],2);sum([norm_num_events_in_track(1:4,16) norm_num_events_in_track(1:4,14)],2);sum([norm_num_events_in_track(5:8,16) norm_num_events_in_track(5:8,14)],2);...
        sum([norm_num_events_in_track(9:12,16) norm_num_events_in_track(9:12,14)],2);sum([norm_num_events_in_track(13:16,16) norm_num_events_in_track(13:16,14)],2);...
        sum([norm_num_events_in_track(17:20,16) norm_num_events_in_track(17:20,14)],2)];
else
    grp22 = [ones(4,1)*2;ones(4,1)*3;ones(4,1)*4;ones(3,1)*5;ones(4,1)*6;ones(19,1)];
    tst22=[norm_num_events_in_track(16:19,8);norm_num_events_in_track(12:15,8);norm_num_events_in_track(8:11,8); norm_num_events_in_track(5:7,8);...
        norm_num_events_in_track(1:4,8);norm_num_events_in_track(:,5)];
end
beeswarm(grp22,tst22,'sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci','corral_style','rand');
xticks(1:6)
xticklabels({'16','8','4','3','2','1'})
xlabel('Number of laps')
ylabel({'Normalized number local';'awake replay events'})
set(gca,'FontSize',14)
    % Repeat with log
nexttile
beeswarm(grp22,log(tst22),'sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci','corral_style','rand');
xticks(1:6)
xticklabels({'16','8','4','3','2','1'})
xlabel('Number of laps')
ylabel({'Normalized number local';'awake replay events (log)'})
set(gca,'FontSize',14)

% Number of events (repeat without normalization)
nexttile
if num_tracks2 == 4 % adding first and sec exposure
    tst11=[sum([num_events_in_track(:,11) num_events_in_track(:,9)],2);sum([num_events_in_track(1:4,16) num_events_in_track(1:4,14)],2);sum([num_events_in_track(5:8,16) num_events_in_track(5:8,14)],2);...
        sum([num_events_in_track(9:12,16) num_events_in_track(9:12,14)],2);sum([num_events_in_track(13:16,16) num_events_in_track(13:16,14)],2);...
        sum([num_events_in_track(17:20,16) num_events_in_track(17:20,14)],2)];
else
    tst11=[num_events_in_track(16:19,8);num_events_in_track(12:15,8);num_events_in_track(8:11,8); num_events_in_track(5:7,8);...
        num_events_in_track(1:4,8);num_events_in_track(:,5)];
end
beeswarm(grp22,tst11,'sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci','corral_style','rand');
yticks([0,50,100,150])
xticks([1:6])
xticklabels({'16','8','4','3','2','1'})
xlabel('Number of laps')
ylabel({'Number local awake';'replay events'})
set(gca,'FontSize',14)
ylim([-0.5 160])
    % Repeat with log
nexttile
beeswarm(grp22,log(tst11),'sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci','corral_style','rand');
xticks([1:6])
xticklabels({'16','8','4','3','2','1'})
xlabel('Number of laps')
ylabel({'Number local awake';'replay events (log)'})
set(gca,'FontSize',14)

if num_tracks2 == 4 % for main data set
    [p13,~]=ranksum([num_events_in_track(17:20,16);nan(16,1)]',num_events_in_track(:,11)');
    [p23,~]=ranksum([num_events_in_track(13:16,16);nan(16,1)]',num_events_in_track(:,11)');
    [p33,~]=ranksum([num_events_in_track(9:12,16);nan(16,1)]',num_events_in_track(:,11)');
    [p43,~]=ranksum([num_events_in_track(5:8,16);nan(16,1)]',num_events_in_track(:,11)');
    [p53,~]=ranksum([num_events_in_track(1:4,16);nan(16,1)]',num_events_in_track(:,11)');
else
    [p13,~]=ranksum([num_events_in_track(16:19,8);nan(16,1)]',num_events_in_track(:,5)');
    [p23,~]=ranksum([num_events_in_track(12:15,8);nan(16,1)]',num_events_in_track(:,5)');
    [p33,~]=ranksum([num_events_in_track(8:11,8);nan(16,1)]',num_events_in_track(:,5)');
    [p43,~]=ranksum([num_events_in_track(5:7,8);nan(16,1)]',num_events_in_track(:,5)');
    [p53,~]=ranksum([num_events_in_track(1:4,8);nan(16,1)]',num_events_in_track(:,5)');
end

%%
%%%%%%%% Number awake local exposure replay events - Re-exposure
f133 = figure('Color','w','Name','Number awake local exposure replay events - Re-exposure');
tiledlayout('flow')
grp22 = [ones(20,1);ones(4,1)*2;ones(4,1)*3;ones(4,1)*4;ones(4,1)*5;ones(4,1)*6];
% Normalised number by time immobile
nexttile
tst22=[norm_num_events_in_track(:,11);norm_num_events_in_track(1:4,16);norm_num_events_in_track(5:8,16);norm_num_events_in_track(9:12,16);norm_num_events_in_track(13:16,16);...
    norm_num_events_in_track(17:20,16)];
beeswarm(grp22,tst22,'sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci','corral_style','rand');
xticks(1:6)
xticklabels({'16','8','4','3','2','1'})
xlabel('Number of laps')
ylabel('Normalized number local awake replay events')
set(gca,'FontSize',14)
    % Repeat with log
nexttile
beeswarm(grp22,log(tst22),'sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci','corral_style','rand');
xticks(1:6)
xticklabels({'16','8','4','3','2','1'})
xlabel('Number of laps')
ylabel('Normalized number local awake replay events (log)')
set(gca,'FontSize',14)
% Number of events
nexttile
tst11=[num_events_in_track(:,11);num_events_in_track(1:4,16);num_events_in_track(5:8,16);num_events_in_track(9:12,16);num_events_in_track(13:16,16);...
    num_events_in_track(17:20,16) ];
beeswarm(grp22,tst11,'sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci','corral_style','rand');
yticks([0,50,100,150])
xticks([1:6])
xticklabels({'16','8','4','3','2','1'})
xlabel('Number of laps')
ylabel('Number local awake replay events')
set(gca,'FontSize',14)
ylim([-0.5 160])
    % Repeat with log
nexttile
beeswarm(grp22,log(tst11),'sort_style','nosort','colormap',[PP.T1;PP.T2],'dot_size',2,'overlay_style','ci','corral_style','rand');
xticks([1:6])
xticklabels({'16','8','4','3','2','1'})
xlabel('Number of laps')
ylabel('Number local awake replay events (log)')
set(gca,'FontSize',14)


[p,~,stats] = kruskalwallis(tst11,grp22)
if p < .05
    c = multcompare(stats);
end

%%
%%%%%%%% All (local+remote) awake replay in track for both exposures
f155 = figure('Color','w','Name','Number awake replay all exposures');
tiledlayout('flow')
grp_frst = [ones(4,1);ones(4,1)*2;ones(4,1)*3;ones(3,1)*4;ones(4,1)*5;ones(19,1)*6]; %from 1 to 16
for j = 1 : 2
    if j == 1
        x = [1:4];
        ttle = '1st Exposure';
    else
        x = [5:8];
        ttle = 'Re-exposure';
    end

    % Normalised number by time immobile
    tst_frst_norm=[[norm_num_events_in_track(16:19,x(3))+norm_num_events_in_track(16:19,x(4))];[norm_num_events_in_track(12:15,x(3))+norm_num_events_in_track(12:15,x(4))];...
        [norm_num_events_in_track(8:11,x(3))+norm_num_events_in_track(8:11,x(4))];[norm_num_events_in_track(5:7,x(3))+norm_num_events_in_track(5:7,x(4))];...
        [norm_num_events_in_track(1:4,x(3))+norm_num_events_in_track(1:4,x(4))];[norm_num_events_in_track(:,x(1))+norm_num_events_in_track(:,x(2))]];
    nexttile
    beeswarm(grp_frst,tst_frst_norm,'sort_style','nosort','colormap',[flipud(PP.T2);PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
    xticks(1:6)
    xticklabels(fliplr({'16','8','4','3','2','1'}))
    xlabel('Number of laps')
    ylabel({'Normalized number awake';'replay events'})
    set(gca,'FontSize',14)
    title(gca,ttle)

    %%% Repeat with log
    nexttile
    beeswarm(grp_frst,log(tst_frst_norm),'sort_style','nosort','colormap',[flipud(PP.T2);PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
    xticks(1:6)
    xticklabels(fliplr({'16','8','4','3','2','1'}))
    xlabel('Number of laps')
    ylabel({'Normalized number awake';'replay events (log)'})
    set(gca,'FontSize',14)
    title(gca,ttle)

    %%% Number of events
    nexttile
    tst_frst=[[num_events_in_track(16:19,x(3))+num_events_in_track(16:19,x(4))];[num_events_in_track(12:15,x(3))+num_events_in_track(12:15,x(4))];...
        [num_events_in_track(8:11,x(3))+num_events_in_track(8:11,x(4))];[num_events_in_track(5:7,x(3))+num_events_in_track(5:7,x(4))];...
        [num_events_in_track(1:4,x(3))+num_events_in_track(1:4,x(4))];[num_events_in_track(:,x(1))+num_events_in_track(:,x(2))]];
    beeswarm(grp_frst,tst_frst,'sort_style','nosort','colormap',[flipud(PP.T2);PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
    yticks([0,50,100,150])
    xticks([1:6])
    xticklabels(fliplr({'16','8','4','3','2','1'}))
    xlabel('Number of laps')
    ylabel({'Number awake';'replay events'})
    set(gca,'FontSize',14)
    ylim([-0.5 160])
    title(gca,ttle)

    %%% Repeat with log
    nexttile
    beeswarm(grp_frst,log(tst_frst),'sort_style','nosort','colormap',[flipud(PP.T2);PP.T1],'dot_size',2,'overlay_style','ci','corral_style','rand');
    xticks([1:6])
    xticklabels(fliplr({'16','8','4','3','2','1'}))
    xlabel('Number of laps')
    ylabel({'Number awake';'replay events (log)'})
    set(gca,'FontSize',14)
    title(gca,ttle)

end

[p,~,stats] = kruskalwallis(tst11,grp22)
if p < .05
    c = multcompare(stats);
end




%%
% BAR PLOT - NUMBER OF REPLAY EVENTS PER TRACK IN EACH TRACK - PER EACH SESSION
protocols = [8,4,3,2,1];
count = 1;
for p = 1 : length(protocols)
    
    cols = repmat([PP.P(p).colorT(1,:); PP.P(p).colorT(2,:);PP.P(p).colorT(3,:) ;PP.P(p).colorT(4,:)],[4,1]);
    f(p) = figure('units','normalized','outerposition',[0 0 1 1]);
    if multievents == 1
        f(p).Name = ['Number of awake replay events per track_per rat_MultiEvents_Protocol 16x' num2str(protocols(p))];
    else
        f(p).Name = ['Number of awake replay events per track_per rat_Protocol 16x' num2str(protocols(p))];
    end
    if multievents == 1
        x = [1:2,4:5,7:10,12:15];
        jj =[1:2,5:6,9:16];
    else
        x = [1:4,6:9,11:14,16:19];
    end
    for c =  1 : 4
        ax(c) = subplot(4,1,c);
        for ii = 1 : length(x)
            hold on
            if multievents == 1
                b(ii) = bar(x(ii), num_events_in_track(count,jj(ii)),0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
            else
                b(ii) = bar(x(ii), num_events_in_track(count,ii),0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
            end
        end
        box off
        ylabel('Mean number of cells','Fontsize',18)
        xticks([2.5,7.5,12.5,17.5]); xticklabels({'T1','T2','R-T1','R-T2'});
        legend([b(1),b(2),b(3),b(4)],{'T1','T2','T3','T4'},'Location','northeastoutside');
        ylabel('# replay events')
        ax(c).FontSize = 16;
        count = count+1;
    end
end

% BAR PLOT - NUMBER OF REPLAY EVENTS PER TRACK IN EACH TRACK - PER EACH SESSION
protocols = [8,4,3,2,1];
val = [1,6,11,16];
count = 1;
f(p) = figure('units','normalized','outerposition',[0 0 1 1]);
if multievents == 1
    f(p).Name = ['Number of awake replay events per track_MultiEvents_ALL_Protocol'];
else
    f(p).Name = ['Number of awake replay events per track__ALL_Protocol'];
end

for p = 1 : length(protocols)
    
    cols = repmat([PP.P(p).colorT(1,:); PP.P(p).colorT(2,:);PP.P(p).colorT(3,:) ;PP.P(p).colorT(4,:)],[4,1]);
    ax(p) = subplot(5,1,p);
    
    if multievents == 1
        x = [1:2,4:5,7:10,12:15];
        jj =[1:2,5:6,9:16];
    else
        x = [1:4];
    end
    t(1) = mean(num_events_in_track(count:count+3,1));
    t(2) = mean(num_events_in_track(count:count+3,6));
    t(3) = mean(num_events_in_track(count:count+3,11));
    t(4) = mean(num_events_in_track(count:count+3,16));
    [pv(p).t12,~]=ranksum([num_events_in_track(count:count+3,1)],[num_events_in_track(count:count+3,6)]);
    [pv(p).t34,~]=ranksum([num_events_in_track(count:count+3,11)],[num_events_in_track(count:count+3,16)]);
    for ii = 1 : length(x)
        hold on
        if multievents == 1
            b(ii) = bar(x(ii), num_events_in_track(count,jj(ii)),0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
        else
            b(ii) = bar(x(ii),t(ii) ,0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
            hold on
            plot(ones(1,4)*ii,num_events_in_track(count:count+3,val(ii)),'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',cols(ii,:))
        end
    end
    box off
    ylabel('Mean number of cells','Fontsize',18)
    xticks([2.5,7.5,12.5,17.5]); xticklabels({'T1','T2','R-T1','R-T2'});
    legend([b(1),b(2),b(3),b(4)],{'T1','T2','T3','T4'},'Location','northeastoutside');
    ylabel('# replay events')
    ax(p).FontSize = 16;
    count = count+4;
end

% BAR PLOT - NORMALISED NUMBER OF LOCAL REPLAY EVENTS (BY TIME IMMOBILE) PER TRACK IN EACH TRACK - PER EACH SESSION
protocols = [8,4,3,2,1];
val = [1,6,11,16];
count = 1;
f(p) = figure('units','normalized','outerposition',[0 0 1 1]);
if multievents == 1
    f(p).Name = ['Norm number of awake replay events per track_MultiEvents_ALL_Protocol'];
else
    f(p).Name = ['Norm number of awake replay events per track__ALL_Protocol'];
end

for p = 1 : length(protocols)
    
    cols = repmat([PP.P(p).colorT(1,:); PP.P(p).colorT(2,:);PP.P(p).colorT(3,:) ;PP.P(p).colorT(4,:)],[4,1]);
    ax(p) = subplot(5,1,p);
    
    if multievents == 1
        x = [1:2,4:5,7:10,12:15];
        jj =[1:2,5:6,9:16];
    else
        x = [1:4];
    end
    t(1) = mean(norm_num_events_in_track(count:count+3,1));
    t(2) = mean(norm_num_events_in_track(count:count+3,6));
    t(3) = mean(norm_num_events_in_track(count:count+3,11));
    t(4) = mean(norm_num_events_in_track(count:count+3,16));
    [pv(p).t12_prop,~]=ranksum([norm_num_events_in_track(count:count+3,1)],[norm_num_events_in_track(count:count+3,6)]);
    [pv(p).t34_prop,~]=ranksum([norm_num_events_in_track(count:count+3,11)],[norm_num_events_in_track(count:count+3,16)]);
    for ii = 1 : length(x)
        hold on
        if multievents == 1
            b(ii) = bar(x(ii), norm_num_events_in_track(count,jj(ii)),0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
        else
            b(ii) = bar(x(ii),t(ii) ,0.5,'facecolor', cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
            hold on
            %plot(ones(1,4)*ii,norm_num_events_in_track(count:count+3,val(ii)),'o','MarkerFaceColor',[1 1 1],'MarkerEdgeColor',cols(ii,:))
            plot(ii,norm_num_events_in_track(count,val(ii)),'Marker',PP.rat_markers{1},'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',cols(ii,:))
            plot(ii,norm_num_events_in_track(count+1,val(ii)),'Marker',PP.rat_markers{2},'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',cols(ii,:))
            plot(ii,norm_num_events_in_track(count+2,val(ii)),'Marker',PP.rat_markers{3},'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',cols(ii,:))
            plot(ii,norm_num_events_in_track(count+3,val(ii)),'Marker',PP.rat_markers{4},'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',cols(ii,:))

        end
    end
    box off
    xticks([2.5,7.5,12.5,17.5]); xticklabels({'T1','T2','R-T1','R-T2'});
    legend([b(1),b(2),b(3),b(4)],{'T1','T2','T3','T4'},'Location','northeastoutside');
    ylabel('norm. # replay events','Fontsize',18)
    ax(p).FontSize = 16;
    count = count+4;
end

elseif strcmp(data_type,'speed') %%%% FIGURES FOR SPEED DATA

    % Get sessions ID to find select corresponding color
    sessions_ID  = arrayfun(@(x) (track_replay_events(x).session{1,1}(strfind(track_replay_events(x).session{1,1},'x')+1:end)),1:length(track_replay_events),'UniformOutput',0);
    color_idx = cell2mat(arrayfun(@(x) find(strcmp(fieldnames(PP),strcat('L', sessions_ID{x}))),1:length(sessions_ID),'UniformOutput',0));
    cols = cell2mat(arrayfun(@(x) PP.(subsref(fieldnames(PP),substruct('{}',{x}))),color_idx,'UniformOutput',0)');
    
    % Number local awake replay on track per session
    f1 = figure('Color','w');
    f1.Name =  'Local awake replay on track';
    for j = 1 : length(sessions_ID)
        subplot(length(sessions_ID),1,j)
        grp = [ones(1,1);ones(1,1)*2;ones(1,1)*3;ones(1,1)*4];
        tst=[num_events_in_track(j,1);num_events_in_track(j,6);num_events_in_track(j,11);num_events_in_track(j,16)];
        beeswarm(grp,tst,'sort_style','nosort','colormap',[cols(j,:);[0.6 0.6 0.6];cols(j,:);[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci','corral_style','rand');
        title(['Session ' sessions_ID{j} 'x'  sessions_ID{j}])
        ylabel('# Local awake replay'); xticks([1,2,3,4]);xticklabels({'T1','T2','R-T1','R-T2'})
        set(gca,'FontSize',14)
    end
    
    % Normalised number of local awake replay on track per session
    f2 = figure('Color','w');
    f2.Name =  'Normalised number local awake replay on track';
    for j = 1 : length(sessions_ID)
        subplot(length(sessions_ID),1,j)
        grp = [ones(1,1);ones(1,1)*2;ones(1,1)*3;ones(1,1)*4];
        tst=[norm_num_events_in_track(j,1);norm_num_events_in_track(j,6);norm_num_events_in_track(j,11);norm_num_events_in_track(j,16)];
        beeswarm(grp,tst,'sort_style','nosort','colormap',[cols(j,:);[0.6 0.6 0.6];cols(j,:);[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci','corral_style','rand');
        title(['Session ' sessions_ID{j} 'x'  sessions_ID{j}])
        ylabel('Norm # Local awake replay'); xticks([1,2,3,4]);xticklabels({'T1','T2','R-T1','R-T2'})
        set(gca,'FontSize',14)
    end

    % Normalised number of local and remote awake replay on track per session
    f3 = figure('Color','w');
    f3.Name =  'Normalised number local and remote awake replay on track';
    for j = 1 : length(sessions_ID)
        col_test = repmat([cols(j,:);cols(j,:);[0.6 0.6 0.6];[0.6 0.6 0.6]],4,1);
        subplot(length(sessions_ID),1,j)
        grp = [ones(4,1);ones(4,1)*2;ones(4,1)*3;ones(4,1)*4];
        tst2=[norm_num_events_in_track(j,1:4)';norm_num_events_in_track(j,5:8)';norm_num_events_in_track(j,9:12)';norm_num_events_in_track(j,13:16)'];
        beeswarm(grp,tst2,'sort_style','nosort','colormap',[cols(j,:);[0.6 0.6 0.6];cols(j,:);[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci',...
            'corral_style','rand','MarkerFaceColor',col_test);      
        title(['Session ' sessions_ID{j} 'x'  sessions_ID{j}])
        ylabel('#  awake replay'); xticks([1,2,3,4]);xticklabels({'T1','T2','R-T1','R-T2'})
        set(gca,'FontSize',14)
    end

    % Number of local and remote awake replay on track per session
    f4 = figure('Color','w');
    f4.Name =  'Normalised number local and remote awake replay on track';
    for j = 1 : length(sessions_ID)
        col_test = repmat([cols(j,:);cols(j,:);[0.6 0.6 0.6];[0.6 0.6 0.6]],4,1);
        subplot(length(sessions_ID),1,j)
        grp = [ones(4,1);ones(4,1)*2;ones(4,1)*3;ones(4,1)*4];
        tst2=[num_events_in_track(j,1:4)';num_events_in_track(j,5:8)';num_events_in_track(j,9:12)';num_events_in_track(j,13:16)'];
        beeswarm(grp,tst2,'sort_style','nosort','colormap',[cols(j,:);[0.6 0.6 0.6];cols(j,:);[0.6 0.6 0.6]],'dot_size',2,'overlay_style','ci',...
            'corral_style','rand','MarkerFaceColor',col_test);      
        title(['Session ' sessions_ID{j} 'x'  sessions_ID{j}])
        ylabel('# awake replay'); xticks([1,2,3,4]);xticklabels({'T1','T2','R-T1','R-T2'})
        set(gca,'FontSize',14)
    end



end



save_all_figures(pwd,[])




end