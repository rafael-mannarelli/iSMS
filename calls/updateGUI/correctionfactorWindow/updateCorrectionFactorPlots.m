function updateCorrectionFactorPlots(mainhandle,cfHandle,axeschoice)
% Updates the plots in the correction factor window
%
%    Input:
%     mainhandle    - handle to main GUI window (sms)
%     cfHandle      - handle to the correction factor GUI window
%     axeschoice    - 'trace', 'hist', 'fit', 'all'. Chooses which axes to
%                     update
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

% Check inputs are handles to the GUI windows
if (isempty(mainhandle)) || (isempty(cfHandle))
    return
elseif (~ishandle(mainhandle)) || (~ishandle(cfHandle))
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
cfHandles = guidata(cfHandle); % Handles to the correctionfactor window

% If there is no data, clear all axes and return
if (isempty(mainhandles.data))
    clearAxes(cfHandles)
    return
end

% Get listed pairs
selectedPairs = getPairs(mainhandle,'correctionSelected',[],[],[],cfHandle);
if isempty(selectedPairs)
    clearAxes(cfHandles)
    return
end

% Scheme
alex = mainhandles.settings.excitation.alex;

%% Update trace plot

if (strcmpi(axeschoice,'trace') || strcmpi(axeschoice,'all')) && size(selectedPairs,1)==1
    filechoice = selectedPairs(1);
    pairchoice = selectedPairs(2);
    pair = mainhandles.data(filechoice).FRETpairs(pairchoice);
    
    % Shorten
    DDtraceAxes = cfHandles.DDtraceAxes;
    ADtraceAxes = cfHandles.ADtraceAxes;
    AAtraceAxes = cfHandles.AAtraceAxes;
    
    % Plot in two bottom axes
    if alex
        % Plot AA trace in ax3
        plotTrace(AAtraceAxes,1:length(pair.AAtrace),pair.AAtrace,'red',getYlabel(mainhandles,'correctionAx3'))
        
        % Update bottom ax
        updateAx4(mainhandles.settings.correctionfactorplot.ax4)
        
    else
        % Plot E trace in ax3
        plotTrace(AAtraceAxes,1:length(pair.Etrace),pair.Etrace,'blue','E')
        
        % Update bottom ax
        updateAx4(1)
    end
    
    % Plot DD and AD
    DDtrace = pair.DDtrace;
    ADtrace = pair.ADtraceCorr;        
    plotTrace(DDtraceAxes,1:length(DDtrace),DDtrace,'green',getYlabel(mainhandles,'correctionAx1'))
    plotTrace(ADtraceAxes,1:length(ADtrace),ADtrace,'red',getYlabel(mainhandles,'correctionAx2'))
    
    %---- Highlight time intervals in trace plots ----%
    % Delete previous plots of time-intervals
    initAxes([DDtraceAxes ADtraceAxes AAtraceAxes]);
    
    ylimDD = get(DDtraceAxes,'ylim');
    ylimAD = get(ADtraceAxes,'ylim');
    ylimAA = get(AAtraceAxes,'ylim');
    
    % Highlight interval used for calculating the correction factor
    if mainhandles.settings.correctionfactorplot.showInterval
        if mainhandles.settings.correctionfactorplot.factorchoice == 1 % Donor leakage pairs
            %             if (bD<=length(pair.DDtrace)) && (bA<=length(pair.ADtrace)) && (bD>bA)
            if ~isempty(pair.DleakageIdx)
                createRectangle(DDtraceAxes, [pair.DleakageIdx(1),ylimDD(1),diff(pair.DleakageIdx),ylimDD(2)-ylimDD(1)], [0.94 0.94 0.94])
                createRectangle(ADtraceAxes, [pair.DleakageIdx(1),ylimAD(1),diff(pair.DleakageIdx),ylimAD(2)-ylimAD(1)], [0.94 0.94 0.94])
            end
            
            %-- Direct A pairs
        elseif mainhandles.settings.correctionfactorplot.factorchoice == 2 % Direct A pairs
            
            if ~isempty(pair.AdirectIdx) && alex
                createRectangle(ADtraceAxes, [pair.AdirectIdx(1),ylimAD(1),diff(pair.AdirectIdx),ylimAD(2)-ylimAD(1)], [0.94 0.94 0.94])
                createRectangle(AAtraceAxes, [pair.AdirectIdx(1),ylimAA(1),diff(pair.AdirectIdx),ylimAA(2)-ylimAA(1)], [0.94 0.94 0.94])
            end
            
            %-- Gamma pairs
        elseif mainhandles.settings.correctionfactorplot.factorchoice == 3 % Gamma factor pairs
            if ~isempty(pair.gammaIdx)
                createRectangle(DDtraceAxes, [pair.gammaIdx(2,1),ylimDD(1),diff(pair.gammaIdx(2,1:2)),ylimDD(2)-ylimDD(1)], [0.94 0.94 0.94])
                createRectangle(DDtraceAxes, [pair.gammaIdx(2,3),ylimDD(1),diff(pair.gammaIdx(2,3:4)),ylimDD(2)-ylimDD(1)], [0.94 0.94 0.94])
                
                createRectangle(ADtraceAxes, [pair.gammaIdx(1,1),ylimAD(1),diff(pair.gammaIdx(1,1:2)),ylimAD(2)-ylimAD(1)], [0.94 0.94 0.94])
                createRectangle(ADtraceAxes, [pair.gammaIdx(1,3),ylimAD(1),diff(pair.gammaIdx(1,3:4)),ylimAD(2)-ylimAD(1)], [0.94 0.94 0.94])
                
            end
        end
        
    end
    
    % Highlight bleaching
    if mainhandles.settings.correctionfactorplot.showBleaching
        bD = pair.DbleachingTime;
        bA = pair.AbleachingTime;
        
        if bD<length(DDtrace)
            % Plot in DD axes
            xdata = get(findall(DDtraceAxes,'type','line'),'xdata');
            if ~isempty(xdata)
                if iscell(xdata)
                    maxX = max([xdata{:}]);
                else
                    maxX = max(xdata(:));
                end
                createRectangle(DDtraceAxes, [bD,ylimDD(1),maxX-bD,ylimDD(2)-ylimDD(1)], [0.94 1 0.94])
                
            end
        end
        
        if bA<length(ADtrace)
            % Plot in AD axes
            xdata = get(findall(ADtraceAxes,'type','line'),'xdata');
            if ~isempty(xdata)
                if iscell(xdata)
                    maxX = max([xdata{:}]);
                else
                    maxX = max(xdata(:));
                end
                createRectangle(ADtraceAxes, [bA,ylimAD(1),maxX-bA,ylimAD(2)-ylimAD(1)], [1 0.94 0.94])
                
                % Plot in AA axes
                if alex
                    createRectangle(AAtraceAxes,[bA,ylimAA(1),maxX-bA,ylimAA(2)-ylimAA(1)], [1 0.94 0.94])
                end
            end
        end
        
    end
    
    %-- Zero lines --
    plotZerolines(DDtraceAxes, [0 0])
    plotZerolines(ADtraceAxes, [0 0])
    plotZerolines(AAtraceAxes, [0 0])
    
    hold(DDtraceAxes,'off')
    hold(ADtraceAxes,'off')
    hold(AAtraceAxes,'off')
    
    % Update context menu
    updateUIcontextMenus(mainhandle,[DDtraceAxes ADtraceAxes AAtraceAxes ax4])
    
