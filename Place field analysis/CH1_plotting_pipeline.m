% CHAPTER 1- PLOTTING PIPELINE
% Marta Huelin

% number of cells active per track
    count_cells_track;
    plot_directional_place_cells;
    skaggs_info_experience_development;
    behaviour_plots;
    save_all_figures(pwd,[]);

% SINGLE CELL & POPULATION STABILITY
    parameter = {'centremass_r','peak_r', 'normcentremass_r'};
    comparison_type = {'within_track-consecutive_laps','within_track-ends_laps'};
    for i = 1 : length(comparison_type)
        for e = 1 : length(parameter)
            plot_plField_LAPcorr(parameter{e},comparison_type{i},'Y'); % Correlation lap by lap at population level within track exposure
            save_all_figures(pwd,[]);
        end
    end
    for e = 2 : length(parameter)
        plot_plField_LAPcorr_first_to_second_exposure(parameter{e});% Correlation lap by lap at population level comparing 4 last laps of first exposure to second exposure
        save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr',[]);
        plot_plField_LAPcorr_second_to_first_exposure(parameter{e});% Correlation lap by lap at population level comparing laps 13-16 of second exposure to first exposure
        save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr',[]);
    end
    
    parameter = {'centreMass_diff','peakFR_diff','norm_centreMass_diff','meanFR_diff'};
    for i = 1 : length(comparison_type)
        for e = 1 : length(parameter)
            plotting_data = plot_singleCell_corr(parameter{e},comparison_type{i},'Y'); % Correlation lap by lap at single cell level
            save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr',[]);
        end
    end
    for e = 1 : length(parameter)
        plotting_data = plot_singleCell_corr_between_exposures(parameter{e},'Y'); % Correlation lap by lap at single cell level comparing 4 last laps of first exposure to second exposure
        save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr',[]);
        session_data = plot_singleCell_corr_second_to_first_exposure(parameter{e},'Y'); % Correlation lap by lap at single cell level comparing laps 13-16 of second exposure to first exposure
        save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\plField_LAPScorr',[]);
    end
% REMAPPING

    plot_population_vector_shuffles; %PPV + global remapping shuffle
    plot_firing_rate_population_vector_shuffles; % modified PPV for firing rate differences + rate remapping shuffles
    protocol = compare_shuffle_PV_corr_pvalues; % Compare distribution of pvalues between shuffles and real data

    % DECODING ERROR

    % plot decoding error per track
    extract_decoding_error_info;
    plot_track_decoding_error;

    % plot_decodingError_laps;
    plot_track_decodingError_across_laps('Y'); %plots median decoding error per lap, compared to the last lap(s)
    plot_track_decodingError_between_exposures('Y'); %plots median decoding error compared to exposure to the same or different track
    plot_track_decodingError_consecutive_laps('Y'); %plots median decoding error of consecutive laps within each track