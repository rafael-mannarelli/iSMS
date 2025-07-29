function mainhandles = inspectPixelValuesToolCallback(mainhandles,axchoice)
% Callback for the pixel info region tool
%
%   Input:
%    mainhandles   - handles structure of the main window
%    axchoice      - 'ROI' 'raw'
%
%   Output:
%    mainhandles   - ...
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

% Return of no data is loaded
if isempty(mainhandles.data)
    set(mainhandles.mboard,'String','No data loaded')
    return
end

% Turn off other active tools
mainhandles = turnofftoggles(mainhandles,'pixelregion');

% Delete if already open
if ishandle(mainhandles.impixelregionWindowHandle)
    try delete(mainhandles.impixelregionWindowHandle), 
        % Re-plot original raw image
        mainhandles = updaterawimage(mainhandles);
        mainhandles = updateROIhandles(mainhandles);
    end
    return
end

%% Open tool

if strcmpi(axchoice,'ROI')
    mainhandles.impixelregionWindowHandle = impixelregion(mainhandles.ROIimage);
else
    
    % Make sure image is not plotted in logscale
    mainhandles = updaterawimage(mainhandles, 0);

    mainhandles.impixelregionWindowHandle = impixelregion(mainhandles.rawimage);
end
updatelogo(mainhandles.impixelregionWindowHandle)
updatemainhandles(mainhandles)

% Make sure window always is on top
figure(mainhandles.impixelregionWindowHandle)
setFigOnTop([])
