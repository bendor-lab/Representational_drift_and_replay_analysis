% PLOT DECODING ERROR IN THETA WINDOWS
% MH, 2020
% Plots decoding error per track (rows) and directions (columns)
% INPUT - thresholded_decoded_thetaSeq_option: 1 if using theta sequences that have passed the position threshold (not happening neither at the
% start or end of track)

function plot_theta_sequences_decoding_error(thresholded_decoded_thetaSeq_option)

cd([pwd '\Theta'])
if thresholded_decoded_thetaSeq_option == 1
    load thetaSequences_decodingError_thresholded.mat
else
    load thetaSequences_decodingError.mat
end
cd ..

PP = plotting_parameters;

folder = pwd;
protocol = str2num(folder(end));
protocols = [8,4,3,2,1];
curr_prot = find(protocols == protocol);

f1 = figure;
c = [1,3,5,7,2,4,6,8];
i =1;
for d = 1 : length(thetaSequences_decodingError) % for each direction
     
    thetaseq = thetaSequences_decodingError(d).bayesian_decodingError;
    
    for t = 1 : length(thetaseq) % for each track
        
        average_decoding_errors = mean(thetaseq(t).all_decoded_errors,1);
        
        ax(c(i)) = subplot(4,2,c(i));
        hold on
        plot(average_decoding_errors,'Color',PP.P(curr_prot).colorT(t,:),'LineWidth',PP.Linewidth{t},'LineStyle',PP.Linestyle{t})
        xlabel('Time'); xticks([0:10:40])
        ylabel('Decoding error (cm)') ; 
        title(['Track ' num2str(t)])
        ax(c(i)).FontSize = 14;
        
        i = i+1;
    end
    
end

linkaxes([ax(1) ax(2) ax(3) ax(4) ax(5) ax(6) ax(7) ax(8)],'y')

for jj = 1 : length(c)
    plot(ax(jj),[20.5 20.5],[min(ylim) max(ylim)],':','Color',[0.5 0.5 0.5],'LineWidth',3)
end

end 