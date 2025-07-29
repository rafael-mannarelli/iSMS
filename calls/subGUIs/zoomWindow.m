function mainhandles = zoomWindow(mainhandles)
% Opens a new figure window for image profiles, or brings the already
% opened one forward.
%
%    Input:
%     mainhandles   - handles structure of the main window
%
%    Output:
%     mainhandles   - ..
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
if ~isempty(mainhandles.zoomwindowHandle) && ishandle(mainhandles.zoomwindowHandle)
    figure(mainhandles.zoomwindowHandle)
return
end

% Try delete any leftovers
warning off
try delete(mainhandles.zoomwindowHandle), end
warning on

%% Make new window
fh = figure('Toolbar','none',...
    'Menubar','none'); % Make new figure window
% set(fh, 'Units','normalized',...
%     'Position',[0.65 .3 .3 .4]) % Set size of figure window
updatelogo(fh) % Window logo

% Put in handle structure
mainhandles.zoomwindowHandle = fh;
updatemainhandles(mainhandles)

% Figure properties
set(fh, 'name','Zoom window')

% Don't allow docking or numbered titles
set(fh, 'numbertitle','off', 'DockControls','off')

%% Make a toolbar with zoom in and out
ht = uitoolbar(fh);

% Use a MATLAB icon for the tool
icon = imread(fullfile(...
    mainhandles.resourcedir,'overview_zoom_in.png'));

% Change background color so it looks transparent
% backgrColor = get(fh,'Color'); % Background color
% temp = sum(icon,3);
% idx = find(temp<100);
% icon(idx) = backgrColor(1)*255;
% icon(idx+numel(temp)) = backgrColor(2)*255;
% icon(idx+2*numel(temp)) = backgrColor(3)*255;

% Create a uipushtool in the toolbar
hpt = uipushtool(ht,'CData',icon,...
    'TooltipString','Zoom in',...
    'ClickedCallback', {@zoomin_Callback, mainhandles});

% And now a zoom out...
% Use a MATLAB icon for the tool
icon = imread(fullfile(...
    mainhandles.resourcedir,'overview_zoom_out.png'));
% 
% temp = sum(icon,3);
% idx = find(temp<100);
% icon(idx) = backgrColor(1)*255;
% icon(idx+numel(temp)) = backgrColor(2)*255;
% icon(idx+2*numel(temp)) = backgrColor(3)*255;

% Create a uipushtool in the toolbar
hpt = uipushtool(ht,'CData',icon,...
    'TooltipString','Zoom out',...
    'ClickedCallback', {@zoomout_Callback, mainhandles});

end

function zoomin_Callback(hObject,~,mainhandles)
mainhandles = guidata(mainhandles.figure1); % The scroll panel handle is not in the handles structure sent but has been added later
if isempty(mainhandles.zoomwindowSPHandle) || ~ishandle(mainhandles.zoomwindowSPHandle)
    return
end

% Get the api of the scroll panel
api = iptgetapi(mainhandles.zoomwindowSPHandle);

% Returns the current magnification factor of the target image in units of
% screen pixels per image pixel. Multiply mag by 100 to convert to
% percentage. For example if mag=2, the magnification is 200
mag = api.getMagnification();

% Returns the current visible portion of the image.
% where r is a rectangle [xmin ymin width height].
r = api.getVisibleImageRect();

% Sets the magnification of the target image in units of screen pixels per
% image pixel where new_mag is a scalar magnification factor.
new_mag = mag*1.5;
api.setMagnification(new_mag)

end

function zoomout_Callback(hObject,eventdata,mainhandles)
mainhandles = guidata(mainhandles.figure1); % The scroll panel handle is not in the handles structure sent but has been added later
if isempty(mainhandles.zoomwindowSPHandle) || ~ishandle(mainhandles.zoomwindowSPHandle)
    return
end

% Get the api of the scroll panel
api = iptgetapi(mainhandles.zoomwindowSPHandle);

% Returns the current magnification factor of the target image in units of
% screen pixels per image pixel. Multiply mag by 100 to convert to
% percentage. For example if mag=2, the magnification is 200
mag = api.getMagnification();

% Returns the current visible portion of the image.
% where r is a rectangle [xmin ymin width height].
r = api.getVisibleImageRect();

% Sets the magnification of the target image in units of screen pixels per
% image pixel where new_mag is a scalar magnification factor.
new_mag = mag/1.5;
api.setMagnification(new_mag)

end
