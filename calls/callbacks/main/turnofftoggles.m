function mainhandles = turnofftoggles(mainhandles,choice,restoreCursor)
% Turn other toggle buttons, but 'choice', off in the main window toolbar
%
%    Input:
%     mainhandles    - handles structure of the main window
%     choice         - 'D','A','E','L','Dminus','Aminus','DeleteMultiple'
%     restoreCursor  - 0/1 whether to restore cursor at end
%
%    Output:
%     mainhandles    - handles structure of the main window
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

if nargin<2
    choice = 'all';
end
if nargin<3
    restoreCursor = 1;
end

%% Turn off Toggled buttons

zoom(mainhandles.figure1,'off')
datacursormode(mainhandles.figure1,'off')
ok = 0;
warning off

if ~strcmpi(choice,'zoom')
    try delete(mainhandles.zoomwindowHandle), end
    mainhandles = guidata(mainhandles.figure1); % Get updated handles structure
end
if ~strcmpi(choice,'pixelregion')
    try delete(mainhandles.impixelregionWindowHandle), end
    mainhandles = guidata(mainhandles.figure1); % Get updated handles structure
end

if ~strcmpi(choice,'distance')
    try
        api = iptgetapi(mainhandles.distancetoolHandle);
        api.delete();
        mainhandles.distancetoolHandle = [];
        updatemainhandles(mainhandles)
    end
    mainhandles = guidata(mainhandles.figure1); % Get updated handles structure
end
if strcmp(get(mainhandles.Toolbar_AddDPeaks,'state'),'on') && ~strcmpi(choice,'D')
    set(mainhandles.Toolbar_AddDPeaks,'state','off')
    ok = 1;
end
if strcmp(get(mainhandles.Toolbar_AddAPeaks,'state'),'on') && ~strcmpi(choice,'A')
    set(mainhandles.Toolbar_AddAPeaks,'state','off')
    ok = 1;
end
if strcmp(get(mainhandles.Toolbar_AddEPeaks,'state'),'on') && ~strcmpi(choice,'E')
    set(mainhandles.Toolbar_AddEPeaks,'state','off')
    ok = 1;
end
% if strcmp(get(mainhandles.Toolbar_liveROI,'state'),'on') && ~strcmpi(choice,'L')
%     set(mainhandles.Toolbar_liveROI,'state','off')
%     ok = 1;
% end
if strcmp(get(mainhandles.Toolbar_DeleteDPeaks,'state'),'on') && ~strcmpi(choice,'Dminus')
    set(mainhandles.Toolbar_DeleteDPeaks,'state','off')
    ok = 1;
end
if strcmp(get(mainhandles.Toolbar_DeleteAPeaks,'state'),'on') && ~strcmpi(choice,'Aminus')
    set(mainhandles.Toolbar_DeleteAPeaks,'state','off')
    ok = 1;
end
if strcmp(get(mainhandles.Toolbar_DeleteMultiplePeaksToggle,'state'),'on') && ~strcmpi(choice,'DeleteMultiple')
    set(mainhandles.Toolbar_DeleteMultiplePeaksToggle,'state','off')
    mainhandles = turnofftoggles(mainhandles,'all');
    updatemainhandles(mainhandles) % Sends the mainhandle to appdata
    message = sprintf('-----------------------------------------\n%s\n%s\n%s\n-----------------------------------------\n\n',...
        'Ignore the error message below and continue what you were doing!',...
        'The error is forced on MATLAB by iSMS whenever you don''t click',...
        'in the image after the lasso-selection tool is selected.');
    terminateExecution()
    fprintf('%s',message)
    try uiresume(mainhandles.figure1), end
    pause(2) % Pause for up to 2 seconds to allow terminateExecution to finish
end

if ok
    drawnow
end
warning on

%% Make sure pointer is not stuck in some alternative form

if restoreCursor
    set(mainhandles.figure1, 'Pointer', mainhandles.functionHandles.cursorPointer);
end
mainhandles = guidata(mainhandles.figure1);

