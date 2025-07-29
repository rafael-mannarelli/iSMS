function varargout = FRETpairwindow(varargin) %% Initializes the GUI
% FRETPAIRWINDOW - GUI window associated with sms for plotting time-traces
%
%  FRETpairwindow cannot be by called by itself as it relies on handles
%  sent by the sms.m main figure window upon opening.
%
%  The FRETpairwindow GUI is programmed using GUIDE. The callbacks of
%  the GUI is found in the FRETpairwindow.m file and is divided into
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

% Last Modified by GUIDE v2.5 20-Mar-2015 12:43:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FRETpairwindow_OpeningFcn, ...
    'gui_OutputFcn',  @FRETpairwindow_OutputFcn, ...
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

function FRETpairwindow_OpeningFcn(hObject, eventdata, handles, varargin) %% Executes just before FRETpairwindow is made visible.
% Set position, title and logo. Turn off visibility.
initGUI(handles.figure1, 'FRET Pairs Window', 'west');

% Handle to main figure window
handles.main = getappdata(0,'mainhandle');
mainhandles = guidata(handles.main);

% Initialize some handles
handles.DintROIhandle = [];
handles.AintROIhandle = [];
handles.AAintROIhandle = [];
handles.DintMaskHandle = [];
handles.AintMaskHandle = [];
handles.AAintMaskHandle = [];
handles.DframeSliderHandle = [];
handles.AframeSliderHandle = [];
handles.AAframeSliderHandle = [];

% Axes
ylabel(handles.PRtraceAxes,'E')
xlabel(handles.PRtraceAxes,'Time')
if mainhandles.settings.FRETpairplots.linkaxes
    linkaxes([handles.DDtraceAxes handles.ADtraceAxes handles.AAtraceAxes handles.StraceAxes handles.PRtraceAxes],'x')
end

% Disable zooming on molecule images (because donor/acceptor center must be in the center of the image)
h = zoom(handles.figure1);
setAllowAxesZoom(h,[handles.DDimageAxes handles.ADimageAxes handles.AAimageAxes],false);

% GUI function handles
handles.functionHandles.PairListbox_Callback = @PairListbox_Callback;

% Set GUI properties depending on excitation scheme
mainhandles = updateALEX(mainhandles,handles.figure1); % This may update

% Update menu checkmarks etc.
updateFRETpairwindowGUImenus(mainhandles,handles)

% Update GUI with data
updateFRETpairlist(handles.main,handles.figure1) % Updates the FRET-pair listbox and the FRET-pair counter
selectedPairs = getPairs(handles.main, 'missingTrace'); % Returns FRET pairs from all files that needs to have their intensity traces calculated
if ~isempty(selectedPairs)
    mainhandles = calculateIntensityTraces(handles.main,selectedPairs); % Calculates intensity traces and puts them in the mainhandles.data.DDtrace... structure
end

% Update group list
updategrouplist(mainhandles.figure1,handles.figure1)

% Update visible functionalities
mainhandles = updatePublic(mainhandles,handles.figure1);

% Turn off some things if its a deployed version
turnoffDeployed(mainhandles, handles.figure1);

% Add classification tool for FRET traces from exported list
if isfield(handles,'ToolsMenu') && ishandle(handles.ToolsMenu)
    uimenu(handles.ToolsMenu, 'Label','Classify traces from list...',...
        'Callback',@Tools_ClassifyFromList_Callback, 'Tag','Tools_ClassifyFromList');
    uimenu(handles.ToolsMenu, 'Label','Classify traces with DeepFRET...',...
        'Callback',@Tools_DeepFRET_Callback, 'Tag','Tools_DeepFRET');
end

% UI elements for DeepFRET classification probabilities
tags = {'confidenceValueTextBox','aggregatedValueTextBox','dynamicValueTextBox',...
        'noisyValueTextBox','scrambledValueTextBox','staticValueTextBox'};
for k = 1:numel(tags)
    htmp = findobj(handles.figure1,'Tag',tags{k});
    if ~isempty(htmp)
        handles.(tags{k}) = htmp;
    end
end

% Save current properties of cursor and graphics handles
handles.functionHandles.cursorPointer = get(handles.figure1, 'Pointer');

% Choose default command line output for FRETpairwindow
handles.output = hObject; % Return handle to GUI window

% Now show GUI and update plots
guidata(handles.figure1,handles)
handles = updateFRETpairplots(handles.main,handles.figure1,'all');
handles = updateMoleculeFrameSliderHandles(handles.main,handles.figure1);
updateCorrectionFactors(handles.main,handles.figure1)

% Set some GUI settings
setGUIappearance(handles.figure1, 0)

function varargout = FRETpairwindow_OutputFcn(hObject, ~, handles) %% Outputs from this function are returned to the command line (not used here)
% Resize final time (this function is run at the end of startup)
FRETpairwindowResizeFcn(handles)

% Now show GUI
set(handles.figure1,'Visible','on')

% Output
varargout{1} = handles.output;

function figure1_CloseRequestFcn(hObject, ~, handles) %% Runs when the GUI (i.e. handles.figure1) is closed
% Get mainhandles
try mainhandles = getmainhandles(handles); end

try % Turn off toggle button
    set(mainhandles.Toolbar_FRETpairwindow,'State','off')
end

% Aims to delete all data and handles used by the program before closing
try cla(handles.DDtraceAxes)
    cla(handles.ADtraceAxes)
    cla(handles.AAtraceAxes)
    cla(handles.StraceAxes)
    cla(handles.PRtraceAxes)
    cla(handles.DDimageAxes)
    cla(handles.ADimageAxes)
    cla(handles.AAimageAxes)
    handles = [];
    handles.figure1 = hObject;
    guidata(hObject,handles)
end % Delete all fields in the handles structure (data, settings, etc.)

try
    delete(hObject);
end

function figure1_ResizeFcn(hObject, eventdata, handles)
FRETpairwindowResizeFcn(handles)

% --------------------------------------------------------------------
% ----------------- Callback-functions start hereafter ---------------
% - Tip: Fold all code for an overview (Ctrl+= on american keyboard) -
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% ------------------------------- Menus ------------------------------
% --------------------------------------------------------------------

function ExportMenu_Callback(hObject, eventdata, handles)
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs

function Export_Figure_Callback(hObject, ~, handles) %% The export figure from the Export menu
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs

% Open a dialog for specifying export properties
settings = export_fig_dlg;
if isempty(settings)
    return
end

% Check if histogram window is open now
mainhandles = guidata(handles.main);
hiswin = get(mainhandles.Toolbar_histogramwindow,'State');

