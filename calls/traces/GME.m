function [params count grid imgFit] = GME(img, initialguess, lb, ub, threshold, options)
% Gaussian Mask Estimator (GME) of 2D Gaussian with a constant background:
% Performs a least squares fit with constant weights.
%
%    Input arguments:
%     img           - The image of the isolated probe.
%     initialguess  - Initial guess of the parameters to be fit:
%                     [x0, y0, sx, sy, theta, background, amplitude]
%                     note: as the fit minimizes only localy it is important
%                     for this inital guess to be fairly close to the true
%                     value.
%     lb            - Lower parameter bounds
%     ub            - Upper parameter bounds
%     threshold     - 0-1 determining optimization settings (0 is for speed,
%                     1 is for accuracy)
%     options       - options structure returned by optimset
%
%    Output arguments:
%     params  - Fitted parameters
%     count   - Integrated Gaussian intensity
%     grid    - [x y] grid used for imgFit
%     imgFit  - Fitted image
%
%    Adapted with inspiration from Holden, Uphoff & Kapanidis's TwoTone:
%       Holden et al., Biophys. J. (2010), 99, 3102
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

%% Initialze

% Default
if nargin<6
    options = optimset('lsqcurvefit');
    options = optimset(options, 'Jacobian','off', 'Display','off',  'TolX',10^-2, 'TolFun',10^-2, 'MaxPCGIter',1, 'MaxIter',500);
end

% x-y grids
[x,y] = meshgrid(1:size(img,2),1:size(img,1)); % Make grids
grid = [x y]; % x-y grid used for Gaussian image

% Rescale the variables - to make magnitude of amplitude, background and
% width similar (good for fitting speed)
ampScaleFactor = max(img(:))/5;
if ampScaleFactor <= 0
    ampScaleFactor = 1;
end

% Rescale
img = img./ampScaleFactor; % Rescale image
initialguess(6) = initialguess(6)./ampScaleFactor; % Rescale backgound
initialguess(7) = initialguess(7)./ampScaleFactor; % Rescale amplitude

% Check bound constraints
constrPos = 0; % Constrain Gaussian center
constrWidth = 0; % Constrain Gaussian width
constrTheta = 0; % Constrain Gaussian angle
if lb(1)==ub(1) || lb(2)==ub(2)
    constrPos = 1;
    initialguess(1) = lb(1);
    initialguess(2) = lb(2);
end
if lb(3)==ub(3) || lb(4)==ub(4)
    constrWidth = 1;
    initialguess(3) = lb(3);
    initialguess(4) = lb(4);
end
if lb(5)==ub(5)
    constrTheta = 1;
    initialguess(5) = lb(5);
end

% Incoming parameters
x0 = initialguess(1);
y0 = initialguess(2);
sx = initialguess(3);
sy = initialguess(4);
theta = initialguess(5);
background = initialguess(6);
amplitude = initialguess(7);

% Don't optimize theta if Gaussian is constrained to be circular
if constrWidth && sx==sy
    constrTheta = 1;
end

% Optimization settings
MaxIter = round(threshold^3*5000); % Maximum number of iterations
TolFun = 10^(-threshold*5); % Function toleration values
TolX = 10^(-threshold*5); % Parameter value toleration values
% options = optimset('lsqcurvefit');
% options = optimset(options, 'Jacobian','off', 'Display','off',  'TolX',10^-2, 'TolFun',10^-2, 'MaxPCGIter',1, 'MaxIter',500);

% We have to define different fit functions because lsqcurvefit does not
% accept equal lower and upper bounds (damn you lsqcurvefit)
if ~constrPos && ~constrWidth && ~constrTheta % All parameters free
    
    optFunc =  @(x, grid) Gauss2D_free(x, grid); % Function to optimize
    idx = 1:7; % Indices of parameters to optimize
    
elseif constrPos && ~constrWidth && ~constrTheta % Fixed position
    
    optFunc = @(x, grid) Gauss2D_fixedPos(x, grid, x0, y0); % Function to optimize
    idx = 3:7; % Indices of parameters to optimize
    
elseif ~constrPos && constrWidth && ~constrTheta % Fixed width
    
    optFunc = @(x, grid) Gauss2D_fixedWidth(x, grid, sx, sy); % Function to optimize
    idx = [1:2 5:7]; % Indices of parameters to optimize
    
