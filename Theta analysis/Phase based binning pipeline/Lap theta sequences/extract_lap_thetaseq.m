% EXTRACT THETA SEQUENCES FOR EACH LAP
% MH 2020
% For each track, extracts theta sequences for each lap. Uses place fields from the whole track session, not from individual laps.
% Then averages all theta sequences within a lap and scores it using quantification methods,
% INPUT:
    % lap_option: 'complete' or 
function lap_thetaseq = extract_lap_thetaseq(lap_option)

sessions = data_folders;
session_names = fieldnames(sessions);

c = 1;
for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        
        load Theta\theta_sequence_quantification.mat
        load extracted_laps.mat
        folder_name = strsplit(pwd,'\');                
        fields = fieldnames(centered_averaged_thetaSeq);
        
        for d = 1 : length(fields)
                
            for t = 1 : length(lap_times) % for each track
                lap_thetaseq(c).session = folder_name{end};
                lap_thetaseq(c).protocol = str2num(lap_thetaseq(c).session(end));
                lap_thetaseq(c).dir = d;
                lap_thetaseq(c).track = t;
                
                if t > 2
                    num_laps = 16; %just look at the first 16 laps of the second exposure
                else
                    num_laps = length(lap_times(t).completeLaps_start);
                end
                
                for thisLap = 1 : num_laps% for each lap
                    
                    % Find theta windows in this lap and average them
                    tseq_indx = [centered_averaged_thetaSeq.(strcat(fields{d}))(t).thetaseq(:).theta_cycle_centre_trough_times] > lap_times(t).completeLaps_start(thisLap) & ...
                        [centered_averaged_thetaSeq.(strcat(fields{d}))(t).thetaseq(:).theta_cycle_centre_trough_times] < lap_times(t).completeLaps_stop(thisLap);
                    if ~any(tseq_indx)
                        continue
                    end
                    
                    lap_thetaseq(c).(strcat('Lap_',num2str(thisLap))).theta_sequences = centered_averaged_thetaSeq.(strcat(fields{d}))(t).thetaseq(tseq_indx);
                    matrix = {centered_averaged_thetaSeq.(strcat(fields{d}))(t).thetaseq(tseq_indx).relative_decoded_position};
                    matrix2 = cat(3,matrix{:});
                    lap_thetaseq(c).(strcat('Lap_',num2str(thisLap))).average_thetaseq = mean(matrix2,3);
                    
                    % Repeat for concatenated structure
                    tseq_indx_concat = [centered_averaged_CONCAT_thetaSeq.(strcat(fields{d}))(t).thetaseq(:).theta_cycle_centre_trough_times] > lap_times(t).completeLaps_start(thisLap) & ...
                        [centered_averaged_CONCAT_thetaSeq.(strcat(fields{d}))(t).thetaseq(:).theta_cycle_centre_trough_times] < lap_times(t).completeLaps_stop(thisLap);
                    lap_thetaseq(c).(strcat('Lap_',num2str(thisLap))).theta_sequences = centered_averaged_CONCAT_thetaSeq.(strcat(fields{d}))(t).thetaseq(tseq_indx_concat);
                    matrix3 = {centered_averaged_CONCAT_thetaSeq.(strcat(fields{d}))(t).thetaseq(tseq_indx_concat).relative_decoded_position};
                    matrix4 = cat(3,matrix3{:});
                    lap_thetaseq(c).(strcat('Lap_',num2str(thisLap))).average_thetaseq_CONCAT = mean(matrix4,3);
                    
                    clear matrix matrix2 matrix3 matrix4
                    
                    %%%%% Apply quantification methods                     
                    % Quadrant Ratio
                    lap_thetaseq(c).(strcat('Lap_',num2str(thisLap))).quadrant_ratio = quadrant_ratio(lap_thetaseq(c).(strcat('Lap_',num2str(thisLap))).average_thetaseq,d);
                    
                    % Weighted Correlation
                    lap_thetaseq(c).(strcat('Lap_',num2str(thisLap))).weighted_corr = weighted_correlation(lap_thetaseq(c).(strcat('Lap_',num2str(thisLap))).average_thetaseq);

%                     % Line fitting
%                     central_cycle =  (lap_thetaseq(c).(strcat('Lap_',num2str(thisLap))).average_thetaseq);
%                     time_bins_length = size(central_cycle,2); % all matrices should have the same size
%                     [all_tstLn,spd2Test]= construct_all_lines(time_bins_length);
%                     [lap_thetaseq(c).(strcat('Lap_',num2str(thisLap))).linear_score,lap_thetaseq(c).(strcat('Lap_',num2str(thisLap))).linear_slope,~] = line_fitting2(central_cycle,all_tstLn(size(central_cycle,2)==time_bins_length),spd2Test);                        
                    
                    % Spike train correlation?
                    
                end
                c = c+1;
            end                    
        end
    end
end

% Save
save('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Lap theta sequences\lap_thetaseq.mat','lap_thetaseq','-v7.3')

end


function quadrant_ratio_score = quadrant_ratio(central_cycle,direction)

half_pos = ceil(size(central_cycle,1)/2); % central position
half_time = ceil(size(central_cycle,2)/2); % central position
%sum(central_cycle.*[1:size(central_cycle,2)]/sum(central_cycle))
% Swap direction if needed - for quadrant ratio sequence need to be from past to future
if direction ~= 2
    central_cycle = flipud(central_cycle); % flip for calculating quadrant ratio
end

% Set the quadrants such that they are overlapping for one bin in  the Y axis.
% Divide the probability of the overlapping bins by 2
if mod(half_pos,2) ~= 0 && mod(half_time,2) == 0 %only overlaps Y axis
    overlapping_y_bins = (central_cycle(half_pos,:))*0.5;
    quadI = sum(sum(central_cycle(1:half_pos-1,(half_time+1):size(central_cycle,2)))) + ...
        sum(overlapping_y_bins(half_time+1:end));
    quadII = sum(sum(central_cycle(1:half_pos-2,1:half_time)))+ ...
        sum(overlapping_y_bins(1:half_time));
    quadIII = sum(sum(central_cycle(half_pos-1:size(central_cycle,1),1:half_time)))+ ...
        sum(overlapping_y_bins(1:half_time));
    quadIV = sum(sum(central_cycle(half_pos-2:size(central_cycle,1),(half_time+1):size(central_cycle,2))))+ ...
        sum(overlapping_y_bins(half_time+1:end));
    
elseif mod(half_time,2) ~= 0 && mod(half_pos,2) == 0 % only overlaps X axis
    overlapping_x_bins = (central_cycle(:,half_time))*0.5;
    quadI = sum(sum(central_cycle(1:half_pos,(half_time+1):size(central_cycle,2)))) + ...
        sum(overlapping_x_bins(1:half_pos));
    quadII = sum(sum(central_cycle(1:half_pos-1,1:half_time-1)))+ ...
        sum(overlapping_x_bins(1:half_pos-1));
    quadIII = sum(sum(central_cycle(half_pos:size(central_cycle,1),1:half_time-1)))+ ...
        sum(overlapping_x_bins(half_pos:size(central_cycle,1)));
    quadIV = sum(sum(central_cycle(half_pos-1:size(central_cycle,1),(half_time+1):size(central_cycle,2))))+ ...
        sum(overlapping_x_bins(half_pos-1:size(central_cycle,1)));
    
elseif mod(half_time,2) ~= 0 && mod(half_pos,2) ~= 0 %both axes overlap
    overlapping_x_bins = (central_cycle(:,half_time))*0.5;
    overlapping_y_bins = (central_cycle(half_pos,:))*0.5;
    quadI = sum(sum(central_cycle(1:half_pos-1,(half_time+1):size(central_cycle,2)))) + ...
        sum(overlapping_y_bins(half_time+1:end)) + sum(overlapping_x_bins(1:half_pos));
    quadII = sum(sum(central_cycle(1:half_pos-2,1:half_time-1))) + ...
        sum(overlapping_y_bins(1:half_time)) + sum(overlapping_x_bins(1:half_pos-1));
    quadIII = sum(sum(central_cycle(half_pos-1:size(central_cycle,1),1:half_time-1)))+ ...
        sum(overlapping_y_bins(1:half_time)) + sum(overlapping_x_bins(half_pos:size(central_cycle,1)));
    quadIV = sum(sum(central_cycle(half_pos-2:size(central_cycle,1),(half_time+1):size(central_cycle,2)))) + ...
        sum(overlapping_y_bins(half_time+1:end)) + sum(overlapping_x_bins(half_pos-1:size(central_cycle,1)));
    
else %no overlapping
    quadI = sum(sum(central_cycle(1:half_pos,(half_time+1):size(central_cycle,2))));
    quadII = sum(sum(central_cycle(1:half_pos,1:half_time)));
    quadIII = sum(sum(central_cycle(half_pos+1:size(central_cycle,1),1:half_time)));
    quadIV = sum(sum(central_cycle(half_pos-1:size(central_cycle,1),(half_time+1):size(central_cycle,2))));
end

size1 = size(quadI);
size2 = size(quadII);
size3 = size(quadIII);
size4 = size(quadIV);
if ~isequal(size1,size2,size3,size4)
    disp(['quadrant sizes are not equal in dir ' num2str(d) ' and track ' num2str(t)])
end

quadrant_ratio_score = ((quadI+quadIII) - (quadII+quadIV)) / (quadI+quadII+quadIII+quadIV);




end


        
        
        
        