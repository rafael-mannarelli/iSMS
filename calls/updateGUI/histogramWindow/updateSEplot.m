function mainhandles = updateSEplot(mainhandle,FRETpairwindowHandle,histogramwindowHandle, choice, binonly, bayesian, densityplotON)
% Updates the plot in the histogramwindow GUI
%
%    Input:
%     mainhandle            - handle to main GUI window (sms)
%     FRETpairwindowHandle  - handle to the FRET-pair GUI window
%     histogramwindowHandle - handle to the histogram GUI window
%     choice                - 'Shist', 'Ehist', 'SEplot', 'all'. Chooses
%                             which axes to update
%     binonly               - 0/1. If 1 only the histogram bin-sizes are
%                             updated
%     bayesian              - 0 or 1. Is 1 if function is being called
%                             after Gaussian analysis (so that fit is
%                             already obtained)
%     densityplotON         - 0/1. If 0 density scatter plot will be turned
%                             off (default, because density plot is slow)
%
%    Output:
%     mainhandles           - handles structure of the main window
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

if ~isempty(mainhandle) && ishandle(mainhandle)
    mainhandles = guidata(mainhandle);
else
    mainhandles = guidata(getappdata(0,'mainhandle'));
    return
end

% Set defaults
if nargin<2 || isempty(FRETpairwindowHandle)
    FRETpairwindowHandle = mainhandles.FRETpairwindowHandle;
end
if nargin<3 || isempty(histogramwindowHandle)
    histogramwindowHandle = mainhandles.histogramwindowHandle;
end
if nargin<4 || isempty(choice)
    choice = 'all';
end
if nargin<5 || isempty(binonly)
    binonly = 0;
end
if nargin<6 || isempty(bayesian)
    bayesian = 0;
end
if nargin<7 || isempty(densityplotON)
    densityplotON = 0;
end

% Check if inputs are handles to the GUI windows
if (isempty(mainhandle)) || (isempty(FRETpairwindowHandle)) || (isempty(histogramwindowHandle))...
        || (~ishandle(mainhandle)) || (~ishandle(FRETpairwindowHandle)) || (~ishandle(histogramwindowHandle))
    mainhandles = guidata(getappdata(0,'mainhandle'));
    return
end

% Get all handles structures
mainhandles = guidata(mainhandle); % Handles to the main GUI window (sms)
FRETpairwindowHandles = guidata(FRETpairwindowHandle); % Handles to the FRET pair window
histogramwindowHandles = guidata(histogramwindowHandle); % Handles to the FRET pair window

% Shorten axes handle
SEax = histogramwindowHandles.SEplot;

% Excitation scheme
alex = mainhandles.settings.excitation.alex;

% If there is no data, clear all axes and return
if (isempty(mainhandles.data))
    cla(SEax),  cla(histogramwindowHandles.Ehist),  cla(histogramwindowHandles.Shist)
    set(histogramwindowHandles.frameCounter, 'String',0)
    set(histogramwindowHandles.moleculeCounter, 'String',0)
    return
end

% Pairs to plot
selectedPairs = getPairs(mainhandle, 'Plotted', [], FRETpairwindowHandle, histogramwindowHandle);

% Update molecule counter
if alex
    set(histogramwindowHandles.moleculeCounter, 'String',size(selectedPairs,1))
else
    set(histogramwindowHandles.moleculeCounter, 'String',sprintf('Molecules in plot: %i',size(selectedPairs,1)))
end

% If there are no FRET-pairs in any of the selected files, clear all axes
% and return
if isempty(selectedPairs)
    cla(SEax),  cla(histogramwindowHandles.Ehist),  cla(histogramwindowHandles.Shist)
    set(histogramwindowHandles.frameCounter, 'String',0)
    return
end

%% Get data for SE scatter

Gaussians = []; % Data to be plotted in SEplot
if bayesian % If function is being called after Bayesian Gaussian mixture analysis, use distribution fitted by the analysis
    Gaussians = mainhandles.settings.SEplot.Gaussians;
    
