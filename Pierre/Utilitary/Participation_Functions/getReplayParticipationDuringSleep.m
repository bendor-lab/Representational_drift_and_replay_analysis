% Function that gives the participation in nb of events of 
% a vector of cell, given a sleep session, the track decoded during replay, a list of significant RE and
% decoded RE

function [activation_vector] = getReplayParticipationDuringSleep(cellVector, sleepSession, replayedTrack, ...
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
    
    % We find the corresponding cell data in decoded (more info than
    % significant file)
    
    allSpikesCells = {decodedRE(replayedTrack).replay_events(relevantReplayID).spikes};
    
    concatAllCellsInv = []; % We initiate the table with an impossible cell ID, will disappear
    
    for RE = allSpikesCells
        temp = RE{1};
        concatAllCellsInv = [concatAllCellsInv; unique(temp(:, 1))]; % Unique gives only one RE to unique cells, without you count spikes.
    end
    
    [nbSpikesPeriod, cellPeriod] = groupcounts(concatAllCellsInv);
    
    nbSpikesPeriod = nbSpikesPeriod(ismember(cellPeriod, cellVector));
    
    cellPeriod = cellPeriod(ismember(cellPeriod, cellVector));
    
    [~, position] = ismember(cellPeriod, cellVector);
    
    activation_vector = repelem(0, length(cellVector));
    
    activation_vector(position) = nbSpikesPeriod;
    
end

