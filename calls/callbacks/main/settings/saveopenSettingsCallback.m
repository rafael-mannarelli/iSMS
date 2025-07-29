function mainhandles = saveopenSettingsCallback(mainhandles)
% Callback for setting settings for opening/saving sessions
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

mainhandles = turnofftoggles(mainhandles,'all'); % Turn off all interactive toggle buttons in the toolbar

%% Dialog

name = 'Settings for saving';

% Make prompt structure
prompt = {'Options for saving sessions:  ' '';...
    'Save ROI movies (raw data) ' 'saveROImovies';...
    'Options for loading sessions:  ' '';...
    'Ask to reload raw data  ' 'askforraw';...
    'Open sub windows too (trace window, etc.) ' 'opensubGUIs';...
    'Apply saved window size and position  ' 'setwindowSize' };

% Make formats structure
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

formats(2,1).type = 'text';
formats(3,1).type = 'check';
formats(5,1).type = 'text';
formats(6,1).type = 'check';
formats(7,1).type = 'check';
formats(8,1).type = 'check';
DefAns.saveROImovies = mainhandles.settings.save.saveROImovies;
DefAns.askforraw = mainhandles.settings.save.askforraw;
DefAns.opensubGUIs = mainhandles.settings.save.opensubGUIs;
DefAns.setwindowSize = mainhandles.settings.save.setwindowSize;

%--------------- Open dialog box --------------%
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns);
if cancelled == 1 || isequal(DefAns,answer)
    return
end

%% Update handles structure

mainhandles = savesettingasDefaultDlg(mainhandles,...
    'save',...
    {'saveROImovies' 'askforraw' 'opensubGUIs' 'setwindowSize'},...
    {answer.saveROImovies, answer.askforraw, answer.opensubGUIs, answer.setwindowSize});
