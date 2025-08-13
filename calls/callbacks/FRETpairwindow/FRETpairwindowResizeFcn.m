function FRETpairwindowResizeFcn(fpHandles)
% Called when resizing the histogramwindow
%
%    Input:
%     fpHandles    - FRETpairwindow handles structure
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
    fpHandles = guidata(mainhandles.FRETpairwindowHandle);
end

% Get mainhandles
mainhandles = getmainhandles(fpHandles);

% Ensure DeepFRET UI elements exist before adjusting positions
required = {'text28','aggregatedValueTextBox','dynamicValueTextBox',...
            'noisyValueTextBox','scrambledValueTextBox','staticValueTextBox'};
if any(~cellfun(@(f) isfield(fpHandles,f) && ishandle(fpHandles.(f)), required))
    return;
end

%% Dimensions

GUIdimensions
topspace = 7;
leftspace = 8;
rightspace = 10;

textW1 = 42;
textW2 = 38;
checkH = 23;

axspaceV = 12;
axspaceR = 12;
axspaceL = 78;
axspaceB = 50;
axspaceT = topspace+sliderheight+verspace;

figpos = getpixelposition(fpHandles.figure1);
axH = round( (figpos(4)-axspaceT-axspaceB-4*axspaceV)/5 );
imW = axH;
imH = imW;

axW = round( 3/4*(figpos(3)-rightspace-imW-axspaceR-axspaceL-leftspace) );

listW = axW*1/3;
listY = bottomspace+4*textheight+4*verspace+vergap; % Bottom listbox position
listsH = figpos(4)-axspaceT-buttonheight-2*verspace-2*vergap-listY; % Sum of listbox heights
listH1 = round( listsH*0.7 );
listH2 = round( listsH*0.3 );

axX = leftspace+listW+axspaceL; % Axes x position
imX = axX+axW+axspaceR;

buttonH = 27;
buttonW = listW-14;

editW = imW-textW2-horspace;
editX = imX+textW2+horspace;

if listW<1
    return
end

%% Counters

setpixelposition(fpHandles.DAbleachingsTextbox,[2*leftspace+2 bottomspace textW1 textheight])
setpixelposition(fpHandles.DAbleachCounter,[2*leftspace+2+textW1+horspace bottomspace textW1 textheight])
setpixelposition(fpHandles.AbleachingsTextbox,[2*leftspace+2 bottomspace+textheight+verspace textW1 textheight])
setpixelposition(fpHandles.AbleachCounter,[2*leftspace+2+textW1+horspace bottomspace+textheight+verspace textW1 textheight])
setpixelposition(fpHandles.DbleachingsTextbox,[2*leftspace+2 bottomspace+2*textheight+2*verspace textW1 textheight])
setpixelposition(fpHandles.DbleachCounter,[2*leftspace+2+textW1+horspace bottomspace+2*textheight+2*verspace textW1 textheight])

setpixelposition(fpHandles.BleachingEventsTextbox,[leftspace+2 bottomspace+3*textheight+3*verspace listW textheight])

%% Left side

vpos = listY;
setpixelposition(fpHandles.GroupsListbox,[leftspace vpos listW listH2])
vpos = vpos+listH2+verspace;
setpixelposition(fpHandles.GroupsTextbox,[leftspace+2 vpos listW textheight])

vpos = vpos+textheight+vergap;
setpixelposition(fpHandles.DeletePairPushbutton,[leftspace+7 vpos buttonW buttonH])

vpos = vpos+buttonH+verspace;
setpixelposition(fpHandles.PairListbox,[leftspace vpos listW listH1])
vpos = vpos+listH1+verspace;
setpixelposition(fpHandles.FRETpairsTextbox,[leftspace+2 vpos 150 textheight])

%% Axes

vpos = axspaceB;
setpixelposition(fpHandles.PRtraceAxes,[axX vpos axW axH])
vpos = vpos+axH+axspaceV;
setpixelposition(fpHandles.StraceAxes,[axX vpos axW axH])
vpos = vpos+axH+axspaceV;
setpixelposition(fpHandles.AAtraceAxes,[axX vpos axW axH])
vpos = vpos+axH+axspaceV;
setpixelposition(fpHandles.ADtraceAxes,[axX vpos axW axH])
vpos = vpos+axH+axspaceV;
setpixelposition(fpHandles.DDtraceAxes,[axX vpos axW axH])

%% Right side

% Correction factors
if editW>=1
    vpos = bottomspace;%axspaceB-vergap-checkH;
    setpixelposition(fpHandles.molspecCheckbox, [imX vpos imW+rightspace checkH])
    
    vpos = axspaceB;
    setpixelposition(fpHandles.GammaTextbox, [imX vpos textW2 textheight])
    setpixelposition(fpHandles.GammaEditbox, [imX+textW2+horspace vpos editW editheight])
    
    if ~isempty(mainhandles) && mainhandles.settings.excitation.alex
        vpos = vpos+editheight+verspace;
        setpixelposition(fpHandles.AdirectTextbox, [imX vpos textW2 textheight])
        setpixelposition(fpHandles.AdirectEditbox, [imX+textW2+horspace vpos editW editheight])
    end
    
    vpos = vpos+editheight+verspace;
    setpixelposition(fpHandles.DleakTextbox, [imX vpos textW2 textheight])
    setpixelposition(fpHandles.DleakEditbox, [imX+textW2+horspace vpos editW editheight])
end

% Pair coordinates
if ~isempty(mainhandles) && mainhandles.settings.excitation.alex
    vpos = axspaceB+2*axH+axspaceV;
else
    vpos = axspaceB+3*axH+2*axspaceV;
end

vpos = vpos-2*textheight-verspace;
setpixelposition(fpHandles.PairCoordinatesTextbox, [imX-4 vpos imW+8 textheight])
vpos = vpos+textheight+verspace;
setpixelposition(fpHandles.paircoordinates, [imX-4 vpos imW+8 textheight])
vpos = vpos+textheight+verspace;
setpixelposition(fpHandles.text28,[imX-4 vpos imW+8 textheight])
vpos = vpos+textheight+verspace;
setpixelposition(fpHandles.aggregatedValueTextBox,[imX-4 vpos imW+8 textheight])
vpos = vpos+textheight+verspace;
setpixelposition(fpHandles.staticValueTextBox,[imX-4 vpos imW+8 textheight])
vpos = vpos+textheight+verspace;
setpixelposition(fpHandles.dynamicValueTextBox,[imX-4 vpos imW+8 textheight])
vpos = vpos+textheight+verspace;
setpixelposition(fpHandles.noisyValueTextBox,[imX-4 vpos imW+8 textheight])
vpos = vpos+textheight+verspace;
setpixelposition(fpHandles.scrambledValueTextBox,[imX-4 vpos imW+8 textheight])
vpos = vpos+textheight+verspace;
setpixelposition(fpHandles.CorrectionFactorsTextbox, [imX-rightspace vpos imW+2*rightspace textheight])

% Images
vpos = axspaceB+2*axH+2*axspaceV;
setpixelposition(fpHandles.AAimageAxes, [imX vpos imW imH])
vpos = vpos+imH+axspaceV;
setpixelposition(fpHandles.ADimageAxes, [imX vpos imW imH])
vpos = vpos+imH+axspaceV;
setpixelposition(fpHandles.DDimageAxes, [imX vpos imW imH])

% Slider
vpos = vpos+imH+verspace;
setpixelposition(fpHandles.ContrastSlider, [imX vpos imW sliderheight])
