function mainhandles = shownROIchannelCallback(mainhandles,choice)
% Callback for changing channel shown in main ROI image
%
%    Input:
%     mainhandles   - handles structure
%     choice        - field
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

% Update settings
mainhandles.settings.view.(choice) = abs(mainhandles.settings.view.(choice)-1);

% Always show at least one channel
if ~mainhandles.settings.view.ROIgreen && ~mainhandles.settings.view.ROIred
    mainhandles.settings.view.ROIgreen = 1;
    mainhandles.settings.view.ROIred = 1;
end

% Update
updatemainhandles(mainhandles)
updatemainGUImenus(mainhandles)
mainhandles = updateROIimage(mainhandles,0,0,1);
