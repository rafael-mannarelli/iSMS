function mainhandles = globalFactorChoiceCallback(cwHandles,field,choice)
% Callback for selecting choice of correction factor setting value in the
% correction factor window
%
%    Input:
%     cwHandles  - handles structure of the correctionfactor window
%     field      - setting field to change
%     choice     - field value
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
mainhandles = getmainhandles(cwHandles);

% Update setting
mainhandles.settings.corrections.(field) = choice;
updatemainhandles(mainhandles)

% Update GUI
updateAvgCorrectionFactor(mainhandles,cwHandles);
updatecorrectionwindowGUImenus(cwHandles)
