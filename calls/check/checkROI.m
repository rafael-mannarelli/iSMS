function roi = checkROI(mainhandles,file,roi)
% Check that ROI does not exceed image
%
%    Input:
%     mainhandles   - handles structure of the main window
%     file          - movie file
%     roi           - ROI position
%
%    Output:
%     roi           - corrected position
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

W = size(mainhandles.data(file).avgimage,1);
H = size(mainhandles.data(file).avgimage,2);

if r2(1)<0.5
    r2(1) = 0.5;
end

if sum(r2([1 3]))>W+.4
    outside = sum(r2([1 3]))-W-.4; % Number of ROI pixels outside movie in x direction [DROI AROI]
    r2(1) = r2(1)-outside; % Make ROI smaller but keep position
end

if r2(2)<0.5
    r2(2) = 0.5;
end

if sum(r2([2 4]))>H+.4
    outside = sum(r2([2 4]))-H-.4; % Number of ROI pixels outside movie in x direction [DROI AROI]
    r2(2) = r2(2)-outside; % Make ROI smaller but keep position
end
