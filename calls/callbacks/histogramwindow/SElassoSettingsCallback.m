function mainhandles = SElassoSettingsCallback(handles)
% Callback for lasso selection tool settings callback in the SE window
%
%    Input:
%     histogramwindowHandles - handles structure of the histogramwindow
%   
%    Output:
%     mainhandles   - handles structure of the main window
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
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

%% Dialog

name = 'Lasso selection callback options';
prompt = {'Copy selected data points to clipboard' 'copy';...
    'Plot info on where points originate from' 'origin';...
    'Create new group with selected molecules' 'newgroup'};

formats = prepareformats();
formats(2,1).type = 'check';
formats(4,1).type = 'check';
formats(6,1).type = 'check';

DefAns.copy = mainhandles.settings.SEplot.lassoCopy;
DefAns.origin = mainhandles.settings.SEplot.lassoOrigin;
DefAns.newgroup = mainhandles.settings.SEplot.lassoNewgroup;

[answer, cancelled] = myinputsdlg(prompt,name,formats,DefAns);
if cancelled
    return
end

%% Update

mainhandles.settings.SEplot.lassoCopy = answer.copy;
mainhandles.settings.SEplot.lassoOrigin = answer.origin;
mainhandles.settings.SEplot.lassoNewgroup = answer.newgroup;
updatemainhandles(mainhandles)
