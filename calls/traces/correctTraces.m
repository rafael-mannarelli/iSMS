function mainhandles = correctTraces(mainhandle, selectedPairs)
% Calculates AD trace corrected donor-leakage and direct A excitation and
% uses this to calculate corrected FRET and S traces. Also corrects for the
% gamma factor.
%
%     Input:
%      mainhandle    - handle to the main figure window
%      selectedPairs - [file pair;...] to calculate
%
%     Output:
%      mainhandles   - handles structure of the main window
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

% Default input parameters
if nargin<2
    selectedPairs = 'all'; % Calculate all FRETpairs
end

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (~ishandle(mainhandle))
    mainhandles = [];
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
if isempty(mainhandles.data)
    return
end

% If calculating all FRET pairs, make an "all" choice matrix
if (isempty(selectedPairs)) || ((ischar(selectedPairs)) && (strcmpi(selectedPairs,'all')))
    selectedPairs = getPairs(mainhandle, 'All');
end

% If there are no FRET-pairs, return
if isempty(selectedPairs)
    return
end

%% Correct

% Correct traces
for i = 1:size(selectedPairs,1) % Loop over all pairs
    file = selectedPairs(i,1); % Movie file
    pair = selectedPairs(i,2); % FRET-pair
    
    % Correction factors
    [gamma, Dleakage, Adirect] = getGamma(mainhandles, [file pair]);
    
    % Traces
    DDtrace = mainhandles.data(file).FRETpairs(pair).DDtrace; % D_emission D_excitation trace
    ADtrace = mainhandles.data(file).FRETpairs(pair).ADtrace; % A_emission D_excitation trace
    AAtrace = mainhandles.data(file).FRETpairs(pair).AAtrace; % A_emission A_excitation trace
    
    % Correct for donor cross talk
    ADtraceCorr = ADtrace - Dleakage*DDtrace; % Corrected A_emission D_excitation trace (signal only due to FRET)
    
    % Correct for acceptor cross talk
    if length(ADtraceCorr)==length(AAtrace)
         ADtraceCorr = ADtraceCorr - Adirect*AAtrace;
    end
    
    % Traces
    mainhandles.data(file).FRETpairs(pair).ADtraceCorr = ADtraceCorr; % Corrected AD trace
    mainhandles.data(file).FRETpairs(pair).PRtrace = ADtrace./(ADtrace+DDtrace); % Uncorrected proximity ratio
    
    % Stoichiometry in ALEX
    if length(ADtraceCorr)==length(AAtrace)
        mainhandles.data(file).FRETpairs(pair).StraceCorr = (gamma*DDtrace+ADtraceCorr)./(gamma*DDtrace+ADtraceCorr+AAtrace); % Corrected Stoichiometry factor
        mainhandles.data(file).FRETpairs(pair).Strace = (DDtrace+ADtrace)./(DDtrace+ADtrace+AAtrace);
    end
    
    % Calculate FRET
    if ~mainhandles.settings.corrections.FRETmethod
        % Standard ratiometric method
        mainhandles.data(file).FRETpairs(pair).Etrace = ADtraceCorr./(ADtraceCorr+gamma*DDtrace); % Corrected FRET trace
    else
        % Direct A ref method
        epsDD = mainhandles.settings.corrections.epsDD;
        epsAA = mainhandles.settings.corrections.epsAA;
%         epsAD = mainhandles.settings.corrections.epsAD;
%         ADtrace = ADtrace - Dleakage*DDtrace; % Remove D leakage
%         mainhandles.data(file).FRETpairs(pair).Etrace = (ADtrace*epsAA-AAtrace*epsAD)./(AAtrace*epsDD);
        mainhandles.data(file).FRETpairs(pair).Etrace = (ADtraceCorr*epsAA)./(AAtrace*epsDD);
    end
    
end

% Update handles structure
updatemainhandles(mainhandles)

% Correct for spot profiles
mainhandles = spotCorrect(mainhandles,selectedPairs);

% Update average pair values for listbox
mainhandles = updateAvgPairValues(mainhandles, selectedPairs, mainhandles.FRETpairwindowHandle);

