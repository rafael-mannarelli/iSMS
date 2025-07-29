function mainhandles = liveintegrationROIcallback(mainhandles)
% Callback for the live-integration ROI in the main window
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

mainhandles = turnofftoggles(mainhandles,'L'); % Turns off all other selection toggles (A peaks and FRET-pair peaks)
if isempty(mainhandles.data) % If no data is loaded, return
    set(mainhandles.mboard,'String','No data loaded')
    return
end

% Delete if open
if (~isempty(mainhandles.liveROIhandle)) && (ishandle(mainhandles.liveROIhandle))
    try delete(mainhandles.liveROIhandle),  end
    return
end

file = get(mainhandles.FilesListbox,'Value'); % Selected movie file

% Get the start position of the live-ROI
data = mainhandles.data(file); % Data of selected file
if (isempty(data.liveROIpos)) || (data.Aroi(3)<=sum(data.liveROIpos([1 3]))) || (data.Aroi(4)<=sum(data.liveROIpos([2 4])));
    if (data.Aroi(3)>11) && (data.Aroi(4)>11) % Put live-ROI into center of the D and A ROIs
        mainhandles.data(file).liveROIpos = [data.Aroi(3)/2-5  data.Aroi(4)/2-5  11  11]; % [xmin ymin width height]
    else % If ROI is very small (< 11 pixels in width) make live ROI small too
        mainhandles.data(file).liveROIpos = [0.5 0.5 data.Aroi(3)-0.5 data.Aroi(4)-0.5];
    end
end
liveROIpos = mainhandles.data(file).liveROIpos; % The position of the live-ROI

%% Make live-ROI handle and define its position callback

liveROIhandle = imrect(mainhandles.ROIimage,liveROIpos); % [xmin ymin width height]
set(liveROIhandle,'Interruptible','off')
setColor(liveROIhandle,'white')
addNewPositionCallback(liveROIhandle,@(p) updateliveROI(p));

% Put D and A ROI movies into handles structure
[mainhandles,MBerror] = saveROImovies(mainhandles);
if MBerror % If couldn't save ROI movies due to lack of memory, return
    return
end

% Make constraint in imrect position:
fcn = makeConstrainToRectFcn('imrect',get(mainhandles.ROIimage,'XLim'),get(mainhandles.ROIimage,'YLim'));
setPositionConstraintFcn(liveROIhandle,fcn);

%% Update

mainhandles.liveROIhandle = liveROIhandle;
updatemainhandles(mainhandles)
updateliveROI(liveROIpos)
