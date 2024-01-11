%MEASURE QUALITY OF AWAKE REPLAY IN TRACK: SCORES, PVALUE, DURATION, NUMBER
%OF CANDIDATE REPLAY EVENTS REJECTED PER LAP

function measure_quality_awake_replay(data_folder,multievents,lap_option)


%%%%% Look at scores and pvalue

% Parameters
cd(['X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Controls\' data_folder])
if multievents == 1
    load(['extracted_awake_replay_track_',lap_option,'lap_MultiEvents.mat'])
else
    load(['extracted_awake_replay_track_',lap_option,'lap.mat'])
end
load('extracted_time_periods_replay.mat')
PP =  plotting_parameters;

if isfield(protocol,'T4')
    num_tracks = 4;
else
    num_tracks = 2;
end

%%%% WEIGHTED CORR SCORE
figure
for p = 1 : size(protocol,2) %for each protocol
    
    for t = 1 : num_tracks %for each track
    
        % Get the rat mean lap score, and average across rats
        active_laps = num_tracks - sum(isnan([protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_mean_replay_score]),1); % Find nans from laps without events
        mean_rat_scores = [protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_mean_replay_score];
        mean_rat_scores(isnan(mean_rat_scores)) = 0; % replace nans with zeros
        mean_lap_scores = sum(mean_rat_scores,1)./active_laps;
        
        subplot(2,2,t)
        hold on
        if t == 2
            plot(mean_lap_scores,'Color',PP.T2(p,:),'LineWidth',2)
        else
            plot(mean_lap_scores(1:16),'Color',PP.T2(p,:),'LineWidth',2)
        end
    end
end



%%%%%%%% P-VAL

exp1 = nan(20,5);
exp3= nan(20,5);
exp4 = nan(20,5);
exp2 = nan(20,5);
c = 1;
c1 =1;
c2 =1;
c3=1;
for p = 1 : size(protocol,2) %for each protocol
    
    for t = 1 : num_tracks %for each track
        
        % Get the rat mean lap pvalue, and average across rats
        active_laps = num_tracks - sum(isnan([protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_mean_replay_pvalue]),1); % Find nans from laps without events
        mean_rat_pval = [protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_mean_replay_pvalue];
        mean_rat_pval(isnan(mean_rat_pval)) = 0; % replace nans with zeros
        mean_lap_pval = sum(mean_rat_pval,1)./active_laps;
        if t ==1
            exp1(1:length(mean_lap_pval),c) = mean_lap_pval';
            c = c+1;
        elseif t == 2
            exp2(1:length(mean_lap_pval),c3) = mean_lap_pval';
            c3 = c3+1;
        elseif t == 4
            exp4(1:16,c1) = mean_lap_pval(1:16)';
            c1 = c1+1;
        else
            exp3(1:16,c2) = mean_lap_pval(1:16)';
            c2 = c2+1;
        end
    end
    
end
t1 = mean(exp1,2,'omitnan');
t2 = mean(exp2,2,'omitnan');
[p,h,s] = ranksum(t1,t2);

[p,~,stats] = kruskalwallis(exp4);
t4 = mean(exp4,2,'omitnan');
t3 = mean(exp3,2,'omitnan');
[p,h,s] = ranksum(t3,t4);
allexp2 = mean([t4 t3],2,'omitnan');
allexp1 = mean([t1 t2],2,'omitnan');

 figure
        subplot(2,2,t)
        hold on
        if t == 2
            plot(mean_lap_pval,'Color',PP.T2(p,:),'LineWidth',2)
        else
            plot(mean_lap_pval(1:16),'Color',PP.T2(p,:),'LineWidth',2)
        end

[p,h,s] = ranksum(allexp1,allexp2);











end