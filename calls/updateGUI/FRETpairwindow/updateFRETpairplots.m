function [FRETpairwindowHandles,mainhandles] = updateFRETpairplots(mainhandle, FRETpairwindowHandle, AxChoice, TraceChoice, ImageChoice)
% Updates the intensity traces and images of the selected FRET pair in the
% FRET-pair GUI window.
%
%     Input:
%      mainhandle            - handle to main GUI window (sms)
%      FRETpairwindowHandle  - handle to the FRET-pair GUI window
%      AxChoice              - 'traces' 'images' or 'all'
%      TraceChoice           - 'all' or 'ADcorrect'
%      ImageChoice           - 'DD', 'AD', 'AA', 'all'
%
%     Output:
%      FRETpairwindowHandles - handles structure of the FRETpair window
%      mainhandles           - handles structure of the main window
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

if nargin<3
    AxChoice = 'all';
end
if (nargin<4) || (isempty(TraceChoice))
    TraceChoice = 'all';
end
if (nargin<5) || (isempty(ImageChoice))
    ImageChoice = 'all';
end

% Get mainhandles
if isempty(mainhandle) || ~ishandle(mainhandle)
    error('hejh')
    [mainhandles, FRETpairwindowHandles] = justreturn();
    return
end
mainhandles = guidata(mainhandle);

% Default handle to FRET pair window
if nargin<2
    FRETpairwindowHandle = mainhandles.FRETpairwindowHandle;
end

% Get FRETpair window handles
if isempty(FRETpairwindowHandle) || ~ishandle(FRETpairwindowHandle)
    [mainhandles, FRETpairwindowHandles] = justreturn();
    return
end
FRETpairwindowHandles = guidata(FRETpairwindowHandle);

%% Initialize data and axes

% Get filechoice and pairchoice
selectedPairs = getPairs(mainhandle, 'Selected', [], FRETpairwindowHandle); % Returns selection in [file pair;...]

% Shorten axes names
DDtraceAxes = FRETpairwindowHandles.DDtraceAxes;
ADtraceAxes = FRETpairwindowHandles.ADtraceAxes;
AAtraceAxes = FRETpairwindowHandles.AAtraceAxes;
StraceAxes = FRETpairwindowHandles.StraceAxes;
PRtraceAxes = FRETpairwindowHandles.PRtraceAxes;

DDimageAxes = FRETpairwindowHandles.DDimageAxes;
ADimageAxes = FRETpairwindowHandles.ADimageAxes;
AAimageAxes = FRETpairwindowHandles.AAimageAxes;

% Excitation scheme
alex = mainhandles.settings.excitation.alex;

% If there is no FRET-pair or there is more than one FRET-pair selected, clear all axes
if (isempty(mainhandles.data)) || (isempty(selectedPairs)) || (size(selectedPairs,1)~=1)
    cla(DDtraceAxes),  cla(ADtraceAxes),  cla(AAtraceAxes),  cla(StraceAxes),
    cla(PRtraceAxes),  cla(DDimageAxes),  cla(ADimageAxes),  cla(AAimageAxes)
    set(FRETpairwindowHandles.paircoordinates,'String','(-, -)')
    set(FRETpairwindowHandles.confidenceValueTextBox,'String','-')
    set(FRETpairwindowHandles.aggregatedValueTextBox,'String','-')
    set(FRETpairwindowHandles.dynamicValueTextBox,'String','-')
    set(FRETpairwindowHandles.noisyValueTextBox,'String','-')
    set(FRETpairwindowHandles.scrambledValueTextBox,'String','-')
    set(FRETpairwindowHandles.staticValueTextBox,'String','-')
    
    FRETpairwindowHandles.DframeSliderHandle = [];
    FRETpairwindowHandles.AframeSliderHandle = [];
    FRETpairwindowHandles.AAframeSliderHandle = [];
    guidata(FRETpairwindowHandle,FRETpairwindowHandles)
    
    return
end

% Pair to plot
file = selectedPairs(:,1);
pair = selectedPairs(:,2);

