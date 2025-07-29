function ROIcallback(pos,choice,pos2,file)
% Runs when the Droi is moved
%
%    Input:
%     pos     - position of ROI
%     choice  - 1: Donor. 2: Acceptor
%     pos2    - position of other ROI
%     file    - movie file
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

if ~isempty(getappdata(0,'dontupdateROIpos'))
    return
end

% Get handles structure
mainhandles = guidata(getappdata(0,'mainhandle'));
if nargin<4 || isempty(file)    
    file = get(mainhandles.FilesListbox,'Value');
end

% Delete possible ROI handles if no data is loaded
if (isempty(mainhandles.data))
    try delete(mainhandles.DROIhandle),  end
    try delete(mainhandles.AROIhandle),  end
    return
end

% Check if raw movie has been deleted
if isempty(mainhandles.data(file).imageData) 
    set(mainhandles.mboard,'String',sprintf('%s\n\n%s',...
        'The raw movie has been deleted for this file so nothing happens when changing the ROI positions. ',...
        'You can reload the raw movie from the ''Performance -> Memory -> Reload raw movie'' menu button.'))
    return
end

% Close windows
if strcmpi(get(mainhandles.Toolbar_FRETpairwindow,'state'),'on')
    set(mainhandles.mboard,'String','Note: All other windows are closed when the ROIs are changed to limit delay times.')
end
if isempty(getappdata(0,'closewindows'))
    mainhandles = closeWindows(mainhandles);
end

% Show info box
message = sprintf(['TIPS for aligning the Regions-Of-Interests (ROIs):\n\n'...
    'There are different ways to align the ROI positions:\n\n'...
    '   1) Drag the ROIs manually inside the raw image.\n'...
    '   2) Fine-adjust the ROI positions from the menu just above the raw image.\n'...
    '   3) Auto-align ROI positions in the menu just above the raw image.\n'...
    '       This is recommended only for samples with a fair number of peaks in each channel.\n'...
    '   4) Load ROI positions from file in the ''File->Emission channel'' menu.\n\n'...
    'You set the default ROI positions in the ''File->Emission channel'' menu.']);
mainhandles = myguidebox(mainhandles,'ROI tips',message,'ROI',0,'http://isms.au.dk/documentation/align-emission-channels/');

% Which ROI
if choice==1
    % Donor ROI is being dragged
    field1 = 'DROIhandle';
    field2 = 'AROIhandle';
    r1_old =  mainhandles.data(file).Droi; % Previous ROI position
else
    % Acceptor ROI is being dragged
    field1 = 'AROIhandle';
    field2 = 'DROIhandle';
    r1_old =  mainhandles.data(file).Aroi; % Previous ROI position
end

if nargin<3
    pos2 = getPosition(mainhandles.(field2));
end

% Get imrect positions
r1 = single( pos ); % ROI being dragged. Single to avoid unintended round off
r2 = single( pos2 ); % Other ROI = [xPos yPos width height]

%% Check dragging direction

diff = r1_old(3:4)-r1(3:4); % Difference between new and previous ROI positions (to detect from where dragging was performed from)
if sum(round(abs(diff)))~=0
    % Do the sum check to avoid unintended round off
    
    % Re-position A roi
    if (r1(1)~=r1_old(1)) && (r1(2)==r1_old(2)) && (r1(3)~=r1_old(3)) && (r1(4)~=r1_old(4))
        % Dragging from left top corner
        r2(1:2) = r2(1:2)+[diff(1) 0];
        
    elseif (r1(1)~=r1_old(1)) && (r1(2)==r1_old(2)) && (r1(3)~=r1_old(3)) && (r1(4)==r1_old(4))
        % Dragging from left middle
        r2(1:2) = r2(1:2)+[diff(1) 0];
        
    elseif (r1(1)~=r1_old(1)) && (r1(2)~=r1_old(2)) && (r1(3)~=r1_old(3)) && (r1(4)~=r1_old(4))
        % Dragging from left bottom corner
        r2(1:2) = r2(1:2)+diff;
        
    elseif (r1(1)==r1_old(1)) && (r1(2)~=r1_old(2)) && (r1(3)==r1_old(3)) && (r1(4)~=r1_old(4))
        % Dragging from bottom middle
        r2(1:2) = r2(1:2)+[0 diff(2)];
        
    elseif (r1(1)==r1_old(1)) && (r1(2)~=r1_old(2)) && (r1(3)~=r1_old(3)) && (r1(4)~=r1_old(4))
        % Dragging from bottom right corner
        r2(1:2) = r2(1:2)+[0 diff(2)];
        
    else
        % Dragging from top middle, right top or right middle, or if just
        % moving the ROI without resizing
        r2(1:2) = r2(1:2);
    end
end

% Set sizes equal
r2(3:4) = r1(3:4);

%% If new roi size makes Droi exceed image limits, move it further into image

W = size(mainhandles.data(file).avgimage,1);
H = size(mainhandles.data(file).avgimage,2);
if r2(1)<0.5
    r2(1) = 0.5;
end
if sum(r2([1 3]))>W+.4
    outside = sum(r2([1 3]))-W-.4; % Number of ROI pixels outside movie in x direction [DROI AROI]
    r2(1) = r2(1)-outside; % Make ROI smaller but keep position
end
if r2(2)<0.5
    r2(2) = 0.5;
end
if sum(r2([2 4]))>H+.4
    outside = sum(r2([2 4]))-H-.4; % Number of ROI pixels outside movie in x direction [DROI AROI]
    r2(2) = r2(2)-outside; % Make ROI smaller but keep position
end

%% Update ROI position

if nargin<3
    setappdata(0,'dontupdateROIpos',1) % Tells this function not to run again
    setPosition(mainhandles.(field2),r2) % [x y width height]
    rmappdata(0,'dontupdateROIpos')
end

%% Update handles structure

% Store new ROI positions
if choice==1
    Droi = r1;
    Aroi = r2;
else
    Droi = r2;
    Aroi = r1;
end
mainhandles = storeROIposition(mainhandles,file,Droi,Aroi);

