function mainhandles = updatecontrastSliders(mainhandles,updateHist,updateImrect,updateRaw,updateROIgreen,updateROIred)
% Updates contrast sliders in main window
%
%    Input:
%     mainhandles   - handles structure of the main window
%     updateHist    - 0/1 whether to update intensity histogram in slider
%     updateImrect  - 0/1 whether to update imrect ROI in slider
%     updateRaw     - 0/1 update raw image
%     updateROIgreen- 0/1 update green ROI slider
%     updateROIred  - 0/1 update red roi slider
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

% Default
if nargin<2
    updateHist = 1;
end
if nargin<3
    updateImrect = 1;
end
if nargin<4
    updateRaw = 1;
end
if nargin<5
    updateROIgreen = 1;
end
if nargin<6
    updateROIred = 1;
end

% Return if contrast sliders are inactive
if ~mainhandles.settings.view.contrastsliders || isempty(mainhandles.data)
    
    % Update textbox
    updatemaincontrastsliderTextbox(mainhandles)
    
    % Clear sliders
    cla(mainhandles.rawcontrastSliderAx)
    cla(mainhandles.greenROIcontrastSliderAx)
    cla(mainhandles.redROIcontrastSliderAx)
    return
end

% File
file = get(mainhandles.FilesListbox,'Value');

% Images
if updateHist && (updateROIgreen || updateROIred)
    [redImage,greenImage] = getROIimages(mainhandles);
end

% Check contrastlimits have been defined
if isempty(mainhandles.data(file).contrastLims)
    
    % Get default contrast value
    [contrastLims rawcontrast] = getContrast(mainhandles,file);
    
    % Update data
    mainhandles.data(file).contrastLims = contrastLims;
    if isempty(mainhandles.data(file).rawcontrast)
        mainhandles.data(file).rawcontrast = rawcontrast;
    end
    if isempty(mainhandles.data(file).redROIcontrast)
        mainhandles.data(file).redROIcontrast = rawcontrast;
    end
    if isempty(mainhandles.data(file).greenROIcontrast)
        mainhandles.data(file).greenROIcontrast = rawcontrast;
    end
    
end

%% Histogram

if updateHist
    % Contrast sliders are plotted on logscale
    
    % Colors
    if mainhandles.settings.view.colorblind
        Dcolor = 'g';%'b';
        Acolor = 'magenta';%'y';
    else
        Dcolor = 'g';
        Acolor = 'r';
    end
    
    % Raw
    if updateRaw
        updatehistslider(getrawImage(mainhandles), mainhandles.data(file).contrastLims, mainhandles.rawcontrastSliderAx,'b','rawcontrastSliderHandle')
    end
    
    % ROI green
    if updateROIgreen
        updatehistslider(greenImage, mainhandles.data(file).contrastLims, mainhandles.greenROIcontrastSliderAx,Dcolor,'greenROIcontrastSliderHandle')
    end
    
    % ROI red
    if updateROIred
        updatehistslider(redImage, mainhandles.data(file).contrastLims, mainhandles.redROIcontrastSliderAx,Acolor,'redROIcontrastSliderHandle')
    end
    
end

%% Create raw contrast slider

if updateImrect
    
    % Raw
    if updateRaw
        
        % Update slider handle
        mainhandles = createSlider(mainhandles, ...
            mainhandles.rawcontrastSliderAx, ...
            'rawcontrastSliderHandle', ...
            real(log10( mainhandles.data(file).rawcontrast )),...
            @(p)mainContrastSliderRawCallback(mainhandles));
    end
    
    % ROI green
    if updateROIgreen
        
        % Update slider handle
        mainhandles = createSlider(mainhandles, ...
            mainhandles.greenROIcontrastSliderAx, ...
            'greenROIcontrastSliderHandle', ...
            real(log10( mainhandles.data(file).greenROIcontrast )),...
            @(p)mainContrastSliderGreenROICallback(mainhandles));
    end
    
    % ROI red
    if updateROIred
        
        % Update slider handle
        mainhandles = createSlider(mainhandles, ...
            mainhandles.redROIcontrastSliderAx, ...
            'redROIcontrastSliderHandle', ...
            real(log10( mainhandles.data(file).redROIcontrast )),...
            @(p)mainContrastSliderRedROICallback(mainhandles));
    end
