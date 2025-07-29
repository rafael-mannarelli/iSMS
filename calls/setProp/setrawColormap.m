function setrawColormap(mainhandles)
% Sets the colormap of the raw image ax in the main window
%
%    Input:
%     mainhandles   - handles structure of the main window
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

% Colormap
if strcmpi(mainhandles.settings.view.rawcolormap,'gray')
    colmap = gray(256);
else
    colmap = jet(256);
end

% Update
colormap(mainhandles.rawimage,colmap)
