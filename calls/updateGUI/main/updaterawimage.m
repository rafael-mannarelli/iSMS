function mainhandles = updaterawimage(mainhandles, logchoice, updatecontrastChoice)
% Updates the raw global image in the sms main window
%
%    Input:
%     mainhandles   - handles structure of the main window
%     logchoice     - 0/1 whether to plot in log-scale. 0 if called from
%                     pixelinspection tool.
%     updatecontrastChoice - 0/1 whether to update contrast sliders
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

% Clear current axes
if isempty(mainhandles.data)
    cla(mainhandles.rawimage)
    return
end

% Default
if nargin<2 || isempty(logchoice)
    logchoice = mainhandles.settings.view.rawlogscale;
end
if nargin<3
    updatecontrastChoice = 1;
end

% Selected
file = get(mainhandles.FilesListbox,'Value');

% Get plotted image
imageData = getrawImage(mainhandles,file);
if isempty(imageData)
    cla(mainhandles.rawimage)
    return
end

%% Plot selected image

% Image and contrast
if logchoice
    
    % Must be floating
    if ~isfloat(imageData)
        imageData = double(imageData);
        mainhandles.data(file).rawcontrast = double(mainhandles.data(file).rawcontrast);
    end
    
    img = real(log10(imageData))';
    clims = real(log10(mainhandles.data(file).rawcontrast));
else
    img = imageData';
    clims = mainhandles.data(file).rawcontrast;
end

% Plot
if isempty(mainhandles.rawImageHandle) || ~ishandle(mainhandles.rawImageHandle) ...
        || ~isequal(size(img),size(get(mainhandles.rawImageHandle,'CData')))
    
    % Plot
    mainhandles.rawImageHandle = imagesc(img, 'Parent',mainhandles.rawimage);
    set(mainhandles.rawimage,'CLim',clims)
    
%     % Set colormap (not necessary)
%     if strcmpi(mainhandles.settings.view.rawcolormap,'gray')
%         colmap = gray(256);
%     else
%         colmap = jet(256);
%     end
%     colormap(mainhandles.rawimage,colmap)
    
    % Set axis properties
    axis(mainhandles.rawimage,'image')
    set(mainhandles.rawimage,'YDir','normal')
    
    % Axis label
    if strcmp(get(mainhandles.rawimage,'xticklabel'),'')
        set(mainhandles.rawimage,'xticklabel','auto','yticklabel','auto');
    end
    
    % Color of axes
    imgBackColor = get(mainhandles.uipanelRawimage,'BackgroundColor');
    if isequal(imgBackColor,[0 0 0])
        set(mainhandles.rawimage,'XColor','white', 'YColor','white');
    else
        set(mainhandles.rawimage,'XColor','black', 'YColor','black');
    end
    
    % Update handles
    updatemainhandles(mainhandles)
    
else
    
    % Faster update
    set(mainhandles.rawImageHandle,'CData',img);
    set(mainhandles.rawimage,'CLim',clims)

end

%% Update contrast sliders

if updatecontrastChoice
    mainhandles = updatecontrastSliders(mainhandles,1,0,1,0,0);
end

% Update context menu
% updateImageContextMenu(mainhandles,mainhandles.rawimage)
