function extract_replay_rate(epoch)
% Looks at the exponentials curves representing the cumulative sum of events and finds the coefficients of the equation (A and B)

% Parameters
load('extracted_replay_plotting_info.mat')
load('extracted_time_periods_replay.mat')

PP =  plotting_parameters;
bin_width = 60; %1 min

% Set periods to be analysed
if isfield(track_replay_events,'T3')
    periods = [{'PRE'},{'sleep_pot1'},{'INTER_post'},{'sleep_pot2'},{'FINAL_post'}];
else  % 2 tracks only
    periods = [{'PRE'},{'sleep_pot1'},{'FINAL_post'}];
end

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

for track = 1 : num_tracks
    
    % For each protocol (8,4,3,2 or 1)
    for i = 1 : length(protocols)
        
        this_protocol_idx = find(t2 == protocols(i)); %find indices of sessions from the current protocol
        
        for p = 1 : length(periods) %for each time period (sleep or run) within the protocol
                N1 = [];
                N= [];
                % find the longest period between these protocol sessions
                mt = [];
                for ii = 1 : length (this_protocol_idx)
                    if ~isempty(period_time(this_protocol_idx(ii)).(strcat(periods{p})).(strcat(epoch,'_cumulative_time')))
                        mt = [mt; max(max(period_time(this_protocol_idx(ii)).(strcat(periods{p})).(strcat(epoch,'_cumulative_time'))))];
                    end
                end
                longest_period_time = max(mt);
                if longest_period_time > 0 && longest_period_time < bin_width %if this period only has 1 bin, that is smaller than 60 sec
                    bin_edges = 0:longest_period_time:longest_period_time;
                    disp(strcat('Time bin for :', periods{p},' is smaller than 1 min'))
                else
                    bin_edges = 0:bin_width:longest_period_time; %bin the time based on the longest period
                end
                
                % For these protocol sessions, find number of events for each time bin (for this period)
                for ii = 1 : length (this_protocol_idx)
                    [N1(ii,:),~] = histcounts([track_replay_events(this_protocol_idx(ii)).(sprintf('%s','T',num2str(track))).(strcat(periods{p},'_',epoch,'_cumulative_times'))],bin_edges); %events track 1
                end
                if size(N1,1) > 1
                    N = sum(N1,1);
                end

                % Normalize event count based on the length of longest time period,by looking how many sessions contribute to each time bin
                bins_with_active_period = ones(1,length(bin_edges))*length(this_protocol_idx); % Set the count as if all periods had the same length
                for t = 1 : length(this_protocol_idx)
                    if max(max(period_time(this_protocol_idx(t)).(strcat(periods{p})).(strcat(epoch,'_cumulative_time')))) < longest_period_time % if this sessions is shorter than the longest period
                        [~,idx] = min(abs(bin_edges - max(max(period_time(this_protocol_idx(t)).(strcat(periods{p})).(strcat(epoch,'_cumulative_time')))))); %find bin indx where session is not active anymore
                        bins_with_active_period(idx+1:end) = bins_with_active_period(idx+1:end) - 1;
                    end
                end
                
                % Sum events of all sessions of this protocol & divide events of each bin by number of active periods in that bin
                event_count(i).(strcat(periods{p},'_cumsum')) = cumsum(N./bins_with_active_period(1:end-1));
                time_bin_edges(i).(strcat(periods{p})) = bin_edges;  %time bin edges per period
                active_bins(i).(strcat(periods{p})) = bins_with_active_period; %number of sessions with info for each time bin
                
               
          % Three ways to calculate linear fit depending on which data is being used:
             %%%%%% Create a scatter plot with each rat exponential curve plotted individually and find the best fit within the scatter plot   
                %x = [bin_edges(1:end-1) bin_edges(1:end-1) bin_edges(1:end-1) bin_edges(1:end-1)];
                %y= [];
                %for ii = 1 : 4
                    %y = [y cumsum(N1(ii,:))];
                %end
                %[A(1,cc),B(1,cc),rsq(1,cc)] = fitting_data(x,y,1);

             %%%%%% All the rats summed together, but only taking data points that are contributing at >= 50 % of the rats
                %half_rats_thresh = find(cumsum(abs(diff(active_bins(i).(strcat(periods{p}))))) >= floor(max(active_bins(i).(strcat(periods{p})))-1),1);  % Find at which time bin starts being information only for half of the rats
                half_rats_thresh = find(cumsum(abs(diff(active_bins(i).(strcat(periods{p}))))) >= floor(max(active_bins(i).(strcat(periods{p})))/2),1);  % Find at which time bin starts being information only for half of the rats
                if ~isempty(half_rats_thresh)
                    new_t = bin_edges(1:half_rats_thresh);
                    new_cum = event_count(i).(strcat(periods{p},'_cumsum'))(1:half_rats_thresh);
                else
                    new_t = bin_edges(1:end-1);
                    new_cum = event_count(i).(strcat(periods{p},'_cumsum'));
                end
                [A(i).(strcat(periods{p})),B(i).(strcat(periods{p})),rsq(i).(strcat(periods{p}))] = fitting_data(new_t,new_cum,0);
            
             %%%%%% All the rats summed together and taking all data points regardless of how many rats are contributing
                %[A(3,cc),B(3,cc),rsq(3,cc)] = fitting_data(bin_edges(1:end-1), event_count(i).(strcat(periods{p},'_cumsum')),1);
        end
        
        % Save for later plotting
        T(track).event_count{i} = event_count(i);
        T(track).protocol_num{i} = protocols(i);
        T(track).time_bin_edges{i} = time_bin_edges(i); 
        T(track).active_bins{i} = active_bins(i);
        T(track).exponential_coefficient_A{i} =  A(i);
        T(track).exponential_coefficient_B{i} =  B(i);
        
    end
    
    figure  
    
    for jj = 1 : length(periods)
        for ii = 1 : length(T(track).exponential_coefficient_A) % for each protocol
            hold on
            plot(jj,T(track).exponential_coefficient_A{1,ii}.(strcat(periods{jj})),'o','MarkerEdgeColor',PP.T2(ii,:),'MarkerFaceColor',PP.T2(ii,:),'MarkerSize',6)
        end
    end
    title(strcat('A - track',num2str(track),'-',epoch))
                
     figure       
     
     for jj = 1 : length(periods)
         for ii = 1 : length(T(track).exponential_coefficient_A) % for each protocol
             hold on
             plot(jj,T(track).exponential_coefficient_B{1,ii}.(strcat(periods{jj})),'o','MarkerEdgeColor',PP.T2(ii,:),'MarkerFaceColor',PP.T2(ii,:),'MarkerSize',6)
         end
     end
     title(strcat('B - track',num2str(track),'-',epoch))

    
    
    
    
    
