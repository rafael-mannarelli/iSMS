function updateFRETpairlist(mainhandle,FRETpairwindowHandle)
% Updates FRET-pair listbox in the FRETpairGUI window and the counter
% located above the FRET pair listbox. Also runs updateDriftWindowPairlist
% in the end.
%
%    Input:
%     mainhandle            - handle to the main figure window (sms)
%     FRETpairWindowHandle  - handle to the FRETpairGUI window
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

% Check mainhandle
if isempty(mainhandle) || ~ishandle(mainhandle)
    return
end

% Get handles
mainhandles = guidata(mainhandle);

% Default handle to FRET pair window
if nargin<2
    FRETpairwindowHandle = mainhandles.FRETpairwindowHandle;
end

% Get FRETpair window handles
if isempty(FRETpairwindowHandle) || ~ishandle(FRETpairwindowHandle)
    return
end
FRETpairwindowHandles = guidata(FRETpairwindowHandle);

% Get string cell for the pair listbox
namestr = getFRETpairString(mainhandle, FRETpairwindowHandle);
if isempty(namestr)
    
    % Pair listbox:
    set(FRETpairwindowHandles.PairListbox,'String','') % Update the FRET-pairs listbox
    set(FRETpairwindowHandles.PairListbox,'Value',1)
    
    % Pair counter:
    set(FRETpairwindowHandles.FRETpairsTextbox,'String','FRET-pairs:  0') % Update the FRET-pair counter
    
    % Bleach counters:
    set(FRETpairwindowHandles.DbleachCounter,'String',0)
    set(FRETpairwindowHandles.AbleachCounter,'String',0)
    set(FRETpairwindowHandles.DAbleachCounter,'String',0)
    
    % Window name:
    set(FRETpairwindowHandle,'name','FRET Pairs Window')    
    
    return
end

%% Update the FRET-pair listbox, the FRET-pair counter, and the selected
% file textbox

npairs = size(namestr,1);
if mainhandles.settings.bin.open
    binnedPairs = getPairs(mainhandles.figure1,'bin');
    npairsBin = size(binnedPairs,1);
    npairsReal = npairs-npairsBin;
    set(FRETpairwindowHandles.FRETpairsTextbox,'String',sprintf('FRET-pairs:  %i (+%i)',npairsReal,npairsBin)) % Update the FRET-pair counter

else
    set(FRETpairwindowHandles.FRETpairsTextbox,'String',sprintf('FRET-pairs:  %i',npairs)) % Update the FRET-pair counter
end

% Set listbox name string
set(FRETpairwindowHandles.PairListbox,'String', namestr)

% If there are less FRET-pairs than listbox value, set value to last
% FRET-pair and update all plots
selectedPair = get(FRETpairwindowHandles.PairListbox,'Value');
if npairs < max(selectedPair)
    set(FRETpairwindowHandles.PairListbox,'Value',npairs)
    [FRETpairwindowHandles,mainhandles] = updateFRETpairplots(mainhandle,FRETpairwindowHandle,'all');
end

% Update bleach counters in the FRET pair window
updateBleachCounters(mainhandle,FRETpairwindowHandle)

%% Update other FRET pair lists in the program:

updateDriftWindowPairlist(mainhandle,mainhandles.driftwindowHandle) % Update drift window pairlist (if its open)
updatephotonwindowPairList(mainhandle,mainhandles.integrationwindowHandle) % Update photoncountingwindow pairlist (if its open)
updatePSFwindowPairList(mainhandle,mainhandles.psfwindowHandle) % Update PSF pars window pairlist (if open)