% Handles of objects to hide when exporting figure
h = [handles.FRETpairsTextbox handles.PairListbox handles.DeletePairPushbutton...
    handles.paircoordinates handles.PairCoordinatesTextbox ...
    handles.confidenceValueTextBox handles.aggregatedValueTextBox ...
    handles.dynamicValueTextBox handles.noisyValueTextBox ...
    handles.scrambledValueTextBox handles.staticValueTextBox ...
    handles.DDimageAxes handles.ADimageAxes handles.AAimageAxes handles.CorrectionFactorsTextbox...
    handles.DleakTextbox handles.DleakEditbox handles.AdirectTextbox handles.AdirectEditbox handles.GammaTextbox handles.GammaEditbox...
    handles.BleachingEventsTextbox handles.DbleachingsTextbox handles.AbleachingsTextbox handles.DAbleachingsTextbox...
    handles.DbleachCounter handles.AbleachCounter handles.DAbleachCounter...
    handles.ContrastSlider handles.molspecCheckbox];

if strcmpi(get(handles.GroupsTextbox,'Visible'),'on')
    h(end+1) = handles.GroupsTextbox;
    h(end+1) = handles.GroupsListbox;
end

% Turn on waitbar
hWaitbar = mywaitbar(1,'Exporting figure. Please wait...','name','iSMS');
setFigOnTop % Sets the waitbar so that it is always in front

% Turn GUI into white empty background
if settings.transparent
    h2 = [handles.DDtraceAxes handles.ADtraceAxes handles.AAtraceAxes handles.StraceAxes handles.PRtraceAxes];
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

% Export figure
try
    figure(handles.figure1)
    eval(settings.command); % This will run export_fig with settings specified in export_fig_dlg
    
catch err
    fprintf('Error message from export_fig: %s', err.message)
    
    % Turn GUI back to original
    set(h,'Visible','on')
    set(handles.figure1,'Color', [0.94118  0.94118  0.94118])
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
set(h,'Visible','on')
set(handles.figure1,'Color', [0.94118  0.94118  0.94118])
if settings.transparent
    set(h2,'Color','white')
end
if datacursor
    set(cursor,'Enable','on')
end
updateALEX(mainhandles)
FRETpairwindowResizeFcn(handles)

% Delete waitbar
try delete(hWaitbar), end

% If window has been deleted by export fig (for unknown reasons)
mainhandles = guidata(handles.main);
if strcmpi(get(mainhandles.Toolbar_FRETpairwindow,'State'),'off')
    set(mainhandles.Toolbar_FRETpairwindow,'State','on')
    set(mainhandles.Toolbar_histogramwindow,'State','on')
end

function Export_SMD_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'smd','selected');

function Export_ASCII_Callback(hObject, ~, handles) %% The export traces from the Export menu
exportMoleculesCallback(handles.main,'ascii','selected');

function Export_vbFRET_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'vbFRET','selected');

function Export_HaMMy_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'hammy','selected');

function Export_boba_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'boba','selected');

function Export_Workspace_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'workspace','selected');

function Export_Molecule_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'molmovie','selected');

function Export_Plot_Callback(hObject, eventdata, handles)
mymsgbox('Right-click inside figure for export options.')

function Export_SaveSession_Callback(hObject, ~, handles) %% Saves iSMS session
mainhandles = savesession(handles.main);

function SortMenu_Callback(hObject, eventdata, handles)
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs

function Sort_File_Callback(hObject, eventdata, handles)
mainhandles = sortpairsCallback(handles.figure1, 1);

function Sort_Group_Callback(hObject, eventdata, handles)
mainhandles = sortpairsCallback(handles.figure1, 2);

function Sort_avgE_Callback(hObject, eventdata, handles)
mainhandles = sortpairsCallback(handles.figure1, 3);

function Sort_avgS_Callback(hObject, eventdata, handles)
mainhandles = sortpairsCallback(handles.figure1, 4);

function Sort_maxDAsum_Callback(hObject, eventdata, handles)
mainhandles = sortpairsCallback(handles.figure1, 5);

function Sort_maxDD_Callback(hObject, eventdata, handles)
mainhandles = sortpairsCallback(handles.figure1, 6);

function Sort_maxAD_Callback(hObject, eventdata, handles)
mainhandles = sortpairsCallback(handles.figure1, 7);

function Sort_maxAA_Callback(hObject, eventdata, handles)
mainhandles = sortpairsCallback(handles.figure1, 8);

function Sort_Update_Callback(hObject, eventdata, handles)
% Get mainhandles structure
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

% GUI menu ticks
updateFRETpairwindowGUImenus(mainhandles, handles)

% Update sorting
mainhandles = sortpairsCallback(handles.figure1, mainhandles.settings.FRETpairplots.sortpairs);

function ViewMenu_Callback(hObject, ~, handles) %% The view menu
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs

function View_PlayMovies_Callback(hObject, ~, handles) %% Plays movie of each of the four DD, AD, DA, and AA traces
playmoleculemoviesCallback(handles);

function View_ImageSliders_Callback(hObject, ~, handles) %% The image sliders submenu from the view menu

function View_ImageSliders_Activate_Callback(hObject, ~, handles) %% Activate molecule avg. image frame sliders
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

% Update
mainhandles.settings.FRETpairplots.frameSliders = abs(mainhandles.settings.FRETpairplots.frameSliders-1);
updatemainhandles(mainhandles)
if mainhandles.settings.FRETpairplots.frameSliders==1
    set(handles.Toolbar_frameSliders,'State','on')
elseif mainhandles.settings.FRETpairplots.frameSliders==0
    set(handles.Toolbar_frameSliders,'State','off')
end
updateFRETpairwindowGUImenus(mainhandles,handles)

function View_ImageSliders_Link_Callback(hObject, ~, handles) %% Links molecule frame sliders
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Update setting
mainhandles.settings.FRETpairplots.linkFrameSliders = abs(mainhandles.settings.FRETpairplots.linkFrameSliders-1);
updatemainhandles(mainhandles)

% Update sliders and menu
handles = updateMoleculeFrameSliderHandles(handles.main,handles.figure1);
updateFRETpairwindowGUImenus(mainhandles,handles)

function View_PixelHighlighting_Callback(hObject, ~, handles) %% The pixel highlighting sub-menu from the View menu

function View_PixelHighlighting_IntMask_Callback(hObject, ~, handles) %% Show/hide pixels used for calculating the intensity
Toolbar_ShowIntegrationArea_ClickedCallback(handles.Toolbar_ShowIntegrationArea, [], handles)

function View_PixelHighlighting_BackMask_Callback(hObject, ~, handles) %% Show/hide pixels used for calculating the background
Toolbar_ShowBackgroundPixels_ClickedCallback(handles.Toolbar_ShowBackgroundPixels, [], handles)

function View_PixelHighlighting_Properties_Callback(hObject, ~, handles) %% Open input dialog for specifying pixel highlighting properties
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

%--------------------- Prepare dialog box --------------------%
prompt = {'Highlight pixels used for calculating the intensity' 'showIntPixels';...
    'Transparency (0-100%): ' 'intMaskTransparency';...
    'Color: ' 'intMaskColor';...
    'Highlight pixels used for calculating the background' 'showBackPixels';...
    'Transparency (0-100%): ' 'backMaskTransparency';...
    'Color: ' 'backMaskColor'};
