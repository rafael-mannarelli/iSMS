function [gamma, Dleakage, Adirect] = getGamma(mainhandles,selectedPair)
% Returns correction factors for selectedPair
%
%    Input:
%     mainhandles   - handles structure of the main window
%     selectedPair  - [file pair]
%
%    Output:
%     gamma         
%     Dleakage
%     Adirect
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

%% Default

Dleakage = mainhandles.settings.corrections.Dleakage;
Adirect = mainhandles.settings.corrections.Adirect;
gamma = mainhandles.settings.corrections.gamma; % Gamma factor: QY_A/QY_D * n_A/n_D

if isempty(selectedPair)
    return
end

% FRET pair
file = selectedPair(1,1);
pair = selectedPair(1,2);

%% Molecule specific correction factors

if mainhandles.settings.corrections.molspec
    
    % D leakage
    if ~isempty(mainhandles.data(file).FRETpairs(pair).Dleakage)
        Dleakage = mainhandles.data(file).FRETpairs(pair).Dleakage; % Gamma factor: QY_A/QY_D * n_A/n_D
    end
    
    % Direct A excitation
    if ~isempty(mainhandles.data(file).FRETpairs(pair).Adirect)
        Adirect = mainhandles.data(file).FRETpairs(pair).Adirect; % Gamma factor: QY_A/QY_D * n_A/n_D
    end
    
    % Gamma
    if ~isempty(mainhandles.data(file).FRETpairs(pair).gamma)
        gamma = mainhandles.data(file).FRETpairs(pair).gamma; % Gamma factor: QY_A/QY_D * n_A/n_D
    end
end