elseif (~bayesian) && ((strcmp(choice,'SEplot'))  || (strcmp(choice,'all'))) % If regular SE-plot
    cla(SEax)
    
    % Put traces of selected pairs into temporary structure for a better
    % code overview
    if mainhandles.settings.SEplot.valuesplotted==1
        
        % Plot all frames
        traces = getTraces(mainhandle,selectedPairs,'SEplot');
    else
        
        % Plot average values
        [mainhandles traces] = getSEdata(mainhandles,selectedPairs,mainhandles.settings.SEplot.valuesplotted);
    end
    
    % Store plotted trace-data (used in some of the old functions)
    mainhandles.settings.SEplot.traces = traces;
    
    %---------------------------------------%
    
    % Make an initial plot, which is possibly used by FitGaussian below,
    % reset axis limits and put scatter data in Gaussian structure for
    % re-plotting again below
    if alex
        Etrace = [traces(:).E]; % Denotes the combined E/PR coordinates of the pairs to be plotted
        Strace = [traces(:).S]; % Denotes the combined S/Scorr coordinates of the pairs to be plotted
        plot(SEax,Etrace,Strace,'.','MarkerSize',mainhandles.settings.SEplot.markersize)
        xlim(SEax, mainhandles.settings.SEplot.xlim)
        ylim(SEax, mainhandles.settings.SEplot.ylim)
        Gaussians = struct('x',Etrace,'y',Strace,'color',mainhandles.settings.SEplot.colorOrder(1)); % Put scatter data in components structure for later plotting, if
    end
    
    % Update handles structure
    mainhandles.settings.SEplot.Gaussians(:) = []; % Reset Gaussians stored in the handles structure
    updatemainhandles(mainhandles)
end

%% Plot

if alex
    % Update SE 2D plot in ALEX
    mainhandles = updateALEXplot(mainhandles);
else
    % Update 1D E plot in single-color excitation
    mainhandles = updateSCplot(mainhandles);
end

% Update frame counter
updateSEframecounter(histogramwindowHandles)

