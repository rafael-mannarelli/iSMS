function [mainhandles,FRETpairwindowHandles] = setBleachingTimesCallback(FRETpairwindowHandles)
% Callback for settings bleaching times in the FRETpairwindow
%
%    Input:
%     FRETpairwindowHandles  - handles structure of the FRETpairwindow
%
%    Output:
%     mainhandles            - handles structure of the main window
%     FRETpairwindowHandles  -
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

FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles,'bleachTime'); % Turn of integration ROIs
mainhandles = getmainhandles(FRETpairwindowHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    set(FRETpairwindowHandles.Toolbar_SetBleachingTimes,'state','off')
    return
end

% File and pair choice
selectedPairs = getPairs(FRETpairwindowHandles.main, 'Selected', [], FRETpairwindowHandles.figure1); % Returns pair selection as [file pair;...]
if isempty(selectedPairs)
    set(FRETpairwindowHandles.Toolbar_SetBleachingTimes,'state','off')
    return
elseif size(selectedPairs,1)>1
    mymsgbox('Please select a single FRET-pair only','Set bleaching');
    set(FRETpairwindowHandles.Toolbar_SetBleachingTimes,'state','off')
    return
end
filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

%% Perform user selection

set(0,'currentfigure',FRETpairwindowHandles.figure1) % Set current figure

% Manually select bleaching time-point
% [x,y,button,ax] = ginputc(1,'Color',[0.2 0.3 0.9]);
[x,y,but,ax] = myginputc2(1,...
    'FigHandle', FRETpairwindowHandles.figure1,...
    'ValidAxes', [FRETpairwindowHandles.DDtraceAxes FRETpairwindowHandles.ADtraceAxes FRETpairwindowHandles.AAtraceAxes],...
    'Color',[0.2 0.3 0.9]);

% Reset hInvisibleAxes used by ginputc
if isempty(but) || (but~=1 && but~=30) % If user didn't press left mouse button
    set(FRETpairwindowHandles.Toolbar_SetBleachingTimes,'State','off')
    return
end

% Reset hInvisibleAxes used by ginputc
if but~=30
    setappdata(0,'hInvisibleAxes',[])
elseif but==30
    [mainhandles,FRETpairwindowHandles] = setBleachingTimesCallback(FRETpairwindowHandles);
    return
end

%% Interpret selection

% x = round(x); % Round off to nearest frame

% Get selected ax
if isequal(ax,FRETpairwindowHandles.DDtraceAxes) || isequal(ax,FRETpairwindowHandles.ADtraceAxes)
    tracelength = length(mainhandles.data(filechoice).FRETpairs(pairchoice).DDtrace);
    movie = mainhandles.data(filechoice).DD_ROImovie; % All D-ROI D-exc frames
    
elseif mainhandles.settings.excitation.alex && isequal(ax,FRETpairwindowHandles.AAtraceAxes)
    tracelength = length(mainhandles.data(filechoice).FRETpairs(pairchoice).AAtrace);
    movie = mainhandles.data(filechoice).AA_ROImovie; % All A-ROI A-exc frames

else
    set(FRETpairwindowHandles.Toolbar_SetBleachingTimes,'state','off')
    return
end

% Convert to idx
if isequal(ax,FRETpairwindowHandles.AAtraceAxes)
    x = timeToIdx(mainhandles,[filechoice pairchoice],'A',x);
else
    x = timeToIdx(mainhandles,[filechoice pairchoice],'D',x);
end

% If both selections are outside trace interval
if isempty(movie) && mainhandles.settings.background.bleachchoice
    if isempty(movie)
        mymsgbox(sprintf('%s%s',...
            'Note that the raw movie has been deleted for this file and the background can therefore not be re-calculated using the set bleaching time. ',...
            'You can reload the movie from the Memory menu in the main window'));
    end
elseif (x(1)<1) || (x(1)>tracelength)
    set(FRETpairwindowHandles.Toolbar_SetBleachingTimes,'state','off')
    return
end

%% Update

% Update new interval in mainhandles
if isequal(ax,FRETpairwindowHandles.DDtraceAxes)
    mainhandles.data(filechoice).FRETpairs(pairchoice).DbleachingTime = x;
elseif (isequal(ax,FRETpairwindowHandles.ADtraceAxes)) || (isequal(ax,FRETpairwindowHandles.AAtraceAxes))
    mainhandles.data(filechoice).FRETpairs(pairchoice).AbleachingTime = x;
end

% Updates the bleach counters
updatemainhandles(mainhandles)
updateBleachCounters(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)

% Make pair re-applicable for correction factor calculation
mainhandles.data(filechoice).FRETpairs(pairchoice).Dleakage = [];
mainhandles.data(filechoice).FRETpairs(pairchoice).Adirect = [];
mainhandles.data(filechoice).FRETpairs(pairchoice).gamma = [];
mainhandles.data(filechoice).FRETpairs(pairchoice).DleakageIdx = [];
mainhandles.data(filechoice).FRETpairs(pairchoice).AdirectIdx = [];
mainhandles.data(filechoice).FRETpairs(pairchoice).gammaIdx = [];
mainhandles.data(filechoice).FRETpairs(pairchoice).DleakageRemoved = [];
mainhandles.data(filechoice).FRETpairs(pairchoice).AdirectRemoved = [];
mainhandles.data(filechoice).FRETpairs(pairchoice).gammaRemoved = [];
updatemainhandles(mainhandles)

% Calculate new intensity trace
plottedPairs = getPairs(FRETpairwindowHandles.main, 'Plotted', [], FRETpairwindowHandles.figure1, mainhandles.histogramwindowHandle);
ok = 0; % Update SE plot because intensity trace is re-calculated?
if (mainhandles.settings.background.bleachchoice)
    mainhandles = calculateIntensityTraces(FRETpairwindowHandles.main,[filechoice pairchoice]);
    FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,'traces');
    FRETpairwindowHandles = updateMoleculeFrameSliderHandles(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1);
    
    % Update SE plot if selected Pair is in it
    if ismember([filechoice pairchoice],plottedPairs,'rows','legacy')
        ok = 1;
    end
end

% Update average pair values
mainhandles = updateAvgPairValues(mainhandles, selectedPairs, mainhandles.FRETpairwindowHandle);

% Only update SE plot if it's relevant
if ok || (ismember([filechoice pairchoice],plottedPairs,'rows','legacy') && mainhandles.settings.SEplot.plotBleaching~=1)
    mainhandles = updateSEplot(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,mainhandles.histogramwindowHandle,'all');
end

% Update correction factor window
listedPairs = getPairs(FRETpairwindowHandles.main, 'correctionListed', [],[],[], mainhandles.correctionfactorwindowHandle);
if ismember(selectedPairs,listedPairs,'rows','legacy')
    updateCorrectionFactorPairlist(FRETpairwindowHandles.main,mainhandles.correctionfactorwindowHandle)
    plottedPairs = getPairs(FRETpairwindowHandles.main, 'correctionSelected', [],[],[], mainhandles.correctionfactorwindowHandle);
    if ismember(selectedPairs,plottedPairs,'rows','legacy')
        updateCorrectionFactorPlots(FRETpairwindowHandles.main,mainhandles.correctionfactorwindowHandle)
    end
end

% Update highlighted interval in trace plots
plotTimeIntervalOfInterest(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)

% Finish by turning off the toggle button again
set(FRETpairwindowHandles.Toolbar_SetBleachingTimes,'state','off')
