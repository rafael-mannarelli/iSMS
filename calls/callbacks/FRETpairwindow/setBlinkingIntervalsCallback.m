function [mainhandles, FRETpairwindowHandles] = setBlinkingIntervalsCallback(FRETpairwindowHandles)
% Callback for setting blinking-intervals in the FRETpairwindow
%
%    Input:
%     FRETpairwindowHandles  - handles structure of the FRETpairwindow
%
%    Output:
%     FRETpairwindowHandles  - ..
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

FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles,'bi'); % Turn of integration ROIs
mainhandles = getmainhandles(FRETpairwindowHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    set(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'State','off')
    return
end

% File and pair choice
selectedPairs = getPairs(FRETpairwindowHandles.main, 'Selected', [], FRETpairwindowHandles.figure1); % Returns pair selection as [file pair;...]
if isempty(selectedPairs)
    set(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'State','off')
    return
elseif size(selectedPairs,1)>1
    mymsgbox('Please select a single FRET-pair only','Integration area');
    set(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'State','off')
    return
end
filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

% Scheme
alex = mainhandles.settings.excitation.alex;

%% Perform selection

% Select interval and return if user didn't press twice with left mouse
% button in one of the trace axes
% set(0,'currentfigure',FRETpairwindowHandles.figure1)
% axes(FRETpairwindowHandles.DDtraceAxes)
for i = 1:2
%     [x,y,but,ax] = ginputc(1,'Color',[0.2 0.3 0.9]); % Mouse click input
    [x,y,but,ax] = myginputc2(1,...
        'FigHandle', FRETpairwindowHandles.figure1,...
        'ValidAxes', [FRETpairwindowHandles.DDtraceAxes FRETpairwindowHandles.ADtraceAxes FRETpairwindowHandles.AAtraceAxes],...
        'Color', [0.2 0.3 0.9]);
    
    if isempty(but) || (but~=1 && but~=30) % If user didn't press left mouse button
        set(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'State','off')
        return
    end
    
    % Reset hInvisibleAxes used by ginputc
    if but~=30
        setappdata(0,'hInvisibleAxes',[])
    elseif but==30 && i==1
        [mainhandles, FRETpairwindowHandles] = setBlinkingIntervalsCallback(FRETpairwindowHandles);
        return
    end
    
    % Check that user pressed one of the axes
    if (~isequal(ax,FRETpairwindowHandles.DDtraceAxes)) ...
            && (~isequal(ax,FRETpairwindowHandles.ADtraceAxes)) ...
            && (~isequal(ax,FRETpairwindowHandles.AAtraceAxes)) ...
        
        set(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'State','off')
        return 
    end
    
    % Reset hInvisibleAxes used by ginputc
    if but~=30
        setappdata(0,'hInvisibleAxes',[])
    elseif but==30 && i==1
        [mainhandles, FRETpairwindowHandles] = setBlinkingIntervalsCallback(FRETpairwindowHandles);
        return
    end
    
    if but~=1 && but~=30 % If user didn't press left mouse button
        set(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'State','off')
        return
    end
    if (~isequal(ax,FRETpairwindowHandles.DDtraceAxes)) && (~isequal(ax,FRETpairwindowHandles.ADtraceAxes)) && (~isequal(ax,FRETpairwindowHandles.AAtraceAxes))
        set(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'State','off')
        return % If didn't press in one of the trace axes
    end
    
    if i==1
        x1 = x;
        ax1 = ax;
        continue
    end
    
    % Both selections
    x = [x1 x];
end

%% Interpret

% Axes in which user pressed
if isequal(ax,FRETpairwindowHandles.DDtraceAxes)
    blinkingInterval = mainhandles.data(filechoice).FRETpairs(pairchoice).DblinkingInterval;
elseif (isequal(ax,FRETpairwindowHandles.ADtraceAxes)) || (isequal(ax,FRETpairwindowHandles.AAtraceAxes) && alex)
    blinkingInterval = mainhandles.data(filechoice).FRETpairs(pairchoice).AblinkingInterval;
else
    set(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'State','off')
    return
end

% Convert to idx
if alex && isequal(ax,FRETpairwindowHandles.AAtraceAxes)
    x = timeToIdx(mainhandles,[filechoice pairchoice],'A',sort(x));
else
    x = timeToIdx(mainhandles,[filechoice pairchoice],'D',sort(x));
end

% Round of x to nearest frames
% x = round(sort(x));
if x(1)==x(2)
    set(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'State','off')
    return
end

% Check if the selection is outside the axes
tracelength = length(mainhandles.data(filechoice).FRETpairs(pairchoice).DDtrace);
if ((x(1)<1) && (x(2)<1)) || ((x(1)>tracelength) && (x(2)>tracelength)) 
    % If both selections are outside to the one side
    set(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'State','off')
    return
end

if (x(1)<1) && (x(2)>tracelength) 
    % If they are outside on either side delete all specified intervals
    blinkingInterval = [];

elseif x(2)>tracelength 
    % If only the second is outside set it to the length of the movie
    x(2) = tracelength;

elseif x(1)<1 
    % If only the first is outside set it to 1
    x(1) = 1;
end

% Check if one of the selected points is within an existing interval or the
% new interval covers an existing interval
idx = [];
for i = 1:size(blinkingInterval,1)
    ti = blinkingInterval(i,:);
    
    if ((x(1)>=ti(1)) && (x(1)<=ti(2))) ...
            || ((x(2)>=ti(1)) && (x(2)<=ti(2))) ...
            || ((x(1)<=ti(1)) && (x(2)>=ti(2))) ...
            || (x(1)==ti(1) && x(2)==ti(2))
        
        idx = [idx; i];
    end
end

%% Update

% Delete overlapping existing intervals, if any
blinkingInterval(idx,:) = [];

% Update new interval in mainhandles
blinkingInterval(end+1,:) = x;
if isequal(ax,FRETpairwindowHandles.DDtraceAxes)
    mainhandles.data(filechoice).FRETpairs(pairchoice).DblinkingInterval = blinkingInterval;
elseif (isequal(ax,FRETpairwindowHandles.ADtraceAxes)) || (isequal(ax,FRETpairwindowHandles.AAtraceAxes))
    mainhandles.data(filechoice).FRETpairs(pairchoice).AblinkingInterval = blinkingInterval;
end
updatemainhandles(mainhandles)
plotTimeIntervalOfInterest(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)
% handles = updateFRETpairplots(handles.main,handles.figure1,'images');

% Update traces and plots
if mainhandles.settings.background.blinkchoice
    mainhandles = calculateIntensityTraces(FRETpairwindowHandles.main, selectedPairs);
    FRETpairwindowHandles = updateFRETpairplots(FRETpairwindowHandles.main, FRETpairwindowHandles.figure1, 'traces');
    FRETpairwindowHandles = updateMoleculeFrameSliderHandles(FRETpairwindowHandles.main, FRETpairwindowHandles.figure1);
end

% Update average pair values
mainhandles = updateAvgPairValues(mainhandles, selectedPairs, mainhandles.FRETpairwindowHandle);

% If histogram is open update the histogram
plottedPairs = getPairs(FRETpairwindowHandles.main,'Plotted');
if ~isempty(plottedPairs) && ismember(selectedPairs,plottedPairs, 'rows','legacy')
    mainhandles = updateSEplot(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,mainhandles.histogramwindowHandle,'all');
end

set(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'State','off')
