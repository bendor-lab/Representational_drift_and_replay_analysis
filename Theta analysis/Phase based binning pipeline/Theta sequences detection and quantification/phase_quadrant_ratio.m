% THETA SEQUENCES QUANTIFICATION : QUADRANT RATIO
% MH 2020

% From Feng et al (2015,J Neuro).Decoded probabilities +-50 cm around the animal’s location, and 1/4 theta cycle around the mid-time
% point of the theta sequence, were divided equally into four quadrants:
% Quadrant I & III: summed decoded probabilities opposite with the animal’s current running direction
% Quadrant II & IV:summed decoded probabilities along the animal’s current running direction
        % Quadrant II: represents region both physically and temporally behind the animal
        % Quadrant IV: represents the region physically and temporally ahead of the animal
% Formula: Q1+Q3 - Q2+Q4 / Q1+Q2+Q3+Q4
% OUTCOME: Positive differences would imply theta sequences sweeping in the running direction of the animal, whereas differences close to zero would indicate
% a lack of sequential structure in the decoded probabilities.


function centered_averaged_thetaSeq = phase_quadrant_ratio(centered_averaged_thetaSeq)

parameters = list_of_parameters;

fields = fieldnames(centered_averaged_thetaSeq);
for d = 1 : length(fields) % for each direction
         
    for t = 1 : length(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))) % for each track
%         if ~isfield(centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t),'thetaseq')
%             continue
%         end
        central_cycle = centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).mean_relative_position;
        half_pos = ceil(size(central_cycle,1)/2); % central position
        half_time = ceil(size(central_cycle,2)/2); % central position         
        %sum(central_cycle.*[1:size(central_cycle,2)]/sum(central_cycle))
        % Swap direction if needed - for quadrant ratio sequence need to be from past to future
        if d ~= 2 
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
        
        centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).quadrants_scores = [quadI,quadII,quadIII,quadIV];
        centered_averaged_thetaSeq.(sprintf('%s',fields{d}))(t).quadrant_ratio = ((quadI+quadIII) - (quadII+quadIV)) / (quadI+quadII+quadIII+quadIV);
        
     end
end



end
