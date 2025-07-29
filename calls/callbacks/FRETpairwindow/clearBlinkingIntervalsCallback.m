function [mainhandles, FRETpairwindowHandles] = clearBlinkingIntervalsCallback(FRETpairwindowHandles)
% Callback for clearing blinking intervals in the FRETpairwindow
%
%    Input:
%     FRETpairwindowHandles   - handles structure of the FRETpairwindow
%
%    Output:
%     mainhandles             - handles structure of the main window
%     FRETpairwindowHandles   - ...
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

FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles); % Turn of integration ROIs
mainhandles = getmainhandles(FRETpairwindowHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% File and pair choice
selectedPairs = getPairs(FRETpairwindowHandles.main, 'Selected', [], FRETpairwindowHandles.figure1); % Returns pair selection as [file pair;...]
if isempty(selectedPairs)
    return
elseif size(selectedPairs,1)>1
    mymsgbox('Please select a single FRET-pair only','Integration area');
    set(FRETpairwindowHandles.Toolbar_IntegrationROI,'state','off')
    return
elseif isempty(mainhandles.data(selectedPairs(1,1)).FRETpairs(selectedPairs(1,2)).DblinkingInterval)...
        && isempty(mainhandles.data(selectedPairs(1,1)).FRETpairs(selectedPairs(1,2)).AblinkingInterval)
    return
end
filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

%% Reset time intervals

mainhandles.data(filechoice).FRETpairs(pairchoice).DblinkingInterval = [];
mainhandles.data(filechoice).FRETpairs(pairchoice).AblinkingInterval = [];

%% Update

% Update traces and plots
updatemainhandles(mainhandles)
if mainhandles.settings.background.blinkchoice
    mainhandles = calculateIntensityTraces(FRETpairwindowHandles.main, selectedPairs);
    FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main, FRETpairwindowHandles.figure1, 'traces');
    FRETpairwindowHandles = updateMoleculeFrameSliderHandles(FRETpairwindowHandles.main, FRETpairwindowHandles.figure1);
end
plotTimeIntervalOfInterest(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)
FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,'images');

% Update average pair values
mainhandles = updateAvgPairValues(mainhandles, selectedPairs, mainhandles.FRETpairwindowHandle);

% If histogram is open update the histogram
plottedPairs = getPairs(FRETpairwindowHandles.main,'Plotted');
if ~isempty(plottedPairs) && ismember(selectedPairs,plottedPairs, 'rows','legacy')
    mainhandles = updateSEplot(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,mainhandles.histogramwindowHandle,'all');
end
