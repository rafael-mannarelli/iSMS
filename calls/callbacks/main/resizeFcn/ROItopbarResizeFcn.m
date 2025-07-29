function ROItopbarResizeFcn(hObject,event)
% Callback for resizing the topbar panels in the main window
%
%    Input:
%     hObject   - handle to the panel (handles.uipanelROItop)
%     event     - eventdata not used
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
temp = getappdata(0,'dontupdatePanelTop');
if ~isempty(temp)% && temp>1
    return
end

% Get mainhandles structure
try mainhandle = get(hObject,'Parent');
    mainhandles = guidata(mainhandle);
catch err
    mainhandle = getappdata(0,'mainhandle');
    mainhandles = guidata(mainhandle);
end

% Object pixel dimensions
bottomspace = 3;
topspace = 5;
leftspace = 5;
midspace = 5;
rightspace = 5;
buttonwidth = 24;
buttonheight = 24;
statusheight = 17;
topbarheight = 35;
textheight = 17;
topbarspace = 5;
framesliderWidth = 0.7;
frametextWidth = 130;
contrastsliderWidth = 0.3;
sliderHeight = 17;

% Handles
sliderAxes = 'ROIframesliderAxes';
panelH = 'uipanelROI';
paneltopH = 'uipanelROItop';
panelImgH = 'uipanelROIimage';
sliderTextbox = 'ROIframesliderTextbox';
extra = 10;

redcontrastSlider = 'redROIcontrastSliderAx';
redcontrastTextbox = 'redROIcontrastTextbox';
greencontrastSlider = 'greenROIcontrastSliderAx';
greencontrastTextbox = 'greenROIcontrastTextbox';

% Do resize
if isfield(mainhandles,sliderAxes) && isfield(mainhandles,panelH) && isfield(mainhandles,'gridflexPanel') ...
        && length(mainhandles.(sliderAxes))==1 && ishandle(mainhandles.(sliderAxes))
    
    % These objects have not been created the first time the GUI is run
    
    uipanelPos = getpixelposition(mainhandles.(panelH));
    
    % Determine sizes in ROI panel
    topPanelPos = getpixelposition(mainhandles.(paneltopH));
    topPanelPos(4) = 2*topspace+topbarheight;
    topPanelPos(2) = uipanelPos(4)-topPanelPos(4)-1;
    
    % Image
    imagePos = getpixelposition(mainhandles.(panelImgH));
    imagePos(4) = uipanelPos(4)-2*topspace+topbarheight-1-extra;
    
    % Frame slider
    frametextPos(1) = leftspace;
    frametextPos(2) = topPanelPos(4)-topspace-sliderHeight;
    frametextPos(3) = topPanelPos(3)*framesliderWidth-frametextWidth-midspace*4;
    frametextPos(4) = sliderHeight;
    
    framesliderPos = frametextPos;
    framesliderPos(2) = frametextPos(2) - sliderHeight-midspace;
    
    % Green contrast
    greencontrastsliderPos(2) = topPanelPos(4)-topspace-sliderHeight;
    greencontrastsliderPos(3) = topPanelPos(3)*contrastsliderWidth;
    greencontrastsliderPos(1) = topPanelPos(3)-rightspace-greencontrastsliderPos(3);
    greencontrastsliderPos(4) = sliderHeight;
    
    greencontrasttextPos = greencontrastsliderPos;    
    greencontrasttextPos(1) = sum(framesliderPos([1 3]))+midspace;    
    greencontrasttextPos(3) = greencontrastsliderPos(1)-sum(framesliderPos([1 3]))-2*midspace;

    % Red contrast
    redcontrastsliderPos = greencontrastsliderPos;
    redcontrastsliderPos(2) = greencontrastsliderPos(2) - sliderHeight-midspace;
    
    redcontrasttextPos = greencontrasttextPos;
    redcontrasttextPos(2) = greencontrasttextPos(2) - sliderHeight-midspace;
    
    % Check minimum width
    minwidth = 10;
    if framesliderPos(3)<minwidth
        framesliderPos(3) = minwidth;
    end
    if redcontrastsliderPos(3)<minwidth
        redcontrastsliderPos(3) = minwidth;
        greencontrastsliderPos(3) = minwidth;
    end
    
%     temp = getappdata(0,'dontupdatePanelTop');
%     if isempty(temp)
        setappdata(0,'dontupdatePanelTop',1)
%     else
%         setappdata(0,'dontupdatePanelTop',temp+1)
%     end
    
    % Set sizes
    setpixelposition(mainhandles.(panelImgH), imagePos);
    setpixelposition(mainhandles.(sliderAxes), framesliderPos);
    setpixelposition(mainhandles.(sliderTextbox), frametextPos);
    setpixelposition(mainhandles.(redcontrastSlider), redcontrastsliderPos);
    setpixelposition(mainhandles.(redcontrastTextbox), redcontrasttextPos);
    setpixelposition(mainhandles.(greencontrastSlider), greencontrastsliderPos);
    setpixelposition(mainhandles.(greencontrastTextbox), greencontrasttextPos);
    
    setpixelposition(mainhandles.(paneltopH), topPanelPos)
    try rmappdata(0,'dontupdatePanelTop'), end
    
end
