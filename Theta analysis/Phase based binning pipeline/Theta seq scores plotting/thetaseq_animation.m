
% CREATES GIFT OF THETA SEQUENCES 


t =3;
matrix = {centered_averaged_thetaSeq.unidirectional(t).thetaseq(500:500+2).relative_decoded_position}; %save decoded cycles in cells
matrix2 = cat(3,matrix{:}); % concatenate in a 3D matrix
mean_relative_position = mean(matrix2,3); % average all cycles

ax(1) = figure;%('visible','off');
imagesc(mean_relative_position)
colormap(jet);
title([num2str(1) ' sequences'])

f =  getframe(ax(1)) ;
[im,map] = rgb2ind(f.cdata,256,'nodither');
im(1,1,1,20) = 0;

j =2:1:30;
for i = 1 : length(j)
    %for t =  1: length(centered_averaged_thetaSeq.unidirectional)
    t=3;
    % Concatenate all windows
    matrix = {centered_averaged_thetaSeq.unidirectional(t).thetaseq(500:500+j(i)).relative_decoded_position}; %save decoded cycles in cells
    matrix2 = cat(3,matrix{:}); % concatenate in a 3D matrix
    mean_relative_position = mean(matrix2,3); % average all cycles
    
    ax(i) = figure('visible','off');
    imagesc(mean_relative_position)
    colormap(jet);
    title([num2str(i) ' sequences'])
    %gif
    f = getframe(ax(i)) ;
    im(:,:,1,i) = rgb2ind(f.cdata,map,'nodither');

    
    close all
    
    clear matrix matrix2 mean_relative_position
end
imwrite(im,map,'sequence.gif','DelayTime',0,'LoopCount',inf) %g443800
