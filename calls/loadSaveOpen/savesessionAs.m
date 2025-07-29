function mainhandles = savesessionAs(mainhandle)
% Opens a dialog for specyfing session name and saves session to file
%
%    Input:
%     mainhandle   - handle to the main figure window
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

% Get mainhandles structure
if (isempty(mainhandle)) || (~ishandle(mainhandle))
    mainhandles = [];
    return
else
    mainhandles = guidata(mainhandle);
end

% Get state structure
[state,mainhandles] = savestate(mainhandles.figure1, mainhandles.FRETpairwindowHandle, mainhandles.histogramwindowHandle);

%% Open a save as dialog box

fileformats = {'*.iSMSsession', 'iSMS session files'; '*.mat', 'Old session files'; '*.*', 'All files'};
[file, path, chose] = uiputfile3(mainhandles,'session',fileformats,'Save session as','name.iSMSsession');
if chose == 0
    return
end
mainhandles.filename = fullfile(path,file);

% Set figure window title
set(mainhandles.figure1,'Name',sprintf('iSMS - smFRET software on immobilized molecules.  Session: %s',mainhandles.filename))

% Turn on waitbar
hWaitbar = mywaitbar(1,'Saving session. Please wait...','name','iSMS');
movegui(hWaitbar,'north')

%% Save file

g = whos('state');
if g.bytes/1073741824>=2 % If state is larger than 2 Gb, use compression
    save(mainhandles.filename,'state','-v7.3');
else
    save(mainhandles.filename,'state');
end
set(mainhandles.mboard,'String',sprintf('Session saved to:\n%s\n\nNote that the raw movies are not saved but must be reloaded upon opening the session.',mainhandles.filename))

% Save recent files list
updateRecentFiles(mainhandles, path, file, 'session');

% Close waitbar
delete(hWaitbar)

%% Update

updatemainhandles(mainhandles)
