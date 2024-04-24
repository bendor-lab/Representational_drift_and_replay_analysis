% Bayesian Bias analysis at the cell level.
% Mean bayesian bias for significant replay events vs. non-significant
% replay events
% The slope over time is also considered (Bollmann et al., 2023)
% Finally, we also consider the number of replay events.

clear

% PATH things
PATH.SCRIPT = fileparts(mfilename('fullpath'));
cd(PATH.SCRIPT)

sessions = data_folders_excl; % Use the function to get all the file paths

% Initiate the final files

sessionID = [];
animal = [];
condition = [];
track = [];
cell = [];
label = [];

bayesian_bias_sig = [];
bayesian_bias_nsig = [];
bayesian_slope_sig = [];
bayesian_slope_nsig = [];
total_replay = [];

% For each session

for fID = 1:length(sessions)

    file = sessions{fID};
    disp(fID);

    indentifier = fID * 1000;

    % Parse the name to get infos
    [animalOI, conditionOI] = parseNameFile(file); % We get the informations about the current data
    animalOI = string(animalOI);
    conditionOI = string(conditionOI);
    disp(conditionOI);

    % We load all the put. rep. ev EXP vs. REEXP

    temp = load(file + "\balanced_analysis\Replay_T1_vs_T3\decoded_replay_events");
    decoded_replay_eventsT1 = temp.decoded_replay_events;

    temp = load(file + "\balanced_analysis\Replay_T2_vs_T4\decoded_replay_events");
    decoded_replay_eventsT2 = temp.decoded_replay_events;

    temp = load(file + "\extracted_lap_place_fields");
    lap_place_fields = temp.lap_place_fields;

    % Load sleep data
    temp = load(file + "\extracted_sleep_state");
    sleep_state = temp.sleep_state;

    % We get the start / end of POST1
    startTime = sleep_state.state_time.INTER_post_start;
    endTime = sleep_state.state_time.INTER_post_end;

    % We get all the sleep replay events during POST1
    [sleepSWRID, timeSWR] = getAllSleepReplay(1, startTime, endTime, decoded_replay_eventsT1, sleep_state);

    for trackOI = 1:2

        if trackOI == 1
            decoded_replay_events = decoded_replay_eventsT1;
        else
            decoded_replay_events = decoded_replay_eventsT2;
        end

        goodPCRUN1 = lap_place_fields(trackOI).Complete_Lap{end}.good_cells;
        goodPCRUN2 = lap_place_fields(trackOI + 2).Complete_Lap{1}.good_cells;

        other_track = mod(trackOI + 1, 2) + mod(trackOI, 2)*2;

        goodPCRUN1Other = lap_place_fields(other_track).Complete_Lap{end}.good_cells;
        goodPCRUN2Other = lap_place_fields(other_track + 2).Complete_Lap{1}.good_cells;

        % We get all the significant replay events ID

        % We find all the significant replay events
        % path2get = [file, '\Replay_T', num2str(trackOI), '_vs_T', num2str(trackOI + 2)];
        path2get = [file, '\Replay\RUN1_Decoding'];
        path2get2 = [file, '\Replay\RUN2_Decoding'];

        temp = load(path2get + "\significant_replay_events_wcorr");
        significant_replay_eventsExp = temp.significant_replay_events;

        temp = load(path2get2 + "\significant_replay_events_wcorr");
        significant_replay_eventsReexp = temp.significant_replay_events;

        good_ids = union(significant_replay_eventsExp.track(trackOI).ref_index, ...
            significant_replay_eventsReexp.track(trackOI).ref_index);

        sleepIDSig = intersect(sleepSWRID, good_ids);
        timeRepSig = timeSWR(ismember(sleepSWRID, sleepIDSig));

        % We get the non significant replay ID (everything except current ID)

        sleepIDNsig = setdiff(sleepSWRID, sleepIDSig);
        timeRepNsig = timeSWR(ismember(sleepSWRID, sleepIDNsig));

        % We get all the cells that fired during SWR

        allSpikes = {decoded_replay_events(1).replay_events(sleepSWRID).spikes};
        allSpikesConc = vertcat(allSpikes{:});
        allCells = allSpikesConc(:, 1);
        uniqueCells = unique(allCells);

        isGoodPCRUN1 = ismember(uniqueCells, goodPCRUN1);
        isGoodPCRUN2 = ismember(uniqueCells, goodPCRUN2);

        current_label = repelem("Unstable", 1,numel(uniqueCells));
        current_label(isGoodPCRUN1 & isGoodPCRUN2)= "Stable";
        current_label(isGoodPCRUN1 & ~isGoodPCRUN2 & goodPCRUN2Other)= "Disappear";
        current_label(~isGoodPCRUN1 & isGoodPCRUN2 & goodPCRUN1Other)= "Appear";

        for cID = 1:numel(uniqueCells)
            current_cell = uniqueCells(cID);

            % We get the events where that cell fired
            boolFired = cellfun(@(x) any(x(:, 1) == current_cell), allSpikes);

            % We find the sig. events and the non-sig events
            participationID = sleepSWRID(boolFired);
            currentSigID = intersect(sleepIDSig, participationID);
            currentNsigID = intersect(sleepIDNsig, participationID);

            % SIG ------

            current_nb_replay = numel(currentSigID);

            if ~isempty(currentSigID)
                allSigDecPosExp = {decoded_replay_events(1).replay_events(currentSigID).decoded_position};
                allSigDecPosReexp = {decoded_replay_events(2).replay_events(currentSigID).decoded_position};
    
                allTimeSig = {decoded_replay_events(1).replay_events(currentSigID).timebins_edges};
                allTimeSig = cellfun(@(x) x(1), allTimeSig);
            else
                allSigDecPosExp = {NaN};
                allSigDecPosReexp = {NaN};
                allTimeSig = NaN;
            end

            all_bb_sig = cellfun(@(x, y) (sum(sum(y))-sum(sum(x)))/(sum(sum(y))+sum(sum(x))), ...
                allSigDecPosExp, allSigDecPosReexp);

            allTimeSig = [ones(size(allTimeSig)); allTimeSig]; % We allow for an intercept
            current_slope_sig = allTimeSig'\all_bb_sig'; % Least square reg.

            current_slope_sig = current_slope_sig(2);
            
            current_bb_sig = mean(all_bb_sig, 'omitnan');

            % NSIG ------
            
            if ~isempty(currentNsigID)
                allNsigDecPosExp = {decoded_replay_events(1).replay_events(currentNsigID).decoded_position};
                allNsigDecPosReexp = {decoded_replay_events(2).replay_events(currentNsigID).decoded_position};
    
                allTimeNsig = {decoded_replay_events(1).replay_events(currentNsigID).timebins_edges};
                allTimeNsig = cellfun(@(x) x(1), allTimeNsig);
            else
                allNsigDecPosExp = {NaN};
                allNsigDecPosReexp = {NaN};
                allTimeNsig = NaN;
            end

            all_bb_nsig = cellfun(@(x, y) (sum(sum(y))-sum(sum(x)))/(sum(sum(y))+sum(sum(x))), ...
                allNsigDecPosExp, allNsigDecPosReexp);

            allTimeNsig = [ones(size(allTimeNsig)); allTimeNsig]; % We allow for an intercept
            current_slope_nsig = allTimeNsig'\all_bb_nsig'; % Least square reg.
            current_slope_nsig = current_slope_nsig(2);
            current_bb_nsig = mean(all_bb_nsig, 'omitnan');

            sessionID = [sessionID; fID];
            animal = [animal; animalOI];
            condition = [condition; conditionOI];
            track = [track; trackOI];
            cell = [cell; current_cell + indentifier];
            label = [label; current_label(cID)];
            bayesian_bias_sig = [bayesian_bias_sig; current_bb_sig];
            bayesian_bias_nsig = [bayesian_bias_nsig; current_bb_nsig];
            bayesian_slope_sig = [bayesian_slope_sig; current_slope_sig];
            bayesian_slope_nsig = [bayesian_slope_nsig; current_slope_nsig];
            total_replay = [total_replay; current_nb_replay];

        end
    end
