function mainhandles = updateframesliderHandle(mainhandles)
% Updates/creates the avg.image slider ROI handle above the ROI image
%
%     Input:
%      mainhandles  - handles structure of the main window
%
%     Output:
%      mainhandles  - ..

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

% Always update frame info textbox
updatemainframesliderTextbox(mainhandles,1)
updatemainframesliderTextbox(mainhandles,2)

% Return if sliders are not active
if ~mainhandles.settings.view.framesliders
    cla(mainhandles.rawframesliderAxes)
    cla(mainhandles.ROIframesliderAxes)
    return
end

% Check if there are too many handles in the slider, and delete them all
mainhandles.ROIframesliderHandle = deleteprevHandles(mainhandles,mainhandles.ROIframesliderAxes,mainhandles.ROIframesliderHandle);
mainhandles.rawframesliderHandle = deleteprevHandles(mainhandles,mainhandles.rawframesliderAxes,mainhandles.rawframesliderHandle);

%% Delete if there is no data or raw movie is deleted

file = get(mainhandles.FilesListbox,'Value');
if isempty(mainhandles.data) || isempty(mainhandles.data(file).imageData) ...
        || get(mainhandles.FramesListbox,'Value')~=1
    
    warning off
    mainhandles.ROIframesliderHandle = deleteSlider(mainhandles.ROIframesliderHandle);
    mainhandles.rawframesliderHandle = deleteSlider(mainhandles.rawframesliderHandle);
    updatemainhandles(mainhandles)
    warning on

    return
end

%% Position ROIs

mainhandles.ROIframesliderHandle = positionSlider(1);
mainhandles.rawframesliderHandle = positionSlider(2);

%% Update

updatemainhandles(mainhandles) % Update handles structure

%% Nested

    function framesliderHandle = positionSlider(choice)
        
        % Get handles
        if choice==1
            framesliderHandle = mainhandles.ROIframesliderHandle;
            ax = mainhandles.ROIframesliderAxes;
            frames = mainhandles.data(file).avgimageFrames;
            sliderFcn = @(p) updateframesliderROIImage(p);
        else
            % This is a fix for version compatibility
            if isempty(mainhandles.data(file).avgimageFramesRaw)
                mainhandles.data(file).avgimageFramesRaw = mainhandles.data(file).avgimageFrames;
                updatemainhandles(mainhandles)
            end
            
            framesliderHandle = mainhandles.rawframesliderHandle;
            ax = mainhandles.rawframesliderAxes;
            frames = mainhandles.data(file).avgimageFramesRaw;
            sliderFcn = @(p) updateframesliderRawImage(p);
        end
        
        % Position and color
        pos = [frames(1)-1 -5 frames(end)-frames(1)+1 15]; % x y width height (-1 because the box is surrounding the ROI area)
        backgrColor = get(mainhandles.uipanelROItop, 'backgroundColor');
        
        % ax ranges
        xrange = [1 size(mainhandles.data(file).imageData,3)];
        yrange = [-5 15];
        
        if isempty(framesliderHandle)            
            % Make new
            
            framesliderHandle = newsliderHandle();
            
        else
            % Update existing
            
            try
                % Set axes limits
                try xlim(ax,xrange), end
                ylim(ax,[0 1])
                
                % Set new slider position
                setappdata(0,'dontupdate',1) % Tells sliderFcn not to run
                setPosition(framesliderHandle,pos)
                rmappdata(0,'dontupdate')
                
                % Make constraint in imrect position:
                fcn = makeConstrainToRectFcn('imrect',xrange,yrange);
                setPositionConstraintFcn(framesliderHandle,fcn);
                
            catch err
                
                % Make new
                framesliderHandle = newsliderHandle();
            end
        end
        
        function framesliderHandle = newsliderHandle()
            % Delete previous
            try delete(framesliderHandle), end
            
            % Make roi's and define position callback
            framesliderHandle = imrect(ax,pos); % Create ROI handle
            set(framesliderHandle,...
                'Interruptible', 'off', ...
                'UserData',choice)
            setColor(framesliderHandle, backgrColor)
            addNewPositionCallback(framesliderHandle,sliderFcn);
            
            % Make constraint in imrect position:
            try xlim(ax,xrange), end
            ylim(ax,[0 1])
            fcn = makeConstrainToRectFcn('imrect',xrange,yrange);
            setPositionConstraintFcn(framesliderHandle,fcn);
        end
    end

    function sliderHandle = deleteprevHandles(mainhandles,ax,sliderHandle)
        prevHandles = get(ax,'children');
        if length(prevHandles)>2
            for i = 1:length(prevHandles)
                try delete(prevHandles(i)), end
            end
            sliderHandle = [];
        end
    end

    function sliderHandle = deleteSlider(sliderHandle)        
        try
            delete(sliderHandle)
        end
        sliderHandle = [];
    end
end