else
    cla(cfHandles.DDtraceAxes)
    cla(cfHandles.ADtraceAxes)
    cla(cfHandles.AAtraceAxes)
    cla(cfHandles.ax4)
end

%% Update histogram plot

if strcmpi(axeschoice,'hist') || strcmpi(axeschoice,'all')
    HistAxes = cfHandles.HistAxes;
    
    % Get all correction factor of selected pairs
    if mainhandles.settings.correctionfactorplot.factorchoice == 1
        % D leakage
        [mainhandles,factors,E,xy] = getFactors(mainhandles, 'Dleakage');
        
    elseif mainhandles.settings.correctionfactorplot.factorchoice == 2
        % Direct A pairs
        [mainhandles,factors,E,xy] = getFactors(mainhandles, 'Adirect');
        
    elseif mainhandles.settings.correctionfactorplot.factorchoice == 3
        % Gamma factor pairs
        [mainhandles,factors,E,xy] = getFactors(mainhandles, 'gamma');
    end
    
    % If there are no plotted data points, return
    if isempty(factors) 
        cla(HistAxes)
        return
    end
    
    % Plot depending on setting
    if mainhandles.settings.correctionfactorplot.histogramplot==1
        % Get number of bins from the slider
        nBins = get(cfHandles.binSlider,'Value');
        
        % Plot histogram
        [n,xout] = hist(factors,nBins); % n is frequency of bin centred at xout
        
        % VERSION DEPENDENT SYNTAX
        if mainhandles.matver>8.3
            b = bar(HistAxes,xout,n,'hist'); % Same as hist(HistAxes,y,nBins)
        else
            b = bar(HistAxes,xout,n,'style','hist'); % Same as hist(HistAxes,y,nBins)
        end
        
        % Bar colors
        set(b, 'EdgeColor',mainhandles.settings.SEplot.binEdgeColor, 'FaceColor',mainhandles.settings.SEplot.binFaceColor)
        
        % Axis labels
        ylabel(HistAxes,'Counts')
        setFactorLabel(HistAxes,'xlabel')
        
    elseif mainhandles.settings.correctionfactorplot.histogramplot==2
        
        % Plot factor vs. E
        scatter(HistAxes,E,factors)
        
        % Axis labels
        xlabel(HistAxes,'FRET at bleaching')
        setFactorLabel(HistAxes,'ylabel')
        
    elseif mainhandles.settings.correctionfactorplot.histogramplot==3
        
        % Plot factor vs. xy-coordinate
        factors = double(factors(:));
        
        if length(factors)>2
            % Grid data
            [xq,yq] = meshgrid(1:1:round(mainhandles.data(selectedPairs(1,1)).Droi(3)), 1:1:round(mainhandles.data(selectedPairs(1,1)).Droi(4)));
            
            % Must be double precision
            xq = double(xq);
            yq = double(yq);
            vq = griddata(xy(:,1),xy(:,2),factors,xq,yq); % Interpolate
            
            % Plot points
            mesh(HistAxes,vq)
            hold(HistAxes,'on')
            % plot3k(cc,'MarkerSize',15)
        end
        
        % Plot points
        scatter3(HistAxes,xy(:,1),xy(:,2),factors,'*')
        hold(HistAxes,'off')
        
        % Plot text labels
        if mainhandles.settings.correctionfactorplot.surflabels
            labels = {};
            for i = 1:size(selectedPairs,1)
                labels{i,1} = sprintf('(%i,%i)',selectedPairs(i,1),selectedPairs(i,2));
            end
            h = text(xy(:,1),xy(:,2),ones(size(selectedPairs,1),1)*10, labels,...
                'Parent', HistAxes,...
                'VerticalAlignment','bottom', ...
                'HorizontalAlignment','right',...
                'Color','black');
            %     uistack(h, 'top')
        end
        
        % Axis properties
        axis(HistAxes,'equal')
        xlim(HistAxes, [0 mainhandles.data(selectedPairs(1,1)).Droi(3)])
        ylim(HistAxes, [0 mainhandles.data(selectedPairs(1,1)).Droi(4)])
        xlabel(HistAxes,'ROI x /pixel index')
        ylabel(HistAxes,'ROI y /pixel index')
        view(HistAxes,2)
        
        % Colorbar
        cb = colorbar('peer',HistAxes);
        setFactorLabel(cb,'ylabel')
        
    end
    
    % Update context menu
    updateUIcontextMenus(mainhandle,[HistAxes])
    
