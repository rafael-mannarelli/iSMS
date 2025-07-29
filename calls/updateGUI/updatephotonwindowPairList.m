function updatephotonwindowPairList(mainhandle, integrationwindowHandle)
% Updates the FRETpair listbox string in the photoncountingwindow
%
%    Input:
%     mainhandle         - handle to the main figure window
%     integrationwindowHandle - handle to the integration settings window
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
if (isempty(mainhandle)) || (isempty(integrationwindowHandle)) || (~ishandle(mainhandle)) || (~ishandle(integrationwindowHandle))
    return
end

% Get handles
integrationwindowHandles = guidata(integrationwindowHandle);

% Get all FRETpairs
listPairs = getPairs(mainhandle, 'All'); 
if isempty(listPairs)
    set(integrationwindowHandles.PairListbox,'String','')
    set(integrationwindowHandles.PairListbox,'Value',1)
    return
end

%% Make string cell

npairs = size(listPairs,1);
namestr = cell(npairs,1);
for i = 1:npairs
    file = listPairs(i,1);
    pair = listPairs(i,2);
    
    % Add file suffix
    namestr{i} = sprintf('%i,%i', file, pair); % Change listbox string
end

% Check that selection does not exceed string size
pairchoice = get(integrationwindowHandles.PairListbox,'Value');
if pairchoice(end)>npairs
    set(integrationwindowHandles.PairListbox,'Value',npairs)
end

%% Set pairlistbox string

set(integrationwindowHandles.PairListbox,'String',namestr)
