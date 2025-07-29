function [handles message] = applyROIposition(handles, filechoices, ROIs)
% Apply ROI position to filechoices, checking if position exceeds image
% dimensions.
%
%   Input:
%    handles      - handles structure of the main window
%    filechoices  - files to apply ROI position to
%    ROIs         - ROI position structure with fields .Droi and .Aroi
%
%   Output:
%    handles      - ..
%    message      - output message
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

message = '';

if isempty(handles.data) || isempty(filechoices)
    return
end

%% Check and set input ROI

for i = filechoices(:)'
    Droi = ROIs.Droi;
    Aroi = ROIs.Aroi;
    
    % If ROIs exceed image
    data = handles.data(i);
    image = handles.data(i).imageData;
    imwidth = size(image,1);
    imheight = size(image,2);
    
    % If ROI is positioned outside axis, set them to left and right hand side
    if Droi(1)>=imwidth || Aroi(1)>=imwidth || Droi(2)>=imheight || Aroi(2)>=imheight
        Droi = [.5 .5 imwidth/2 imheight];
        Aroi = [imwidth/2+.5 .5 imwidth/2 imheight];
    end
    
    % If ROI exceeds axis limits
    if sum(Droi([1 3]))>=imwidth+.5 || sum(Aroi([1 3]))>=imwidth+.5
        outside = [sum(Droi([1 3]))-imwidth-.4  sum(Aroi([1 3]))-imwidth-.4]; % Number of ROI pixels outside movie in x direction [DROI AROI]
        Droi(3) = Droi(3)-max(outside); % Make ROI smaller but keep position
        Aroi(3) = Droi(3); % Make ROI smaller but keep position
    end
    
    if sum(Droi([2 4]))>=imheight+.5 || sum(Aroi([2 4]))>=imheight+.5
        outside = [sum(Droi([2 4]))-imheight-.4  sum(Aroi([2 4]))-imheight-.4]; % Number of ROI pixels outside movie in x direction [DROI AROI]
        %     Droi(4) = floor(Droi(4)-max(outside)); % Make ROI smaller but keep position
        %     Aroi(4) = Droi(4); % Make ROI smaller but keep position
        Droi(4) = Droi(4)-max(outside); % Make ROI smaller but keep position
        Aroi(4) = Droi(4); % Make ROI smaller but keep position
    end
    
    % Check again if ROI sizes now exceed the image now
    if sum(Droi([1 3]))>=imwidth+.5 || sum(Aroi([1 3]))>=imwidth+.5 || sum(Droi([2 4]))>=imheight+.5 || sum(Aroi([2 4]))>=imheight+.5
        message = sprintf('%sThe loaded ROI positions exceeded the image limits in %s.\n',message,handles.data(i).name);
        continue
    end
    
    % Store
    handles = storeROIposition(handles,i,Droi,Aroi,0);
%     handles.data(i).Droi = Droi;
%     handles.data(i).Aroi = Aroi;
    
end

%% Update GUI

updatemainhandles(handles)
handles = filesListboxCallback(handles.FilesListbox); % Imitate click in listbox

% Displat message about size issue
if ~isempty(message)
    set(handles.mboard,'String',sprintf('%sThe old ROI positions are kept.',message))
end
