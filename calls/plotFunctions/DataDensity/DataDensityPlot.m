function h = DataDensityPlot( x, y, levels )
%DATADENSITYPLOT Plot the data density 
%   Makes a contour map of data density
%   x, y - data x and y coordinates
%   levels - number of contours to show
%
% By Malcolm Mclean
%
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

    map = dataDensity(x, y, 256, 256);
    map = map - min(min(map));
    map = floor(map ./ max(max(map)) * (levels-1));
%     f = figure();
    
    h = image(map);
    colormap(jet(levels));
    set(gca, 'XTick', [1 256]);
    set(gca, 'XTickLabel', [min(x) max(x)]);
    set(gca, 'YTick', [1 256]);
    set(gca, 'YTickLabel', [min(y) max(y)]);

