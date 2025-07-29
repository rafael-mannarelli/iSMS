function [redImage, greenImage] = getROIimages(mainhandles,file)
% Returns images to be plotted in the main ROI image ax
%
%    Input:
%     mainhandles   - handles structure of the main window
%
%    Output:
%     redImage      - red image data
%     greenImage    - green image data

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

redImage = [];
greenImage = [];

if nargin<2 || isempty(file)
    file = get(mainhandles.FilesListbox,'Value');
end

% Selected image
imageData = getimageData(mainhandles,file);
if isempty(imageData) && get(mainhandles.FramesListbox,'Value')==2
    set(mainhandles.FramesListbox,'Value',1)
    updatemainhandles(mainhandles)
    mainhandles = filesListboxCallback(mainhandles.FilesListbox); % Imitate click in files listbox
    return
end

% Get and check ROI positions
[mainhandles, Droi, Aroi] = getROI(mainhandles,file,imageData);
if (Droi(3)==0) || (Droi(4)==0) 
    % If ROI has been squeezed to zero
    return
end

% D and A data ranges
donx = Droi(1) :(Droi(1)+Droi(3))-1;
dony = Droi(2) :(Droi(2)+Droi(4))-1;
accx = Aroi(1) :(Aroi(1)+Aroi(3))-1;
accy = Aroi(2) :(Aroi(2)+Aroi(4))-1;

%% Overlayed image

if mainhandles.data(file).spot==1 ...
        || (mainhandles.settings.view.ROIgreen && ~mainhandles.settings.view.ROIred)
    % Make green image
    
    % Cut D ROIs from avgimage
    if size(imageData,3) == 1
        greenImage = imageData(donx , dony);
    elseif size(imageData,3) == 2
        greenImage = imageData(donx , dony, 1);
    end
    
elseif mainhandles.data(file).spot==2 ...
        || (mainhandles.settings.view.ROIred && ~mainhandles.settings.view.ROIgreen)
   % Make red image
    
    % Cut A ROIs from avgimage
    if size(imageData,3) == 1
        redImage = imageData(accx , accy);
    elseif size(imageData,3) == 2
        redImage = imageData(accx , accy, 2);
    end
    
else
    % Make red-green image
    
    % Cut D and A ROIs from avgimage
    if size(imageData,3) == 1
        greenImage = imageData(donx , dony);
        redImage = imageData(accx , accy);
    elseif size(imageData,3) == 2
        greenImage = imageData(donx , dony, 1);
        redImage = imageData(accx , accy, 2);
    end
end

end