% PLOTS AVERAGE THETA SEQUENCES 
% Plots average theta sequences per track and direction. Plots single
% sequence, in groups and log groups.
% INPUT:
    % centered_averaged_thetaSeq: if empty, loads the file from the current folder


function plot_averaged_concat_theta_sequences(centered_averaged_thetaSeq,centered_averaged_CONCAT_thetaSeq,save_option)

if isempty(centered_averaged_thetaSeq)
    load Theta\theta_sequence_quantification.mat
end

folder = strsplit(pwd,'\');
session = [folder{end-1} '_' folder{end}(end-3:end)];

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
f1.Name = ['Raw average theta seq_' session];
f2 = figure('units','normalized','outerposition',[0 0 1 1]);
f2.Name = ['Raw concat average theta seq_' session];
f3 = figure('units','normalized','outerposition',[0 0 1 1]);
f3.Name = ['Smoothed concat average theta seq_' session];


c = 1;

fields = fieldnames(centered_averaged_thetaSeq);
for d = 1 : length(fields)
    for t =  1: length(centered_averaged_thetaSeq.(strcat(fields{d})))
        
        figure(f1)
        subplot(3,4,c)
        imagesc(flipud(centered_averaged_thetaSeq.(strcat(fields{d}))(t).mean_relative_position));colormap(jet)
        yticks([1 20 40])
        yticklabels({'40','0','-40'})
        ylabel('Position (cm)')
        xticks([2,7])
        xticklabels({'0','\pi'})
        xlabel('Phase')
        colorbar
        
        if ~isempty(centered_averaged_CONCAT_thetaSeq)
            figure(f2)
            subplot(3,4,c)
            imagesc(flipud(centered_averaged_CONCAT_thetaSeq.(strcat(fields{d}))(t).mean_relative_position));colormap(jet)
            yticks([1 20 40])
            yticklabels({'40','0','-40'})
            ylabel('Position (cm)')
            xticks([2,7,12,17,22,27])
            xticklabels({'-2\pi','-\pi','0','\pi','2\pi','5\pi/2'})
            xlabel('Phase')
            colorbar
            
            figure(f3)
            subplot(3,4,c)
            cycle = centered_averaged_CONCAT_thetaSeq.(strcat(fields{d}))(t).mean_relative_position;
            cycle(cycle < 0.005) = 0.005;
            smoothed = imgaussfilt((cycle),0.8);            
            imagesc(flipud(smoothed)); colormap(jet)
            %cb = colorbar;
            %smoothed(smoothed > str2double(cb.TickLabels{end})) = str2double(cb.TickLabels{end});
            %imagesc(flipud(smoothed)); colormap(jet)
            colorbar
            yticks([1 20 40])
            yticklabels({'40','0','-40'})
            ylabel('Position (cm)')
            xticks([2,7,12,17,22,27])
            xticklabels({'-2\pi','-\pi','0','\pi','2\pi','5\pi/2'})
            xlabel('Phase')
        end
        
        
        c =  c+1;
    end
end

if  strcmp(save_option,'Y')
        save_all_figures('X:\BendorLab\Drobo\Lab Members\Marta\Analysis\HIPP\Chapter 3\Averaged theta sequences',[])
end
end