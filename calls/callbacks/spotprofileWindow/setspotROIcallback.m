function spHandles = setspotROIcallback(spHandles)
% Callback for setting the spot profile ROI in the spot profile window
%
%   Input:
%    spHandles   - spot profile window handles structure
%
%   Output:
%    spHandles   - ..
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

%% Get data

[spHandles, img, ROI, spotROI, spottype, spotchoice] = selectedSpot(spHandles);
if isempty(img)
    mymsgbox('First import data.')
    return
end

%% Create figure

fh = figure;
updatelogo(fh)
set(fh,'name','Set ROI','numbertitle','off')
try h_im = imagesc(img'.^0.1);
catch err
    h_im = imagesc(img');
end
axis image
axis xy

% Title
if spottype==1
    str = 'Select green spot ROI, double-click to finish: ';
    roicol = 'green';
else
    str = 'Select red spot ROI, double-click to finish: ';
    roicol = 'red';
end
title(str)

%% Create ROI tool

h = imrect(gca,spotROI);
setColor(h,roicol)
fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
setPositionConstraintFcn(h,fcn); 

% Get positions after double click
pos = wait(h);
try delete(fh), end
if isempty(pos)
    return
end

%% Update

if spottype==1
    spHandles.green(spotchoice).spotROI = pos;
else
    spHandles.red(spotchoice).spotROI = pos;
end

guidata(spHandles.figure1,spHandles)
updateimages(spHandles)
% BW = createMask(e,h_im);
