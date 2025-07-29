function varargout = dynamicsWindow2(varargin) %% Initializes the GUI
% DYNAMICSWINDOW2 - GUI window associated with iSMS for analysing FRET state
% dynamics
%
%  dynamicsWindow2.m cannot be by called by itself as it relies on handles
%  sent by both the sms.m main figure window and the FRETpairwindow.m upon
%  opening.
%
%  The dynamicswindow2 GUI is programmed using GUIDE. The callbacks of
%  the GUI is found in the dynamicswindow2.m file and is divided into
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

% Last Modified by GUIDE v2.5 16-Mar-2015 17:36:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @dynamicsWindow2_OpeningFcn, ...
    'gui_OutputFcn',  @dynamicsWindow2_OutputFcn, ...
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

function dynamicsWindow2_OpeningFcn(hObject, eventdata, handles, varargin) %% Executes just before GUI is made visible.
% Set position, title and logo. Turn off visibility.
initGUI(handles.figure1, 'FRET State Dynamics Window', 'center');

% Handle to main figure window
handles.main = getappdata(0,'mainhandle');
mainhandles = guidata(handles.main);

% Turn off fitting for now until it is implemented properly:
mainhandles.settings.dynamicsplot.fit = 0;
updatemainhandles(mainhandles)

handles = createDynamicsGridFlex(handles);
set(handles.gridflexPanel,'units','normalized','position',[0 0 1 1])

% Axes
ylabel(handles.TraceAxes,'E','fontunits','normalized')
xlabel(handles.TraceAxes,'Time /frames','fontunits','normalized')
ylabel(handles.HistAxes,'Counts','fontunits','normalized')
xlabel(handles.HistAxes,'Dwell time /frames','fontunits','normalized')
set([handles.TraceAxes handles.HistAxes],'XTickLabel','','YTickLabel','')

% Turn off some things if its a deployed version
turnoffDeployed(mainhandles,[],[],[], handles.figure1);

% % Update GUI according to default settings
% if mainhandles.settings.dynamicsplot.fit
%     set(handles.FitTogglebutton,'value',1)
% end
% FitTogglebutton_Callback(handles.FitTogglebutton, [], handles) % This will show/hide relevant objects
% set(handles.ExponentialsEditbox,'String',mainhandles.settings.dynamicsplot.exponentials)
% set(handles.ExponentialsSlider,'Value',mainhandles.settings.dynamicsplot.exponentials)
% % Update rownames in table
% if mainhandles.settings.dynamicsplot.exponentials==1
%     set(handles.parTable,'RowName',{'I0';'I1';'k'})
% elseif mainhandles.settings.dynamicsplot.exponentials==2
%     set(handles.parTable,'RowName',{'I0';'I1';'k1';'k2';'a'})
% end
% Update handle visibilities
% h = [handles.ExponentialsTextbox handles.ExponentialsEditbox handles.ExponentialsSlider handles.FitTogglebutton handles.parTable handles.binSlider...
%     handles.BinsTextbox handles.ChiSqTextbox handles.ChiSqCounter];
% set(h,'Visible','off')

% Update public
mainhandles = updatePublic(mainhandles,[],[],[],handles.figure1);

% Choose default command line output for FRETpairwindow
handles.output = hObject; % Return handle to GUI window

% Now show GUI and update plots
guidata(handles.figure1,handles)
updateDynamicsList(handles.main,handles.figure1,'all');
updateDynamicsPlot(handles.main,handles.figure1,'all');
% updateDynamicsFit(handles.main,handles.figure1);
set(handles.figure1,'Visible','on')

% Set some GUI settings
setGUIappearance(handles.figure1)

function varargout = dynamicsWindow2_OutputFcn(hObject, ~, handles) %% Outputs from this function are returned to the command line (not used here)
% Get default command line output from handles structure
varargout{1} = handles.output;

function figure1_CloseRequestFcn(hObject, ~, handles) %% Runs when the GUI (i.e. handles.figure1) is being closed
% Turn off toggle button in main window
try
    mainhandles = guidata(handles.main);
    set(mainhandles.Toolbar_dynamicswindow,'State','off')
end

% Aims to delete all data and handles used by the program before closing
try cla(handles.TraceAxes)
    cla(handles.HistAxes)
    handles = [];
    handles.figure1 = hObject;
    guidata(hObject,handles)
end % Delete all fields in the handles structure (data, settings, etc.)

% Close GUI
try delete(hObject), end

