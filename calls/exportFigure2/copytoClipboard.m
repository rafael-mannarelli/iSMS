function copytoClipboard(ax)
% Callback for copying plotted image to clipboard
%
%    Input:
%     handles   - handles structure of the main window
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

mainhandle = getappdata(0,'mainhandle');
if isempty(mainhandle) || ~ishandle(mainhandle)
    return
end

handles = guidata(mainhandle);

% Get image from axes
[imageData,flag] = getimage(ax);
if flag==0
    % Not an image
    return
elseif flag==1 || flag==2 || flag==3
    % Convert intensity image to rgb
    imageData = mat2gray(imageData);
%     imageData = gray2rgb(imageData);
end

d = contrast2sliderpos(handles,handles.data(1).rawcontrast);
imageData = imadjust(imageData,d,[0 1]);

% Set pointer to thinking
pointer = get(handles.figure1,'pointer'); % e.g 'arrow'
set(handles.figure1, 'pointer', 'watch')
drawnow

% Copy to clipboard
try
    imclipboard('copy', imageData)
catch err
    rethrow err
    % Set pointer back to arrow
    set(handles.figure1, 'pointer', pointer)
    drawnow
end

% Set pointer back to arrow
set(handles.figure1, 'pointer', pointer)

% % Remove appdata
% rmappdata(0,'alphaMap')
