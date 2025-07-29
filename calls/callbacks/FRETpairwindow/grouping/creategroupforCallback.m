function mainhandles = creategroupforCallback(fpwHandle,choice)
% Callback for createing new group for molecules with specific properties
%
%    Input:
%     fpwHandle    - handle to the FRETpairwindow
%     choice       - 'Dbleach', 'Ableach', 'DAbleach' 'blink'
%
%    Output:
%     mainhandles  - handles structure of the main window
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

if isempty(fpwHandle) || ~ishandle(fpwHandle)
    mainhandles = guidata(getappdata(0,'mainhandle'));
    return
end

% Get handles
fpwHandles = guidata(fpwHandle);
mainhandles = getmainhandles(fpwHandles);

% Pairs to put in new group
groupPairs = getPairs(mainhandles.figure1,choice);
if strcmpi(choice,'Dbleach')
    name = 'D bleaching';
elseif strcmpi(choice,'Ableach')
    name = 'A bleaching';
elseif strcmpi(choice,'DAbleach')
    name = 'D & A bleaching';
elseif strcmpi(choice,'blink')
    name = 'Blinking';
end

% Check if group already exists
idx = 0;
for i = 1:length(mainhandles.groups)
    if ismember(name,{mainhandles.groups(i).name})
        idx = i;
        break
    end
end

%% Group

if idx
    mainhandles = deleteGroup(mainhandles,idx);
end

% Create new group
mainhandles = createNewGroup(mainhandles, groupPairs, name, [], 0);

%% Update

mainhandles = updateGUIafterNewGroup(mainhandles.figure1);

