function mainhandles = bleachfinderSettingsCallback(mainhandles)
% Callback for opening bleachfinder settings dialog
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

%% Prepare dialog box

prompt = {'Find D bleaching' 'findD';...
    'Find A bleaching' 'findA';...
    'A bleaching: Aem-Aexc intensity upper threshold (counts): ' 'Athreshold';...
    'D bleaching: Sum intensity upper threshold (counts):' 'Dthreshold';...
    '#frames allowed to deviate above threshold' 'allow';...
    'Run bleachfinder when pressing OK' 'run'};
name = 'Bleachfinder settings';

formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% A bleaching
formats(2,1).type = 'check';
formats(3,1).type = 'check';
formats(5,1).type = 'edit';
formats(5,1).size   = 50;
formats(5,1).format = 'float';
formats(6,1).type = 'edit';
formats(6,1).size   = 50;
formats(6,1).format = 'float';

% D bleaching
formats(8,1).type = 'edit';
formats(8,1).size   = 50;
formats(8,1).format = 'integer';

formats(12,1).type = 'check';

DefAns.findD = mainhandles.settings.bleachfinder.findD;
DefAns.findA = mainhandles.settings.bleachfinder.findA;
DefAns.Athreshold = mainhandles.settings.bleachfinder.Athreshold;
DefAns.Dthreshold = mainhandles.settings.bleachfinder.Dthreshold;
DefAns.allow = mainhandles.settings.bleachfinder.allow;
DefAns.run = 0;

options.CancelButton = 'on';

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1) && isequal(DefAns,answer) && ~answer.run
    return
end

%% Update mainhandles structure

mainhandles = savesettingasDefaultDlg(mainhandles,...
    'bleachfinder',...
    {'findD' 'findA' 'Athreshold' 'Dthreshold' 'allow'},...
    {answer.findD answer.findA answer.Athreshold, answer.Dthreshold, answer.allow});

%% Run bleachfinder

if answer.run
    [mainhandles, FRETpairwindowHandles] = bleachfinderCallback(mainhandles.figure1);
end
