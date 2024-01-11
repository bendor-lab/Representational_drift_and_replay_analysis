

function decoded_thetaSeq = remove_nospikes

load Theta\decoded_theta_sequences.mat
load Theta\theta_time_window.mat

fields = fieldnames(decoded_thetaSeq);
fields = fields(cellfun(@(s) isempty(strmatch ('phase', s)), fieldnames(decoded_thetaSeq)));

for d = 1 : length(fields)
    for t = 1 : length(decoded_thetaSeq.(sprintf('%s',fields{d})))
        for seq = 1 : length(decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences)
            modified_decoded_event = decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(seq).decoded_position;
            idx = decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(seq).index_from_theta_windows;
            no_spikes_column = find(sum(theta_windows.track(t).event_spike_count{1,idx},1)==0);
            if ~isempty(no_spikes_column)
                modified_decoded_event(:,no_spikes_column) = zeros(size(modified_decoded_event(:,no_spikes_column)));
                decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(seq).decoded_position = modified_decoded_event;
                decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(seq).remove_nospike_columns = 1;
            else
                decoded_thetaSeq.(sprintf('%s',fields{d}))(t).theta_sequences(seq).remove_nospike_columns = 0;
            end
        end
    end
end

end