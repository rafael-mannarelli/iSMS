function cwHandles = turnofftogglesCorrectionWindow(cwHandles,choice)
% Turns of all toggle buttons from the toolbar in the correction factor
% window
%
%    Input:
%     cwHandles    - handles structure of the correction factor window
%     choice       - 'all'
%
%    Output:
%     cwHandles    - ..
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

zoom(cwHandles.figure1,'off')
datacursormode(cwHandles.figure1,'off')
if nargin<2
    choice = 'all';
end
ok = 0;

%% Turn off

if (~strcmpi(choice,'ti')) && strcmp(get(cwHandles.Toolbar_SetTimeInterval,'state'),'on')
    set(cwHandles.Toolbar_SetTimeInterval,'state','off')
    ok = 1;
end

% Get updated FRETpairwindowHandles
if ok
    cwHandles = guidata(cwHandles.figure1); % Get updated handles structure
end

%% Make sure pointer is not stuck in some alternative form

set(cwHandles.figure1, 'Pointer', cwHandles.functionHandles.cursorPointer);
cwHandles = guidata(cwHandles.figure1);
