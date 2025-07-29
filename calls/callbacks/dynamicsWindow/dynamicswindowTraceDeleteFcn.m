function dynamicswindowTraceDeleteFcn(hObject,event,dwHandle)
% Callback for the remove trace menu button in the dynamics window
%
%   Input:
%    hObject    - handle to the button
%    event      - eventdata not used
%    dwHandle   - handle to the dynamics window
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

dwHandles = guidata(dwHandle);
mainhandles = getmainhandles(dwHandles);
if isempty(mainhandles)
    return
end
mainhandle = dwHandles.main;

% Selected trace
selectedPairs = getPairs(mainhandle, 'dynamicsSelected',[],[],[],[],[],[],[],dwHandle);
if isempty(selectedPairs)
    return
end

%% Remove all dynamics information

mainhandles = deleteIdealizedTrace(mainhandles,selectedPairs);

%% Update

updatemainhandles(mainhandles)
updateDynamicsList(mainhandle,dwHandle,'all')

% Check selection does not exceed number of traces
selectedPair = get(dwHandles.PairListbox,'Value');
dynamicsPairs = getPairs(mainhandle, 'Dynamics');
if max(selectedPair)>size(dynamicsPairs,1)
    set(dwHandles.PairListbox,'Value',size(dwHandles.PairListbox,1))
end

% Update plot
updateDynamicsPlot(mainhandle,dwHandle,'all')
