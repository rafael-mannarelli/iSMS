function varargout = correctionfactorWindow(varargin) %% Initializes the GUI
% CORRECTIONFACTORWINDOW - GUI associated with iSMS for calculating
% correction factors
%
%  correctionfactorWindow.m cannot be by called by itself as it relies on
%  handles sent by the sms.m main figure window upon opening.
%
%  The correctionfactorWindow GUI is programmed using GUIDE. The callbacks of
%  the GUI is found in the correctionfactorWindow.m file and is divided into
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

% Last Modified by GUIDE v2.5 16-Mar-2015 17:37:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @correctionfactorWindow_OpeningFcn, ...
    'gui_OutputFcn',  @correctionfactorWindow_OutputFcn, ...
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

function correctionfactorWindow_OpeningFcn(hObject, eventdata, handles, varargin) %% Executes just before GUI is made visible.
% Set position, title and logo. Turn off visibility.
initGUI(handles.figure1, 'Correction Factor Window: Donor Leakage', 'center');

% Handle to main figure window
handles.main = getappdata(0,'mainhandle');
guidata(handles.figure1,handles) % Update handles structure
mainhandles = guidata(handles.main);

% Update GUI depending on excitation scheme
mainhandles = updateALEX(mainhandles,[],[],handles.figure1);

% Update visible functionalities
mainhandles = updatePublic(mainhandles,[],[],handles.figure1);

% Axes
ylabel(handles.DDtraceAxes,getYlabel(mainhandles,'correctionAx1'))
ylabel(handles.ADtraceAxes,getYlabel(mainhandles,'correctionAx2'))
ylabel(handles.AAtraceAxes,getYlabel(mainhandles,'correctionAx3'))
ylabel(handles.ax4,getYlabel(mainhandles,'correctionAx4'))
xlabel(handles.ax4,'Time /frames')
set([handles.DDtraceAxes handles.ADtraceAxes handles.AAtraceAxes handles.ax4], 'XTickLabel','', 'YTickLabel', '')
linkaxes([handles.DDtraceAxes handles.ADtraceAxes handles.AAtraceAxes handles.ax4],'x')

ylabel(handles.HistAxes,'Counts')
xlabel(handles.HistAxes,'Correction factor')
box(handles.DDtraceAxes,'on')
box(handles.ADtraceAxes,'on')
box(handles.AAtraceAxes,'on')
box(handles.ax4,'on')
box(handles.HistAxes,'on')

% Update GUI according to default settings
if mainhandles.settings.correctionfactorplot.factorchoice == 1
    set(handles.DleakageRadiobutton,'Value',1)
    set(handles.figure1,'name','Correction Factor Window: Donor Leakage','numbertitle','off')
    set(handles.CorrectionFactorDefTextbox,'String',sprintf(...
        'Donor leakage factor is A/D for D-only species'))
elseif mainhandles.settings.correctionfactorplot.factorchoice == 2
    set(handles.AdirectRadiobutton,'Value',1)
    set(handles.figure1,'name','Correction Factor Window: Direct Acceptor Excitation','numbertitle','off')
    set(handles.CorrectionFactorDefTextbox,'String',sprintf(...
        'Direct A excitation factor is A/AA for A-only species'))
elseif mainhandles.settings.correctionfactorplot.factorchoice == 3
    set(handles.GammaRadiobutton,'Value',1)
    set(handles.figure1,'name','Correction Factor Window: Gamma Factor','numbertitle','off')
    set(handles.CorrectionFactorDefTextbox,'String',sprintf(...
        'Gamma factor is (A1-A2)/(D2-D1) at A bleaching events'))
end
if mainhandles.settings.correctionfactorplot.showBleaching == 1
    set(handles.Toolbar_ShowBleaching,'state','on')
else
    set(handles.Toolbar_ShowBleaching,'state','off')
end
if mainhandles.settings.correctionfactorplot.showInterval == 1
    set(handles.Toolbar_ShowCorrectionInterval,'state','on')
else
    set(handles.Toolbar_ShowCorrectionInterval,'state','off')
end

% Updates checkmarks in menu
updatecorrectionwindowGUImenus(handles)

% Turn off some things if its a deployed version
turnoffDeployed(mainhandles,[],[], handles.figure1);

% Save current properties of cursor and graphics handles
handles.functionHandles.cursorPointer = get(handles.figure1, 'Pointer');

% Choose default command line output for FRETpairwindow
handles.output = hObject; % Return handle to GUI window