% Intensity traces
if mainhandles.settings.FRETpairplots.plotDgamma
    gamma = getGamma(mainhandles,selectedPairs);
    DDtrace = mainhandles.data(file).FRETpairs(pair).DDtrace*gamma;
else
    DDtrace = mainhandles.data(file).FRETpairs(pair).DDtrace;
end
if mainhandles.settings.FRETpairplots.plotADcorr
    ADtrace = mainhandles.data(file).FRETpairs(pair).ADtraceCorr;
else
    ADtrace = mainhandles.data(file).FRETpairs(pair).ADtrace;
end
ADtraceCorr = mainhandles.data(file).FRETpairs(pair).ADtraceCorr;
AAtrace = mainhandles.data(file).FRETpairs(pair).AAtrace;

% Background
DDback = mainhandles.data(file).FRETpairs(pair).DDback;
ADback = mainhandles.data(file).FRETpairs(pair).ADback;
AAback = mainhandles.data(file).FRETpairs(pair).AAback;

% S and E
StraceCorr = mainhandles.data(file).FRETpairs(pair).StraceCorr;
Etrace = mainhandles.data(file).FRETpairs(pair).Etrace;

%% Update axes

% Plot intensity traces
if strcmp(AxChoice,'traces') || strcmp(AxChoice,'all')...
        || (strcmpi(TraceChoice,'ADcorrect') && mainhandles.settings.FRETpairplots.plotADcorr)
    
    % Make x-data vector
    xD = getTimeVector(mainhandles,selectedPairs,'D');
    if isempty(xD)
        xD = 1:length(DDtrace);
    end
    xA = getTimeVector(mainhandles,selectedPairs,'A');
    if isempty(xA)
        xA = 1:length(AAtrace);
    end
    
    if strcmpi(TraceChoice,'all')...
            || (strcmpi(TraceChoice,'ADcorrect') && mainhandles.settings.FRETpairplots.plotADcorr)
        
        % Update intensity traces
        
        % Trace colors
        if mainhandles.settings.FRETpairplots.DAtraceColor % If plotting donor and acceptor in different colors
            Dcolor = 'green';
            Acolor = 'red';
        else % If plotting in same colors
            Dcolor = 'blue';
            Acolor = 'blue';
        end
        
        % Plot A & D traces
        if mainhandles.settings.FRETpairplots.plotBackground==0
            
            % Plot background-corrected traces only
            plotTrace(DDtraceAxes,xD,{DDtrace},{Dcolor}) % DD trace
            plotTrace(ADtraceAxes,xD,{ADtrace},{Acolor}) % AD trace
            
            if alex
                plotTrace(AAtraceAxes,xA,{AAtrace},{Acolor}) % AA trace
            end
            
        elseif mainhandles.settings.FRETpairplots.plotBackground==1
            
            % Plot raw traces + background
            plotTrace(DDtraceAxes,xD,{DDtrace+DDback DDback},{Dcolor mainhandles.settings.FRETpairplots.backgroundColor})
            plotTrace(ADtraceAxes,xD,{ADtrace+ADback ADback},{Acolor mainhandles.settings.FRETpairplots.backgroundColor})
            
            if alex
                plotTrace(AAtraceAxes,xA,{AAtrace+AAback AAback},{Acolor mainhandles.settings.FRETpairplots.backgroundColor})
            end
            
        elseif mainhandles.settings.FRETpairplots.plotBackground==2
            
            % Plot background traces only
            plotTrace(DDtraceAxes,xD,{DDback},{mainhandles.settings.FRETpairplots.backgroundColor}) % DD trace
            plotTrace(ADtraceAxes,xD,{ADback},{mainhandles.settings.FRETpairplots.backgroundColor}) % AD trace
            
            if alex
                plotTrace(AAtraceAxes,xA,{AAback},{mainhandles.settings.FRETpairplots.backgroundColor}) % AA trace
            end
        end
        
        % In single-color excitation, plot overlay in ax3 and sum in ax4
        if ~alex
            
            % Normalize traces
            yD = DDtrace-min(min(DDtrace));
            yA = ADtrace-min(min(ADtrace));
            yD = yD/max(max(yD));
            yA = yA/max(max(yA));
            
            % Plot overlay
            plotTrace(AAtraceAxes,xD,{yD,yA},{'green','red'})
            
            % Plot sum
            gamma = getGamma(mainhandles,selectedPairs);
            plotTrace(StraceAxes,xD,{DDtrace*gamma+ADtraceCorr},{'blue'})
            
        end
        
        % Axis limits
        if mainhandles.settings.FRETpairplots.autozoom
            
            % Autozoom axis
            axis([DDtraceAxes ADtraceAxes AAtraceAxes],'tight','manual')
            
            if ~alex
                axis(StraceAxes,'tight','manual')
            end
        end
        
        % Axis labels
        setYLabel(DDtraceAxes,getYlabel(mainhandles,'FRETpairwindowAx1'))
        setYLabel(ADtraceAxes,getYlabel(mainhandles,'FRETpairwindowAx2'))
        setYLabel(AAtraceAxes,getYlabel(mainhandles,'FRETpairwindowAx3'))
        
    end
    
    % In ALEX, plot stoichiometry in ax4
    if alex
        
        plotTrace(StraceAxes,xD,{StraceCorr}, {'b'}) % DD trace
        try
            zoom(StraceAxes, 'reset')
            ylim(StraceAxes,mainhandles.settings.FRETpairplots.Sylim)
        end
    end
    
    % Ax 4 y-label
    setYLabel(StraceAxes,getYlabel(mainhandles,'FRETpairwindowAx4'))
    
    % FRET trace
    plotTrace(PRtraceAxes,xD,{Etrace}, {'b'}) % DD trace
    setYLabel(PRtraceAxes,'E')
    set(PRtraceAxes, 'XTickLabelMode','auto')
    if strcmp(get(get(PRtraceAxes,'xlabel'),'string'),'')
        xlabel(PRtraceAxes, getTimeLabel(mainhandles, selectedPairs))
    end
    try
        zoom(StraceAxes, 'reset')
        ylim(PRtraceAxes,mainhandles.settings.FRETpairplots.Eylim)
    end
    
    % Plot ref-lines
    if mainhandles.settings.FRETpairplots.zeroline
        plotzeroLine(DDtraceAxes, [0 0])
        plotzeroLine(ADtraceAxes, [0 0])
        
        if alex
            plotzeroLine(AAtraceAxes, [0 0])
            plotzeroLine(StraceAxes, [1 1])
        end
        
        plotzeroLine(StraceAxes, [0 0])
        plotzeroLine(PRtraceAxes, [0 0])
        plotzeroLine(PRtraceAxes, [1 1])
    end
    
    % Update highlighted time-interval of interest
    plotTimeIntervalOfInterest(mainhandle,FRETpairwindowHandle)
    
    % Update ui context menus
    updateUIcontextMenus(mainhandle, [DDtraceAxes ADtraceAxes AAtraceAxes StraceAxes PRtraceAxes]);
    
