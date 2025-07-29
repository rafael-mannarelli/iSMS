function widthEst = widthEstimate(img)
% Estimate Gaussian width for initial guess
%
%    Input:
%     img       - Isolated molecule image
%
%    Output:
%     widthEst  - estimated width value
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

[sizey sizex] = size(img);
vx = sum(img); % Sum of x columns
vy = sum(img'); % Sum of y rows

vx = vx.*(vx>0); % Square values
vy = vy.*(vy>0); % Square values

x = [1:sizex]; % x vector
y = [1:sizey]; % y vector

% Do some magic
cx = sum(vx.*x)/sum(vx);
cy = sum(vy.*y)/sum(vy);
sx = sqrt(sum(vx.*(abs(x-cx).^2))/sum(vx));
sy = sqrt(sum(vy.*(abs(y-cy).^2))/sum(vy));

% Estimated width
widthEst = 0.5*(sx + sy);