% Calculate correction factors
mainhandles = calculateCorrectionFactors(handles.main);

% Update GUI
guidata(handles.figure1,handles)
updateCorrectionFactorPairlist(handles.main,handles.figure1)
updateCorrectionFactorPlots(handles.main,handles.figure1)

% Set some GUI settings
setGUIappearance(handles.figure1)

function varargout = correctionfactorWindow_OutputFcn(hObject, ~, handles) %% Outputs from this function are returned to the command line (not used here)
% Resize final time (this function is run at the end of startup)
correctionfactorwindowResizeFcn(handles)

% Now show GUI
set(handles.figure1,'Visible','on')

% Get default command line output from handles structure
varargout{1} = handles.output;

function figure1_CloseRequestFcn(hObject, ~, handles) %% Runs when the GUI (i.e. handles.figure1) is being closed
% Turn off toggle button in main window
try
    mainhandles = guidata(handles.main);
    set(mainhandles.Toolbar_correctionfactorWindow,'State','off')
end

% Aims to delete all data and handles used by the program before closing
try cla(handles.DDtraceAxes)
    cla(handles.HistAxes)
    handles = [];
    handles.figure1 = hObject;
    guidata(hObject,handles)
end % Delete all fields in the handles structure (data, settings, etc.)

% Close GUI
try delete(hObject), end

function figure1_ResizeFcn(hObject, eventdata, handles)
correctionfactorwindowResizeFcn(handles)

% --------------------------------------------------------------------
% ----------------- Callback-functions start hereafter ---------------
% - Tip: Fold all code for an overview (Ctrl+= on american keyboard) -
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% ------------------------------- Menus ------------------------------
% --------------------------------------------------------------------

function ExportMenu_Callback(hObject, ~, handles) %% The file menu
handles = turnofftogglesCorrectionWindow(handles);

function Export_Figure_Callback(hObject, ~, handles) % The export figure submenu from the file menu
handles = turnofftogglesCorrectionWindow(handles);
mainhandles = getmainhandles(handles); % Get handles structure to the main window (sms)
if isempty(mainhandles)
    return
end

% Open dialog for choosing axes
%--------- Prepare dialog box ---------%
name = 'Export figure';

% Make prompt structure
prompt = {...
    'Select figures to export: ' '';...
    'Trace plots' 'trace';...
    'Histogram plot' 'hist'};

% formats
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(1,1).type = 'text';
formats(2,1).type = 'check';
formats(3,1).type = 'check';

% Make DefAns structure
DefAns.trace = mainhandles.settings.correctionfactorplot.exportTracePlots;
DefAns.hist = mainhandles.settings.correctionfactorplot.exportHistPlot;

%-------- Open dialog box -------%
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns);
if cancelled == 1 || (~answer.trace && ~answer.hist)
    return
end
mainhandles.settings.correctionfactorplot.exportTracePlots = answer.trace;
mainhandles.settings.correctionfactorplot.exportHistPlot = answer.hist;
updatemainhandles(mainhandles)
%------------%

% Store window settings so they can be restored if export_fig decides to
% close the window
pairchoices = get(handles.PairListbox,'Value');

% Open a dialog for specifying export properties
settings = export_fig_dlg;
if isempty(settings)
    return
end

% Handles of objects to hide when exporting figure
h = [handles.PairListbox handles.PairCounter handles.RemovePushbutton handles.binSlider handles.CorrectionFactorPanel...
    handles.DleakageRadiobutton handles.AdirectRadiobutton handles.GammaRadiobutton handles.CorrectionFactorDefTextbox];
if ~answer.trace
    h(end+1) = handles.DDtraceAxes;
    h(end+1) = handles.ADtraceAxes;
    h(end+1) = handles.AAtraceAxes;
    h(end+1) = handles.ax4;
elseif ~answer.hist
    h(end+1) = handles.HistAxes;
end

% Turn on waitbar
hWaitbar = mywaitbar(1,'Exporting figure. Please wait...','name','iSMS');
setFigOnTop % Sets the waitbar so that it is always in front

% Turn GUI into white empty background
% if settings.transparent
%     h2 = [handles.DDtraceAxes handles.ADtraceAxes handles.AAtraceAxes handles.ax4 handles.PRtraceAxes];
%     set(h2,'Color','none')
% end
datacursor = 0; % Marker off whether data cursor is on or off
cursor = datacursormode(handles.figure1);
if strcmp(get(cursor,'Enable'),'on') % If data cursor mode is on, turn it off
    set(cursor,'Enable','off')
    datacursor = 1;