%% Nested

    function mainhandles = updateALEXplot(mainhandles)
        % Updates plot for ALEX excitation scheme
        
        %% Plot SE scatter and/or surf
        
        % Limits
        xlimSE = mainhandles.settings.SEplot.xlim; %get(SEax,'xlim');
        ylimSE = mainhandles.settings.SEplot.ylim; %get(SEax,'ylim');
        
        if ~isempty(Gaussians) % If Gaussians structure is empty here it means that function was called only for updating the histograms
            % Turn off density plot if not chosen deliberately
            if ~densityplotON && mainhandles.settings.SEplot.SEplotType==2
                mainhandles.settings.SEplot.SEplotType = 1;
                updatemainhandles(mainhandles)
            end
            
            cla(SEax)
            
            % For inverse S plot
            if mainhandles.settings.SEplot.inverseS
                for i = 1:length(Gaussians)
                    Gaussians(i).y = 1./Gaussians(i).y;
                end
            end
            
            % Only use points inside axes limits
            for i = 1:length(Gaussians)
                % Get points inside axes limits
                x = Gaussians(i).x;
                y = Gaussians(i).y;
                idx = x>xlimSE(1) & x<xlimSE(2) & y>ylimSE(1) & y<ylimSE(2);
                
                Gaussians(i).x = Gaussians(i).x(idx);
                Gaussians(i).y = Gaussians(i).y(idx);
            end
            
            if (strcmp(mainhandles.settings.SEplot.ScatOrSurf,'scat')) || (strcmp(mainhandles.settings.SEplot.ScatOrSurf,'both'))
                
                % Plot scatter according to plot type
                if mainhandles.settings.SEplot.SEplotType == 1 % If regular plot
                    for i = 1:length(Gaussians)
                        
                        % Color of cluster
                        if mainhandles.settings.SEplot.GaussColorChoiceSE
                            gausscolor = Gaussians(i).color;
                        else
                            gausscolor = Gaussians(1).color;
                        end
                        
                        %                         % Get points inside axes limits
                        %                         x = Gaussians(i).x;
                        %                         y = Gaussians(i).y;
                        %                         idx = x>xlimSE(1) & x<xlimSE(2) & y>ylimSE(1) & y<ylimSE(2);
                        
                        % Plot
                        plot(SEax,Gaussians(i).x, Gaussians(i).y, ['.' gausscolor],'MarkerSize',mainhandles.settings.SEplot.markersize);
                        hold(SEax,'on')
                    end
                    
                elseif mainhandles.settings.SEplot.SEplotType == 2 % If scatplot
                    
                    % Get all E ans S coordinates
                    E = [Gaussians(:).x]';
                    E = E(:);
                    S = [Gaussians(:).y]';
                    S = S(:);
                    if (~isempty(E)) && (~isempty(S))
                        
                        % Remove data points outside plot range
                        ESall = [E S];
                        %                         ESall(ESall(:,1)<xlimSE(1),:) = [];
                        %                         ESall(ESall(:,2)<ylimSE(1),:) = [];
                        %                         ESall(ESall(:,1)>xlimSE(2),:) = [];
                        %                         ESall(ESall(:,2)>ylimSE(2),:) = [];
                        
                        % Remove points with identical coordinates (these are not
                        % tolerated by scatplot
                        [ESuniq,idxUniq] = unique(ESall,'rows','legacy');
                        
                        % Plot an invisible scatter plot of removed points
                        % so they are included in the histogram plots
                        idxDup = 1:size(ESall,1);
                        idxDup(idxUniq) = []; % Index of duplicate rows
                        plot(SEax,ESall(idxDup,1),ESall(idxDup,2),'.','MarkerFaceColor','none','MarkerEdgeColor','none');
                        
                        
                        % Sample large distributions
                        upthres = 4e4;
                        if size(ESuniq,1)>upthres
                            
                            % Random indices
                            temp = 1:size(ESuniq,1);
                            idx = unique(randi(size(ESuniq,1),upthres,1));
                            temp(idx) = [];
                            
                            % Plot invisible plot
                            if ~isempty(temp)
                                hold(SEax,'on')
                                plot(SEax,ESuniq(temp,1),ESuniq(temp,2),'.','MarkerFaceColor','none','MarkerEdgeColor','none');
                            end
                            
                            % Sample
                            ESuniq = ESuniq(idx,:);
                        end
                        
                        % Hold on
                        axes(SEax) % Set as current axes
                        hold(SEax,'on')
                        
                        % Color map
                        colmap = eval( lower(mainhandles.settings.SEplot.colormap) ); % Returns colormap array (mx3). lower converts HSV (from older iSMS versions) to hsv
                        if mainhandles.settings.SEplot.colorinversion
                            colmap = flipud(colmap);
                        end
                        %                 colormap(SEax, colmap);
                        
                        % Plot density scatter
                        out = scatplot(ESuniq(:,1),ESuniq(:,2),[],[],[],[],[],mainhandles.settings.SEplot.markersize,colmap,SEax); % out = scatplot(x,y,method,radius,N,n,po,ms)
                        
                        %                         mamamamamamama=max(max(ESuniq))
                        %                         mininininini=min(min(ESuniq))
                        %                         figure
                        %                         plot(ESuniq(:,1),ESuniq(:,2),'.')%,'MarkerFaceColor','red','MarkerEdgeColor','none')
                        %                         updateUIcontextMenus(mainhandles.figure1,gca)
                    end
                    
                elseif mainhandles.settings.SEplot.SEplotType == 3 % If smoothhist2D plot
                    
                    % Get all E and S coordinates
                    E = [Gaussians(:).x];
                    E = E(:);
                    S = [Gaussians(:).y];
                    S = S(:);
                    if (~isempty(E)) && (~isempty(S))
                        axes(SEax)
                        
                        %                         % Remove data points outside plot range
                        %                         ES = [E S];
                        %                         ES(ES(:,1)<xlimSE(1),:) = [];
                        %                         ES(ES(:,1)>xlimSE(2),:) = [];
                        %                         ES(ES(:,2)<ylimSE(1),:) = [];
                        %                         ES(ES(:,2)>ylimSE(2),:) = [];
                        
                        % Remove data points outside plot range
                        ESall = [E S];
                        %                         ESall(ESall(:,1)<xlimSE(1),:) = [];
                        %                         ESall(ESall(:,2)<ylimSE(1),:) = [];
                        %                         ESall(ESall(:,1)>xlimSE(2),:) = [];
                        %                         ESall(ESall(:,2)>ylimSE(2),:) = [];
                        
                        smoothhist2D(ESall, 5, [110, 110],0) % smoothhist2D(X,lambda,nbins,outliercutoff,plottype)
                        
                        % Check that produced image covers entire SE plot axes range
                        [x,y,A] = getimage(SEax); % Get the image plotted by smoothhist2D
                        xstep = (max(x)-min(x))/(length(x)-1); % X step size of image
                        ystep = (max(y)-min(y))/(length(y)-1); % Y step size of image
                        replot = 0; % Determines if replotting image is necessary
                        
                        if min(x) > xlimSE(1) % Expand image in negative x-direction
                            xextra = min(x)-xstep:-xstep:xlimSE(1); % X-range from image limits to x = -0.1
                            x = [fliplr(xextra) x]; % Increase image x-range in the negative direction
                            A = [zeros(size(A,1),length(xextra)) A]; % Insert zeros in image
                            replot = 1; % Tell to replot image
                        end
                        
                        if max(x) < xlimSE(2) % Expand image in positive x-direction
                            xextra = max(x)+xstep:xstep:xlimSE(2); % X-range from image limits to x = 1.1
                            x = [x xextra]; % Increase image x-range in the positive direction
                            A = [A zeros(size(A,1),length(xextra))]; % Insert zeros in image
                            replot = 1; % Tell to replot image
                        end
                        
                        if min(y) > ylimSE(1) % Expand image in negative y-direction
                            yextra = min(y)-ystep:-ystep:ylimSE(1); % Y-range from image limits to y = -0.1
                            y = [fliplr(yextra) y]; % Increase image y-range in the negative direction
                            A = [zeros(length(yextra),size(A,2)); A]; % Insert zeros in image
                            replot = 1; % Tell to replot image
                        end
                        
                        if max(y) < ylimSE(2) % Expand image in positive y-direction
                            yextra = max(y)+ystep:ystep:ylimSE(2); % Y-range from image limits to y = 1.1
                            y = [y yextra]; % Increase image y-range in the positive direction
                            A = [A; zeros(length(yextra),size(A,2))]; % Insert zeros in image
                            replot = 1; % Tell to replot image
                        end
                        
                        % Replot smoothed scatter image expanded with zeros in entire plot rang
                        if replot
                            cla(SEax)
                            image(x,y,A)
                        end
                        set(gca,'YDir','normal') % Ensure that y-axis goes from negative to positive
                        
                        % Plot an invisible scatter plot needed to make the histograms
                        hold(SEax,'on')
                        for i = 1:length(Gaussians)
                            plot(SEax,Gaussians(i).x,Gaussians(i).y,'.','MarkerFaceColor','none','MarkerEdgeColor','none');
                        end
                        
                        % Set color map
                        colmap = eval( lower(mainhandles.settings.SEplot.colormap) ); % Returns colormap array (mx3)
                        if mainhandles.settings.SEplot.colorinversion
                            colmap = flipud(colmap);
                        end
                        colormap(SEax, colmap);
                        
                    end
                    
                end
                hold(SEax,'off')
            end
            
            % Update axes limits and labels
            
            % Plot properties
            if mainhandles.settings.SEplot.inverseS % Inverse S plot
                ylabel(SEax,'1/Stoichiometry (1/S)')
                ylim(SEax,[0.9 19])
                %         ylimSE = [1/-0.1 1/1.1]; % Rescale y-axis
            else
                ylabel(SEax,'Stoichiometry (S)')
                ylim(SEax,ylimSE)
            end
            xlabel(SEax,'FRET efficiency (E)')
            xlim(SEax,xlimSE)
            
        end
        
        %% Update histograms
        
        if (strcmp(choice,'Ehist'))  || (strcmp(choice,'all'))
            
            % Update E histogram
            updatehistax(mainhandles,histogramwindowHandles,'Ehist',binonly)
        end
        
        if (strcmp(choice,'Shist'))  || (strcmp(choice,'all'))
            
            % Update S histogram
            updatehistax(mainhandles,histogramwindowHandles,'Shist',binonly)
        end
        
        if (strcmp(choice,'Ehist') || strcmp(choice,'Shist') || strcmp(choice,'all')) && ~binonly
            mainhandles.settings.SEplot.EGaussians(:) = [];
            mainhandles.settings.SEplot.SGaussians(:) = [];
            updatemainhandles(mainhandles)
            
            % Update Gaussian components window
            updateGaussianComponentsWindow(mainhandle,histogramwindowHandle,mainhandles.GaussianComponentsWindowHandle)
        end
        
        % Update context menus for axes
        updateUIcontextMenus(mainhandle,SEax)
        
    end

    function mainhandles = updateSCplot(mainhandles)
        
        % Get data now, if calling from bin slider
        if binonly
            traces = getTraces(mainhandle,selectedPairs,'SEplot');
        end
        
        % All data to plot
        data = [traces(:).E]; % Denotes the combined E/PR coordinates of the pairs to be plotted
        
        % Clear ax if there are no plotted data points
        if isempty(data)
            cla(histogramwindowHandles.Ehist)
            return
        end
        
        % Shorten handles and settings
        SEax = histogramwindowHandles.SEplot;
        
        ax = histogramwindowHandles.Ehist;
        plotfit = mainhandles.settings.SEplot.plotEfit;
        plotfitTot = mainhandles.settings.SEplot.plotEfitTot;
        
        sliderHandle = histogramwindowHandles.EbinsizeSlider;
        bintextboxHandle = histogramwindowHandles.EbinsTextbox;
        binsize = mainhandles.settings.SEplot.lockEbinsize;
        
        nticks = mainhandles.settings.SEplot.EhistTicks;
        nBins = get(sliderHandle,'Value');
        
        % If function was called from one of the bin-sliders, extract
        % distribution fits in order to plot them again after update
        if (plotfit || plotfitTot) && binonly
            h = findobj(ax,'type','line');
            linecolors = cell(1);
            linexs = cell(1);
            lineys = cell(1);
            for i = 1:length(h)
                linecolors{i,1} = get(h(i),'color');
                linexs{i,1} = get(h(i),'xdata');
                lineys{i,1} = get(h(i),'ydata');
            end
            delete(h) % Remove any previous fits
        end
        if ~binonly
            cla(ax);
        end
        
        % Cut data outside limits
        limE = mainhandles.settings.SEplot.xlim;
        data(data < limE(1)) = [];
        data(data > limE(2)) = [];
        if isempty(data) % If there are no remaining data points
            cla(histogramwindowHandles.Ehist)
            return
        end
        
        % Calculate histogram
        if length(binsize)==1
            
            bins = min(data(:)):binsize:max(data(:)); % Bin centers are evenly distributed
            [n,xout] = hist(data,bins); % n is frequency of bin centred at xout
            
            % Update bin slider value
            nBins = length(bins); % Number of bins
            if nBins>100
                set(sliderHandle,'Value',100)
            else
                set(sliderHandle,'Value',nBins)
            end
            
        else
            [n,xout] = hist(data,nBins); % n is frequency of bin centred at xout
            binsize = mean(diff(xout(:))); % Bin size
        end
        
        % Plot histogram
        if mainhandles.settings.SEplot.plotBins
            
            % VERSION DEPENDENT SYNTAX
            if mainhandles.matver>8.3
                b = bar(ax,xout,n,'hist'); % Same as hist(histogramwindowHandles.Shist,y,nBins)
            else
                b = bar(ax,xout,n,'style','hist'); % Same as hist(histogramwindowHandles.Shist,y,nBins)
            end
            
            % Bar colors
            set(b,...
                'EdgeColor',mainhandles.settings.SEplot.binEdgeColor,...
                'FaceColor',mainhandles.settings.SEplot.binFaceColor)
        end
        
        % Update bin info textbox
        if mainhandles.settings.SEplot.showbins
            if mainhandles.settings.SEplot.showbinsType==1
                set(bintextboxHandle, 'Visible','on', 'String',sprintf('Bins: %i ',nBins))
            elseif mainhandles.settings.SEplot.showbinsType==2
                set(bintextboxHandle, 'Visible','on', 'String',sprintf('Bin width: %.4f ',binsize) )
            end
        end
        
        % Save bin size in userdata so it can be extracted when locking binsize
        set(sliderHandle,'UserData',binsize)
        
        % Re-plot distribution fit in E-hist if function is called from
        % binslider
        hold(ax,'on')
        if plotfit && binonly % Re-plot distributions
            
            for i = 1:size(linecolors,1)
                x = linexs{i}(:);
                y = lineys{i}(:);
                color = linecolors{i};
                plot(ax,x,y,'color',color,'linewidth',2)
            end
        end
        hold(ax,'off')
        
        %---- Axes properties ----%
        xlim(ax,mainhandles.settings.SEplot.xlim) % Set x-limits of the S-histogram equal to the y-limits of the SE-plot
        ylimhist = get(ax,'ylim');
        %         if limSE(2)<=1 && ylimhist(2)>1
        %     ylim(ax,[1 ylimhist(2)])
        % end
        set(ax, 'YTick', linspace(ylimhist(1),ylimhist(2),nticks)) % Number of tick marks
        ylabel(ax,getYlabel(mainhandles,'Ehist'))
        xlabel(ax,getXlabel(mainhandles,'Ehist'))
        
        % Update context menus for axes
        updateUIcontextMenus(mainhandles.figure1,[ax b])
        
    end

