function set_colorbar_position(cb,axpos,position_desc)

%
% set_colorbar_position(cb,axpos,position_desc)
%
% cb = colorbar handle
% axpos = [x y w h] original position of axis i.e. before colorbar added (in cm)
% position_desc = 'right', 'right-top'
%

cb.Units = 'centimeters';

switch position_desc
    case 'right'
        cbpos(1) = axpos(1) + axpos(3) + 0.1;
        cbpos(2) = axpos(2);
        cbpos(3) = 0.5;
        cbpos(4) = axpos(4);
        
    case 'right-top'       
        cbpos(1) = axpos(1) + axpos(3) + 0.1;
        cbpos(2) = axpos(2) + 0.5*axpos(4);
        cbpos(3) = 0.5;
        cbpos(4) = 0.5*axpos(4);
        
end

set(cb,'position',cbpos)