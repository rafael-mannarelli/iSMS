function mainhandles = clearBleachingTime(mainhandles,selectedPairs,updatechoice)
% Clears bleaching times and relevant associated info of selectedPairs
%
%    Input:
%     fpwHandles     - FRETpair-window handles structure
%     selectedPairs  - [file1 pair1;...]
%     updatechoice   - 0/1 whether to update GUI
%
%    Output:
%     mainhandles    - ..
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

if nargin<3 || isempty(updatechoice)
    updatechoice = 1;
end

%% Clear relevant fields

for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    % Clear    
    mainhandles.data(file).FRETpairs(pair).DbleachingTime = [];
    mainhandles.data(file).FRETpairs(pair).AbleachingTime = [];
    
    % Update the bleach counters
    updatemainhandles(mainhandles)
    updateBleachCounters(mainhandles.figure1,mainhandles.FRETpairwindowHandle)
    
    % Make pair re-applicable for correction factor calculation
    mainhandles.data(file).FRETpairs(pair).Dleakage = [];
    mainhandles.data(file).FRETpairs(pair).Adirect = [];
    mainhandles.data(file).FRETpairs(pair).gamma = [];
    mainhandles.data(file).FRETpairs(pair).DleakageIdx = [];
    mainhandles.data(file).FRETpairs(pair).AdirectIdx = [];
    mainhandles.data(file).FRETpairs(pair).gammaIdx = [];
    mainhandles.data(file).FRETpairs(pair).DleakageRemoved = [];
    mainhandles.data(file).FRETpairs(pair).AdirectRemoved = [];
    mainhandles.data(file).FRETpairs(pair).gammaRemoved = [];
end

updatemainhandles(mainhandles)

if ~updatechoice
    return
end

%% Calculate new intensity trace

plottedPairs = getPairs(mainhandles.figure1, 'Plotted');
ok = 0; % Update SE plot because intensity trace is re-calculated?
if mainhandles.settings.background.bleachchoice
    mainhandles = calculateIntensityTraces(mainhandles.figure1,[file pair]);
    fpwHandles = updateFRETpairplots(mainhandles.figure1,mainhandles.FRETpairwindowHandle,'traces');
    fpwHandles = updateMoleculeFrameSliderHandles(mainhandles.figure1,mainhandles.FRETpairwindowHandle);
    
    % Update SE plot if selected Pair is in it
    if ismember(selectedPairs,plottedPairs,'rows','legacy')
        ok = 1;
    end
end

%% Update average pair values

mainhandles = updateAvgPairValues(mainhandles, selectedPairs, mainhandles.FRETpairwindowHandle);

%% Only update SE plot if it's relevant

if ok || (ismember(1,ismember(selectedPairs,plottedPairs,'rows','legacy')) && mainhandles.settings.SEplot.plotBleaching~=1)
    mainhandles = updateSEplot(mainhandles.figure1,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
end

%% Update correction factor window

listedPairs = getPairs(mainhandles.figure1, 'correctionListed', [],[],[], mainhandles.correctionfactorwindowHandle);
if ismember(selectedPairs,listedPairs,'rows','legacy')
    updateCorrectionFactorPairlist(mainhandles.figure1,mainhandles.correctionfactorwindowHandle)
    plottedPairs = getPairs(mainhandles.figure1, 'correctionSelected', [],[],[], mainhandles.correctionfactorwindowHandle);
    if ismember(selectedPairs,plottedPairs,'rows','legacy')
        updateCorrectionFactorPlots(mainhandles.figure1,mainhandles.correctionfactorwindowHandle)
    end
end

%% Update highlighted interval in trace plots

plotTimeIntervalOfInterest(mainhandles.figure1,mainhandles.FRETpairwindowHandle)

%% Finish

% Finish by turning off the toggle button again
try set(fpwHandles.Toolbar_SetBleachingTimes,'state','off'), end
