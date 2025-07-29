function autocontrastCallback(hObject, event, mainhandle, ax, hrectField)
% Callback for copying plotted data to clipboard
%
%    Input:
%     hObject   - handle to the menu object
%     event     - unused eventdata
%     handles   - handles structure of the main window
%     ax        - handle to the axes with the context menu
%     hrectField - fieldname of rectangle handle
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

if nargin<3 || isempty(mainhandle) || nargin<4
    mainhandle = getappdata(0,'mainhandle');
    mainhandles = guidata(mainhandle);
    return
end
if nargin<5
    choice = 'clipboard';
end

% Get mainhandles structure
mainhandles = guidata(mainhandle);

% Check its an axes handle, elseif graph obj grap parent axes
if (~isprop(ax,'Type') || ~strcmpi(get(ax,'type'),'axes')) ...
        && ishghandle(ax)
    ax = get(ax,'parent');
end

if (~isprop(ax,'Type') || ~strcmpi(get(ax,'type'),'axes'))
    return
end

%% Get handle to imrect slider

% Get handle to imrect
himrect = mainhandles.(hrectField);

% Get handle to bar hist plot
hBar = findobj(ax,'-property','BarWidth');
if isempty(hBar)
    return
end

% Get bar data
xdata = get(hBar,'xdata');
x1 = min(xdata(:));
x2 = max(xdata(:));

% Set new imrect position
if x2>x1
    pos = [x1 -5 x2-x1 15];
    setPosition(himrect,pos)
end
