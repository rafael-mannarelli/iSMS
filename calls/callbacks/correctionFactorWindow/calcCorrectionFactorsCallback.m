function mainhandles = calcCorrectionFactorsCallback(cfwHandles,resetchoice)
% Callback for forcing calculation of all correction factors
%
%    Input:
%     cfwHandles  - handles structure of the correction factor window
%     resetchoice - 0/1 reset all settings before updating
%
%    Output:
%     mainhandles - handles structure of the main window
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

% Get handles structure
mainhandles = getmainhandles(cfwHandles);
if isempty(mainhandles) || isempty(mainhandles.data)
    return
end

% All pairs
allPairs = getPairs(mainhandles.figure1,'all');
if isempty(allPairs)
    return
end

if resetchoice
    % Sure dialog
    if mainhandles.settings.corrections.molspec
        str = 'This will reset all correction factor time intervals, reuse previously removed correction-factor pairs, and recalculate all factors and FRET traces.';
    else
        str = 'This will reset all correction factor time intervals, reuse previously removed correction-factor pairs and recalculate all factors.';
    end
    
    sure = mysuredlg('Reset correction factors',str);    
    if ~sure
        return
    end
end

%% Recalculate

mainhandles = calculateCorrectionFactors(mainhandles.figure1,allPairs,'all',resetchoice);

%% Update

updateCorrectionFactorPairlist(mainhandles.figure1,cfwHandles.figure1)
updateCorrectionFactorPlots(mainhandles.figure1,cfwHandles.figure1)

if mainhandles.settings.corrections.molspec
    
    % Calculate new traces
    mainhandles = correctTraces(mainhandles.figure1, 'all');
    
    % Update plots
    FRETpairwindowHandles = updateFRETpairplots(mainhandles.figure1,mainhandles.FRETpairwindowHandle, 'traces','ADcorrect');
    
    % Update the SE plot only if pair is plotted
    mainhandles = updateSEplot(mainhandles.figure1,...
        mainhandles.FRETpairwindowHandle, ...
        mainhandles.histogramwindowHandle,...
        'all');
end
