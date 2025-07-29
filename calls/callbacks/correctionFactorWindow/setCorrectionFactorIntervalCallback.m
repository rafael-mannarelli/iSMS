function [mainhandles, cwHandles] = setCorrectionFactorIntervalCallback(cwHandles)
% Callback for setting time-intervals of interest in the FRETpairwindow
%
%    Input:
%     cwHandles  - handles structure of the correction factor window
%
%    Output:
%     mainhandles  - handles structure of the main window
%     cwHandles  - ..
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

cwHandles = turnofftogglesCorrectionWindow(cwHandles,'ti');
mainhandles = getmainhandles(cwHandles);
if isempty(mainhandles)
    return
end

% Turn on interval highlighting
if strcmpi(get(cwHandles.Toolbar_ShowCorrectionInterval,'State'),'off')
    set(cwHandles.Toolbar_ShowCorrectionInterval,'State','on')
    mainhandles = showcorrectionfactorIntervalCallback(cwHandles);
    mainhandles = getmainhandles(cwHandles);
end

% File and pair choice
selectedPairs = getPairs(cwHandles.main, 'correctionSelected', [],[],[], cwHandles.figure1); % Returns pair selection as [file pair;...]
if isempty(selectedPairs)
    set(cwHandles.Toolbar_SetTimeIntervalToggle,'State','off')
    return
elseif size(selectedPairs,1)>1
    mymsgbox('Please select a single trace only','iSMS');
    set(cwHandles.Toolbar_SetTimeIntervalToggle,'State','off')
    return
end
filechoice = selectedPairs(1,1);
pairchoice = selectedPairs(1,2);

%% User input

% Select interval and return if user didn't press twice with left mouse
% button in one of the trace axes
set(0,'currentfigure',cwHandles.figure1)
% axes(handles.ADtraceAxes)
for i = 1:2
%     [x,y,but,ax] = ginputc(1,'Color','k'); % Mouse click input
    [x,y,but,ax] = myginputc2(1,...
        'FigHandle', cwHandles.figure1,...
        'ValidAxes', [cwHandles.DDtraceAxes cwHandles.ADtraceAxes cwHandles.AAtraceAxes cwHandles.ax4],...
        'Color','k');
    
    % If user didn't press left mouse button
    if isempty(but) || (but~=1 && but~=30) 
        set(cwHandles.Toolbar_SetTimeInterval,'State','off')
        return
    end
    
    % Reset hInvisibleAxes used by ginputc
    if but~=30
        setappdata(0,'hInvisibleAxes',[])
    elseif but==30 && i==1
        [mainhandles, cwHandles] = setCorrectionFactorIntervalCallback(cwHandles);
        return
    end
    
    % Check that user pressed in one of the axes
    if (~isequal(ax,cwHandles.DDtraceAxes)) ...
            && (~isequal(ax,cwHandles.ADtraceAxes)) ...
            && (~isequal(ax,cwHandles.AAtraceAxes)) ...
            && (~isequal(ax,cwHandles.ax4))
        
        set(cwHandles.Toolbar_SetTimeInterval,'State','off')
        return
    end
    
    if mainhandles.settings.correctionfactorplot.factorchoice==1 || mainhandles.settings.correctionfactorplot.factorchoice==3
        if (~isequal(ax,cwHandles.DDtraceAxes)) && (~isequal(ax,cwHandles.ADtraceAxes))
            set(cwHandles.Toolbar_SetTimeInterval,'State','off')
            return % If didn't press in one of the trace axes
        end
    elseif mainhandles.settings.correctionfactorplot.factorchoice == 2
        if (~isequal(ax,cwHandles.ADtraceAxes)) && (~isequal(ax,cwHandles.AAtraceAxes))
            set(cwHandles.Toolbar_SetTimeInterval,'State','off')
            return % If didn't press in one of the trace axes
        end
    end
    
    % Check if selection is outside the y-axes, or the first selection is
    % outside the x-axes
    xlims = get(ax,'xlim');
    ylims = get(ax,'ylim');
    if (y(1)<ylims(1) || y(1)>ylims(2)) || (i==1 && (x(1)<xlims(1) || x(1)>xlims(2)))
        set(cwHandles.Toolbar_SetTimeInterval,'State','off')
        return
    end
    
    % Continue to next
    if i==1
        x1 = x;
        ax1 = ax;
        continue
    end
    
    % Both selections
    x = [x1 x];
end

