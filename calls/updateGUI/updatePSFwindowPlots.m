function updatePSFwindowPlots(mainhandle, psfwindowHandle, axeschoice)
% Updates the plots in the PSF parameter plot window
%
%   Input:
%    mainhandle      - handle to the main window
%    psfwindowHandle - handle to the psf window
%    axeschoice      - 'all', 'psfTraces', 'axes1', 'axes2'. Chooses which axes to
%                      update
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

% Set defaults
if nargin<3
    axeschoice = 'all';
end

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (isempty(psfwindowHandle))
    return
elseif (~ishandle(mainhandle)) || (~ishandle(psfwindowHandle))
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
psfwindowHandles = guidata(psfwindowHandle); % Handles to the dynamics window

% If there is no data, clear all axes and return
if (isempty(mainhandles.data))
    cla(psfwindowHandles.TraceAxes1)
    cla(psfwindowHandles.TraceAxes2)
    return
end

% Interpret axes choice
updateAxes1 = 0;
updateAxes2 = 0;
axes1choice = get(psfwindowHandles.Axes1PopupMenu,'Value'); % Selected trace for axes 1
axes2choice = get(psfwindowHandles.Axes2PopupMenu,'Value'); % Selected trace for axes 2
if strcmpi(axeschoice,'axes1') || (strcmpi(axeschoice,'psfTraces') && axes1choice>5) || strcmpi(axeschoice,'all')
    updateAxes1 = 1; % update axes 1
end
if strcmpi(axeschoice,'axes2') || (strcmpi(axeschoice,'psfTraces') && axes2choice>5) || strcmpi(axeschoice,'all')
    updateAxes2 = 1; % update axes 2
end

% Selected pair
selectedPair = getPairs(mainhandle, 'psfwindowSelected');
if size(selectedPair,1)~=1
    return
end
file = selectedPair(1);
pair = selectedPair(2);
pair1 = mainhandles.data(file).FRETpairs(pair);

% Selected channel
channels = {'DD' 'AD' 'AA'};
channel = channels{get(psfwindowHandles.PSFpopupMenu,'Value')};

tic
% Check if PSF parameter trace exists, else calculate it now
if (updateAxes1 && axes1choice>5) || (updateAxes2 && axes2choice>5)
    
    % Temporary setting
    currentSettings = mainhandles.settings;
    mainhandles.settings.integration.type = get(psfwindowHandles.MethodPopupMenu,'Value')+1;
    updatemainhandles(mainhandles)
    
    % Calculate traces
    %     if isempty(pair1.([channel 'GaussianTrace']))
    mainhandles = calculateIntensityTraces(mainhandle, selectedPair, 0, [], 0, channel); % Calculate intensity traces
    %     end
    
    % New pair
    pair2 = mainhandles.data(file).FRETpairs(pair);
    
    % Reset handles structure to previous content, but keep parameters
    parTrace = mainhandles.data(file).FRETpairs(pair).([channel 'GaussianTrace']);
    mainhandles.data(file).FRETpairs(pair) = pair1;
    
    mainhandles.data(file).FRETpairs(pair).([channel 'GaussianTrace']) = pair2.([channel 'GaussianTrace']);
    
    % Keep previous settings
    mainhandles.settings = currentSettings;
    updatemainhandles(mainhandles)
end
timed = toc

%% Update plots

if updateAxes1
    
    % Update trace plot
    updateAxes(psfwindowHandles.TraceAxes1, get(psfwindowHandles.Axes1PopupMenu,'Value'), mainhandles.settings.psfWindow.axes1color)
    
    % Highlight bleaching
    highlightBleaching(psfwindowHandles.TraceAxes1)
    
end

if updateAxes2
    
    % Update trace plot
    updateAxes(psfwindowHandles.TraceAxes2, get(psfwindowHandles.Axes2PopupMenu,'Value'), mainhandles.settings.psfWindow.axes2color)
    
    % Highlight bleaching
    highlightBleaching(psfwindowHandles.TraceAxes2)
    
end

set(psfwindowHandles.TraceAxes1, 'XTickLabel','', 'XTick',[])
xlabel(psfwindowHandles.TraceAxes2, 'Time /frames')

