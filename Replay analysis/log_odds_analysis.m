% Script to calculate log-odds on already generated replay analysis
% Taken from Masa, modified by Pierre 2024

function [] = log_odds_analysis(folders,timebin,BAYSESIAN_NORMALIZED_ACROSS_TRACKS)

% Input:
% Folders: Each Folder is data for a session
% Timebin: 0.02 or 1
% 0.02 -> 20ms time bin
% 1 -> 1 event time bin
% posbin: [] or 1
% [] -> 20 position bin per track (will load extracted_place_field_BAYESIAN)
% 1 -> 1 position bin per track

% Output:
% log_odd: save the log odd - log(sum(probability of T1)/sum(probability of
% T2)) of the events that are considered significant according to the original bayesian decoding
% as well as the 1000 T1&T2 turning curve shuffles for each event
% It will also contain the session ID, 'ground truth' replay track ID and
% behavioral epoch (-1: PRE, 0: POST, 1: T1 RUN, 2: T2 RUN) and etc



end