name = 'Highlight region settings';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% Choices
% Integration pixels
formats(2,1).type = 'check';
formats(3,1).type = 'edit';
formats(3,1).size   = 50;
formats(3,1).format = 'float';
formats(4,1).type = 'list';
formats(4,1).style = 'popupmenu';
formats(4,1).items = {'white','gray'};
% Background pixels
formats(7,1).type = 'check';
formats(8,1).type = 'edit';
formats(8,1).size   = 50;
formats(8,1).format = 'float';
formats(9,1).type = 'list';
formats(9,1).style = 'popupmenu';
formats(9,1).items = {'white','gray'};

% Default choices
% Integration pixels
DefAns.showIntPixels = mainhandles.settings.FRETpairplots.showIntPixels;
DefAns.intMaskTransparency = mainhandles.settings.FRETpairplots.intMaskTransparency*100;
if strcmp(mainhandles.settings.FRETpairplots.intMaskColor,'white')
    DefAns.intMaskColor = 1;
elseif strcmp(mainhandles.settings.FRETpairplots.intMaskColor,'gray')
    DefAns.intMaskColor = 2;
end
% Background pixels
DefAns.showBackPixels = mainhandles.settings.FRETpairplots.showBackPixels;
DefAns.backMaskTransparency = mainhandles.settings.FRETpairplots.backMaskTransparency*100;
if strcmp(mainhandles.settings.FRETpairplots.backMaskColor,'white')
    DefAns.backMaskColor = 1;
elseif strcmp(mainhandles.settings.FRETpairplots.backMaskColor,'gray')
    DefAns.backMaskColor = 2;
end

options.CancelButton = 'on';

%------------------------- Open dialog box ----------------------%
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1) || (isequal(DefAns,answer))
    return
end

%------------------------ Set new settings ----------------------%
% Integration pixels
mainhandles.settings.FRETpairplots.showIntPixels = answer.showIntPixels;
if answer.intMaskTransparency < 0
    mainhandles.settings.FRETpairplots.intMaskTransparency = 0;
elseif answer.intMaskTransparency > 100
    mainhandles.settings.FRETpairplots.intMaskTransparency = 1;
else
    mainhandles.settings.FRETpairplots.intMaskTransparency = answer.intMaskTransparency/100;
end
if answer.intMaskColor == 1
    mainhandles.settings.FRETpairplots.intMaskColor = 'white';
elseif answer.intMaskColor == 2
    mainhandles.settings.FRETpairplots.intMaskColor = 'gray';
end
% Background pixels
mainhandles.settings.FRETpairplots.showBackPixels = answer.showBackPixels;
if answer.backMaskTransparency < 0
    mainhandles.settings.FRETpairplots.backMaskTransparency = 0;
elseif answer.backMaskTransparency > 100
    mainhandles.settings.FRETpairplots.backMaskTransparency = 1;
else
    mainhandles.settings.FRETpairplots.backMaskTransparency = answer.backMaskTransparency/100;
end
if answer.backMaskColor == 1
    mainhandles.settings.FRETpairplots.backMaskColor = 'white';
elseif answer.backMaskColor == 2
    mainhandles.settings.FRETpairplots.backMaskColor = 'gray';
end

%--------------------------- Update GUI -------------------------%
updatemainhandles(mainhandles)
handles = updateFRETpairplots(handles.main,handles.figure1,'images');
handles = updateMoleculeFrameSliderHandles(handles.main,handles.figure1);

function View_liveupdateTrace_Callback(hObject, eventdata, handles)
% Get mainhandles structure
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

% New setting
mainhandles.settings.FRETpairplots.liveupdateTrace = abs(mainhandles.settings.FRETpairplots.liveupdateTrace-1); % Width of background circle / pixels

% Update
updatemainhandles(mainhandles)
updateFRETpairwindowGUImenus(mainhandles,handles)

function View_logImage_Callback(hObject, ~, handles) %% Sets whether to plot the molecule image in log-scale intensity
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

if mainhandles.settings.FRETpairplots.logImage==0
    mainhandles.settings.FRETpairplots.logImage = 1;
    set(handles.View_logImage,'Checked','on')
elseif mainhandles.settings.FRETpairplots.logImage==1
    mainhandles.settings.FRETpairplots.logImage = 0;
    set(handles.View_logImage,'Checked','off')
end
updatemainhandles(mainhandles)
handles = updateFRETpairplots(handles.main,handles.figure1,'images');

function View_ZeroLines_Callback(hObject, ~, handles) %% This button from the View menu adds or removes a zero-line to each of the trace-plots
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

if mainhandles.settings.FRETpairplots.zeroline==0
    mainhandles.settings.FRETpairplots.zeroline = 1;
    set(handles.View_ZeroLines,'Checked','on')
elseif mainhandles.settings.FRETpairplots.zeroline==1
    mainhandles.settings.FRETpairplots.zeroline = 0;
    set(handles.View_ZeroLines,'Checked','off')
end
updatemainhandles(mainhandles)
handles = updateFRETpairplots(handles.main,handles.figure1,'traces');
handles = updateMoleculeFrameSliderHandles(handles.main,handles.figure1);

function View_BackgroundTraces_Callback(hObject, ~, handles) %% Hide/show background traces in intensity plots
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles);
if isempty(mainhandles) % If main window for some reason is no longer a handle
    return
end

if mainhandles.settings.FRETpairplots.plotBackground==0
    mainhandles.settings.FRETpairplots.plotBackground = 1;
    set(handles.View_BackgroundTraces,'Checked','on')
elseif mainhandles.settings.FRETpairplots.plotBackground==1
    mainhandles.settings.FRETpairplots.plotBackground = 2;
    set(handles.View_BackgroundTraces,'Checked','on')
elseif mainhandles.settings.FRETpairplots.plotBackground==2
    mainhandles.settings.FRETpairplots.plotBackground = 0;
    set(handles.View_BackgroundTraces,'Checked','off')
end
updatemainhandles(mainhandles)
handles = updateFRETpairplots(handles.main,handles.figure1,'traces');
handles = updateMoleculeFrameSliderHandles(handles.main,handles.figure1);

function View_AtraceMenu_Callback(hObject, eventdata, handles)

function View_AtraceMenu_Raw_Callback(hObject, eventdata, handles)
[handles, mainhandles] = viewAtraceCallback(handles,0,'plotADcorr');

function View_AtraceMenu_ADcorr_Callback(hObject, eventdata, handles)
[handles, mainhandles] = viewAtraceCallback(handles,1,'plotADcorr');

function View_DtraceMenu_Callback(hObject, eventdata, handles)

function View_DtraceMenu_Raw_Callback(hObject, eventdata, handles)
[handles, mainhandles] = viewAtraceCallback(handles,0,'plotDgamma');

function View_DtraceMenu_gamma_Callback(hObject, eventdata, handles)
[handles, mainhandles] = viewAtraceCallback(handles,1,'plotDgamma');

function View_avgFRET_Callback(hObject, eventdata, handles)
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Update settings structure
if mainhandles.settings.FRETpairplots.avgFRET==0
    mainhandles.settings.FRETpairplots.avgFRET = 1;
    set(handles.View_avgFRET,'Checked','on')
