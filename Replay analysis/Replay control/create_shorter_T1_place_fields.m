% CREATE NEW PLACE FIELDS FOR TRACK 1
% MH_2020
% Takes the rate maps of T1 for the same number of laps than for T2 (e.g. If T2 is 2 Laps, then it takes ratemaps after 2
% laps in T1). Depending on the control that is being run, it will modify general parametrs of the session, such as all tracks good cells, unique
% cells, etc.


function create_shorter_T1_place_fields(control_type,lap_order)

load('extracted_place_fields_BAYESIAN.mat')
load('extracted_clusters.mat')
load('extracted_position.mat')
load extracted_laps.mat

parameters = list_of_parameters;

if strcmp(control_type,'Stability')
    % In this control we keep both the replay events and the good cells from the orgininal data set (i.e. in replay_decoding, use original good cells
    % to find spikes inside replay event). This control tells us a bout place field stability, that is, how well can you decode with earlier cells in
    % the exposure. The analysis would be equivalent to adding a 5th track to decode.
    
    
    % Get the new place fiels for T1 - Use place fields from the same number of
    % laps than T2 (e.g. 16x2 - use place fields of T1 after 2 laps)
    folder_name = pwd;
    T2_laps = str2num(folder_name(end));
    new_T1_place_fields = get_lap_place_fields(1,1,T2_laps,'Y','complete'); % re-calculate place fields in T1
    
    % Change name variable for compatibility
    new_T1_place_fields.mean_rate_track = new_T1_place_fields.mean_rate_lap;
    
    % Remove extra fields that are not in the original place_fields.Track structure
    new_T1_place_fields = rmfield(new_T1_place_fields,'interneurons');
    new_T1_place_fields = rmfield(new_T1_place_fields,'pyramidal_cells');
    new_T1_place_fields = rmfield(new_T1_place_fields,'other_cells');
    new_T1_place_fields = rmfield(new_T1_place_fields,'mean_rate_lap');
    new_T1_place_fields = rmfield(new_T1_place_fields,'mean_rate');
    
    % Calculate missing fields
    for j = 1 : length(new_T1_place_fields.spike_hist)
        new_T1_place_fields.mean_rate_session(j) = length(find(clusters.spike_id==j))/(position.t(end)-position.t(1)); %mean firing rate
    end
    new_T1_place_fields.unique_cells = setdiff(new_T1_place_fields.good_cells,place_fields_BAYESIAN.good_place_cells);
    
    % Replace T1 place fields by new ones
    place_fields_BAYESIAN.track(1) = new_T1_place_fields;  
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(control_type,'short_exposure')
    % In this control, both the replay events and good cells will be changed, by replacing the T1 good cells for the new T1 good cells (which will be
    % good cells after running X laps, where X is the same amount of laps run in T2). That means that replay events won't be including cells that will
    % only appear in later laps in T1. This control tries to simulate what would have happened if there was the same number of laps in both tracks.
    
    load('extracted_waveforms.mat')
    
    % Get the new place fiels for T1 - Use place fields from the same number of
    % laps than T2 (e.g. 16x2 - use place fields of T1 after 2 laps)
    foldername = strsplit(pwd,'\');
    folder_name = foldername{9};
    T2_laps = str2num(folder_name(end));
    
    % When chosing the lap starting from first lap in T1
    if strcmp(lap_order,'first')
        new_T1_place_fields = get_lap_place_fields(1,1,T2_laps,'Y'); % re-calculate place fields in T1
        % When chosing the lap starting from last lap in T1
    elseif strcmp(lap_order,'last')
        if lap_times(1).number_completeLaps < 16
            new_T1_place_fields = get_lap_place_fields(1,lap_times(1).number_completeLaps-T2_laps,lap_times(1).number_completeLaps,'Y'); % re-calculate place fields in T1
        else
            new_T1_place_fields = get_lap_place_fields(1,16-T2_laps,16,'Y'); % re-calculate place fields in T1
        end
    end
    
    % Change name variable for compatibility
    new_T1_place_fields.mean_rate_track = new_T1_place_fields.mean_rate_lap;
    
    % Remove extra fields that are not in the original place_fields.Track structure
    new_T1_place_fields = rmfield(new_T1_place_fields,'interneurons');
    new_T1_place_fields = rmfield(new_T1_place_fields,'pyramidal_cells');
    new_T1_place_fields = rmfield(new_T1_place_fields,'other_cells');
    new_T1_place_fields = rmfield(new_T1_place_fields,'mean_rate_lap');
    new_T1_place_fields = rmfield(new_T1_place_fields,'mean_rate');
    
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
    
end


save extracted_place_fields_BAYESIAN place_fields_BAYESIAN;


end