end

% Update average value
mainhandles = updateAvgCorrectionFactor(mainhandles,cfHandles,selectedPairs);

%% Nested

    function [mainhandles factors E xy] = getFactors(mainhandles, choice)
        factors = [];
        E = [];
        xy = [];
        for i = 1:size(selectedPairs,1)
            filechoice = selectedPairs(i,1);
            pairchoice = selectedPairs(i,2);
            pair = mainhandles.data(filechoice).FRETpairs(pairchoice);
            
            % If correction factor has not been calculated yet, do it now
            if isempty(pair.(choice))
                mainhandles = calculateCorrectionFactors(mainhandle,[filechoice pairchoice],choice);
                pair = mainhandles.data(filechoice).FRETpairs(pairchoice);
                if ~isempty(pair.(choice))
                    updateCorrectionFactorPairlist(mainhandle,cfHandle)
                    updateCorrectionFactorPlots(mainhandle,cfHandle,'trace')
                end
            end
            
            % Collect factor
            if ~isempty(pair.(choice))
                factors(end+1) = pair.(choice);
                
                % Get E at bleaching time
                if mainhandles.settings.correctionfactorplot.histogramplot==2
                    
                    % Indices used for calculating E
                    idx2 = min([pair.AbleachingTime pair.DbleachingTime])-mainhandles.settings.corrections.spacer;
                    idx1 = idx2-mainhandles.settings.corrections.Eframes;
                    if idx1<1
                        idx1 = 1;
                    end
                    if idx2<1
                        idx2 = 1;
                    end
                    
                    % Get E
                    E(end+1) = mean(pair.Etrace(idx1:idx2));
                    
                elseif mainhandles.settings.correctionfactorplot.histogramplot==3
                    
                    % Molecule coordinates
                    xy(end+1,1:2) = (pair.Dxy+pair.Axy)/2;
                    
                end
            end
            
        end
    end

    function plotTrace(ax,x,y,col,ylab)
        % Plot trace
        p = plot(ax,x,y,'Color',col);
        
        % Update UI context menu
        updateUIcontextMenus(mainhandle,p)
        
        % Zoom y-axes
        if length(unique(y))>1
            ylim(ax,[min(y) max(y)])
        end
        
        % Axes labels
        if strcmp(get(get(ax,'ylabel'),'string'),'')
            ylabel(ax,ylab,'Interpreter','tex')
            set(ax, 'XTickLabel','')
        end
        
    end

    function initAxes(h)
        for i = 1:length(h)
            r = findobj(h(i),'type','rectangle');
            delete(r)
            
            hold(h(i),'on')
        end
    end

    function createRectangle(ax, pos, col)
        
        xdata = get(findall(ax,'type','line'), 'xdata');
        if ~isempty(xdata)
            
            % Create rectangle
            h = rectangle('Parent',ax,...
                'Position',pos,...
                'FaceColor',col); % Plot rectangular area [x y width height]
            
            % Move to bottom
            uistack(h,'bottom')
            
            % Update context menu
            updateUIcontextMenus(mainhandle,h)
        end
        
    end

    function plotZerolines(ax, y1)
        xl = get(ax,'xlim');
        p = plot(ax,xl,y1,'--k');
        updateUIcontextMenus(mainhandle,p)
    end

    function updateAx4(choice)
        % Updates plot in bottom ax, which is setting dependent.
        
        % Default
        if nargin<1
            choice = mainhandles.settings.correctionfactorplot.ax4;
        end
        
        % Handle to axes
        ax4 = cfHandles.ax4;
        
        % Get data
        x = [];
        y = [];
        if choice==1
            if mainhandles.settings.correctionfactorplot.factorchoice == 1
                temp = pair.DleakageTrace;
                val = pair.Dleakage;
            elseif mainhandles.settings.correctionfactorplot.factorchoice == 2
                temp = pair.AdirectTrace;
                val = pair.Adirect;
            elseif mainhandles.settings.correctionfactorplot.factorchoice == 3
                temp = pair.gammaTrace;
                val = pair.gamma;
            end
            if ~isempty(temp)
                x = temp(:,1);
                y = temp(:,2);
            end
            
        elseif choice==2
            y = pair.StraceCorr;
            x = 1:length(y);
            
        elseif choice==3
            y = pair.Etrace;
            x = 1:length(y);
            
        end
        
        % Plot trace
        plotTrace(ax4,x,y,'blue',getYlabel(mainhandles,'correctionAx4'))
        
        % Append avg. factor value
        if choice==1 ...
                && mainhandles.settings.correctionfactorplot.factorchoice~=3 ...
                && mainhandles.settings.correctionfactorplot.plotfactorvalue
            
            hold(ax4,'on')
            xlims = get(ax4,'xlim');
            ylims = get(ax4,'ylim');
            
            plot(ax4,[min(x) max(x)],[val val],'-r')
            
            xlim(ax4,xlims)
            ylim(ax4,ylims)
            hold(ax4,'off')
        end
        
        if strcmp(get(get(ax4,'xlabel'),'string'),'')
            xlabel(ax4,'Time /frame')
        end
        set(ax4, 'XTickLabelMode','auto')
        
        initAxes([ax4]);
        
        ylimAx4 = get(ax4,'ylim');
        
        plotZerolines(ax4, [0 0])
        zoom(ax4,'reset')
        if choice~=1
            plotZerolines(ax4, [1 1])
            ylim(ax4,[-0.1 1.1])
        end
        
        hold(ax4,'off')
    end

    function setFactorLabel(ax,lab)
        % Set label according to which correction factor is being plotted
        if mainhandles.settings.correctionfactorplot.factorchoice == 1 % Donor leakage pairs
            set(get(ax,lab),'String','D leakage factor')
        elseif mainhandles.settings.correctionfactorplot.factorchoice == 2 % Direct A pairs
            set(get(ax,lab),'String','Direct A factor')
        elseif mainhandles.settings.correctionfactorplot.factorchoice == 3 % Gamma factor pairs
            set(get(ax,lab),'String','Gamma factor')
        end
    end

end

function clearAxes(correctionfactorwindowHandles)
% Clears all axes
cla(correctionfactorwindowHandles.DDtraceAxes)
cla(correctionfactorwindowHandles.ADtraceAxes)
cla(correctionfactorwindowHandles.AAtraceAxes)
cla(correctionfactorwindowHandles.ax4)
cla(correctionfactorwindowHandles.HistAxes)
set(correctionfactorwindowHandles.meanValueCounter,'String','')
end