end
panel1string = get(handles.CorrectionFactorPanel,'Title');
set(handles.CorrectionFactorPanel,'Title','') % The panel titles are not hidden by just setting panel visibility to off
set(h,'Visible','off') % Turn of GUI object visibilities
figure1color = get(handles.figure1,'Color');
set(handles.figure1,'Color','white') % Set GUI background to white

% Export figure
try
    figure(handles.figure1)
    eval(settings.command) % This will run export_fig with settings specified in export_fig_dlg
    
catch err
    fprintf('Error message from export_fig: %s', err.message)
    
    % Turn GUI back to original
    set(h,'Visible','on')
    set(handles.figure1,'Color', figure1color)%[0.94118  0.94118  0.94118])
    if datacursor
        set(cursor,'Enable','on')
    end
    set(handles.CorrectionFactorPanel,'Title',panel1string) % The panel titles are not hidden by just setting panel visibility to off
    
    % Delete waitbar
    try delete(hWaitbar), end
    
    % Show error message
    if strcmp(err.message,'Ghostscript not found. Have you installed it from www.ghostscript.com?')
        if (strcmp(settings.format,'pdf')) || (strcmp(settings.format,'eps'))
            mymsgbox(sprintf('%s%s%s%s',...
                'Exporting figures to vector formats (pdf and eps) requires that ghostscript is installed on your computer. ',...
                'Install it from www.ghostscript.com. ',...
                'Exporting to eps additionally requires pdftops, from the Xpdf suite of functions. ',...
                'You can download this from:  http://www.foolabs.com/xpdf'),'Ghostscript missing');
        else
            mymsgbox('Ghostscript not found. Have you installed it from www.ghostscript.com?','Ghostscript missing');
        end
    elseif strcmp(err.message,'pdftops executable not found.')
        mymsgbox(sprintf('%s%s',...
            'Exporting to eps requires pdftops, from the Xpdf suite of functions. ',...
            'You can download this from:  http://www.foolabs.com/xpdf. You could also export to the other vector format, pdf.'),'pdftops missing');
    end
    
end

% Turn GUI back to original
try set(h,'Visible','on'), end
try set(handles.figure1,'Color', figure1color), end
try set(handles.CorrectionFactorPanel,'Title',panel1string), end % The panel titles are not hidden by just setting panel visibility to off

% if settings.transparent
%     set(h2,'Color','white')
% end
% if datacursor
%     set(cursor,'Enable','on')
% end

% If window has been deleted by export fig (for unknown reasons)
mainhandles = guidata(handles.main);
if strcmpi(get(mainhandles.Toolbar_correctionfactorWindow,'State'),'off')
    set(mainhandles.Toolbar_correctionfactorWindow,'State','on')
    try
        mainhandles = guidata(handles.main);
        handles = guidata(mainhandles.correctionfactorwindowHandle);
        %         updateCorrectionFactorPairlist(handles.main,handles.figure1)
        set(handles.PairListbox,'Value',pairchoices)
        updateCorrectionFactorPlots(handles.main,handles.figure1)
    end
end

% Delete waitbar
try delete(hWaitbar), end

function Export_SMD_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'smd','correctionSelected');

function Export_ASCII_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'ascii','correctionSelected');

function Export_vbFRET_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'vbFRET','correctionSelected');

function Export_HaMMy_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'hammy','correctionSelected');

function Export_boba_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'boba','correctionSelected');

function Export_Workspace_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'workspace','correctionSelected');

function Export_Raw_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'molmovie','correctionSelected');

function Export_Plot_Callback(hObject, eventdata, handles)
mymsgbox('Right-click inside figure for export options.')

function SortMenu_Callback(hObject, eventdata, handles)

function Sort_file_Callback(hObject, eventdata, handles)
mainhandles = sortcorrectionpairsCallback(handles.figure1, 1);

function Sort_value_Callback(hObject, eventdata, handles)
mainhandles = sortcorrectionpairsCallback(handles.figure1, 2);

function Sort_var_Callback(hObject, eventdata, handles)
mainhandles = sortcorrectionpairsCallback(handles.figure1, 6);

function Sort_group_Callback(hObject, eventdata, handles)
mainhandles = sortcorrectionpairsCallback(handles.figure1, 3);

function Sort_E_Callback(hObject, eventdata, handles)
mainhandles = sortcorrectionpairsCallback(handles.figure1, 4);

function Sort_S_Callback(hObject, eventdata, handles)
mainhandles = sortcorrectionpairsCallback(handles.figure1, 5);

