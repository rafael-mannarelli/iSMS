function varargout = driftWindow(varargin) %% Initializes the GUI
% DRIFTWINDOW - GUI associated with iSMS for analysing and compensating
% drift
%
%  driftWindow.m cannot be by called by itself as it relies on handles
%  sent by both the sms.m main figure window upon opening.
%
%  The driftwindow GUI is programmed using GUIDE. The callbacks of
%  the GUI is found in the driftWindow.m file and is divided into
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

% Last Modified by GUIDE v2.5 20-Aug-2014 13:02:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @driftWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @driftWindow_OutputFcn, ...
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

function driftWindow_OpeningFcn(hObject, eventdata, handles, varargin) %% Executes just before GUI is made visible.
% Set position, title and logo. Turn off visibility.
initGUI(handles.figure1, 'Drift Window', 'center');

% Handle to main figure window
handles.main = getappdata(0,'mainhandle');
mainhandles = guidata(handles.main);
guidata(handles.figure1,handles)

% Axes
ylabel(handles.DDtraceAxes,'D_e_m - D_e_x_c')
ylabel(handles.AAtraceAxes,getYlabel(mainhandles,'driftwindowAx2'))
ylabel(handles.EtraceAxes,'E')
xlabel(handles.EtraceAxes,'Time /frames')
set([handles.DDtraceAxes handles.AAtraceAxes handles.EtraceAxes], 'XTickLabel','', 'YTickLabel', '')
linkaxes([handles.DDtraceAxes handles.AAtraceAxes handles.EtraceAxes],'x')

ylabel(handles.driftAxes1,'y drift /pixels')
xlabel(handles.driftAxes1,'x drift /pixels')
ylabel(handles.driftAxes2,'Total drift /pixels')
xlabel(handles.driftAxes2,'Time /frames')
box(handles.driftAxes1,'on')
box(handles.driftAxes2,'on')
box(handles.DDtraceAxes,'on')
box(handles.AAtraceAxes,'on')
box(handles.EtraceAxes,'on')
box(handles.DDimageAxes1,'on')
box(handles.DDimageAxes2,'on')
box(handles.AAimageAxes1,'on')
box(handles.AAimageAxes2,'on')

% Disable zooming on molecule images (because donor/acceptor center must be in the center of the image)
h = zoom(handles.figure1);
setAllowAxesZoom(h,[handles.DDimageAxes1 handles.DDimageAxes2 handles.AAimageAxes1 handles.AAimageAxes2],false);

% Update GUI according to default settings

% Save current properties of cursor and graphics handles
handles.functionHandles.cursorPointer = get(handles.figure1, 'Pointer');

% Turn off some things if its a deployed version
turnoffDeployed(mainhandles,[],[],[],[],[], handles.figure1);

% Choose default command line output of this GUI window
handles.output = hObject; % Return handle to GUI window

% Now show and update GUI
guidata(handles.figure1,handles)
updatefileslist(handles.main,[],'driftwindow',handles.figure1)
if ~isempty(mainhandles.data) && mainhandles.data(1).drifting.choice
    set(handles.CompensateCheckbox,'Value',1)
    CompensateCheckbox_Callback(handles.CompensateCheckbox, [], handles, 0)
end
updateDriftWindowPairlist(handles.main,handles.figure1)
mainhandles = updateDriftWindowPlots(handles.main,handles.figure1);

set(handles.figure1,'Visible','on')

% Set some GUI settings
setGUIappearance(handles.figure1)

function varargout = driftWindow_OutputFcn(hObject, ~, handles) %% Outputs from this function are returned to the command line (not used here)
varargout{1} = handles.output;

function figure1_CloseRequestFcn(hObject, ~, handles) %% Runs when the GUI (i.e. handles.figure1) is being closed
% Turn off button in main window
try
    mainhandles = guidata(handles.main);
    set(mainhandles.Tools_DriftAnalysisWindow,'Checked','off')
end

% Aims to delete all data and handles used by the program before closing
try cla(handles.driftAxes1)
    cla(handles.driftAxes2)
    cla(handles.DDtraceAxes)
    cla(handles.AAtraceAxes)
    cla(handles.EtraceAxes)
    cla(handles.DDimageAxes1)
    cla(handles.DDimageAxes2)
    cla(handles.AAimageAxes1)
    cla(handles.AAimageAxes2)
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

function FileMenu_Callback(hObject, ~, handles) %% The file menu

function File_ExportFigure_Callback(hObject, ~, handles) %% The export figure callback from the file menu
% Open a dialog for specifying export properties
settings = export_fig_dlg;
if isempty(settings)
    return
end

% Handles of objects to hide when exporting figure
h = [handles.FilesListbox handles.FilesTextbox handles.AnalysePushbutton...
    handles.CompensateCheckbox handles.PairsTextbox handles.PairListbox...
    handles.CompensationPanel...
    handles.BeforeTextbox1 handles.BeforeTextbox handles.AfterTextbox];

% Turn on waitbar
hWaitbar = mywaitbar(1,'Exporting figure. Please wait...','name','iSMS');
setFigOnTop % Sets the waitbar so that it is always in front

% Turn GUI into white empty background
backColor = get(handles.figure1,'Color');
if settings.transparent
    h2 = [handles.DDtraceAxes handles.AAtraceAxes handles.EtraceAxes handles.driftAxes1 handles.driftAxes2];
    set(h2,'Color','none')
