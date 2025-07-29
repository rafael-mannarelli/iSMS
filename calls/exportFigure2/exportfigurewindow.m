function exportfigurewindow(hObject,event,mainhandle,ax)
% Callback for opening an axes in a new figure window
%
%    Input:
%     hObject   - handle to the menu object
%     event     - unused eventdata
%     handles   - handles structure of the main window
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

% Temporary window
hf = copywindow(mainhandles, ax, 1);

% Store the handle in order to delete it down when closing the program
mainhandles.figures{end+1} = hf;
updatemainhandles(mainhandles)
