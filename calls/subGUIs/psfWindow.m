function varargout = psfWindow(varargin) %% Initializes the GUI
% PSFWINDOW - GUI window associated with sms for plotting Gaussian PSF
% parameters
%
%  psfWindow cannot be by called by itself as it relies on handles
%  sent by the sms.m main figure window upon opening.
%
%  The psfWindow GUI is programmed using GUIDE. The callbacks of
%  the GUI is found in the psfWindow.m file and is divided into
%  sections of:
%      1) Menus (menu bar items)
%      2) Toolbar items
%      3) Miscellaneous function called by the GUI
%      4) GUI object callbacks (buttons, listboxes, etc.)
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

% Last Modified by GUIDE v2.5 20-Aug-2014 12:49:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @psfWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @psfWindow_OutputFcn, ...
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

function psfWindow_OpeningFcn(hObject, eventdata, handles, varargin) %% Executes just before FRETpairwindow is made visible.
% Set position, title and logo. Turn off visibility.
initGUI(handles.figure1, 'PSF Parameters Window', 'center');

% Handle to main figure window
handles.main = getappdata(0,'mainhandle');
mainhandles = guidata(handles.main);

% Axes
set(handles.TraceAxes1, 'XTickLabel','')
linkaxes([handles.TraceAxes1 handles.TraceAxes2],'x')

% Update GUI content
if 1
    set(handles.MethodPopupMenu, 'Value', mainhandles.settings.psfWindow.type)
    set(handles.PosLimEditbox, 'String', mainhandles.settings.integration.posLim)
    set(handles.MinWidthEditbox, 'String', mainhandles.settings.integration.sigmaLim(1))
    set(handles.MaxWidthEditbox, 'String', mainhandles.settings.integration.sigmaLim(2))
    set(handles.MinAngleEditbox, 'String', mainhandles.settings.integration.thetaLim(1))
    set(handles.MaxAngleEditbox, 'String', mainhandles.settings.integration.thetaLim(2))
    set(handles.ConstrainWidthCheckbox, 'Value', mainhandles.settings.integration.constrainGaussianFWHM);

    
    % Update GUI with data
    % MethodPopupMenu_Callback(handles.MethodPopupMenu, [], handles) % Simulate selection i method popupmenu
    updatePSFwindowPairList(handles.main, handles.figure1)
    updatePSFwindowPlots(handles.main, handles.figure1, 'all')

end

% Turn off some things if its a deployed version
turnoffDeployed(mainhandles,[],[],[],[],[],[],[], handles.figure1);

% Choose default command line output for FRETpairwindow
handles.output = hObject; % Return handle to GUI window

% Now show GUI and update plots
% updatePhotonCountingPlots(handles.main,handles.figure1)
set(handles.figure1,'Visible','on')
guidata(handles.figure1,handles) % Updates handles structure

% Do some window corrections
setGUIappearance(handles.figure1)

function varargout = psfWindow_OutputFcn(hObject, ~, handles) %% Outputs from this function are returned to the command line (not used here)
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

function File_ExportASCII_Callback(hObject, ~, handles) %% Export to ASCII from the file menu

function ViewMenu_Callback(hObject, ~, handles) %% The view menu

function View_Trace1Color_Callback(hObject, ~, handles) %% Set color of trace 1
mainhandles = getmainhandles(handles);
if isempty(handles)
    return
end

prevcolor = mainhandles.settings.psfWindow.axes1color; % Current color as default
c = uisetcolor([prevcolor(1) prevcolor(2) prevcolor(3)], 'Trace 1 color'); % Open dialog for setting color
mainhandles.settings.psfWindow.axes1color = c; % Update handles structure

% Update
updatemainhandles(mainhandles)
updatePSFwindowPlots(handles.main, handles.figure1, 'axes1')

function View_Trace2Color_Callback(hObject, ~, handles) %% Set color of trace 2
mainhandles = getmainhandles(handles);
if isempty(handles)
    return
end

prevcolor = mainhandles.settings.psfWindow.axes2color; % Current color as default
c = uisetcolor([prevcolor(1) prevcolor(2) prevcolor(3)], 'Trace 1 color'); % Open dialog for setting color
mainhandles.settings.psfWindow.axes2color = c; % Update handles structure

% Update
updatemainhandles(mainhandles)
updatePSFwindowPlots(handles.main, handles.figure1, 'axes2')

function HelpMenu_Callback(hObject, ~, handles) %% The help menu

function Help_mfile_Callback(hObject, ~, handles) %% Open this mfile
edit psfWindow.m

function Help_figfile_Callback(hObject, ~, handles) %% Open fig file in GUIDE
guide psfWindow

% ------------------------------------------------------------------
% ----------------------------- Objects ----------------------------
% ------------------------------------------------------------------

