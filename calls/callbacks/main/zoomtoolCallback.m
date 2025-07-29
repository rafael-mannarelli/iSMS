function mainhandles = zoomtoolCallback(mainhandles, axchoice)
% Callback for the zoom tool.
%
%    Input:
%     mainhandles   - handles structure of the main window
%     axchoice      - 'raw' 'ROI'
%
%    Output:
%     mainhandles   - ...
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

% If there is no data loaded
if isempty(mainhandles.data)
    set(mainhandles.mboard, 'String', 'No data loaded.')
    return
end

% If there is no image plotted in the axes
% if isempty(mainhandles.imageHandle) || ~ishandle(mainhandles.imageHandle)
%     cla(mainhandles.ImageAxes1)
%     set(mainhandles.mboard, 'String', 'No image plotted.')
%     return
% end

% Turn off other active tools
mainhandles = turnofftoggles(mainhandles,'zoom');

% Close existing instance of the zoom tool
if ishandle(mainhandles.zoomwindowHandle)
    try delete(mainhandles.zoomwindowHandle), end
    set(mainhandles.mboard,'String','')
    return
end

%% Open a zoom window if it's not open already, or put attention to it

mainhandles = zoomWindow(mainhandles); % Handle stored in handles.zoomwindowHandle

%% Create image scroll panel in new figure window

if strcmpi(axchoice,'ROI')
    selectedImage = getimage(mainhandles.ROIimage);
else
    selectedImage = getimage(mainhandles.rawimage);
end

% Make a scroll panel in the zoom window
warning off
if strcmpi(axchoice,'ROI')
    for i = 1:3
        selectedImage(:,:,i) = flipud(selectedImage(:,:,i));
    end
    zoomimageHandle = image(selectedImage); % Handle to plotted image in the scroll panel
    
else
    zoomimageHandle = imagesc(flipud(selectedImage)); % Handle to plotted image in the scroll panel
end
mainhandles.zoomwindowSPHandle = imscrollpanel(mainhandles.zoomwindowHandle, zoomimageHandle); % Handle to scroll panel
set(mainhandles.zoomwindowSPHandle,...
    'Units','normalized',...
    'Position',[0 .1 1 .9]) % Set size of panel in figure window
set(mainhandles.zoomwindowHandle, 'Units','normalized',...
    'Position',[0.1 .3 .3 .4]) % Set size of figure window
warning on

% Make a magnification box
hMagBox = immagbox(mainhandles.zoomwindowHandle, zoomimageHandle);
pos = get(hMagBox,'Position');
set(hMagBox,'Position',[0 0 pos(3) pos(4)])

% Make an overview panel in the main window
if strcmpi(axchoice,'ROI')
    mainhandles.imoverviewpanelHandle = imoverviewpanel(mainhandles.uipanelROIimage, zoomimageHandle);
else
    mainhandles.imoverviewpanelHandle = imoverviewpanel(mainhandles.uipanelRawimage, zoomimageHandle);
end

%% Update

% Update handles structure
updatemainhandles(mainhandles)

% Display message
set(mainhandles.mboard,'String','Zooming in and out is done from the Zoom window''s toolbar.')

% Make sure window always is on top
figure(mainhandles.zoomwindowHandle)
setFigOnTop([])
