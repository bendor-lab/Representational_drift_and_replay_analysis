multievents = 0;
if multievents == 1
    load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\extracted_awake_replay_track_MultiEvents.mat')
else
     load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\extracted_awake_replay_track.mat')
end
%load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Lap theta sequences\lap_thetaseq.mat')
load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\thetaseq_scores_individual_laps.mat')
load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\session_thetaseq_scores.mat')
load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\behavioural_data.mat')

% ALLOCATION 
for ses = 1 : length(lap_WeightedCorr)    
    for t = 1 : length(lap_WeightedCorr(1).track)       
        track_info(t).thetaseq_WC_scores(ses,:) = nan(1,52);
        track_info(t).thetaseq_QR_scores(ses,:) = nan(1,52);
        track_info(t).num_thetaseq(ses,:) = nan(1,52);
        track_info(t).norm_num_thetaseq(ses,:) = nan(1,52);
    end
end

protocols = [8,4,3,2,1];
c = 1;
for p = 1 : length(protocols) %for each protocol
    for r = 1 : size(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate,1) %for each rat
        for t = 1 : length(lap_WeightedCorr(1).track) %for each track
            track_info(t).lap_num_replay(c,:) = nan(1,52);
            track_info(t).lap_replay_rates(c,:) = nan(1,52);
            track_info(t).norm_lap_num_replay(c,:) = nan(1,52);
        end
        c = c +1;
    end
end

% EXTRACT THETA INFO

for ses = 1 : length(lap_WeightedCorr)
    for t = 1 : length(lap_WeightedCorr(1).track) %for each track       
        track_info(t).thetaseq_WC_scores(ses,1:length(lap_WeightedCorr(ses).track(t).score)) = lap_WeightedCorr(ses).track(t).score;
        track_info(t).thetaseq_QR_scores(ses,1:length(lap_QuadrantRatio(ses).track(t).score)) = lap_QuadrantRatio(ses).track(t).score;
        track_info(t).num_thetaseq(ses,1:length(lap_WeightedCorr(ses).track(t).score)) = lap_WeightedCorr(ses).track(t).num_thetaseq;
        track_info(t).norm_num_thetaseq(ses,1:length(lap_WeightedCorr(ses).track(t).score)) = lap_WeightedCorr(ses).track(t).num_thetaseq./...
            quantification_scores(1).num_thetaseq(t,ses);
    end
end

% EXTRACT REPLAY INFO
protocols = [8,4,3,2,1];
c = 1;
for p = 1 : length(protocols) %for each protocol
    for r = 1 : size(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate,1) %for each rat
        for t = 1 : length(lap_WeightedCorr(1).track) %for each track
            track_info(t).lap_num_replay(c,1:length(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_num_events(r,:))) = protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_num_events(r,:);
            track_info(t).lap_replay_rates(c,1:length(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(r,:))) = protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_replay_rate(r,:);
            track_info(t).norm_lap_num_replay(c,1:length(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_num_events(r,:))) = protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_num_events(r,:)./...
                sum(protocol(p).(sprintf('%s','T',num2str(t)))(t).Rat_num_events(r,:));
        end
        c = c +1;
    end
end

mean_num_theta_seq = mean(track_info(t).num_thetaseq,1);
mean_num_replay = mean(track_info(t).norm_lap_num_replay,1);

dd = lap_behaviour(1).time_immobile(:,1:14)';
dd = dd(:)';
time_im = cell2mat(dd);
ee = lap_behaviour(1).time_moving(:,1:14)';
ee = ee(:)';
time_m = cell2mat(ee);

sp = lap_behaviour(1).moving_speed(:,1:14)';
sp = sp(:)';
lap_speed = cell2mat(sp);

t1_thetaseq = track_info(1).num_thetaseq(:,1:14)';
t1_thetaseq = t1_thetaseq(:)';
t1_awake_replay = track_info(1).lap_num_replay(:,1:14)';
t1_awake_replay = t1_awake_replay(:)';

norm_t1_awake_replay = t1_awake_replay./time_im;
norm_t1_theta_seq = t1_thetaseq./time_m;

[rh,pv]=corr(t1_awake_replay',t1_thetaseq');
cols = parula(14);
figure;    
count = 0;
for ii = 1 : 20
    for lap =  1 : 14
        hold on
        scatter(t1_awake_replay(count+lap),t1_thetaseq(count+lap),30,cols(lap,:),'filled')
    end
    count = count +14;
end
title(['R:' num2str(rh) '- PV:' num2str(pv)])
xlabel('T1 num awake replay per lap')
ylabel('T1 num theta seq per lap')
%text(max(xlim),max(ylim),[num2str(rh) '-' num2str(pv)])


