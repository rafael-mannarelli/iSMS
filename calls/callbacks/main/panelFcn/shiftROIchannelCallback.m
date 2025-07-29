function mainhandles = shiftROIchannelCallback(mainhandles)
% Callback for shifting ROI emission channel in main window
%
%   Input:
%    mainhandles   - handles structure of the main window
%
%   Output:
%    mainhandles   - ..
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

% Turn off all interactive toggle buttons in the toolbar
mainhandles = turnofftoggles(mainhandles,'all');

% If no data is loaded, return
if isempty(mainhandles.data) 
    set(mainhandles.mboard,'String','No data loaded')
    return
end

%% Update setting

if mainhandles.settings.view.ROIgreen && mainhandles.settings.view.ROIred
    mainhandles.settings.view.ROIred = 0;
elseif mainhandles.settings.view.ROIgreen && ~mainhandles.settings.view.ROIred
    mainhandles.settings.view.ROIred = 1;
    mainhandles.settings.view.ROIgreen = 0;
else
    mainhandles.settings.view.ROIgreen = 1;
    mainhandles.settings.view.ROIred = 1;
end

%% Update

% Update handles structure
updatemainhandles(mainhandles)

% Update plot
mainhandles = updateROIimage(mainhandles,0,0,1);
mainhandles = updatepeakplot(mainhandles,'all');
