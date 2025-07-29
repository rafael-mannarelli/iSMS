function updateimages(spHandles) 
% Updates spot profile images in the spot profile window
%
%   Input:
%    spHandles  - handles structure of the spot profile window
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

cla(spHandles.rawimage)
cla(spHandles.ROIimage)

% Check data
if isempty(spHandles.red) && isempty(spHandles.green)
    return
elseif isempty(spHandles.red)
    set(spHandles.greenRadiobutton,'Value',1)
elseif isempty(spHandles.green)
    set(spHandles.redRadiobutton,'Value',1)
end

% Selected data
[spHandles, imageData, roi, spotROI, spottype, spotchoice] = selectedSpot(spHandles);
if isempty(imageData)
    return
end

%% Update raw image

% Plot raw image
% axes(handles.rawimage) % make rawimage current axis
try imagesc(imageData'.^0.1,'Parent',spHandles.rawimage);
catch err
    imagesc(imageData','Parent',spHandles.rawimage);
end

% Plot ROI rectangles
if spottype==1
    rcol = 'green';
else
    rcol = 'red';
end

hold on
rectangle('Parent',spHandles.rawimage,...
    'Position',roi,...
    'Edgecolor','white',...
    'LineWidth',2,...
    'LineStyle', '-')
rectangle('Parent',spHandles.rawimage,...
    'Position',spotROI,...
    'Edgecolor',rcol,...
    'LineWidth',2,...
    'LineStyle', '-.')
hold off

% Set axes properties
caxis(spHandles.rawimage,'auto')
axis(spHandles.rawimage,'image')
set(spHandles.rawimage,'YDir','normal')
xlabel(spHandles.rawimage,'x /pixel')
ylabel(spHandles.rawimage,'y /pixel')

%% Update ROI image

% Cut D and A ROIs from avgimage
x = roi(1):(roi(1)+roi(3))-1;
y = roi(2):(roi(2)+roi(4))-1;
ROIimage = single(imageData(x , y));

% Set contrast
contrast = 1-get(spHandles.contrastSlider,'Value');
ROIimage(ROIimage(:)-min(ROIimage(:))>(max(ROIimage(:))-min(ROIimage(:)))*contrast) = max(ROIimage(:))*contrast;

% Plot ROI image
% axes(handles.ROIimage) % make rawimage current axis
try imagesc(ROIimage'.^0.1,'Parent',spHandles.ROIimage);
catch err
    imagesc(ROIimage','Parent',spHandles.ROIimage);
end

% Set axes properties
caxis(spHandles.ROIimage,'auto')
axis(spHandles.ROIimage,'image')
set(spHandles.ROIimage,'YDir','normal')
xlabel(spHandles.ROIimage,'x /pixel')
ylabel(spHandles.ROIimage,'y /pixel')
