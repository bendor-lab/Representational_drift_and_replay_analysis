function extract_replay_bias(computer,epoch)
% Marta Huelin, 2020
% Plots replay bayesian probability bias between tracks
    
    
% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
else
    sessions = data_folders;
    session_names = fieldnames(sessions);
end

cd('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis')
load('extracted_time_periods_replay.mat')
load('extracted_replay_plotting_info.mat')

if strcmp(epoch, 'awake')
    periods = [{'PRE'},{'T1'},{'sleep_pot1'},{'T2'},{'INTER_post'},{'T3'},{'sleep_pot2'},{'T4'},{'FINAL_post'}];
else
    periods = [{'PRE'},{'sleep_pot1'},{'INTER_post'},{'sleep_pot2'},{'FINAL_post'}];
end
PP = plotting_parameters;

i = 1; % session count

for p = 1 : length(session_names)
    
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    f(2*p) = figure('units','normalized','outerposition',[0 0 1 1]);
    f(2*p).Name = strcat('Replay score for multi events for T1 and T3_',epoch,' Replay_Protocol_',session_names{p});
    f(5*p) = figure('units','normalized','outerposition',[0 0 1 1]);
    f(5*p).Name = strcat('Replay score for multi events for T2 and T4_',epoch,' Replay_Protocol_',session_names{p});
