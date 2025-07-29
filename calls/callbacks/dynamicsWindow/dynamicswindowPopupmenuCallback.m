function dynamicswindowPopupmenuCallback(hObject,event,dwHandle)
% Callback for the popupmenu in the dynamics window
%
%    Input:
%     hObject   - handle to the popupmenu
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
value = get(dwHandles.PlotPopupmenu,'Value');

%% Update handle visibilities

h = [dwHandles.binSlider dwHandles.BinsTextbox];% dwHandles.BinCounter];
if value == 1
    set(h,'Visible','on')
else
    set(h,'Visible','off')
end
if value==3 || value==4
    set(dwHandles.binSlider,'Value',10)
    set(dwHandles.BinsTextbox,'String','Bins: 10')
    set(h,'Visible','on')
end

%% Update plots

updateDynamicsPlot(dwHandles.main,dwHandles.figure1,'hist')
if mainhandles.settings.dynamicsplot.fit
    updateDynamicsFit(dwHandles.main,dwHandles.figure1)
end

% dynamicswindowHisttopbarResizeFcn([],[],dwHandles.figure1)