elseif mainhandles.settings.FRETpairplots.avgFRET==1
    mainhandles.settings.FRETpairplots.avgFRET = 0;
    set(handles.View_avgFRET,'Checked','off')
end

% Update
updatemainhandles(mainhandles)
updateFRETpairlist(handles.main,handles.figure1)

function View_LinkAxes_Callback(hObject, ~, handles) %% Link/unlink x axes
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

if mainhandles.settings.FRETpairplots.linkaxes==0
    mainhandles.settings.FRETpairplots.linkaxes = 1;
    set(handles.View_LinkAxes,'Checked','on')
    linkaxes([handles.DDtraceAxes handles.ADtraceAxes handles.AAtraceAxes handles.StraceAxes handles.PRtraceAxes],'x')
elseif mainhandles.settings.FRETpairplots.linkaxes==1
    mainhandles.settings.FRETpairplots.linkaxes = 0;
    set(handles.View_LinkAxes,'Checked','off')
    linkaxes([handles.DDtraceAxes handles.ADtraceAxes handles.AAtraceAxes handles.StraceAxes handles.PRtraceAxes],'off')
end
updatemainhandles(mainhandles)
handles = updateFRETpairplots(handles.main,handles.figure1,'traces');
handles = updateMoleculeFrameSliderHandles(handles.main,handles.figure1);

function View_AutoZoom_Callback(hObject, ~, handles) %% Auto-zoom y-axes in intensity traces
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Put in handles structure
if mainhandles.settings.FRETpairplots.autozoom==0
    mainhandles.settings.FRETpairplots.autozoom = 1;
    set(handles.View_AutoZoom,'Checked','on')
elseif mainhandles.settings.FRETpairplots.autozoom==1
    mainhandles.settings.FRETpairplots.autozoom = 0;
    set(handles.View_AutoZoom,'Checked','off')
end
updatemainhandles(mainhandles)

% Delete frame sliders
handles = deleteframeSliders(handles);

% Update plot
handles = updateFRETpairplots(handles.main,handles.figure1,'traces');
handles = updateMoleculeFrameSliderHandles(handles.main,handles.figure1);

function View_ESylim_Callback(hObject, eventdata, handles)
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Prepare dialog box
prompt = {'S trace: ' '';...
    'y min:' 'Symin';...
    'y max:' 'Symax';...
    'E trace: ' '';...
    'y min:' 'Eymin';...
    'y max:' 'Eymax'};
name = 'Set axes scale';

% Handles formats
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(2,1).type   = 'text';
formats(3,1).type   = 'edit';
formats(3,1).format = 'float';
formats(3,1).size = 80;
formats(3,2).type   = 'edit';
formats(3,2).format = 'float';
formats(3,2).size = 80;
formats(4,1).type   = 'text';
formats(5,1).type   = 'edit';
formats(5,1).format = 'float';
formats(5,1).size = 80;
formats(5,2).type   = 'edit';
formats(5,2).format = 'float';
formats(5,2).size = 80;

% Default answers:
% SExlim = get(handles.SEplot,'xlim');
% SEylim = get(handles.SEplot,'ylim');

DefAns.Symin = mainhandles.settings.FRETpairplots.Sylim(1);
DefAns.Symax = mainhandles.settings.FRETpairplots.Sylim(2);
DefAns.Eymin = mainhandles.settings.FRETpairplots.Eylim(1);
DefAns.Eymax = mainhandles.settings.FRETpairplots.Eylim(2);

% Open input dialogue and get answer
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns); % Open dialog box
if cancelled == 1
    return
end
mainhandles.settings.FRETpairplots.Sylim = sort([answer.Symin answer.Symax]);
mainhandles.settings.FRETpairplots.Eylim = sort([answer.Eymin answer.Eymax]);
updatemainhandles(mainhandles)

% Set axis limits
ylim(handles.StraceAxes, mainhandles.settings.FRETpairplots.Sylim)
ylim(handles.PRtraceAxes, mainhandles.settings.FRETpairplots.Eylim)

function PlotMenu_Callback(hObject, eventdata, handles)
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs

function Plot_DAoverlay_Callback(hObject, ~, handles) %% Plot D and A overlay
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Selected pair
selectedPairs = getPairs(handles.main,'Selected',[],handles.figure1);
if isempty(selectedPairs)
    mymsgbox('There are no selected FRET pairs');
    return
end

% Start exporting FRET pairs one by one
for i = 1:size(selectedPairs,1)
    filechoice = selectedPairs(i,1);
    pairchoice = selectedPairs(i,2);
    
    % Prepare data to export
    DD = mainhandles.data(filechoice).FRETpairs(pairchoice).DDtrace;
    AD = mainhandles.data(filechoice).FRETpairs(pairchoice).ADtrace;
    
    % Attempt to plot in same range
    DD = DD/max(DD);
    DD = DD-min(DD);
    AD = AD/max(AD);
    AD = AD-min(AD);
    
    % Create figure
    fh = figure;
    updatelogo(fh)
    set(fh,'name',sprintf('Pair %i,%i',filechoice,pairchoice),'numbertitle','off')
    
    % Figure size and position
    setTracefigSize(fh,gca,handles.DDtraceAxes)
    
    % Plot
    plot(DD,'g')
    hold on
    plot(AD,'r')
    
    % Axes
    xlabel('Time /frames')
    ylabel('Intensity /rel.')
    ylim([0 1])
    
    % Store in handles structure
    mainhandles.figures{end+1} = fh;
    
end

% Update mainhandles structure
updatemainhandles(mainhandles)

function Plot_SumPlot_Callback(hObject, ~, handles) %% Plots the sum of DD and AD
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Pairs to plot
selectedPairs = getPairs(handles.main, 'Selected', [], handles.figure1);
if isempty(selectedPairs)
    return
end

% Create figure
fh = figure;
updatelogo(fh)

% Figure size and position
setTracefigSize(fh,gca,handles.DDtraceAxes)

% Plot
npairs = size(selectedPairs,1);
for i = 1:npairs
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    subplot(npairs,1,i)
    
    % Calculate sum
    DAbackSum = mainhandles.data(file).FRETpairs(pair).DDback + mainhandles.data(file).FRETpairs(pair).ADback;
    DAsum = mainhandles.data(file).FRETpairs(pair).DDtrace + mainhandles.data(file).FRETpairs(pair).ADtraceCorr + DAbackSum;
    
    % Plot
    plot(DAsum,'-b')
    hold on
    plot(DAbackSum,'-k')
    
    % Ax properties
    title(sprintf('Pair %i,%i',file,pair))
    ylabel('D+A intensity')
    if i == npairs
        xlabel('Time /frames')
    else
        set(gca,'xtick',[])
        set(gca,'xticklabel','')
    end
    
    ylim([min([DAsum(:); DAbackSum(:)]) max([DAsum(:); DAbackSum(:)])])
end

% Update UI context menu
updateUIcontextMenus(handles.main,gca)

function Plot_plotCrossCorrelation_Callback(hObject, ~, handles) %% Plots the autocorrelation plot between DD and AD traces
[mainhandles, handles] = plotcrosscorrCallback(handles);

