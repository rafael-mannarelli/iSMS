function varargout = integrationsettingsWindow(varargin) %% Initializes the GUI
% INTEGRATIONSETTINGSWINDOW - GUI window associated with iSMS for choosing and
% comparing photon counting methods.
%
%   integrationsettingsWindow cannot be called by itself as it relies on handles
%   sent by the main window (sms) upon opening.
%
%  The integrationsettingsWindow GUI is programmed using GUIDE. The callbacks of
%  the GUI is found in the integrationsettingsWindow.m file.
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

% Last Modified by GUIDE v2.5 15-Jul-2014 11:08:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @integrationsettingsWindow_OpeningFcn, ...
    'gui_OutputFcn',  @integrationsettingsWindow_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function integrationsettingsWindow_OpeningFcn(hObject, eventdata, handles, varargin) %% This function is run right before the GUI is made visible. Initializes the settings structure.
% Set position, title and logo. Turn off visibility.
initGUI(handles.figure1, 'Pixel integration settings', 'center');

% Handle to main figure window
handles.main = getappdata(0,'mainhandle');
mainhandles = guidata(handles.main);

% Axes
ylabel(handles.DDaxes1,'D - D')
ylabel(handles.ADaxes1,'A - D')
ylabel(handles.Eaxes1,'A - A')
ylabel(handles.DDaxes2,'')
ylabel(handles.ADaxes2,'')
ylabel(handles.Eaxes2,'')
xlabel(handles.Eaxes1,'Time /frames')
xlabel(handles.Eaxes2,'Time /frames')
set([handles.DDaxes1 handles.DDaxes2 handles.ADaxes1 handles.ADaxes2...
    handles.Eaxes1 handles.Eaxes2 handles.PSFaxes],...
    'XTickLabel','','YTickLabel','')

% Link axes
linkaxes([handles.DDaxes1 handles.DDaxes2],'x')
linkaxes([handles.ADaxes1 handles.ADaxes2],'x')
linkaxes([handles.Eaxes1 handles.Eaxes2],'x')

% Update GUI content
set(handles.MethodPopupMenu, 'Value', mainhandles.settings.integration.type)
set(handles.AreaSizeEditbox, 'String', mainhandles.settings.integration.wh(1));
set(handles.equalPixelsCheckbox, 'value',mainhandles.settings.integration.equalPixels)
set(handles.PosLimEditbox, 'String', mainhandles.settings.integration.posLim)
set(handles.MinWidthEditbox, 'String', mainhandles.settings.integration.sigmaLim(1))
set(handles.MaxWidthEditbox, 'String', mainhandles.settings.integration.sigmaLim(2))
set(handles.MinAngleEditbox, 'String', mainhandles.settings.integration.thetaLim(1))
set(handles.MaxAngleEditbox, 'String', mainhandles.settings.integration.thetaLim(2))
set(handles.ConstrainWidthCheckbox, 'Value', mainhandles.settings.integration.constrainGaussianFWHM);
handles.settings.view.plotBackground = 0; % Default settings for plotting background traces
set(handles.ThresholdSlider,'Value',mainhandles.settings.integration.threshold);

% Update GUI with data
% MethodPopupMenu_Callback(handles.MethodPopupMenu, [], handles) % Simulate selection i method popupmenu
updateMethodSelection(handles)
updateCompareCheckbox(handles)
updatephotonwindowPairList(handles.main, handles.figure1)
selectedPairs = getPairs(handles.main, 'missingTrace'); % Returns FRET pairs from all files that needs to have their intensity traces calculated
if ~isempty(selectedPairs)
    mainhandles = calculateIntensityTraces(handles.main,selectedPairs); % Calculates intensity traces and puts them in the mainhandles.data.DDtrace... structure
end

% Turn off some things if its a deployed version
turnoffDeployed(mainhandles,[],[],[],[],[],[], handles.figure1);

% Choose default command line output for FRETpairwindow
handles.output = hObject; % Return handle to GUI window

% Now show GUI and update plots
% updatePhotonCountingPlots(handles.main,handles.figure1)
set(handles.figure1,'Visible','on')
guidata(handles.figure1,handles) % Updates handles structure

% Set some GUI settings
setGUIappearance(handles.figure1)

function varargout = integrationsettingsWindow_OutputFcn(hObject, ~, handles) %% This function returns handles.output (varargout) to the command line.
% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
% ----------------- Callback-functions start hereafter ---------------
% - Tip: Fold all code for an overview (Ctrl+= on american keyboard) -
% --------------------------------------------------------------------

