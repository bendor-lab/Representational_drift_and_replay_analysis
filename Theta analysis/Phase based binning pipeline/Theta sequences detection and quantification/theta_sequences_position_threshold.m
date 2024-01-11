% THETA SEQUENCES POSITION THRESHOLD
% MH, 2020
% Set position threshold: theta sequences only analysed when the animal is in the middle of track (1/6 to 5/6) - Feng et al (2015, J Neuro)

function  [decoded_thetaSeq,deleted_decoded_thetaSeq]= theta_sequences_position_threshold(decoded_thetaSeq,save_option)

if isempty(decoded_thetaSeq)
    cd([pwd '\Theta'])
    load decoded_theta_sequences.mat
    cd ..
end
load extracted_position.mat

parameters = list_of_parameters;

% Exclude reward sites, both are 20 cm (total length 200cm)
lower_thresh = 20; 
high_thresh = 180;

for d = 1 : length(fieldnames(decoded_thetaSeq)) % for each direction
    thetaseq = decoded_thetaSeq.(strcat('direction',num2str(d)));    
    
    for t = 1 : length(thetaseq) % for each track
        indices_to_remove = [];
        
        for s = 1 : size(thetaseq(t).theta_sequences,2) %for each theta sequence
            
            linear_position =  position.linear(t).linear(~isnan(position.linear(t).linear));
            [~,time_idx] = min(abs(position.linear(t).timestamps - thetaseq(t).theta_sequences(s).theta_cycle_centre_trough_times));
            real_position(s) = linear_position(time_idx);
            
            % If animal position is at the start or end of track, save index
            if real_position(s) < lower_thresh | real_position(s) > high_thresh
                indices_to_remove = [indices_to_remove s];
            end
        end
        
        %%% Uncomment for safety check figure
        %figure;
        %histogram(real_position)
        %xlabel('Position (cm)'); ylabel('number of theta windows')
        
        clear real_position
        % For checking, save only the deleted sequences
        deleted_decoded_thetaSeq.(strcat('direction',num2str(d)))(t).theta_sequences = decoded_thetaSeq.(strcat('direction',num2str(d)))(t).theta_sequences(indices_to_remove);
        % Delete indices
        decoded_thetaSeq.(strcat('direction',num2str(d)))(t).theta_sequences(indices_to_remove) = [];
        
    end
    
end

% Save
if save_option == 1
    cd([pwd '\Theta'])
    save thresholded_decoded_thetaSeq decoded_thetaSeq deleted_decoded_thetaSeq
    cd ..
end
end
            