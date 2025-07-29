function [pars,trace] = fit2Dgauss1(image, startguess, xdata)
% Fits a 2D Gauss
%
%     Input:
%      image      - image data
%      startguess - start parameters
%      xdata      - x vector
%
%     Output:
%      pars       - fitted parameters
%      trace      - not used
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

% Optimize parameters: par = [Amplitude, x0, Xwidth, y0, Ywidth, angle, background]
% DD
pars = startguess(2:6);
p0 = startguess([1 7]);
lb = [0 0];
ub = [65535 65535];
% options = optimset('MaxFunEvals', 10000, 'MaxIter', 10000, 'TolFun', 1e-5);
pars = lsqcurvefit(@D2GaussFunctionRot2, p0, xdata, image, lb, ub, [],pars)

% Store fits in handles structure
pars = [pars(1) startguess(2:6) pars(2)];