% ------------------------------------------------------------------
% ------------------------------- Menus ----------------------------
% ------------------------------------------------------------------

function FileMenu_Callback(hObject, ~, handles) %% The file menu

function File_ExportFigure_Callback(hObject, ~, handles) %% Export figure from the file menu

function HelpMenu_Callback(hObject, ~, handles) %% Help menu

function Help_mfile_Callback(hObject, ~, handles) %% Open this m-file
edit integrationsettingsWindow.m

function Help_figfile_Callback(hObject, ~, handles) %% Open fig file in GUIDE
guide integrationsettingsWindow

function Help_plotfcn_Callback(hObject, eventdata, handles)
edit updatePhotonCountingPlots.m

function Help_integrationfcn_Callback(hObject, eventdata, handles)
edit calculateIntensityTraces.m

% ------------------------------------------------------------------
% ----------------------------- Toolbar ----------------------------
% ------------------------------------------------------------------

function Toolbar_ShowHideBackground_ClickedCallback(hObject, eventdata, handles)
mainhandles = getmainhandles(handles);
if isempty(mainhandles) % If main window for some reason is no longer a handle
    return
end

% Don't do anything if compare methods is not turned on
if ~get(handles.CompareCheckbox,'Value')
    return
end

% Update handles structure settings
if handles.settings.view.plotBackground==0
    handles.settings.view.plotBackground = 1;
    
elseif handles.settings.view.plotBackground==1
    handles.settings.view.plotBackground = 2;
    
elseif handles.settings.view.plotBackground==2
    handles.settings.view.plotBackground = 0;
end

% Update plots
guidata(handles.figure1,handles) % Update handles structure
recalc = 0;
updatePhotonCountingPlots(handles.main, handles.figure1, 'traces', recalc)

% --------------------------------------------------------------------
% ------------------------------- Objects ----------------------------
% --------------------------------------------------------------------

function MethodPopupMenu_Callback(hObject, ~, handles) %% Popup menu for chosen intensity method
updateMethodSelection(handles)
function MethodPopupMenu_CreateFcn(hObject, ~, handles) %% Runs when the popupmenu is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AreaSizeEditbox_Callback(hObject, ~, handles) %% Callback for default area size editbox
function AreaSizeEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function equalPixelsCheckbox_Callback(hObject, eventdata, handles)

%-------------------- Gaussian parameters table ----------------%
function PosLimEditbox_Callback(hObject, ~, handles) %% Callback for the position radius limit editbox
function PosLimEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MinWidthEditbox_Callback(hObject, ~, handles) %% Callback for the minimum width editbox
function MinWidthEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MaxWidthEditbox_Callback(hObject, ~, handles) %% Callback for the maximum width editbox
function MaxWidthEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MinAngleEditbox_Callback(hObject, ~, handles) %% Callback for the minimum angle editbox
function MinAngleEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MaxAngleEditbox_Callback(hObject, ~, handles) %% Callback for the max angle editbox
function MaxAngleEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ConstrainWidthCheckbox_Callback(hObject, ~, handles) %% Callback for constrain width checkbox

function ThresholdSlider_Callback(hObject, ~, handles) %% Callback for the threshold slider
function ThresholdSlider_CreateFcn(hObject, ~, handles) %% Runs when the slider is created
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%----------------- Compare methods objects ------------------%
function CompareCheckbox_Callback(hObject, ~, handles) %% Callback for the compare methods checkbox
updateCompareCheckbox(handles)

