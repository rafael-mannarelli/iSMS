function [params, count, grid, imgFit] = MLEwG(img, initialguess, lb, ub, threshold, options)
% Maximum likelihood estimate of 2D Gaussian with a constant background.
%
%    Input arguments:
%     data          - The image of the isolated probe.
%     initialguess  - Initial guess of the parameters to be fit:
%                     [x0, y0, sx, sy, theta, background, amplitude]
%                     note: as the fit minimizes only localy it is important
%                     for this inital guess to be fairly close to the true
%                     value.
%     lb            - Lower parameter bounds
%     ub            - Upper parameter bounds
%     threshold     - 0-1 determining optimization settings (0 is for speed,
%                     1 is for accuracy)
%     options       - options structure for fminsearchbnd
%
%    Output arguments:
%     params  - Fitted parameters
%     count   - Integrated Gaussian intensity
%     grid    - [x y] grid used for imgFit
%     imgFit  - Fitted Gaussian image
%
%    Adapted from Mortensen & Flyvbjerg's MLEwG:
%       Mortensen et al., Nat. Methods (2010), 7, 377
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

% Default
if nargin<6
    MaxFunEvals = round(threshold^3*10000); % Maximum number of function evaluations
    MaxIter = round(threshold^3*10000); % Maximum number of iterations
    TolFun = 10^(-threshold*10); % Function toleration values
    options = optimset('Display','off', 'MaxFunEvals', MaxFunEvals, 'MaxIter', MaxIter, 'TolFun', TolFun); % Fitting options structure
end

% Make X-Y grids
[x,y] = meshgrid(1:size(img,2),1:size(img,1)); % Make grids
grid = [x y]; % Grid used for plotting

% The funtion to be minimized is the negative of the log likelihood
% -1 * SOM. sum(sum()) is for summing arrays
datafun = @(params)(...
    sum(sum( expected(x,y,params) ))...
    -sum(sum( img.*log(expected(x,y,params)) )));

%% Optimize

% Fminsearch performs the multivariable minimization
params = fminsearchbnd(datafun, initialguess, lb, ub, options); % Optimize and return optimized parameters

%% Finalize

% Gaussian eccentricity
eccentricity = sqrt( 1 - (min(params(3),params(4))/max(params(3),params(4)) )^2);

% Integrated Gaussian (analytical)
count = 2*pi*params(3)*params(4)*params(7); % The total count is 2*pi*sx*sy*Amplitude

% Fitted image
imgFit = expected(x,y,params); % Fitted Gaussian image

% Normalize angle
params(5) = mod(params(5),2*pi);% Transform theta onto the interval 0->2*pi

end

function p = twoDGauss(x, y, x0, y0, sx, sy, theta)
% Rotated 2D Gaussian
%
%    x     - x-grid
%    y     - y-grid
%    x0,y0 - Center coordinates
%    sx,sy - Gaussian width (x and y std. dev.)
%    ti    - Angle of rotation

xprime = (x-x0)*cos(theta) - (y-y0)*sin(theta);
yprime = (x-x0)*sin(theta) + (y-y0)*cos(theta);

p = exp( - ((xprime).^2 /(2*sx^2) + (yprime).^2 /(2*sy^2) ));

end

function E = expected(x,y,params)
% The expected counts per pixel. Gaussian*amplitude + background.

% Parameters
x0 = params(1);
y0 = params(2);
sx = params(3);
sy = params(4);
theta = params(5);
background = params(6);
amplitude = params(7);

% Gaussian
E = amplitude*twoDGauss(x, y, x0, y0, sx, sy, theta) + background;

end