end

function updatehistax(mainhandles,histogramwindowHandles,choice,binonly)
% Updates histogram axes
%
%    Input:
%     choice   - 'Ehist', 'Shist'

% Shorten axes handle
SEax = histogramwindowHandles.SEplot;

% Axes dependent settings:
if strcmpi(choice,'Ehist')
    
    ax = histogramwindowHandles.Ehist;
    plotfit = mainhandles.settings.SEplot.plotEfit;
    plotfitTot = mainhandles.settings.SEplot.plotEfitTot;
    
    sliderHandle = histogramwindowHandles.EbinsizeSlider;
    bintextboxHandle = histogramwindowHandles.EbinsTextbox;
    binsize = mainhandles.settings.SEplot.lockEbinsize;
    
    nticks = mainhandles.settings.SEplot.EhistTicks;
    
elseif strcmpi(choice,'Shist')
    
    ax = histogramwindowHandles.Shist;
    plotfit = mainhandles.settings.SEplot.plotSfit;
    plotfitTot = mainhandles.settings.SEplot.plotSfitTot;
    
    sliderHandle = histogramwindowHandles.SbinsizeSlider;
    bintextboxHandle = histogramwindowHandles.SbinsTextbox;
    binsize = mainhandles.settings.SEplot.lockSbinsize;
    
    nticks = mainhandles.settings.SEplot.ShistTicks;