function PairListbox_Callback(hObject, ~, handles) %% Callback for selection change in the FRET pair listbox
updatePSFframePopupMenu(handles) % Updates the psf frames popup menu string
updatePhotonCountingPlots(handles.main, handles.figure1, 'all') % Updates the axes plots
function PairListbox_CreateFcn(hObject, ~, handles) %% Runs when the listbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FirstFramesEditbox_Callback(hObject, ~, handles) %% Callback for the compare first x frames editbox
updatePhotonCountingPlots(handles.main, handles.figure1, 'traces')
function FirstFramesEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Axes1PopupMenu_Callback(hObject, ~, handles) %% Callback for the left axes selection popupmenu
updatePhotonCountingPlots(handles.main, handles.figure1, 'axes1')
function Axes1PopupMenu_CreateFcn(hObject, ~, handles) %% Runs when the popupmenu is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Axes2PopupMenu_Callback(hObject, ~, handles) %% Callback for the right axes selection popupmenu
updatePhotonCountingPlots(handles.main, handles.figure1, 'axes2')
function Axes2PopupMenu_CreateFcn(hObject, ~, handles) %% Runs when the popupmenu is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PSFmethodPopupMenu_Callback(hObject, ~, handles) %% Callback for the psf-method selection popupmenu
updatePhotonCountingPlots(handles.main, handles.figure1, 'psf')
function PSFmethodPopupMenu_CreateFcn(hObject, ~, handles) %% Runs when the popupmenu is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PSFchannelPopupMenu_Callback(hObject, ~, handles) %% Callback for the channel-selection popupmenu
updatePhotonCountingPlots(handles.main, handles.figure1, 'psf')
function PSFchannelPopupMenu_CreateFcn(hObject, ~, handles) %% Runs when the popupmenu is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PSFframePopupMenu_Callback(hObject, ~, handles) %% Callback for the frame PSF popupmenu
updatePhotonCountingPlots(handles.main, handles.figure1, 'psf')
function PSFframePopupMenu_CreateFcn(hObject, ~, handles) %% Runs when the popupmenu is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------- OK and cancel pushbuttons -------------%
function OKpushbutton_Callback(hObject, ~, handles) %% Callback for pressing the OK button
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

%% Update settings structure

wh_before = mainhandles.settings.integration.wh;
type_before = mainhandles.settings.integration.type;
type = get(handles.MethodPopupMenu,'Value');
mainhandles.settings.integration.type = type;
mainhandles.settings.integration.wh = [...
    str2num(get(handles.AreaSizeEditbox,'String')) str2num(get(handles.AreaSizeEditbox,'String'))];
mainhandles.settings.integration.equalPixels = get(handles.equalPixelsCheckbox, 'value');

if type~=1 % If method is one of the PSF fitting methods
    mainhandles.settings.integration.posLim = str2num(get(handles.PosLimEditbox,'String'));
    mainhandles.settings.integration.sigmaLim = [...
        str2num(get(handles.MinWidthEditbox,'String')) str2num(get(handles.MaxWidthEditbox,'String'))];
    mainhandles.settings.integration.thetaLim = [...
        str2num(get(handles.MinAngleEditbox,'String')) str2num(get(handles.MaxAngleEditbox,'String'))];
    mainhandles.settings.integration.constrainGaussianFWHM = get(handles.ConstrainWidthCheckbox,'Value');
    mainhandles.settings.integration.threshold = get(handles.ThresholdSlider,'Value');
end

%% Pairs to update

% Check new aperture size
calcPairs = [];
if ~isequal(type_before,type) ...
        || ~isequal(wh_before,mainhandles.settings.integration.wh)
    
    % Dialog
    choice = myquestdlg(sprintf('%s%s',...
        'Do you wish to calculate traces in the current FRET pairs?'),...
        'Update traces',...
        'Yes, apply to all','Yes, apply to selected molecules','No','Yes, apply to all');
    
    % Reset
    if strcmpi(choice,'Yes, apply to all')
        calcPairs = getPairs(handles.main,'all');
    elseif strcmpi(choice,'Yes, apply to selected molecules')
        calcPairs = getPairs(handles.main,'Selected');
    end
    
end

% Reset pairs
if ~isempty(calcPairs)
    for i = 1:size(calcPairs,1)
        file = calcPairs(i,1);
        pair = calcPairs(i,2);
        mainhandles.data(file).FRETpairs(pair).Dwh = mainhandles.settings.integration.wh;
        mainhandles.data(file).FRETpairs(pair).Awh = mainhandles.settings.integration.wh;
        mainhandles.data(file).FRETpairs(pair).DintMask = [];
        mainhandles.data(file).FRETpairs(pair).AintMask = [];
        mainhandles.data(file).FRETpairs(pair).DbackMask = [];
        mainhandles.data(file).FRETpairs(pair).AbackMask = [];
        if ~isempty(mainhandles.data(file).DD_ROImovie)
            mainhandles.data(file).FRETpairs(pair).DD_avgimage = []; % This will force a molecule image re-calculation by updateFRETpairplots
        end
    end
end

%% Update

updatemainhandles(mainhandles) % Update mainhandles structure