end

% Update handles
updatemainhandles(mainhandles)

% Update textbox
updatemaincontrastsliderTextbox(mainhandles)

%% Nested

    function updatehistslider(imageData,rawLims,ax,barcolor,hrectField)
        % Updates the intensity histogram in the contrast slider
        
        % Log
        if ~isfloat(imageData)
            imageData = double(imageData);
        end
        imageData(imageData<1) = 1; % Avoid <1 values for log scale
        imageData = real(log10( imageData )); % Log and scale to 0-1 range
        
        % Bin image intensities
        [y,x] = hist(imageData(:),100);
        if min(x(:))<0
            x = x-min(x(:));
        end
        
        % Normalize histogram
        y = y/max(y(:));
        
        % Get previous barplot
        h = findobj(ax,'-property','BarWidth');
        if ~isempty(h)
            
            % Update bar data
            set(h,'xdata',x)
            set(h,'ydata',y)
        else
            
            % Create bar plot
            h = bar(ax,x,y);
            set(h,'edgecolor',barcolor,'facecolor',barcolor) % Color
            uistack(h,'bottom') % Put it in the back of imrect
            set(ax, 'XTick',[],'YTick',[],'Color','white')
            %             updateUIcontextMenus(mainhandles.figure1,ax)
            %             updateContrastsliderUIcontextMenu(mainhandles.figure1, h, hrectField)
            
        end
        
    end

    function mainhandles = createSlider(mainhandles, ax, hrectField, contrast, sliderCallback)
        % Handle to the rectangle slider
        sliderHandle = mainhandles.(hrectField);
        
        % Check if there are too many handles in the slider, and delete them all
        prevHandles = findobj(ax,'type','hggroup','tag','imrect');
        if length(prevHandles)>2
            
            % Delete all handles
            for i = 1:length(prevHandles)
                try delete(prevHandles(i)), end
            end
            mainhandles.(hrectField) = [];
            updatemainhandles(mainhandles)
        end
        
        % Delete if there is no data or raw movie is deleted
        file = get(mainhandles.FilesListbox,'Value');
        if isempty(mainhandles.data)
            %                 || isempty(mainhandles.data(file).imageData) || get(mainhandles.FramesListbox,'Value')~=1 || mainhandles.data(file).spot
            
            warning off
            try
                delete(sliderHandle)
                mainhandles.(hrectField) = [];
                updatemainhandles(mainhandles)
            end
            warning on
            
            return
        end
        
        % Position ROIs
        pos = [contrast(1) -5 diff(contrast) 15];
        if isempty(sliderHandle)
            
            sliderHandle = newsliderHandle();
            
        else
            
            try
                % Set new slider position
                setappdata(0,'dontupdate',1) % Tells sliderCallback not to run
                setPosition(sliderHandle,pos)
                rmappdata(0,'dontupdate')
                
            catch err
                % Make new
                sliderHandle = newsliderHandle();
            end
            
        end
        
        % Set axes limits
        rawLims = real(log10(mainhandles.data(file).contrastLims));
        if ~isequal(get(ax,'xlim'), rawLims)
            xlim(ax, rawLims)
        end
        ylim(ax,[0 1])
        
        % Make constraint in imrect position:
        fcn = makeConstrainToRectFcn('imrect',get(ax,'xlim'),[-5 15]);
        setPositionConstraintFcn(sliderHandle,fcn);
        
        % Update
        mainhandles.(hrectField) = sliderHandle;
        updatemainhandles(mainhandles) % Update handles structure
        updateContrastsliderUIcontextMenu(mainhandles.figure1, ax, hrectField)
        
        function sliderHandle = newsliderHandle()
            % Try delete previous, just to be sure
            try delete(sliderHandle), end
            
            % Create ROI handle
            sliderHandle = imrect(ax,pos);
            
            % Set properties
            set(sliderHandle, 'Interruptible', 'off')
            backgrColor = get(mainhandles.uipanelROItop, 'backgroundColor');
            setColor(sliderHandle, backgrColor)
            
            % Set position callback
            addNewPositionCallback(sliderHandle,sliderCallback);
        end
    end

end
