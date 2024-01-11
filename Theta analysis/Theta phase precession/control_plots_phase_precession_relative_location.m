function control_plots_phase_precession_relative_location(track)

% Sanity check plots at different time points of theta phase precession extraction code
% Uses output from main code 'phase_precession_relative_location', which is a structure called TPP

load('extracted_phase_precession.mat')
load('extracted_position.mat')
load('extracted_CSC.mat')


track_linear = position.linear(track).linear(~isnan(position.linear(track).linear));
track_times = position.linear(track).timestamps;
track_x = position.x(position.linear(track).clean_track_Indices);
track_y = position.y(position.linear(track).clean_track_Indices);


% For each good cell in the track
for pc = 1 : length(place_fields.track(track).good_cells)
    
    figure % plot place field
    axes('next','add')
    plot(place_fields.track(track).smooth{TPP(track).cell_id(pc)},'k','LineWidth',2)
    plot([0 200],[firing_thresh,firing_thresh],'r--','LineWidth',2)
    plot(firing_idx*max_firing)
    plot(edge_detect_idx*max_firing*0.25)
    text(max(track_linear)-20,firing_thresh+0.1,{'20% max';'firing rate'},...
        'Color','r','FontWeight','bold')
    xlabel('Linearized position (cm)')
    ylabel('Firing rate (Hz)')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
        
    
    %sanity check to ensure the place field have been split properly by
    %direction
    figure
    axes('next','add')
    plot(track_times,track_linear)
    plot(track_times,smoothed_pos)
    plot(xlim,[pc_bound(1) pc_bound(1)],'r--')
    plot(xlim,[pc_bound(2) pc_bound(2)],'r--')
    text(max(track_times)+1, pc_bound(1)+5,'place field',...
        'Color','r','FontWeight','bold','Rotation',90)
    area(track_times, pf_idx*230,'facecolor','k','facealpha',0.3,'LineStyle','none')
    area(track_times ,direction1*200,'facecolor','g','facealpha',0.4,'LineStyle','none')
    area(track_times,direction2*200,'facecolor','c','facealpha',0.4,'LineStyle','none')
    text(max(track_times)-35,max(track_linear)+40,'all place field entries','Color',[0.2 0.2 0.2],'FontSize',12,'FontWeight','bold')
    text(max(track_times)-35,max(track_linear)+30,'place field entries in direction 1','Color','g','FontSize',12,'FontWeight','bold')
    text(max(track_times)-35,max(track_linear)+20,'place field entries in direction 2','Color','c','FontSize',12,'FontWeight','bold')
    xlabel('Time (s)')
    ylabel('Linearized position (cm)')
    title('Place field extraction')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    
    
    %sanity check to ensure the spike selection within place fields works
    figure
    axes('next','add')
    plot(track_times,track_linear)
    plot(track_times,smoothed_pos)
    plot(xlim,[pc_bound(1) pc_bound(1)],'r--')
    plot(xlim,[pc_bound(2) pc_bound(2)],'r--')
    text(max(track_times)+1, pc_bound(1)+5,'place field',...
        'Color','r','FontWeight','bold','Rotation',90)
    area(track_times,pf_idx*230,'facecolor','k','facealpha',0.3,'LineStyle','none')
    area(track_times,direction1*200,'facecolor','g','facealpha',0.4,'LineStyle','none')
    area(track_times,direction2*200,'facecolor','c','facealpha',0.4,'LineStyle','none')
    raster_plot(clusters.spike_times(place_cell_times > track_times(1) & place_cell_times < track_times(end)),pc_bound(1)+(pc_bound(2)-pc_bound(1))/2-(0.5*(pc_bound(2)-pc_bound(1))/5),'k',(pc_bound(2)-pc_bound(1))/5) % all spikes
    raster_plot(place_cell_times_track(dir1_test),pc_bound(2)-(pc_bound(2)-pc_bound(1))/7-(0.5*(pc_bound(2)-pc_bound(1))/5),'g',(pc_bound(2)-pc_bound(1))/5) % spikes in direction 1 (only during running)
    raster_plot(place_cell_times_track(dir2_test),pc_bound(1)+(pc_bound(2)-pc_bound(1))/7-(0.5*(pc_bound(2)-pc_bound(1))/5),'c',(pc_bound(2)-pc_bound(1))/5) % spikes in direction 2 (only during running)
    xlabel('Time (s)')
    ylabel('Linearized position (cm)')
    title('Place field extraction')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    
    
    
    %% plot the phase precession over position - plot 2 cycles for clarity
    figure
    % recombine both directions
    relative_positions = [TPP(track).relative_spike_positions_1{pc}; TPP(track).relative_spike_positions_2{pc}];
    spike_phase        = [TPP(track).spike_phases_1{pc}; TPP(track).spike_phases_2{pc}];
    
    plot([relative_positions;relative_positions],[rad2deg(spike_phase)+180;rad2deg(spike_phase)+180+360],...
        'Marker','o','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',3,'LineStyle','none')
    xlabel('Relative position')
    ylabel('Phase (degrees)')
    set(findall(gcf,'-property','FontSize'),'FontSize',16)
    
    
    
    
    
    
    
    
end




end