end
datacursor = 0; % Marker off whether data cursor is on or off
cursor = datacursormode(handles.figure1);

if strcmp(get(cursor,'Enable'),'on') % If data cursor mode is on, turn it off
    set(cursor,'Enable','off')
    datacursor = 1;
end
set(h,'Visible','off') % Turn of GUI object visibilities
set(handles.figure1,'Color','white') % Set GUI background to white

panelTitle = get(handles.CompensationPanel,'Title');
set(handles.CompensationPanel,'Title','')

% Export figure
try
    figure(handles.figure1)
    eval(settings.command) % This will run export_fig with settings specified in export_fig_dlg
    
catch err
    fprintf('Error message from export_fig: %s', err.message)
    
    % Turn GUI back to original
    set(h,'Visible','on')
    set(handles.figure1,'Color', backColor)
    if datacursor
        set(cursor,'Enable','on')
    end
    
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
set(handles.CompensationPanel,'Title',panelTitle)
set(h,'Visible','on')
set(handles.figure1,'Color', backColor)
if settings.transparent
    set(h2,'Color','white')
end
if datacursor
    set(cursor,'Enable','on')
end
FilesListbox_Callback(handles.FilesListbox, [], handles)

% Delete waitbar
try delete(hWaitbar), end

function SettingsMenu_Callback(hObject, ~, handles) %% The settings menu

function Settings_Drift_Callback(hObject, ~, handles) %% Opens drift analysis settings dialog
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

% Open dialog
mainhandles = driftSettings(handles.main);

function ToolsMenu_Callback(hObject, ~, handles) %% The tools menu

function Tools_RunAnalysisAll_Callback(hObject, ~, handles) %% Callback for the run drift analysis on all files item from the tools menu
mainhandles = driftanalysisAllCallback(handles);

function Tools_SyntheticDriftMenu_Callback(hObject, ~, handles) %% Synthetic drift sub menu in the tools menu

function Tools_SyntheticDrift_Simulate_Callback(hObject, ~, handles) %% Simulates synthetic drift in ROI movies
mainhandles = syntheticdriftCallback(handles);

function Tools_SyntheticDrift_Reset_Callback(hObject, ~, handles) %% Resets ROI movies
set(handles.CompensateCheckbox,'Value',0)
CompensateCheckbox_Callback(handles.CompensateCheckbox, [], handles, 0)
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end
if isempty(mainhandles.data)
    return
end

mainhandles = saveROImovies(mainhandles,'all');
AnalysePushbutton_Callback(handles.AnalysePushbutton, [], handles)

function Tools_ForceUpdate_Callback(hObject, eventdata, handles)
updateDriftWindowPairlist(handles.main,handles.figure1)
mainhandles = updateDriftWindowPlots(handles.main,handles.figure1);

function HelpMenu_Callback(hObject, ~, handles) %% The help menu

function Help_Documentation_Callback(hObject, eventdata, handles)
myopenURL('http://isms.au.dk/documentation/drift-compensation/')

function Help_mfile_Callback(hObject, ~, handles) %% Open this m-file
edit driftWindow.m

function Help_figfile_Callback(hObject, ~, handles) %% Open fig file in GUIDE
guide driftWindow

function Help_updateplotfcn_Callback(hObject, eventdata, handles)
edit updateDriftWindowPlots.m

function Help_driftanalysis_Callback(hObject, eventdata, handles)
edit analyseDrift.m

function Help_driftcompensationfile_Callback(hObject, eventdata, handles)
edit compensateDrift.m

% --------------------------------------------------------------------
% ----------------------------- Toolbar ------------------------------
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% ------------------------------- Misc -------------------------------
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% ------------------------------ Objects -----------------------------
% --------------------------------------------------------------------

function FilesListbox_Callback(hObject, ~, handles) %% Callback for selection change in files listbox
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end
filechoice = get(handles.FilesListbox,'Value');

if mainhandles.data(filechoice).drifting.choice && get(handles.CompensateCheckbox,'Value')==0
    set(handles.CompensateCheckbox,'Value',1)
elseif ~mainhandles.data(filechoice).drifting.choice && get(handles.CompensateCheckbox,'Value')==1
    set(handles.CompensateCheckbox,'Value',0)
end
CompensateCheckbox_Callback(handles.CompensateCheckbox, [], handles, 0)

updateDriftWindowPairlist(handles.main,handles.figure1)
mainhandles = updateDriftWindowPlots(handles.main,handles.figure1,'all');
function FilesListbox_CreateFcn(hObject, ~, handles) %% Runs when the files listbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PairListbox_Callback(hObject, ~, handles) %% Callback for selection change in FRET pair listbox
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end
mainhandles = updateDriftWindowPlots(handles.main,handles.figure1,'pair');
function PairListbox_CreateFcn(hObject, ~, handles) %% Runs when the pair listbox is created upon startup
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AnalysePushbutton_Callback(hObject, ~, handles) %% Callback for the analyse button
mainhandles = analysedriftCallback(handles);

function CompensateCheckbox_Callback(hObject, ~, handles, runCompensation) %% Callback for selection change in compensate checkbox
mainhandles = compensatedriftCheckboxCallback(handles);
