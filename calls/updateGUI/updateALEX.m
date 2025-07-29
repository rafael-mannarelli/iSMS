function mainhandles = updateALEX(mainhandles,fpwHandle,hwHandle,cfwHandle)
% Updates GUI properties (menu visibilities etc.) depending on excitation
% scheme
%
%    Input:
%     mainhandles  - handles structure of the main window
%     fpwHandle    - handle to the FRETpair window
%     hwHandle     - handle to the histogramwindow
%     cfwHandle    - handle to the correction factor window
%
%    Output:
%     mainhandles  - ...
%

%% Initialize

% Defaults
if nargin<2 || isempty(fpwHandle)
    fpwHandle = mainhandles.FRETpairwindowHandle;
end
if nargin<3 || isempty(hwHandle)
    hwHandle = mainhandles.histogramwindowHandle;
end
if nargin<4 || isempty(cfwHandle)
    cfwHandle = mainhandles.correctionfactorwindowHandle;
end

% Get handles structures
fpwHandles = [];
hwHandles = [];
cfwHandles = [];
if ~isempty(fpwHandle) && ishandle(fpwHandle)
    fpwHandles = guidata(fpwHandle);
end
if ~isempty(hwHandle) && ishandle(hwHandle)
    hwHandles = guidata(hwHandle);
end
if ~isempty(cfwHandle) && ishandle(cfwHandle)
    cfwHandles = guidata(cfwHandle);
end

alex = mainhandles.settings.excitation.alex;

%% Update settings

if ~alex
    
    % FRETpair window
    if mainhandles.settings.FRETpairplots.sortpairs==4 || mainhandles.settings.FRETpairplots.sortpairs==8
        mainhandles.settings.FRETpairplots.sortpairs = 1;
    end
    
    % Update handles
    updatemainhandles(mainhandles)
    
end

%% Update main window

% Handles to all alex-dependent menu items
h2 = [mainhandles.Tools_SpotProfile mainhandles.Settings_LaserSpotProfiles...
    mainhandles.Tools_Windows_SpotProfiles...
    mainhandles.Tools_Windows_TFM];

% Turn on/off
if alex
    set(h2,'Visible','on')
else
    set(h2,'Visible','off')
end

%% Update FRETpair window

if ~isempty(fpwHandles)
    
    % Handles to all alex-dependent menu items
    h2 = [fpwHandles.Sort_avgS fpwHandles.Sort_maxAA ...
        fpwHandles.Plot_CoordinateCorrelation fpwHandles.AAimageAxes...
        fpwHandles.AdirectTextbox fpwHandles.AdirectEditbox...
        fpwHandles.Settings_FRETmethod];
    
    % Turn on/off
    if alex
        set(h2,'Visible','on')
    else
        set(h2,'Visible','off')
    end
    
    % Update axes titles
    ylabel(fpwHandles.DDtraceAxes, getYlabel(mainhandles,'FRETpairwindowAx1'))
    ylabel(fpwHandles.ADtraceAxes, getYlabel(mainhandles,'FRETpairwindowAx2'))
    ylabel(fpwHandles.AAtraceAxes, getYlabel(mainhandles,'FRETpairwindowAx3'))
    ylabel(fpwHandles.StraceAxes, getYlabel(mainhandles,'FRETpairwindowAx4'))
    
    % Update GUI appearance
    FRETpairwindowResizeFcn(fpwHandles)
end

%% Update histogram window

if ~isempty(hwHandles)
    
    % Handles to all sc-dependent menu items
    h1 = [hwHandles.GaussTable hwHandles.FitPushbutton hwHandles.backgroundPanel];
    
    % Handles to all alex-dependent menu items
    h2 = [hwHandles.View_PlotInverseS hwHandles.View_lockSbinsize...
        hwHandles.View_PlotTypeMenu hwHandles.Settings_Lasso...
        hwHandles.Toolbar_PlotType hwHandles.Toolbar_InverseColors...
        hwHandles.Toolbar_LassoSelectionPlot hwHandles.Toolbar_fit2Dgauss...
        hwHandles.Toolbar_fit1DgaussS hwHandles.Toolbar_predict2Dgauss...
        hwHandles.Toolbar_predict1DgaussS hwHandles.Toolbar_PlotEhist...
        hwHandles.Toolbar_Colormap hwHandles.Toolbar_GaussianComponentsWindow...
        hwHandles.SEplot hwHandles.Shist...
        hwHandles.SbinsTextbox hwHandles.SbinsizeSlider...
        hwHandles.frameCounterTextbox hwHandles.frameCounter ...
        hwHandles.moleculeCounterTextbox hwHandles.MergeFilesTextbox];
    
    % Turn on/off
    if alex
        set(h1,'Visible','off')
        set(h2,'Visible','on')
        
        set(hwHandles.EbinsTextbox, 'HorizontalAlignment','center')
        set([hwHandles.Toolbar_predict1DgaussE hwHandles.Toolbar_plotFits], 'Separator','on')
        set(hwHandles.View_lockEbinsize,'Label','Lock bin size of E')
        
    else
        set(h1,'Visible','on')
        set(h2,'Visible','off')
        
        xlabel(hwHandles.Ehist, 'FRET efficiency (E)')
        set(hwHandles.EbinsTextbox, 'HorizontalAlignment','right')
        set([hwHandles.Toolbar_predict1DgaussE hwHandles.Toolbar_plotFits], 'Separator','off')
        set(hwHandles.View_lockEbinsize,'Label','Lock bin size')
        
        set([hwHandles.moleculeCounter hwHandles.EbinsTextbox hwHandles.EbinsizeSlider],...
            'BackgroundColor',[1 1 1])
        set([hwHandles.moleculeCounter hwHandles.EbinsTextbox],'string','')
        
        set([hwHandles.Ehist hwHandles.EbinsizeSlider hwHandles.EbinsTextbox hwHandles.moleculeCounter hwHandles.frameCounter],...
            'Parent',hwHandles.backgroundPanel)
        set(hwHandles.Ehist,'ActivePositionProperty','outerposition')
        
        xlabel(hwHandles.Shist,'')
        xlabel(hwHandles.SEplot,'')
        ylabel(hwHandles.Shist,'')
        ylabel(hwHandles.SEplot,'')
    end
    
    % Update GUI appearance
    histogramwindowResizeFcn(hwHandles)
end

%% Update correction factor window

if ~isempty(cfwHandles)
    % Handles to all sc-dependent menu items
    h1 = [];
    
    % Handles to all alex-dependent menu items
    h2 = [cfwHandles.Sort_S cfwHandles.View_Axes4];
    
    % Turn on/off
    if alex
        set(h1,'Visible','off')
        set(h2,'Visible','on')
        
    else
        set(h1,'Visible','on')
        set(h2,'Visible','off')
        
        % Don't show A direct
        set(cfwHandles.AdirectRadiobutton,'Visible','off','String','Direct acceptor (ALEX only)')
        if mainhandles.settings.correctionfactorplot.factorchoice==2
            mainhandles.settings.correctionfactorplot.factorchoice = 1;
            updatemainhandles(mainhandles)
        end
        
        % Don't sort according to S
        if mainhandles.settings.correctionfactorplot.sortpairs==5
            mainhandles.settings.correctionfactorplot.sortpairs = 1;
            updatemainhandles(mainhandles)
        end
    end
    
end
