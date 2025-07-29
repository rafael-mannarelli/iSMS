function updateSEframecounter(histogramwindowHandles)
% Updates the frame counter in the histogram window
%
%     Input:
%      histogramwindowHandles    - handle structure of the histogram window
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

%% Get data from SEplot

h = findobj(histogramwindowHandles.SEplot,'type','line');
xSEplot = get(h,'xdata');

if isempty(xSEplot)
    return
elseif size(xSEplot,1)>1 % If there is more than one data-set plotted (e.g. Gaussian mixture)
    xSEplot = [xSEplot{:}];
end

%% Update counter

set(histogramwindowHandles.frameCounter,'String', length(xSEplot))
