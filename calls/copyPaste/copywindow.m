function hfig = copywindow(handles,ax,vis)
% Copies the graph window to a new figure window and returns it's handle
%
%    Input:
%     handles    - handles structure of the main window
%     ax         - handle to axes
%     vis        - 0/1 whether to show figure, or make it hidden
% 
%    Output:
%     hfig       - handle to the created window
%

% --- Copyrights (C) ---
%
% This file is part of:
% iSMS - Single-molecule FRET microscopy software
% Copyright (C) Aarhus University, @ V. Birkedal Lab
% <http://isms.au.dk>
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     The GNU General Public License is found at
%     <http://www.gnu.org/licenses/gpl.html>.

%% Initialize

if nargin<3
    vis = 1;
end

%% Make figure

hfig = figure;%('units','characters','position',fpos);
if ~vis
    set(hfig,'Visible','off',...
        'Toolbar','none',...
        'Menubar', 'none')
else
    updatelogo(hfig)
end
% setpixelposition(hfig,[fpos])
ax1 = gca; % Abs ax
% ax2 = axes('Position',get(ax1,'Position')); % Em ax

% Copy axes and legends into new figure
copyaxs(ax,ax1,true);

s = getpixelposition(ax);
setpixelposition(hfig,s)
set(ax1,'units','normalized','outerposition',[0 0 0.95 0.95])

% copyaxes(handles.EmWindow,ax2,true);

%% Set figure properties according to settings

% Size ans position
% setpixelposition(hfig,[100 100 handles.settings.export.width handles.settings.export.height])
% 
% % Get line objects
% h = findobj(hfig,'type','line');
% for i = 1:length(h)
%     set(h(i),'linewidth',handles.settings.export.linewidth)
% end
% 
% % labels
% ax = allchild(hfig);
% ax = findobj(ax,'type','ax');
% for i = 1:length(ax)
%     set(ax(i),'FontSize',handles.settings.export.labelsize)
%     
%     set(ax(i),'ActivePositionProperty','OuterPosition','OuterPosition',[0 0 1 1])
%     if i == 1
%         setFigSize(ax(i))
%     end
%     set(ax(i),'OuterPosition',[0 0 1 1])
%     
%     h = get(ax(i),'xlabel');
%     set(h,'FontSize',handles.settings.export.labelsize)
% 
%     h = get(ax(i),'ylabel');
%     set(h,'FontSize',handles.settings.export.labelsize)
% end
% 
% %% Legend
% 
% leg = findobj(handles.figure1,'Type','axes','Tag','legend'); % Legend handle
% 
% if length(leg)==1
%     
%     if (isempty(get(handles.AbsWindow,'YTick')))
%         % Its em legend
%         l = legend(ax2,get(leg(1),'String'),1);
%     else
%         % Its abs legend
%         l = legend(ax1,get(leg(1),'String'),2);
%     end
%     
%     % Set position
%     set(l,'location','northeast')
%     set(l,'Color','w')
% 
% elseif length(leg)==2
%     
%     % abs legend
%     l = legend(ax1,get(leg(1),'String'));
%     set(l,'location','northwest')
%     set(l,'Color','w')
%     
%     % em legend
%     l = legend(ax2,get(leg(2),'String'));
%     set(l,'location','northeast')
%     set(l,'Color','w')
%     
% end
% 
% % Move fig to center
% if vis
%     movegui(hfig,'center')
% end

% set(ax1,'units','normalized') % Allow auto-resize
% set(ax2,'units','normalized')
% if isdeployed
%     set(hfig,'Toolbar','figure');
% end

%% Nested

    function setFigSize(ax)
        fpos = getpixelposition(hfig);
        apos = getpixelposition(ax);
        d = [handles.settings.export.width handles.settings.export.height] - apos(3:4);
        pos2 = [fpos(1:2) fpos(3)-d(1) fpos(4)-d(2)];
        setpixelposition(hfig,round(pos2))
    end
end