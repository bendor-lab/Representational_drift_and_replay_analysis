function Ch1_place_field_stability_example_figure


load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Q-BLU\Q-BLU_Day8_16x8\extracted_lap_place_fields.mat')
load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Q-BLU\Q-BLU_Day8_16x8\extracted_position.mat')

figure;
c=1;
t = 3;
y_vector=[];
col = parula(length(lap_place_fields(t).Complete_Lap{1,12}.sorted_good_cells));
for ii=1:length(lap_place_fields(t).Complete_Lap{1,12}.sorted_good_cells)
    %plot sorted
    matrix=[];
    normalized_matrix=[];
    
    matrix(ii,:)= lap_place_fields(t).Complete_Lap{1,12}.smooth{lap_place_fields(t).Complete_Lap{1,12}.sorted_good_cells(ii)};
    normalized_matrix(ii,:)=(matrix(ii,:)-min(matrix(ii,:)))/(max(matrix(ii,:))-min(matrix(ii,:)));
    
    plfield_row= normalized_matrix(ii,:)+(1.5*ii-1);
    plot(1:length(plfield_row),plfield_row,'k'); hold on;
    x2 = [1:length(plfield_row), fliplr(1:length(plfield_row))];
    inBetween = [(1.5*ii-1)*ones(size(plfield_row)), fliplr(plfield_row)];
    fill(x2, inBetween,col(ii,:));
    y_vector= [y_vector, 1.5*ii-1];
end

xlim([0 size(normalized_matrix,2)+2]);
ylim([0 max(y_vector)+1.2]);
yt=lap_place_fields(t).Complete_Lap{1,12}.sorted_good_cells;
set(gca,'ytick',y_vector);
set(gca,'yticklabel',yt);
ylabel('Unit ID');
xlabel('sorted linearized position (bins)');


figure;
c=1;
t = 1;
y_vector=[];
col = parula(length(lap_place_fields(t).Complete_Lap{1,1}.sorted_good_cells));
for ii=1:length(lap_place_fields(t).Complete_Lap{1,1}.sorted_good_cells)
    %plot sorted
    matrix=[];
    normalized_matrix=[];
    
    matrix(ii,:)= lap_place_fields(t).Complete_Lap{1,1}.smooth{lap_place_fields(t).Complete_Lap{1,1}.sorted_good_cells(ii)};
    normalized_matrix(ii,:)=(matrix(ii,:)-min(matrix(ii,:)))/(max(matrix(ii,:))-min(matrix(ii,:)));
    
    plfield_row= normalized_matrix(ii,:)+(1.5*ii-1);
    plot(1:length(plfield_row),plfield_row,'k'); hold on;
    x2 = [1:length(plfield_row), fliplr(1:length(plfield_row))];
    inBetween = [(1.5*ii-1)*ones(size(plfield_row)), fliplr(plfield_row)];
    fill(x2, inBetween,col(ii,:));
    y_vector= [y_vector, 1.5*ii-1];
end

xlim([0 size(normalized_matrix,2)+2]);
ylim([0 max(y_vector)+1.2]);
yt=lap_place_fields(t).Complete_Lap{1,1}.sorted_good_cells;
set(gca,'ytick',y_vector);
set(gca,'yticklabel',yt);
ylabel('Unit ID');
xlabel('sorted linearized position (bins)');



figure;
c=1;
t = 1;
y_vector=[];
col = parula(length(lap_place_fields(t).Complete_Lap{1,2}.sorted_good_cells));
for ii=1:length(lap_place_fields(t).Complete_Lap{1,2}.sorted_good_cells)
    %plot sorted
    matrix=[];
    normalized_matrix=[];
    
    matrix(ii,:)= lap_place_fields(t).Complete_Lap{1,2}.smooth{lap_place_fields(t).Complete_Lap{1,2}.sorted_good_cells(ii)};
    normalized_matrix(ii,:)=(matrix(ii,:)-min(matrix(ii,:)))/(max(matrix(ii,:))-min(matrix(ii,:)));
    
    plfield_row= normalized_matrix(ii,:)+(1.5*ii-1);
    plot(1:length(plfield_row),plfield_row,'k'); hold on;
    x2 = [1:length(plfield_row), fliplr(1:length(plfield_row))];
    inBetween = [(1.5*ii-1)*ones(size(plfield_row)), fliplr(plfield_row)];
    fill(x2, inBetween,col(ii,:));
    y_vector= [y_vector, 1.5*ii-1];
end
xlim([0 size(normalized_matrix,2)+2]);
ylim([0 max(y_vector)+1.2]);


figure
for xx = 1 : 12
subplot(3,4,xx)
t = 1;
y_vector=[];
col = parula(length(lap_place_fields(t).Complete_Lap{1,12}.sorted_good_cells));
for ii=1:length(lap_place_fields(t).Complete_Lap{1,12}.sorted_good_cells)
    %plot sorted
    matrix=[];
    normalized_matrix=[];
    
    matrix(ii,:)= lap_place_fields(t).Complete_Lap{1,xx}.smooth{lap_place_fields(t).Complete_Lap{1,12}.sorted_good_cells(ii)};
    normalized_matrix(ii,:)=(matrix(ii,:)-min(matrix(ii,:)))/(max(matrix(ii,:))-min(matrix(ii,:)));
    
    plfield_row= normalized_matrix(ii,:)+(1.5*ii-1);
    plot(1:length(plfield_row),plfield_row,'k'); hold on;
    x2 = [1:length(plfield_row), fliplr(1:length(plfield_row))];
    inBetween = [(1.5*ii-1)*ones(size(plfield_row)), fliplr(plfield_row)];
    fill(x2, inBetween,col(ii,:));
    y_vector= [y_vector, 1.5*ii-1];
end
xlim([0 size(normalized_matrix,2)+2]);
ylim([0 max(y_vector)+1.2]);
yt=lap_place_fields(t).Complete_Lap{1,12}.sorted_good_cells;
% set(gca,'ytick',y_vector);
% set(gca,'yticklabel',yt);
% ylabel('Unit ID');
% xlabel('sorted linearized position (bins)');
end


figure;
plot(position.linear(2).timestamps,position.linear(2).linear(position.linear(2).clean_track_LogicalIndices),'Color',[.2 .0 0.6],'LineWidth',2) 
box off
axis off
set(gcf,'color','w')



end