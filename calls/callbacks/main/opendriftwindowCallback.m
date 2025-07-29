function mainhandles = opendriftwindowCallback(mainhandles)
% Callback for opening the drift window from the main window
%
%    Input:
%     mainhandles   - handles structure of the main window
%
%    Output:
%     mainhandles   - ..
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

mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar

% If already open
if ~isempty(mainhandles.driftwindowHandle) && ishandle(mainhandles.driftwindowHandle)
    set(mainhandles.mboard,'String','The drift window is already open.')
    figure(mainhandles.driftwindowHandle)
    return
end

%% Open

setappdata(0,'mainhandle',mainhandles.figure1)
mainhandles.driftwindowHandle = driftWindow;
guidata(mainhandles.figure1,mainhandles)

% Set checkbox to on
set(mainhandles.Tools_DriftAnalysisWindow,'Checked','on')

