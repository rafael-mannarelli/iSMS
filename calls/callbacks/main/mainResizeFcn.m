function mainResizeFcn(hObject, mainhandles)
% Callback when user resizes main GUI window. See also RAWtopbarResizeFcn
%
%     Input:
%      hObject      - handle to the main window
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

% Get screen size to check if window sizes exceeds screen size
rootunits = get(0,'units');
set(0,'Units','pixels')
scrsize = get(0,'ScreenSize');
set(0,'units',rootunits);

%% Set position of main window

% winsize = getpixelposition(mainhandles.figure1);
figurePos = getpixelposition(mainhandles.figure1);%checkWindowSize(winsize);
% if ~isequal(winsize,figurePos)
%     setpixelposition(mainhandles.figure1,figurePos);
% end

%% Change position of grid flex panel

if isfield(mainhandles,'gridflexPanel')
    gridflexPos = getpixelposition(mainhandles.gridflexPanel);
    
    gridflexPos(1) = leftspace+buttonwidth+midspace;
    gridflexPos(2) = bottomspace+statusheight+bottomspace;
    gridflexPos(3) = figurePos(3)-rightspace-gridflexPos(1);
    gridflexPos(4) = figurePos(4)-topspace-gridflexPos(2);
    
    setpixelposition(mainhandles.gridflexPanel,gridflexPos)
end

%% Change positions of left toolbar

dataupPos = getpixelposition(mainhandles.DataUpPushbutton);
datadownPos = getpixelposition(mainhandles.DataDownPushbutton);
addPos = getpixelposition(mainhandles.AddMoviePushbutton);
deletefilePos = getpixelposition(mainhandles.DeleteMoviePushbutton);
reloadPos = getpixelposition(mainhandles.ReloadMoviePushbutton);
clearPos = getpixelposition(mainhandles.ClearRawPushbutton);

addfilePos(1) = leftspace;
addfilePos(2) = figurePos(4)-4*topspace-buttonheight;
addfilePos(3) = buttonwidth;
addfilePos(4) = buttonheight;

deletefilePos = addfilePos;
deletefilePos(2) = figurePos(4)-5*topspace-2*buttonheight;

dataupPos = addfilePos;
dataupPos(2) = figurePos(4)-7*topspace-3*buttonheight;

datadownPos = addfilePos;
datadownPos(2) = figurePos(4)-8*topspace-4*buttonheight;

reloadPos = addfilePos;
reloadPos(2) = figurePos(4)-10*topspace-5*buttonheight;

clearPos = addfilePos;
clearPos(2) = figurePos(4)-11*topspace-6*buttonheight;

% Set positions
setpixelposition(mainhandles.AddMoviePushbutton, addfilePos)
setpixelposition(mainhandles.DeleteMoviePushbutton, deletefilePos)
setpixelposition(mainhandles.DataUpPushbutton, dataupPos)
setpixelposition(mainhandles.DataDownPushbutton, datadownPos)
setpixelposition(mainhandles.ReloadMoviePushbutton, reloadPos)
setpixelposition(mainhandles.ClearRawPushbutton, clearPos)

%% Change position of top bar

%% Change positions of lower statusbar

% Get positions
memoryTextPos = getpixelposition(mainhandles.MemoryTextbox);

% Status bar position
memoryx = figurePos(3)-memoryTextPos(3)-rightspace-1;
memoryTextPos(1) = memoryx;
memoryTextPos(2) = bottomspace;
memoryTextPos(4) = statusheight;

% Set positions
setpixelposition(mainhandles.MemoryTextbox,memoryTextPos)

%% Change positions of peakfinder elements

% see peakfinderResizeFcn.m

%% Nested

    function winsize2 = checkWindowSize(winsize)
        % Checks if window size exceeds screensize and adjusts accordingly
        winsize2 = winsize;
        
        % Check position
        if winsize2(1)<0
            winsize2(1) = 1;
        end
        if winsize2(2)<0
            winsize2(2) = 1;
        end
        
        % Check size
        if winsize2(3)>scrsize(3)
            
            % If window size is larger than screen size
            winsize2(1) = 1;
            winsize2(3) = scrsize(3);
            
        elseif sum(winsize2([1 3]))>scrsize(3)
            
            % If right border exceeds right screen size
            d = sum(winsize2([1 3]))-scrsize(3);
            winsize2(1) = winsize2(1)-d;
            if winsize2(1)<0
                
                % If movement caused the window to go outside left bound
                winsize2(3) = winsize2(3)+winsize2(1)-1;
                winsize2(1) = 1;
            end
        end
        
        if winsize2(4)>scrsize(4)
            
            % If window size is larger than screen size
            winsize2(2) = 1;
            winsize2(4) = scrsize(4);
            
        elseif sum(winsize2([2 4]))>scrsize(4)
            
            % If right border exceeds right screen size
            d = sum(winsize2([2 4]))-scrsize(4);
            winsize2(2) = winsize2(2)-d;
            if winsize2(2)<0
                
                % If movement caused the window to go outside left bound
                winsize2(4) = winsize2(4)+winsize2(2)-1;
                winsize2(2) = 1;
            end
        end
    end

end
