function updategrouplist(mainhandle,FRETpairwindowHandle)
% Updates the groups listbox in the FRETpairGUI window and the counter
% located above the FRET pair listbox.
%
%     Input:
%      mainhandles           - handle to the main figure window
%      FRETpairWindowHandles - handle to the FRETpairGUI window
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
if (isempty(mainhandle)) || (isempty(FRETpairwindowHandle)) || (~ishandle(mainhandle)) || (~ishandle(FRETpairwindowHandle))
    return
end

% Get handles
mainhandles = guidata(mainhandle);
FRETpairwindowHandles = guidata(FRETpairwindowHandle);
if isempty(mainhandles.data)
    set(FRETpairwindowHandles.GroupsListbox,'String','') % Update the FRET-pairs listbox
    set(FRETpairwindowHandles.GroupsListbox,'Value',1)
    return
end

% Get groups
groups = length(mainhandles.groups); % No. of FRET pairs

% Clear if there are no groups
if groups == 0
    set(FRETpairwindowHandles.GroupsListbox,'String','') % Update the FRET-pairs listbox
    set(FRETpairwindowHandles.GroupsListbox,'Value',1)
    return
end

%% Update the groups listbox

% Check current value does not exceed string
if max(get(FRETpairwindowHandles.GroupsListbox,'Value'))>groups
    set(FRETpairwindowHandles.GroupsListbox,'Value',groups)
end

% Add suffix with number of pairs in the group
namestr = getgroupString(mainhandles,FRETpairwindowHandle);

% Set string name
set(FRETpairwindowHandles.GroupsListbox,'String',namestr) % Update the FRET-pairs listbox
if groups < get(FRETpairwindowHandles.GroupsListbox,'Value') % If there are less groups than listbox value, set value to last group
    set(FRETpairwindowHandles.GroupsListbox,'Value',groups)
end

