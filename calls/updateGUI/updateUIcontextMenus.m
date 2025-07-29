function updateUIcontextMenus(mainhandle, ax)
% Creates the ui context menus for a given axes
%
%     Input:
%      mainhandle    - handle to the main window
%      ax            - handles to the axes (or graph objects in ax)
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

% Check input
if nargin<2 ...
        || (isempty(mainhandle) || ~ishandle(mainhandle))...
        || isempty(ax)
    return
end

%% Update

% Update context menu for all input axes handles
for i = 1:length(ax)
    
    % Handle i
    h = ax(i);
    
    % Create uicontext menu
    cm = uicontextmenu;
    
    % Create menu items
    if ispc
        uimenu(cm,'Label','Copy figure to clipboard.','Callback',{@copyfigtoclipboard, mainhandle, h})
        uimenu(cm,'Label','Copy data to clipboard.','Callback',{@copydatatoclipboard, mainhandle, h, 'clipboard'})
    else
        uimenu(cm,'Label','Copy figure to clipboard (Windows only).','Enable','off')
        uimenu(cm,'Label','Copy data to clipboard (Windows only).','Enable','off')
    end
    if ~isdeployed
        uimenu(cm,'Label','Copy data to workspace variable.','Callback',{@copydatatoclipboard, mainhandle, h, 'workspace'})
    end
    uimenu(cm,'Label','Export data to ASCII file (txt).','Callback',{@copydatatoclipboard, mainhandle, h, 'file'})
    uimenu(cm,'Label','Open figure in new window.','Callback',{@exportfigurewindow, mainhandle, h},'Separator','on')
    uimenu(cm,'Label','Set axis limits.','Callback',{@setaxlimits, mainhandle, h})
    
    % Update context menu
    try
        set(h, 'uicontextmenu',cm)
        
    catch err
        
        % Make sure its the current axes
        try
            % VERSION DEPENDENT SYNTAX
            mainhandles = guidata(mainhandle);
            if mainhandles.matver>8.3
                isAX = isgraphics(h,'axes');
            else
                isAX = strcmpi(get(h,'type'),'axes');
            end
            
            if isprop(h,'Type') && isAX
                fh = get(h,'parent');
                set(0,'currentfigure',fh)
                set(fh,'currentaxes',h)
            end
        end
        try
            set(h, 'uicontextmenu',cm)
        end
    end
end