% --------------------------------------------------------------------
% ----------------- Callback-functions start hereafter ---------------
% - Tip: Fold all code for an overview (Ctrl+= on american keyboard) -
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% ------------------------------- Menus ------------------------------
% --------------------------------------------------------------------

function ExportMenu_Callback(hObject, ~, handles) %% The file menu

function Export_Figure_Callback(hObject, eventdata, handles)
mymsgbox('Right-click inside figure for export options.')

function Export_SMD_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'smd','dynamics');

function Export_ASCII_Callback(hObject, ~, handles) %% Callback for the export to ASCII item in the file menu
exportMoleculesCallback(handles.main,'ascii','dynamics');

function Export_vbFRET_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'vbFRET','dynamics');

function Export_HaMMy_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'hammy','dynamics');

function Export_boba_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'boba','dynamics');

function Export_Workspace_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'workspace','dynamics');

function Export_Plot_Callback(hObject, eventdata, handles)
mymsgbox('Right-click inside figure for export options.')

function SettingsMenu_Callback(hObject, ~, handles) %% The settings menu

function Settings_vbFRET_Callback(hObject, ~, handles) %% Open vbFRET settings dialog
mainhandles = vbFRETsettings(handles.main); % Opens a dialog and saves to mainhandles structure

function Settings_RateAnalysis_Callback(hObject, ~, handles) %% Settings for rate analysis

function Settings_DwellTimes_Callback(hObject, eventdata, handles)
mainhandles = dwelltimesSettingsCallback(handles);

function Settings_DSplotTimefilter_Callback(hObject, eventdata, handles)
% Open dialog window
TDSplot_TimefilterDialog;
uiwait(TDSplot_TimefilterDialog)

% Update plot
mainhandles = getmainhandles(handles); % Get handles structure to the main window (sms)
if isempty(mainhandles)
    return
end
if get(handles.PlotPopupmenu,'Value')==3
    updateDynamicsPlot(handles.main,handles.figure1,'all')
end

function HelpMenu_Callback(hObject, ~, handles) %% The help menu

function Help_mfile_Callback(hObject, ~, handles) %% Open this m-file
edit dynamicsWindow2.m

function Help_figfile_Callback(hObject, ~, handles) %% Open this fig file in GUIDE
guide dynamicsWindow2

function Help_gridflexfile_Callback(hObject, eventdata, handles)
edit createDynamicsGridFlex.m

function Help_updateplotfcn_Callback(hObject, eventdata, handles)
edit updateDynamicsPlot.m

function Help_vbfretfile_Callback(hObject, eventdata, handles)
edit vbAnalysis.m

% --------------------------------------------------------------------
% ----------------------------- Toolbar ------------------------------
% --------------------------------------------------------------------

function Toolbar_Edit_OnCallback(hObject, eventdata, handles)
plotedit('on')

function Toolbar_Edit_OffCallback(hObject, eventdata, handles)
plotedit('off')

function Toolbar_runvbFRET_ClickedCallback(hObject, ~, handles) %% The run vbFRET analysis button in the Toolbar
mainhandles = getmainhandles(handles); % Get handles structure to the main window (sms)
if isempty(mainhandles)
    return
end

% Open selection dialog
selectedPairs = selectionDlg(mainhandles,'vbFRET analysis','Select traces to analyse: ','pair');
if isempty(selectedPairs)
    return
end

% Run calculation
[mainhandles,returnedErr,errmsg] = vbAnalysis(handles.main,selectedPairs,'E'); % This will also update both listbox strings and plots through updateDynamicsList and updateDynamicsPlot

% Err message
if returnedErr
    mywarndlg(errmsg,'iSMS')
end

% Select calculated trace
listedPairs = getPairs(handles.main,'Dynamics');
if isempty(listedPairs)
    return
end

% New selection
idx = find( ismember(listedPairs,selectedPairs(end,:), 'rows', 'legacy') );
if isequal(idx, get(handles.PairListbox,'Value'))
    return
end

% Update
set(handles.PairListbox,'Value',idx)
updateDynamicsPlot(handles.main,handles.figure1,'all')
updateDynamicsFit(handles.main,handles.figure1)

% --------------------------------------------------------------------
% ------------------------------- Misc -------------------------------
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% ------------------------------ Objects -----------------------------
% --------------------------------------------------------------------

function PairListbox_Callback(hObject, ~, handles) %% Callback when changing the trace selection in the trace listbox
mainhandles = getmainhandles(handles); % Get handles structure to the main window (sms)
if isempty(mainhandles)
    return
