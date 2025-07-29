function RAWtopbarResizeFcn(hObject,event)
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
if ~isempty(getappdata(0,'dontupdatePanelTop'))
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
topbarheight = 17;
textheight = 17;
topbarspace = 5;
% framesliderWidth = 0.75;
frametextWidth = 100;
% contrastsliderWidth = 0.25;
contrasttextWidth = 60;

sliderAxes = 'rawframesliderAxes';
contrastSlider = 'rawcontrastSliderAx';
panelH = 'uipanelRAW';
paneltopH = 'uipanelRAWtop';
panelImgH = 'uipanelRawimage';
sliderTextbox = 'rawframesliderTextbox';
extra = 10;

% Do resize
if isfield(mainhandles,sliderAxes) && isfield(mainhandles,panelH) && isfield(mainhandles,'gridflexPanel') ...
        && length(mainhandles.(sliderAxes))==1 && ishandle(mainhandles.(sliderAxes))
    
    % These objects have not been created the first time the GUI is run
    framesliderPos = getpixelposition(mainhandles.(sliderAxes));
    contrastsliderPos = getpixelposition(mainhandles.(contrastSlider));
    
    uipanelPos = getpixelposition(mainhandles.(panelH));
    
    
    % Determine sizes in ROI panel
    topPanelPos = getpixelposition(mainhandles.(paneltopH));
    topPanelPos(4) = 2*topspace+topbarheight;
    topPanelPos(2) = uipanelPos(4)-topPanelPos(4)-1;
    
    sliderWidth = round((topPanelPos(3)-leftspace-rightspace-2*midspace-frametextWidth-contrasttextWidth)/2);

    imagePos = getpixelposition(mainhandles.(panelImgH));
    imagePos(4) = uipanelPos(4)-2*topspace+topbarheight-1-extra;
    
    framesliderPos(1) = leftspace;
    framesliderPos(2) = topPanelPos(4)-topspace-topbarheight;
    framesliderPos(3) = sliderWidth;%topPanelPos(3)*framesliderWidth-frametextWidth-contrasttextWidth-midspace*5;
    framesliderPos(4) = topbarheight;
    
    frametextPos(1) = framesliderPos(1)+framesliderPos(3)+midspace;
    frametextPos(2) = topPanelPos(4)-topspace-topbarheight-1;
    frametextPos(3) = frametextWidth;
    frametextPos(4) = topbarheight;
    
    contrastsliderPos = framesliderPos;
    contrastsliderPos(1) = topPanelPos(3)-rightspace-contrastsliderPos(3);
    
    contrasttextPos = frametextPos;
    contrasttextPos(1) = contrastsliderPos(1)-contrasttextWidth-midspace;
    contrasttextPos(3) = contrasttextWidth;
    
    % Check minimum width
    minwidth = 10;
    if framesliderPos(3)<minwidth
        framesliderPos(3) = minwidth;
    end
    if contrastsliderPos(3)<minwidth
        contrastsliderPos(3) = minwidth;
    end
    
    % Set sizes
    setpixelposition(mainhandles.(panelImgH), imagePos);
    setpixelposition(mainhandles.(sliderAxes), framesliderPos);
    setpixelposition(mainhandles.(sliderTextbox), frametextPos);
    setpixelposition(mainhandles.(contrastSlider), contrastsliderPos);
    setpixelposition(mainhandles.rawcontrastTextbox, contrasttextPos);
    
    % Make sure this function is not run again, when setting new position
    setappdata(0,'dontupdatePanelTop',1)
    setpixelposition(mainhandles.(paneltopH), topPanelPos)
    rmappdata(0,'dontupdatePanelTop')
    
end
