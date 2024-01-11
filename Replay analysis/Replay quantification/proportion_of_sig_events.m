% Proportion of significant replay events

function proportion_of_sig_events(computer)

% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
elseif isempty(computer) %normal computer
    sessions = data_folders;
    session_names = fieldnames(sessions);
else %if entering a single folder
    folders = {computer};
    session_names = folders;
end

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
f1.Name = 'Proportion of significant events per protocol';
c = 1;
PP = plotting_parameters;
protocols = [8,4,3,2,1];

% For each protocol
for p = 1 : length(session_names)
    
    if length(session_names) > 1 %more than one folder
        folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    end
    
    events_wcorr = [];    events_spearman = []; events_linear=[];
    
    for s = 1 : length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        
        if exist(strcat(pwd,'\significant_replay_events_wcorr.mat'),'file')
            load('significant_replay_events_wcorr.mat')
            wcorr_events = significant_replay_events;
            clear significant_replay_events
            load('significant_replay_events_spearman.mat')
            spearman_events = significant_replay_events;
            clear significant_replay_events
            load('significant_replay_events_linear.mat')
            linear_events = significant_replay_events;
            clear significant_replay_events
            
            % For each track, calculate proportion of sig events VS the total candidate events
            %WCORR
            events_wcorr(1,s) = length(wcorr_events.track(1).index)/length(wcorr_events.all_event_times)*100;
            events_wcorr(2,s) = length(wcorr_events.track(2).index)/length(wcorr_events.all_event_times)*100;
            events_wcorr(3,s) = length(wcorr_events.track(3).index)/length(wcorr_events.all_event_times)*100;
            events_wcorr(4,s) = length(wcorr_events.track(4).index)/length(wcorr_events.all_event_times)*100;
            
            total_num_sig_events.wcorr{p,s} = [length(wcorr_events.track(1).index) length(wcorr_events.track(2).index) length(wcorr_events.track(3).index)...
                length(wcorr_events.track(4).index)];
            total_num_sig_events.total_wcorr(p,s) = [length(wcorr_events.track(1).index) + length(wcorr_events.track(2).index) + length(wcorr_events.track(3).index)...
                + length(wcorr_events.track(4).index)];
            
            % SPEARMAN
            events_spearman(1,s) = length(spearman_events.track(1).index)/length(spearman_events.all_event_times)*100;
            events_spearman(2,s) = length(spearman_events.track(2).index)/length(spearman_events.all_event_times)*100;
            events_spearman(3,s) = length(spearman_events.track(3).index)/length(spearman_events.all_event_times)*100;
            events_spearman(4,s) = length(spearman_events.track(4).index)/length(spearman_events.all_event_times)*100;
            
             total_num_sig_events.spearman{p,s} = [length(spearman_events.track(1).index) length(spearman_events.track(2).index) length(spearman_events.track(3).index)...
                length(spearman_events.track(4).index)];
            total_num_sig_events.total_spearman(p,s) = [length(spearman_events.track(1).index) + length(spearman_events.track(2).index) + length(wcorr_events.track(3).index)...
                + length(spearman_events.track(4).index)];
            
            % Line fitting
            events_linear(1,s) = length(linear_events.track(1).index)/length(linear_events.all_event_times)*100;
            events_linear(2,s) = length(linear_events.track(2).index)/length(linear_events.all_event_times)*100;
            events_linear(3,s) = length(linear_events.track(3).index)/length(linear_events.all_event_times)*100;
            events_linear(4,s) = length(linear_events.track(4).index)/length(linear_events.all_event_times)*100;
            
            total_num_sig_events.linear{p,s} = [length(linear_events.track(1).index) length(linear_events.track(2).index) length(linear_events.track(3).index)...
                length(linear_events.track(4).index)];
            total_num_sig_events.total_linear(p,s) = [length(linear_events.track(1).index) + length(linear_events.track(2).index) + length(wcorr_events.track(3).index)...
                + length(linear_events.track(4).index)];
            
        end
    end
    
    subplot(5,3,c)
    for i = 1 : 4
        hold on
        b(i) = bar(i,mean(events_wcorr(i,:)));
        b(i).FaceColor = PP.P(p).colorT(i,:);
        b(i).EdgeColor = PP.P(p).colorT(i,:);
        if i > 2
          b(i).FaceAlpha = 0.5;
          b(i).EdgeAlpha = 0.5;
        end
        e(i) = errorbar(i,mean(events_wcorr(i,:)),std(events_wcorr(i,:)),'Color',[0.6 0.6 0.6]);
        for j = 1 : 4
            plot(ones(1,length(events_wcorr(i,j)))*i,events_wcorr(i,j),'Marker',PP.rat_markers{j},'MarkerFace','w','MarkerEdge','k',...
                'MarkerSize',PP.rat_markers_size{j}+2)
        end
    end
    ylabel('proportion of sig events')
    ylim([0 15])
    set(gca, 'XTick',1:1:4)
    set(gca, 'XTickLabel', {'T1','T2','R-T1','R-T2'})
    title(strcat('WCORR - 16x',num2str(protocols(p))))
    c = c+1;
    
        
    subplot(5,3,c)
    for i = 1 : 4
        hold on
        b(i) = bar(i,mean(events_spearman(i,:)));
        b(i).FaceColor = PP.P(p).colorT(i,:);
        b(i).EdgeColor = PP.P(p).colorT(i,:);
        if i > 2
            b(i).FaceAlpha = 0.5;
            b(i).EdgeAlpha = 0.5;
        end
        e(i) = errorbar(i,mean(events_spearman(i,:)),std(events_spearman(i,:)),'Color',[0.6 0.6 0.6]);
        for j = 1 : 4
            plot(ones(1,length(events_spearman(i,j)))*i,events_spearman(i,j),'Marker',PP.rat_markers{j},'MarkerFace','w','MarkerEdge','k',...
                'MarkerSize',PP.rat_markers_size{j}+2)
        end
        %plot(ones(1,length(events_spearman(i,:)))*i,events_spearman(i,:),'Marker,'o','MarkerFace','w','MarkerEdge','k')
    end
    ylabel('proportion of sig events')
    ylim([0 15])
    set(gca, 'XTick',1:1:4)
    set(gca, 'XTickLabel', {'T1','T2','R-T1','R-T2'})
    title(strcat('SPEARMAN - 16x',num2str(protocols(p))))
    c = c+1;

    
    subplot(5,3,c)
    for i = 1 : 4
        hold on
        b(i) = bar(i,mean(events_linear(i,:)));
        b(i).FaceColor = PP.P(p).colorT(i,:);
        b(i).EdgeColor = PP.P(p).colorT(i,:);
        if i > 2
            b(i).FaceAlpha = 0.5;
            b(i).EdgeAlpha = 0.5;
        end
        e(i) = errorbar(i,mean(events_linear(i,:)),std(events_linear(i,:)),'Color',[0.6 0.6 0.6]);
        for j = 1 : 4
            plot(ones(1,length(events_linear(i,j)))*i,events_linear(i,j),'Marker',PP.rat_markers{j},'MarkerFace','w','MarkerEdge','k',...
                'MarkerSize',PP.rat_markers_size{j}+2)
        end
    end
    ylabel('proportion of sig events')
    ylim([0 15])
    set(gca, 'XTick',1:1:4)
    set(gca, 'XTickLabel', {'T1','T2','R-T1','R-T2'})
    title(strcat('LINE FITTING - 16x',num2str(protocols(p))))
    c = c+1;
    
    % save in structure
    protocol_sig_events(p).events_wcorr = events_wcorr;
    protocol_sig_events(p).events_spearman = events_spearman;
    protocol_sig_events(p).events_linear = events_linear;
    
end

% Save
save_path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
save([save_path '\proportion_sig_events.mat'],'protocol_sig_events')
end