[rho2,pval2] = partialcorr([t1_thetaseq' ,norm_t1_awake_replay'],[time_m',lap_speed'] );
[rho,pval] = partialcorr([t1_thetaseq' ,t1_awake_replay'],[time_m',lap_speed',time_im'] );

cols = parula(14);
figure;
for lap =  1 : 14
    hold on
    scatter(cell2mat(lap_behaviour(1).time_immobile(:,lap)), track_info(1).lap_num_replay(:,lap),30,cols(lap,:),'filled')
end
[rh,pv] = corr(time_im',t1_awake_replay');
title(['R:' num2str(rh) '- PV:' num2str(pv)])
xlabel('Immobile time in lap')
ylabel('T1 num awake replay per lap')
hold on
scatter(time_im(t1_awake_replay==0),t1_awake_replay(t1_awake_replay==0),'r')


next_t1_awake_replay =  track_info(1).lap_num_replay(:,1:13);
next_t1_thetaseq = track_info(1).num_thetaseq(:,2:14);
t1_thetaseq = next_t1_thetaseq(:)';
t1_awake_replay = next_t1_awake_replay(:)';
[rh,pv]=corr(t1_awake_replay',t1_thetaseq');
cols = parula(13);
figure;    
count = 0;
for ii = 1 : 20
    for lap =  1 : 13
        hold on
        scatter(t1_awake_replay(count+lap),t1_thetaseq(count+lap),30,cols(lap,:),'filled')
    end
    count = count +13;
end
title(['R:' num2str(rh) '- PV:' num2str(pv)])
xlabel('T1 num awake replay per lap')
ylabel('T1 num theta seq NEXT lap')


binned_speed = histcounts(lap_speed,floor(min(lap_speed)):2:ceil(max(lap_speed)));
proportion_binned_speed = bsxfun(@rdivide,binned_speed,length(lap_speed));
figure; bar(proportion_binned_speed); xticks([1:1:length(proportion_binned_speed)]); xticklabels({'10-11','12-13','14-15','16-17',...
    '18-19','20-21','22-23','24-25'});
binned_speed_replay = histcounts(lap_speed(t1_awake_replay==0),floor(min(lap_speed)):2:ceil(max(lap_speed)));
proportion_binned_speed_replay = bsxfun(@rdivide,binned_speed_replay,length(lap_speed));
figure; bar(proportion_binned_speed_replay); xticks([1:1:length(proportion_binned_speed_replay)]); xticklabels({'10-11','12-13','14-15','16-17',...
    '18-19','20-21','22-23','24-25'});
figure; histogram(lap_speed,floor(min(lap_speed)):2:ceil(max(lap_speed)))
hold on; histogram(lap_speed(t1_awake_replay==0),floor(min(lap_speed)):2:ceil(max(lap_speed)));
histogram(binned_speed.\binned_speed_replay,[min(lap_speed):2:max(lap_speed)])

binned_awake_replay = histcounts(t1_awake_replay,floor(min(time_im)):0.2:ceil(max(time_im)));
figure;histogram(t1_awake_replay,floor(min(time_im)):0.2:ceil(max(time_im)))


figure
for ii = 1 : 20
    data = track_info(1).num_thetaseq(ii,~isnan(track_info(1).num_thetaseq(ii,:)));
    time = cell2mat(lap_behaviour(1).time_moving(ii,:));
    hold on
    plot(cumsum(data./time))

end


for t= 1: 4
t1_thetaseq = track_info(1).num_thetaseq(:,1:14)';
t1_thetaseq = t1_thetaseq(:)';
t1_awake_replay = track_info(1).lap_replay_rates(:,1:14)';
t1_awake_replay = t1_awake_replay(:)';
c = track_info(2).num_thetaseq';
c = c(:)';
d = track_info(2).lap_replay_rates';
d = d(:)';
a =[a c];
b = [b d];

nan_idx = isnan(a);
a(nan_idx) = [];
b(nan_idx) = [];
nan_idx = isnan(b);
a(nan_idx) = [];
b(nan_idx) = [];
[rh,pv]=corr(a',b')
figure;scatter(a,b)
text(max(xlim),max(ylim),[num2str(rh) '-' num2str(pv)])
[rh,pv]=corr(a(b>0.015)',b(b>0.015)')
figure;scatter(a(b>0.015),b(b>0.015))
text(max(xlim),max(ylim),[num2str(rh) '-' num2str(pv)])

end


for s = 1 : length(lap_thetaseq)
    if lap_thetaseq(s).dir == 3
        for f = 1 : length(fields)
            if ~isempty(lap_thetaseq(s).(sprintf('%s',fields{f})))
                lap_num_seq(f) = length(lap_thetaseq(s).(sprintf('%s',fields{f})).theta_sequences);
                lap_QR_score(f) = lap_thetaseq(s).(sprintf('%s',fields{f})).quadrant_ratio;
                lap_WC_score(f) = lap_thetaseq(s).(sprintf('%s',fields{f})).weighted_corr;
                all_lap_num_seq =[all_lap_num_seq lap_num_seq(f)];
                all_lap_QR_score =[all_lap_QR_score lap_QR_score(f)];
                all_lap_WC_score =[all_lap_WC_score lap_WC_score(f)];
            end
        end
        
        [QR_R,QR_pval] = corr(lap_num_seq',lap_QR_score');
        [WC_R,WC_pval] = corr(lap_num_seq',lap_WC_score');
        
        if WC_pval < 0.05 | QR_pval < 0.05
            count = count + 1;
            idces = [idces s];
        end
        clear lap_QR_score lap_num_seq lap_WC_score
    end
end

figure; plot(all_lap_num_seq,all_lap_QR_score,'o')
figure; plot(all_lap_num_seq,all_lap_WC_score,'o')

