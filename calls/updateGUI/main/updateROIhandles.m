function mainhandles = updateROIhandles(mainhandles)
% Updates/creates the D and A ROI handles in the global image of the main
% window
%
%    Input:
%     mainhandles   - handles structure of the main window
%
%    Output:
%     mainhandles   - handles structure of the main window
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

% Open this file if no input is specified
if nargin==0
    edit updateROIhandles.m
end

% Delete current ROIs
if isempty(mainhandles.data)
    warning off
    try delete(mainhandles.DROIhandle),  end
    try delete(mainhandles.AROIhandle),  end
    warning on
    return
end

% File
file = get(mainhandles.FilesListbox,'Value');

% Color
if mainhandles.settings.view.colorblind
    Dcolor = 'green';%'blue';
    Acolor = 'magenta';%'yellow';
else
    Dcolor = 'green';
    Acolor = 'red';
end

% ROI positions
Droi = mainhandles.data(file).Droi;
Aroi = mainhandles.data(file).Aroi;

%% Make roi's and define position callback

% Make constraint function in imrect position:
imXlim = get(mainhandles.rawimage,'XLim');
imYlim = get(mainhandles.rawimage,'YLim');
constrainFcn = makeConstrainToRectFcn('imrect',[imXlim(1) imXlim(2)-0.1],[imYlim(1) imYlim(2)-0.1]);

% Update ROIs
mainhandles.DROIhandle = activateROI(mainhandles.DROIhandle,Droi, Dcolor, @(p)updateDroiPos(p));
mainhandles.AROIhandle = activateROI(mainhandles.AROIhandle,Aroi, Acolor, @(p) updateAroiPos(p));
updatemainhandles(mainhandles)

%-- Each imrect position is now defined by MATLAB as follows:
% [x y width height], where
%  min(x)     =0.5 and max(x)     =size(image,1)+0.5
%  min(y)     =0.5 and max(y)     =size(image,2)+0.5
%  min(width) =0   and max(width) =size(image,1)
%  min(height)=0   and max(height)=size(image,2)
%----

%% Nested

    function ROIhandle = activateROI(ROIhandle,pos,col,updateFcn)
        % Create or update ROI handle
        if ~isempty(ROIhandle)
            
            try
                % Update position of existing handles (fastest)
                setappdata(0,'dontupdateROIpos',1)
                setPosition(ROIhandle,pos)
                rmappdata(0,'dontupdateROIpos')
            catch err
                
                % Create new if above failed
                ROIhandle = createNewROI(); % x y width height (-0.5 because each pixel goes from x-0.5 to x+0.5)
            end
            
        else
            % Create new
            ROIhandle = createNewROI(); % x y width height (-0.5 because each pixel goes from x-0.5 to x+0.5)
        end
        
        function ROIhandle = createNewROI()
            % Make new imrect
            ROIhandle = imrect(mainhandles.rawimage,pos); % x y width height (-0.5 because each pixel goes from x-0.5 to x+0.5)
            
            % Set position contraint to image axes
            setPositionConstraintFcn(ROIhandle,constrainFcn);
            
            % Don't allow it to be interrupted (by itself)
            set(ROIhandle,'Interruptible', 'off')
            
            % Set color
            setColor(ROIhandle,col)
            
            % Set callback
            addNewPositionCallback(ROIhandle,updateFcn);
        end
    end

end