elseif ~constrPos && ~constrWidth && constrTheta % Fixed theta
    
    optFunc = @(x, grid) Gauss2D_fixedTheta(x, grid, theta); % Function to optimize
    idx = [1:4 6:7]; % Indices of parameters to optimize
    
elseif constrPos && constrWidth && ~constrTheta % Fixed position and width
    
    optFunc = @(x, grid) Gauss2D_fixedPosWidth(x, grid, x0, y0, sx, sy); % Function to optimize
    idx = 5:7; % Indices of parameters to optimize
    
elseif constrPos && ~constrWidth && constrTheta % Fixed position and theta
    
    optFunc = @(x, grid) Gauss2D_fixedPosTheta(x, grid, x0, y0, theta); % Function to optimize
    idx = [3:4 6:7]; % Indices of parameters to optimize
    
elseif ~constrPos && constrWidth && constrTheta % Fixed width and theta
    
    optFunc = @(x, grid) Gauss2D_fixedWidthTheta(x, grid, sx, sy, theta); % Function to optimize
    idx = [1:2 6:7]; % Indices of parameters to optimize
    
elseif constrPos && constrWidth && constrTheta % Fixed position, width and theta
    
    optFunc = @(x, grid) Gauss2D_fixedPosWidthTheta(x, grid, x0, y0, sx, sy, theta); % Function to optimize
    idx = 6:7; % Indices of parameters to optimize
    
end

% Initialize all parameters array
params = initialguess;

% Parameters to optimize
initialguess = initialguess(idx);
lb = lb(idx);
ub = ub(idx);

%% Optimize

[paramsFit, res] = lsqcurvefit(... % lsqcurvefit performs the optimization. This requires the Optimization Toolbox
    optFunc, ... % Function to optimize
    initialguess, grid, img,... % p0, xdata, ydata
    lb, ub, options); % params: [x0, y0, sx, sy, theta, background, amplitude]

% Re-insert constrained values
params(idx) = paramsFit;

% Adjust scaled parameters
params(5) = mod(params(5),2*pi);% Transform theta onto the interval 0->2*pi
params(6) = params(6)*ampScaleFactor; % Rescale background
params(7) = params(7)*ampScaleFactor; % Rescale amplitude
if params(7) < 0 % We know that negative amplitude values are patently unphysical so ignore them
    params(7) = 0;
end

%% Finalize

% Final parameters
x0 = params(1);
y0 = params(2);
sx = params(3);
sy = params(4);
theta = params(5);
background = params(6);
amplitude = params(7);

% Chi-square of fit
normChi2 = res/numel(img); % Normalized chi square. numel(img) is number of pixels

% Gaussian eccentricity
eccentricity = sqrt( 1 - (min(sx,sy)/max(sx,sy) )^2);

% Integrated Gaussian (analytical)
count = 2*pi*sx*sy*amplitude; % The total count is 2*pi*sx*sy*Amplitude

% Fitted image
imgFit = Gauss2D(grid, x0, y0, sx, sy, theta, background, amplitude);
end

%% Functions to fit: Rotated, elliptical 2D Gaussian
function imgFit = Gauss2D(grid, x0, y0, sx, sy, theta, background, amplitude) %% Outputs an elliptical, rotated, 2D Gaussian
% Rotated 2D elliptical 2D Gaussian
%
%    Input arguments:
%       grid       - [x y] meshgrids
%       x0,y0      - Center coordinates
%       sx,sy      - Gaussian width (x and y std. dev.)
%       theta      - Angle of rotation
%       background - constant offset
%       amplitude  - amplitude factor
%
%    Output arguments:
%    imgFit - Gaussian image (model function)

% Initialize
[sizey sizex] = size(grid);
sizex = sizex/2; % The grid is sent as [x y]
imgFit = zeros(sizey, sizex); % Pre-allocate imgFit

% X and Y grids
x = grid(:,1:sizex);
y = grid(:,sizex+1:end);

% Transform
xprime = (x-x0)*cos(theta) - (y-y0)*sin(theta);
yprime = (x-x0)*sin(theta) + (y-y0)*cos(theta);

