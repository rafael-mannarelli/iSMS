function updateDriftWindowPairlist(mainhandle,driftwindowHandle)
% Updates the FRET-pair list in the drift window
%
%    Input:
%     mainhandle         - handle to the main window (sms)
%     driftwindowHandle  - handle to the drift window
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

% If one of the windows is closed
if (isempty(mainhandle)) || (isempty(driftwindowHandle)) || (~ishandle(mainhandle)) || (~ishandle(driftwindowHandle))
    return
end

% Get handles
mainhandles = guidata(mainhandle);
driftwindowHandles = guidata(driftwindowHandle);

% Return if drifting is not compensated for selected file
filechoice = get(driftwindowHandles.FilesListbox,'Value');
if isempty(mainhandles.data) || ~mainhandles.data(filechoice).drifting.choice
    return
end

% Get pairs to be listed
listedPairs = getPairs(mainhandle,'driftListed',[],[],[],[],driftwindowHandle); % Pairs to be listed in the listbox, in correct order [file pair; ...]
if isempty(listedPairs)
    set(driftwindowHandles.PairListbox,'String','') % Update the FRET-pairs listbox
    set(driftwindowHandles.PairListbox,'Value',1)
    return
end

npairs = size(listedPairs,1);

%% Update the FRET-pair listbox

namestr = cell(npairs,1);
for i = 1:npairs
    file = listedPairs(i,1);
    pair = listedPairs(i,2);
    
    % If listing all files files add file suffix
    namestr{i} = sprintf('%i,%i', file, pair); % Change listbox string
    
end

% Set listbox name string
set(driftwindowHandles.PairListbox,'String', namestr)

% If there are less FRET-pairs than listbox value, set value to last
% FRET-pair and update all plots
selectedPair = get(driftwindowHandles.PairListbox,'Value');
if npairs < max(selectedPair)
    set(driftwindowHandles.PairListbox,'Value',npairs)
    mainhandles = updateDriftWindowPlots(mainhandle,driftwindowHandle);
end

