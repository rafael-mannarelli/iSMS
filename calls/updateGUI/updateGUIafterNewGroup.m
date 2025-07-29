function mainhandles = updateGUIafterNewGroup(mainhandle)
% Updates GUIs after a new group has been made
%
%     Input:
%      mainhandle   - handle to the main window
%
%     Output:
%      mainhandles  - handles structure of the main window
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
mainhandles = guidata(mainhandle);

%% Update

updateFRETpairlist(mainhandle, mainhandles.FRETpairwindowHandle)
updategrouplist(mainhandle, mainhandles.FRETpairwindowHandle)

if mainhandles.settings.FRETpairplots.sortpairs==2
    mainhandles = sortpairsCallback(mainhandles.FRETpairwindowHandle, 2);
end

%% If histogram is open update the histogram

if (strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on')) && (~isempty(mainhandles.histogramwindowHandle)) && (ishandle(mainhandles.histogramwindowHandle))
    histogramwindowHandles = guidata(mainhandles.histogramwindowHandle);
    
    if get(histogramwindowHandles.plotSelectedGroupRadiobutton,'Value') 

        % If plotting only data-points from the group selected in the FRETpairwindow GUI
        mainhandles = updateSEplot(mainhandle, mainhandles.FRETpairwindowHandle, mainhandles.histogramwindowHandle,'all');
    end
    
end