end

%         % SP TEMPORARY LIMITS
%         ylim(DDtraceAxes,[0 3300])
%         ylim(ADtraceAxes,[0 5800])
%         ylim(AAtraceAxes,[0 3800])
%     % Update highlighted time-interval of interest
%     plotTimeIntervalOfInterest(mainhandle,FRETpairwindowHandle)

%% Update images
if (strcmp(AxChoice,'images')) || (strcmp(AxChoice,'all'))
    
    % Get molecule images
    if ~isempty(mainhandles.data(file).DD_ROImovie) && isempty(mainhandles.data(file).FRETpairs(pair).DD_avgimage)
        % If ROI movie has not been deleted, calculate the molecule images
        mainhandles = calculateMoleculeImages(mainhandle,selectedPairs);
        
    elseif isempty(mainhandles.data(file).DD_ROImovie) && isempty(mainhandles.data(file).FRETpairs(pair).DD_avgimage)
        % If both ROI movie and avg molecule image has been deleted
        
        % Clear if data is empty
        cla(DDimageAxes)
        cla(ADimageAxes)
        cla(AAimageAxes)
        
        FRETpairwindowHandles.DframeSliderHandle = [];
        FRETpairwindowHandles.AframeSliderHandle = [];
        FRETpairwindowHandles.AAframeSliderHandle = [];
        guidata(FRETpairwindowHandle,FRETpairwindowHandles)
        
        return
        
    end
    
    % Stored images
    DD_avg = mainhandles.data(file).FRETpairs(pair).DD_avgimage; % Avg. image of molecule in D emission with D excitations
    AD_avg = mainhandles.data(file).FRETpairs(pair).AD_avgimage; % Avg. image of molecule in A emission with D excitations
    AA_avg = mainhandles.data(file).FRETpairs(pair).AA_avgimage; % Avg. image of molecule in A emission with A excitations
    
    % D and A image ranges
    Dxrange = mainhandles.data(file).FRETpairs(pair).Dxrange;
    Dyrange = mainhandles.data(file).FRETpairs(pair).Dyrange;
    Axrange = mainhandles.data(file).FRETpairs(pair).Axrange;
    Ayrange = mainhandles.data(file).FRETpairs(pair).Ayrange;
    
    % Save x and y range in handles structure. To be used by the pixel
    % selection pointer tool
    set(FRETpairwindowHandles.Toolbar_ShowIntegrationArea,'UserData',{Dxrange, Dyrange, Axrange, Ayrange})
    
    % Round-off difference used to correct image centers later:
    limcorrect = mainhandles.data(file).FRETpairs(pair).limcorrect;
    
    % If D or A is at the edge of the ROI make image smaller
    edges = mainhandles.data(file).FRETpairs(pair).edges;
    
    % DD image
    if strcmpi(ImageChoice,'DD') || strcmpi(ImageChoice,'all')
        
        % Plot molecule image
        [hImg, mainhandles] = imageMolecule(mainhandles,...
            DDimageAxes,...
            DD_avg,...
            limcorrect(1:2),...
            edges(1,:));
        
        % Highlight pixels
        [hInt hBack] = highlightPixels(DDimageAxes, ...
            DD_avg,...
            mainhandles.data(file).FRETpairs(pair).DintMask,...
            mainhandles.data(file).FRETpairs(pair).DbackMask,...
            Dxrange, ...
            Dyrange);
        
        % Store handles
        FRETpairwindowHandles.DDimage = hImg;
        FRETpairwindowHandles.DintMaskHandle = hInt;
        FRETpairwindowHandles.DbackMaskHandle = hBack;
        
    end
    
    % AD image
    if strcmpi(ImageChoice,'AD') || strcmpi(ImageChoice,'all')
        
        % Plot molecule image
        [hImg, mainhandles] = imageMolecule(mainhandles,...
            ADimageAxes,...
            AD_avg,...
            limcorrect(3:4),...
            edges(2,:));
        
        % Highlight pixels
        [hInt hBack] = highlightPixels(ADimageAxes, ...
            AD_avg,...
            mainhandles.data(file).FRETpairs(pair).AintMask,...
            mainhandles.data(file).FRETpairs(pair).AbackMask,...
            Axrange, ...
            Ayrange);
        
        % Store handles
        FRETpairwindowHandles.ADimage = hImg;
        FRETpairwindowHandles.AintMaskHandle = hInt;
        FRETpairwindowHandles.AbackMaskHandle = hBack;
        
    end
    
    % AA image
    if (strcmpi(ImageChoice,'AA') || strcmpi(ImageChoice,'all')) ...
            && ~isempty(AA_avg)
        
        % Plot molecule image
        [hImg, mainhandles] = imageMolecule(mainhandles,...
            AAimageAxes,...
            AA_avg,...
            limcorrect(3:4),...
            edges(2,:));
        
        % Highlight pixels
        [hInt hBack] = highlightPixels(AAimageAxes, ...
            AA_avg,...
            mainhandles.data(file).FRETpairs(pair).AintMask,...
            mainhandles.data(file).FRETpairs(pair).AbackMask,...
            Axrange, ...
            Ayrange);
        
        % Store handles
        FRETpairwindowHandles.AAimage = hImg;
        FRETpairwindowHandles.AintMaskHandle = hInt;
        FRETpairwindowHandles.AbackMaskHandle = hBack;
        
    end
    
    % Disable zooming on images (because donor/acceptor center must be in
    % the center of the image when defining integration range ROI)
    h = zoom(FRETpairwindowHandles.figure1);
    setAllowAxesZoom(h,[DDimageAxes ADimageAxes AAimageAxes],false);
    
    %--- Update handles structure
    guidata(FRETpairwindowHandle,FRETpairwindowHandles)
