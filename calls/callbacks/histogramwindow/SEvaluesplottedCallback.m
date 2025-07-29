function mainhandles = SEvaluesplottedCallback(hwHandles,choice)
% Callback for settings values plotted in the histogramwindow
%
%     Input:
%      hwHandles    - handles structure of the histogramwindow
%      choice       - plot setting
%
%     Output:
%      mainhandles  - handles structure of the main window
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

% Get mainhandles
mainhandles = getmainhandles(hwHandles);

%% Set setting

mainhandles.settings.SEplot.valuesplotted = choice;

% Set larger marker size for single value plots
if choice==1
    mainhandles.settings.SEplot.markersize = 3;
else
    mainhandles.settings.SEplot.markersize = 5;
end

% Set plot type to regular
mainhandles.settings.SEplot.SEplotType = 1;

%% Update

updatemainhandles(mainhandles)
updateHistwindowGUImenus(mainhandles,hwHandles)
mainhandles = updateSEplot(mainhandles.figure1);