end
if get(handles.PlotPopupmenu,'Value')==3
    updateDynamicsPlot(handles.main,handles.figure1,'all')
else
    updateDynamicsPlot(handles.main,handles.figure1,'trace')
end
updateDynamicsList(handles.main,handles.figure1,'states')
function PairListbox_CreateFcn(hObject, ~, handles) %% Runs when the trace listbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function StateListbox_Callback(hObject, ~, handles) %% Callback when changing the state selection in the state listbox
mainhandles = getmainhandles(handles); % Get handles structure to the main window (sms)
if isempty(mainhandles)
    return
end
if get(handles.PlotPopupmenu,'Value')==1 || get(handles.PlotPopupmenu,'Value')==4
    updateDynamicsPlot(handles.main,handles.figure1,'hist')
    if get(handles.PlotPopupmenu,'Value')==1 && mainhandles.settings.dynamicsplot.fit
        updateDynamicsFit(handles.main,handles.figure1)
    end
end
function StateListbox_CreateFcn(hObject, ~, handles) %% Runs when the state listbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DeleteTracePushbutton_Callback(hObject, ~, handles) %% Delete the stored vbFRET analysis of selected traces
mainhandles = getmainhandles(handles); % Get handles structure to the main window (sms)
if isempty(mainhandles)
    return
end
plottedPairs = getPairs(handles.main, 'Dynamics');
if isempty(plottedPairs)
    return
end

pairchoices = get(handles.PairListbox,'Value');
selectedPairs = plottedPairs(pairchoices,:); % Pairs selected in the dynamics window [file pair;...]

% Delete
for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    mainhandles.data(file).FRETpairs(pair).vbfitE_fit = [];
    mainhandles.data(file).FRETpairs(pair).vbfitE_bestLP = [];
    mainhandles.data(file).FRETpairs(pair).vbfitE_out = [];
    mainhandles.data(file).FRETpairs(pair).vbfitE_mix = [];
    mainhandles.data(file).FRETpairs(pair).vbfitE_idx = [];
end

% Set new pair selection
Epairs = size(plottedPairs,1)-size(selectedPairs,1);
if (Epairs==0) % If there are no FRET-pairs left
    set(handles.PairListbox,'Value',1)
elseif length(pairchoices) > 1 % If there were more than one pair selected, set the value to the first
    if min(pairchoices) <= Epairs
        set(handles.PairListbox,'Value',min(pairchoices))
    else set(handles.PairListbox,'Value',Epairs)
    end
elseif pairchoices > Epairs % If the selected pair was the last
    set(handles.PairListbox,'Value',Epairs)
else
    set(handles.PairListbox,'Value',pairchoices) % Else set value to the same as before
end

% Updates
updatemainhandles(mainhandles)
updateDynamicsList(handles.main,handles.figure1,'all')
updateDynamicsPlot(handles.main,handles.figure1,'all')
if mainhandles.settings.dynamicsplot.fit
    updateDynamicsFit(handles.main,handles.figure1)
end

function PlotPopupmenu_Callback(hObject, ~, handles) %% Callback when changing the plot type from the popup menu
mainhandles = getmainhandles(handles); % Get handles structure to the main window (sms)
if isempty(mainhandles)
    return
end
value = get(handles.PlotPopupmenu,'Value');

% Update handles structure
% mainhandles.settings.dynamicsplot.histplot = value;
% updatemainhandles(mainhandles)

% Update handle visibilities
% h = [handles.ExponentialsTextbox handles.ExponentialsEditbox handles.ExponentialsSlider handles.FitTogglebutton handles.parTable ...
%     handles.ChiSqTextbox handles.ChiSqCounter handles.binSlider handles.BinsTextbox handles.BinCounter];
h = [handles.binSlider handles.BinsTextbox handles.BinCounter];
if value == 1
    set(h,'Visible','on')
    if ~mainhandles.settings.dynamicsplot.fit
        set([handles.ChiSqTextbox handles.ChiSqCounter],'Visible','off')
    end
else
    set(h,'Visible','off')
end
if value==3 || value==4
    set(handles.binSlider,'Value',10)
    set(handles.BinCounter,'String',10)
    set([handles.binSlider handles.BinsTextbox handles.BinCounter],'Visible','on')
end

% Update plots
updateDynamicsPlot(handles.main,handles.figure1,'hist')
if mainhandles.settings.dynamicsplot.fit
    updateDynamicsFit(handles.main,handles.figure1)
