function dynamicswindowHisttopbarResizeFcn(hObject,event,dwHandle)
% Callback for resizing the topbar hist panel in the dynamics window
%
%    Input:
%     hObject   - handle to the panel (handles.uipanelROItop)
%     event     - eventdata not used
%     dwHandle  - handle to the dynamics window
%
%    Ourput:
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

% Don't run function if its called by itself
if ~isempty(getappdata(0,'dontupdatePanelTop'))
    return
end

mainhandles = guidata(getappdata(0,'mainhandle'));
if mainhandles.matver>8.3
    %     return
end

% Get mainhandles structure
% try dwHandle = get(hObject,'Parent');
%     dwHandles = guidata(dwHandle);
% catch err
%     dwHandle = getappdata(0,'mainhandle');
dwHandles = guidata(dwHandle);
% end


% Object pixel dimensions
topspace = 2;
topbarheight = 21;

textW = 65;
binsliderW = 65;
horspace = 5;
rightspace = 2;
leftspace = 2;


%% Do resizing

setappdata(0,'dontupdatePanelTop',1)
if isfield(dwHandles,'HistAxes') && isfield(dwHandles,'uipanelLR') && isfield(dwHandles,'gridflexPanel') ...
        && ishandle(dwHandles.HistAxes)
    
    % These objects have not been created the first time the GUI is run
    
    % VERSION DEPENDENT SYNTAX
    if mainhandles.matver>8.3
        
        posLRbox = getpixelposition(dwHandles.boxpanelLR);
        setpixelposition(dwHandles.uipanelLR,posLRbox)
        
        posLR  = getpixelposition(dwHandles.uipanelLR);
        posLRT = getpixelposition(dwHandles.uipanelLRT);
        posLRL = getpixelposition(dwHandles.uipanelLRL);
        
        posLRT(4) = 22;
        posLRT(2) = posLR(4)-4-posLRT(4);
        setpixelposition(dwHandles.uipanelLRT,posLRT)
        
        posLRL(3) = posLR(3);
        posLRL(4) = posLR(4)-posLRT(4);
        setpixelposition(dwHandles.uipanelLRL,posLRL)
        
    else
        
        HistuipanelPos = getpixelposition(dwHandles.uipanelLR);
        
        % Determine sizes in panel
        HisttopPanelPos = getpixelposition(dwHandles.uipanelLRT);
        HisttopPanelPos(4) = 2*topspace+topbarheight;
        HisttopPanelPos(2) = HistuipanelPos(4)-HisttopPanelPos(4);
        
        HistaxPos = getpixelposition(dwHandles.uipanelLRL);
        HistaxPos(3) = HistuipanelPos(3);
        HistaxPos(4) = HistuipanelPos(4)-2*topspace-topbarheight-1;
        
        bintextPos(1) = HisttopPanelPos(3)-rightspace-textW;
        bintextPos(2) = HisttopPanelPos(4)-topspace-topbarheight-2;
        bintextPos(3) = textW;
        bintextPos(4) = topbarheight;
        
        binsliderPos(1) = bintextPos(1)-horspace-binsliderW;
        binsliderPos(2) = HisttopPanelPos(4)-topspace-topbarheight;
        binsliderPos(3) = binsliderW;
        binsliderPos(4) = topbarheight;
        
        popupPos(1) = leftspace;
        popupPos(2) = HisttopPanelPos(4)-topspace-topbarheight;
        popupPos(3) = HisttopPanelPos(3)-leftspace-rightspace-2*horspace-binsliderW-textW;
        popupPos(4) = topbarheight;
        
        % Check minimum width
        minwidth = 10;
        if popupPos(3)<minwidth
            popupPos(3) = minwidth;
        end
        
        % Set sizes
        %     setappdata(0,'dontupdatePanelTop',1)
        % Make sure this function is not run again, when setting new position
        setpixelposition(dwHandles.uipanelLRT, HisttopPanelPos)
        %     rmappdata(0,'dontupdatePanelTop')
        
        setpixelposition(dwHandles.uipanelLRL, HistaxPos);
        setpixelposition(dwHandles.PlotPopupmenu, popupPos);
        setpixelposition(dwHandles.BinsTextbox, bintextPos);
        setpixelposition(dwHandles.binSlider, binsliderPos);
        
    end
    
end
rmappdata(0,'dontupdatePanelTop')