% If user didn't press twice in the same axes
if ~isequal(ax,ax1)
    set(cwHandles.Toolbar_SetTimeInterval,'State','off')
    return
end

% Round of x to nearest frames
x = round(sort(x));
if x(1)==x(2)
    set(cwHandles.Toolbar_SetTimeInterval,'State','off')
    return
end

% Check if the selection is outside the axes
if ((x(1)<xlims(1)) && (x(2)<xlims(1))) || ((x(1)>xlims(2)) && (x(2)>xlims(2))) || ((x(1)<xlims(1)) && (x(2)>xlims(2)))
    set(cwHandles.Toolbar_SetTimeInterval,'State','off')
    return
end

% Check seleted interval and update mainhandles
traceLength = length(mainhandles.data(filechoice).FRETpairs(pairchoice).DDtrace);
if mainhandles.settings.correctionfactorplot.factorchoice == 1
    if min(x)<1 % If one is outside return
        set(cwHandles.Toolbar_SetTimeInterval,'State','off')
        return
    elseif x(2)>traceLength % If only the second is outside set it to the length of the movie
        x(2) = traceLength;
    end
    
    mainhandles.data(filechoice).FRETpairs(pairchoice).DleakageIdx = x;
    
    % Calculate correction factor
    updatemainhandles(mainhandles)
    mainhandles = calculateCorrectionFactors(cwHandles.main,selectedPairs,'Dleakage');
    
elseif  mainhandles.settings.correctionfactorplot.factorchoice == 2
    if min(x)<1 % If one is outside return
        set(cwHandles.Toolbar_SetTimeInterval,'State','off')
        return
    elseif x(2)>traceLength % If only the second is outside set it to the length of the movie
        x(2) = traceLength;
    end
    
    mainhandles.data(filechoice).FRETpairs(pairchoice).AdirectIdx = x;
    
    % Calculate new correction factor
    updatemainhandles(mainhandles)
    mainhandles = calculateCorrectionFactors(cwHandles.main,selectedPairs,'Adirect');
    
elseif  mainhandles.settings.correctionfactorplot.factorchoice == 3
    % Check if selection was made across the A bleaching time
    bA = mainhandles.data(filechoice).FRETpairs(pairchoice).AbleachingTime;
    if (min(x)<bA && max(x)>bA)
        fh = mymsgbox(sprintf('%s%s',...
            'For specifying gamma factor intervals, the selection must be done on either side of the A bleaching time point. ',...
            'If you insist on the specified interval, you can re-set the A bleaching time and do the selection again.'));
        set(cwHandles.Toolbar_SetTimeInterval,'State','off')
        movegui(fh,'northwest')
        return
    end
    
    % Check on what side of the A bleaching time selection was made
    if isequal(ax,cwHandles.DDtraceAxes) && (x(1)<bA && x(2)<=bA && x(1)>=1 && x(2)>1) % If selection was made in DD axes on left side of A bleaching time
        mainhandles.data(filechoice).FRETpairs(pairchoice).gammaIdx(2,1:2) = x;
    elseif isequal(ax,cwHandles.DDtraceAxes) && (x(1)>=bA && x(2)>bA && x(1)<traceLength && x(2)<=traceLength) % If selection was made in DD axes on right side of A bleaching time
        mainhandles.data(filechoice).FRETpairs(pairchoice).gammaIdx(2,3:4) = x;
    elseif isequal(ax,cwHandles.ADtraceAxes) && (x(1)<bA && x(2)<=bA && x(1)>=1 && x(2)>1) % If selection was made in AD axes on left side of A bleaching time
        mainhandles.data(filechoice).FRETpairs(pairchoice).gammaIdx(1,1:2) = x;
    elseif isequal(ax,cwHandles.ADtraceAxes) && (x(1)>=bA && x(2)>bA && x(1)<traceLength && x(2)<=traceLength) % If selection was made in AD axes on right side of A bleaching time
        mainhandles.data(filechoice).FRETpairs(pairchoice).gammaIdx(1,3:4) = x;
    end
    
    % Calculate new correction factor
    updatemainhandles(mainhandles)
    mainhandles = calculateCorrectionFactors(cwHandles.main,selectedPairs,'gamma');
end

% Update GUI
updatemainhandles(mainhandles)
updateCorrectionFactorPairlist(cwHandles.main,cwHandles.figure1)
updateCorrectionFactorPlots(cwHandles.main,cwHandles.figure1)
set(cwHandles.Toolbar_SetTimeInterval,'State','off')
