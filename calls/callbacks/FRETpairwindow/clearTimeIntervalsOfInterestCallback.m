function [mainhandles, FRETpairwindowHandles] = clearTimeIntervalsOfInterestCallback(FRETpairwindowHandles)
% Callback for clearing time intervals of interest in the FRETpairwindow
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
end

filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

%% Reset time intervals

mainhandles.data(filechoice).FRETpairs(pairchoice).timeInterval = [];
if ~isempty(mainhandles.data(filechoice).DD_ROImovie)
    mainhandles.data(filechoice).FRETpairs(pairchoice).DD_avgimage = []; % This will force a molecule image re-calculation by updateFRETpairplots
end

%% Update

updatemainhandles(mainhandles)
plotTimeIntervalOfInterest(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)
FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,'images');

% Update average pair values
mainhandles = updateAvgPairValues(mainhandles, selectedPairs, mainhandles.FRETpairwindowHandle);

% If histogram is open update the histogram
plottedPairs = getPairs(FRETpairwindowHandles.main,'Plotted');
if ~isempty(plottedPairs) && ismember(selectedPairs,plottedPairs, 'rows','legacy') && mainhandles.settings.SEplot.onlytinterest
    mainhandles = updateSEplot(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,mainhandles.histogramwindowHandle,'all');
end
