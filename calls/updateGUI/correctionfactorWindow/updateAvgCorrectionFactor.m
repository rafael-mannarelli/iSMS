function mainhandles = updateAvgCorrectionFactor(mainhandles,cfHandles,selectedPairs,factorchoice)
% Calculates the average correction factor value of selectedPairs
%
%    Input:
%     mainhandles   - handles structure of the mai window
%     cfHandles     - handles structure of the correction factor window
%     selectedPairs - [file1 pair1;...]
%     factorchoice  - 1: D leakage. 2: A direct. 3: gamma
%
%    Output
%     mainhandles   - ..
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

% Default
if nargin<3 || isempty(selectedPairs)
    selectedPairs = getPairs(mainhandles.figure1,'correctionselected');
end
if nargin<4 || isempty(factorchoice)
    factorchoice = mainhandles.settings.correctionfactorplot.factorchoice;
end

if isempty(selectedPairs)
    return
end

% Check if variances have been calculated
mainhandles = calculateCorrectionVariances(mainhandles,selectedPairs,0);

%% Get all values

% Update mean value counter
factors = [];
vars = [];
for i = 1:size(selectedPairs,1)
    filechoice = selectedPairs(i,1);
    pairchoice = selectedPairs(i,2);
    pair = mainhandles.data(filechoice).FRETpairs(pairchoice);
    
    if factorchoice == 1
        
        % Donor leakage pairs
        if ~isempty(pair.Dleakage)
            factors(end+1) = pair.Dleakage;
            vars(end+1) = pair.DleakageVar;
        end
        
    elseif factorchoice == 2
        
        % Direct A pairs
        if ~isempty(pair.Adirect)
            factors(end+1) = pair.Adirect;
            vars(end+1) = pair.AdirectVar;
        end
        
    elseif factorchoice == 3
        
        % Gamma factor pairs
        if ~isempty(pair.gamma)
            factors(end+1) = pair.gamma;
            vars(end+1) = pair.gammaVar;
        end
    end
end

%% Calculate average and std. dev.

if isempty(factors) % If there are no plotted data points
    set(cfHandles.meanValueCounter,'String','')
    return
end

if length(factors)==1
    
    % A single selection
    val = factors;
    stddev = sqrt(vars);
    str = 'Value:';
    
elseif ~isempty(vars) && mainhandles.settings.corrections.globalavgChoice==2
    
    % Weighted mean
    w = 1./vars; % Weights = 1/variance
    
    % Weighted average
    val = sum(factors.*w)/sum(w); % Weighted mean
    
    % Weighted std. dev.
    weightedVar = var(factors,w); % Weighted variance
    stddev = sqrt( weightedVar ); % Weighted std. dev.
    
    % String
    str = 'Weighted mean:';
    
elseif mainhandles.settings.corrections.globalavgChoice==3
    
    % Median and std. dev.
    val = median(factors);
    stddev = sqrt(pi/2)*std(factors); % Median std. dev.
    
    % String
    str = 'Median:';
    
else
    
    % Unweighted average and std. dev.
    val = mean(factors);
    stddev = std(factors);
    
    % String
    str = 'Mean:';
    
end

% Update text
set(cfHandles.meanValueCounter,'String',sprintf('%s %.3f (+-%.3f)',str,val,stddev))
