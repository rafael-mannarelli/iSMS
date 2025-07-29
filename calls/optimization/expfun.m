function [res,sim] = expfun(pars,data)
% Eponential function used for fitting FRET state dynamics data
%
%     Input:
%      pars   - parameters of the model
%      data   - nx2 data array
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

% Parameters
I0 = pars(1);
I1 = pars(2);

% Data
x = data(:,1);
meas = data(:,2);

% Model
sim = [];
if length(pars)==3 % Single exponential
    k = pars(3);
    sim = I0*exp(-k.*x)+I1;
elseif length(pars)==5 % Double exponential
    k1 = pars(3);
    k2 = pars(4);
    a = pars(5);
    sim = I0*(a*exp(-k1.*x)+(1-a)*exp(-k2.*x));
end

% Residual between model and measured
res = ( sim - meas );