% CREATE NEW PLACE FIELDS FOR EACH LAP OF TRACK 1 AND MERGES WITH PLACE FIELD STRUCTURE 
% MH_2020
% Takes the rate maps of each lap in T1 and uses them to replace T1 ratemap calculated in the general place field structure.
% Modifies general parameters of the session, such as all tracks good cells, unique cells, etc.
% Code meant to be use in control for 1LAP replay - pretends that there is only 1 lap in T1

function create_1LAP_T1_place_fields(lap,rat_folder,main_save_folder,lap_save_folder)

load([rat_folder '\extracted_place_fields_BAYESIAN.mat'])
load([main_save_folder '\extracted_clusters.mat'])
load([rat_folder '\extracted_lap_place_fields_BAYESIAN.mat'])
load([main_save_folder '\extracted_waveforms.mat'])
load([main_save_folder '\extracted_position.mat'])

parameters = list_of_parameters;

% In this control, both the decoded replay events and good cells will be changed, by replacing the T1 good cells for the new T1 good cells (which will be
% good cells after running X laps, where X is the same amount of laps run in T2). That means that replay events won't be including cells that will
% only appear in later laps in T1. This control tries to simulate what would have happened if there was the same number of laps in both tracks.

new_T1_place_fields = lap_place_fields_BAYESIAN(1).Complete_Lap{1,lap};

% Change name variable for compatibility
new_T1_place_fields.mean_rate_track = new_T1_place_fields.mean_rate_lap;

% Remove extra fields that are not in the original place_fields.Track structure
new_T1_place_fields = rmfield(new_T1_place_fields,'interneurons');
new_T1_place_fields = rmfield(new_T1_place_fields,'pyramidal_cells');
new_T1_place_fields = rmfield(new_T1_place_fields,'other_cells');
new_T1_place_fields = rmfield(new_T1_place_fields,'mean_rate_lap');

% Calculate missing fields
for j = 1 : length(new_T1_place_fields.spike_hist)
    new_T1_place_fields.mean_rate_session(j) = length(find(clusters.spike_id==j))/(position.t(end)-position.t(1)); %mean firing rate
end

% Re-calculate general fields with new place fields (e.g. good cells, unique cells, etc)
good_place_cells=[]; track=[];
for track_id = 1 : length(position.linear) %good cells classfication
    if track_id == 1
        good_place_cells = [good_place_cells new_T1_place_fields.sorted_good_cells];
        track =[track track_id*ones(size(new_T1_place_fields.sorted_good_cells))];
    else
        good_place_cells = [good_place_cells place_fields_BAYESIAN.track(track_id).sorted_good_cells];
        track =[track track_id*ones(size(place_fields_BAYESIAN.track(track_id).sorted_good_cells))];
    end
end
place_fields_BAYESIAN.good_place_cells = unique(good_place_cells);

good_place_cells_LIBERAL=[];
for track_id=1:length(position.linear) %good cells (liberal threshold) classfication
    if track_id == 1
        good_place_cells_LIBERAL = [good_place_cells_LIBERAL new_T1_place_fields.sorted_good_cells_LIBERAL];
    else
        good_place_cells_LIBERAL = [good_place_cells_LIBERAL place_fields_BAYESIAN.track(track_id).sorted_good_cells_LIBERAL];
    end
end
place_fields_BAYESIAN.good_place_cells_LIBERAL = unique(good_place_cells_LIBERAL);

% cells that are unique for each track
unique_cells=[];
for track_id = 1:length(position.linear)
    if track_id == 1
        new_T1_place_fields.unique_cells = setdiff(good_place_cells(track==track_id),good_place_cells(track~=track_id),'stable');
        unique_cells = [unique_cells, new_T1_place_fields.unique_cells];
    else
        place_fields_BAYESIAN.track(track_id).unique_cells = setdiff(good_place_cells(track==track_id),good_place_cells(track~=track_id),'stable');
        unique_cells = [unique_cells, place_fields_BAYESIAN.track(track_id).unique_cells];
    end
end
place_fields_BAYESIAN.unique_cells = unique_cells;  % all cells that have good place fields only on a single track

% putative pyramidal cells classification:  pyramidal cells that pass the 'Pyramidal type' threshold (but not need to be place cells)
putative_pyramidal_cells = find(place_fields_BAYESIAN.mean_rate <= parameters.max_mean_rate);

% Run threshold on pyramidal cells: half-width amplitude
if ~isempty(allclusters_waveform)
    PC_indices = [allclusters_waveform.half_width] > parameters.half_width_threshold; % cells that pass treshold of pyramidal cell half width
    pyramidal_cells = [allclusters_waveform(PC_indices).converted_ID];
end
place_fields_BAYESIAN.pyramidal_cells = intersect(putative_pyramidal_cells,pyramidal_cells);
place_fields_BAYESIAN.pyramidal_cells=unique(place_fields_BAYESIAN.pyramidal_cells);

%interneurons classfication
interneurons = find(place_fields_BAYESIAN.mean_rate > parameters.max_mean_rate);
place_fields_BAYESIAN.interneurons = interneurons;

other_cells = setdiff(1:max(clusters.id_conversion(:,1)),good_place_cells,'stable'); %find the excluded putative pyramidal cells
place_fields_BAYESIAN.other_cells = setdiff(other_cells,interneurons,'stable'); %remove also the interneurons

% Replace T1 place fields by new ones
place_fields_BAYESIAN.track(1) = new_T1_place_fields;

save([main_save_folder '\extracted_place_fields_BAYESIAN.mat'],'place_fields_BAYESIAN','-7.3');
save([lap_save_folder '\extracted_place_fields_BAYESIAN.mat'],'place_fields_BAYESIAN','-7.3');



end