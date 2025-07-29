function gauss = make2Dgauss(imsize, pars) 
% Returns a 2D gauss image of size imsize with parameters specified by pars
%
%     Input:
%      imsize   - 1x2 vector specifying the size of the image
%      pars     - Gaussian parameters
%
%     Output:
%      gauss    - image
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

xy = zeros(imsize(1),imsize(2),2); % 
[X,Y] = meshgrid(1:imsize(2),1:imsize(1)); % Make grid
xy(:,:,1) = X';
xy(:,:,2) = Y';
gauss = D2GaussFunctionRot(pars,xy);
