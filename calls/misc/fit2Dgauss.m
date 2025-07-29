function pars = fit2Dgauss(profilewindowHandles, image, roi, spot) 
% Fits a 2D gauss image to the roi-region of image, and returns pars
% corresponding to image
% 
%     Input:
%      profilewindowHandles  - handles structure of the profile window
%      image                 - image to fit
%      roi                   - ROI region
%      spot                  - 1 if green profile. 2 if red profile
%      
%     Output:
%      pars                  - Fitted Gaussians parameters
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

% Turn on waitbar
hWaitbar = mywaitbar(1,'Fitting Gauss. Please wait...','name','iSMS');
setFigOnTop % Sets the waitbar so that it is always in front

% Fit settings
MaxFunEvals = round(profilewindowHandles.settings.fit.MaxFunEvals);
MaxIter = round(profilewindowHandles.settings.fit.MaxIter);
TolFun = profilewindowHandles.settings.fit.TolFun;
TolX = profilewindowHandles.settings.fit.TolX;
options = optimset('Display','off',...
    'MaxFunEvals',MaxFunEvals,...
    'MaxIter',MaxIter,...
    'TolFun',TolFun,...
    'TolX',TolX); % Don't display messages about iterations

% If fitting to entire side of global image, make new roi parameters
if strcmpi(profilewindowHandles.settings.fit.image,'global') 
    if (spot==1 && strcmpi(profilewindowHandles.settings.sides.green,'left')) || (spot==2 && strcmpi(profilewindowHandles.settings.sides.green,'right'))
        roi = [1 1 floor(size(image,1)/2) size(image,2)];
    elseif (spot==1 && strcmpi(profilewindowHandles.settings.sides.green,'right')) || (spot==2 && strcmpi(profilewindowHandles.settings.sides.green,'left'))
        roi = [ceil(size(image,1)/2) 1 floor(size(image,1)/2) size(image,2)];
    elseif (spot==1 && strcmpi(profilewindowHandles.settings.sides.green,'bottom')) || (spot==2 && strcmpi(profilewindowHandles.settings.sides.green,'top'))
        roi = [1 1 size(image,1) floor(size(image,2)/2)];
    elseif (spot==1 && strcmpi(profilewindowHandles.settings.sides.green,'top')) || (spot==2 && strcmpi(profilewindowHandles.settings.sides.green,'bottom'))
        roi = [1 ceil(size(image,2)/2) size(image,1) floor(size(image,2)/2)];
    end
end

% Cut ROI from global image
x = roi(1):(roi(1)+roi(3))-1;
y = roi(2):(roi(2)+roi(4))-1;
image = double(image(x,y));

% xy-grid
xy = zeros(size(image,1),size(image,2),2);
[X,Y] = meshgrid(1:size(image,1),1:size(image,2));
xy(:,:,1) = X';
xy(:,:,2) = Y';

%% Fit Gaussian

[x0,y0] = find(image==max(image(:)));
p0 = [max(image(:))-min(image(:)),... % Amplitude
    x0(1),...                         % x0
    size(image,1)/2,...               % x-width
    y0(1),...                         % y0
    size(image,2)/2,...               % y-width
    0];%,...                             % angle
%     min(image(:))];                   % background
lb = [0,... % Lower bounds
    1,...
    0,...
    1,...
    0,...
    -pi/4];%,...
%     0];
ub = [65535,... % Upper bounds
    size(image,1),...
    size(image,1)^2,...
    size(image,2),...
    size(image,2)^2,...
    pi/4];%,...
%     65535 ]; % 65535 is the max of uint16

pars = lsqcurvefit(@D2GaussFunctionRot, p0, xy, image, lb, ub, options); % Fit Gaussian
pars(2) = pars(2)+roi(1)-1; % Shift position so it matches global image
pars(4) = pars(4)+roi(2)-1; % Shift position so it matches global image

% Delete waitbar
try delete(hWaitbar), end
