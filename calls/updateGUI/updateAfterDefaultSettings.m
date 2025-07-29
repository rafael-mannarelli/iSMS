function mainhandles = updateAfterDefaultSettings(mainhandle)
% Updates all GUIs after a new settings structure has been loaded
%
%    Input:
%     mainhandle   - handle to the main window
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

%% Initialize

% Check input
if isempty(mainhandle) || ~ishandle(mainhandle)
    mainhandle = getappdata(0,'mainhandle');
end

% Get mainhandles structure
mainhandles = guidata(mainhandle);

% Close open windows
mainhandles = closeWindows(mainhandles);

%% Update main window
mainhandles = updatePeakthresholdsEditbox(mainhandles, 2);

%% Update FRET pair window
