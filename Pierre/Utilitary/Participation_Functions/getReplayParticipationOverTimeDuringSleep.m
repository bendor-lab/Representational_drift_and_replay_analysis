% Function that gives the participation in nb of events of 
% a vector of cell, given a sleep session, the track decoded during replay, a list of significant RE and
% decoded RE

function [timestampsAll] = getReplayParticipationOverTimeDuringSleep(cellVector, sleepSession, replayedTrack, ...
                                                                         sleep_state, significantRE, decodedRE)

    if sleepSession == "PRE"
        SleepStart = sleep_state.state_time.PRE_start;
        SleepStop = sleep_state.state_time.PRE_end;
    elseif sleepSession == "POST1"
        SleepStart = sleep_state.state_time.INTER_post_start;
        SleepStop = sleep_state.state_time.INTER_post_end;
    else
        SleepStart = sleep_state.state_time.FINAL_post_start;
        SleepStop = sleep_state.state_time.FINAL_post_end;
    end
    
    % We get the ID of the significant replay events in this period
    
    goodSignReplayData = significantRE.track(replayedTrack);
    
    boolMatIsReplayPeriod = goodSignReplayData.event_times <= SleepStop & goodSignReplayData.event_times >= SleepStart;
    
    relevantReplayID = goodSignReplayData.index(boolMatIsReplayPeriod);
    
    goodDataDecode = decodedRE(replayedTrack).replay_events;
    
    goodDataDecode = goodDataDecode(ismember([goodDataDecode.replay_id], [relevantReplayID]));
    
    % We get the timestamps of each replay events including the cells
    timestampsAll = {};
    
    % We iterate through cells of our cell vector
    for cellID = cellVector
        % We get the subset of RE that contains our cell
        isContainingCell = cellfun(@(x) ismember(cellID, x(:, 1)), {goodDataDecode.spikes});
        % To timestamp, we take the first timebin 
        timestamps = cellfun(@(x) x(1), {goodDataDecode(isContainingCell).timebins_edges});
        % We add the timestamp to the main file
        timestampsAll = [timestampsAll; {timestamps}];
        
    end
    
end

