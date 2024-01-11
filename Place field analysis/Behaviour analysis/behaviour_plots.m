% BEHAVIOURAL PLOTS
% MH, 2020
% Extracts some behavioural features, such as speed, time immobile and time
% running in the track, for each protocol and session and creates plots
% Saves data structure 

function behaviour_plots(computer,data_type)

% Load name of data folders
if strcmp(computer,'GPU')
    sessions = strcat(data_type);
    session_names = fieldnames(sessions);
elseif isempty(computer) %normal computer
    sessions = data_type;
    session_names = fieldnames(sessions);
else %if entering a single folder
    folders = {computer};
    session_names = folders;
end

PP = plotting_parameters;
% Find indices for each type of protocol
t2 = [];
for s = 1 : length(session_names)
    if strfind(session_names{s},'speed')
        idx_x =  strfind(session_names{s},'x');
        t2 = [t2 str2num(session_names{s}(idx_x+1:end))];
    else
        t2 = [t2 str2num(session_names{s}(end))];
    end
end
protocols = unique(t2,'stable');
parameters = list_of_parameters;
num_sessions = length(session_names);

% Initialise structure
[lap_behaviour(1:4).moving_speed] = deal(nan(num_sessions,46)); %where 46 is max number of laps recorded
[lap_behaviour(1:4).immobile_speed] = deal(nan(num_sessions,46));
[lap_behaviour(1:4).time_moving] = deal(nan(num_sessions,46));
[lap_behaviour(1:4).time_immobile] = deal(nan(num_sessions,46));

c = 1;
% For each protocol
for p = 1 : length(session_names)
    
    if length(session_names) > 1 %more than one folder
        folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    end
    
    for s = 1 : length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        
        load extracted_position.mat
        load extracted_place_fields_BAYESIAN.mat
        load extracted_laps.mat
        
        % Speed in track
        for t = 1 : length(position.linear)
            track_speed = position.v_cm(position.linear(t).clean_track_Indices); 
            moving_speed(c,t) = mean(track_speed(find(track_speed>5))); %c is session, t is track
            immobile_speed(c,t) = mean(track_speed(find(track_speed<5)));
            time_mov = position.linear(t).timestamps(find(track_speed>5));
            time_moving(c,t) = length(time_mov)*0.04/60; %rate
            time_im = position.linear(t).timestamps(find(track_speed<5));
            time_immobile(c,t) = (length(time_im)*0.04)/60; %rate
            ratio_time_moving_immobile(c,t) = time_moving(c,t)/time_immobile(c,t);
            
            %EXTRACT PER TRACK LAPS
            for lap = 1 : lap_times(t).number_completeLaps
                lap_idx = find(position.linear(t).timestamps > lap_times(t).completeLaps_start(lap) & position.linear(t).timestamps < lap_times(t).completeLaps_stop(lap));
                lap_speed = track_speed(lap_idx);
                lap_behaviour(t).moving_speed(c,lap) = mean(lap_speed(find(lap_speed>5)));
                lap_behaviour(t).immobile_speed(c,lap) = mean(lap_speed(find(lap_speed<5)));
                lap_time = position.linear(t).timestamps(lap_idx);
                lap_time_move = lap_time(find(lap_speed>5));
                lap_behaviour(t).time_moving(c,lap) = length(lap_time_move)*0.04/60; %rate
                lap_time_im = lap_time(find(lap_speed<5));
                lap_behaviour(t).time_immobile(c,lap) = (length(lap_time_im)*0.04)/60; %rate
                lap_behaviour(t).ratio_time_moving_immobile(c,lap) = lap_behaviour(t).time_moving(c,lap)/lap_behaviour(t).time_immobile(c,lap);
                moving_speed_thresh = lap_speed(find(lap_speed>5));
                lap_behaviour(t).acceleration(c,lap) =  2*(200-moving_speed_thresh(1)*lap_behaviour(t).time_moving(c,lap))/(sqrt(lap_behaviour(t).time_moving(c,lap))); %a = 2 * (?d - v_i * ?t) / ?t²
                lap_behaviour(t).acceleration2(c,lap) =  (moving_speed_thresh(end)-moving_speed_thresh(1))/lap_behaviour(t).time_moving(c,lap); %a = (v_f - v_i) / ?t
            end
            
        end
        c = c+1;
    end
end

% Find number of different rats in this data set
num_rats = length(unique(arrayfun(@(x) sessions.(sprintf('%s',session_names{x})){1,1}(52:56),1:length(session_names),'UniformOutput',0))); %indx 52-56 are always the same based on folder name

if strcmp(data_type,'data_folders') % if plotting main data set
% RUN STATS - REPEATED MEASURES ANOVA
    % Moving speed
tbl = table;
rats = repmat([1:num_rats],[1,length(protocols)])';
tbl.rats = rats;
for j = 1 : size(moving_speed,2)
    tbl.(sprintf('%s','T',num2str(j))) = moving_speed(:,j);
