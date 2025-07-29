function FRETpairwindowHandles = deleteframeSliders(FRETpairwindowHandles)
% Deletes the molecule frame sliders in the FRETpair window
%
%     Input:
%      FRETpairwindowHandles  - handles structure of the FRETpairwindwo
%
%     Output:
%      FRETpairwindowHandles  - ..
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

% Turn off warning about non-existing objects (if they are not activated)
warning off

% Delete objects
try delete(FRETpairwindowHandles.DframeSliderHandle), end
try delete(FRETpairwindowHandles.AframeSliderHandle), end
try delete(FRETpairwindowHandles.AAframeSliderHandle), end

% Remove handles from handles structure
FRETpairwindowHandles.DframeSliderHandle = [];
FRETpairwindowHandles.AframeSliderHandle = [];
FRETpairwindowHandles.AAframeSliderHandle = [];

% Update handles structure
guidata(FRETpairwindowHandles.figure1,FRETpairwindowHandles)

% Turn warnings back on
warning on
