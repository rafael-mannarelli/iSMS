function mainhandles = SEplotchoiceCallback(hwHandle)
% Callback for selection change in the radio button group of the
% histogramwindow
%
%    Input:
%     hwHandle    - handle to the histogramwindow
%
%    Output:
%     mainhandles - handles structure of the main window
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

% Get handles
hwHandles = guidata(hwHandle);
mainhandles = getmainhandles(hwHandles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

% If choice is set on groups, check if there are any groups
if get(hwHandles.plotSelectedGroupRadiobutton,'Value')...
        && isempty(mainhandles.groups)
    mymsgbox('There are no groups. Create a new group by navigating to ''Grouping->Create new group'' in the FRET-pair window.')
end

%% Show/hide files listbox, depending on selection choice

h = [hwHandles.MergeFilesTextbox hwHandles.FilesListbox];
if get(hwHandles.plotAllPairsRadiobutton,'Value') ...
        || get(hwHandles.plotAllWithBleachRadiobutton,'Value') ...
        || (get(hwHandles.plotAllExceptRadiobutton,'Value') && get(hwHandles.plotAllExceptPopupMenu,'Value')==2)
    
    % Choice is on all pairs
    updatefileslist(hwHandles.main,hwHandles.figure1,'histogramwindow')
    set(hwHandles.FilesListbox,'Value',1:length(mainhandles.data))
    if strcmp(get(hwHandles.FilesListbox,'Enable'),'off')
        set(h,'Enable','on')
    end
    
    % Don't plot the density plot because it is slow
    if mainhandles.settings.SEplot.SEplotType == 2
        mainhandles.settings.SEplot.SEplotType = 1;
        updatemainhandles(mainhandles)
    end
    
else
    % Choice is on selected pairs or group
    if strcmp(get(hwHandles.FilesListbox,'Enable'),'on')
        set(h,'Enable','off')
    end
end

%% Enable/disable except popupmenu

if get(hwHandles.plotAllExceptRadiobutton,'Value')
    set(hwHandles.plotAllExceptPopupMenu,'Enable','on')
else
    set(hwHandles.plotAllExceptPopupMenu,'Enable','off')
end

%% Update SE-plot

mainhandles = guidata(hwHandles.main);
mainhandles = updateSEplot(hwHandles.main, mainhandles.FRETpairwindowHandle, hwHandles.figure1,'all');
