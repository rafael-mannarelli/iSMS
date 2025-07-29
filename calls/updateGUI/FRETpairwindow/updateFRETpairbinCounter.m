function updateFRETpairbinCounter(mainhandle, FRETpairwindowHandle)
% Updates the number of pairs in the recycle bin displayed in the
% FRETpairwindow
%
%     Input:
%      mainhandles  - handles structure of the main window
%      FRETpairwindowHandles - handles structure of the FRETpairwindow
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

%% Initialze

% Get handles structures
if isempty(mainhandle) || ~ishandle(mainhandle) || isempty(FRETpairwindowHandle) || ~ishandle(FRETpairwindowHandle)
    return
end
mainhandles = guidata(mainhandle);
FRETpairwindowHandles = guidata(FRETpairwindowHandle);

% All pairs in recycle bin
if mainhandles.settings.bin.open
    binnedPairs = getPairs(mainhandle,'bin');
    n = size(binnedPairs,1);
    
else
    binnedPairs = getbinnedPairs(mainhandles.figure1,'all');
    n = length(binnedPairs);
end

%% Update counter

set(FRETpairwindowHandles.BinMenu, 'Label', sprintf('Bin (%i)',n))