function Plot_CoordinateCorrelation_Callback(hObject, ~, handles) %% Plots the Stoichiometry factor (avg) as a function of molecule coordinate
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

mainhandles = ScoordinateCorrelationCallback(mainhandles);

function Plot_GroupDistribution_Callback(hObject, eventdata, handles)
mainhandles = groupsplotCallback(handles);

function Plot_AperturePlot_Callback(hObject, eventdata, handles)
mainhandles = apertureplotCallback(handles);

function Plot_Percentile_Callback(hObject, eventdata, handles)
mainhandles = percentileplotCallback(handles);

function SettingsMenu_Callback(hObject, ~, handles) %% The settings menu
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs

function Settings_Integration_Callback(hObject, eventdata, handles)
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

mainhandles.integrationwindowHandle = integrationsettingsWindow; % Opens a modal dialog window
updatemainhandles(mainhandles) % Updates the handle in the mainhandles structure

function Settings_Background_Callback(hObject, ~, handles) %% The Settings -> Background menu
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
[mainhandles, handles] = backgroundSettings(handles.main);

function Settings_CorrectionFactors_Callback(hObject, ~, handles) %% Set correction factors dialog box
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

[mainhandles,handles] = correctionfactorSettingsDlg(handles.main);

function Settings_Bleachfinder_Callback(hObject, ~, handles) %% Settings for the bleach-finder
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Dialog
mainhandles = bleachfinderSettingsCallback(mainhandles);

function Settings_Grouping_Callback(hObject, eventdata, handles)
mainhandles = groupingSettingsCallback(handles);

function ToolsMenu_Callback(hObject, ~, handles) %% The tools menu
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs

function Tools_Bleachfinder_Callback(hObject, ~, handles) %% Auto-detects bleaching events
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

[mainhandles, handles] = bleachfinderCallback(handles.main);

function Tools_ClearBleachingTimes_Callback(hObject, eventdata, handles)
mainhandles = getmainhandles(handles);
allPairs = getPairs(handles.main,'all');
mainhandles = clearBleachingTime(mainhandles,allPairs);

function Tools_ForceUpdate_Callback(hObject, eventdata, handles) %% Force re-calculation of molecule traces and images
% Get mainhandles structure
mainhandles = getmainhandles(handles);

% Get selected FRET pairs
selectedPairs = getPairs(handles.main,'Selected',[],handles.figure1);
if isempty(selectedPairs)
    return
end

% All selected files
filechoices = unique(selectedPairs(:,1));

% Make sure raw data is still there
for i = 1:length(filechoices)
    filechoice = filechoices(i);
    if isempty(mainhandles.data(filechoice).DD_ROImovie)
        
        % Saves ROI movies to handles structure if not already done so
        [mainhandles,MBerror] = saveROImovies(mainhandles);
        if MBerror % If couldn't save ROI movies due to lack of memory, return
            return
        end
    end
end

% Calculate all selected pairs
for i = 1:size(selectedPairs)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    if ~isempty(mainhandles.data(file).DD_ROImovie)
        
        % Calculate intensity traces
        mainhandles = calculateIntensityTraces(mainhandles.figure1,[file pair]);
        
        % Delete molecule images. This will force a recalculation of these
        % before the plotting routine
        mainhandles.data(file).FRETpairs(pair).DD_avgimage = [];
        mainhandles.data(file).FRETpairs(pair).AD_avgimage = [];
        mainhandles.data(file).FRETpairs(pair).AA_avgimage = [];
        updatemainhandles(mainhandles)
        
        % Update plots
        FRETpairwindowHandles = updateFRETpairplots(mainhandles.figure1,mainhandles.FRETpairwindowHandle,'all','all');
    end
end

% Update the histogramwindow
plottedPairs = getPairs(handles.main,'Plotted');
if ~isempty(plottedPairs) && ismember(selectedPairs,plottedPairs, 'rows','legacy') && mainhandles.settings.SEplot.onlytinterest
    mainhandles = updateSEplot(mainhandles.figure1,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
end

function Tools_FilterPairs_Callback(hObject, ~, handles) %% Opens a dialogue for deleting FRET pairs based on criteria
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

mainhandles = filterPairsDialog(mainhandles);

function Tools_CheckBack_Callback(hObject, eventdata, handles)
mainhandles = checkbackgroundCallback(handles);

function Tools_CheckDynamics_Callback(hObject, eventdata, handles)
mainhandles = checkdynamicsCallback(handles);

function Tools_ClassifyFromList_Callback(hObject, eventdata, handles)
% Classify traces listed in a text file into a group

% When created programmatically, this callback may be invoked with only two
% arguments.  Retrieve the handles structure if it was not supplied.
if nargin < 3 || isempty(handles)
    handles = guidata(hObject);
end

handles = turnoffFRETpairwindowtoggles(handles); % Turn off integration ROIs
mainhandles = getmainhandles(handles); % Get main window handles
if isempty(mainhandles)
    return
end

[file, path, chose] = uigetfile3(mainhandles,'results','*.txt', ...
    'Select exported trace list','name','off');
if chose==0
    return
end

listfile = fullfile(path,file);
mainhandles = classifyTracesFromList(mainhandles.figure1, listfile);
% Update GUI with classification results
updateFRETpairlist(mainhandles.figure1, handles.figure1);
updateFRETpairplots(mainhandles.figure1, handles.figure1);

function Tools_DeepFRET_Callback(hObject, eventdata, handles)
% Classify selected traces using DeepFRET

if nargin < 3 || isempty(handles)
    handles = guidata(hObject);
end

handles = turnoffFRETpairwindowtoggles(handles);
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

selectedPairs = selectionDlg(mainhandles,'DeepFRET classification',...
    'Select traces to classify: ','pair');
if isempty(selectedPairs)
    return
end

mainhandles = classifyWithDeepFRET(mainhandles.figure1, selectedPairs);
% Update GUI with classification results
updateFRETpairlist(mainhandles.figure1, handles.figure1);
updateFRETpairplots(mainhandles.figure1, handles.figure1);

function GroupingsMenu_Callback(hObject, ~, handles) %% The Groups menu
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs

function Grouping_NewGroup_Callback(hObject, ~, handles) %% Add molecules to a group
mainhandles = newgroupCallback(handles);

function Grouping_DeleteGroup_Callback(hObject, eventdata, handles)
% Get mainhandles
mainhandles = getmainhandles(handles);

% Check number of groups
% if length(mainhandles.groups)==1
%     mymsgbox('There is only one existing group.')
%     return
% end

% Selected group
groupchoice = get(handles.GroupsListbox,'Value');
if isempty(groupchoice)
    groupchoice = 1;
else
    groupchoice = groupchoice(1);
end

% Prompt for group to delete
group = mylistdlg('ListString',{mainhandles.groups(:).name}',...
    'name','Select group',...
    'SelectionMode','single',...
    'InitialValue', groupchoice,...
    'ListSize', [300 300]);

% Delete group
mainhandles = deleteGroup(mainhandles,group);

function Grouping_SortGroups_Callback(hObject, eventdata, handles)
mainhandles = sortgroupsCallback(handles);

function Grouping_DistributionPlot_Callback(hObject, eventdata, handles)
mainhandles = groupsplotCallback(handles);

function Grouping_GroupSelected_Callback(hObject, ~, handles) %% The put-selected-molecules-in-selected-group menubutton
[mainhandles, handles] = groupselectedCallback(handles);

function Grouping_RemoveFromPrevious_Callback(hObject, eventdata, handles)
% Update settings
mainhandles = getmainhandles(handles);
mainhandles.settings.grouping.removefromPrevious = abs(mainhandles.settings.grouping.removefromPrevious-1);
updatemainhandles(mainhandles)

% Update menu
updateFRETpairwindowGUImenus(mainhandles,handles)

function Grouping_DbleachGroup_Callback(hObject, eventdata, handles)
mainhandles = creategroupforCallback(handles.figure1,'Dbleach');

function Grouping_AbleachGroup_Callback(hObject, eventdata, handles)
mainhandles = creategroupforCallback(handles.figure1,'Ableach');

function Grouping_DAbleachGroup_Callback(hObject, eventdata, handles)
mainhandles = creategroupforCallback(handles.figure1,'DAbleach');

function Grouping_blinkGroup_Callback(hObject, eventdata, handles)
mainhandles = creategroupforCallback(handles.figure1,'blink');

function Grouping_Rename_Callback(hObject, ~, handles) %% Rename groups button from the Grouping menu
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
elseif isempty(mainhandles.groups)
    mymsgbox('No groups defined');
    return
end

%------------- Prepare dialog box ------------%
name = 'Rename groups';

% Make prompt structure
prompt = {'Groups:' ''};
for i = 1:length(mainhandles.groups)
    % Replace all '_' with '\_' to avoid legend subscripts
    n = mainhandles.groups(i).name;
    run = 0;
    for k = 1:length(n)
        run = run+1;
        if n(run)=='_'
            n = sprintf('%s\\%s',n(1:run-1),n(run:end));
            run = run+1;
        end
    end
    prompt{end+1,1} = sprintf('%s:',n);
    prompt{end,2} = sprintf('group%i',i);
end

% Make formats structure
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(1,1).type   = 'text';
for i = 1:length(mainhandles.groups)
    formats(end+1,1).type   = 'edit';
end

% Make DefAns structure
for i = 1:length(mainhandles.groups)
    DefAns.(sprintf('group%i',i)) = mainhandles.groups(i).name;
end

%--------------- Open dialog box --------------%
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns);
if (cancelled==1) || (isequal(DefAns,answer))
    return
