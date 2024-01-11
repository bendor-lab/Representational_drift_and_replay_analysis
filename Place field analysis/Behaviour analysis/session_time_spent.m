function session_time_spent

curr_folder = pwd;
cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis')
load('extracted_time_periods_replay.mat')
cd(curr_folder)

period_sort_order = [5,1,6,2,7,3,8,4,9]; %based on the order in the structure
names = fieldnames(period_time);

% Find mean and median times for each period across all sessions
period_allsession_times = [];
mean_times = [];
median_times = [];
std_times = [];
for i = 1 : length(names)
    this_period_times = [];
    if contains(cell2mat(names(i)),'length')
        this_period_times = extractfield(period_time,cell2mat(names(i)))./60;
        period_allsession_times = [period_allsession_times; this_period_times]; % save all time values
        mean_times = [mean_times, mean(this_period_times)];
        std_times = [std_times, std(this_period_times)]; 
        median_times = [median_times, median(this_period_times)];
        [p(ii),~,~] = anova1(this_period_times);
    end
end

% Sort by order of appearance within session
mean_times = mean_times(period_sort_order);
median_times = median_times(period_sort_order);
std_times = std_times(period_sort_order);
period_allsession_times = period_allsession_times(period_sort_order,:);

f1 = figure;
f1.Name = 'Mean time per period';
cols = summer(size(period_allsession_times,1));
for ii = 1 : size(period_allsession_times,1)
    hold on
    b(ii) = bar(ii, mean_times(ii),0.5,'facecolor',cols(ii,:), 'edgecolor',cols(ii,:),'facealpha',1,'edgealpha',1);
    e = errorbar(ii,mean_times(ii),std_times(ii),'.');
    e.Color = [0 0 0];
    plot(ii,period_allsession_times(ii,:),'o','MarkerEdgeColor','k','MarkerFaceColor',cols(ii,:))
end
xticklabels({'Pre','T1','rest1','T2','POST1','T3','rest2','POST2'})








end