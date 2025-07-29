function [mainhandles, FRETpairwindowHandles] = clearBleachingTimesCallback(FRETpairwindowHandles)
% Callback for clearing bleaching times in the FRETpairwindow
%
%    Input:
%     FRETpairwindowHandles  - handles structure of the FRETpairwindow
%
%    Output:
%     mainhandles            - handles structure of the main window
%     FRETpairwindowHandles  - ..
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

% Only a single pair allowed
if isempty(selectedPairs)
    return
elseif size(selectedPairs,1)>1
    mymsgbox('Please select a single FRET-pair only','Bleaching');
    return
elseif isempty(mainhandles.data(selectedPairs(1,1)).FRETpairs(selectedPairs(1,2)).DbleachingTime)...
        && isempty(mainhandles.data(selectedPairs(1,1)).FRETpairs(selectedPairs(1,2)).AbleachingTime)
    plotTimeIntervalOfInterest(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1) % Remove any plotted intervals
    return
end

%% Clear

mainhandles = clearBleachingTime(mainhandles,selectedPairs);
