function correctionfactorwindowResizeFcn(cfHandles)
% Called when resizing the correctionfactor window
%
%    Input:
%     cfHandles    - correctionfactorWindow handles structure
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
    cfHandles = guidata(mainhandles.correctionfactorwindowHandle);
end

%% Dimensions

GUIdimensions
topspace = 7;
leftspace = 5;

panelH = 97;

axspaceV = 10;
axspaceR = 14;
axspaceL = 75;
axspaceL2 = 65;
axspaceB = 50;
axspaceT = topspace+sliderheight+verspace;
rightspace = axspaceR;

figpos = getpixelposition(cfHandles.figure1);
axH1 = round( (figpos(4)-axspaceT-axspaceB-3*axspaceV)/4 );

listW = 165;
listH = figpos(4)-axspaceB-axspaceT;

buttonH = 27;
buttonW = listW-14;

axH2 = figpos(4)-axspaceT-2*axspaceB-panelH;
axW2 = axH2*1.1;
axW1 = round( figpos(3)-axspaceL-axspaceL2-axspaceR-listW-axW2-rightspace );

panelW = axW2;
sliderW = 50;
textW3 = axW2-sliderW-leftspace-horspace;

if axW1<1
    return
end

%% Left side

vpos = axspaceB;
setpixelposition(cfHandles.ax4,[axspaceL vpos axW1 axH1])
vpos = vpos+axH1+axspaceV;
setpixelposition(cfHandles.AAtraceAxes,[axspaceL vpos axW1 axH1])
vpos = vpos+axH1+axspaceV;
setpixelposition(cfHandles.ADtraceAxes,[axspaceL vpos axW1 axH1])
vpos = vpos+axH1+axspaceV;
setpixelposition(cfHandles.DDtraceAxes,[axspaceL vpos axW1 axH1])

vpos = vpos+axH1+verspace;
setpixelposition(cfHandles.CorrectionFactorDefTextbox,[axspaceL+leftspace vpos axW1-leftspace textheight])

%% Center

vpos = axspaceB-verspace-buttonH;
hpos = axspaceL+axW1+axspaceR;
setpixelposition(cfHandles.RemovePushbutton,[hpos+7 vpos buttonW buttonH])
vpos = axspaceB;
setpixelposition(cfHandles.PairListbox,[hpos vpos listW listH])

vpos = vpos+listH+verspace;
setpixelposition(cfHandles.PairCounter,[hpos+leftspace vpos listW-leftspace textheight])

%% Right side

vpos = axspaceB;
hpos = figpos(3)-axspaceR-panelW;
setpixelposition(cfHandles.CorrectionFactorPanel,[hpos vpos panelW panelH])

vpos = vpos+panelH+axspaceB;
setpixelposition(cfHandles.HistAxes,[hpos vpos axW2 axH2])

vpos = vpos+axH2+verspace;
setpixelposition(cfHandles.meanValueCounter,[hpos+leftspace vpos textW3 textheight])
setpixelposition(cfHandles.binSlider,[hpos+leftspace+textW3+horspace vpos sliderW sliderheight])