function ViewMenu_Callback(hObject, eventdata, handles)

function View_Axes4_Callback(hObject, eventdata, handles)

function View_Axes4_C_Callback(hObject, eventdata, handles)
updateAx4(handles, 'ax4', 1)

function View_Axes4_S_Callback(hObject, eventdata, handles)
updateAx4(handles, 'ax4', 2)

function View_Axes4_E_Callback(hObject, eventdata, handles)
updateAx4(handles, 'ax4', 3)

function View_Axes4_plotfactor_Callback(hObject, eventdata, handles)
mainhandles = getmainhandles(handles);
updateAx4(handles,'plotfactorvalue',abs(mainhandles.settings.correctionfactorplot.plotfactorvalue-1))

function updateAx4(handles,field,choice)
% Update setting
mainhandles = getmainhandles(handles);
mainhandles.settings.correctionfactorplot.(field) = choice;

% Update
updatemainhandles(mainhandles)
updateCorrectionFactorPlots(handles.main,handles.figure1,'trace')
updatecorrectionwindowGUImenus(handles)

function View_CorrectionMenu_Callback(hObject, eventdata, handles)

function View_Correction_Histogram_Callback(hObject, eventdata, handles)
histogramViewCallback(handles,1)

function View_Correction_FRET_Callback(hObject, eventdata, handles)
histogramViewCallback(handles,2)

function View_Correction_Coordinate_Callback(hObject, eventdata, handles)
histogramViewCallback(handles,3)

function histogramViewCallback(handles,choice)
mainhandles = getmainhandles(handles);
mainhandles.settings.correctionfactorplot.histogramplot = choice;
updatemainhandles(mainhandles)
updateCorrectionFactorPlots(handles.main,handles.figure1,'hist')
updatecorrectionwindowGUImenus(handles)

function SettingsMenu_Callback(hObject, ~, handles) %% The settings menu

function Settings_CorrectionFactor_Callback(hObject, ~, handles) %% Set correction factor settings
handles = turnofftogglesCorrectionWindow(handles);
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

[mainhandles,FRETpairwindowHandles] = correctionfactorSettingsDlg(handles.main);

function Settings_GlobalValueMenu_Callback(hObject, eventdata, handles)

function Settings_GlobalMenu_Mean_Callback(hObject, eventdata, handles)
mainhandles = globalFactorChoiceCallback(handles,'globalavgChoice',1);

function Settings_GlobalMenu_WeightedMean_Callback(hObject, eventdata, handles)
mainhandles = globalFactorChoiceCallback(handles,'globalavgChoice',2);

function Settings_GlobalMenu_Median_Callback(hObject, eventdata, handles)
mainhandles = globalFactorChoiceCallback(handles,'globalavgChoice',3);

function Settings_IntensityMenu_Callback(hObject, eventdata, handles)

function Settings_IntensityMenu_Mean_Callback(hObject, eventdata, handles)
mainhandles = correctionFactorIntensitySettingCallback(handles,'medianI',0);

function Settings_IntensityMenu_Median_Callback(hObject, eventdata, handles)
mainhandles = correctionFactorIntensitySettingCallback(handles,'medianI',1);

function ToolsMenu_Callback(hObject, eventdata, handles)

function Tools_Update_Callback(hObject, eventdata, handles)
mainhandles = calcCorrectionFactorsCallback(handles,0);

function Tools_Reset_Callback(hObject, eventdata, handles)
mainhandles = calcCorrectionFactorsCallback(handles,1);

function HelpMenu_Callback(hObject, ~, handles) %% The help menu

function Help_mfile_Callback(hObject, ~, handles) %% Opens this m file
edit correctionfactorWindow.m

function Help_figfile_Callback(hObject, ~, handles) %% Open fig file in GUIDE
guide correctionfactorWindow

function Help_updateplotfcn_Callback(hObject, eventdata, handles)
edit updateCorrectionFactorPlots.m

function Help_correctioncalcfile_Callback(hObject, eventdata, handles)
edit calculateCorrectionFactors.m

function Help_correctingtracesfcn_Callback(hObject, eventdata, handles)
edit correctTraces.m

% --------------------------------------------------------------------
% ----------------------------- Toolbar ------------------------------
% --------------------------------------------------------------------

function Toolbar_ShowCorrectionInterval_ClickedCallback(hObject, ~, handles) %% Show intervals used for the correction factor calculation in the trace plots
mainhandles = showcorrectionfactorIntervalCallback(handles);