end

% If function was called from one of the bin-sliders, extract
% distribution fits in order to plot them again after update
if (plotfit || plotfitTot) && binonly
    h = findobj(ax,'type','line');
    linecolors = cell(1);
    linexs = cell(1);
    lineys = cell(1);
    for i = 1:length(h)
        linecolors{i,1} = get(h(i),'color');
        linexs{i,1} = get(h(i),'xdata');
        lineys{i,1} = get(h(i),'ydata');
    end
    delete(h) % Remove any previous fits
end
if ~binonly
    cla(ax);
end

% Get number of bins from the slider
nBins = get(sliderHandle,'Value');

% Get data from SEplot
h = findobj(SEax,'type','line');
if strcmpi(choice,'Ehist')
    data = get(h,'xdata');
    limSE = get(SEax,'xlim');
else
    data = get(h,'ydata');
    limSE = get(SEax,'ylim');
end

% If there are no plotted data points
if isempty(data)
    cla(histogramwindowHandles.Ehist)
    cla(histogramwindowHandles.Shist)
    return
elseif size(data,1)>1 % If there is more than one data-set plotted (e.g. Gaussian mixture)
    data = [data{:}];
end

% Remove points outside the SEplot limits
data(data < limSE(1)) = [];
data(data > limSE(2)) = [];
if isempty(data) % If there are remaining data points
    return
