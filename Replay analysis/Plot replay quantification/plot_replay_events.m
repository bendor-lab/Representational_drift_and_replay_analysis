


function plot_replay_events(significant_replay_events,place_fields_BAYESIAN,events,track)

load significant_replay_events_wcorr.mat
load extracted_place_fields_BAYESIAN.mat
load extracted_position.mat
load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis\extracted_replay_plotting_info.mat')

color = flipud(bone);
%events = [58,25,26,13,66];
%events = 1:40;
t=track;

events = significant_replay_events.track(t).ref_index([7,8]);    
%%
%events_idx= find(significant_replay_events.track(2).event_times > position.linear(2).timestamps(1) & significant_replay_events.track(2).event_times < position.linear(2).timestamps(end));
%events= significant_replay_events.track(t).ref_index(events_idx);   
count = 1;
figure;
for i = 1 : length(events)
    
    struct_id = find(significant_replay_events.track(t).ref_index == events(i));
    
    spikes = []; units = []; all_ids = [];
    spikes = significant_replay_events.track(t).spikes{struct_id}(:,2); % sorted timestamps
    spikes_ids{i} = significant_replay_events.track(t).spikes{struct_id}(:,1);
    spike_id_sorted = NaN(size(spikes));
    for ii = 1 : length(place_fields_BAYESIAN.track(t).sorted_good_cells)
        idx= find(significant_replay_events.track(t).spikes{struct_id}(:,1) == place_fields_BAYESIAN.track(t).sorted_good_cells(ii));
         if ~isempty(idx)
             spike_id_sorted(idx)=ii;
         end
    end
    index=find(isnan(spike_id_sorted));
    spike_id_sorted(index)=[];
    spike_times_sorted = spikes;
    spike_times_sorted(index)=[];
    [~,~,spike_id2_sorted]=unique(spike_id_sorted);
      
    ax(count) = subplot(4,6,count);
    %raster_plot(spikes,all_ids,[],1)
    raster_plot(spike_times_sorted,spike_id2_sorted,[],1);
    xlabel('Time'); ylabel('Units')
    %yticks([1: length(units)])
    yticklabels(units)
    ax(count).FontSize = 14;
    title(['Num time bins: ' num2str(length(significant_replay_events.track(t).time_edges{struct_id}))])
    
    ax(count+1) = subplot(4,6,count+1);
    imagesc(flipud(significant_replay_events.track(t).decoded_position{struct_id}));
    %imagesc(decoded_replay_events(2).replay_events(69).decoded_position)
    colormap(color)
    xlabel('Time'); ylabel('Decoded position')
    ax(count+1).FontSize = 14;
    title(['Num time bins: ' num2str(size(significant_replay_events.track(t).decoded_position{struct_id},2))])
  
    
%     if spikes > min(significant_replay_events.track(t).time_edges{struct_id}) &...
%             spikes < max(significant_replay_events.track(t).time_edges{struct_id})
%         disp('spikes inside time edges')
%     end
    
        
    count = count+2;
end


    
%     for j=1:length(data.place_fields_BAYESIAN.track)
%     spike_times_sorted{j}=spike_times;
%     spike_id_sorted{j}=NaN(size(spike_id));
%     for i=1:length(data.place_fields_BAYESIAN.track(j).sorted_good_cells)
%         a=find(spike_id==data.place_fields_BAYESIAN.track(j).sorted_good_cells(i));
%         if ~isempty(a)
%         spike_id_sorted{j}(a)=i;
%         end
%     end
%     index=find(isnan(spike_id_sorted{j}));
%     spike_id_sorted{j}(index)=[];
%     spike_times_sorted{j}(index)=[];
%     [~,~,spike_id2_sorted{j}]=unique(spike_id_sorted{j});
%     subplot(6,6,rr+12)
%     hold on;
%     c = ['b','m','g','r'];
%      raster_plot(spike_times_sorted{j},(j-1)*number_of_units+spike_id2_sorted{j},c(j),1);
%    end
%     
end
function raster_plot(x,y,c,h)
x2(1:3:length(x)*3)=x;
x2(2:3:length(x)*3)=x;
x2(3:3:length(x)*3)=NaN;
y2(1:3:length(x)*3)=y;
y2(2:3:length(x)*3)=y+h;
y2(3:3:length(x)*3)=NaN;
if isempty(c)
     c = [0.6 0.6 0.6];
    plot(x2,y2,'Color',c,'LineWidth',1);
elseif isnumeric(c) %colormap
    p = 1;
    for i = 1 : 3 :  length(x2)
        plot(x2(i:i+2),y2(i:i+2),'Color',c(p,:),'LineWidth',1.3);
        hold on
        p = p + 1;
    end
elseif isstring(c) %single color
    plot(x2,y2,'Color',c,'LineWidth',2);
end
end


