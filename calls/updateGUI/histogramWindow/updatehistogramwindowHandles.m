function updatehistogramwindowHandles(histogramwindowHandles) 
% Updates handles structure of the histogramwindow GUI and sends it to
% appdata
%
%     Input:
%      histogramwindowHandles  - handles structure of the histogramwindow
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

guidata(histogramwindowHandles.figure1,histogramwindowHandles)
setappdata(0,'histogramwindowHandles',histogramwindowHandles)
setappdata(0,'histogramwindowHandle',histogramwindowHandles.figure1)