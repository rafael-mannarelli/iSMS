function mainhandles = updateAvgPairValues(mainhandles, selectedPairs, FRETpairwindowHandle)
% Updates the values of average E and S, and the FRETpair listbox, if this
% is depending on these values.
%
%    Input:
%     mainhandles          - handles structure of the main window
%     selectedPairs        - pairs to calculcate
%     FRETpairwindowHandle - handle to the FRETpair window
%
%    Output:
%     mainhandles          - ..
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

% Default
if nargin<2 || isempty(selectedPairs)
    selectedPairs = getPairs(mainhandles.figure1);
end
if nargin<3 || isempty(FRETpairwindowHandle)
    FRETpairwindowHandle = mainhandles.FRETpairwindowHandle;
end

% Calculate and sort avg. E
if mainhandles.settings.FRETpairplots.sortpairs==3
    mainhandles = calculateAvgTrace(mainhandles.figure1, 'E', selectedPairs);
    mainhandles = sortpairsCallback(FRETpairwindowHandle, 3);
end

% Calculate and sort avg. S
if mainhandles.settings.FRETpairplots.sortpairs==4
    mainhandles = calculateAvgTrace(mainhandles.figure1, 'S', selectedPairs);
    mainhandles = sortpairsCallback(FRETpairwindowHandle, 4);
end

% Display avg. E in FRETpair listbox
if mainhandles.settings.FRETpairplots.avgFRET && mainhandles.settings.FRETpairplots.sortpairs~=3
    mainhandles = calculateAvgTrace(mainhandles.figure1, 'E', selectedPairs);
    updateFRETpairlist(mainhandles.figure1,FRETpairwindowHandle)
end

% Update
updatemainhandles(mainhandles)
