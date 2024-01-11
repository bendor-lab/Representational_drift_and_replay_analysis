% CALULATES AVERAGE THETA CYCLE PER TRACK AND DIRECTION
% MH 2020
% For each direction and track, gets decoded theta windows and centres to the actual position of the animal at the trough. Then creates a smaller
% window of 100ms around the trough and centres the decoded position around it. Finally average of all centered theta windows.
% INPUTS:
    % decoded_thetaSeq - uses decoded theta sequences that have passed velocity and number of active units thresholds. 
    %                   If empty, loads the file in the folder
    % thresholded_decoded_thetaSeq_option - 1 if using decoded theta sequences that have passed velocity, number of active units and
    %                   position threshold.
    
function [centered_averaged_thetaSeq,centered_averaged_CONCAT_thetaSeq] = averaged_concat_theta_cycle(decoded_thetaSeq,concat_option)

load extracted_position.mat
load extracted_directional_place_fields.mat
if  isempty(decoded_thetaSeq)
    load Theta\decoded_theta_sequences.mat
end
centered_averaged_CONCAT_thetaSeq = [];

if concat_option == 1
    % For visualization purposes, create a structure concatenating 3 cycles together
    fields = fieldnames(decoded_thetaSeq);
    fields = fields(cellfun(@(s) isempty(strmatch ('phase', s)), fieldnames(decoded_thetaSeq)));   
    for d = 1 : length(fields) % for each direction
        for t = 1 : length(decoded_thetaSeq.(sprintf('%s','direction',num2str(d)))) % for each track
            a = {decoded_thetaSeq.(sprintf('%s','direction',num2str(d)))(t).theta_sequences(:).decoded_position};
            A = a(bsxfun(@plus,(1:3),(0:1:length(a)-3)')); %concatenate 3 cycles together, overlapping every two (123,234,345..)
            if length(a) >3
                cycle_troughs =  [decoded_thetaSeq.(sprintf('%s','direction',num2str(d)))(t).theta_sequences(2:length(A)+1).theta_cycle_trough_time];%keep time of central cycle trough
                cycle_peaks =  [decoded_thetaSeq.(sprintf('%s','direction',num2str(d)))(t).theta_sequences(2:length(A)+1).theta_cycle_peaks_times];%keep time of central cycle peaks
            elseif length(a) <= 3 %if there are less than 3 cycles in this track keep the middle trough
                cycle_troughs = [decoded_thetaSeq.(sprintf('%s','direction',num2str(d)))(t).theta_sequences(ceil(median(1:length(a)))).theta_cycle_trough_time];
                cycle_peaks =  [decoded_thetaSeq.(sprintf('%s','direction',num2str(d)))(t).theta_sequences(ceil(median(1:length(a)))).theta_cycle_peaks_times];
            end
            for i = 1 : size(A,1)
                concat_cycles.(sprintf('%s','direction',num2str(d)))(t).theta_sequences(i).decoded_position = cat(2,A{i,:}); %merge together each 3 cycles in a row
                concat_cycles.(sprintf('%s','direction',num2str(d)))(t).theta_sequences(i).theta_cycle_trough_time = cycle_troughs(i);%keep time of central cycle trough
                concat_cycles.(sprintf('%s','direction',num2str(d)))(t).theta_sequences(i).theta_cycle_peaks_times = cycle_peaks(i);%keep time of central cycle peaks/edges
            end
            clear a A cycle_troughs cycle_peaks
        end
    end
end

%Centre theta sequences based on animal's current position
centered_averaged_thetaSeq = centre_thetaseq_animal_position(decoded_thetaSeq,position,directional_place_fields);
if concat_option == 1
    centered_averaged_CONCAT_thetaSeq = centre_thetaseq_animal_position(concat_cycles,position,directional_place_fields);
end
clear directional_place_fields

% Checks if all tracks are facing same direction at the start of run (i.e. which way the animal is facing the room).
% If that's the case, in extracted_laps, all tracks' initial directions should be -1 or 1. 
% If needed to be corrected, will assume that first initial direction has to be -1, and 
% will swap directions on that track (direction 1 will be direction 2, and viceversa)
curr_path = pwd;
load([curr_path '\extracted_laps.mat']) 
fields = fieldnames(centered_averaged_thetaSeq);
for d = 1 : length(fields)
    [centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(:).direction_swapped] = deal(0); %preallocate
    if concat_option == 1
        [centered_averaged_CONCAT_thetaSeq.(sprintf('%s',fields{d}))(:).direction_swapped] = deal(0);
    end
end
tracks_initial_dir = sum([lap_times(:).initial_dir]);
if tracks_initial_dir ~= -length(centered_averaged_thetaSeq.(sprintf('%s',fields{1}))) || tracks_initial_dir ~= length(centered_averaged_thetaSeq.(sprintf('%s',fields{1})))
    for t = 1 : length(centered_averaged_thetaSeq.(sprintf('%s',fields{1}))) 
        if lap_times(t).initial_dir ~= -1 & ~isempty(centered_averaged_thetaSeq.(sprintf('%s',fields{1}))(t).thetaseq) % if different initial direction to the other tracks, swap directions for this track
            temp_rep = centered_averaged_thetaSeq.direction2(t);
            if ~isfield(centered_averaged_thetaSeq,'direction1')
                centered_averaged_thetaSeq.direction1(t).thetaseq = struct;
                centered_averaged_thetaSeq.direction1(t).direction_swapped = struct;
                centered_averaged_thetaSeq.direction2(t).thetaseq = [];
                centered_averaged_thetaSeq.direction2(t).direction_swapped = [];
            else
                centered_averaged_thetaSeq.direction2(t) = centered_averaged_thetaSeq.direction1(t);
                centered_averaged_thetaSeq.direction2(t).direction_swapped = 1; %change to 1 to indicate directions for this track have been swapped
            end
            centered_averaged_thetaSeq.direction1(t) = temp_rep;
            centered_averaged_thetaSeq.direction1(t).direction_swapped = 1; %change to 1 to indicate directions for this track have been swapped
            if concat_option == 1
                % Repeat for concatenated structure
                temp_rep_concat = centered_averaged_CONCAT_thetaSeq.direction2(t);
                centered_averaged_CONCAT_thetaSeq.direction2(t) = centered_averaged_CONCAT_thetaSeq.direction1(t);
                if ~isfield(centered_averaged_CONCAT_thetaSeq,'direction1')
                    centered_averaged_CONCAT_thetaSeq.direction1(t).thetaseq = struct;
                    centered_averaged_CONCAT_thetaSeq.direction1(t).direction_swapped = struct;
                    centered_averaged_CONCAT_thetaSeq.direction2(t).thetaseq = struct;
                    centered_averaged_CONCAT_thetaSeq.direction2(t).direction_swapped = struct;
                else
                    centered_averaged_CONCAT_thetaSeq.direction2(t) = centered_averaged_CONCAT_thetaSeq.direction1(t);
                    centered_averaged_CONCAT_thetaSeq.direction2(t).direction_swapped = 1; %change to 1 to indicate directions for this track have been swapped
                end
                centered_averaged_CONCAT_thetaSeq.direction1(t) = temp_rep_concat;
                centered_averaged_CONCAT_thetaSeq.direction1(t).direction_swapped = 1; %change to 1 to indicate directions for this track have been swapped
            end
        end
    end
end
clear lap_times
        
% Merge all sequences in one direction : Get sequences in direction 2 and flip them
fields = fieldnames(centered_averaged_thetaSeq);
if length(fields) >1 & ~isempty(centered_averaged_thetaSeq.(sprintf('%s',fields{1}))(t).thetaseq) & ~isempty(centered_averaged_thetaSeq.(sprintf('%s',fields{2}))(t).thetaseq)
    [centered_averaged_thetaSeq.unidirectional(1:size(centered_averaged_thetaSeq.direction1(:),1)).thetaseq] = centered_averaged_thetaSeq.direction1(:).thetaseq;
    if concat_option == 1
        [centered_averaged_CONCAT_thetaSeq.unidirectional(1:size(centered_averaged_CONCAT_thetaSeq.direction1(:),1)).thetaseq] = centered_averaged_CONCAT_thetaSeq.direction1(:).thetaseq;
    end
    for t = 1 : length(centered_averaged_thetaSeq.direction2)
        if isempty(centered_averaged_thetaSeq.direction2(t).thetaseq)
            continue
        end
        for seq =  1 : length(centered_averaged_thetaSeq.direction2(t).thetaseq)
            unidirectional(t).thetaSeq(seq).relative_decoded_position = flipud(centered_averaged_thetaSeq.direction2(t).thetaseq(seq).relative_decoded_position);
            unidirectional(t).thetaSeq(seq).theta_window_index= centered_averaged_thetaSeq.direction2(t).thetaseq(seq).theta_window_index;
            unidirectional(t).thetaSeq(seq).theta_cycle_centre_trough_times= centered_averaged_thetaSeq.direction2(t).thetaseq(seq).theta_cycle_centre_trough_times;
            unidirectional(t).thetaSeq(seq).theta_cycle_peaks_times= centered_averaged_thetaSeq.direction2(t).thetaseq(seq).theta_cycle_peaks_times;
        end
        centered_averaged_thetaSeq.unidirectional(t).thetaseq = [centered_averaged_thetaSeq.unidirectional(t).thetaseq, unidirectional(t).thetaSeq];
        if concat_option == 1
            % Repeat for concatenated structure
            for seq =  1 : length(centered_averaged_CONCAT_thetaSeq.direction2(t).thetaseq)
                unidirectional_concat(t).thetaSeq(seq).relative_decoded_position = flipud(centered_averaged_CONCAT_thetaSeq.direction2(t).thetaseq(seq).relative_decoded_position);
                unidirectional_concat(t).thetaSeq(seq).theta_cycle_centre_trough_times= centered_averaged_CONCAT_thetaSeq.direction2(t).thetaseq(seq).theta_cycle_centre_trough_times;
                unidirectional_concat(t).thetaSeq(seq).theta_cycle_peaks_times= centered_averaged_CONCAT_thetaSeq.direction2(t).thetaseq(seq).theta_cycle_peaks_times;
            end
            centered_averaged_CONCAT_thetaSeq.unidirectional(t).thetaseq = [centered_averaged_CONCAT_thetaSeq.unidirectional(t).thetaseq, unidirectional_concat(t).thetaSeq];
        end
    end
else
    if strcmp(fields{1},'direction1')   % any(strcmp(fields,'direction1'))
        if ~isempty(centered_averaged_thetaSeq.direction1)
            [centered_averaged_thetaSeq.unidirectional(1:size(centered_averaged_thetaSeq.direction1(:),1)).thetaseq] = centered_averaged_thetaSeq.direction1(:).thetaseq;
            if concat_option == 1
                [centered_averaged_CONCAT_thetaSeq.unidirectional(1:size(centered_averaged_CONCAT_thetaSeq.direction1(:),1)).thetaseq] = centered_averaged_CONCAT_thetaSeq.direction1(:).thetaseq;
            end
        end
    elseif strcmp(fields{1},'direction2')    %any(strcmp(fields,'direction2'))
        
        for t = 1 : length(centered_averaged_thetaSeq.direction2)
            if isempty(centered_averaged_thetaSeq.direction2(t).thetaseq)
                continue
            end
            centered_averaged_thetaSeq.unidirectional(t).thetaseq = struct;
            if concat_option == 1
                centered_averaged_CONCAT_thetaSeq.unidirectional(t).thetaseq = struct;
            end
            for seq =  1 : length(centered_averaged_thetaSeq.direction2(t).thetaseq)
                unidirectional(t).thetaSeq(seq).relative_decoded_position = flipud(centered_averaged_thetaSeq.direction2(t).thetaseq(seq).relative_decoded_position);
                unidirectional(t).thetaSeq(seq).theta_window_index= centered_averaged_thetaSeq.direction2(t).thetaseq(seq).theta_window_index;
                unidirectional(t).thetaSeq(seq).theta_cycle_centre_trough_times= centered_averaged_thetaSeq.direction2(t).thetaseq(seq).theta_cycle_centre_trough_times;
                unidirectional(t).thetaSeq(seq).theta_cycle_peaks_times= centered_averaged_thetaSeq.direction2(t).thetaseq(seq).theta_cycle_peaks_times;
            end
            centered_averaged_thetaSeq.unidirectional(t).thetaseq = unidirectional(t).thetaSeq;
            if concat_option == 1
                % Repeat for concatenated structure
                for seq =  1 : length(centered_averaged_CONCAT_thetaSeq.direction2(t).thetaseq)
                    unidirectional_concat(t).thetaSeq(seq).relative_decoded_position = flipud(centered_averaged_CONCAT_thetaSeq.direction2(t).thetaseq(seq).relative_decoded_position);
                    unidirectional_concat(t).thetaSeq(seq).theta_cycle_centre_trough_times= centered_averaged_CONCAT_thetaSeq.direction2(t).thetaseq(seq).theta_cycle_centre_trough_times;
                    unidirectional_concat(t).thetaSeq(seq).theta_cycle_peaks_times= centered_averaged_CONCAT_thetaSeq.direction2(t).thetaseq(seq).theta_cycle_peaks_times;
                end
                centered_averaged_CONCAT_thetaSeq.unidirectional(t).thetaseq = unidirectional_concat(t).thetaSeq;
            end
        end
    end
end
clear unidirectional unidirectional_concat

% CALCULATE AVERAGE THETA SEQUENCE
fields = fieldnames(centered_averaged_thetaSeq);
for d = 1 : length(fields)
    for t =  1: length(centered_averaged_thetaSeq.(sprintf('%s',fields{d})))
        if isempty(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq)
            continue
        end
        % Concatenate all windows
        concat = zeros(size(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(1).relative_decoded_position,1),size(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(1).relative_decoded_position,2));
        for i = 1 : length(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq)
            concat = concat + centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(i).relative_decoded_position;
            %concat = concat + (bsxfun(@rdivide,centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(i).relative_decoded_position,max(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(i).relative_decoded_position,[],1)));
        end
        % Calculates the average theta cycle and saves it
        centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).mean_relative_position = concat./length(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq);
        
        if concat_option == 1
            %Repeat for concatenated structure
            concat = zeros(size(centered_averaged_CONCAT_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(1).relative_decoded_position,1),size(centered_averaged_CONCAT_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(1).relative_decoded_position,2));
            for i = 1 : length(centered_averaged_CONCAT_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq)
                concat = concat + centered_averaged_CONCAT_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(i).relative_decoded_position;
                %concat = concat + (bsxfun(@rdivide,centered_averaged_CONCAT_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(i).relative_decoded_position,max(centered_averaged_CONCAT_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(i).relative_decoded_position,[],1)));
            end
            % Calculates the average theta cycle and saves it
            centered_averaged_CONCAT_thetaSeq.(sprintf('%s',fields{d}))(t).mean_relative_position = concat./length(centered_averaged_CONCAT_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq);
                        
        end
    end
end



end

function centered_averaged_thetaSeq = centre_thetaseq_animal_position(decoded_thetaSeq,position,directional_place_fields)
% Find animal's current position at the trough and center theta sequence
% around it

parameters = list_of_parameters;

%num_position_bins = size(decoded_thetaSeq.direction1(1).theta_sequences(1).decoded_position,1);
 
% Set position window (from Farooq & Dragoi(2019,Science)).
window_width = parameters.theta_position_window_width; 
fields = fieldnames(decoded_thetaSeq);
fields = fields(cellfun(@(s) isempty(strmatch ('phase', s)), fieldnames(decoded_thetaSeq)));

% Center decoded sequence on the animal's current position
for d = 1 : length(fields) % for each direction
    
    for t = 1 : length(decoded_thetaSeq.(sprintf('%s',fields{d}))) % for each track
        c = 1;
        for s = 1 : size(decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences,2) %for each theta sequence
            num_position_bins = size(decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(s).decoded_position,1);
            
            % Find animal's real position at the time of the trough
            linear_position =  position.linear(t).linear(~isnan(position.linear(t).linear));
            [~,time_idx] = min(abs(position.linear(t).timestamps - decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(s).theta_cycle_trough_time));
            real_position = linear_position(time_idx); % position at the theta trough
            
            % conversion from real position in each time bin to the closest binned position value
            [~,idx] = min(abs(directional_place_fields(d).place_fields.track(t).x_bin_centres - real_position));
            
            % Center decoded position to the animal's converted position and keep 40/50 cm before and after 
            num_bins = window_width/parameters.x_bins_width; % Find how many bins make 40cm
            
            upper_lim = idx-num_bins;
            lower_lim = idx+num_bins;
            if upper_lim <= 0 % wrap around the track if needed
                if upper_lim == 0 
                    added = num_position_bins;
                else %if it goes past the start
                    added = num_position_bins:-1:(num_position_bins+upper_lim);
                end
                added = [sort(added),1:lower_lim];
                centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(c).relative_decoded_position = decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(s).decoded_position(added,:);
            elseif lower_lim > num_position_bins %if it goes past the end (100)
                added = 1:1:(lower_lim-num_position_bins);
                added = [upper_lim:num_position_bins, added];
                centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(c).relative_decoded_position = decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(s).decoded_position(added,:);
            else
                centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(c).relative_decoded_position = decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(s).decoded_position(upper_lim:lower_lim,:);
            end
            if isfield(decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences,'index_from_theta_windows')
                centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(c).theta_window_index = decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(s).index_from_theta_windows;
            end
            centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(c).theta_cycle_centre_trough_times = decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(s).theta_cycle_trough_time; % keep trough times
            centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).thetaseq(c).theta_cycle_peaks_times = decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(s).theta_cycle_peaks_times; % keep peaks/edges times
            c = c+1;
        end
    end
    
end
end