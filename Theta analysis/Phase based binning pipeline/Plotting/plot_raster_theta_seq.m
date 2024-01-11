
function plot_raster_theta_seq(track)

    load extracted_position.mat
    load('extracted_clusters.mat');
    load('extracted_place_fields.mat');
    load('extracted_CSC.mat');
    load('estimated_position.mat');

    figure
    t=track;

    % PLOT RAW AND ESTIMATED POSITION
    ax(1)= subplot(3,1,1);

    time_center = estimated_position(t).run_time_centered(estimated_position(t).run_time_centered> position.linear(t).timestamps(1) & estimated_position(t).run_time_centered < position.linear(t).timestamps(end));
    run = estimated_position(t).run(:,estimated_position(t).run_time_centered > position.linear(t).timestamps(1) & estimated_position(t).run_time_centered < position.linear(t).timestamps(end));
    imagesc(time_center,estimated_position(t).position_bin_centres,run)
    colormap(flipud(bone))
    hold on
    plot(position.linear(t).timestamps, position.linear(t).linear(position.linear(t).clean_track_LogicalIndices),'LineWidth',2,'Color','b')

    % PLOT THETA
    ax(2)= subplot(3,1,2);

    CSC_time = CSC(4).CSCtime(CSC(t).CSCtime > position.linear(t).timestamps(1) & CSC(t).CSCtime < position.linear(t).timestamps(end));
    CSC_theta = CSC(4).theta(CSC(t).CSCtime > position.linear(t).timestamps(1) & CSC(t).CSCtime < position.linear(t).timestamps(end));
    plot(CSC_time,CSC_theta,'LineWidth',3,'Color','b')

    % PLOT RASTER PLOT
    ax(3)= subplot(3,1,3);

    spike_index=find(clusters.spike_times > position.linear(t).timestamps(1)& clusters.spike_times < position.linear(t).timestamps(end));
    spike_times=clusters.spike_times(spike_index)';
    spike_id=clusters.spike_id(spike_index);
    number_of_units=max(place_fields.track(t).sorted_good_cells);
    index=[];
    spike_id_sorted=[];
    spike_id_unique=[];
    spike_times_sorted=[];
    spike_times_unique=[];
    for j=1:length(place_fields.track(t).sorted_good_cells)
        index=find(spike_id==place_fields.track(t).sorted_good_cells(j));
        spike_id_sorted=[spike_id_sorted j*ones(1,length(index))];
        spike_times_sorted=[spike_times_sorted spike_times(index)];
    end

    raster_plot(spike_times_sorted,spike_id_sorted,[0.3 0.3 0.3],10);
    set(ax(3),'xdir','normal','ydir','reverse')
    
    linkaxes([ax(1) ax(2) ax(3)],'x')
end


function raster_plot(x,y,c,h)
    x2(1:3:length(x)*3)=x;
    x2(2:3:length(x)*3)=x;
    x2(3:3:length(x)*3)=NaN;
    y2(1:3:length(x)*3)=y;
    y2(2:3:length(x)*3)=y+h;
    y2(3:3:length(x)*3)=NaN;
    if isempty(c)
        plot(x2,y2);
    else
        plot(x2,y2,'Color',c,'LineWidth',2);
    end
end