function shuffle_type= shuffle_scoring(shuffled_struct,analysis_type,event_type)
% new function to score shuffles post hoc. allows rerunning of scores
% without having to redo the actual shuffles.
% will overwrite shuffled_tracks if exists

parameters= list_of_parameters;

if isempty(shuffled_struct)
    load('Bayesian controls\Only re-exposure\shuffled_decoded_events.mat');   
end

% if some scoring has already been done load - will overwrite preexistent
% scoring according to analysis type
if strcmp(event_type,'whole') && exist('shuffled_tracks.mat')==2  
    load('shuffled_tracks.mat');
    disp('overwriting scoring matrix');
elseif strcmp(event_type,'segments') && exist('shuffled_tracks_segments.mat')==2  
    load('shuffled_tracks_segments.mat')
    disp('overwriting scoring matrix');
else
    disp('scoring matrix not found, proceeding.')
end

% don't do spearman on shuffles
analysis_type(4)=0;

% create all the possible slopes (kernels) for your events
% takes advantage that there is a limited number of replay event lengths

tmp= cellfun(@(x) x(1,:), {shuffled_struct{1}.decoded_position},'UniformOutput',0);
unique_lengths= unique(cellfun(@(x) size(x,2),[tmp{:}]));
% min_tbins= min(cellfun(@(x) size(x,2),[tmp{:}]));
% max_tbins= max(cellfun(@(x) size(x,2),[tmp{:}]));
if analysis_type(1)==1 
        [all_tstLn,spd2Test]= construct_all_lines(unique_lengths);
end

num_shuffles_choices= length(shuffled_struct);
num_tracks= length(shuffled_struct{1});
num_shuffles= size(shuffled_struct{1}(1).decoded_position,1);

% split events by lengths, this speeds up the calculations for line fitting
for this_batch_events= 1:length(unique_lengths)
    for s=1:num_shuffles_choices
        for track=1:num_tracks
            decoded_lengths= cellfun(@(x) size(x,2), shuffled_struct{1}(track).decoded_position(1,:));
            batch_idx{track,this_batch_events}= find(decoded_lengths == unique_lengths(this_batch_events));
            decoded_pos_tmp(this_batch_events).shuffled_struct{s}(track).decoded_position(1:num_shuffles,1:length(batch_idx{track,this_batch_events}))= shuffled_struct{s}(track).decoded_position(1:num_shuffles,batch_idx{track,this_batch_events});
        end
    end
    tstLn_tmp(this_batch_events).all_tstLn= all_tstLn(this_batch_events);
end

p =gcp;
% now actually score the shuffles
tic;
    fprintf('events processed: ')
    for ii=1:length(unique_lengths)
        shuff_tmp(ii).shuffle_type= score_shuffle(decoded_pos_tmp(ii).shuffled_struct,tstLn_tmp(ii).all_tstLn,spd2Test,analysis_type);
        fprintf('\b');
        fprintf('%i%s ', round(100*ii/length(unique_lengths)),' %'); 
    end
 toc
 
    % reassign to original structure that is used in rest of pipeline
    for this_batch_events= 1:length(unique_lengths)
            for s=1:num_shuffles_choices
                if ~isempty(shuff_tmp(this_batch_events).shuffle_type{1})
                     for track=1:size(shuff_tmp(this_batch_events).shuffle_type{1}.shuffled_track,2)
                          if ~isempty(shuff_tmp(this_batch_events).shuffle_type{1}.shuffled_track(track).replay_events)
                                if analysis_type(1)
                                    [shuffle_type{s}.shuffled_track(track).replay_events(batch_idx{track,this_batch_events}).linear_score]= deal(shuff_tmp(this_batch_events).shuffle_type{s,1}.shuffled_track(track).replay_events.linear_score);
                                else
                                     [shuffle_type{s}.shuffled_track(track).replay_events(batch_idx{track,this_batch_events}).linear_score]= deal(NaN);
                                end
                                if analysis_type(2)
                                    [shuffle_type{s}.shuffled_track(track).replay_events(batch_idx{track,this_batch_events}).weighted_corr_score]= deal(shuff_tmp(this_batch_events).shuffle_type{s}.shuffled_track(track).replay_events.weighted_corr_score);
                                else
                                     [shuffle_type{s}.shuffled_track(track).replay_events(batch_idx{track,this_batch_events}).weighted_corr_score]= deal(NaN);
                                end
                                if analysis_type(3)
                                    [shuffle_type{s}.shuffled_track(track).replay_events(batch_idx{track,this_batch_events}).path_score]= deal(shuff_tmp(this_batch_events).shuffle_type{s}.shuffled_track(track).replay_events.path_score);
                                else
                                     [shuffle_type{s}.shuffled_track(track).replay_events(batch_idx{track,this_batch_events}).path_score]= deal(NaN);
                                end
                          end
                    end
                end
           end
    end
   
    % save structure with new scores
    if isempty(shuffled_struct)
        save('Bayesian controls\Only re-exposure\shuffled_tracks.mat','shuffle_type','-v7.3');
    end

end