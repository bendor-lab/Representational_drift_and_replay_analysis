function stats_replay_bias = diff_cumulative_replay_stats(epoch)
% epoch = 'sleep' or 'rest'


%path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
%path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Controls\All_controls';
path ='X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Spearman';
load([path '\' epoch '_diff_cum_replay.mat'])
PP = plotting_parameters;

% indices of comparisons to analyse
idx = [1,2]; % for T1 vs T2 and R-T1 vs R-T2
figure

for comp =  1 : length(idx)
    if idx(comp) == 1 % T1 vs T2
        for p = 1 : length(T(idx(comp)).protocol_num) %for each protocol
            events_vector = T(idx(comp)).event_count{1,p}.INTER_post_total_events;   
            random_walks = random_walk_simulation(events_vector,T(idx(comp)).event_count{1,p}.INTER_post_cumsum_ALLRATS,T(idx(comp)).active_bins{1,p}.INTER_post,10000);
            
            stats_replay_bias(comp,p).protocol = T(idx(comp)).protocol_num{1,p};
            stats_replay_bias(comp,p).comparison = [1,2];
            stats_replay_bias(comp,p).random_walks = random_walks;
            stats_replay_bias(comp,p).num_events = T(idx(comp)).event_count{1,p}.INTER_post_mean_total_events_ALLRATS;
            
            ax1 = subplot(2,3,1);
            hold on
            stats_replay_bias(comp,p).random_walks.pval(stats_replay_bias(comp,p).random_walks.pval ==0) = .0001;
            plot(log10(stats_replay_bias(comp,p).random_walks.pval),'Color',PP.T2(p,:),'LineWidth',2)
            %plot(stats_replay_bias(comp,p).random_walks.pval,'Color',PP.T2(p,:),'LineWidth',2)
            ax2 = subplot(2,3,2);
            hold on
            plot(log10(stats_replay_bias(comp,p).random_walks.pval(1:20)),'Color',PP.T2(p,:),'LineWidth',2)
            %plot(stats_replay_bias(comp,p).random_walks.pval(1:20),'Color',PP.T2(p,:),'LineWidth',2)
            subplot(2,3,3)
            hold on
            plot(stats_replay_bias(comp,p).num_events,'Color',PP.T2(p,:),'LineWidth',2)
            box off
            
            clear events_vector
        end
    elseif  idx(comp) == 2 % R-T1 vs R-T2
        
        for p = 1 : length(T(idx(comp)).protocol_num) %for each protocol
            events_vector = T(idx(comp)).event_count{1,p}.FINAL_post_total_events;   
            random_walks = random_walk_simulation(events_vector,T(idx(comp)).event_count{1,p}.FINAL_post_cumsum_ALLRATS,T(idx(comp)).active_bins{1,p}.FINAL_post,10000);
            
            stats_replay_bias(comp,p).protocol = T(idx(comp)).protocol_num{1,p};
            stats_replay_bias(comp,p).comparison = [3,4];
            stats_replay_bias(comp,p).random_walks = random_walks;
            stats_replay_bias(comp,p).num_events = T(idx(comp)).event_count{1,p}.FINAL_post_mean_total_events_ALLRATS;
            
            ax3 = subplot(2,3,4);
            hold on
            %plot(log10(stats_replay_bias(comp,p).random_walks.pval),'Color',PP.T2(p,:),'LineWidth',2)
            stats_replay_bias(comp,p).random_walks.pval(stats_replay_bias(comp,p).random_walks.pval ==0) = .0001;
            plot(stats_replay_bias(comp,p).random_walks.pval,'Color',PP.T2(p,:),'LineWidth',2)
            ax4 = subplot(2,3,5);
            hold on
            %plot(log10(stats_replay_bias(comp,p).random_walks.pval(1:6)),'Color',PP.T2(p,:),'LineWidth',2)
            plot(stats_replay_bias(comp,p).random_walks.pval(1:6),'Color',PP.T2(p,:),'LineWidth',2)
            subplot(2,3,6)
            hold on
            plot(stats_replay_bias(comp,p).num_events,'Color',PP.T2(p,:),'LineWidth',2)
            box off
            clear events_vector
        end
    end
end


plot(ax1,[min(xlim(ax1)) max(xlim(ax1))],[0.05 0.05],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2)
plot(ax2,[min(xlim(ax2)) max(xlim(ax2))],[0.05 0.05],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2)
plot(ax3,[min(xlim(ax3)) max(xlim(ax3))],[0.05 0.05],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2)
plot(ax4,[min(xlim(ax4)) max(xlim(ax4))],[0.05 0.05],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2)

plot(ax1,[min(xlim(ax1)) max(xlim(ax1))],[0.01 0.01],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2)
plot(ax2,[min(xlim(ax2)) max(xlim(ax2))],[0.01 0.01],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2)
plot(ax3,[min(xlim(ax3)) max(xlim(ax3))],[0.01 0.01],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2)
plot(ax4,[min(xlim(ax4)) max(xlim(ax4))],[0.01 0.01],'Color',[0.6 0.6 0.6],'LineStyle',':','LineWidth',2)

save([path '\' epoch '_stats_replay_bias.mat'],'stats_replay_bias','-v7.3')

end


function rand_walks = random_walk_simulation(events_vector,real_data,active_bins,num_repetitions) 
%events vector is a 4xn struct, a row for each rat - each row is a vector with the number of replay events in each time
%active bins is the the number of rats contributing to each time bin
%real data is the mean bias across all rats (original plot)

for i = 1 : length(real_data) % for each time bin
    for j = 1 : num_repetitions
        out1(i,j) = coin_flip(events_vector(1,i)); % each rat is an outX
        out2(i,j) = coin_flip(events_vector(2,i));
        out3(i,j) = coin_flip(events_vector(3,i));
        out4(i,j) = coin_flip(events_vector(4,i));
    end
    rand_walks.mean(i,:) = (out1(i,:)+out2(i,:)+out3(i,:)+out4(i,:))/active_bins(i);
       %rand_walks.mean(i,:) = (out1(i,:)+out2(i,:)+out3(i,:))/active_bins(i);

    %rand_walks.pval(1,i) = length(find(rand_walks.mean(i,:)>= abs(real_data(i))))/length(rand_walks.mean(i,:));
    % just trying other things
    %[rand_walks.percentile1(1,i), rand_walks.percentile2(1,i)] = comp_percentile(rand_walks.mean(i,:),abs(real_data(i)));
end
%  Cumulative sum across time bins for each simulation
rand_walks.cum_sum = cumsum(rand_walks.mean,1);  %a cumulative sum generates a random walk from coin flips (heads=track1, tails=track2)

for i=1:length(real_data)
    rand_walks.pval(1,i) = length(find(rand_walks.cum_sum(i,:)>= abs(real_data(i))))/length(rand_walks.cum_sum(i,:));
end


% rand_walks.mean = mean(rand_walks.cumsum,2);
% rand_walks.var = [var(rand_walks.cumsum,1,2) -var(rand_walks.cumsum,1,2)];
%rand_walks.diff_cumsum = rand_walks.cumsum - real_data';
%rand_walks.diff_mean = mean(rand_walks.diff_cumsum,2);
%rand_walks.diff_var = [var(rand_walks.diff_cumsum,1,2) -var(rand_walks.diff_cumsum,1,2)];

end



%could find the pvalue by determining where the true value lies within or
%outside the distribution (like what we do for shuffles), but keep in mind
%its a two tailed distribution.


function out = coin_flip(n)

out = random('Binomial',n,0.5); %n is number of total events in the time bin, 0.5 is equal weighting between heads and tails
out = (out-(n-out));  %heads minus tails (T1 minus T2)

end

function [x, percentrank] = comp_percentile(dist,value)
    perc = prctile(dist,0:100);
    [~, index] = min(abs(perc'-value));
    x = index+1;
    percentrank =  reshape( mean( bsxfun(@le, dist(:), value(:).') ) * 100, size(value) );
end