%% Nested

    function updateAxes(ax, choice, traceColor)
        % Updates ax according to trace choice
        
        % Gaussian parameter choice
        GaussianTrace = pair2.([channel 'GaussianTrace']);
        
        % Trace to be plotted in ax
        ylims = [];
        if choice == 1
            % DD trace
            trace = pair2.DDtrace;
            ylab = 'D - D';
        elseif choice == 2
            % AD trace
            trace = pair2.ADtrace;
            ylab = 'A - D';
        elseif choice == 3
            % AA trace
            trace = pair2.AAtrace;
            ylab = 'A - A';
        elseif choice == 4
            % S trace
            trace = pair2.StraceCorr;
            ylab = 'S';
            ylims = [-.1 1.1];
        elseif choice == 5
            % E trace
            trace = pair2.Etrace;
            ylab = 'FRET';
            ylims = [-.1 1.1];
        elseif ~isempty(GaussianTrace)
            if choice == 6
                % PSF width
                trace = mean(GaussianTrace(:,3:4)');
                ylab = 'Width /pxl';
            elseif choice == 7
                % PSF position
                x0 = GaussianTrace(1,1);
                y0 = GaussianTrace(1,2);
                x = GaussianTrace(:,1);
                y = GaussianTrace(:,2);
                trace = sqrt( (x-x0).^2 + (y-y0).^2 ); % Position from initial center
                ylab = 'Distance /pxl';
            elseif choice == 8
                % PSF x0
                trace = GaussianTrace(:,1);
                ylab = 'x-center /pxl';
            elseif choice == 9
                % PSF y0
                trace = GaussianTrace(:,2);
                ylab = 'y-center /pxl';
            elseif choice == 10
                % PSF x-width
                trace = GaussianTrace(:,3);
                ylab = 'x-width /pxl';
            elseif choice == 11
                % PSF y-width
                trace = GaussianTrace(:,4);
                ylab = 'y-width /pxl';
            elseif choice == 12
                % PSF angle
                trace = GaussianTrace(:,5)*180/pi;
                ylab = 'Deg.';
            elseif choice == 13
                % PSF background
                trace = GaussianTrace(:,6);
                ylab = 'Background';
            elseif choice == 14
                % PSF amplitude
                trace = GaussianTrace(:,7);
                ylab = 'Amplitude';
            end
        end
        
        x = 1:length(trace); % x-vector
        
        % Plot
        plot(ax, x,trace, 'Color',traceColor)
        
        % Zoom y-axes
        if isempty(ylims)
            ylims = [min(trace) max(trace)];
        end
        if length(unique(ylims))>1 % Set min and max only if they are not equal
            ylim(ax, ylims)
        end
        
        % Axes labels
        ylabel(ax, ylab)
    end

    function highlightBleaching(ax)
        % Highlights bleaching times in ax
        if ~mainhandles.settings.psfWindow.showBleaching
            return
        end
        
        % Plotted data
        ydata = get( findall(ax, 'type','line'), 'ydata');
        xdata = get( findall(ax, 'type','line'), 'xdata');
        if isempty(ydata)
            return
        elseif iscell(ydata)
            ydata = [ydata{:}];
            xdata = [xdata{:}];
        end
        
        % Axes
        ylimAx = get(ax, 'ylim'); % ylimit
        maxX = max(xdata(:)); % xlimits
        hold(ax,'on') % Hold on
        
        % Bleaching times
        bD = pair2.DbleachingTime;
        bA = pair2.AbleachingTime;
        
        if bD < length(ydata) % Plot donor bleaching
            h = rectangle('Parent', ax,...
                'Position',[bD ylimAx(1) maxX-bD ylimAx(2)-ylimAx(1)],...
                'FaceColor',[0.94 1 0.94]); % Plot rectangular area [x y width height]
            uistack(h,'bottom')
        end
        
        if bA < length(ydata) % Plot acceptor bleaching
            h = rectangle('Parent', ax,...
                'Position',[bA ylimAx(1) maxX-bA ylimAx(2)-ylimAx(1)],...
                'FaceColor',[0.94 1 0.94]); % Plot rectangular area [x y width height]
            uistack(h,'bottom')
        end
        
        hold(ax,'off')
        
    end

end