%    
%     f(12*p) = figure('units','normalized','outerposition',[0 0 1 1]);
%     f(12*p).Name = strcat('Cumulative sum replay scores for T1 and T3_',epoch,' Replay_Protocol_',session_names{p});
%     f(13*p) = figure('units','normalized','outerposition',[0 0 1 1]);
%     f(13*p).Name = strcat('Cumulative sum replay scores for T2 and T4_',epoch,' Replay_Protocol_',session_names{p});    
      
    f(21*p) = figure('units','normalized','outerposition',[0 0 1 1]);
    f(21*p).Name = strcat('Replay score for all tracks_',epoch,' Replay_Protocol_',session_names{p});

    
    for s = 1: length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        
        if exist(strcat(pwd,'\significant_events.mat'),'file')
            load('significant_replay_events.mat')
            
            curr_folder = strsplit(folders{s},'\');
            rat = curr_folder{8}; sess = curr_folder{9};
            
            % For each track, get sleep & awake indices in each period and concatenate together
            folder_indx = (find(strcmp([track_replay_events(:).session],sess)==1)+1)/2;% find the extracted replay information for this session
            replay_idxs_T1 = [];   replay_REAL_idxs_T1 = [];
            replay_idxs_T3 = [];   replay_REAL_idxs_T3 = [];
            replay_idxs_T2 = [];   replay_REAL_idxs_T2 = [];
            replay_idxs_T4 = [];   replay_REAL_idxs_T4 = [];
            for ii = 1 : length(periods)
                if length(periods{ii})>2
                    replay_idxs_T1 = [replay_idxs_T1 track_replay_events(folder_indx).T1.(strcat(periods{ii},'_',epoch,'_index'))]; %indices from track_replay_events.track.index
                    replay_idxs_T3 = [replay_idxs_T3 track_replay_events(folder_indx).T3.(strcat(periods{ii},'_',epoch,'_index'))];
                    replay_idxs_T2 = [replay_idxs_T2 track_replay_events(folder_indx).T2.(strcat(periods{ii},'_',epoch,'_index'))];
                    replay_idxs_T4 = [replay_idxs_T4 track_replay_events(folder_indx).T4.(strcat(periods{ii},'_',epoch,'_index'))];
                    
                    replay_REAL_idxs_T1 = [replay_REAL_idxs_T1 track_replay_events(folder_indx).T1.(strcat(periods{ii},'_',epoch,'_REAL_index'))]; %real replay indices
                    replay_REAL_idxs_T3 = [replay_REAL_idxs_T3 track_replay_events(folder_indx).T3.(strcat(periods{ii},'_',epoch,'_REAL_index'))];
                    replay_REAL_idxs_T2 = [replay_REAL_idxs_T2 track_replay_events(folder_indx).T2.(strcat(periods{ii},'_',epoch,'_REAL_index'))];
                    replay_REAL_idxs_T4 = [replay_REAL_idxs_T4 track_replay_events(folder_indx).T4.(strcat(periods{ii},'_',epoch,'_REAL_index'))];

                elseif length(periods{ii})==2
                    replay_idxs_T1 = [replay_idxs_T1 track_replay_events(folder_indx).T1.(strcat(periods{ii},'_index'))];
                    replay_idxs_T3 = [replay_idxs_T3 track_replay_events(folder_indx).T3.(strcat(periods{ii},'_index'))];
                    replay_idxs_T2 = [replay_idxs_T2 track_replay_events(folder_indx).T2.(strcat(periods{ii},'_index'))];
                    replay_idxs_T4 = [replay_idxs_T4 track_replay_events(folder_indx).T4.(strcat(periods{ii},'_index'))];
                    
                    replay_REAL_idxs_T1 = [replay_REAL_idxs_T1 track_replay_events(folder_indx).T1.(strcat(periods{ii},'_REAL_index'))]; %real replay indices
                    replay_REAL_idxs_T3 = [replay_REAL_idxs_T3 track_replay_events(folder_indx).T3.(strcat(periods{ii},'_REAL_index'))];
                    replay_REAL_idxs_T2 = [replay_REAL_idxs_T2 track_replay_events(folder_indx).T2.(strcat(periods{ii},'_REAL_index'))];
                    replay_REAL_idxs_T4 = [replay_REAL_idxs_T4 track_replay_events(folder_indx).T4.(strcat(periods{ii},'_REAL_index'))];

                end
            end
            
            % For each track, find the indices of those events that initially were significant for the first and secon exposure (multievents)
            [~,indx_1,~] = intersect(significant_replay_events.track(1).index,significant_replay_events.track1_and_1R_significant(:,1));
            [~,indx_3,~] = intersect(significant_replay_events.track(3).index,significant_replay_events.track1_and_1R_significant(:,1));
            [~,indx_2,~] = intersect(significant_replay_events.track(2).index,significant_replay_events.track2_and_2R_significant(:,1));
            [~,indx_4,~] = intersect(significant_replay_events.track(4).index,significant_replay_events.track2_and_2R_significant(:,1));

            % From the multievents indices,find indices of those happening in the epoch analysed (sleep or awake)
            epoch_indx_1 = intersect(indx_1,replay_idxs_T1);
            epoch_indx_3 = intersect(indx_3,replay_idxs_T3);
            epoch_indx_2 = intersect(indx_2,replay_idxs_T2);
            epoch_indx_4 = intersect(indx_4,replay_idxs_T4);
            
%%%% PLOTS FOR EACH RAT
                              
   %%%%%%%%% PLOT DIFFERENCE IN REPLAY SCORE FOR MULTIEVENTS
    figure(f(2*p)) % T1 & R-T1
            subplot(length(folders),1,s)

            %scores T1 - scores T3
            [~,epoch_multi_events,~] = intersect(significant_replay_events.track1_and_1R_significant,[replay_REAL_idxs_T1 replay_REAL_idxs_T3]);
            score_diff = significant_replay_events.track1_and_1R_significant(epoch_multi_events,2) - significant_replay_events.track1_and_1R_significant(epoch_multi_events,3);
            plot(significant_replay_events.all_event_times(significant_replay_events.track1_and_1R_significant(epoch_multi_events,1)),...
                score_diff,'Color',PP.T1,'LineWidth',PP.Linewidth{1},'LineStyle',PP.Linestyle{1})
            hold on
            plot(significant_replay_events.all_event_times(significant_replay_events.track1_and_1R_significant(epoch_multi_events,1)),...
                score_diff,'o','MarkerFaceColor',PP.T1,'MarkerEdgeColor',PP.T1)
      
            % Add time limits
            folder_indx = find(strcmp([period_time(:).sessions_order],sess)==1);% find the time information for this session
            for ii = 1 : length(periods)
                hold on
                plot([period_time(folder_indx).(strcat(periods{ii})).time_limits(2) period_time(folder_indx).(strcat(periods{ii})).time_limits(2)],...
                    [min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',2)
            end
                
            % Add threshold lines
            plot([min(xlim) max(xlim)],[0 0],'LineStyle',':','Color','k','LineWidth',0.5) % separates T1 vs T3
            plot([min(xlim) max(xlim)],[-0.1 -0.1],'LineStyle',':','Color',[0.8 0 0.2],'LineWidth',1) % 20% threshold (60% vs 40%)
            plot([min(xlim) max(xlim)],[0.1 0.1],'LineStyle',':','Color',[0.8 0 0.2],'LineWidth',1)

            box off
            xlabel('Binned time (min)'); ylabel('Diff replay score');
            session = strsplit(folders{s},'\');
            title(strcat('Rat: ',rat),'FontSize',10)
            
    figure(f(5*p)) % T2 & R-T2
            subplot(length(folders),1,s)  
            %scores T2 - scores T4    
            [~,epoch_multi_events,~] = intersect(significant_replay_events.track2_and_2R_significant,[replay_REAL_idxs_T2 replay_REAL_idxs_T4]);
            score_diff = significant_replay_events.track2_and_2R_significant(epoch_multi_events,2) - significant_replay_events.track2_and_2R_significant(epoch_multi_events,3);
            plot(significant_replay_events.all_event_times(significant_replay_events.track2_and_2R_significant(epoch_multi_events,1)),...
                score_diff,'Color',PP.T2(p,:),'LineWidth',PP.Linewidth{1},'LineStyle',PP.Linestyle{1})
            hold on
            plot(significant_replay_events.all_event_times(significant_replay_events.track2_and_2R_significant(epoch_multi_events,1)),...
                score_diff,'o','MarkerFaceColor',PP.T2(p,:),'MarkerEdgeColor',PP.T2(p,:))
      
            % Add time limits
            folder_indx = find(strcmp([period_time(:).sessions_order],sess)==1);% find the time information for this session
            for ii = 1 : length(periods)
                hold on
                plot([period_time(folder_indx).(strcat(periods{ii})).time_limits(2) period_time(folder_indx).(strcat(periods{ii})).time_limits(2)],...
                    [min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',2)
            end
                
            % Add threshold lines
            plot([min(xlim) max(xlim)],[0 0],'LineStyle',':','Color','k','LineWidth',0.5) % separates T1 vs T3
            plot([min(xlim) max(xlim)],[-0.1 -0.1],'LineStyle',':','Color',[0.8 0 0.2],'LineWidth',1) % 20% threshold (60% vs 40%)
            plot([min(xlim) max(xlim)],[0.1 0.1],'LineStyle',':','Color',[0.8 0 0.2],'LineWidth',1)
            
            box off
            xlabel('Binned time (min)'); ylabel('Diff replay score');
            title(strcat('Rat: ',rat),'FontSize',12)
           
  
%    %%%%%%%%%%%%%%%               
%    figure(f(12*p))
%             subplot(length(folders),1,s)     
%        
%                figure(f(13*p))
%             subplot(length(folders),1,s)
%             plot(significant_replay_events.track(2).event_times,significant_replay_events.track(2).replay_score,'Color',PP.T2(p,:),'LineWidth',PP.Linewidth{2},'LineStyle',PP.Linestyle{2})
%             hold on
%             plot(significant_replay_events.track(4).event_times,significant_replay_events.track(4).replay_score,'Color',PP.T2(p,:),'LineWidth',PP.Linewidth{4},'LineStyle',PP.Linestyle{4})
%             [~,i2,~] = intersect(significant_replay_events.track(2).index,significant_replay_events.track2_and_2R_significant(:,1));
%             [~,i4,~] = intersect(significant_replay_events.track(4).index,significant_replay_events.track2_and_2R_significant(:,1));
%             plot(significant_replay_events.track(2).event_times(i2),significant_replay_events.track(2).replay_score(i2),'o','MarkerFaceColor',[0.6 0.6 0.6]);
%             plot(significant_replay_events.track(4).event_times(i4),significant_replay_events.track(4).replay_score(i4),'o','MarkerFaceColor',[0.6 0.4 0.8]);
%             
%             % Add time limits
%             folder_indx = find(strcmp([period_time(:).sessions_order],sess)==1);% find the time information for this session
%             for ii = 1 : length(periods)
%                 hold on
%                 plot([period_time(folder_indx).(strcat(periods{ii})).time_limits(2) period_time(folder_indx).(strcat(periods{ii})).time_limits(2)],...
%                     [min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',2)
%             end
%             
%             box off
%             xlabel('Binned time (min)'); ylabel('Diff replay score');
%             session = strsplit(folders{s},'\');
%             title(strcat('Rat: ',rat),'FontSize',10)
%             
%             %%%%%%%%% Get scores of events sgnificant for the 1st and Re-exposure to track 2       
% 
%             
            
            
    %%%%%%%  PLOT REPLAY SCORE FOR ALL TRACKS
    
            figure(f(21*p))
            subplot(length(folders),1,s)
            plot(significant_replay_events.track(1).event_times(replay_idxs_T1),significant_replay_events.track(1).replay_score(replay_idxs_T1),'Color',PP.T1,'LineWidth',PP.Linewidth{1},'LineStyle',PP.Linestyle{1})
            hold on
            plot(significant_replay_events.track(3).event_times(replay_idxs_T3),significant_replay_events.track(3).replay_score(replay_idxs_T3),'Color',PP.T1,'LineWidth',PP.Linewidth{3},'LineStyle',PP.Linestyle{3})            
            plot(significant_replay_events.track(2).event_times(replay_idxs_T2),significant_replay_events.track(2).replay_score(replay_idxs_T2),'Color',PP.T2(p,:),'LineWidth',PP.Linewidth{2},'LineStyle',PP.Linestyle{2})            
            plot(significant_replay_events.track(4).event_times(replay_idxs_T4),significant_replay_events.track(4).replay_score(replay_idxs_T4),'Color',PP.T2(p,:),'LineWidth',PP.Linewidth{4},'LineStyle',PP.Linestyle{4})            
            
            plot(significant_replay_events.track(1).event_times(epoch_indx_1),significant_replay_events.track(1).replay_score(epoch_indx_1),'o','MarkerFaceColor',[0.6 0.6 0.6],'MarkerEdgeColor','y');
            plot(significant_replay_events.track(3).event_times(epoch_indx_3),significant_replay_events.track(3).replay_score(epoch_indx_3),'o','MarkerFaceColor',[0.6 0.4 0.8],'MarkerEdgeColor','m');
            plot(significant_replay_events.track(2).event_times(epoch_indx_2),significant_replay_events.track(2).replay_score(epoch_indx_2),'o','MarkerFaceColor',[0.6 0.6 0.6],'MarkerEdgeColor','g');
            plot(significant_replay_events.track(4).event_times(epoch_indx_4),significant_replay_events.track(4).replay_score(epoch_indx_4),'o','MarkerFaceColor',[0.6 0.4 0.8],'MarkerEdgeColor','b');
 
            % Add time limits
            folder_indx = find(strcmp([period_time(:).sessions_order],sess)==1);% find the time information for this session
            for ii = 1 : length(periods)
                hold on
                plot([period_time(folder_indx).(strcat(periods{ii})).time_limits(2) period_time(folder_indx).(strcat(periods{ii})).time_limits(2)],...
                    [min(ylim) max(ylim)],'Color',[0.6 0.6 0.6],'LineWidth',2)
            end
            
            box off
            xlabel('Binned time (min)'); ylabel('Replay score');
            session = strsplit(folders{s},'\');
            title(strcat('Rat: ',rat),'FontSize',10)
            
            
        end
    end
   figure(f(2*p))
   annotation('textbox',[0.4,0.9,0.05,0.1],'String',strcat(session_names{p},'- Difference replay score between T1 and Re-T1'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
      annotation('textbox',[0.91,0.83,0.05,0.1],'String','T1','FitBoxToText','on','EdgeColor','none','FontSize',15);
   annotation('textbox',[0.91,0.7,0.05,0.1],'String','Re-T1','FitBoxToText','on','EdgeColor','none','FontSize',15);
      annotation('textbox',[0.91,0.61,0.05,0.1],'String','T1','FitBoxToText','on','EdgeColor','none','FontSize',15);
   annotation('textbox',[0.91,0.48,0.05,0.1],'String','Re-T1','FitBoxToText','on','EdgeColor','none','FontSize',15);
      annotation('textbox',[0.91,0.38,0.05,0.1],'String','T1','FitBoxToText','on','EdgeColor','none','FontSize',15);
   annotation('textbox',[0.91,0.26,0.05,0.1],'String','Re-T1','FitBoxToText','on','EdgeColor','none','FontSize',15);
      annotation('textbox',[0.91,0.16,0.05,0.1],'String','T1','FitBoxToText','on','EdgeColor','none','FontSize',15);
   annotation('textbox',[0.91,0.05,0.05,0.1],'String','Re-T1','FitBoxToText','on','EdgeColor','none','FontSize',15);

   figure(f(5*p))
   annotation('textbox',[0.4,0.9,0.05,0.1],'String',strcat(session_names{p},'- Difference replay score between T2 and Re-T2'),'FitBoxToText','on','EdgeColor','none','FontSize',20);
      annotation('textbox',[0.91,0.83,0.05,0.1],'String','T2','FitBoxToText','on','EdgeColor','none','FontSize',15);
   annotation('textbox',[0.91,0.7,0.05,0.1],'String','Re-T2','FitBoxToText','on','EdgeColor','none','FontSize',15);
      annotation('textbox',[0.91,0.61,0.05,0.1],'String','T2','FitBoxToText','on','EdgeColor','none','FontSize',15);
   annotation('textbox',[0.91,0.48,0.05,0.1],'String','Re-T2','FitBoxToText','on','EdgeColor','none','FontSize',15);
      annotation('textbox',[0.91,0.38,0.05,0.1],'String','T2','FitBoxToText','on','EdgeColor','none','FontSize',15);
   annotation('textbox',[0.91,0.26,0.05,0.1],'String','Re-T2','FitBoxToText','on','EdgeColor','none','FontSize',15);
      annotation('textbox',[0.91,0.16,0.05,0.1],'String','T2','FitBoxToText','on','EdgeColor','none','FontSize',15);
   annotation('textbox',[0.91,0.05,0.05,0.1],'String','Re-T2','FitBoxToText','on','EdgeColor','none','FontSize',15);
   
   
end














end