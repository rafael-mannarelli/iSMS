function mainhandles = emptyRecycleBinCallback(FRETpairwindowHandles)
% Callback for emptying recycle bin in the FRETpairwindow
%
%     Input:
%      FRETpairwindowHandles   - handles structure of the FRETpairwindow
%
%     Output:
%      mainhandles             - handles structure of the main window
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

% Get mainhandles structure
mainhandles = getmainhandles(FRETpairwindowHandles);
if isempty(mainhandles)
    return
end

if isempty(mainhandles.data)
    return
end

% Count bin
binnedPairs = getbinnedPairs(mainhandles.figure1);
if isempty(binnedPairs)
    return
end

% Sure dialog
if length(binnedPairs)==1
    message = 'This will permanently delete 1 FRETpair.';
else
    message = sprintf('This will permanently delete %i FRETpairs.',length(binnedPairs));
end
sure = mysuredlg('Empty recycle bin', message);
if ~sure
    return
end

%% Start emptying

for i = 1:length(mainhandles.data)
    
    if ~mainhandles.settings.bin.open
        mainhandles.data(i).FRETpairsBin(:) = [];
    else
        bingroup = getbingroup(mainhandles.figure1);
        binnedPairs = getPairs(mainhandles.figure1,'bin');
        mainhandles = deletePairs(mainhandles.figure1,binnedPairs);
        
    end
end

%% Update

% Reset last binned pairs
mainhandles.settings.bin.lastpair = [];

% Update handles structure
updatemainhandles(mainhandles)

% Update bin counter
updateFRETpairbinCounter(FRETpairwindowHandles.main, FRETpairwindowHandles.figure1)
