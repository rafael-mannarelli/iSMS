function updateBleachCounters(mainhandle,FRETpairwindowHandle)
% Updates the bleach counters in the FRETpairwindow
%
%     Input:
%      mainhandle      - handle to the main window
%      FRETpairwindow  - handle to the FRETpairwindow
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

% If one of the windows is closed
if (isempty(mainhandle)) || (isempty(FRETpairwindowHandle)) || (~ishandle(mainhandle)) || (~ishandle(FRETpairwindowHandle))
    return
end

% Get handles
mainhandles = guidata(mainhandle);
FRETpairwindowHandles = guidata(FRETpairwindowHandle);

% Get pairs with bleaching
DbleachedPairs = getPairs(mainhandle, 'Dbleach');
AbleachedPairs = getPairs(mainhandle, 'Ableach');
DAbleachedPairs = getPairs(mainhandle, 'DAbleach');

% Update the bleach counters:
set(FRETpairwindowHandles.DbleachCounter,'String',size(DbleachedPairs,1))
set(FRETpairwindowHandles.AbleachCounter,'String',size(AbleachedPairs,1))
set(FRETpairwindowHandles.DAbleachCounter,'String',size(DAbleachedPairs,1))