function PairListbox_Callback(hObject, ~, handles) %% Callback for selection change in the FRET pair listbox
updatePSFwindowPlots(handles.main, handles.figure1, 'all')
function PairListbox_CreateFcn(hObject, ~, handles) %% Runs when the listbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Axes1PopupMenu_Callback(hObject, ~, handles) %% Callback for selection change of the axes 1 popupmenu
updatePSFwindowPlots(handles.main, handles.figure1, 'axes1')
function Axes1PopupMenu_CreateFcn(hObject, ~, handles) %% Runs when the popup menu is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Axes2PopupMenu_Callback(hObject, ~, handles) %% Callback for selection change in the axes 2 popupmenu
updatePSFwindowPlots(handles.main, handles.figure1, 'axes2')
function Axes2PopupMenu_CreateFcn(hObject, ~, handles) %% Runs when the popupmenu is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PSFpopupMenu_Callback(hObject, ~, handles) %% Callback for selection change in the PSF selection popupmenu
updatePSFwindowPlots(handles.main, handles.figure1, 'psfTraces')
updatePSFwindowPairList(handles.main, handles.figure1) % Update pair listbox
function PSFpopupMenu_CreateFcn(hObject, ~, handles) %% Runs when the popupmenu is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CalculatePushbutton_Callback(hObject, ~, handles) %% Callback for pressing the calculate button
mainhandles = getmainhandles(handles); % Get handles structure of the main window
if isempty(mainhandles)
    return
end

% Open dialog for selecting traces
% Open selection dialog
if get(handles.PSFpopupMenu,'Value')==1
    channel = 'DD';
elseif get(handles.PSFpopupMenu,'Value')==2
    channel = 'AD';
elseif get(handles.PSFpopupMenu,'Value')==3
    channel = 'AA';
end
selectedPairs = selectionDlg(mainhandles,sprintf('PSF analysis of %s channel',channel),'Select molecules to analyse: ','pair');
if isempty(selectedPairs)
    return
end

% Run calculation
mainhandles = calculatePSFtraces(handles.main, selectedPairs, channel);

% Update GUI
updatePSFwindowPlots(handles.main, handles.figure1, 'all') % Update plot
updatePSFwindowPairList(handles.main, handles.figure1) % Update pair listbox

%--------------- Gaussian optimization parameters panel ------------%

function PosLimEditbox_Callback(hObject, ~, handles) %% Callback for editing the position limits editbox
updateNewGaussianSettings(handles)
function PosLimEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MinWidthEditbox_Callback(hObject, ~, handles) %% Callback for editing the min width editbox
updateNewGaussianSettings(handles)
function MinWidthEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MaxWidthEditbox_Callback(hObject, ~, handles) %% Callback for editing the max width editbox
updateNewGaussianSettings(handles)
function MaxWidthEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MinAngleEditbox_Callback(hObject, ~, handles) %% Callback for editing the min angle editbox
updateNewGaussianSettings(handles)
function MinAngleEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MaxAngleEditbox_Callback(hObject, ~, handles) %% Callback for editing the max angle editbox
updateNewGaussianSettings(handles)
function MaxAngleEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ConstrainWidthCheckbox_Callback(hObject, ~, handles) %% Callback for the constrain width checkbox
updateNewGaussianSettings(handles)

function ThresholdSlider_Callback(hObject, ~, handles)
updateNewGaussianSettings(handles)
function ThresholdSlider_CreateFcn(hObject, ~, handles) %% Runs when the slider is created
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function AvgFramesEditbox_Callback(hObject, ~, handles)
updateNewGaussianSettings(handles)
function AvgFramesEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MethodPopupMenu_Callback(hObject, ~, handles)
updateNewGaussianSettings(handles)
function MethodPopupMenu_CreateFcn(hObject, ~, handles) %% Runs when the popupmenu is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%------------ Misc --------------%

function updateNewGaussianSettings(handles) %% Updates main handles structure according to settings specified in the GUI
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

% Update handles structure
mainhandles.settings.psfWindow.type = get(handles.MethodPopupMenu, 'Value');
mainhandles.settings.integration.posLim = str2num(get(handles.PosLimEditbox, 'String'));
mainhandles.settings.integration.sigmaLim(1) = str2num(get(handles.MinWidthEditbox, 'String'));
mainhandles.settings.integration.sigmaLim(2) = str2num(get(handles.MaxWidthEditbox, 'String'));
mainhandles.settings.integration.thetaLim(1) = str2num(get(handles.MinAngleEditbox, 'String'));
mainhandles.settings.integration.thetaLim(2) = str2num(get(handles.MaxAngleEditbox, 'String'));
mainhandles.settings.integration.constrainGaussianFWHM = get(handles.ConstrainWidthCheckbox, 'Value');
updatemainhandles(mainhandles)

function Help_Documentation_Callback(hObject, eventdata, handles)
myopenURL('http://isms.au.dk/documentation/tethered-fluorophore-motion-tfm/')