end

%----------- Make new choices happen ----------%
for i = 1:length(mainhandles.groups)
    mainhandles.groups(i).name = answer.(sprintf('group%i',i));
end

% Update pair-listbox
updatemainhandles(mainhandles)
updateFRETpairlist(handles.main,handles.figure1)
updategrouplist(handles.main,handles.figure1)

function Grouping_Sort_Callback(hObject, ~, handles) %% Sort molecule list according to group
mainhandles = sortpairsCallback(handles.figure1, 2);

function Grouping_Color_Callback(hObject, ~, handles) %% Set group colors from the group menu
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
elseif isempty(mainhandles.groups)
    mymsgbox('No groups defined');
    return
end

% Open selection box
Gchoice = groupselection(handles,'Set group color','Choose groups');
if (isempty(Gchoice))
    return
end

%--- Open color dialog and set new color ----%
if ~isempty(Gchoice)
    for i = 1:length(Gchoice)
        prevcolor = mainhandles.groups(Gchoice(i)).color/255;
        c = uisetcolor([prevcolor(1) prevcolor(2) prevcolor(3)],mainhandles.groups(Gchoice(i)).name);
        mainhandles.groups(Gchoice(i)).color = c*255;
    end
    updatemainhandles(mainhandles)
    updateFRETpairlist(handles.main,handles.figure1)
    updategrouplist(handles.main,handles.figure1)
end

function Grouping_Settings_Callback(hObject, ~, handles) %% General groups settings from the group menu
mainhandles = groupingSettingsCallback(handles);

function Grouping_Help_Callback(hObject, eventdata, handles)
% % Get textstr
% str = howstuffworksStr('grouping');
%
% % Show dialog
% mymsgbox(str,'Grouping help','help')
myopenURL('http://isms.au.dk/documentation/grouping-molecules/')

function BinMenu_Callback(hObject, eventdata, handles)
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs

function Bin_open_Callback(hObject, eventdata, handles)
mainhandles = openFRETpairbinCallback(handles);

function Bin_Empty_Callback(hObject, eventdata, handles)
mainhandles = emptyRecycleBinCallback(handles);

function Bin_ReuseAll_Callback(hObject, eventdata, handles)
mainhandles = reusebinCallback(handles,'all');

function Bin_RemoveSelected_Callback(hObject, eventdata, handles)
% Remove
handles = deletePairsPushbuttonCallback(handles);

% Show dialog
mainhandles = getmainhandles(handles);
str = 'The selected molecules where moved to the bin (Ctrl+D).';
mainhandles = myguidebox(mainhandles,'Pairs removed',str,'fastbin');

function Bin_RecycleLast_Callback(hObject, eventdata, handles)
mainhandles = recyclelastPair(handles);

function Bin_Help_Callback(hObject, eventdata, handles)
myopenURL('http://isms.au.dk/documentation/recycle-bin/')

function HelpMenu_Callback(hObject, ~, handles) %% The help menu
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs

function Help_mfile_Callback(hObject, ~, handles) %% Open this mfile
edit FRETpairwindow.m

function Help_figfile_Callback(hObject, ~, handles) %% Open fig file in guide
guide FRETpairwindow

function Help_updatefcn_Callback(hObject, eventdata, handles)
edit updateFRETpairplots.m

% --------------------------------------------------------------------
% ----------------------------- Toolbar ------------------------------
% --------------------------------------------------------------------

function Toolbar_BackgroundTraces_ClickedCallback(hObject, ~, handles) %% Hide/show background traces in intensity plots
View_BackgroundTraces_Callback(handles.View_BackgroundTraces, [], handles)

function Toolbar_frameSliders_OnCallback(hObject, ~, handles) %% Activate avg. molecule image frame sliders
handles = turnoffFRETpairwindowtoggles(handles,'frameSliders'); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Display userguide info box
textstr = sprintf(['The frame sliders are now activated on top of the trace plots.\n'...
    'The shown molecule images are the average of the time-interval defined by the frame-sliders.\n\n'...
    'How to change the frame sliders:\n\n'...
    '  1) Drag from left or right side of the frame slider to narrow the time-interval. \n'...
    '  2) Move the frame slider by draggin on top of the trace plot.\n'...
    '  3) It is recommended to turn the frame sliders back off when finished in order not to slow down the GUI.\n\n'...
    'The molecule images are automatically updated according to the new frame intervals.\n\n ']);
