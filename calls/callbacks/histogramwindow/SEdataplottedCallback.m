function mainhandles = SEdataplottedCallback(hwHandles,choice)
% Callback for choosing which bleaching intervals to plot in the SE window
%
%    Input:
%     hwHandles    - handles structure of the histogramwindow
%     choice       - setting choice
%
%    Output:
%     mainhandles  - ..
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

% Get mainhandles
mainhandles = getmainhandles(hwHandles);

% Update setting
mainhandles.settings.SEplot.plotBleaching = choice;
updatemainhandles(mainhandles)

% Update window
updateHistwindowGUImenus(mainhandles,hwHandles)
mainhandles = updateSEplot(hwHandles.main, mainhandles.FRETpairwindowHandle, hwHandles.figure1, 'all');
