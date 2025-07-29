function plotTimeIntervalOfInterest(mainhandle, FRETpairwindowHandle)
% Highlights the time intervals of interest specified for the selected FRET
% pair in the FRETpairwindow GUI.
%
%    Input:
%     mainhandle           - handle to the main figure window (sms)
%     FRETpairwindowHandle - handle to the FRETpairwindow
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

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (isempty(FRETpairwindowHandle)) || (~ishandle(mainhandle)) || (~ishandle(FRETpairwindowHandle))
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
FRETpairwindowHandles = guidata(FRETpairwindowHandle); % Handles to the FRET pair window

% Get selected FRET-pairs
selectedPairs = getPairs(mainhandle, 'Selected', [], FRETpairwindowHandle); % Returns pair selection as [file pair;...]

% Shorten axes tags
DDtraceAxes = FRETpairwindowHandles.DDtraceAxes;
ADtraceAxes = FRETpairwindowHandles.ADtraceAxes;
AAtraceAxes = FRETpairwindowHandles.AAtraceAxes;
StraceAxes = FRETpairwindowHandles.StraceAxes;
PRtraceAxes = FRETpairwindowHandles.PRtraceAxes;

% If there is no FRET-pair, clear all axes
if (isempty(mainhandles.data))  || (isempty(selectedPairs))
    cla(DDtraceAxes),  cla(ADtraceAxes),  cla(AAtraceAxes),  cla(StraceAxes),  cla(PRtraceAxes)
    cla(DDimageAxes),  cla(ADimageAxes),  cla(AAimageAxes)
    return
end

% Delete previous plots of time-intervals
h = findobj(DDtraceAxes,'type','rectangle');
delete(h)
h = findobj(ADtraceAxes,'type','rectangle');
delete(h)
h = findobj(AAtraceAxes,'type','rectangle');
delete(h)
h = findobj(StraceAxes,'type','rectangle');
delete(h)
h = findobj(PRtraceAxes,'type','rectangle');
delete(h)

% If there is more than one selected pair, return
if size(selectedPairs,1)~=1
    return
end

% Selected file and pairFRET-pair in selected movie file
filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

% If there are no manually specified time-interval, return
ti = mainhandles.data(filechoice).FRETpairs(pairchoice).timeInterval; % Time-interval of interest
Di = mainhandles.data(filechoice).FRETpairs(pairchoice).DblinkingInterval; % Donor blinking intervals
Ai = mainhandles.data(filechoice).FRETpairs(pairchoice).AblinkingInterval; % Acceptor blinking intervals
Db = mainhandles.data(filechoice).FRETpairs(pairchoice).DbleachingTime; % Donor bleaching time
Ab = mainhandles.data(filechoice).FRETpairs(pairchoice).AbleachingTime; % Acceptor bleaching time
if isempty(ti) && isempty(Ai) && isempty(Di) && isempty(Ab) && isempty(Db)
    return
end

% Get time vector
time = getTimeVector(mainhandles,selectedPairs,'D');

% Correct indices
ti(ti<1) = 1;
ti(ti>length(time)) = length(time);

% Convert time
ti = time(ti);
Di = time(Di);
Ai = time(Ai);
Db = time(Db);
Ab = time(Ab);

% Axes limits
ylimDD = get(DDtraceAxes,'ylim');
ylimAD = get(ADtraceAxes,'ylim');
ylimAA = get(AAtraceAxes,'ylim');
ylimS = get(StraceAxes,'ylim');
ylimPR = get(PRtraceAxes,'ylim');

% Hold on
hold(DDtraceAxes,'on')
hold(ADtraceAxes,'on')
hold(AAtraceAxes,'on')
hold(StraceAxes,'on')
hold(PRtraceAxes,'on')

%% Plot time-interval of interest and move them to the back

