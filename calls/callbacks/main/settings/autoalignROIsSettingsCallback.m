function mainhandles = autoalignROIsSettingsCallback(mainhandles)
% Callback for the auto align ROIs settings menu item
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

prompt = {'Number of peaks used for alignment:  ' 'npeaks';...
    'Show peaks used for alignment' 'showpeaks';...
    'Use auto-resizing' 'autoResize';...
    'Lower ROI size /pixels:  ' 'lowerSize';...
    'Alignment reference frame  ' 'refframe'};
name = 'Auto-ROI settings ';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% Interpolation choices
formats(2,1).type = 'edit';
formats(2,1).size = 50;
formats(2,1).format = 'integer';
formats(3,1).type = 'check';
formats(5,1).type = 'check';
formats(6,1).type = 'edit';
formats(6,1).size = 50;
formats(6,1).format = 'integer';
formats(8,1).type = 'list';
formats(8,1).style = 'popupmenu';
formats(8,1).items = {'Align A-ROI relative to fixed D-ROI  ';'Align D-ROI relative to fixed A-ROI  '};

% Default choices
DefAns.npeaks = mainhandles.settings.autoROI.npeaks;
DefAns.showpeaks = mainhandles.settings.autoROI.showpeaks;
DefAns.autoResize = mainhandles.settings.autoROI.autoResize;
DefAns.lowerSize = mainhandles.settings.autoROI.lowerSize;
DefAns.refframe = mainhandles.settings.autoROI.refframe;

options.CancelButton = 'on';

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1) || (isequal(DefAns,answer))
    return
end

%% Save settings

if answer.npeaks<1
    answer.npeaks = 1;
end

% Save as default dialog
mainhandles = savesettingasDefaultDlg(mainhandles,...
    'autoROI',...
    {'npeaks' 'showpeaks' 'autoResize' 'lowerSize' 'refframe'},...
    {answer.npeaks, answer.showpeaks, answer.autoResize, answer.lowerSize, answer.refframe});
