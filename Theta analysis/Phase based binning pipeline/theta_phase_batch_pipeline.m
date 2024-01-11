% THETA BATCH ANALYSIS PIPELINE
% MH 2020

function theta_phase_batch_pipeline(option,computer,plot_select,varargin)
% option: 1- phase precession ; 2 - extract directional clusters and place fields ; 3 - extract theta extrema ; 4 -bayesian decoding ;
% 5 - Theta sequence quantification ; 6 - shuffles ; 7 - finding theta sequence center
% plot_select: 1 or 0 to choose whether to run plotting scripts
% varargin: [] or 'all'- see replay
% computer: 'GPU' for supercomputer


% Load name of data folders
if strcmp(computer,'GPU')
    sessions = data_folders_GPU;
    session_names = fieldnames(sessions);
else
    sessions = data_folders;
    session_names = fieldnames(sessions);
end

for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders)
        cd(cell2mat(folders(s)))
        disp(cell2mat(folders(s)))
        tic
        if ~exist([pwd '\Theta'], 'dir')
            mkdir('Theta')
        end
            
        % PHASE PRECESSION
        if any(ismember(option,1)) || strcmp(varargin,'all')
            %half_laps_times = extract_running_laps;
            TPP = phase_precession_absolute_location;
        end
        
        % THETA SEQUENCES
        if any(ismember(option,2)) || strcmp(varargin,'all')
            % Extract directional place fields
            disp('extracting new clusters')
            extract_directional_clusters;
            
            disp('calculating directional clusters')
            parameters = list_of_parameters;
            calculate_directional_place_fields(parameters.x_bins_width); %2cm
            calculate_directional_place_fields(parameters.x_bins_width_bayesian); %10cm
            %extract_unidirectional_place_cells;
%             
%             if plot_select == 1
%                 % Plot place fields for each direction
%                 plot_place_fields(directional_place_fields(1).place_fields)
%                 plot_place_fields(directional_place_fields(2).place_fields)
%             end
        end
        
        if any(ismember(option,3)) || strcmp(varargin,'all')
            % Extract theta cycles
            disp('extracting theta windows')
            extract_theta_peak_trough(2);
        end
        
        if any(ismember(option,4)) || strcmp(varargin,'all')
            
            % Bayesian decoding on theta cycles and decoding error
            disp('extracting theta windows')
            theta_sequences_detection_decoding([]);
        end
        
        if any(ismember(option,5)) || strcmp(varargin,'all')
            % quantification methods
            disp('Apply quantification methods')
            %phase_theta_sequence_quantification([],1,[],'Y');
            %spike_train_correlation_phase([],[],'Y'); %non-bayesian quantification
            theta_sequences_decoding_error_phase([],1); 
            plot_theta_sequences_decoding_error;
            
            if plot_select == 1
                plot_averaged_concat_theta_sequences([]); 
            end
        end
%         cd([pwd '\Theta'])
%         save_all_figures(pwd,[]);
%         cd ..
       
        if any(ismember(option,6)) || strcmp(varargin,'all')
            disp('running shuffles')
            % Shuffles
            num_shuffles = 1000;
            thetaseq_circular_position_shuffle([],num_shuffles,1,'Y'); % POST bayesian
            %average_theta_sequences_timebins_phase_shuffle(num_shuffles,1);
            thetaseq_phase_PRE_spike_circ_shuffle([],[],num_shuffles,1,'Y')  % PRE bayesian
            thetaseq_circular_phase_shuffle([],num_shuffles,1,'Y');  % POST bayesian
            if plot_select == 1
                plot_time_bin_phase_shuffle;
                plot_position_shuffle;
                plot_PREspike_train_phase_shuffle;
            end
        end
        
        if any(ismember(option,7)) || strcmp(varargin,'all')
            disp('significance score')
            % SIGNIFICANCE
            centered_averaged_thetaSeq = average_thetaseq_significance_scoring;
        end
        toc
    end
end
end
