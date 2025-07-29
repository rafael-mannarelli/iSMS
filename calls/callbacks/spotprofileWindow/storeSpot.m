function data = storeSpot(data, name, img, ROI, spotROI,pars, existing, measured)
% Store new spot profile in the spot profile window handles structure
%
%    Input:
%     data      - data structure
%     name      - data name
%     img       - image data
%     ROI       - ROI
%     spotROI   - ROI for spot
%     pars      - parameters
%     existing  - 
%     measured  - 0/1 measured spot
%
%    Output:
%     data      - ..
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

if nargin<1 || isempty(data)
    data = [];
end
if nargin<2 || isempty(name)
    name = [];
end
if nargin<3 || isempty(img)
    img = [];
end
if nargin<4 || isempty(ROI)
    ROI = [];
end
if nargin<5 || isempty(spotROI)
    spotROI = ROI;
end
if nargin<6 || isempty(pars)
    pars = [];
end
if nargin<7 || isempty(existing)
    existing = 0;
end
if nargin<8 || isempty(measured)
    measured = 0;
end

%% Populate

if isempty(data)
    data(1).name = name;
else
    data(end+1).name = name;
end

data(end).image = img;
data(end).raw = img;
data(end).ROI = ROI;
data(end).spotROI = spotROI;
data(end).pars = pars;
data(end).existing = existing;
data(end).measured = measured;
