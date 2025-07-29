function histogramwindowResizeFcn(hwHandles)
% Called when resizing the histogramwindow. The GUI layout depends on
% excitation scheme
%
%    Input:
%     hwHandles    - histogramwindow handles structure
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

if nargin<1
    mainhandles = guidata(getappdata(0,'mainhandle'));
    hwHandles = guidata(mainhandles.histogramwindowHandle);
end

% Get mainhandles
mainhandles = getmainhandles(hwHandles);

%% Dimensions

GUIdimensions
leftspace = 8;
rightspace = 30;
topspace = 7;

panelW = 150;
panel1H = 175;
panel2H = 62;

textW = 90;

popupW = 17;

lowerY = bottomspace+2*textheight+verspace+vergap;
rightX = leftspace+panelW+64;

figpos = getpixelposition(hwHandles.figure1);
listW = panelW;
listH = figpos(4)-bottomspace-topspace-3*textheight-panel1H-panel2H-2*verspace-3*vergap;

histH = 83;
SEplotW = figpos(3)-rightX-rightspace-histH;
SEplotH = figpos(4)-lowerY-histH-2*topspace;

sliderH = 17;
sliderW = histH-sliderH-2*horspace;

if mainhandles.settings.excitation.alex
    
    %% Set positions
    
    if listH<1
        return
    end
    
    % GUI layout in the ALEX scheme
    
    % Counters
    setpixelposition(hwHandles.moleculeCounterTextbox,[leftspace bottomspace textW textheight])
    setpixelposition(hwHandles.moleculeCounter,[leftspace+textW+horspace bottomspace textW textheight])
    setpixelposition(hwHandles.frameCounterTextbox,[leftspace bottomspace+textheight+verspace textW textheight])
    setpixelposition(hwHandles.frameCounter,[leftspace+textW+horspace bottomspace+textheight+verspace textW textheight])
    
    % Left side
    vpos = lowerY;
    setpixelposition(hwHandles.FilesListbox,[leftspace vpos listW listH])
    vpos = vpos+listH+verspace;
    setpixelposition(hwHandles.MergeFilesTextbox,[leftspace+2 vpos listW textheight])
    
    vpos = vpos+textheight+vergap;
    setpixelposition(hwHandles.GaussiansPanel,[leftspace vpos panelW panel2H])
    
    s = getpixelposition(hwHandles.GaussiansTextbox);
    correctPanel(hwHandles.GaussiansTextbox,s(1)+5)
    correctPanel(hwHandles.GaussiansSlider,s(1))
    correctPanel(hwHandles.GaussiansEditbox,s(1)+2)
    
    vpos = vpos+panel2H+vergap;
    setpixelposition(hwHandles.plotchoicePanel,[leftspace vpos panelW panel1H])
    
    % Right side
    setpixelposition(hwHandles.SEplot,[rightX lowerY SEplotW SEplotH])
    setpixelposition(hwHandles.Ehist, [rightX lowerY+SEplotH SEplotW histH])
    setpixelposition(hwHandles.Shist, [rightX+SEplotW lowerY histH SEplotH])
    
    setpixelposition(hwHandles.EbinsizeSlider, [rightX+SEplotW+horspace figpos(4)-2*topspace-sliderH sliderW sliderH])
    setpixelposition(hwHandles.EbinsTextbox, [rightX+SEplotW+horspace figpos(4)-2*topspace-2*sliderH-verspace sliderW sliderH])
    
    setpixelposition(hwHandles.SbinsizeSlider, [figpos(3)-rightspace-sliderH lowerY+SEplotH+horspace sliderH sliderW])
    setpixelposition(hwHandles.SbinsTextbox, [rightX+SEplotW+horspace lowerY+SEplotH+horspace+round(sliderW/2)-round(textheight/2) sliderW sliderH])
    
else
    % GUI layout in the single-color scheme
    
    bottomspace = 12;
    axspaceV = 12;
    axspaceR = 12;
    axspaceL = 70;
    axspaceB = 50;
    axspaceT = topspace+sliderheight+vergap;
    
    lowerH = 175;
    
    panelW2 = 230;
    
    topH = axspaceT;
    listW = figpos(3)-axspaceR-panelW-panelW2-axspaceR-2*horspace;
    listH = lowerH-verspace-textheight;
    sliderW = 60;
    textW1 = 150;%2*textW;
    textW2 = 120;%figpos(3)-axspaceL-leftspace-textW1-2*horspace-sliderW-axspaceR;
    
    % Lower
    hpos = axspaceR;
    setpixelposition(hwHandles.plotchoicePanel, [hpos bottomspace panelW lowerH])
    
    hpos = hpos+panelW+horspace;
    setpixelposition(hwHandles.FilesListbox, [hpos bottomspace listW lowerH-8])
    
    hpos = figpos(3)-axspaceR-panelW2;
    setpixelposition(hwHandles.GaussiansPanel, [hpos bottomspace panelW2 lowerH])
    temp = getpixelposition(hwHandles.GaussTable);
    temp(1) = 0;
    temp(2) = 0;
    temp(3) = panelW2;
    setpixelposition(hwHandles.GaussTable,temp)
    
    % Ax
    vpos = bottomspace+lowerH+bottomspace;
    panelsize = [0 vpos figpos(3)+2 figpos(4)-vpos+2];
    setpixelposition(hwHandles.backgroundPanel,panelsize)
    axH = panelsize(4)-axspaceB-axspaceT;
    
    setpixelposition(hwHandles.Ehist, [axspaceL axspaceB panelsize(3)-axspaceL-axspaceR axH])
    
    % Top
    vpos = panelsize(4)-vergap-sliderH;%axspaceB+axH+verspace;
    hpos = panelsize(3)-axspaceR-sliderW;
    setpixelposition(hwHandles.EbinsizeSlider, [hpos vpos sliderW sliderH])
    hpos = hpos-horspace-textW2;
    setpixelposition(hwHandles.EbinsTextbox, [hpos vpos textW2 sliderH])
    
    hpos = axspaceL+35;
    setpixelposition(hwHandles.moleculeCounter, [hpos vpos textW1 sliderH])
    setpixelposition(hwHandles.frameCounter, [hpos vpos+textheight+verspace textW1 sliderH])
    
end
end

function correctPanel(h,s)
temp = getpixelposition(h);;
temp(2) = s;
setpixelposition(h,temp)
end

