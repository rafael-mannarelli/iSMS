function mainhandles = updateROIimage(mainhandles,saveROImoviesChoice,updatepairsChoice,updatecontrastChoice)
% Updates the ROI image in the sms main window and sends the ROI movies to
% the handles structure by running saveROImovies(handles)
%
%     Input:
%      mainhandles         - handles structure of the main window  (sms)
%      saveROImoviesChoice - binary parameters determining whether to save
%                            ROI movies
%      updatepairs         - 0/1 whether to update FRET pairs
%      updatecontrastChoice - 0/1 whether to update contrast sliders
%
%     Output:
%      mainhandles  - handles structure of the main window
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

if nargin<2
    saveROImoviesChoice = 1;
end
if nargin<3
    updatepairsChoice = 1;
end
if nargin<4
    updatecontrastChoice = 1;
end

% If no data is loaded, return
if isempty(mainhandles.data)
    cla(mainhandles.ROIimage)
    return
end

file = get(mainhandles.FilesListbox,'Value');

%% Prepare image

% Get color images
[redImage,greenImage] = getROIimages(mainhandles);
if isempty(redImage) && isempty(greenImage)
    return
end

% Rotate for view
redImage = redImage';
greenImage = greenImage';

% Adjust contrast of each color channel
if ~isempty(redImage)
    redImage = adjustImgContrast(redImage, mainhandles.data(file).redROIcontrast, mainhandles.data(file).contrastLims);
end
if ~isempty(greenImage)
    greenImage = adjustImgContrast(greenImage, mainhandles.data(file).greenROIcontrast, mainhandles.data(file).contrastLims);
end

% Make blank channels
if isempty(redImage)
    redImage = zeros(size(greenImage));
end
if isempty(greenImage)
    greenImage = zeros(size(redImage));
end

% Stack RGB color channels
if mainhandles.settings.view.colorblind
    overlay = cat(3,...
        redImage,... % Red channel
        redImage,... % Green channel
        greenImage... % Blue channel
        );
else
    overlay = cat(3,...
        redImage,... % Red channel
        greenImage,... % Green channel
        zeros(size(redImage))... % Blue channel
        );
end

% sqroot and normalize intensity
if mainhandles.settings.view.ROIsqrt
    overlay = sqrt(overlay);
    overlay = overlay./max(overlay(:));
end

%% Plot overlayed ROI image

if isempty(mainhandles.ROIimageHandle) ...
        || ~ishandle(mainhandles.ROIimageHandle) ...
        || ~isequal(size(overlay),size(get(mainhandles.ROIimageHandle,'CData')))
    
    % Plot
    hold(mainhandles.ROIimage,'off')
    mainhandles.ROIimageHandle = image(overlay, 'Parent',mainhandles.ROIimage);
    axis(mainhandles.ROIimage,'image')
    set(mainhandles.ROIimage,'YDir','normal')
    
    % Axis label
    if strcmp(get(mainhandles.ROIimage,'xticklabel'),'')
        set(mainhandles.ROIimage,'xticklabel','auto','yticklabel','auto')
    end
    
    % Color of axes
    imgBackColor = get(mainhandles.uipanelROIimage,'BackgroundColor');
    if isequal(imgBackColor,[0 0 0])
        set(mainhandles.ROIimage,'XColor','white', 'YColor','white')
    else
        set(mainhandles.ROIimage,'XColor','black', 'YColor','black')
    end
    
else
    
    % This justs updates the image cdata without resetting axes (faster)
    set(mainhandles.ROIimageHandle,'CData',overlay);
    
    % VERSION DEPENDENT SYNTAX
    if mainhandles.matver>8.3
        set(mainhandles.ROIimage,'xlim',[1 size(overlay,2)],'ylim',[1 size(overlay,1)])
    end
end

%% After

% This is put here for convenience, because updateROIimage is run everytime
% the ROI is changed. The update takes some delay time, so its only
% performed when the data analysis windows are open and there are active
% FRETpairs. saveROImovies will be run also when the analysis windows are
% opened

% Update handles
updatemainhandles(mainhandles)

if ((strcmp(get(mainhandles.Toolbar_FRETpairwindow,'state'),'on')) ...
        || (strcmp(get(mainhandles.Toolbar_histogramwindow,'state'),'on'))) ...
        && (~isempty(mainhandles.data(file).FRETpairs))
    if saveROImoviesChoice
        mainhandles = saveROImovies(mainhandles); % Saves the ROI movies to the handles structure
    end
end

% If there are FRET pairs in selected movie, check if any are outside ROI
if updatepairsChoice && ~isempty(mainhandles.data(file).FRETpairs)
    mainhandles = updateFRETpairs(mainhandles,file);
end

% Update contrast sliders
if updatecontrastChoice
    mainhandles = updatecontrastSliders(mainhandles,1,0,0,1,1);
end