end
end

function [A,B,rsq] = fitting_data(t,cum_replay,plot_option)
% DB/MH_2020

% Convert data to linear equation with log and calculate linear fit

X = 1 + max(cum_replay) - cum_replay;   %this equals A*exp(-B*t).
% Added "1+" in the beginning so that the value is never zero.
% Essentially this is saying that after one more replay event, you would read saturation.

p = polyfit(t,log(X),1); % polyfit returns the coefficient (a & b) for the line that is a best fit - y = ax + b
a = exp(p(2)); % slope in linear equation = A in exponential equation
b = -p(1); % y intercept in linear equation =  B in exponential equation

% Calculate least square (R^2) to assess degree of error
yfit = polyval(p,t);
yresid = log(X) - yfit; % compute residual values
SSresid = sum(yresid.^2); %square the residuals and total them to obtain the residual sum of squares
SStotal = (length(log(X))-1)*var(log(X)); % compute the total sum of squares of y by multiplying the variance of y by the number of observations minus 1
rsq = 1 - SSresid/SStotal; % Compute simple R^2 - tells which % of the variance in the variable y is explained by A and B


% Fit a & b in MATLAB method
exp_equation = 'a*(1-exp(-b*x))';
f1 = fit(t',cum_replay',exp_equation,'StartPoint', [a b]); % fit works better with an estimate of a and b, that's why we first calculate them with polyfit
A = f1.a; % tells how high it gets
B = f1.b; % tells how fast the exponential raises

if A > 150 
    A = a;
    B= b;
end
    
if plot_option == 1
    figure
    subplot(4,1,1)
    plot(t,cum_replay,'.'); %plot raw data
    title('raw data')
    
    subplot(4,1,2)
    plot(t,log(X),'o');  % turn data to linear by applying natural log
    hold on
    plot(t, polyval(p,t),'r'); % plots best fit to see if it matches
    title('convert to linear, with linear fit')
    
    subplot(4,1,3)
    plot(t,cum_replay,'o')
    hold on
    plot(t,a-a*exp(-b*t),'r')
    title('convert from linear fit to exponential fit, with original data')
    
    %MATLAB method
    subplot(4,1,4)
    plot(t,cum_replay,'o')
    hold on
    plot(t,A-A*exp(-B*t),'r')
    title('MATLAB version')
end
end