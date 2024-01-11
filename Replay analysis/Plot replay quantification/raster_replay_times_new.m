function raster_replay_times_new(state)
% Plot replay times as raster plot for all sessions
% Loads 'extracted_replay_plotting_info.mat'
% INPUT:
% track: being 1 - for 16 runs,2 - for short exposures,3 - for re-exposure to track 1, or 4 - for re-exposure to track2
% state: 'sleep' for plotting only SLEEP replay (thus only plots sleep periods, as assumes there's no sleep replay during run)
% 'awake' for plotting only AWAKE replay
% 'ALL' for plotting raster with both sleep and awake replays

% cd 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis'
% New version is based on Bayesian controlled replay decoding (normalised acorss two track pairs)
% Only first exposure place field for POST1 replay and Only re-exposure place field for POST2 replay

load('extracted_replay_plotting_info.mat')
load('extracted_time_periods_replay.mat')

%Set number of tracks
num_tracks = 2;

T1_T2_events = [];
T1_T2_IDs = [];
T1_T2_indices = [];

cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\Bayesian Controls\Only re-exposure')

for track = 1 : num_tracks
    % Find the maximum length of time for each sleep period across all sessions analysed and adds the time already run (from previous sleep periods)
    if strcmp(state,'sleep')
        
        periods = [{'PRE'},{'sleep_pot1'},{'INTER_post'},{'sleep_pot2'},{'FINAL_post'}];
        % Find max length for each sleep period
        for p = 1 : length(periods)
            times = [];
            for ii = 1 : length(period_time)
                times = [times; period_time(ii).(strcat(periods{p})).length];
            end
            if p == 1
                SleepPeriod_time_end(p) = max(times); % end of this sleep period
            else
                SleepPeriod_time_end(p) = max(times) + SleepPeriod_time_end(p-1); % end of this sleep period + the length of the previous sleep periods
            end
        end
        
        % For plotting purposes, add to each sleep period the time already past (previous sleep period lengths)
        for j = 1 : length(track_replay_events)
            raster_session(j).norm_sig_event_times = track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).norm_sleep_event_times;
            for i = 3 : length(track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).sleep_period_start_indices) %skip PRE-sleep since it's the first period and no need to modify
                start_idx = track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).sleep_period_start_indices(i-1);
                end_idx = track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).sleep_period_start_indices(i)-1;
                
                if end_idx < start_idx &&  i ~= length(track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).sleep_period_start_indices) %if there's not sleep in this period, and it's not the last one
                    continue %if start idx is bigger than end indx means that there's no sleep for that period, thus skip
                    
                elseif end_idx < start_idx && i == length(track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).sleep_period_start_indices) %if the sleep_pot2 doesn't have sleep,, and it's also the final index (FINAL_post sleep), just add time in the FINAL period
                    raster_session(j).norm_sig_event_times(end_idx+1:end) = raster_session(j).norm_sig_event_times(end_idx+1:end) + SleepPeriod_time_end(i-1);
                    
                elseif  i == length(track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).sleep_period_start_indices) %if sleep_pot2 has sleep, and it's also the final index (FINAL_post sleep)
                    raster_session(j).norm_sig_event_times(start_idx:end_idx) = raster_session(j).norm_sig_event_times(start_idx:end_idx) + SleepPeriod_time_end(i-2);
                    raster_session(j).norm_sig_event_times(end_idx+1:end) = raster_session(j).norm_sig_event_times(end_idx+1:end) + SleepPeriod_time_end(i-1);
                    
                elseif end_idx >= start_idx % if it's a period between PRE and FINAL with sleep
                    raster_session(j).norm_sig_event_times(start_idx:end_idx) = raster_session(j).norm_sig_event_times(start_idx:end_idx) + SleepPeriod_time_end(i-2);
                end
            end
        end
        % Concat IDs
        all_ids = [];
        all_vals = [];
        for j = 1 : length(track_replay_events)
            all_ids = [all_ids track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).sleep_session_id];
            all_vals = [all_vals track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).score_sig_events_sleep];
        end
        
        
    elseif strcmp(state,'awake') || strcmp(state,'ALL')
        
        periods = [{'PRE'},{'T1'},{'sleep_pot1'},{'T2'},{'INTER_post'},{'T3'},{'sleep_pot2'},{'T4'},{'FINAL_post'}];
        % Find max length for each sleep period
        for p = 1 : length(periods)
            times = [];
            for ii = 1 : length(period_time)
                times = [times; period_time(ii).(strcat(periods{p})).length];
            end
            if p == 1
                ALLPeriods_time_end(p) = max(times); % end of this period
            else
                ALLPeriods_time_end(p) = max(times) + ALLPeriods_time_end(p-1); % end of this period + the length of the previous periods
            end
        end
        
        % For plotting purposes, add to each period the time already past (previous period lengths)
        for j = 1 : length(track_replay_events)
            raster_session(j).all_norm_sig_event_times = track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).(strcat('norm_',state,'_event_times'));
            start_indices = track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).(strcat(state,'_period_start_indices'));
            for i = 3 : length(start_indices) %skip PRE-sleep since it's the first period and no need to modify
                start_idx = start_indices(i-1);
                end_idx = start_indices(i)-1;
                
                if end_idx < start_idx &&  i ~= length(start_indices) %if there's not sleep in this period, and it's not the last one
                    continue %if start idx is bigger than end indx means that there's no sleep for that period, thus skip
                    
                elseif end_idx < start_idx && i == length(start_indices) %if the sleep_pot2 doesn't have sleep, and it's also the final index (FINAL_post sleep), just add time in the FINAL period
                    raster_session(j).all_norm_sig_event_times(end_idx+1:end) = raster_session(j).all_norm_sig_event_times(end_idx+1:end) + ALLPeriods_time_end(i-1);
                    
                elseif  i == length(start_indices) %if sleep_pot2 has sleep, and it's also the final index (FINAL_post sleep)
                    raster_session(j).all_norm_sig_event_times(start_idx:end_idx) = raster_session(j).all_norm_sig_event_times(start_idx:end_idx) + ALLPeriods_time_end(i-2);
                    raster_session(j).all_norm_sig_event_times(end_idx+1:end) = raster_session(j).all_norm_sig_event_times(end_idx+1:end) + ALLPeriods_time_end(i-1);
                    
                elseif end_idx >= start_idx % if it's a period between PRE and FINAL with sleep
                    raster_session(j).all_norm_sig_event_times(start_idx:end_idx) = raster_session(j).all_norm_sig_event_times(start_idx:end_idx) + ALLPeriods_time_end(i-2);
                end
            end
        end
        % Concat IDs
        all_ids = [];
        all_vals = [];
        for j = 1 : length(track_replay_events)
            all_ids = [all_ids track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).(strcat(state,'_session_id'))];
            if strcmp(state,'awake')
                all_vals = [all_vals track_replay_events(j).(sprintf('%s','T',num2str(track),'_concat')).score_sig_events_awake];
            else
                all_vals = [all_vals track_replay_events(j).(sprintf('%s','T',num2str(track))).score_all_sig_events];
            end
        end
        
    end