end

condition(track == 1) = 16;
newConditions = split(condition(track ~= 1), 'x');
condition(track ~= 1) = newConditions(:, 2);
condition = str2double(condition);

bb_data = table(sessionID, animal, condition, cell, label, bayesian_bias_sig, bayesian_bias_nsig, ...
             bayesian_slope_sig, bayesian_slope_nsig, total_replay);

save("bayesian_bias_cell.mat", "bb_data")

%% 

tiledlayout(2, 1)
nexttile;
histogram(bb_data.bayesian_bias_sig, 100)
hold on;
histogram(bb_data.bayesian_bias_nsig, 100)

nexttile;
histogram(bb_data.bayesian_slope_sig, 1000)
hold on;
histogram(bb_data.bayesian_slope_nsig, 1000)
xlim([-0.0007 0.0007])

figure;
allConditions = [1 2 3 4 8 16];
tiledlayout(6, 1)
h = [];
for cID = 1:numel(allConditions)
    n = nexttile;
    h(end + 1) = n;
    current_cond = allConditions(cID);
    histogram(bb_data.bayesian_bias_sig(bb_data.condition == current_cond))
    hold on;
    xline(mean(bb_data.bayesian_bias_sig(bb_data.condition == current_cond), 'omitnan'))
end

linkaxes(h)

boxchart(bb_data.condition, bb_data.bayesian_slope_sig)

%% 
hist(categorical(bb_data.label))
boxchart(categorical(bb_data.label), bb_data.total_replay)
