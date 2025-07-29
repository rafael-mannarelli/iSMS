function dynamicswindowStatelistCallback(hObject,event,dwHandle)
% Callback for the state listbox in the dynamics window
%
%    Input:
%     hObject   - handle to the listbox
%     event     - not used
%     dwHandle  - handle to the dynamics window
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

mainhandles = getmainhandles(dwHandles); % Get handles structure to the main window
if isempty(mainhandles)
    return
end

%% Update

if get(dwHandles.PlotPopupmenu,'Value')~=2 && get(dwHandles.PlotPopupmenu,'Value')~=3
    
    updateDynamicsPlot(dwHandles.main,dwHandles.figure1,'hist')
    if get(dwHandles.PlotPopupmenu,'Value')==1 && mainhandles.settings.dynamicsplot.fit
        updateDynamicsFit(dwHandles.main,dwHandles.figure1)
    end
end