mainhandles = myguidebox(mainhandles, 'Molecule frame sliders', textstr, 'framesliders');

% Set handles structure
mainhandles.settings.FRETpairplots.frameSliders = 1;
updateFRETpairwindowGUImenus(mainhandles,handles)

% Update GUI
updatemainhandles(mainhandles)
handles = updateMoleculeFrameSliderHandles(handles.main,handles.figure1);

function Toolbar_frameSliders_OffCallback(hObject, ~, handles) %% Turn of the avg. molecule image frame sliders
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Set handles structure
mainhandles.settings.FRETpairplots.frameSliders = 0;
updateFRETpairwindowGUImenus(mainhandles,handles)

% Update GUI
updatemainhandles(mainhandles)
handles = updateMoleculeFrameSliderHandles(handles.main,handles.figure1);

function Toolbar_SetTimeIntervalToggle_OnCallback(hObject, ~, handles) %% Activates selection tool for time-interval of interest
[mainhandles, handles] = setTimeIntervalOfInterestCallback(handles);

function Toolbar_SetTimeIntervalToggle_OffCallback(hObject, ~, handles) %% De-activates the time-interval selection tool
myginputc(0);

function Toolbar_ResetTimeIntervals_ClickedCallback(hObject, ~, handles) %% Reset time-interval from the toolbar set the timeInterval of interest to []
[mainhandles, handles] = clearTimeIntervalsOfInterestCallback(handles);

function Toolbar_SetBleachingTimes_OnCallback(hObject, ~, handles) %% Activates the selection tool for bleaching times
[mainhandles,handles] = setBleachingTimesCallback(handles);

function Toolbar_SetBleachingTimes_OffCallback(hObject, ~, handles) %% De-activates the selection tool for bleaching times
myginputc(0);

function Toolbar_ClearBleachingTimes_ClickedCallback(hObject, ~, handles) %% Clear bleaching times of donor and acceptor
[mainhandles, handles] = clearBleachingTimesCallback(handles);

function Toolbar_SetBlinkingIntervalToggle_OnCallback(hObject, eventdata, handles)
[mainhandles, handles] = setBlinkingIntervalsCallback(handles);

function Toolbar_SetBlinkingIntervalToggle_OffCallback(hObject, eventdata, handles)
myginputc(0);

function Toolbar_ClearBlinkingInterval_ClickedCallback(hObject, ~, handles) %% Clear blinking intervals
[mainhandles, handles] = clearBlinkingIntervalsCallback(handles);

function Toolbar_IntegrationROI_OnCallback(hObject, ~, handles) %% Activates integration ROIs on molecule images
[mainhandles, handles] = turnOnIntegrationROIcallback(handles);

function Toolbar_IntegrationROI_OffCallback(hObject, ~, handles) %% Turns off integration ROIs and updates handles structure
[mainhandles, handles] = turnOffIntegrationROIcallback(handles);

function Toolbar_ShowIntegrationArea_ClickedCallback(hObject, ~, handles) %% Turns highlight of pixels used for integration on/off
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Update handles structure and images
if mainhandles.settings.FRETpairplots.showIntPixels==0
    mainhandles.settings.FRETpairplots.showIntPixels = 1;
    set(handles.View_PixelHighlighting_IntMask,'Checked','on')
elseif mainhandles.settings.FRETpairplots.showIntPixels==1
    mainhandles.settings.FRETpairplots.showIntPixels = 0;
    set(handles.View_PixelHighlighting_IntMask,'Checked','off')
end
updatemainhandles(mainhandles)
handles = updateFRETpairplots(handles.main, handles.figure1, 'images');

function Toolbar_ShowBackgroundPixels_ClickedCallback(hObject, ~, handles) %% Turns the highlight of the pixels used as background on/off
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Update handles structure and images
if mainhandles.settings.FRETpairplots.showBackPixels==0
    mainhandles.settings.FRETpairplots.showBackPixels = 1;
    set(handles.View_PixelHighlighting_BackMask,'Checked','on')
elseif mainhandles.settings.FRETpairplots.showBackPixels==1
    mainhandles.settings.FRETpairplots.showBackPixels = 0;
    set(handles.View_PixelHighlighting_BackMask,'Checked','off')
end
updatemainhandles(mainhandles)
handles = updateFRETpairplots(handles.main, handles.figure1, 'images');

function Toolbar_SelectBackPixels_OnCallback(hObject, ~, handles) %% Manually select pixels used for background
[mainhandles, handles] = turnOnSelectBackPixelsCallback(handles);

function Toolbar_SelectBackPixels_OffCallback(hObject, ~, handles) %% Turn off manual background selection
myginputc(0);

function Toolbar_vbAnalysis_ClickedCallback(hObject, ~, handles) %% Predicts ideal traces based on vbFRET algorithm
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

%-- Prepare dialog box
prompt = {'Get ideal traces of:' '';...
    'E-trace' 'Etrace';...
    'S-trace' 'Strace'};
name = 'vbFRET analysis';

formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

formats(2,1).type = 'text';
formats(3,1).type = 'check';
formats(4,1).type = 'check';

DefAns.Etrace = 1;
DefAns.Strace = 0;

options.CancelButton = 'on';

