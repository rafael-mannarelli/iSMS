function [initialguess, lb, ub] = initialGuessGaussion(img)
% Prepares a reasonable initial guess of Gaussian parameters for a molecule
% PSF fit.
%
%    Input arguments:
%     img          - molecule image
%
%    Output arguments:
%     initialguess - [x0 y0 sx sy theta background amplitude]
%     lb           - lower bounds
%     ub           - upper bounds
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

% Get limits from mainhandles structure
mainhandle = getappdata(0,'mainhandle');
if ~isempty(mainhandle) && ishandle(mainhandle)
    mainhandles = guidata(mainhandle);

    posLim = mainhandles.settings.integration.posLim; % mean(size(img))/2; % radius to allow shift from initial fit position
    sigmaLim = mainhandles.settings.integration.sigmaLim; % [minwidth maxwidth]  - fit limits of psf width
    thetaLim = mainhandles.settings.integration.thetaLim; % [mintheta maxtheta]  - fit limits of Gaussian angle. Don't set limits on theta but convert it to range 0->2pi afterwards

else mainhandles = [];
    
    % Parameter limits if not running this function from iSMS
    posLim = 2; % mean(size(img))/2; % radius to allow shift from initial fit position
    sigmaLim = [0 3]; % [minwidth maxwidth]  - fit limits of psf width
    thetaLim = [-inf inf]; % [mintheta maxtheta]  - fit limits of Gaussian angle. Don't set limits on theta but convert it to range 0->2pi afterwards
end

backgroundLim = [0 max(img(:))]; % Min and maximum allowed background
amplitudeLim = [0 max(img(:))*3]; % Min and maximum allowed amplitude

%% Initial guess. Parameters: [x0, y0, sx, sy, theta, backround, amplitude]

x0 = size(img,1)/2+0.5; % Assume center position
y0 = size(img,2)/2+0.5; % Assume center position
sx = widthEstimate(img)/2; % Width estimate
if sx < sigmaLim(1) % Check if estimated width exceeds set contraints
    sx = sigmaLim(1);
elseif sx > sigmaLim(2)
    sx = sigmaLim(2);
end
sy = sx; % Width in y-direction
theta = 0; % Angle
background = min(img(:)); % Offset
amplitude = max(img(:))-background; % Amplitude

% Parameter arrays
initialguess = [x0 y0 sx sy theta background amplitude]; % Start values
lb = [x0-posLim y0-posLim sigmaLim(1) sigmaLim(1) thetaLim(1) backgroundLim(1) amplitudeLim(1)]; % Lower bounds
ub = [x0+posLim y0+posLim sigmaLim(2) sigmaLim(2) thetaLim(2) backgroundLim(2) amplitudeLim(2)]; % Upper bounds

% If constraining FWHM
if ~isempty(mainhandles) 
    try 
        if mainhandles.settings.integration.constrainGaussianFWHM
            lb(3:4) = initialguess(3:4);
            ub(3:4) = initialguess(3:4);
        end
    end
end

end

function widthEst = widthEstimate(img)
% Estimate Gaussian width for initial guess
%
%     img  - Isolated molecule image

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

% And then, estimated width:
widthEst = 0.5*(sx + sy);
end
