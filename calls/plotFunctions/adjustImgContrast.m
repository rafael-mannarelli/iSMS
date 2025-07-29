function img = adjustImgContrast(img,contrast,L)
% Adjusts image contrast before plotting
% 
%    Input:
%     img       - imageData
%     contrast  - contrast intensity values
%     L         - lower and upper limits
%
%    Output:
%     img       - ..
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

% Lower and upper image intensities
avgLims = ceil([getmovMin(img) getmovMax(img)]);

% First adjust image to raw intensity interval
out = getContrastIn(avgLims, L);
img = imadjust( mat2gray(img),...
    [0 1],...
    out);

% Then adjust contrast according to slider values
img = imadjust( img,...
    getContrastIn(contrast, L),...
    [0 1]);

end
