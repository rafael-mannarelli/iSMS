function [mainhandles, Droi, Aroi] = getROI(mainhandles,file,imageData,checkROI)
% Returns the G and R ROIs: [x0 y0 width height]. Corrects ROI positions if
% the exceed size of imagedata
%
%    Input:
%     mainhandles    - handles structure of the main window
%     filechoice     - file to analyse. Default: selected
%     imagedata      - image to extract roi from. Default: plotted raw
%     checkROI       - 0/1 whether to check ROI size and position
%
%    Output:
%     mainhanles     - ..
%     Droi           - Donor ROI. [x0 y0 width height]
%     Aroi           - Acceptor ROI. [x0 y0 width height]
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
if nargin<2 || isempty(file)
    file = get(mainhandles.FilesListbox,'Value');
end
if nargin<3 || isempty(imageData)
    imageData = getimageData(mainhandles,file);
end
if nargin<4 || isempty(checkROI)
    checkROI = 1;
end

% Get ROI from handles structure
Droi = single( round(mainhandles.data(file).Droi) ); %  [x y width height]
Aroi = single( round(mainhandles.data(file).Aroi) ); %  [x y width height]
if (Droi(3)==0) || (Droi(4)==0) % If ROI has been squeezed to zero
    return
end

% Return if not check ROI
if ~checkROI
    return
end

%% Check if one of the ROI is positioned off the image by accident

% Left and bottom of ROIs
if Droi(1)<1
    Droi(1) = 1; 
end
if Droi(2)<1
    Droi(2) = 1;
end
if Aroi(1)<1
    Aroi(1) = 1;
end
if Aroi(2)<1
    Aroi(2) = 1;
end

% Right and top of ROIs
if Droi(1)+Droi(3)-1 > size(imageData,1)
    d = (Droi(1)+Droi(3)-1)-size(imageData,1);
    Droi(3) = Droi(3)-d;    
end
if Droi(2)+Droi(4)-1 > size(imageData,2)
    d = (Droi(2)+Droi(4)-1)-size(imageData,2);
    Droi(4) = Droi(4)-d;    
end
if Aroi(1)+Aroi(3)-1 > size(imageData,1)
    d = (Aroi(1)+Aroi(3)-1)-size(imageData,1);
    Aroi(3) = Aroi(3)-d;    
end
if Aroi(2)+Aroi(4)-1 > size(imageData,2)
    d = (Aroi(2)+Aroi(4)-1)-size(imageData,2);
    Aroi(4) = Aroi(4)-d;    
end

% If D and A are not equally sized, set them to the smalles of the two
if ~isequal(Droi(3:4),Aroi(3:4))
    
    Droi(3) = min([Droi(3) Aroi(3)]);
    Aroi(3) = min([Droi(3) Aroi(3)]);
    Droi(4) = min([Droi(4) Aroi(4)]);
    Aroi(4) = min([Droi(4) Aroi(4)]);
end

% Update ROI coordinates
mainhandles.data(file).Droi = Droi;
mainhandles.data(file).Aroi = Aroi;
updatemainhandles(mainhandles)