%-- Open dialog box
% [answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
% if (cancelled==1)
%     return
% end
answer.Etrace = 1;
answer.Strace = 0;

%---- Run analysis ----%
selectedPairs = getPairs(handles.main, 'Selected', [], handles.figure1);

if answer.Etrace
    traceChoice = 'E';
    mainhandles = vbAnalysis(handles.main,selectedPairs,traceChoice);
    
    % Plot
    for i = 1:size(selectedPairs,1);
        fh = figure;
        mainhandles.figures{end+1} = fh;
        updatelogo(fh)
        set(gcf,'name',sprintf('File: %s - Pair: %i',mainhandles.data(selectedPairs(i,1)).name, selectedPairs(i,2)),'numbertitle','off')
        
        raw = mainhandles.data(selectedPairs(i,1)).FRETpairs(selectedPairs(i,2)).Etrace;
        fit = mainhandles.data(selectedPairs(i,1)).FRETpairs(selectedPairs(i,2)).vbfitE_fit(:,1);
        idx = mainhandles.data(selectedPairs(i,1)).FRETpairs(selectedPairs(i,2)).vbfitE_idx;
        
        ylab = 'FRET efficiency';
        plot(raw,'-r')
        hold on
        
        % Cut traces according to intervals
        idx1 = 1;
        for j = 1:size(idx,1)
            idx2 = idx1 + idx(j,2)-idx(j,1);
            plot(idx(j,1):idx(j,2),fit(idx1:idx2),'-b','linewidth',2)
            idx1 = idx2+1;
        end
        
        %             plot(fit,'-b','linewidth',2)
        ylabel(ylab)
        xlabel('Time /frame')
%         xlim(get(handles.PRtraceAxes,'xlim'))
        ylim(get(handles.PRtraceAxes,'ylim'))
    end
end
if answer.Strace
    traceChoice = 'S';
    mainhandles = vbAnalysis(handles.main,selectedPairs,traceChoice);
    
    % Plot
    for i = 1:size(selectedPairs,1);
        fh = figure;
        mainhandles.figures{end+1} = fh;
        set(gcf,'name',sprintf('File: %s - Pair: %i',mainhandles.data(selectedPairs(i,1)).name, selectedPairs(i,2)),'numbertitle','off')
        
        raw = mainhandles.data(selectedPairs(i,1)).FRETpairs(selectedPairs(i,2)).StraceCorr;
        fit = mainhandles.data(selectedPairs(i,1)).FRETpairs(selectedPairs(i,2)).vbfitS_fit(:,1);
        
        ylab = 'Stoichiometry';
        plot(raw,'-r')
        hold on
        plot(fit,'-b','linewidth',2)
        ylabel(ylab)
        xlabel('Time /frame')
    end
    xlim tight
end
updatemainhandles(mainhandles)

% --------------------------------------------------------------------
% ------------------------------ Objects -----------------------------
% --------------------------------------------------------------------

function PairListbox_Callback(hObject, ~, handles) %% Runs when selecting a FRET-pair from the FRET pair listbox
[mainhandles, handles] = FRETpairlistboxCallback(handles.figure1);

function PairListbox_CreateFcn(hObject, ~, handles) %% Runs when the FRET-pair listbox is created upon startup
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DeletePairPushbutton_Callback(hObject, ~, handles) %% Deletes the selected FRET-pair and then updates all figure windows
handles = deletePairsPushbuttonCallback(handles);

% Info box
str = 'Molecule moved to bin.';
if ispc
    str = sprintf('%s\n\nTip: Use the shortcut Ctrl+D.\n',str);
end
mainhandles = getmainhandles(handles);
mainhandles = myguidebox(mainhandles,'Binned',str,'removepair',1,'http://isms.au.dk/documentation/recycle-bin/');

function GroupsListbox_Callback(hObject, ~, handles) %% Callback for changing the selected group
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Bold-highlight groupmembers of selected group
if mainhandles.settings.grouping.highlight
    groupchoices = get(handles.GroupsListbox,'Value');
    groupmembers = getPairs(handles.main, 'Group', [], handles.figure1);
    
    if ~isempty(groupmembers)
        updateFRETpairlist(handles.main,handles.figure1) % Reset listbox string
        namestr = cellstr(get(handles.PairListbox, 'String')); % Current listbox string
        
        allPairs = getPairs(handles.main,'Listed'); % Array with all pairs ordered as [file pair;...]
        run = 1;
        for i = 1:length(mainhandles.data)
            pairList = 1:length(mainhandles.data(i).FRETpairs);
            allPairs(run:run+length(pairList)-1,:) = [ones(length(pairList),1)*i  pairList'];
            run = run+length(pairList);
        end
        
        for i = 1:size(allPairs,1)
            if ismember(allPairs(i,:),groupmembers)
                if strcmp(namestr{groupmembers(i,2)}(1:6),'<HTML>')
                    namestr{i} = sprintf('<HTML><b>%s</b></HTML>', namestr{i}(7:end-7)); % Change string to HTML code
                else
                    namestr{i} = sprintf('<HTML><b>%s</b></HTML>', namestr{i}); % Change string to HTML code
                end
            end
        end
        
        set(handles.PairListbox,'String',namestr)
    end
end

% If histogram is open update the histogram
if (strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on')) ...
        && (~isempty(mainhandles.histogramwindowHandle)) && (ishandle(mainhandles.histogramwindowHandle))
    histogramwindowHandles = guidata(mainhandles.histogramwindowHandle);
    
    if get(histogramwindowHandles.plotSelectedGroupRadiobutton,'Value')...
            || (get(histogramwindowHandles.plotAllExceptRadiobutton,'Value') && mainhandles.settings.SEplot.exceptchoice==3)
        
        % If plotting data-points using selected group
        mainhandles = updateSEplot(handles.main,handles.figure1,mainhandles.histogramwindowHandle,'all');
        figure(handles.figure1)
    end
end
function GroupsListbox_CreateFcn(hObject, ~, handles) %% Runs when the group listbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function GammaEditbox_Callback(hObject, ~, handles) %% Callback for changing the gamma value in the gamme-editbox
mainhandles = correctionfactorEditboxCallback(handles,'gamma');
function GammaEditbox_CreateFcn(hObject, ~, handles) %% Runs when the gamma editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AdirectEditbox_Callback(hObject, ~, handles) %% Callback for changing the A-direct value in the A-direct editbox
mainhandles = correctionfactorEditboxCallback(handles,'Adirect');
function AdirectEditbox_CreateFcn(hObject, ~, handles) %% Runs when the A-direct editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DleakEditbox_Callback(hObject, ~, handles) %% Callback for changing the D-leakage value in the D-leakage editbox
mainhandles = correctionfactorEditboxCallback(handles,'Dleakage');
function DleakEditbox_CreateFcn(hObject, ~, handles) %% Runs when the D-leakage editbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ContrastSlider_Callback(hObject, ~, handles) %% The contrast slider callback
handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

selectedPairs = getPairs(handles.main, 'Selected', [], handles.figure1);

% Update images
if size(selectedPairs,1)==1
    mainhandles.data(selectedPairs(1)).FRETpairs(selectedPairs(2)).contrastslider = get(handles.ContrastSlider,'Value');
    updatemainhandles(mainhandles)
    [handles,mainhandles] = updateFRETpairplots(handles.main,handles.figure1,'images');
end
function ContrastSlider_CreateFcn(hObject, ~, handles) %% Runs when the contast slider is created
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function molspecCheckbox_Callback(hObject, eventdata, handles)
mainhandles = getmainhandles(handles);

% New setting
mainhandles.settings.corrections.molspec = get(handles.molspecCheckbox,'Value');
updatemainhandles(mainhandles)

% Calculate new traces
mainhandles = correctTraces(mainhandles.figure1, 'all');

% Update plots
handles = updateFRETpairplots(handles.main,handles.figure1, 'traces','ADcorrect');

% Update correction factor editboxes
updateCorrectionFactors(handles.main,handles.figure1);

% Update the SE plot
mainhandles = updateSEplot(handles.main,handles.figure1, mainhandles.histogramwindowHandle,'all');

function Settings_FRETmethod_Callback(hObject, eventdata, handles)
% Get mainhandles
mainhandles = getmainhandles(handles);

% Update settings
mainhandles.settings.corrections.FRETmethod = abs(mainhandles.settings.corrections.FRETmethod-1);
updatemainhandles(mainhandles)

% Update GUI
updateFRETpairwindowGUImenus(mainhandles,handles);

% Update traces
mainhandles = correctTraces(mainhandles.figure1,'all');

% Update plots
handles = updateFRETpairplots(handles.main,handles.figure1, 'traces','ADcorrect');

% Update the SE plot
mainhandles = updateSEplot(handles.main,handles.figure1, mainhandles.histogramwindowHandle,'all');


function Plot_FilteredTraces_Callback(hObject, eventdata, handles)
mainhandles = plotFilteredTracesCallback(handles);