end

%% Update the pair coordinates textbox

Dxy = mainhandles.data(file).FRETpairs(pair).Dxy; % Position of the donor within the D ROI [x y]
Axy = mainhandles.data(file).FRETpairs(pair).Axy; % Position of the acceptor within the A ROI [x y]
Exy = (Dxy+Axy)/2;
set(FRETpairwindowHandles.paircoordinates,'String',sprintf('(%0.1f, %0.1f)',Exy(1),Exy(2)))

% Update DeepFRET probabilities
if isfield(mainhandles.data(file).FRETpairs(pair),'DeepFRET_probs')
    probs = mainhandles.data(file).FRETpairs(pair).DeepFRET_probs;
    set(FRETpairwindowHandles.confidenceValueTextBox,'String',sprintf('%0.1f %%',100*probs.confidence));
    set(FRETpairwindowHandles.aggregatedValueTextBox,'String',sprintf('%0.1f %%',100*probs.aggregated));
    set(FRETpairwindowHandles.dynamicValueTextBox,'String',sprintf('%0.1f %%',100*probs.dynamic));
    set(FRETpairwindowHandles.noisyValueTextBox,'String',sprintf('%0.1f %%',100*probs.noisy));
    set(FRETpairwindowHandles.scrambledValueTextBox,'String',sprintf('%0.1f %%',100*probs.scrambled));
    set(FRETpairwindowHandles.staticValueTextBox,'String',sprintf('%0.1f %%',100*probs.static));
