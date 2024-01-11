% Calculates rate of replay (events/min) for each track during sleep periods. To do so divides periods in 30min chunks. Plots rates for each
% 30min chunk and compares it between tracks.
% INPUT:
    % data_type: 'main' for using data from main HIPP replay project; 'speed' for using speed protocol data; and 'ctrl' for control data
    % epoch: 'sleep' or 'awake', for sleep or awake/rest replay, or 'merged' for both
    % bayesian_control: 'Only first exposure' or 'Only re-exposure'
% OUTPUT: T 'struct', where each row is a track (T(track)). Inside, each column is a time_period (e.g. PRE sleep), and each row a Protocol (e.g.
% 16x8). Within each Period x Protocol cell there is information for each session (i.e. rat) about num of replay events, rate replay, and information about time bins used to
% calculate it. Inside of each of these cells there are as many columns as time chunks are being analysed (e.g. first column is events during first
% 30 min, 2nd column events during next 30 min)
% E.g. T(1).P(1).PRE_merged.Rat_num_events = [26,27,11,8; [],23,5,0] --> Track 1, Protocol 16x8, during PRE sleep period analysing together (merged) awake
% and sleep events, how many detected events (num) per each of the 4 rats at each time bin.

% Marta Huelin, 2020

function plot_replay_rate_binned_time(epoch,bayesian_control)
path = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only first exposure'];
load([path '\extracted_replay_plotting_info_excl.mat'])


PP =  plotting_parameters;
periods = [{'PRE'},{'INTER_post'},{'FINAL_post'}];

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
num_tracks = 2;


%% Plot temporal pattern of normalized replay rate T1 vs T2
% experiments together (& T3 vs T4 for FINAL sleep)
%         Protocols color coded and rats shaped coded
%         It's T1-T2/T1+T2 - so how many more times there's more replay for one track than the other
path = ['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls'];
rate_replay_15 = load([path '\rate_per_sec_merged_replay_15min_excl.mat']);
rate_replay_30 = load([path '\rate_per_sec_merged_replay_30min_excl.mat']);

f3 = figure('units','normalized','outerposition',[0 0 1 1],'Color','w');

max_time_bin = [4,4,3];
for p = 1 : length(periods) %for each time period (sleep or run) within the protocol
    
    if p == 1 || p == 2 | ~isempty(bayesian_control)
        tracks = [1 2];
    elseif p == 3 & isempty(bayesian_control)
        tracks = [3 4];
    end
    
    if p == 1 | p == 3
        T = rate_replay_15.rate_replay;
        time_chunk_size = 900;
    elseif p == 2
        T = rate_replay_30.rate_replay;
        time_chunk_size = 1800;
    end
    
    ax(p) = subplot(1,length(periods),p);
    alpha = linspace(0.1,0.9,max_time_bin(p));
    
    for timebin = 1:max_time_bin(p)
        
        col = [PP.T2(1,:);PP.T2(2,:);PP.T2(3,:);PP.T2(4,:);PP.T2(5,:)];
        x_labels = {'16x8','16x4','16x3','16x2','16x1'}; %set labels for X axis
        track_rates_ratio{p}{timebin} = NaN(4,length(protocols));
        for i = 1 : length(protocols)
            track_rates_ratio{p}{timebin}(1:length([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,1}]),i) = ...
                ([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,timebin}] - [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,timebin}])./...
                ([T(tracks(1)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,timebin}] + [T(tracks(2)).P(i).(strcat(periods{p},'_',epoch)).Rat_replay_rate{:,timebin}]);
            scatter(i,nanmean(track_rates_ratio{p}{timebin}(:,i),1),100,'MarkerEdgeColor',col(i,:),'MarkerFaceColor',col(i,:),'MarkerFaceAlpha',alpha(timebin))
            hold on
        end
        
    end
    
    xticks([1 2 3 4 5])
    xticklabels(x_labels)
    ylabel(strcat('Normalized T',num2str(tracks(1)),'- T',num2str(tracks(2)),'Replay Rate (events/sec)'))
    title({['Normalised rate replay over time (' num2str(time_chunk_size/60) 'min bins): '];[periods{p} '-' epoch]})
    line([0 max(xlim)],[0 0],'LineStyle','--','Color','k')

end
linkaxes([ax(:)],'y')
ylim([-1 max(ylim)])
f3.Name = ['Normalised rate replay over time (' num2str(time_chunk_size/60) 'min bins): '];[periods{p} '-' epoch];


end