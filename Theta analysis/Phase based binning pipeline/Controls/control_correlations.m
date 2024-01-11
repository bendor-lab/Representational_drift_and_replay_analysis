% CONTROL THETA SEQUENCES: CORRELATION PLOTS
function control_correlations

 data_folder = 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores';
 load([data_folder '\session_thetaseq_scores.mat'])
 load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Theta sequence scores\thetaseq_scores_individual_laps.mat')
 path2= 'X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Decoding_error';
 load([path2 '\all_tracks_decoding_error.mat']);
 load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\behavioural_data.mat')
 path4='X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 2\Raw_replay_analysis';
 load([path4 '\extracted_time_periods_replay.mat']);

 %%%%  1. Single correlations
 
 % SCORES VS NUM THETA SEQ
 all_scores = [quantification_scores(2).scores(1,:) quantification_scores(2).scores(2,:)];
 all_num_thetaseq = [quantification_scores(2).num_thetaseq(1,:) quantification_scores(2).num_thetaseq(2,:)];
 [R_Score_NTS,pv_Score_NTS] = corrcoef([all_scores',all_num_thetaseq']); %YES
 
 % SCORES VS NUM LAPS
 protocols = [8,4,3,2,1];
 num_laps = [];
 num_laps = [num_laps ones(1,length(quantification_scores(2).scores(1,:)))*16]; %add T1 laps
 for p = 1 : length(protocols)
     num_laps = [num_laps ones(1,4)*protocols(p)]; %add other protocols' num of laps, 4 session per each
 end
 [R_Score_NL,pv_Score_NL] = corrcoef([all_scores',num_laps']); %YES
 
 % SCORES VS TIME SPENT IN TRACK
 for jj = 1 : length(period_time)
    T1_times(jj) = period_time(jj).T1.length;
    T2_times(jj) = period_time(jj).T2.length;
 end
 all_times = [T1_times T2_times];
 [R_Score_TS,pv_Score_TS] = corrcoef([all_scores',all_times']); %YES 
 
 % PLACE FIELD STABILITY VS SCORES/NUM THETA SEQ
 skaggs_info = extract_skaggs_info; % mean Skagg values of the good bayesian place cel for each session as a proxy of place fields stability measure
 all_decoding_error = [all_tracks_decoding_error(:).T1 all_tracks_decoding_error(:).T2]; % median decoding error per track
 [RSK_Score,pSK_Score] = corrcoef([skaggs_info,all_scores']); %NO
 [RSK_NTS,pvSK_NTS] = corrcoef([skaggs_info,all_num_thetaseq']);%NO
 [RDE_Score,pDE_Score] = corrcoef([all_decoding_error',all_scores']); %YES
 [RDE_NTS,pvDE_NTS] = corrcoef([all_decoding_error',all_num_thetaseq']);%YES
 
 % NUMBER OF UNITS VS SCORES/NUM THETA SEQ
 [mean_units,thetaseq_units,mean_lap_skaggs,mean_lap_units] = extract_thetaseq_units; % Finds mean number of active units in theta seq per track
 [RAC_NTS,pvAC_NTS] = corrcoef([mean_units,all_num_thetaseq']); %YES
 [RAC_Score,pAC_Score] = corrcoef([mean_units,all_scores']); %YES
 
 % AVERAGE TRACK SPEED VS SCORES/NUM THETA SEQ
 tracks_speed = [moving_speed(:,1);moving_speed(:,2)];
 [RAS_NTS,pAS_NTS] = corrcoef([tracks_speed,all_num_thetaseq']); %NO
 [RAS_Score,pAS_Score] = corrcoef([tracks_speed,all_scores']); %NO
 
     for t = 1 :2
         scores_lap{t} = [];
         num_seq_lap{t} = [];
         for ii = 1 : length(lap_WeightedCorr)
             scores_lap{t} = [scores_lap{t} lap_WeightedCorr(ii).track(t).score];
            num_seq_lap{t} = [num_seq_lap{t} lap_WeightedCorr(ii).track(t).num_thetaseq./cell2mat(lap_behaviour(t).time_moving(ii,1:length(lap_WeightedCorr(ii).track(t).score)))];
         end
     end
     track_scores_lap = [scores_lap{1}'; scores_lap{2}'];
     track_num_seq_lap = [num_seq_lap{1}'; num_seq_lap{2}'];
     [lap_track_speed,time_moving,prot_idics] = get_average_track_speed;
     lap_track_speed([266,335,319]) = [];
     time_moving([266,335,319]) = [];
     prot_idics([266,335,319]) = [];
     mean_lap_skaggs([266,335,319]) = [];
     mean_lap_units([266,335,319]) = [];
     lap_dec_error = extract_lap_decoding_error;
     
     [RLS_LScore,pAS_Score] = corrcoef([lap_track_speed,track_scores_lap]); %YES
     [RLS_LScore,pAS_Score] = corrcoef([lap_dec_error,track_scores_lap]); %YES
     [RLS_LScore,pAS_Score] = corrcoef([track_num_seq_lap,track_scores_lap]); %YES
     
     [RLS_LScore,pAS_Score] = corrcoef([mean_lap_skaggs,track_scores_lap]); %YES
     [RLS_LScore,pAS_Score] = corrcoef([mean_lap_units,track_scores_lap]); %YES




     tempmat = [time_moving;track_scores_lap;track_num_seq_lap];
     [rho,pval] = partialcorr([time_moving,track_scores_lap],track_num_seq_lap);
     [rho,pval] = partialcorr([time_moving,track_scores_lap],[track_num_seq_lap,lap_track_speed]);
     [rho,pval] = partialcorr([time_moving,track_scores_lap],[track_num_seq_lap,lap_track_speed,lap_dec_error]);

     [rho,pval] = partialcorr(tempmat);
     rho = array2table(rho,'VariableNames',{'Time_moving','LAP_theta_seq_score','LAP_Num_theta_seq'},...
         'RowNames',{'Time_moving','LAP_theta_seq_score','LAP_Num_theta_seq'});
     disp('Partial Correlation Coefficients')
     disp(rho)
     pval = array2table(pval,'VariableNames',{'Time_moving','LAP_theta_seq_score','LAP_Num_theta_seq'},...
         'RowNames',{'Time_moving','LAP_theta_seq_score','LAP_Num_theta_seq'});
     disp('Partial Correlation Coefficients')
     disp(pval)

 %%%%  2. Test semi-partial correlation between number of laps, numbet of
 %%%%  theta sequences and average theta sequence score

 tempmat = [num_laps',all_scores',all_num_thetaseq'];
 [rho,pval] = partialcorr(tempmat);
 
 rho = array2table(rho,'VariableNames',{'Num_Laps','WC_theta_seq_score','Num_theta_seq'},...
    'RowNames',{'Num_Laps','WC_theta_seq_score','Num_theta_seq'});
disp('Partial Correlation Coefficients')
disp(rho)

 tempmat = [all_times',all_scores',all_num_thetaseq'];
 [rho,pval] = partialcorr(tempmat);
 
 rho = array2table(rho,'VariableNames',{'All_times','WC_theta_seq_score','Num_theta_seq'},...
    'RowNames',{'All_times','WC_theta_seq_score','Num_theta_seq'});
disp('Partial Correlation Coefficients')
disp(rho)


%%%% 3. Test correlation between place cell stability (using either skagg's
%%%% information or decoding error) and theta sequence score & number of
%%%% theta sequences

[rho2,pval2] = partialcorr([all_decoding_error' ,all_scores' ,all_num_thetaseq'] );
 skaggs_info 
rho2 = array2table(rho2,'VariableNames',{'Skaggs_info','Track_decoding_errors','WC_theta_seq_score','Num_theta_seq'},...
    'RowNames',{'Skaggs_info','Track_decoding_errors','WC_theta_seq_score','Num_theta_seq'});
disp('Partial Correlation Coefficients')
disp(rho2)

%%%% 4. TRY ALL CORRELATED VARIABLES 

x_var =  [num_laps',all_scores'];
%y_var = [];
control_var = [all_decoding_error',mean_units,all_num_thetaseq'];
[rho_all,pval_all] = partialcorr(x_var,control_var);
[rho_all2,pval_all2] = partialcorr([num_laps',all_scores',all_decoding_error',mean_units]);


x_var =  [all_times',all_scores'];
%y_var = [];
control_var = [all_decoding_error',mean_units,all_num_thetaseq'];
[rho_all,pval_all] = partialcorr(x_var,control_var);
[rho_all2,pval_all2] = partialcorr([num_laps',all_scores',all_decoding_error',mean_units]);


figure;
scatter3(num_laps,all_scores,all_num_thetaseq)


end



%%%%%%%%%%%%%%%% BUILT-IN FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%


function skaggs_info = extract_skaggs_info
% extracts mean skagg's information for track
skaggs_info= [];
sessions = data_folders;
session_names = fieldnames(sessions);
for p = 1 : length(session_names)
     folders = sessions.(sprintf('%s',cell2mat(session_names(p))));

    for s = 1: length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        if exist(strcat(pwd,'\extracted_place_fields_BAYESIAN.mat'),'file')
            load('extracted_place_fields_BAYESIAN.mat')
            % Row are protocols, columns Tracks, and values in cell are
            % mean skagg info per rat 
            skaggs_info = [skaggs_info; mean(place_fields_BAYESIAN.track(1).skaggs_info(place_fields_BAYESIAN.track(1).good_cells)); ...
                mean(place_fields_BAYESIAN.track(2).skaggs_info(place_fields_BAYESIAN.track(2).good_cells))];
        end
    end
end
end


function lap_dec_error = extract_lap_decoding_error
sessions = data_folders;
session_names = fieldnames(sessions);
decerr_1 = [];
decerr_2 = [];
for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    
    for s = 1: length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        load('track_decoding_error.mat')
        decerr_1 = [decerr_1, track_decoding_error(1).median_decoding_error];
        decerr_2 = [decerr_2, track_decoding_error(2).median_decoding_error];
    end
end
lap_dec_error = [decerr_1'; decerr_2'];
end


function [mean_units,thetaseq_units,mean_lap_skaggs,mean_lap_units] = extract_thetaseq_units
t1_mean_units = [];
t2_mean_units = [];
lap_t1_mean_units =[];
lap_t2_mean_units =[];
lap_t1_skaggs = [];
lap_t2_skaggs = [];
sessions = data_folders;
session_names = fieldnames(sessions);
c=1;
for p = 1 : length(session_names)
    folders = sessions.(sprintf('%s',cell2mat(session_names(p))));
    for s = 1: length(folders) % where 's' is a recorded session
        cd(cell2mat(folders(s)))
        load('Theta\theta_time_window.mat')
        load('Theta\theta_sequence_quantification.mat')
        load('extracted_laps.mat')
        load('extracted_directional_place_fields.mat')
        for t =  1 : 2 % only for the first 2 tracks
            thetaseq_idcs = [centered_averaged_thetaSeq.unidirectional(t).thetaseq(:).theta_window_index];
            thetaseq_units{c,t} = theta_windows.track(t).thetaseq_num_active_units(thetaseq_idcs);
            
            for lap = 1 : lap_times(t).number_completeLaps
                idx = find(theta_windows.track(t).theta_windows(thetaseq_idcs,1) >= lap_times(t).completeLaps_start(lap) &  ...
                    theta_windows.track(t).theta_windows(thetaseq_idcs,1) <= lap_times(t).completeLaps_stop(lap));
                lap_thetaseq_units(lap) = mean(theta_windows.track(t).thetaseq_num_active_units(thetaseq_idcs(idx)));
                lap_thetaseq_unitsID_c = theta_windows.track(t).thetaseq_idx_active_units(1,thetaseq_idcs(idx));
                lap_thetaseq_unitsID = unique(vertcat(lap_thetaseq_unitsID_c{:}));
                %check if it's using place fields of direction 1 or 2. In the future ideally use lap place fields
                for un = 1 : length(lap_thetaseq_unitsID)
                    if any(ismember(directional_place_fields(1).place_fields.track(t).good_cells,lap_thetaseq_unitsID(un)))
                        skaggs_info(un) = directional_place_fields(1).place_fields.track(t).skaggs_info(lap_thetaseq_unitsID(un));
                    elseif any(ismember(directional_place_fields(2).place_fields.track(t).good_cells,lap_thetaseq_unitsID(un)))
                        skaggs_info(un) = directional_place_fields(2).place_fields.track(t).skaggs_info(lap_thetaseq_unitsID(un));
                    else
                        continue
                    end
                end
                lap_skaggs(lap) = mean(skaggs_info);
            end
            if t == 1
                lap_t1_mean_units = [lap_t1_mean_units lap_thetaseq_units];
                lap_t1_skaggs = [lap_t1_skaggs lap_skaggs];
            else
                lap_t2_mean_units = [lap_t2_mean_units lap_thetaseq_units];
                lap_t2_skaggs = [lap_t2_skaggs lap_skaggs];
            end
            clear lap_skaggs lap_thetaseq_units
        end
        t1_mean_units = [t1_mean_units mean(thetaseq_units{c,1})];
        t2_mean_units = [t2_mean_units mean(thetaseq_units{c,2})];
        c = c+1;
    end
end
mean_units = [t1_mean_units'; t2_mean_units'];
mean_lap_units = [lap_t1_mean_units'; lap_t2_mean_units'];
mean_lap_skaggs = [lap_t1_skaggs'; lap_t2_skaggs'];

end

function [lap_track_speed,time_moving,prot_idics] = get_average_track_speed
load('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 1\Behaviour analysis\behavioural_data.mat')
lap_track_speed =[];
time_moving =[];
lap_ID = [];
prot_idics = [];
c=1;
for t = 1 : 2 %only first 2 tracks
    for s = 1 : size(lap_behaviour(t).moving_speed,1)
        lap_track_speed = [lap_track_speed; cell2mat([lap_behaviour(t).moving_speed(s,:)])'];
        time_moving = [time_moving; cell2mat([lap_behaviour(t).time_moving(s,:)])'];
        lap_ID = [lap_ID; [1:length(cell2mat([lap_behaviour(t).time_moving(s,:)]))]'];
        prot_idics = [prot_idics; 100; ones(length(cell2mat([lap_behaviour(t).moving_speed(s,:)])')-1,1)*c*t];% marks with 100 first laps
        c = c+1;
    end
end
end
