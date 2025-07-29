function updateAAintROI(p) 
% Callback when changing the size or position of the donor integration area
% ROI 
%
%    Input:
%     p    - ROI position
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

 % Get handles structure of the main window
mainhandles = guidata(getappdata(0,'mainhandle'));
FRETpairwindowHandles = guidata(mainhandles.FRETpairwindowHandle); % Handles of the FRETpairwindow containing information on integration ROIs
if isempty(mainhandles.data) || isempty(FRETpairwindowHandles.AAintROIhandle)
    try delete(FRETpairwindowHandles.AAintROIhandle),  end
    return
end

% Set the position of the AD-ROI to be equal to this AA-ROI
setPosition(FRETpairwindowHandles.AintROIhandle,p) % [x y width height]

