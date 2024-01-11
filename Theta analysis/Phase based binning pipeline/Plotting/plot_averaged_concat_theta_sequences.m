% PLOTS AVERAGE THETA SEQUENCES 
% Plots average theta sequences per track and direction. Plots single
% sequence, in groups and log groups.
% INPUT:
    % centered_averaged_thetaSeq: if empty, loads the file from the current folder


function plot_averaged_concat_theta_sequences(centered_averaged_thetaSeq,centered_averaged_CONCAT_thetaSeq)

if isempty(centered_averaged_thetaSeq)
    load Theta\theta_sequence_quantification.mat
end

f1 = figure;
f2 = figure;
f3 = figure;

c = 1;

fields = fieldnames(centered_averaged_thetaSeq);
for d = 1 : length(fields)
    for t =  1: length(centered_averaged_thetaSeq.(strcat(fields{d})))
        
        figure(f1)
        subplot(3,4,c)
        imagesc(flipud(centered_averaged_thetaSeq.(strcat(fields{d}))(t).mean_relative_position));colormap(jet)
        ylabel('Relative decoded position (cm)')
        xlabel('Time')
        colorbar 
        
        figure(f2)
        subplot(3,4,c)
        imagesc(flipud(centered_averaged_CONCAT_thetaSeq.(strcat(fields{d}))(t).mean_relative_position));colormap(jet)
        ylabel('Relative decoded position (cm)')
        xlabel('Time')
        colorbar
        
        figure(f3)
        subplot(3,4,c)
        cycle = centered_averaged_CONCAT_thetaSeq.(strcat(fields{d}))(t).mean_relative_position;
        cycle(cycle < 0.005) = 0.005;
        cycle(cycle > 0.08) = 0.08;
        imagesc(flipud(log2(cycle))); colormap(jet)
        %imagesc(flipud(log2(centered_averaged_CONCAT_thetaSeq.(strcat(fields{d}))(t).mean_relative_position)));colormap(jet)
        ylabel('Relative decoded position (cm)')
        xlabel('Time')
        colorbar

        
        c =  c+1;
    end
end


end