end
meas = table([1 2 3 4]','VariableNames',{'Tracks'});
rm = fitrm(tbl,'T1-T4~rats','WithinDesign',meas);
ranovatbl = ranova(rm);
    % Running Time
tbl = table;
rats = repmat([1:num_rats],[1,length(protocols)])';
tbl.rats = rats;
tbl.T1 = time_moving(:,1);
tbl.T3 = time_moving(:,3);
tbl.T4 = time_moving(:,4);
meas = table([1 2 3]','VariableNames',{'Tracks'});
rm = fitrm(tbl,'T1-T4~rats','WithinDesign',meas);
ranovatbl = ranova(rm);  
    % Immobile Time
tbl = table;
rats = repmat([1:num_rats],[1,length(protocols)])';
tbl.rats = rats;
tbl.T1 = time_immobile(:,1);
tbl.T3 = time_immobile(:,3);
tbl.T4 = time_immobile(:,4);
meas = table([1 2 3]','VariableNames',{'Tracks'});
rm = fitrm(tbl,'T1-T4~rats','WithinDesign',meas);
ranovatbl = ranova(rm);  


 % Mean running speed per track
    f1 = figure('units','normalized','outerposition',[0 0 1 1]);
    f1.Name = 'Behaviour plots';
    subplot(2,2,1)
    hold on
    x_labels = {'T1','T2','R-T1','R-T2'}; %set labels for X axis
    boxplot(moving_speed,'PlotStyle','traditional','Colors',[0.3 0.3 0.3],'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([1,2,3,4]));  % Get the children you need (boxes for first exposure)
    set(boxes,'LineWidth',2); % Set width
    box off
    for ii = 1 : 4 %for each track
        c = 1;
        for p = 1 : num_sessions
            plot(ii,moving_speed(c:c+num_rats-1,ii),'o','MarkerEdgeColor',PP.T2(p,:),'MarkerFaceColor',PP.T2(p,:))
            c = c + num_rats;
        end
    end
    ylabel('mean running speed','FontSize',16)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    title('Mean running speed per track','FontSize',18);
    
    % Difference in speed between tracks
    speed_diff = [moving_speed(:,2)-moving_speed(:,1) moving_speed(:,3)-moving_speed(:,2) moving_speed(:,4)-moving_speed(:,3)];
    mean_speed_diff = mean(speed_diff,1);
    std_speed_diff = std(speed_diff,1);
    subplot(2,2,2)
    hold on
    for s = 1  : size(speed_diff,2) %for track diff
        for ii = 1 : size(speed_diff,1) % for each protocol
            %             hold on
            %             plot(s,speed_diff(ii,s),'o','MarkerFaceColor',[0.8 0.8 0.8],'MarkerEdgeColor',[0.8 0.8 0.8])
            %             plot(speed_diff(ii,:),'Color',[0.8 0.8 0.8],'LineWidth',0.5)
          if ii <5
              p = 1;
          elseif ii>4 && ii<9
              p = 2;
          elseif ii>8 && ii<13
              p = 3;
          elseif ii>12 && ii<17
              p = 4;
          elseif ii>16 && ii<21
              p = 5;
          end
          plot(s,speed_diff(ii,s),'o','MarkerEdgeColor',PP.T2(p,:),'MarkerFaceColor',PP.T2(p,:));
          plot(speed_diff(ii,:),'Color',PP.T2(p,:),'LineWidth',0.5);
        end
    end
    plot(mean_speed_diff,'Color','k','LineWidth',3)
    xlim([0.5 3.5])
    xticks([1 2 3])
    xticklabels({'T2 - T1','R-T1 - T2','R-T2 - R-T1'})
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    ylabel('Difference in running speed between tracks (cm/s)','FontSize',16);
    title('Difference in running speed','FontSize',18);
    
    % Time running
    c=1;
    invert_time = flipud(time_moving(:,2));
    for p = 1 : num_sessions
        if size(invert_time,1) < size(time_moving(:,1),1) 
            test(:,p) = [invert_time(c:c+num_rats-1); nan(16,1)];
        else 
            test(:,p) = [invert_time(c:c+num_rats-1); nan(1,1)]; %for speed data
        end
        c = c +num_rats;
    end
    test = [test time_moving(:,1) time_moving(:,3:4)];
    subplot(2,2,3)
    hold on
    x_labels = {'1 Lap','2 Laps','3 Laps','4 Laps','8 Laps','16 Laps','R-T1','R-T2'}; %set labels for X axis
    boxplot(test,'PlotStyle','traditional','Colors',[0.3 0.3 0.3],'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([1:8]));  % Get the children you need (boxes for first exposure)
    set(boxes,'LineWidth',2); % Set width
    box off
    for ii = 1 : size(test,2)-3 %for each protocol 1 to 8
          plot(ii,test(:,ii),'o','MarkerEdgeColor',PP.T2(6-ii,:),'MarkerFaceColor',PP.T2(6-ii,:))
    end
    for ii = size(test,2)-2 : size(test,2) %for 16 laps and reexp
        c = 1;
        for p = 1 : 5
            plot(ii,test(c:c+3,ii),'o','MarkerEdgeColor',PP.T2(p,:),'MarkerFaceColor',PP.T2(p,:))
            c = c +4;
        end
    end
    ylabel('Time spent running','fontsize',16)
    title('Time running','FontSize',18);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    
    % Plot time immobile in the track
    c=1;
    test= [];
    invert_time = flipud(time_immobile(:,2));
    for p = 1 : 5
        test(:,p) = [invert_time(c:c+3); nan(16,1)];
        c = c +4;
    end
    test = [test time_immobile(:,1) time_immobile(:,3:4)];
    subplot(2,2,4)
    hold on
    x_labels = {'1 Lap','2 Laps','3 Laps','4 Laps','8 Laps','16 Laps','R-T1','R-T2'}; %set labels for X axis
    boxplot(test,'PlotStyle','traditional','Colors',[0.3 0.3 0.3],'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([1:8]));  % Get the children you need (boxes for first exposure)
    set(boxes,'LineWidth',2); % Set width
    box off
    for ii = 1 : size(test,2)-3 %for each protocol 1 to 8
          plot(ii,test(:,ii),'o','MarkerEdgeColor',PP.T2(6-ii,:),'MarkerFaceColor',PP.T2(6-ii,:))
    end
    for ii = size(test,2)-2 : size(test,2) %for 16 laps and reexp
        c = 1;
        for p = 1 : 5
            plot(ii,test(c:c+3,ii),'o','MarkerEdgeColor',PP.T2(p,:),'MarkerFaceColor',PP.T2(p,:))
            c = c +4;
        end
    end
    ylabel('Time spent immobile','FontSize',16)
    title('Time immobile','FontSize',18);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    
    
    %%% Ratio time moving/time immobile
    figure
    c=1;
    test= [];
    invert_time = flipud(ratio_time_moving_immobile(:,2));
    for p = 1 : 5
        test(:,p) = [invert_time(c:c+3); nan(16,1)];
        c = c +4;
    end
    test = [test ratio_time_moving_immobile(:,1) ratio_time_moving_immobile(:,3:4)];
    hold on
    x_labels = {'1 Lap','2 Laps','3 Laps','4 Laps','8 Laps','16 Laps','R-T1','R-T2'}; %set labels for X axis
    boxplot(test,'PlotStyle','traditional','Colors',[0.3 0.3 0.3],'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([1:8]));  % Get the children you need (boxes for first exposure)
    set(boxes,'LineWidth',2); % Set width
    box off
    for ii = 1 : size(test,2)-3 %for each protocol 1 to 8
          plot(ii,test(:,ii),'o','MarkerEdgeColor',PP.T2(6-ii,:),'MarkerFaceColor',PP.T2(6-ii,:))
    end
    for ii = size(test,2)-2 : size(test,2) %for 16 laps and reexp
        c = 1;
        for p = 1 : 5
            plot(ii,test(c:c+3,ii),'o','MarkerEdgeColor',PP.T2(p,:),'MarkerFaceColor',PP.T2(p,:))
            c = c +4;
        end
    end
    ylabel('Ratio time moving/immobile','FontSize',16)
    title('Ratio time moving/immobile','FontSize',18);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    
    tbl = table;
    rats = repmat([1,2,3,4],[1,5])';
    tbl.rats = rats;
    for j = 1 : size(ratio_time_moving_immobile,2)
        tbl.(sprintf('%s','T',num2str(j))) = ratio_time_moving_immobile(:,j);
    end
    meas = table([1 2 3 4]','VariableNames',{'Tracks'});
    rm = fitrm(tbl,'T1-T4~rats','WithinDesign',meas);
    ranovatbl = ranova(rm);
    
    
    %%% Lap moving speed per protocol
    f1 = figure;
    idx = [1 5 9 13 17];
    protocol_lap = [];
    protocol_lap_std = [];
    temp = [];
    cols=[];
    for hh = 1 : 5
        for ii = 1 : length(idx)
            %             temp_mean = mean(lap_behaviour(4).moving_speed(idx(ii):idx(ii)+3,1:7),1,'omitnan');
            %             temp_std = std(lap_behaviour(4).moving_speed(idx(ii):idx(ii)+3,1:7),[],1,'omitnan');
            %             protocol_lap = [protocol_lap; temp_mean];
            %             protocol_lap_std = [protocol_lap_std; temp_std];
                        %             hold on
            %             plot(temp_mean,'LineWidth',3,'Color',PP.T2(ii,:));
            %             x = 1:numel(temp_mean);
            %             shade1 = temp_mean + temp_std;
            %             shade2 = temp_mean - temp_std;
            %             x2 = [x,fliplr(x)];
            %             inBetween = [shade1,fliplr(shade2)];
            %             h=fill(x2,inBetween,PP.T2(ii,:));
            %             set(h,'facealpha',0.2,'LineStyle','none')
            
            temp = [temp lap_behaviour(4).moving_speed(idx(ii):idx(ii)+3,hh)];
        end
        cols = [cols; PP.T2; [0 0 0]];
        temp = [temp nan(size(temp,1),1)];
    end
    boxplot(temp,'PlotStyle','traditional','Color',cols)
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idxs = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes =a(idxs);
    set(boxes,'LineWidth',3); % Set width
    hold on
    c=1;
    for jj = 1 : 5
        for ii = 1 : length(idx)
            arrayfun(@(x) plot(c,lap_behaviour(4).moving_speed(idx(ii)+x,jj),'o','MarkerFaceColor',[.6 .6 .6],'MarkerEdgeColor',[.6 .6 .6],...
                'MarkerSize',8,'Marker',PP.rat_markers{x+1}),[0 1 2 3]);
            if ii < 5
                c =  c+1;
            else
                c = c+2;
            end
        end
    end
    box off;   set(gcf,'Color','w');   
    ylabel('Lap speed (cm/s)');
    set(gca,'XTick',[2.5,8.5,14.5,20.5,25.5],'XTickLabel',{'Lap 1','Lap 2','Lap 3','Lap 4','Lap 5'},'FontSize',14);

    p,h = ranksum(lap_behaviour(4).moving_speed(1:4,2),lap_behaviour(4).moving_speed(17:20,2))
    p,h = ranksum(lap_behaviour(4).moving_speed(1:4,2),lap_behaviour(4).moving_speed(17:20,2))
    [p,~,stats]= kruskalwallis(temp(:,1:5))
    [p,~,stats]= kruskalwallis(temp(:,7:11))
    [p,~,stats]= kruskalwallis(temp(:,13:17))
    [p,~,stats]= kruskalwallis(temp(:,19:23))

    
      %%% Lap moving speed comparison between re-exposures
      f1 = figure;
      idx = [1 5 9 13 17];
      protocol_lap = [];
      protocol_lap_std = [];
      protocol_lap_2 = [];
      protocol_lap_std_2 = [];
      
      for ii = 1 : length(idx)
          temp_mean_RT1 = mean(lap_behaviour(3).moving_speed(idx(ii):idx(ii)+3,1:7),1,'omitnan');
          temp_std_RT1 = std(lap_behaviour(3).moving_speed(idx(ii):idx(ii)+3,1:7),[],1,'omitnan');
          protocol_lap = [protocol_lap; temp_mean_RT1];
          protocol_lap_std = [protocol_lap_std; temp_std_RT1];
          
          temp_mean_RT2 = mean(lap_behaviour(4).moving_speed(idx(ii):idx(ii)+3,1:7),1,'omitnan');
          temp_std_RT2 = std(lap_behaviour(4).moving_speed(idx(ii):idx(ii)+3,1:7),[],1,'omitnan');
          protocol_lap_2 = [protocol_lap_2; temp_mean_RT2];
          protocol_lap_std_2 = [protocol_lap_std_2; temp_std_RT2];
          
          subplot(3,2,ii)
          p1 = plot(temp_mean_RT1,'LineWidth',3,'Color',PP.T2(ii,:));         
          hold on
          x = 1:numel(temp_mean_RT1);
          shade1 = temp_mean_RT1 + temp_std_RT1;
          shade2 = temp_mean_RT1 - temp_std_RT1;
          x2 = [x,fliplr(x)];
          inBetween = [shade1,fliplr(shade2)];
          h=fill(x2,inBetween,PP.T2(ii,:));
          set(h,'facealpha',0.2,'LineStyle','none')
          
          hold on
          p2 = plot(temp_mean_RT2,'LineWidth',3,'Color',PP.T2(ii,:),'LineStyle',':');
          x = 1:numel(temp_mean_RT2);
          shade1 = temp_mean_RT2 + temp_std_RT2 ;
          shade2 = temp_mean_RT2 - temp_std_RT2 ;
          x2 = [x,fliplr(x)];
          inBetween = [shade1,fliplr(shade2)];
          h=fill(x2,inBetween,PP.T2(ii,:));
          set(h,'facealpha',0.2,'LineStyle','none')
          
          box off;   set(gcf,'Color','w');
          ylabel('Lap speed (cm/s)'); xlabel('Lap number')
          title(['Protocol 16x' PP.titles.protocols{1,ii}])
          legend([p1,p2],{'R-T1','R-T2'})
          set(gca,'FontSize',14);
          
          pvals = arrayfun(@(x) ranksum(lap_behaviour(3).moving_speed(idx(ii):idx(ii)+3,x), lap_behaviour(4).moving_speed(idx(ii):idx(ii)+3,x)),1:1:7)

      end

   
    
   %%% Lap moving acceleration per protocol
    f1 = figure;
    idx = [1 5 9 13 17];
    protocol_lap = [];
    protocol_lap_std = [];
    for ii = 1 : length(idx)
            temp_mean = mean(lap_behaviour(4).acceleration2(idx(ii):idx(ii)+3,1:24),1,'omitnan');
            temp_std = std(lap_behaviour(4).acceleration2(idx(ii):idx(ii)+3,1:24),[],1,'omitnan');
            protocol_lap = [protocol_lap; temp_mean];
            protocol_lap_std = [protocol_lap_std; temp_std];
            
            figure(f1)
            hold on
            plot(temp_mean,'LineWidth',3,'Color',PP.T2(ii,:));
            x = 1:numel(temp_mean);
            shade1 = temp_mean + temp_std;
            shade2 = temp_mean - temp_std;
            x2 = [x,fliplr(x)];
            inBetween = [shade1,fliplr(shade2)];
            h=fill(x2,inBetween,PP.T2(ii,:));
            set(h,'facealpha',0.2,'LineStyle','none')
            
    end
    
       %%% Lap ratio moving/immobile per protocol
    f1 = figure;
    idx = [1 5 9 13 17];
    protocol_lap = [];
    protocol_lap_std = [];
    for ii = 1 : length(idx)
            temp_mean = mean(lap_behaviour(4).ratio_time_moving_immobile(idx(ii):idx(ii)+3,1:24),1,'omitnan');
            temp_std = std(lap_behaviour(4).ratio_time_moving_immobile(idx(ii):idx(ii)+3,1:24),[],1,'omitnan');
            protocol_lap = [protocol_lap; temp_mean];
            protocol_lap_std = [protocol_lap_std; temp_std];
            
            figure(f1)
            hold on
            plot(temp_mean,'LineWidth',3,'Color',PP.T2(ii,:));
            x = 1:numel(temp_mean);
            shade1 = temp_mean + temp_std;
            shade2 = temp_mean - temp_std;
            x2 = [x,fliplr(x)];
            inBetween = [shade1,fliplr(shade2)];
            h=fill(x2,inBetween,PP.T2(ii,:));
            set(h,'facealpha',0.2,'LineStyle','none')
            
    end
    
    
    %%% ANIMAL AVERAGE SPEED
     
    idx = [1 5 9 13 17];
    all_tracks = [];
    % each animal average speed
    for ii = 1 : 4
        all_tracks = [all_tracks; reshape(lap_behaviour(1).moving_speed(idx,:),[length(lap_behaviour(1).moving_speed(idx,:))*5,1]);...
            reshape(lap_behaviour(2).moving_speed(idx,:),[length(lap_behaviour(2).moving_speed(idx,:))*5,1]);...
            reshape(lap_behaviour(3).moving_speed(idx,1:24),[length(lap_behaviour(3).moving_speed(idx,1:24))*5,1]);...
            reshape(lap_behaviour(4).moving_speed(idx,1:24),[length(lap_behaviour(4).moving_speed(idx,1:24))*5,1])];
        
        rats_mean_speed(ii) = mean(all_tracks,'omitnan');
        for t  = 1 : 4
            if t < 3
                temp = arrayfun(@(x) lap_behaviour(t).moving_speed(x,:)./rats_mean_speed(ii),idx,'UniformOutput',0);
            else
                temp = arrayfun(@(x) lap_behaviour(t).moving_speed(x,1:24)./rats_mean_speed(ii),idx,'UniformOutput',0);
            end
            rat(ii).(strcat('T',num2str(t))) = arrayfun(@(x) temp{1,x}(~isnan(temp{x})),1:length(temp),'UniformOutput',0);
            rat(ii).(strcat('mean_T',num2str(t))) = cellfun(@mean, rat(ii).(strcat('T',num2str(t))));
        end
        idx = idx + 1;
    end
    
    figure;
    cols = [];
    for r = 1 : 4 %rat
        subplot(2,2,r)
        temp = nan(24,24);
        c=1;
        for k = 1 : 5 %session
            for j = 1 : 4 %track
                temp(1:length(rat(r).(strcat('T',num2str(j))){k}),c)= rat(r).(strcat('T',num2str(j))){k}';
                c = c+1;
            end
            c = c+1;
            cols = [cols; PP.T1; PP.T2(k,:); PP.T1; PP.T2(k,:);[0 0 0]];
        end
        boxplot(temp,'PlotStyle','traditional','Colors', cols)
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        tt = get(a,'tag');   % List the names of all the objects
        idx = find(strcmpi(tt,'box')==1);  % Find Box objects
        boxes =a(idx);
        set(boxes,'LineWidth',3); % Set width
        hold on
        colid =find(~isnan(temp(1,:)));
        for jj = 1 : length(colid)
            plot(colid(jj),temp(~isnan(temp(:,colid(jj))),colid(jj)),'o','MarkerFaceColor',[.6 .6 .6],'MarkerEdgeColor',[.6 .6 .6],'MarkerSize',4)
        end
        ylabel('Normalized track speed')
        box off;   set(gcf,'Color','w');   
        set(gca,'XTick',[2.5,8.5,14.5,20.5,25.5],'XTickLabel',{'16x8','16x4','16x3','16x2','16x1'},'FontSize',14);

    end
    
elseif strcmp(data_type,'speed_data_folders')   %%%%%%%%%%%%%%%%% SPEED DATA PLOTTING

 % Mean running speed per track
    f1 = figure('units','normalized','outerposition',[0 0 1 1]);
    f1.Name = 'Behaviour plots';
    subplot(2,2,1)
    hold on
    x_labels = {'T1','T2','R-T1','R-T2'}; %set labels for X axis
    boxplot(moving_speed,'PlotStyle','traditional','Colors',[0.3 0.3 0.3],'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([1,2,3,4]));  % Get the children you need (boxes for first exposure)
    set(boxes,'LineWidth',2); % Set width
    box off
    for ii = 1 : 4 %for each track
        c = 1;
        for p = 1 : num_sessions
            plot(ii,moving_speed(c:c+num_rats-1,ii),'o','MarkerEdgeColor',PP.T2(p,:),'MarkerFaceColor',PP.T2(p,:))
            c = c + num_rats;
        end
    end
    ylabel('mean running speed','FontSize',16)
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    title('Mean running speed per track','FontSize',18);
    
    % Difference in speed between tracks
    speed_diff = [moving_speed(:,2)-moving_speed(:,1) moving_speed(:,3)-moving_speed(:,2) moving_speed(:,4)-moving_speed(:,3)];
    mean_speed_diff = mean(speed_diff,1);
    std_speed_diff = std(speed_diff,1);
    subplot(2,2,2)
    hold on
    for s = 1  : size(speed_diff,2) %for track diff
        for ii = 1 : size(speed_diff,1) % for each protocol
          if ii <1
              p = 1;
          elseif ii>1 
              p = 2;
%           elseif ii>8 && ii<13
%               p = 3;
%           elseif ii>12 && ii<17
%               p = 4;
%           elseif ii>16 && ii<21
%               p = 5;
          end
          plot(s,speed_diff(ii,s),'o','MarkerEdgeColor',PP.T2(p,:),'MarkerFaceColor',PP.T2(p,:));
          plot(speed_diff(ii,:),'Color',PP.T2(p,:),'LineWidth',0.5);
        end
    end
    plot(mean_speed_diff,'Color','k','LineWidth',3)
    xlim([0.5 3.5])
    xticks([1 2 3])
    xticklabels({'T2 - T1','R-T1 - T2','R-T2 - R-T1'})
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    ylabel({'Difference in running speed'; 'between tracks (cm/s)'},'FontSize',16);
    title('Difference in running speed','FontSize',18);
    
    % Time running
    test=[];
    invert_time = flipud(time_moving(:,1:2));
    for p = 1 : num_sessions
        test = [test, [invert_time(p,:); nan(1,2)]]; %for speed data
    end
    test = [test time_moving(:,3:4)];
    subplot(2,2,3)
    hold on
    x_labels = {'1 Lap','1 Lap+Blocks','16 Laps','16 Laps+Blocks','R-T1','R-T2'}; %set labels for X axis
    boxplot(test,'PlotStyle','traditional','Colors',[0.3 0.3 0.3],'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([1:8]));  % Get the children you need (boxes for first exposure)
    set(boxes,'LineWidth',2); % Set width
    box off
    cols = [PP.T2(5,:);PP.T2(5,:);PP.T1;PP.T1];
    cols_face = [PP.T2(5,:);[1 1 1];PP.T1;[1 1 1]];
    for ii = 1 : size(test,2)-3 %for each protocol 1 to 8
          plot(ii,test(:,ii),'o','MarkerEdgeColor',PP.T2(6-ii,:),'MarkerFaceColor',PP.T2(6-ii,:))
    end
    for ii = size(test,2)-2 : size(test,2) %for 16 laps and reexp
        c = 1;
        for p = 1 : 5
            plot(ii,test(c:c+3,ii),'o','MarkerEdgeColor',PP.T2(p,:),'MarkerFaceColor',PP.T2(p,:))
            c = c +4;
        end
    end
    ylabel('Time spent running','fontsize',16)
    title('Time running','FontSize',18);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    
    % Plot time immobile in the track
     test=[];
    invert_time = flipud(time_immobile(:,1:2));
    for p = 1 : num_sessions
        test = [test, [invert_time(p,:); nan(1,2)]]; %for speed data
    end
    test = [test time_immobile(:,3:4)];
    subplot(2,2,4)
    hold on
    x_labels = {'1 Lap','1 Lap+Blocks','16 Laps','16 Laps+Blocks','R-T1','R-T2'}; %set labels for X axis
    boxplot(test,'PlotStyle','traditional','Colors',[0.3 0.3 0.3],'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([1:8]));  % Get the children you need (boxes for first exposure)
    set(boxes,'LineWidth',2); % Set width
    box off
    % temporarily hard-coded
    plot(1,test(:,1),'o','MarkerEdgeColor',PP.T2(5,:),'MarkerFaceColor',PP.T2(5,:))
    plot(2,test(:,2),'o','MarkerEdgeColor',PP.T2(5,:),'MarkerFaceColor',PP.T2(5,:))
    plot(3,test(:,3),'o','MarkerEdgeColor',PP.T1,'MarkerFaceColor',PP.T1)
    plot(4,test(:,4),'o','MarkerEdgeColor',PP.T1,'MarkerFaceColor',PP.T1)
    plot(5,test(1,5),'o','MarkerEdgeColor',PP.T1,'MarkerFaceColor',PP.T1)
    plot(6,test(1,6),'o','MarkerEdgeColor',PP.T1,'MarkerFaceColor',PP.T1)
    plot(5,test(2,5),'o','MarkerEdgeColor',PP.T2(5,:),'MarkerFaceColor',PP.T2(5,:))
    plot(6,test(2,6),'o','MarkerEdgeColor',PP.T2(5,:),'MarkerFaceColor',PP.T2(5,:))
    ylabel('Time spent immobile','FontSize',16)
    title('Time immobile','FontSize',18);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    
    
    %%% Ratio time moving/time immobile
    figure
    test = [];
    invert_time = flipud(ratio_time_moving_immobile(:,1:2));
    for p = 1 : num_sessions
        test = [test, [invert_time(p,:); nan(1,2)]]; %for speed data
    end
    test = [test ratio_time_moving_immobile(:,3:4)];

    hold on
    x_labels = {'1 Lap','1 Lap+Blocks','16 Laps','16 Laps+Blocks','R-T1','R-T2'}; %set labels for X axis
    boxplot(test,'PlotStyle','traditional','Colors',[0.3 0.3 0.3],'labels',x_labels,...
        'LabelOrientation','horizontal','Widths',0.5);
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idx = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes = a(idx([1:8]));  % Get the children you need (boxes for first exposure)
    set(boxes,'LineWidth',2); % Set width
    box off
    for ii = 1 : size(test,2)-3 %for each protocol 1 to 8
          plot(ii,test(:,ii),'o','MarkerEdgeColor',PP.T2(6-ii,:),'MarkerFaceColor',PP.T2(6-ii,:))
    end
    for ii = size(test,2)-2 : size(test,2) %for 16 laps and reexp
        c = 1;
        for p = 1 : 5
            plot(ii,test(c:c+3,ii),'o','MarkerEdgeColor',PP.T2(p,:),'MarkerFaceColor',PP.T2(p,:))
            c = c +4;
        end
    end
    ylabel('Ratio time moving/immobile','FontSize',16)
    title('Ratio time moving/immobile','FontSize',18);
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',16)
    
    tbl = table;
    rats = repmat([1,2,3,4],[1,5])';
    tbl.rats = rats;
    for j = 1 : size(ratio_time_moving_immobile,2)
        tbl.(sprintf('%s','T',num2str(j))) = ratio_time_moving_immobile(:,j);
    end
    meas = table([1 2 3 4]','VariableNames',{'Tracks'});
    rm = fitrm(tbl,'T1-T4~rats','WithinDesign',meas);
    ranovatbl = ranova(rm);
    
    
    %%% Lap moving speed per protocol
    f1 = figure;
    idx = [1 5 9 13 17];
    protocol_lap = [];
    protocol_lap_std = [];
    temp = [];
    cols=[];
    for hh = 1 : 5
        for ii = 1 : length(idx)
            %             temp_mean = mean(lap_behaviour(4).moving_speed(idx(ii):idx(ii)+3,1:7),1,'omitnan');
            %             temp_std = std(lap_behaviour(4).moving_speed(idx(ii):idx(ii)+3,1:7),[],1,'omitnan');
            %             protocol_lap = [protocol_lap; temp_mean];
            %             protocol_lap_std = [protocol_lap_std; temp_std];
                        %             hold on
            %             plot(temp_mean,'LineWidth',3,'Color',PP.T2(ii,:));
            %             x = 1:numel(temp_mean);
            %             shade1 = temp_mean + temp_std;
            %             shade2 = temp_mean - temp_std;
            %             x2 = [x,fliplr(x)];
            %             inBetween = [shade1,fliplr(shade2)];
            %             h=fill(x2,inBetween,PP.T2(ii,:));
            %             set(h,'facealpha',0.2,'LineStyle','none')
            
            temp = [temp lap_behaviour(4).moving_speed(idx(ii):idx(ii)+3,hh)];
        end
        cols = [cols; PP.T2; [0 0 0]];
        temp = [temp nan(size(temp,1),1)];
    end
    boxplot(temp,'PlotStyle','traditional','Color',cols)
    a = get(get(gca,'children'),'children');   % Get the handles of all the objects
    tt = get(a,'tag');   % List the names of all the objects
    idxs = find(strcmpi(tt,'box')==1);  % Find Box objects
    boxes =a(idxs);
    set(boxes,'LineWidth',3); % Set width
    hold on
    c=1;
    for jj = 1 : 5
        for ii = 1 : length(idx)
            arrayfun(@(x) plot(c,lap_behaviour(4).moving_speed(idx(ii)+x,jj),'o','MarkerFaceColor',[.6 .6 .6],'MarkerEdgeColor',[.6 .6 .6],...
                'MarkerSize',8,'Marker',PP.rat_markers{x+1}),[0 1 2 3]);
            if ii < 5
                c =  c+1;
            else
                c = c+2;
            end
        end
    end
    box off;   set(gcf,'Color','w');   
    ylabel('Lap speed (cm/s)');
    set(gca,'XTick',[2.5,8.5,14.5,20.5,25.5],'XTickLabel',{'Lap 1','Lap 2','Lap 3','Lap 4','Lap 5'},'FontSize',14);

    p,h = ranksum(lap_behaviour(4).moving_speed(1:4,2),lap_behaviour(4).moving_speed(17:20,2))
    p,h = ranksum(lap_behaviour(4).moving_speed(1:4,2),lap_behaviour(4).moving_speed(17:20,2))
    [p,~,stats]= kruskalwallis(temp(:,1:5))
    [p,~,stats]= kruskalwallis(temp(:,7:11))
    [p,~,stats]= kruskalwallis(temp(:,13:17))
    [p,~,stats]= kruskalwallis(temp(:,19:23))

    
      %%% Lap moving speed comparison between re-exposures
      f1 = figure;
      idx = [1 5 9 13 17];
      protocol_lap = [];
      protocol_lap_std = [];
      protocol_lap_2 = [];
      protocol_lap_std_2 = [];
      
      for ii = 1 : length(idx)
          temp_mean_RT1 = mean(lap_behaviour(3).moving_speed(idx(ii):idx(ii)+3,1:7),1,'omitnan');
          temp_std_RT1 = std(lap_behaviour(3).moving_speed(idx(ii):idx(ii)+3,1:7),[],1,'omitnan');
          protocol_lap = [protocol_lap; temp_mean_RT1];
          protocol_lap_std = [protocol_lap_std; temp_std_RT1];
          
          temp_mean_RT2 = mean(lap_behaviour(4).moving_speed(idx(ii):idx(ii)+3,1:7),1,'omitnan');
          temp_std_RT2 = std(lap_behaviour(4).moving_speed(idx(ii):idx(ii)+3,1:7),[],1,'omitnan');
          protocol_lap_2 = [protocol_lap_2; temp_mean_RT2];
          protocol_lap_std_2 = [protocol_lap_std_2; temp_std_RT2];
          
          subplot(3,2,ii)
          p1 = plot(temp_mean_RT1,'LineWidth',3,'Color',PP.T2(ii,:));         
          hold on
          x = 1:numel(temp_mean_RT1);
          shade1 = temp_mean_RT1 + temp_std_RT1;
          shade2 = temp_mean_RT1 - temp_std_RT1;
          x2 = [x,fliplr(x)];
          inBetween = [shade1,fliplr(shade2)];
          h=fill(x2,inBetween,PP.T2(ii,:));
          set(h,'facealpha',0.2,'LineStyle','none')
          
          hold on
          p2 = plot(temp_mean_RT2,'LineWidth',3,'Color',PP.T2(ii,:),'LineStyle',':');
          x = 1:numel(temp_mean_RT2);
          shade1 = temp_mean_RT2 + temp_std_RT2 ;
          shade2 = temp_mean_RT2 - temp_std_RT2 ;
          x2 = [x,fliplr(x)];
          inBetween = [shade1,fliplr(shade2)];
          h=fill(x2,inBetween,PP.T2(ii,:));
          set(h,'facealpha',0.2,'LineStyle','none')
          
          box off;   set(gcf,'Color','w');
          ylabel('Lap speed (cm/s)'); xlabel('Lap number')
          title(['Protocol 16x' PP.titles.protocols{1,ii}])
          legend([p1,p2],{'R-T1','R-T2'})
          set(gca,'FontSize',14);
          
          pvals = arrayfun(@(x) ranksum(lap_behaviour(3).moving_speed(idx(ii):idx(ii)+3,x), lap_behaviour(4).moving_speed(idx(ii):idx(ii)+3,x)),1:1:7)

      end

   
    
   %%% Lap moving acceleration per protocol
    f1 = figure;
    idx = [1 5 9 13 17];
    protocol_lap = [];
    protocol_lap_std = [];
    for ii = 1 : length(idx)
            temp_mean = mean(lap_behaviour(4).acceleration2(idx(ii):idx(ii)+3,1:24),1,'omitnan');
            temp_std = std(lap_behaviour(4).acceleration2(idx(ii):idx(ii)+3,1:24),[],1,'omitnan');
            protocol_lap = [protocol_lap; temp_mean];
            protocol_lap_std = [protocol_lap_std; temp_std];
            
            figure(f1)
            hold on
            plot(temp_mean,'LineWidth',3,'Color',PP.T2(ii,:));
            x = 1:numel(temp_mean);
            shade1 = temp_mean + temp_std;
            shade2 = temp_mean - temp_std;
            x2 = [x,fliplr(x)];
            inBetween = [shade1,fliplr(shade2)];
            h=fill(x2,inBetween,PP.T2(ii,:));
            set(h,'facealpha',0.2,'LineStyle','none')
            
    end
    
       %%% Lap ratio moving/immobile per protocol
    f1 = figure;
    idx = [1 5 9 13 17];
    protocol_lap = [];
    protocol_lap_std = [];
    for ii = 1 : length(idx)
            temp_mean = mean(lap_behaviour(4).ratio_time_moving_immobile(idx(ii):idx(ii)+3,1:24),1,'omitnan');
            temp_std = std(lap_behaviour(4).ratio_time_moving_immobile(idx(ii):idx(ii)+3,1:24),[],1,'omitnan');
            protocol_lap = [protocol_lap; temp_mean];
            protocol_lap_std = [protocol_lap_std; temp_std];
            
            figure(f1)
            hold on
            plot(temp_mean,'LineWidth',3,'Color',PP.T2(ii,:));
            x = 1:numel(temp_mean);
            shade1 = temp_mean + temp_std;
            shade2 = temp_mean - temp_std;
            x2 = [x,fliplr(x)];
            inBetween = [shade1,fliplr(shade2)];
            h=fill(x2,inBetween,PP.T2(ii,:));
            set(h,'facealpha',0.2,'LineStyle','none')
            
    end
    
    
    %%% ANIMAL AVERAGE SPEED
     
    idx = [1 5 9 13 17];
    all_tracks = [];
    % each animal average speed
    for ii = 1 : 4
        all_tracks = [all_tracks; reshape(lap_behaviour(1).moving_speed(idx,:),[length(lap_behaviour(1).moving_speed(idx,:))*5,1]);...
            reshape(lap_behaviour(2).moving_speed(idx,:),[length(lap_behaviour(2).moving_speed(idx,:))*5,1]);...
            reshape(lap_behaviour(3).moving_speed(idx,1:24),[length(lap_behaviour(3).moving_speed(idx,1:24))*5,1]);...
            reshape(lap_behaviour(4).moving_speed(idx,1:24),[length(lap_behaviour(4).moving_speed(idx,1:24))*5,1])];
        
        rats_mean_speed(ii) = mean(all_tracks,'omitnan');
        for t  = 1 : 4
            if t < 3
                temp = arrayfun(@(x) lap_behaviour(t).moving_speed(x,:)./rats_mean_speed(ii),idx,'UniformOutput',0);
            else
                temp = arrayfun(@(x) lap_behaviour(t).moving_speed(x,1:24)./rats_mean_speed(ii),idx,'UniformOutput',0);
            end
            rat(ii).(strcat('T',num2str(t))) = arrayfun(@(x) temp{1,x}(~isnan(temp{x})),1:length(temp),'UniformOutput',0);
            rat(ii).(strcat('mean_T',num2str(t))) = cellfun(@mean, rat(ii).(strcat('T',num2str(t))));
        end
        idx = idx + 1;
    end
    
    figure;
    cols = [];
    for r = 1 : 4 %rat
        subplot(2,2,r)
        temp = nan(24,24);
        c=1;
        for k = 1 : 5 %session
            for j = 1 : 4 %track
                temp(1:length(rat(r).(strcat('T',num2str(j))){k}),c)= rat(r).(strcat('T',num2str(j))){k}';
                c = c+1;
            end
            c = c+1;
            cols = [cols; PP.T1; PP.T2(k,:); PP.T1; PP.T2(k,:);[0 0 0]];
        end
        boxplot(temp,'PlotStyle','traditional','Colors', cols)
        a = get(get(gca,'children'),'children');   % Get the handles of all the objects
        tt = get(a,'tag');   % List the names of all the objects
        idx = find(strcmpi(tt,'box')==1);  % Find Box objects
        boxes =a(idx);
        set(boxes,'LineWidth',3); % Set width
        hold on
        colid =find(~isnan(temp(1,:)));
        for jj = 1 : length(colid)
            plot(colid(jj),temp(~isnan(temp(:,colid(jj))),colid(jj)),'o','MarkerFaceColor',[.6 .6 .6],'MarkerEdgeColor',[.6 .6 .6],'MarkerSize',4)
        end
        ylabel('Normalized track speed')
        box off;   set(gcf,'Color','w');   
        set(gca,'XTick',[2.5,8.5,14.5,20.5,25.5],'XTickLabel',{'16x8','16x4','16x3','16x2','16x1'},'FontSize',14);

    end
    

end
   

% Save
    if strcmp(data_type,'main')
        path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis';
    elseif strcmp(data_type,'speed')
        path = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\Speed Control';
    end
    save([path '\behavioural_data.mat'],'time_immobile','time_moving','moving_speed','speed_diff','lap_behaviour','ratio_time_moving_immobile','-v7.3')


end