function Toolbar_ShowBleaching_ClickedCallback(hObject, ~, handles) %% Show bleaching times in the trace plots
handles = turnofftogglesCorrectionWindow(handles);
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

if strcmp(get(handles.Toolbar_ShowBleaching,'state'),'on')
    mainhandles.settings.correctionfactorplot.showBleaching = 1;
elseif strcmp(get(handles.Toolbar_ShowBleaching,'state'),'off')
    mainhandles.settings.correctionfactorplot.showBleaching = 0;
end
updatemainhandles(mainhandles)
updateCorrectionFactorPlots(handles.main,handles.figure1,'trace')

function Toolbar_SetTimeInterval_OnCallback(hObject, ~, handles) %% Activates selection tool for setting time-interval used for correction factor calculation
[mainhandles, handles] = setCorrectionFactorIntervalCallback(handles);

function Toolbar_SetTimeInterval_OffCallback(hObject, ~, handles) %% Turn of the interval selection tool
myginputc(0);

% --------------------------------------------------------------------
% ------------------------------ Objects -----------------------------
% --------------------------------------------------------------------

function PairListbox_Callback(hObject, ~, handles) %% Callback for selection change in the pair listbox
handles = turnofftogglesCorrectionWindow(handles);
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end
updateCorrectionFactorPlots(handles.main,handles.figure1)
function PairListbox_CreateFcn(hObject, ~, handles) %% Runs when the pair listbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function RemovePushbutton_Callback(hObject, ~, handles) %% Callback for the delete pair pushbutton
handles = turnofftogglesCorrectionWindow(handles);
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

% Pairs selected in the listbox
selectedPairs = getPairs(handles.main, 'correctionSelected', [],[],[], handles.figure1);

% Remove pair by setting the 'Removed' field to 1
for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    if mainhandles.settings.correctionfactorplot.factorchoice==1
        mainhandles.data(file).FRETpairs(pair).DleakageRemoved = 1;
        mainhandles.data(file).FRETpairs(pair).Dleakage = [];
    elseif mainhandles.settings.correctionfactorplot.factorchoice==2
        mainhandles.data(file).FRETpairs(pair).AdirectRemoved = 1;
        mainhandles.data(file).FRETpairs(pair).Adirect = [];
    elseif mainhandles.settings.correctionfactorplot.factorchoice==3
        mainhandles.data(file).FRETpairs(pair).gammaRemoved = 1;
        mainhandles.data(file).FRETpairs(pair).gamma = [];
    end
end

% Update GUI
updatemainhandles(mainhandles)
updateCorrectionFactorPairlist(handles.main,handles.figure1)
updateCorrectionFactorPlots(handles.main,handles.figure1)

function CorrectionFactorPanel_SelectionChangeFcn(hObject, eventdata, handles) %% Callback for changing the radiobutton correction factor selection
handles = turnofftogglesCorrectionWindow(handles);
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'DleakageRadiobutton'
        mainhandles.settings.correctionfactorplot.factorchoice = 1;
        set(handles.figure1,'name','Correction Factor Window: Donor Leakage','numbertitle','off')
        set(handles.CorrectionFactorDefTextbox,'String',sprintf(...
            'Donor leakage factor is A/D for D-only species'))
    case 'AdirectRadiobutton'
        mainhandles.settings.correctionfactorplot.factorchoice = 2;
        set(handles.figure1,'name','Correction Factor Window: Direct Acceptor Excitation','numbertitle','off')
        set(handles.CorrectionFactorDefTextbox,'String',sprintf(...
            'Direct A excitation factor is A/AA for A-only species'))
    case 'GammaRadiobutton'
        mainhandles.settings.correctionfactorplot.factorchoice = 3;
        set(handles.figure1,'name','Correction Factor Window: Gamma Factor','numbertitle','off')
        set(handles.CorrectionFactorDefTextbox,'String',sprintf(...
            'Gamma factor is (A1-A2)/(D2-D1) at A bleaching events'))
end

updatemainhandles(mainhandles)
updateCorrectionFactorPairlist(handles.main,handles.figure1)
updateCorrectionFactorPlots(handles.main,handles.figure1)

function binSlider_Callback(hObject, ~, handles) %% Callback for changing the bin slider
handles = turnofftogglesCorrectionWindow(handles);
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end
updateCorrectionFactorPlots(handles.main,handles.figure1,'hist')
function binSlider_CreateFcn(hObject, ~, handles) %% Runs when the bin slider is created
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
