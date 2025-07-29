function peakfinderResizeFcn(hObject,event, mainhandle)
% Callback for resizing the peakfinder panel in the main window
%
%    Input:
%     hObject   - handle to the panel
%     event     - eventdata not used
%     mainhandle - handle to the main window
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

% Get mainhandles structure
try mainhandles = guidata(mainhandle);
catch err
    mainhandle = getappdata(0,'mainhandle');
    mainhandles = guidata(mainhandle);
end

% Object pixel dimensions
bottomspace = 3;
topspace = 5;
leftspace = 5;
midspace = 5;
rightspace = 6;
buttonwidth = 24;
buttonheight = 24;
statusheight = 17;
topbarheight = 17;
textheight = 17;
topbarspace = 5;
textwidth = 18;
counterwidth = 38;
editwidth = 40;
editheight = 22;
buttonheight = 25;
buttonwidth = 70;

%% Do resizing
if isfield(mainhandles,'uipanelPeakfinder') && isfield(mainhandles,'gridflexPanel') ...
        && length(mainhandles.DPeakFinderTextbox)==1 && ishandle(mainhandles.DPeakFinderTextbox)

    % These objects have not been created the first time the GUI main fcn
    % is run
    peakpanelPos = getpixelposition(mainhandles.uipanelPeakfinder);
    topspace = topspace*2;
    
    % Determine positions
    DtextPos(1) = leftspace;
    DtextPos(2) = peakpanelPos(4)-topspace-textheight-1;
    DtextPos(3) = textwidth;
    DtextPos(4) = textheight;
    
    AtextPos(1) = leftspace;
    AtextPos(2) = peakpanelPos(4)-2*topspace-2*textheight-1;
    AtextPos(3) = textwidth;
    AtextPos(4) = textheight;
    
    EtextPos(1) = leftspace;
    EtextPos(2) = peakpanelPos(4)-3*topspace-3*textheight-1;
    EtextPos(3) = textwidth*2;
    EtextPos(4) = textheight;
    
    DcounterPos(3) = counterwidth;
    DcounterPos(4) = textheight;
    DcounterPos(1) = peakpanelPos(3)-rightspace-DcounterPos(3);
    DcounterPos(2) = DtextPos(2);
    
    AcounterPos(3) = counterwidth;
    AcounterPos(4) = textheight;
    AcounterPos(1) = peakpanelPos(3)-rightspace-AcounterPos(3);
    AcounterPos(2) = AtextPos(2);
    
    EcounterPos(3) = counterwidth;
    EcounterPos(4) = textheight;
    EcounterPos(1) = peakpanelPos(3)-rightspace-EcounterPos(3);
    EcounterPos(2) = EtextPos(2);
    
    DsliderPos(1) = DtextPos(1)+DtextPos(3)+midspace;
    DsliderPos(2) = DtextPos(2);
    DsliderPos(3) = peakpanelPos(3)-DsliderPos(1)-midspace-DcounterPos(3)-rightspace;
    DsliderPos(4) = textheight;
    
    AsliderPos(1) = AtextPos(1)+AtextPos(3)+midspace;
    AsliderPos(2) = AtextPos(2);
    AsliderPos(3) = peakpanelPos(3)-AsliderPos(1)-midspace-AcounterPos(3)-rightspace;
    AsliderPos(4) = textheight;
    
    thresTextPos(1) = leftspace;
    thresTextPos(2) = EtextPos(2)-2*topspace-textheight-1;
    thresTextPos(3) = peakpanelPos(3)-rightspace-leftspace;
    thresTextPos(4) = textheight;
    
    DthresTextPos(1) = leftspace;
    DthresTextPos(2) = thresTextPos(2)-topspace-textheight-1;
    DthresTextPos(3) = textwidth;
    DthresTextPos(4) = textheight;

    AthresTextPos(1) = leftspace;
    AthresTextPos(2) = thresTextPos(2)-2*topspace-2*textheight-1;
    AthresTextPos(3) = textwidth;
    AthresTextPos(4) = textheight;
    
    pushbuttonPos(3) = buttonwidth;
    pushbuttonPos(4) = 2*editheight+midspace;
    pushbuttonPos(1) = peakpanelPos(3)-rightspace-pushbuttonPos(3);
    pushbuttonPos(2) = AthresTextPos(2);

    DthresEditPos(1) = DsliderPos(1);
    DthresEditPos(2) = DthresTextPos(2);
    DthresEditPos(3) = pushbuttonPos(1)-DthresEditPos(1)-midspace;
    DthresEditPos(4) = editheight;

    AthresEditPos(1) = AsliderPos(1);
    AthresEditPos(2) = AthresTextPos(2);
    AthresEditPos(3) = pushbuttonPos(1)-AthresEditPos(1)-midspace;
    AthresEditPos(4) = editheight;

    % If widths are less than 
    minsliderWidth = 10;
    if DsliderPos(3)<minsliderWidth
        DsliderPos(3) = minsliderWidth;
    end
    if AsliderPos(3)<minsliderWidth
        AsliderPos(3) = minsliderWidth;
    end
    mineditWidth = 20;
    if DthresEditPos(3)<mineditWidth
        DthresEditPos(3) = mineditWidth;
    end
    if AthresEditPos(3)<mineditWidth
        AthresEditPos(3) = mineditWidth;
    end

    % Set positions
    setpixelposition(mainhandles.DPeakFinderTextbox,DtextPos)
    setpixelposition(mainhandles.APeakFinderTextbox,AtextPos)
    setpixelposition(mainhandles.EPeakCounterTextbox,EtextPos)
    setpixelposition(mainhandles.DPeakSlider,DsliderPos)
    setpixelposition(mainhandles.APeakSlider,AsliderPos)
    setpixelposition(mainhandles.DPeakCounter,DcounterPos)
    setpixelposition(mainhandles.APeakCounter,AcounterPos)
    setpixelposition(mainhandles.EPeakCounter,EcounterPos)
    
    setpixelposition(mainhandles.PeakfinderThresholdTextbox,thresTextPos)
    setpixelposition(mainhandles.DPeakfinderThresholdTextbox,DthresTextPos)
    setpixelposition(mainhandles.APeakfinderThresholdTextbox,AthresTextPos)
    setpixelposition(mainhandles.DPeakfinderThresholdEditbox,DthresEditPos)
    setpixelposition(mainhandles.APeakfinderThresholdEditbox,AthresEditPos)
    setpixelposition(mainhandles.runpeakfinderPushbutton,pushbuttonPos)
end