end


for track = 1 : num_tracks
    if track == 1
        if strcmp(state,'sleep')
            T1_events = raster_session;
            T1_IDs(:) = all_ids;
        else
            T1_events = raster_session;
            T1_IDs(:) = all_ids;
        end
    elseif track == 2
        if strcmp(state,'sleep')
            for jj = 1 : length(raster_session)
                indx = [];
                [T1_T2_events(jj).norm_sig_events,indx] = sort([T1_events(jj).norm_sig_event_times raster_session(jj).norm_sig_event_times]);
                T1_idx = T1_IDs == jj;
                T2_idx = all_ids == jj;
                combined = [T1_IDs(T1_idx) all_ids(T2_idx)*100];
                T1_T2_indices = [T1_T2_indices, combined(indx)];
            end
            T1_T2_IDs = sort([T1_IDs all_ids]);
        else
            for jj = 1 : length(raster_session)
                indx = [];
                [T1_T2_events(jj).norm_sig_events,indx] = sort([T1_events(jj).all_norm_sig_event_times raster_session(jj).all_norm_sig_event_times]);
                T1_idx = T1_IDs == jj;
                T2_idx = all_ids == jj;
                combined = [T1_IDs(T1_idx) all_ids(T2_idx)*100];
                T1_T2_indices = [T1_T2_indices, combined(indx)];
            end
            T1_T2_IDs = sort([T1_IDs all_ids]);
        end
    end
    
    % Create colormap based on wcorr scores (darker - higher score)
    % vals = all_vals;
    % quadrnt1 = prctile(vals,25); %lower score
    % quadrnt2 = prctile(vals,50);
    % quadrnt3 = prctile(vals,75); %higher score
    %
    % for ii = 1 : length(vals) % Colormap based on quadrants from the vals distribution
    %     valsN = vals(ii);
    %     if valsN <= quadrnt1
    %         rgb{ii} = [0.8 0.8 0.8];
    %     elseif valsN > quadrnt1 && valsN <= quadrnt2
    %         rgb{ii} = [0.5 0.5 0.5];
    %     elseif valsN > quadrnt2 && valsN <= quadrnt3
    %         rgb{ii} = [0.3 0.3 0.3];
    %     elseif valsN > quadrnt3
    %         rgb{ii} = [0.0 0.0 0.0];
    %     end
    % end
    
    % ALTERNATIVE COLORMAP:
    %colmap = 'bone';
    %crange = [min(vals) max(vals)];
    %cmap = eval([flipud(colmap) '(256)']);
    % for ii = 1:length(vals)
    %     % Normalize the values to be between 1 and 256 for cell ii
    %     valsN = vals(ii);
    %     valsN(valsN < crange(1)) = crange(1);
    %     valsN(valsN > crange(2)) = crange(2);
    %     valsN = round(((valsN - crange(1)) ./ diff(crange)) .* 255)+1;
    %     % Convert any nans to ones
    %     valsN(isnan(valsN)) = 1;
    %     % Convert the normalized values to the RGB values of the colormap
    %     rgb{ii} = cmap(valsN, :);
    % end
    
    
    % RASTER PLOT OF REPLAY EVENTS
    PP = plotting_parameters;
    
    f1=figure('units','normalized','outerposition',[0 0 1 1]);
    f1.Name = strcat('Significant replay events during -', state, ' periods - Track  ',num2str(track));
    
    if strcmp(state,'sleep')
        
        % COLORMAP BASED ON PROTOCOL
        count = 1;
        cols = [];
        for i = 1 : 5 % 5 protocols
            cols = [cols; repmat(PP.T2(i,:),length([raster_session(count:count+3).norm_sig_event_times]),1)];
            count = count + 4;
        end
        
        raster_plot([raster_session(:).norm_sig_event_times]',all_ids,cols,1)
        hold on
        
        % Purple color - [0.4940, 0.1840, 0.5560]
        line([SleepPeriod_time_end(1) SleepPeriod_time_end(1)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2) % PRE end limit
        line([SleepPeriod_time_end(2) SleepPeriod_time_end(2)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2) % sleep pot 1 end limit
        line([SleepPeriod_time_end(3) SleepPeriod_time_end(3)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % inter post 2 end limit
        line([SleepPeriod_time_end(4) SleepPeriod_time_end(4)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % sleep pot 2 end limit
        
        annotation('textbox',[0.17 0.85 0.1 0.1],'String',strcat('PRE SLEEP'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        annotation('textbox',[0.26 0.85 0.1 0.1],'String',strcat('REST 1'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        annotation('textbox',[0.45 0.85 0.1 0.1],'String',strcat('INTER SLEEP'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        annotation('textbox',[0.66 0.85 0.1 0.1],'String',strcat('REST 2'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        annotation('textbox',[0.76 0.85 0.1 0.1],'String',strcat('FINAL SLEEP'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        
        box off
    elseif strcmp(state,'ALL') || strcmp(state,'awake')
        
        % COLORMAP BASED ON PROTOCOL
        count = 1;
        cols = [];
        for i = 1 : 5 % 5 protocols
            cols = [cols; repmat(PP.T2(i,:),length([raster_session(count:count+3).all_norm_sig_event_times]),1)];
            count = count + 4;
        end
        
        raster_plot([raster_session(:).all_norm_sig_event_times]',all_ids,cols,1)
        hold on
        
        line([ALLPeriods_time_end(1) ALLPeriods_time_end(1)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % PRE limit
        line([ALLPeriods_time_end(2) ALLPeriods_time_end(2)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % track 1 end limit
        line([ALLPeriods_time_end(3) ALLPeriods_time_end(3)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % sleep pot 1 end limit
        line([ALLPeriods_time_end(4) ALLPeriods_time_end(4)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % track 2 end limit
        line([ALLPeriods_time_end(5) ALLPeriods_time_end(5)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % inter post 2 end limit
        line([ALLPeriods_time_end(6) ALLPeriods_time_end(6)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % track3 end limit
        line([ALLPeriods_time_end(7) ALLPeriods_time_end(7)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % sleep pot 2 end limit
        line([ALLPeriods_time_end(8) ALLPeriods_time_end(8)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % track4 end limit
        
        annotation('textbox',[0.15 0.85 0.1 0.1],'String',strcat('PRE SLEEP'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        annotation('textbox',[0.23 0.85 0.1 0.1],'String',strcat('T1'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        annotation('textbox',[0.27 0.85 0.1 0.1],'String',strcat('REST 1'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        annotation('textbox',[0.29 0.85 0.1 0.1],'String',strcat('T2'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        annotation('textbox',[0.45 0.85 0.1 0.1],'String',strcat('INTER SLEEP'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        annotation('textbox',[0.61 0.85 0.1 0.1],'String',strcat('T3'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        annotation('textbox',[0.64 0.85 0.1 0.1],'String',strcat('REST 2'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        annotation('textbox',[0.67 0.85 0.1 0.1],'String',strcat('T4'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        annotation('textbox',[0.76 0.85 0.1 0.1],'String',strcat('FINAL SLEEP'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
        
        box off
    end
    
    
    % patch('vertices',[min(xlim),17;min(xlim),21;max(xlim),21;max(xlim),17],'faces',[1,2,3,4],'FaceColor',PP.T2(5,:),'FaceAlpha',0.08,'EdgeColor',PP.T2(5,:),'EdgeAlpha',0.2);
    % patch('vertices',[min(xlim),13;min(xlim),17;max(xlim),17;max(xlim),13],'faces',[1,2,3,4],'FaceColor',PP.T2(4,:),'FaceAlpha',0.08,'EdgeColor',PP.T2(4,:),'EdgeAlpha',0.2);
    % patch('vertices',[min(xlim),9;min(xlim),13;max(xlim),13;max(xlim),9],'faces',[1,2,3,4],'FaceColor',PP.T2(3,:),'FaceAlpha',0.12,'EdgeColor',PP.T2(3,:),'EdgeAlpha',0.2);
    % patch('vertices',[min(xlim),5;min(xlim),9;max(xlim),9;max(xlim),5],'faces',[1,2,3,4],'FaceColor',PP.T2(2,:),'FaceAlpha',0.12,'EdgeColor',PP.T2(2,:),'EdgeAlpha',0.2);
    % patch('vertices',[min(xlim),1;min(xlim),5;max(xlim),5;max(xlim),1],'faces',[1,2,3,4],'FaceColor',PP.T2(1,:),'FaceAlpha',0.12,'EdgeColor',PP.T2(1,:),'EdgeAlpha',0.2);
    
    names = [track_replay_events.session];
    names = names(1:2:end);
    for i = 1 : length(names) % Fix formatting name
        nm = names{i};
        nm(strfind(nm,'_')) = '-';
        names{i} = nm;
    end
    
    set(gca,'YLim',[0 length(track_replay_events)+2],'ytick',[2:1:length(track_replay_events)+1],'yticklabel',names)
    b = get(gca,'XTickLabel');
    set(gca,'XTickLabel',b,'Fontsize',14)
    %ylabel('sessions','FontSize',16);
    xlabel('Time (sec)','FontSize',16)
    annotation('textbox',[0.45 0.88 0.1 0.1],'String',strcat('Significant replay events during -', state, ' periods - Track  ',num2str(track)),'EdgeColor', 'none','HorizontalAlignment', 'center',...
        'FontSize',13,'FontWeight','bold');
    
end


f2=figure('units','normalized','outerposition',[0 0 1 1]);
f2.Name = strcat('Significant replay events during -', state, ' periods - Tracks 1 and 2' );

% PLOT T1 and T2 together

% COLORMAP BASED ON PROTOCOL
count = 1;
cols = [];
for i = 1 : 5 % 5 protocols
    cols = [cols; repmat(PP.T2(i,:),length([T1_T2_events(count:count+3).norm_sig_events]),1)];
    count = count + 4;
end
T1_indices = find(T1_T2_indices < 20);
for i = 1 : length(T1_indices)
    cols(T1_indices(i),:) = PP.T1;
end


raster_plot([T1_T2_events(:).norm_sig_events]',T1_T2_IDs,cols,1)
hold on

if strcmp(state,'sleep')
    
    line([SleepPeriod_time_end(1) SleepPeriod_time_end(1)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2) % PRE end limit
    line([SleepPeriod_time_end(2) SleepPeriod_time_end(2)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2) % sleep pot 1 end limit
    line([SleepPeriod_time_end(3) SleepPeriod_time_end(3)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % inter post 2 end limit
    line([SleepPeriod_time_end(4) SleepPeriod_time_end(4)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % sleep pot 2 end limit
    
    annotation('textbox',[0.17 0.85 0.1 0.1],'String',strcat('PRE SLEEP'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    annotation('textbox',[0.26 0.85 0.1 0.1],'String',strcat('REST 1'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    annotation('textbox',[0.45 0.85 0.1 0.1],'String',strcat('INTER SLEEP'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    annotation('textbox',[0.66 0.85 0.1 0.1],'String',strcat('REST 2'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    annotation('textbox',[0.76 0.85 0.1 0.1],'String',strcat('FINAL SLEEP'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    
elseif strcmp(state,'ALL') || strcmp(state,'awake')
    
    line([ALLPeriods_time_end(1) ALLPeriods_time_end(1)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % PRE limit
    line([ALLPeriods_time_end(2) ALLPeriods_time_end(2)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % track 1 end limit
    line([ALLPeriods_time_end(3) ALLPeriods_time_end(3)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % sleep pot 1 end limit
    line([ALLPeriods_time_end(4) ALLPeriods_time_end(4)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % track 2 end limit
    line([ALLPeriods_time_end(5) ALLPeriods_time_end(5)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % inter post 2 end limit
    line([ALLPeriods_time_end(6) ALLPeriods_time_end(6)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % track3 end limit
    line([ALLPeriods_time_end(7) ALLPeriods_time_end(7)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % sleep pot 2 end limit
    line([ALLPeriods_time_end(8) ALLPeriods_time_end(8)],[min(ylim) max(ylim)],'Color',[0.3, 0.3, 0.3],'LineWidth',2)  % track4 end limit
    
    annotation('textbox',[0.15 0.85 0.1 0.1],'String',strcat('PRE SLEEP'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    annotation('textbox',[0.23 0.85 0.1 0.1],'String',strcat('T1'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    annotation('textbox',[0.27 0.85 0.1 0.1],'String',strcat('REST 1'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    annotation('textbox',[0.29 0.85 0.1 0.1],'String',strcat('T2'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    annotation('textbox',[0.45 0.85 0.1 0.1],'String',strcat('INTER SLEEP'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    annotation('textbox',[0.61 0.85 0.1 0.1],'String',strcat('T3'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    annotation('textbox',[0.64 0.85 0.1 0.1],'String',strcat('REST 2'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    annotation('textbox',[0.67 0.85 0.1 0.1],'String',strcat('T4'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    annotation('textbox',[0.76 0.85 0.1 0.1],'String',strcat('FINAL SLEEP'),'EdgeColor', 'none','HorizontalAlignment', 'center','Fontsize',14);
    
end

names = [track_replay_events.session];
names = names(1:2:end);
for i = 1 : length(names) % Fix formatting name
    nm = names{i};
    nm(strfind(nm,'_')) = '-';
    names{i} = nm;
end

set(gca,'YLim',[0 length(track_replay_events)+2],'ytick',[2:1:length(track_replay_events)+1],'yticklabel',names)
b = get(gca,'XTickLabel');
set(gca,'XTickLabel',b,'Fontsize',14)
%ylabel('sessions','FontSize',16);
xlabel('Time (sec)','FontSize',16)
annotation('textbox',[0.45 0.88 0.1 0.1],'String',strcat('Significant replay events during -', state, ' periods - Tracks 1 and 2 '),'EdgeColor', 'none','HorizontalAlignment', 'center',...
    'FontSize',13,'FontWeight','bold');



end

function raster_plot(x,y,c,h)
x2(1:3:length(x)*3)=x;
x2(2:3:length(x)*3)=x;
x2(3:3:length(x)*3)=NaN;
y2(1:3:length(x)*3)=y;
y2(2:3:length(x)*3)=y+h;
y2(3:3:length(x)*3)=NaN;
if isempty(c)
    plot(x2,y2,'LineWidth',1);
elseif isnumeric(c) %colormap
    p = 1;
    for i = 1 : 3 :  length(x2)
        plot(x2(i:i+2),y2(i:i+2),'Color',c(p,:),'LineWidth',1.3);
        hold on
        p = p + 1;
    end
elseif isstring(c) %single color
    plot(x2,y2,c,'LineWidth',2);
end
end
