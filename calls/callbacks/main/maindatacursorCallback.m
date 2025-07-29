function CursorText = maindatacursorCallback(obj,event_obj,mainhandle)
% Callback for the data cursor in the main window
%
%     Input:
%      obj         - handle to cursor
%      event_obj   - eventdata
%      mainhandle  - handle to the main window
%
%     Output:
%      CursorText  - cursor text

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
CursorText = '';

%% Get cursor info

try
    % Get mainhandles structure
    if isempty(mainhandle) || ~ishandle(mainhandle)
        mainhandle = getappdata(0,'mainhandle');
    end
    mainhandles = guidata(mainhandle);
    
    mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar
    if (isempty(mainhandles.data))
        return
    end
    file = get(mainhandles.FilesListbox,'Value');
    
    % Get data cursor position
    pos = get(event_obj,'Position');
    x = round(pos(1));
    y = round(pos(2));
    
    % Start output message
    CursorText = {['x: ',num2str(x,4) ...
        ';  y: ',num2str(y,4)]};
    
    if size(get(get(event_obj,'Target'),'CData'),3)==3 || size(get(get(event_obj,'Target'),'CData'),1)==1 % If data cursor is in ROI image, the ==1 is for peak selection
        % Get plotted image
        imagedata = getimageData(mainhandles,file);
        
        % ROI data ranges
        [mainhandles, Droi, Aroi] = getROI(mainhandles,file);
        
        donx = Droi(1):(Droi(1)+Droi(3))-1;
        dony = Droi(2):(Droi(2)+Droi(4))-1;
        accx = Aroi(1):(Aroi(1)+Aroi(3))-1;
        accy = Aroi(2):(Aroi(2)+Aroi(4))-1;
        
        % Cut D ROIs from avgimage
        if size(imagedata,3) == 1
            DROIimage     = imagedata(donx , dony);
            AROIimage     = imagedata(accx , accy);
        elseif size(imagedata,3) == 2
            DROIimage     = imagedata(donx , dony, 1);
            AROIimage     = imagedata(accx , accy, 2);
        end
        
        % Pixel values
        Dintensity = DROIimage(x,y);
        Aintensity = AROIimage(x,y);
        
        % Continue output message
        CursorText{end+1} = sprintf('Green intensity: %.1f', Dintensity);
        CursorText{end+1} = sprintf('Red intensity: %.1f', Aintensity);
        
    else  % If selection is made in the global image
        CursorText{end+1} = sprintf('Intensity: %.1f', mainhandles.data(file).avgimage(x,y));
    end
    
catch err
    err.message
end
