function mainhandles = showcorrectionfactorIntervalCallback(cwHandles)
% Callback for turning correction factor interval on/off in the correction
% factor window
%
%    Input:
%     cwHandles  - handles structure of the correction factor window
%
%    Outut:
%     mainhandles - handles structure of the main window
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

% Get mainhandles structure
mainhandles = getmainhandles(cwHandles);
if isempty(mainhandles)
    return
end

% Update setting
if strcmp(get(cwHandles.Toolbar_ShowCorrectionInterval,'state'),'on')
    mainhandles.settings.correctionfactorplot.showInterval = 1;
elseif strcmp(get(cwHandles.Toolbar_ShowCorrectionInterval,'state'),'off')
    mainhandles.settings.correctionfactorplot.showInterval = 0;
end

% Update
updatemainhandles(mainhandles)
updateCorrectionFactorPlots(cwHandles.main,cwHandles.figure1,'trace')
