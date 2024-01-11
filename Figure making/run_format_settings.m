

function run_format_settings(figure_handle,varargin)%axis_handle
%varargin - settings that are not for the main figure
% match_ax, match_Xax, match_Yax: match limits of multiple axes. Can choose both, or only X or Y
% ...any other type of figure that doesn't run with the main settings

%%%% Load settings
form = formatting_settings;
fieldsform = fields(form);
%ax = axis_handle;
if isempty(figure_handle)
    f = gcf;
else
    f = figure_handle;
end
allax = findall(f,'type','axes');
redo_ax = 0;

% Find if there are insets
inset_ax= [];
for k = 1 : length(allax) %find axis indx of inset
    idx = find(1: length(allax) ~= k);
    inset_ax = [inset_ax idx(cell2mat(arrayfun(@(x)  allax(k).Position(1) < allax(x).Position(1) &  allax(k).Position(2) < allax(x).Position(2) &...
        (allax(k).Position(1)+allax(k).Position(3)) >= (allax(x).Position(1)+allax(x).Position(3)),idx,'UniformOutput',0)))];
    % &  (allax(k).Position(2)+allax(k).Position(4)) <=  (allax(x).Position(2)+allax(x).Position(4))
end
if ~isempty(inset_ax)
    main_ax = find(~ismember(1: length(allax),unique(inset_ax))); %exclude axis indx of inset
else
    main_ax = 1: length(allax);
end

%%%%% General figure settings
box off
if ~isempty(ax.Colorbar) % change colorbar settings, if exists
    ax.Colorbar.Ticks = linspace(ax.Colorbar.Ticks(1),ax.Colorbar.Ticks(end),form.ColorbarTicks);
    ax.Colorbar.TickLabels = num2cell(ax.Colorbar.Ticks);
    ax.Colorbar.FontSize = form.FontSize;
    ax.Colorbar.FontName = form.FontName;
end

%%%% Find settings that refer to axis properties
prop_idx = find(cell2mat(arrayfun(@(x) isprop(ax,fieldsform{x}), 1:length(fieldsform),'UniformOutput',0)));
%non_prop_idx = setdiff(1:length(fieldsform), prop_idx);


if ~isempty(varargin)
    
    % Find indices of axes that share X or Y labels
    xl = arrayfun(@(x) allax(x).XLabel.String, main_ax,'UniformOutput',0);
    [~,ia] = ismember(xl,ax.XLabel.String);
    lnk_ax = main_ax(logical(ia));
    yl = arrayfun(@(x) allax(x).YLabel.String, main_ax,'UniformOutput',0);
    [~,ib] = ismember(yl,ax.YLabel.String);
    lnk_ay = main_ax(logical(ib));
    
    if length(allax) > 1 & strcmp(varargin,'match_ax') |  strcmp(varargin,'match_Xax') % match X axes limits
        lims = [allax(lnk_ax).XLim];
        [~,mxid] = max(lims);
        [~,mnid] = min(lims);
        [allax(lnk_ax).XLim] = deal([lims(mnid) lims(mxid)]);
        redo_ax = 1;
    end
    if length(allax) > 1 & strcmp(varargin,'match_ax') |  strcmp(varargin,'match_Yax') % match Y axes limits
        lims = [allax(lnk_ay).YLim];
        [~,mxid] = max(lims);
        [~,mnid] = min(lims);
        [allax(lnk_ay).YLim] = deal([lims(mnid) lims(mxid)]);
        redo_ax = 1;
    end
end


%%%% Apply axis settings
if any(ax == allax(main_ax))
    for k = 1 : length(prop_idx)
        set(ax,fieldsform{prop_idx(k)},form.(sprintf('%s',fieldsform{prop_idx(k)})))
    end
    num_yticks = form.NumYTicks;
    num_xticks = form.NumXTicks;
    if redo_ax == 1
        Yax_id = allax(lnk_ay);
        Xax_id = allax(lnk_ax); %main_ax
    else
        Yax_id = ax;
        Xax_id = ax;
    end
    
    
    
    
elseif any(ax == allax(inset_ax)) %if inset
    
    subf = fields(form.inset);
    subf_prop = find(cell2mat(arrayfun(@(x) isprop(ax,subf{x}), 1:length(subf),'UniformOutput',0)));
    subf = subf(subf_prop);
    for j = 1 : length(subf)
        set(ax,subf{j},form.inset.(sprintf('%s',subf{j})))
        xl = get(ax,'xlabel');
        yl = get(ax,'ylabel');
    end
    num_yticks = form.inset.NumYTicks;
    num_xticks = form.inset.NumXTicks;
    Yax_id = ax;
    Xax_id = ax;
end

%%% Adjust axes ticks
for j = 1 : length(Yax_id)
    ax = Yax_id(j);
    if length(ax.YTick) > num_yticks
        new_Yticks = linspace(min(ylim(ax)),max(ylim(ax)),num_yticks);
        if new_Yticks(2) < 0 & any(new_Yticks~=0) %if Y axis starts negative, make sure a tick is zero
            
            [~,mnid] = min(abs(new_Yticks));
            new_spacing = (0 - new_Yticks(1))/(mnid-1);
            new_ticks_sp = new_Yticks(1):new_spacing:new_Yticks(end);
            ax.YTick = new_ticks_sp;
        else
            ax.YTick = new_Yticks;
        end
    end
%     if sum(mod(ax.YTick,1))>0 % decimal
%         ytickformat(form.tickformat_dec);
%     else
%         ytickformat(form.tickformat);
%     end
    
end

for  j = 1 : length(Xax_id)
    ax = Xax_id(j);
    if length(ax.XTick) > num_xticks
        new_Xticks = linspace(min(xlim(ax)),max(xlim(ax)),num_xticks);
        if new_Xticks(2) < 0 & any(new_Xticks~=0) %if X axis starts negative, make sure a tick is zero
            [~,mnid] = min(abs(new_Xticks));
            new_spacing = (0 - new_Xticks(1))/(mnid-1);
            new_ticks_sp = new_Xticks(1):new_spacing:max(xlim(ax));%new_Xticks(end);
            ax.XTick = new_ticks_sp;
        else
            ax.XTick = new_Xticks;
        end
    end
%     if sum(mod(new_Xticks,1))>0 % decimal
%         xtickformat(form.tickformat_dec);
%     else
%         xtickformat(form.tickformat);
%     end
    
end


end