% Make 2D Gaussian
p = exp( - ((xprime).^2/(2*sx^2) + (yprime).^2/(2*sy^2) )); % Gaussian
imgFit = amplitude*p + background; % Add amplitude and offset


%--- Compute the Jacobian---%
% NOTE: This was removed by Søren because it didn't do the trick. If you
% want to use explicit Jacobians for the optimization, set the output
% arguments to [imgFit J]

% initialise everything.
% n = numel(imgFit);
% J = zeros(n,3); % initialise J
% Ga1F = zeros(sizey, sizex);% dF/da(1)
% Ga2F = Ga1F;% dF/da(2)
% Ga3F = Ga1F;% dF/da(3)
% Ga4F = Ga1F;% dF/da(4)
% Ga5F = Ga1F;% dF/da(5)
% Ga6F = Ga1F;% dF/da(6)
% Ga7F = Ga1F;% dF/da(7)
%
% Calculate derivatives
% Ga1F = p;
% Ga2F = amplitude* p .*xprime.^2 .*sx.^-3;% (A * e) * (pow(xprime,2) * pow(sigma_x,-3)); //dF/dsigma_x
% Ga3F = amplitude* p .*yprime.^2 .*sy.^-3;% (A * e) * (pow(yprime,2) * pow(sigma_y,-3)); //dF/dsigma_y
% Ga4F = ones(size(X));
% Ga5F = amplitude* p .*( xprime.*sx.^(-2).*cos(theta) + yprime.*sy.^(-2)*sin(theta) );
% Ga6F = amplitude* p .*( -xprime.*sx.^(-2).*sin(theta) + yprime.*sy.^(-2)*cos(theta) );
% Ga7F = -amplitude* p.*(  (-xprime).*sx.^(-2).*((X-x0)*sin(theta)+ (Y-y0)*cos(theta))  +  (yprime).*sy.^(-2).*((X-x0)*cos(theta)- (Y-y0)*sin(theta)) );
%
% Form the jacobian, see the printed notes on getGaussFit for derivation
% J = [Ga1F(:) Ga2F(:) Ga3F(:) Ga4F(:) Ga5F(:) Ga6F(:) Ga7F(:)];

end

function imgFit = Gauss2D_free(params, grid) %% All parameters free.
%    Input arguments:
%    params - [x0, y0, sx, sy, theta, background, amplitude]
%       x0,y0      - Center coordinates
%       sx,sy      - Gaussian width (x and y std. dev.)
%       theta      - Angle of rotation
%       background - constant offset
%       amplitude  - amplitude factor
%    grid   - [x y] meshgrids
%
%    Output arguments:
%    imgFit - Gaussian image (model function)

% Parameters being optimized
x0 = params(1);
y0 = params(2);
sx = params(3);
sy = params(4);
theta = params(5);
background = params(6);
amplitude = params(7);

% Create Gaussian model corresponding to input parameters
imgFit = Gauss2D(grid, x0, y0, sx, sy, theta, background, amplitude);

end

function imgFit = Gauss2D_fixedPos(params, grid, x0, y0) %% Fixed position.
%    Input arguments:
%    params - [sx, sy, theta, background, amplitude]
%       sx,sy      - Gaussian width (x and y std. dev.)
%       theta      - Angle of rotation
%       background - constant offset
%       amplitude  - amplitude factor
%    grid   - [x y] meshgrids
%    x0,y0  - Center coordinates
%
%    Output arguments:
%    imgFit - Gaussian image (model function)

% Parameters being optimized
sx = params(1);
sy = params(2);
theta = params(3);
background = params(4);
amplitude = params(5);

% Create Gaussian model corresponding to input parameters
imgFit = Gauss2D(grid, x0, y0, sx, sy, theta, background, amplitude);
end

function imgFit = Gauss2D_fixedWidth(params, grid, sx, sy) %% Fixed width.
%    Input arguments:
%    params - [x0, y0, theta, background, amplitude]
%       x0,y0      - Center coordinates
%       theta      - Angle of rotation
%       background - constant offset
%       amplitude  - amplitude factor
%    grid   - [x y] meshgrids
%    sx,sy  - Gaussian width (x and y std. dev.)
%
%    Output arguments:
%    imgFit - Gaussian image (model function)