else
    set(FRETpairwindowHandles.confidenceValueTextBox,'String','-');
    set(FRETpairwindowHandles.aggregatedValueTextBox,'String','-');
    set(FRETpairwindowHandles.dynamicValueTextBox,'String','-');
    set(FRETpairwindowHandles.noisyValueTextBox,'String','-');
    set(FRETpairwindowHandles.scrambledValueTextBox,'String','-');
    set(FRETpairwindowHandles.staticValueTextBox,'String','-');
end

%% Nested

    function plotTrace(ax, x, data, linecolor)
        % Plot trace and set it's uicontextmenu
        for i = 1:length(data)
            if isempty(data{i})
                continue
            end
            
            h = plot(ax, x,data{i}, 'Color',linecolor{i});
            hold(ax,'on')
            
            % UI context menu
            updateUIcontextMenus(mainhandle, h)
        end
        hold(ax,'off')
        
    end

    function plotzeroLine(ax, yval)
        % Plot straight line from yval(1) to yval(2)
        xl = get(ax,'xlim');
        hold(ax, 'on')
        h = plot(ax, xl,yval, '--k');
        hold(ax, 'off')
        
        % UI context menu
        updateUIcontextMenus(mainhandle, h)
    end

    function setYLabel(ax, lab)
        if strcmp(get(get(ax,'ylabel'),'string'),'')
            ylabel(ax,lab, 'Interpreter','tex')
            set(ax, 'XTickLabel','')
        end
    end

    function [hImg, mainhandles] = imageMolecule(mainhandles, ax, img, limcorrect, edge)
        
        % Check contrast
        if isempty(mainhandles.data(file).FRETpairs(pair).contrastslider) % Set a default contrast slider value, if it's empty
            mainhandles.data(file).FRETpairs(pair).contrastslider = 0;
            updatemainhandles(mainhandles)
        end
        contrastMax = 1-mainhandles.data(file).FRETpairs(pair).contrastslider;
        
        % Set Contrast
        maxValue = (max(img(:))-min(img(:)))*contrastMax + min(img(:));
        img(img>maxValue) = maxValue;
        
        % Make logarithmic scale plot
        if mainhandles.settings.FRETpairplots.logImage
            img = real(log10(img));
        end
        
        % Plot image
        hImg = imagesc(img,'Parent',ax); % Show image
        
        % Set axis properties
        axis(ax,'image') % Equalizes x and y limits
        set(ax,'YDir','normal') % Flips y-axis so that it goes from low to high numbers, going up
        if ~strcmp(get(ax,'XTickLabel'),'') % Remove axes labels
            set(ax, 'XTickLabel','')
            set(ax, 'YTickLabel','')
        end
        
        % Make sure moleucule position is in the exact center of the image
        
        % Check current limits
        xlims = get(ax,'xlim'); % Get current x-limits
        ylims = get(ax,'ylim'); % Get current y-limits
        xlims = xlims+limcorrect(1)+[1 -1]; % Correct center of image due to pixel round-off. +[1 -1] to avoid white edges
        ylims = ylims+limcorrect(2)+[1 -1];
        
        % If molecule is located at an edge set additional limits
        if sum(edge)>0
            xlims = [xlims(1)-edge(1) xlims(2)+edge(2)];
            ylims = [ylims(1)-edge(3) ylims(2)+edge(4)];
        end
        
        % Set new limits
        xlim(ax,sort(xlims)) % Set axis limits so that Dxy is in the exact center of the image
        ylim(ax,sort(ylims))
        
        % Update UIcontextmenu
        updateUIcontextMenus(mainhandles.figure1,hImg)
        
    end

    function [hInt hBack] = highlightPixels(ax, img, intMask, backMask, xi, yi)
        % Highglights pixels in image
        hInt = [];
        hBack = [];
        
        if ~mainhandles.settings.FRETpairplots.showIntPixels && ~mainhandles.settings.FRETpairplots.showBackPixels
            return
        end
        
        % Current axes
        %         axes(ax)
        
        if mainhandles.settings.FRETpairplots.showIntPixels
            
            hInt = highlightPixels2(...
                1-mainhandles.settings.FRETpairplots.intMaskTransparency,...
                mainhandles.settings.FRETpairplots.intMaskColor,...
                intMask);
        end
        
        if mainhandles.settings.FRETpairplots.showBackPixels
            hBack = highlightPixels2(...
                1-mainhandles.settings.FRETpairplots.backMaskTransparency,...
                mainhandles.settings.FRETpairplots.backMaskColor,...
                backMask);
        end
        
        function h = highlightPixels2(transparency, maskcolor, mask)
            
            % Freezes color-scale
            caxis(ax,'manual')
            
            % Make a truecolor all-white image and overlay it on image
            if strcmp(maskcolor,'white') % If plotting white mask
                maskImage = ones([size(img) 3]);
            else % If plotting gray mask
                maskImage = ones([size(img) 3])*0.5;
            end
            
            % Show
            hold(ax,'on')
            %             cmap = colormap; % Current colormap
            h = image(maskImage,'Parent',ax);
            hold(ax,'off')
            
            % Make a transparency grid matching the integration pixels mask
            try
                % Try is a temp fix for wrong ranges
                mask = double(mask(xi, yi));
                set(h, 'AlphaData', mask'*transparency)
            end
            
        end
    end

    function [mainhandles FRETpairwindowHandles] = justreturn()
        try mainhandles = guidata(getappdata(0,'mainhandle'));
        catch err
            mainhandles = [];
        end
        FRETpairwindowHandles = [];
    end

end
