function mainhandles = loadRecentSessionCallback(hObject,event,type,mainhandle,file)
% Callback for loading a recent session
%
%    Input:
%     hObject   - handle to the menu item
%     event     - not used
%     type      - 'session', 'movie'
%     mainhandle - handle to the main window
%     file      - fullfilename
%
%    Output:
%     mainhandles  - handles structure of the main window
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

if strcmpi(type,'session')
    % Open recent session
    mainhandles = opensession(mainhandle,file);

elseif strcmpi(type,'movie')

    % Open recent file
    mainhandles = guidata(mainhandle);
    mainhandles = loadDataCallback(mainhandles, 0, file);
end