% Parameters being optimized
x0 = params(1);
y0 = params(2);
theta = params(3);
background = params(4);
amplitude = params(5);

% Create Gaussian model corresponding to input parameters
imgFit = Gauss2D(grid, x0, y0, sx, sy, theta, background, amplitude);
end

function imgFit = Gauss2D_fixedTheta(params, grid, theta) %% Fixed angle of rotation.
%    Input arguments:
%    params - [x0, y0, sx, sy, background, amplitude]
%       x0,y0      - Center coordinates
%       sx,sy      - Gaussian width (x and y std. dev.)
%       background - constant offset
%       amplitude  - amplitude factor
%    grid   - [x y] meshgrids
%    theta  - Angle of rotation
%
%    Output arguments:
%    imgFit - Gaussian image (model function)

% Parameters being optimized
x0 = params(1);
y0 = params(2);
sx = params(3);
sy = params(4);
background = params(5);
amplitude = params(6);

% Create Gaussian image corresponding to input parameters
imgFit = Gauss2D(grid, x0, y0, sx, sy, theta, background, amplitude);
end

function imgFit = Gauss2D_fixedPosWidth(params, grid, x0, y0, sx, sy) %% Fixed position and width.
%    Input arguments:
%    params - [theta, background, amplitude]
%       theta      - Angle of rotation
%       background - constant offset
%       amplitude  - amplitude factor
%    grid   - [x y] meshgrids
%    x0,y0  - Center coordinates
%    sx,sy  - Gaussian width (x and y std. dev.)
%
%    Output arguments:
%    imgFit - Gaussian image (model function)

% Parameters being optimized
theta = params(1);
background = params(2);
amplitude = params(3);

% Create Gaussian model corresponding to input parameters
imgFit = Gauss2D(grid, x0, y0, sx, sy, theta, background, amplitude);
end

function imgFit = Gauss2D_fixedPosTheta(params, grid, x0, y0, theta) %% Fixed position and theta.
%    Input arguments:
%    params - [sx, sy, background, amplitude]
%       sx,sy      - Gaussian width (x and y std. dev.)
%       background - constant offset
%       amplitude  - amplitude factor
%    grid   - [x y] meshgrids
%    x0,y0  - Center coordinates
%    theta  - Angle of rotation
%
%    Output arguments:
%    imgFit - Gaussian image (model function)

% Parameters being optimized
sx = params(1);
sy = params(2);
background = params(3);
amplitude = params(4);

% Create Gaussian model corresponding to input parameters
imgFit = Gauss2D(grid, x0, y0, sx, sy, theta, background, amplitude);
end

function imgFit = Gauss2D_fixedWidthTheta(params, grid, sx, sy, theta) %% Fixed width and angle of rotation.
%    Input arguments:
%    params - [x0, y0, background, amplitude]
%       x0,y0      - Center coordinates
%       background - constant offset
%       amplitude  - amplitude factor
%    grid   - [x y] meshgrids
%    sx,sy  - Gaussian width (x and y std. dev.)
%    theta  - Angle of rotation
%
%    Output arguments:
%    imgFit - Gaussian image (model function)

% Parameters being optimized
x0 = params(1);
y0 = params(2);
background = params(3);
amplitude = params(4);

% Create Gaussian model corresponding to input parameters
imgFit = Gauss2D(grid, x0, y0, sx, sy, theta, background, amplitude);
end

function imgFit = Gauss2D_fixedPosWidthTheta(params, grid, x0, y0, sx, sy, theta) %% Fixed position, width and angle of rotation.
%    Input arguments:
%    params - [background, amplitude]
%       background - constant offset
%       amplitude  - amplitude factor
%    grid   - [x y] meshgrids
%    x0,y0  - Center coordinates
%    sx,sy  - Gaussian width (x and y std. dev.)
%    theta  - Angle of rotation
%
%    Output arguments:
%    imgFit - Gaussian image (model function)

% Parameters being optimized
background = params(1);
amplitude = params(2);

% Create Gaussian model corresponding to input parameters
imgFit = Gauss2D(grid, x0, y0, sx, sy, theta, background, amplitude);
end