end

% Calculate histogram
if length(binsize)==1
    
    bins = min(data(:)):binsize:max(data(:)); % Bin centers are evenly distributed
    [n,xout] = hist(data,bins); % n is frequency of bin centred at xout
    
    % Update bin slider value
    nBins = length(bins); % Number of bins
    if nBins>100
        set(sliderHandle,'Value',100)
    else
        set(sliderHandle,'Value',nBins)
    end
    
else
    [n,xout] = hist(data,nBins); % n is frequency of bin centred at xout
    binsize = mean(diff(xout(:))); % Bin size
end

% Plot histogram
if mainhandles.settings.SEplot.plotBins
    
    % VERSION DEPENDENT BAR SYNTAX
    if mainhandles.matver>8.3
        b = bar(ax,xout,n,'hist'); % Same as hist(histogramwindowHandles.Shist,y,nBins)
    else
        b = bar(ax,xout,n,'style','hist'); % Same as hist(histogramwindowHandles.Shist,y,nBins)
    end
    
    % Set bar colors
    set(b,...
        'EdgeColor',mainhandles.settings.SEplot.binEdgeColor,...
        'FaceColor',mainhandles.settings.SEplot.binFaceColor)
end

% Update bin info textbox
if mainhandles.settings.SEplot.showbins
    if mainhandles.settings.SEplot.showbinsType==1
        set(bintextboxHandle, 'Visible','on', 'String',sprintf('%i ',nBins))
    elseif mainhandles.settings.SEplot.showbinsType==2
        set(bintextboxHandle, 'Visible','on', 'String',sprintf('%.4f ',binsize) )
    end
end

% Save bin size in userdata so it can be extracted when locking binsize
set(sliderHandle,'UserData',binsize)

% Re-plot distribution fit in E-hist if function is called from
% binslider
hold(ax,'on')
if plotfit && binonly % Re-plot distributions
    
    for i = 1:size(linecolors,1)
        x = linexs{i}(:);
        y = lineys{i}(:);
        color = linecolors{i};
        plot(ax,x,y,'color',color,'linewidth',2)
    end
end
hold(ax,'off')

%---- Axes properties ----%
xlim(ax,limSE) % Set x-limits of the S-histogram equal to the y-limits of the SE-plot
ylimhist = get(ax,'ylim');
if limSE(2)<=1 && ylimhist(2)>1
    ylim(ax,[1 ylimhist(2)])
end
set(ax, 'YTick', linspace(ylimhist(1),ylimhist(2),nticks)) % Number of tick marks
set(ax,'XtickLabel','') % Remove tick labels from the S-hist

% Rotate s-hist axes
if strcmpi(choice,'Shist')
    view(histogramwindowHandles.Shist,90,-90) % Rotate the S-hist plot
end

% Update context menus for axes
updateUIcontextMenus(mainhandles.figure1,ax)

end