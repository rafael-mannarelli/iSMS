function [mainhandles, FRETpairwindowHandles] = setTimeIntervalOfInterestCallback(FRETpairwindowHandles)
% Callback for setting time-intervals of interest in the FRETpairwindow
%
%    Input:
%     FRETpairwindowHandles  - handles structure of the FRETpairwindow
%
%    Output:
%     mainhandles            - handles structure of the main window
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

FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles,'ti'); % Turn of integration ROIs
mainhandles = getmainhandles(FRETpairwindowHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    set(FRETpairwindowHandles.Toolbar_SetTimeIntervalToggle,'State','off')
    return
end

% File and pair choice
selectedPairs = getPairs(FRETpairwindowHandles.main, 'Selected', [], FRETpairwindowHandles.figure1); % Returns pair selection as [file pair;...]
if isempty(selectedPairs)
    set(FRETpairwindowHandles.Toolbar_SetTimeIntervalToggle,'State','off')
    return
elseif size(selectedPairs,1)>1
    mymsgbox('Please select a single FRET-pair only','Integration area');
    set(FRETpairwindowHandles.Toolbar_SetTimeIntervalToggle,'State','off')
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
for i = 1:2
%     [x,y,but,ax] = ginputc(1,'Color',[1 0.35 0.35]); % Mouse click input
    [x,y,but,ax] = myginputc2(1,...
        'FigHandle', FRETpairwindowHandles.figure1,...
        'ValidAxes', [FRETpairwindowHandles.DDtraceAxes FRETpairwindowHandles.ADtraceAxes FRETpairwindowHandles.AAtraceAxes FRETpairwindowHandles.StraceAxes FRETpairwindowHandles.PRtraceAxes],...
        'Color',[1 0.35 0.35]);
    
    % If user didn't press left mouse button
    if isempty(but) || (but~=1 && but~=30) 
        set(FRETpairwindowHandles.Toolbar_SetTimeIntervalToggle,'State','off')
        return
    end
    
    % Reset hInvisibleAxes used by ginputc
    if but~=30
        setappdata(0,'hInvisibleAxes',[])
    elseif but==30 && i==1
        [mainhandles, FRETpairwindowHandles] = setTimeIntervalOfInterestCallback(FRETpairwindowHandles);
        return
    end
    
    % Check that user pressed in one of the axes
    if (~isequal(ax,FRETpairwindowHandles.DDtraceAxes)) ...
            && (~isequal(ax,FRETpairwindowHandles.ADtraceAxes)) ...
            && (~isequal(ax,FRETpairwindowHandles.AAtraceAxes)) ...
            && (~isequal(ax,FRETpairwindowHandles.StraceAxes)) ...
            && (~isequal(ax,FRETpairwindowHandles.PRtraceAxes))
        
        set(FRETpairwindowHandles.Toolbar_SetTimeIntervalToggle,'State','off')
        return 
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

% Convert to idx
if alex && isequal(ax,FRETpairwindowHandles.AAtraceAxes)
    x = timeToIdx(mainhandles,[filechoice pairchoice],'A',sort(x));
else
    x = timeToIdx(mainhandles,[filechoice pairchoice],'D',sort(x));
end

% Round of x to nearest frames
% x = round(sort(x));
if x(1)==x(2)
    set(FRETpairwindowHandles.Toolbar_SetTimeIntervalToggle,'State','off')
    return
end

% Check if the selection is outside the axes
tracelength = length(mainhandles.data(filechoice).FRETpairs(pairchoice).DDtrace); % All D-ROI D-exc frames
if ((x(1)<1) && (x(2)<1)) || ((x(1)>tracelength) && (x(2)>tracelength)) % If both selections are outside to the one side
    set(FRETpairwindowHandles.Toolbar_SetTimeIntervalToggle,'State','off')
    return
end

if (x(1)<1) && (x(2)>tracelength)
    % If they are outside on either side delete all specified intervals
    mainhandles.data(filechoice).FRETpairs(pairchoice).timeInterval = [];

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
for i = 1:size(mainhandles.data(filechoice).FRETpairs(pairchoice).timeInterval,1)
    ti = mainhandles.data(filechoice).FRETpairs(pairchoice).timeInterval(i,:);
    
    if ((x(1)>=ti(1)) && (x(1)<=ti(2))) ...
            || ((x(2)>=ti(1)) && (x(2)<=ti(2))) ...
            || ((x(1)<=ti(1)) && (x(2)>=ti(2))) ...
            || (x(1)==ti(1) && x(2)==ti(2))
        
        idx = [idx; i];
    end
end

% Delete overlapping existing intervals, if any
mainhandles.data(filechoice).FRETpairs(pairchoice).timeInterval(idx,:) = [];
if ~isempty(mainhandles.data(filechoice).DD_ROImovie)
    mainhandles.data(filechoice).FRETpairs(pairchoice).DD_avgimage = []; % This will force a molecule image re-calculation by updateFRETpairplots
end

%% Update

% Update new interval in mainhandles
mainhandles.data(filechoice).FRETpairs(pairchoice).timeInterval(end+1,:) = x;
updatemainhandles(mainhandles)
plotTimeIntervalOfInterest(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)
% handles = updateFRETpairplots(handles.main,handles.figure1,'images');

% Update average pair values
mainhandles = updateAvgPairValues(mainhandles, selectedPairs, mainhandles.FRETpairwindowHandle);

% If histogram is open update the histogram
plottedPairs = getPairs(FRETpairwindowHandles.main,'Plotted');
if ~isempty(plottedPairs) && ismember(selectedPairs,plottedPairs, 'rows','legacy') && mainhandles.settings.SEplot.onlytinterest
    mainhandles = updateSEplot(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,mainhandles.histogramwindowHandle,'all');
    figure(FRETpairwindowHandles.figure1)
end

set(FRETpairwindowHandles.Toolbar_SetTimeIntervalToggle,'State','off')
