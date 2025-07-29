function pars = getGaussianStartGuess(image, xdata)
% Get start guess for Gaussians
%
%     Input:
%      image   - image to guess parameters in
%      xdata   - xdata
%
%     Output:
%      pars    - guessed parameters
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

% Size
imageSize = size(image);

%    [Amplitude, x0, Xwidth, y0, Ywidth, angle, background]
p0 = [max(image(:))-min(image(:)), (imageSize(2)+1)/2, 2, (imageSize(2)+1)/2, 2, 0, min(image(:))]; % Inital guess parameters
lb = [0, .5, 0, .5, 0, -pi/4, 0]; % 65535 is the max of uint16
ub = [65535, imageSize(1), (imageSize(1)/2)^2, imageSize(2), (imageSize(2)/2)^2, pi/4, 65535];

% Optimize
options = optimset('Display','off');
pars = lsqcurvefit(@D2GaussFunctionRot, p0, xdata, image, lb, ub, options);
