function [pars, variance] = fit2Ggauss2(image, pars0, a)
% Maximum likelihood fit to a 2D Gaussian with a constant background
%
%   N* 1/(2*pi*s^2) * exp (-( (x-ux).^2+(y-uy).^2 ) / (2*s^2)) + b^2
%
% Input Parameters:
% Required:
%  data -- the image of the isolated probe.
%  pars0 -- The user's initial guess of the parameters to be fit:
%           [ux, uy, s, b, N]
%           ux, uy and s should be specified in nanometers.
%           note: as the fit minimizes only localy it is important for this
%           inital guess to be fairly close to the true value.
%
% Optional:
%  variance -- the variance of the localization based on eq.(5) of Mortensen
%  et al.
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

% Make image grid in nanometers
imageSize = size(image);
[x, y] = meshgrid (0.5:imageSize(2)-.5, .5:imageSize(1)-.5);
x = x*a;
y = y*a;

% The funtion to be minimized is the negative of the log likelihood
% -1 * SOM Eq (49)
datafun = @(params)(sum (sum ((expected (x,y,params,a))))...
                        -sum (sum (image.*log (expected (x,y,params,a)))));

% fminsearch performs the multivariable minimization
options = optimset('MaxFunEvals', 10000, 'MaxIter', 10000, 'TolFun', 1e-5);
[pars,fval,exitflag,output]  = fminsearch(datafun, pars0, options);

% if find_variance
%     b2 = pars(4)^2;
%     N = pars(5);
%     sa = pars(3);
%     F = (@(t)log(t)./(1+(N*a^2*t/(2*pi*sa^2*b2)) ) );
%     integral = quadgk (F, 0,1);
%     variance = sa^2/N*(1+integral)^-1;
% end
% 
% if plot_on
%     figure (10)
%     subplot (1,2,1)
%     mesh (image)
%     subplot (1,2,2)
%     mesh (expected (x,y,pars,a))
%     figure (11)
%     imagesc (image)
%     hold on
%     plot (pars (1)/a+.5, pars (2)/a+.5, '*g')
% end


end

function p = twoDGauss (x,y,ux,uy,s)
% 2D Gaussian. (SOM Eq. 3)
p = 1/(2*pi*s^2) * exp (-( (x-ux).^2+(y-uy).^2 ) / (2*s^2));

end

function E = expected (x,y,params,a)
% The expected counts per pixel. (SOM Eq. 12)
E = params(5)*a^2*twoDGauss(x,y,params(1),params(2),params(3)) + params(4)^2;
end
