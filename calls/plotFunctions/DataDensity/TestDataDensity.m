%
%
%
%  Test the data density plot
%
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

x = randn(2048, 1);
y = randn(2048, 1);
x(1:512) = x(1:512) + 2.75;
x(1537:2048) = x(1537:2048) + 2.75;
y(1025:2048) = y(1025:2048) + 2.75;

% On scatter plot you probably can't see the data density
scatter(x, y);
% On data density plot the structure should be visible
DataDensityPlot(x, y, 32);