% Run calculation and update windows
if ~isempty(calcPairs)
    mainhandles = calculateIntensityTraces(handles.main,calcPairs); % Calculates all traces and update the correctionfactorwindow
    FRETpairwindowHandles = updateFRETpairplots(handles.main,mainhandles.FRETpairwindowHandle,'all');
    FRETpairwindowHandles = updateMoleculeFrameSliderHandles(handles.main,mainhandles.FRETpairwindowHandle);
    
    % If histogram is open update the histogram
    if strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on')
        mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
    end
end

% Close window
try 
    delete(handles.figure1)
end

function CancelPushbutton_Callback(hObject, ~, handles) %% Callback for pressing the Cancel button
% Close window
try 
    delete(handles.figure1)
end

%-------------- Misc ----------------%
% function updatePhotonWindow(handles)
function updateMethodSelection(handles) %% Updates GUI according to method selection
% Selected integration method
methodchoice = get(handles.MethodPopupMenu,'Value');

% Handles to all objects in the Gaussian settings panel
h = allchild(handles.SettingsPanel);

% Make objects visible
grey = [0.7 0.7 0.7];
blck = [0 0 0];
if methodchoice==1
    set(h,'Enable','off')
    set(handles.SettingsPanel, 'ForegroundColor',grey)
else
    set(h,'Enable','on')
    set(handles.SettingsPanel, 'ForegroundColor',blck)
end

function updateCompareCheckbox(handles) %% Updates GUI according to compare method-checkbox selection
% Handles
h = [handles.PairListbox handles.FirstFramesEditbox handles.FRETpairTextbox...
    handles.FirstFramesTextbox1 handles.FirstFramesTextbox2 handles.Axes1PopupMenu...
    handles.Axes2PopupMenu handles.PSFtextbox handles.PSFframePopupMenu handles.PSFframeTextbox...
    handles.PSFchannelPopupMenu handles.PSFmethodPopupMenu handles.PSFchannelTextbox];

% Colors
grey = [0.7 0.7 0.7];
blck = [0 0 0];

% Act to selection
choice = get(handles.CompareCheckbox, 'Value');
axs = [handles.DDaxes1 handles.DDaxes2 handles.ADaxes1 handles.ADaxes2...
    handles.Eaxes1 handles.Eaxes2 handles.PSFaxes];

if choice==1
    
    set(h,'enable','on')
    set(axs, 'xcolor',blck)
    set(axs, 'ycolor',blck)

    % Axis labels colors
    xlabel(handles.Eaxes1, get(get(handles.Eaxes1,'xlabel'),'string'), 'Color',blck)
    xlabel(handles.Eaxes2, get(get(handles.Eaxes2,'xlabel'),'string'), 'Color',blck)
    ylabel(handles.DDaxes1, get(get(handles.DDaxes1,'ylabel'),'string'), 'Color',blck)
    ylabel(handles.ADaxes1, get(get(handles.ADaxes1,'ylabel'),'string'), 'Color',blck)
    ylabel(handles.Eaxes1, get(get(handles.Eaxes1,'ylabel'),'string'), 'Color',blck)
    
    updatePSFframePopupMenu(handles)

else
    
    set(h,'enable','off')
    set(axs, 'xcolor',grey)
    set(axs, 'ycolor',grey)

    % Axis labels colors
    xlabel(handles.Eaxes1, get(get(handles.Eaxes1,'xlabel'),'string'), 'Color',grey)
    xlabel(handles.Eaxes2, get(get(handles.Eaxes2,'xlabel'),'string'), 'Color',grey)
    ylabel(handles.DDaxes1, get(get(handles.DDaxes1,'ylabel'),'string'), 'Color',grey)
    ylabel(handles.ADaxes1, get(get(handles.ADaxes1,'ylabel'),'string'), 'Color',grey)
    ylabel(handles.Eaxes1, get(get(handles.Eaxes1,'ylabel'),'string'), 'Color',grey)
    
end

function updatePSFframePopupMenu(handles)
mainhandles = getmainhandles(handles); % Get main handles structure
if isempty(mainhandles)
    return
end

% Pair selected in the listbox
selectedPair = getPairs(handles.main, 'photonSelected', [],[],[],[],[], handles.figure1);
if isempty(selectedPair)
    set(handles.PSFframePopupMenu,'String',' ')
    return    
end

% Number of frames
frameStr = 1:length(find(mainhandles.data(selectedPair(1,1)).excorder=='D'));

% Check if current selection is outside range
if get(handles.PSFframePopupMenu,'Value')>length(frameStr)
    set(handles.PSFframePopupMenu,'Value',1)
end

% Update string
set(handles.PSFframePopupMenu,'String',frameStr)