if ~isempty(ti)
    for i = 1:size(ti,1)
        if ti(i,1)>=ti(i,2)
            continue
        end
        
        % Plot in all axes
        plotrectangle(DDtraceAxes, [ti(i,1),ylimDD(1),ti(i,2)-ti(i,1),ylimDD(2)-ylimDD(1)], [1 0.85 0.85])
        plotrectangle(ADtraceAxes, [ti(i,1),ylimAD(1),ti(i,2)-ti(i,1),ylimAD(2)-ylimAD(1)], [1 0.85 0.85])
        plotrectangle(AAtraceAxes, [ti(i,1),ylimAA(1),ti(i,2)-ti(i,1),ylimAA(2)-ylimAA(1)], [1 0.85 0.85])
        plotrectangle(StraceAxes, [ti(i,1),ylimS(1),ti(i,2)-ti(i,1),ylimS(2)-ylimS(1)], [1 0.85 0.85])
        plotrectangle(PRtraceAxes, [ti(i,1),ylimPR(1),ti(i,2)-ti(i,1),ylimPR(2)-ylimPR(1)], [1 0.85 0.85])
    end
end

%% Plot blinking intervals

if ~isempty(Di)
    for i = 1:size(Di,1)
        if Di(i,1)>=Di(i,2)
            continue
        end
        
        % Plot in DD axes
        plotrectangle(DDtraceAxes, [Di(i,1),ylimDD(1),Di(i,2)-Di(i,1),ylimDD(2)-ylimDD(1)], [0.65 1 0.65])
    end
end

if ~isempty(Ai)
    for i = 1:size(Ai,1)
        if Ai(i,1)>=Ai(i,2)
            continue
        end
        
        % Plot in AD and AA axes
        plotrectangle(ADtraceAxes, [Ai(i,1),ylimAD(1),Ai(i,2)-Ai(i,1),ylimAD(2)-ylimAD(1)], [1 0.65 0.65])        
        if mainhandles.settings.excitation.alex
            plotrectangle(AAtraceAxes, [Ai(i,1),ylimAA(1),Ai(i,2)-Ai(i,1),ylimAA(2)-ylimAA(1)], [1 0.65 0.65])
        end
    end
end

%% Plot bleaching times

if ~isempty(Db)
    % Plot in DD axes
    xdata = get(findall(DDtraceAxes,'type','line'),'xdata');
    
    if ~isempty(xdata)
        if ~iscell(xdata)
            xdata = {xdata};
        end
        
        % Plot rectangle
        plotrectangle(DDtraceAxes, [Db, ylimDD(1), max([xdata{:}])-Db, ylimDD(2)-ylimDD(1)], [0.94 1 0.94])
    end
end

if ~isempty(Ab)
    % Plot in AD axes
    xdata = get(findall(ADtraceAxes,'type','line'),'xdata');
    
    if ~isempty(xdata)
        if ~iscell(xdata)
            xdata = {xdata};
        end
        
        % Plot rectangle
        plotrectangle(ADtraceAxes, [Ab, ylimAD(1), max([xdata{:}])-Ab, ylimAD(2)-ylimAD(1)], [1  0.94  0.94])
    end
    
    % Plot in AA axes
    if mainhandles.settings.excitation.alex
        xdata = get(findall(AAtraceAxes,'type','line'),'xdata');
        
        if ~isempty(xdata)
            if ~iscell(xdata)
                xdata = {xdata};
            end
            
            % Plot rectangle
            plotrectangle(AAtraceAxes, [Ab,ylimAA(1),max([xdata{:}])-Ab,ylimAA(2)-ylimAA(1)], [1  0.94  0.94])
        end
    end
end

hold(DDtraceAxes,'off')
hold(ADtraceAxes,'off')
hold(AAtraceAxes,'off')
hold(StraceAxes,'off')
hold(PRtraceAxes,'off')

%% Nested

    function plotrectangle(ax, pos, facecolor)
        % Plots rectangle in ax and sends it to bottom
        try
            h = rectangle('Parent',ax,...
                'Position',pos,...
                'FaceColor',facecolor); % Plot rectangular area [x y width height]
            uistack(h,'bottom')
            updateUIcontextMenus(mainhandle,h)
            
        catch err
            % This threw an error due 0 positions once, don't know why
            fprintf('Error when trying to plot rectangle in plotTimeIntervalOfInterest:\n %s',err.message)
            rethrow err
        end
    end
end
