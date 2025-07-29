function mainhandles = correctionFactorIntensitySettingCallback(cwHandles,field,choice)
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

%% Initialize

% Get mainhandles
mainhandles = getmainhandles(cwHandles);

%% Update setting

mainhandles.settings.corrections.(field) = choice;
updatemainhandles(mainhandles)
updatecorrectionwindowGUImenus(cwHandles)

%% Update traces and other windows

mainhandle = mainhandles.figure1;
allPairs = getPairs(mainhandle, 'All');
mainhandles = calculateCorrectionFactors(mainhandle,allPairs,'all',0);
updateCorrectionFactorPairlist(mainhandle,mainhandles.correctionfactorwindowHandle)
updateCorrectionFactorPlots(mainhandle,mainhandles.correctionfactorwindowHandle)

% Re-calculate traces
if mainhandles.settings.corrections.molspec
    mainhandles = correctTraces(mainhandle, 'all');
    FRETpairwindowHandles = updateFRETpairplots(mainhandle,mainhandles.FRETpairwindowHandle,'traces','ADcorrect');
end

% If histogram is open update the histogram
if strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on')
    mainhandles = updateSEplot(mainhandle,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
    
    % Turn attention back to window
    figure(cwHandles.figure1)
end

