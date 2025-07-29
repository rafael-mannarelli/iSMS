function updateFRETpairwindowHandles(FRETpairwindowHandles) 
% Updates the handles structure of the FRETpairwindow
%
%    Input:
%     FRETpairwindowHandles   - handles structure of the FRETpair window
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

% Update handles structure
guidata(FRETpairwindowHandles.figure1,FRETpairwindowHandles)

% Send handles structure to appdata
setappdata(0,'FRETpairwindowHandles',FRETpairwindowHandles)

