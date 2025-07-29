function [gamma variance] = calculateGammaVariance(mainhandles,A1,A2,D1,D2)
% Calculate gamma factor from intensity intervals
%
%    Input:
%     mainhandles  - handles structure of the main window
%     A1           - A intensity trace prior bleaching
%     A2           - A intensity trace post bleaching
%     D1           - ..
%     D2           - ..
%
%    Output:
%     gamma        - gamma factor value
%     variance     - variance on gamma value
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

%% Get intensities

if mainhandles.settings.corrections.medianI
    % Variance
    varA1 = (pi/2)*var(A1);
    varA2 = (pi/2)*var(A2);
    varD1 = (pi/2)*var(D1);
    varD2 = (pi/2)*var(D2);
    
    % Estimator
    A1 = median(A1);
    A2 = median(A2);
    D1 = median(D1);
    D2 = median(D2);
    
else
    % Variance
    varA1 = var(A1);
    varA2 = var(A2);
    varD1 = var(D1);
    varD2 = var(D2);
    
    % Estimator
    A1 = mean(A1);
    A2 = mean(A2);
    D1 = mean(D1);
    D2 = mean(D2);
    
end

%% Gamma factor

gamma = (A1-A2)/(D2-D1);

%% Variance (approximated by delta method)

variance = ((D1-D2)^2*(varA1+varA2) + (A1-A2)^2*(varD1+varD2)) / (D1-D2)^4;