end
function PlotPopupmenu_CreateFcn(hObject, ~, handles) %% Runs when the plot type popup menu is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function binSlider_Callback(hObject, ~, handles) %% Callback when changing the slider value defining hist bin size
mainhandles = getmainhandles(handles); % Get handles structure to the main window (sms)
if isempty(mainhandles)
    return
end
updateDynamicsPlot(handles.main,handles.figure1,'hist')
if mainhandles.settings.dynamicsplot.fit
    updateDynamicsFit(handles.main,handles.figure1)
end
set(handles.BinCounter,'String',get(hObject,'Value'))
function binSlider_CreateFcn(hObject, ~, handles) %% Runs when the bin slider is created
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function ExponentialsEditbox_Callback(hObject, ~, handles) %% Editbox specifying number of exponentials used for fitting dwell time plot
mainhandles = getmainhandles(handles); % Get handles structure to the main window (sms)
if isempty(mainhandles)
    return
end

% Value
value = round(abs(str2num(get(handles.ExponentialsEditbox,'String'))));
if value<1
    value = 1;
elseif value > 2
    value = 2;
end

% Update
set(handles.ExponentialsSlider,'Value',value)
mainhandles.settings.dynamicsplot.exponentials = value;
updatemainhandles(mainhandles)
updateDynamicsFit(handles.main,handles.figure1) % Updates both fit and plot of fit

% Update rownames in table
if mainhandles.settings.dynamicsplot.exponentials==1
    set(handles.parTable,'RowName',{'I0';'I1';'k'})
elseif mainhandles.settings.dynamicsplot.exponentials==2
    set(handles.parTable,'RowName',{'I0';'I1';'k1';'k2';'a'})
end
function ExponentialsEditbox_CreateFcn(hObject, ~, handles) %% Runs when the editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ExponentialsSlider_Callback(hObject, ~, handles) %% Slider denoting number of exponentials used for fitting dwell time plot
mainhandles = getmainhandles(handles); % Get handles structure to the main window (sms)
if isempty(mainhandles)
    return
end

% Value
value = get(handles.ExponentialsSlider,'Value');

% Update
set(handles.ExponentialsEditbox,'String',value)
mainhandles.settings.dynamicsplot.exponentials = value;
updatemainhandles(mainhandles)
updateDynamicsFit(handles.main,handles.figure1) % Update both fit and plot of fit

% Update rownames in table
if mainhandles.settings.dynamicsplot.exponentials==1
    set(handles.parTable,'RowName',{'I0';'I1';'k'})
elseif mainhandles.settings.dynamicsplot.exponentials==2
    set(handles.parTable,'RowName',{'I0';'I1';'k1';'k2';'a'})
end
function ExponentialsSlider_CreateFcn(hObject, ~, handles) %% Runs when the slider is created
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function FitTogglebutton_Callback(hObject, ~, handles) %% Toggle button setting whether to fit plotted dwell times
mainhandles = getmainhandles(handles); % Get handles structure to the main window (sms)
if isempty(mainhandles)
    return
end

% Update handles structure
h = [handles.parTable handles.ChiSqTextbox...
    handles.ChiSqCounter handles.ExponentialsTextbox...
    handles.ExponentialsEditbox handles.ExponentialsSlider];

if get(handles.FitTogglebutton,'Value')==0
    mainhandles.settings.dynamicsplot.fit = 0;
    set(handles.parTable,'data',[])
    set(h,'Visible','off')

else
    mainhandles.settings.dynamicsplot.fit = 1;
    if mainhandles.settings.dynamicsplot.exponentials==1
        set(handles.parTable,'RowName',{'I0';'I1';'k'})
    elseif mainhandles.settings.dynamicsplot.exponentials==2
        set(handles.parTable,'RowName',{'I0';'I1';'k1';'k2';'a'})
    end
    set(h,'Visible','on')
end
updatemainhandles(mainhandles)

% Update fit
updateDynamicsFit(handles.main,handles.figure1)

function Help_TimeUnits_Callback(hObject, eventdata, handles)
str = sprintf(['To convert time units from frames to seconds you must set the integration time of the raw movie file (ms/frame).\n\n'...
    'The integration time of each file is set from the ''File->File settings'' menu in the main window.\n\n'...
    'When an integration time is set for a given file the time units are automatically converted to seconds.']);
mymsgbox(str)
