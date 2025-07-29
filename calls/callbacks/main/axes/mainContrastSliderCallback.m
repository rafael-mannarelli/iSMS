function mainContrastSliderCallback(pos,choice)
% Callback when an image contrast-slider is changed
%
%   Input:
%    pos     - [x y width height]
%    choice  - 1: called from raw slider. 2: from green ROI slider. 3: from
%              red ROI slider
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

% dontupdate if its being called after just updating its position
if ~isempty(getappdata(0,'dontupdate'))
    return
end

% Get mainhandles
mainhandle = getappdata(0,'mainhandle');
mainhandles = guidata(mainhandle);

% Selected fil
file = get(mainhandles.FilesListbox,'Value');

if choice==1
    % Callback from raw axes
    ax = 'rawcontrastSliderAx';
    imrectHandle = 'rawcontrastSliderHandle';
    contrastField = 'rawcontrast';
    rectcolor = 'b';

elseif choice==2
    % Callback for green ROI
    ax = 'greenROIcontrastSliderAx';
    imrectHandle = 'greenROIcontrastSliderHandle';
    contrastField = 'greenROIcontrast';
    rectcolor = 'g';
    
elseif choice==3
    % Callback for red ROI
    ax = 'redROIcontrastSliderAx';
    imrectHandle = 'redROIcontrastSliderHandle';
    contrastField = 'redROIcontrast';
    rectcolor = 'r';
end

% Delete possible ROI handles if no data is loaded
if isempty(mainhandles.data) %...
%     || isempty(mainhandles.data(file).imageData) || get(mainhandles.FramesListbox,'Value')~=1 || mainhandles.data(file).spot
    warning off
    try
        h = findobj(mainhandles.(ax),'type','rectangle')
        delete(h)
        delete(mainhandles.(imrectHandle))
        mainhandles.(imrectHandle) = [];
        updatemainhandles(mainhandles)
    end
    warning on
    return
end

%% Get position

% Position of frame slider ROI
pos = getPosition(mainhandles.(imrectHandle)); % [xPos yPos width height]

% Correct position to within y=[-5 15]
if pos(2)>-1 || pos(4)~=15 || pos(2)+pos(4)<=2
    pos(2) = -5;
    pos(4) = 15;
    setPosition(mainhandles.(imrectHandle),pos) % [x y width height]. This will re-run this function
    return
end
if pos(3)==0 % If width has been squeezed to zero
    pos(3) = 1;
    setPosition(mainhandles.(imrectHandle),pos) % [x y width height]. This will re-run this function
    return
end

% Set pointer to thinking (TOO SLOW)
% pointer = setpointer(handles.figure1,'watch');

%% Update according to position

% Convert imrect position to contrast values
contrastVal = 10.^[pos(1) pos(1)+pos(3)];

% Update handles structure with new contrast
mainhandles.data(file).(contrastField) = contrastVal;
updatemainhandles(mainhandles)

% Update plot
if choice==1
    
    % Update contrast. We can use the clim property because it's an
    % intensity image
    if mainhandles.settings.view.rawlogscale
        set(mainhandles.rawimage,'CLim',real(log10(mainhandles.data(file).rawcontrast)))
    else
        set(mainhandles.rawimage,'CLim', mainhandles.data(file).rawcontrast)
    end
    
else
    
    % Update ROI image
    mainhandles = updateROIimage(mainhandles,0,0,0);
    
end

%% Update textbox

updatemaincontrastsliderTextbox(mainhandles)

