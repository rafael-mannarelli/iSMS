function mainhandles = spotCorrect(mainhandles,selectedPairs)
% Corrects traces for laser spot profile intensities
%
%   Input:
%    mainhandles    - handles structure of the main window
%    selectedPairs  - [file pair;...
%
%   Output:
%    mainhandles    - ..
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

% Only correct if this is the setting
if ~mainhandles.settings.spot.choice
    return
end

% Make sure global peak coordinates are up to date
mainhandles = updatepeakglobal(mainhandles,'FRET');

%% Correct

for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);

    % Traces
    DDtrace = mainhandles.data(file).FRETpairs(pair).DDtrace; % D_emission D_excitation trace
    ADtraceCorr = mainhandles.data(file).FRETpairs(pair).ADtraceCorr; % A_emission D_excitation trace
    AAtrace = mainhandles.data(file).FRETpairs(pair).AAtrace; % A_emission A_excitation trace
    
    % Correction factors
    gamma = getGamma(mainhandles, [file pair]);
    
    % Spot images
    Gspot = double(mainhandles.data(file).GspotProfile); % Normalized image of the green laser spot profile of this movie
    Rspot = double(mainhandles.data(file).RspotProfile); % Normalized image of the red laser spot profile of this movie
    
    % Molecule coordinates
    DxyGlobal = round(mainhandles.data(file).FRETpairs(pair).DxyGlobal);
    AxyGlobal = round(mainhandles.data(file).FRETpairs(pair).AxyGlobal);
    
    % Green and red intensities
    G = Gspot(DxyGlobal(1),DxyGlobal(2));
    R = Rspot(AxyGlobal(1),AxyGlobal(2));
    
    % Ratio
    if G == 0 || R == 0
        GR = 1;
    else
        GR = G/R;
    end
    
    % Corrected trace
    mainhandles.data(file).FRETpairs(pair).StraceCorr = (gamma*DDtrace+ADtraceCorr)./(gamma*DDtrace+ADtraceCorr+GR*AAtrace); % Corrected Stoichiometry factor
    
%     pairinfo = [file pair; DxyGlobal; AxyGlobal; G R; GR GR]
end

%% Update handles structure

updatemainhandles(mainhandles)
