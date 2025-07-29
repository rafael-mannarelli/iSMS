function varargout = iSMS(varargin) %% Initializes the GUI
% iSMS - Single-molecule FRET microscopy software
%
%  HOW TO RUN
%  Open iSMS.m (this file) and press the green run button in the toolbar of
%  the editor. If a popup message tells you the file is not on the MATLAB
%  search path then press 'Change Folder'. 
%
%  DOCUMENTATION and updates:
%   http://isms.au.dk
%
%  TIPS:
%  - When inspecting an m-file, it is recommended to fold all code as the
%  first thing you do.
%  - The callbacks of the main GUI window are found in the iSMS.m file and
%  is divided into sections of:
%      1) Menus (menu bar items)
%      2) Toolbar items
%      3) Miscellaneous function called by the GUI
%      4) GUI object callbacks (buttons, listboxes, etc.)
%  - Functions called by the software is located in the 'calls' folder and
%    its sub-directories.
%  - Use the Help menus in the GUI windows to get direct access to relevant
%  m files.
%
%  FILES to get started:
%  - The settings structure is initialized in internalSettingsStructure.m.
%  - Data-fields specific settings and fields (ROIs, etc.) are initialized in
%  storeMovie.m upon loading the data file.
%  - The main GUI window is initialized in createGridFlex.m
%
%  Important concepts:
%   MAINHANDLES  - handles structure of the main GUI window. Contains all
%                  data, settings and UI handles.
%   DATA         - located in handles.data. Initialized by storeMovie.m
%   SETTINGS     - located in handles.settings. Initialized by
%                  internalSettingsStructure.m
%
%  iSMS is developed in the single-molecule biophotonics laboratory of
%  Victoria Birkedal, iNANO center, Aarhus University, Denmark. For help,
%  please go the website http://isms.au.dk
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

% Last Modified by GUIDE v2.5 16-Mar-2015 17:25:45

% Set up paths
if ~isdeployed
    
    % Change the current folder to the folder of this m-file.
    cd(fileparts(which(mfilename)));
    
    % Add the subfolders to the MATLAB search path
    if isempty(getappdata(0,'iSMSstarted'))
        addpath(pwd) % Adds the current directory (installation directory)
        addpath(genpath(fullfile(pwd,'calls'))) % Adds the calls subdirectory and its subfolders
        setappdata(0,'iSMSstarted',1)
    end
end

% Splash screen
mysplashScreen()

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @iSMS_OpeningFcn, ...
    'gui_OutputFcn',  @iSMS_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    try
        gui_State.gui_Callback = str2func(varargin{1});
    end
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function iSMS_OpeningFcn(hObject, eventdata, handles, varargin) %% This function is run right before the GUI is made visible. Initializes the settings structure.
% Software specifications
handles.workdir = getcurrentdir; % Root directory
handles.settingsdir = getsettingsdir(handles.workdir); % Default settings directory
handles.resourcedir = getresourcedir(handles.workdir); % Directory containing resource files (icons, etc.)
handles.name = 'iSMS'; % Short name
handles.website = 'http://isms.au.dk/'; % Homepage
handles.version = '2.01'; % This software version. Must be string.
handles.checkversion = 'http://isms.au.dk/fileadmin/isms.au.dk/version/version.txt'; % URL returning latest version of software
handles.splashScreenHandle = getappdata(0,'smsSplashHandle'); % Handle to the splash screen running on startup
handles.ispublic = 1; % 0/1 whether version is for internal (0) or public use (1). Internal version contains unverified scripts and functions used for testing.
handles.matver = getmatlabversion();

% Make sure the deployed version is always public
if isdeployed
    handles.ispublic = 1;
end

% Update above settings
updatemainhandles(handles) % Updates handles structure of the main window
setappdata(0, 'workdirSMS',handles.workdir) % It is necessary also to send workdir to appdata

% Create required folders on system path
ok = createFolders(handles);
if ~ok
    deleteSplashScreen(handles.splashScreenHandle) % Delete the splash screen
    try delete(hObject), end % Delete window object
    return
end

% Set position, title and logo. Turn off visibility.
initGUI(handles.figure1, 'iSMS - Single-Molecule FRET Microscopy Software', 'center');

% Settings
settings = internalSettingsStructure(); % Initialize settings structure with internal values
[handles.settings, ok] = loadDefaultSettings(handles, settings); % Load default settings from file

% If permission denied to write to disk, close down
if ~ok
    try rmappdata(0,'administratorMsgbox'), end % Reactivate the message box for next try
    try deleteSplashScreen(handles.splashScreenHandle), end % Delete the splash screen
    try delete(hObject), end % Delete window object
    return
end

% Settings that should not be changed:
handles.settings.view.ROIimage = 1; % Always start with an overlay plot in the ROI image
handles.settings.integration.type = 1; % Always start intensity trace calculation using aperture photometry
handles.settings.bin.lastpair = []; % No last binned pair

% Check the MATLAB version. Must be positioned after settings
[handles, choseReturn] = checkforMATLAB(handles,'1-Jun-2013','2013b');
if choseReturn
    deleteSplashScreen(handles.splashScreenHandle) % Delete the splash screen
    try delete(hObject), end % Delete window object
    return
end

% Check that user has the proper toolboxes installed
[handles, choseReturn] = checkforToolboxes(handles,'image_toolbox','optimization_toolbox','statistics_toolbox');
if choseReturn % If user does not whish to continue without proper toolboxes
    deleteSplashScreen(handles.splashScreenHandle)
    try delete(hObject), end
    return
end

% Check computer
handles = checkRAM(handles,12000);

% Check allocated Java heap space
handles = checkJava(handles,250);

% Check screen resolution
handles = checkScreenResolution(handles);

% Check for parallel computing toolbox
if ~checkforParTB()
    handles.settings.performance.parallel = 0;
end

% Adjust searchpath depending on matlab version
warning off
if handles.matver>8.3
    try rmpath(genpath(fullfile(handles.workdir,'calls','GUILayout-v1'))), end
    try rmpath(genpath(fullfile(handles.workdir,'calls','exportFigure1'))), end
    set(0,'DefaultAxesLabelFontSizeMultiplier',1) % Set back previous font sizes (introduced in R2014b with default 1.1)
else
    try rmpath(genpath(fullfile(handles.workdir,'calls','GUILayout-v2'))), end
    try rmpath(genpath(fullfile(handles.workdir,'calls','exportFigure2'))), end
end
warning on

% Create gridflex (draggable GUI elemets)
handles = createGridFlex(handles);

% Data
handles.data = struct([]); % Data structure is defined and populated when loading data in storeMovie.m
handles = createNewGroup(handles); % Initialize groups structure
handles.profiles = struct([]); % Laser spot profile structure is defined and populated when making the spot profiles

% File, state and various
handles.filename = [];
handles.notes = '';
handles.state1 = [];
handles.state2 = [];

% Load default ROIs from file. This will overwrite above settings
handles = loaddefaultROIs(handles);

% Initialize handles
handles = initobjectHandles(handles);

% Turn off some things if its a deployed version
turnoffDeployed(handles);

% Save current properties of cursor and graphics handles
handles.functionHandles.cursorPointer = get(handles.figure1, 'Pointer');

% Customize data cursor
hdt = datacursormode;
set(hdt,'UpdateFcn',{@maindatacursorCallback, handles.figure1})
datacursormode('off')

% Update recent files menus. Must be positioned after the recent
updateRecentFilesMenu(handles)

% Choose default command line output for iSMS
handles.output = hObject;

% Update handles structure
updatemainhandles(handles)

% % Set GUI dimensions
% mainResizeFcn(hObject, handles)
% ROItopbarResizeFcn(handles.uipanelROItop, [])
% RAWtopbarResizeFcn(handles.uipanelRAWtop, [])
% 
% Set some GUI settings
setGUIappearance(handles.figure1,0)

% Update peakfinder threshold editboxes
handles = updatePeakthresholdsEditbox(handles,2);

% Initiate image axes
set([handles.rawimage handles.ROIimage],'XTickLabel','','YTickLabel','')
set([handles.rawframesliderAxes handles.ROIframesliderAxes handles.rawcontrastSliderAx...
    handles.redROIcontrastSliderAx handles.greenROIcontrastSliderAx],...
    'XTick',[],'YTick',[],'Color','white')

% Set default colormap of raw image ax
setrawColormap(handles);

% Update excitation-scheme dependent menus
handles = updateALEX(handles);

% Update visible functionalities
handles = updatePublic(handles);

% Default text type
set(0, 'DefaultTextInterpreter', 'tex');

% Disable zooming on framesliderAxes
h = zoom(handles.figure1);
setAllowAxesZoom(h,handles.ROIframesliderAxes,false);
setAllowAxesZoom(h,handles.rawframesliderAxes,false);

% If GUI was opened with a session file, open session
% handles = openSessionOnStartup(handles, varargin);

% Update memory
handles = updateMemorybar(handles);

% Check for updates. Positioned right before deleting splash screen and
% updating GUI menus
handles = checkforUpdates(handles, handles.checkversion);

% Update menu checkmarks
updatemainGUImenus(handles)

% Delete splash screen
deleteSplashScreen(handles.splashScreenHandle)

function varargout = iSMS_OutputFcn(hObject, ~, handles) %% This function returns handles.output (varargout) to the command line. Is not used by iSMS.
% This is run both right after opening_fcn and right after close_requestfcn
varargout{1} = [];
if ~isempty(handles) % Is empty if called as a disruption of startup
    
    % Show GUI
    if strcmpi(get(handles.figure1,'Visible'),'off')
        set(handles.figure1,'Visible','on')
    end
    
    % Set element positions. Starting from R2014b this must be put after
    % setting the 'Visible' property is set to on
    mainResizeFcn(handles.figure1, handles)
    peakfinderResizeFcn([],[],handles.figure1)
    ROItopbarResizeFcn(handles.uipanelROItop, [])
    RAWtopbarResizeFcn(handles.uipanelRAWtop, [])
    
    % In version >2014b, re-update the elements (not sure why yet)
    if handles.matver>8.3
        mainResizeFcn(handles.figure1, handles)
        peakfinderResizeFcn([],[],handles.figure1)
        ROItopbarResizeFcn(handles.uipanelROItop, [])
        RAWtopbarResizeFcn(handles.uipanelRAWtop, [])

        set([handles.rawimage handles.ROIimage],'XColor','k','YColor','k')

    end
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
else varargout{1} = [];
end

% Prompt for a demo on first run
handles = firstRunDemo(handles);

function figure1_CloseRequestFcn(hObject, ~, handles) %% Runs when the GUI (i.e. handles.figure1) is closed
maincloseFcn(hObject, handles)

function figure1_ResizeFcn(hObject, eventdata, handles) %% Runs when user resizes GUI window
mainResizeFcn(hObject, handles)

% --------------------------------------------------------------------
% ----------------- Callback-functions start hereafter ---------------
% - Tip: Fold all code for an overview (Ctrl+= on american keyboard) -
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% ------------------------------- Menus ------------------------------
% --------------------------------------------------------------------

function FileMenu_Callback(hObject, ~, handles) %% The file menu
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

function File_LoadData_Callback(hObject, ~, handles) %% The load data button from the Files menu loads movies from files into the handles.data structure
handles = loadDataCallback(handles);

function File_Data_LoadFromSession_Callback(hObject, eventdata, handles)
handles = importfromSession(handles);

function File_ImportMovieWorkspace_Callback(hObject, eventdata, handles)
% Prompt dialog
[vars, varnames] = uigetvariables({'Please select workspace variable'}, ...
    'Introduction',['The selected variable must be a numeric array of size n*m*frames.']);

% Import data into handles structure
temp.imageData = vars{1};
try
    handles = storeMovie(handles,temp,varnames{1},pwd,0);
catch err
    set(handles.mboard, 'String',sprintf('Unable to import workspace variable:\n %s',err.message))
    return
end

% Update GUI and finish
set(handles.FilesListbox,'Value',length(handles.data))
set(handles.FramesListbox,'Value',1)
updatemainhandles(handles)
updatefileslist(handles.figure1,handles.histogramwindowHandle)
handles = filesListboxCallback(handles.FilesListbox); % Imitate click in listbox

function File_SessionMenu_Callback(hObject, ~, handles) %% The session submenu from the File menu

function File_NewSession_Callback(hObject, ~, handles) %% The New Session button from the File menu restarts GUI
newSessionCallback(handles)

function File_OpenSession_Callback(hObject, ~, handles) %% Open an existing session
handles = opensession(handles.figure1);

function File_SaveSession_Callback(hObject, ~, handles) %% Save current session
handles = savesession(handles.figure1);

function File_SaveSessionAs_Callback(hObject, ~, handles) %% Save current session as
handles = savesessionAs(handles.figure1);

function File_MergeSession_Callback(hObject, ~, handles) %% Merges a saved session with the current session
handles = mergeSessionCallback(handles);

function File_MovieMenu_Callback(hObject, ~, handles) %% The movies sub menu from the file menu

function File_SettingsForSaving_Callback(hObject, ~, handles) %% Specify settings for saving sessions
handles = saveopenSettingsCallback(handles);

function File_MovieSettings_Callback(hObject, ~, handles) %% Opens a dialog for specifying settings associated with movies
handles = turnofftoggles(handles,'all'); % Turn off all interactive toggle buttons in the toolbar
if isempty(handles.data)
    mymsgbox('No movies loaded','iSMS');
    return
end

answer = fileSettings(handles.figure1); % Opens a settings input dialog box
if isempty(answer)
    updatemainhandles(handles) % Restore settings to previous
    return
end

function File_ExportMenu_Callback(hObject, eventdata, handles)
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

function File_Export_SMD_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.figure1,'smd');

function File_Export_ASCII_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.figure1,'ascii');

function File_Export_BOBA_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.figure1,'boba');

function File_Export_vbFRET_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.figure1,'vbFRET');

function File_Export_HaMMy_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.figure1,'hammy');

function File_Export_Workspace_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.figure1,'workspace');

function File_Export_RawVideo_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.figure1,'molmovie');

function File_Export_ROIimage_Callback(hObject, eventdata, handles)
imsave(handles.ROIimage)
set(handles.mboard,'String','File exported.')

function File_Export_PrintScreen_Callback(hObject, ~, handles) %% Export the loaded images as figure files
handles = turnofftoggles(handles,'all'); % Turn off all interactive toggle buttons in the toolbar

% Open a dialog for specifying export properties
settings = export_fig_dlg;
if isempty(settings)
    return
end

% Export figure
try
    figure(handles.figure1)
    eval(settings.command) % This will run export_fig with settings specified in export_fig_dlg
    
catch err
    fprintf('Error message from export_fig: %s', err.message)
    
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

% Imititate click in listbox
handles = filesListboxCallback(handles.FilesListbox); % Imitate click in listbox

% Delete waitbar
try delete(hWaitbar), end

function File_ExportOptions_Callback(hObject, eventdata, handles)
myopenURL('http://isms.au.dk/documentation/export-data-and-figures/export/')

function File_Notebook_Callback(hObject, ~, handles) %% Opens a notebook for typing in notes related to the current session
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

if (~isempty(handles.notebookHandle)) && (ishandle(handles.notebookHandle)) % If notebook is already open send it to front
    figure(handles.notebookHandle)
else % Open notebook window and store its handle in the mainhandles structure
    handles.notebookHandle = notebookwindow(handles.figure1);
    guidata(handles.figure1,handles)
end

function File_ROImenu_Callback(hObject, ~, handles) %% The ROI submenu from the file menu

function File_SaveDefaultROIs_Callback(hObject, ~, handles) %% Save current ROI positions as defaults
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.data) % If no data is loaded, return
    set(handles.mboard,'String','No data loaded')
    return
end

defaultROIsFile = fullfile(handles.settingsdir,'default.rois');

% Save file with settings structure
if isempty(handles.data)
    ROIs = handles.settings.ROIs;
else
    filechoice = get(handles.FilesListbox,'Value');
    ROIs.Droi = handles.data(filechoice).Droi;
    ROIs.Aroi = handles.data(filechoice).Aroi;
    handles.settings.ROIs = ROIs;
end
save(defaultROIsFile,'ROIs');
set(handles.mboard,'String',sprintf('Default ROIs saved to:\n%s\n',defaultROIsFile))

function File_ROI_ApplyDefault_Callback(hObject, eventdata, handles)
if isempty(handles.data) % If no data is loaded, return
    set(handles.mboard,'String','No data loaded')
    return
end

% Default file path
defaultROIsFile = fullfile(handles.settingsdir,'default.rois');
if ~exist(defaultROIsFile)
    set(handles.mboard,'String','Default ROIs file not found.')
    return
end

% Load file
temp = load(defaultROIsFile,'-mat');
ROIs = temp.ROIs;

% Filechoices
if length(handles.data)==1
    filechoices = 1;
else
    % Dialog
    [filechoices, ok] = mylistdlg('ListString',getfileslistStr(handles),...
        'SelectionMode','multiple',...
        'InitialValue',get(handles.FilesListbox,'Value'),...
        'name','Select files',...
        'ListSize',[400 300]);
    if ~ok
        return
    end
end

% Set ROI
[handles, message] = applyROIposition(handles, filechoices, ROIs);

function File_SaveROIs_Callback(hObject, ~, handles) %% Save current ROI positions to file
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.data) % If no data is loaded, return
    set(handles.mboard,'String','No data loaded')
    return
end

% Open a save as dialog box
[file, path, chose] = uiputfile3(handles,'settings',{'*.rois;*.mat'},'Load ROIs','name.rois');
if chose == 0
    return
end
filename = fullfile(path,file);

% Save file with ROIs
filechoice = get(handles.FilesListbox,'Value');
ROIs.Droi = handles.data(filechoice).Droi;
ROIs.Aroi = handles.data(filechoice).Aroi;
save(filename,'ROIs');
set(handles.mboard,'String',sprintf('ROIs saved to:\n%s\n',filename))

function File_LoadROIs_Callback(hObject, ~, handles) %% Load ROI positions from file
handles = loadROIcallback(handles);

function File_ROI_ApplyToAll_Callback(hObject, eventdata, handles)
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.data) % If no data is loaded, return
    set(handles.mboard,'String','No data loaded')
    return
end

% ROI
filechoice = get(handles.FilesListbox,'Value');
ROIs.Droi = handles.data(filechoice).Droi;
ROIs.Aroi = handles.data(filechoice).Aroi;

% Set ROI
[handles, message] = applyROIposition(handles, 1:length(handles.data), ROIs);

function File_SettingsMenu_Callback(hObject, ~, handles) %% The settings submenu from the file menu

function File_LoadSettings_Callback(hObject, ~, handles) %% Load settings from file
handles = loadsettingsCallback(handles);

function File_SaveSettings_Callback(hObject, ~, handles) %% Opens a dialog for specyfing settings structure name and saves it to file
% Open a save as dialog box
fileformats = {'*.iSMSsettings', 'iSMS settings files'; '*.mat', 'Old settings files'; '*.*', 'All files'};
[file, path, chose] = uiputfile3(handles,'settings',fileformats,'Save settings as','name.iSMSsettings');
if chose == 0
    return
end
filename = fullfile(path,file);

% Save file with settings structure
saveSettings(handles, handles.settings, filename);
set(handles.mboard,'String',sprintf('Settings saved to:\n%s\n',filename))

function File_SaveDefaultSettings_Callback(hObject, ~, handles) %% Save current settings as defaults
saveDefaultSettings(handles, handles.settings);

function File_Settings_RestoreInternal_Callback(hObject, eventdata, handles)
handles = restoreInternalSettings(handles);

function File_RecentSessionsMenu_Callback(hObject, eventdata, handles) %% Recent files menus are populated by updateRecentFiles.m and updateRecentFilesMenu.m

function File_RecentMoviesMenu_Callback(hObject, eventdata, handles) %% Recent files menu are populated by updateRecentFiles.m and updateRecentFilesMenu.m

function File_FileSettings_Callback(hObject, eventdata, handles)
filesettingsDlg(handles);

function EditMenu_Callback(hObject, ~, handles) %% The Edit menu
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

function Edit_MergeTimed_Callback(hObject, ~, handles) %% Merges two movie files
handles = mergeMoviesCallback(handles);

function Edit_MergeSideBySide_Callback(hObject, eventdata, handles)
handles = mergeEmissionChannelsCallback(handles);

function Edit_MergeFrameByFrame_Callback(hObject, eventdata, handles)
handles = mergeFrameByFrameCallback(handles);

function Edit_SplitFrames_Callback(hObject, eventdata, handles)
handles = splitframesCallback(handles);

function Edit_DeleteFrames_Callback(hObject, ~, handles) %% The delete frames button from the Edit menu
handles = deleteframesCallback(handles);

function Edit_RenameData_Callback(hObject, ~, handles) %% The rename-data button from the Edit menu opens a dialog box for renaming data
handles = renameDataCallback(handles);

function Edit_Duplicate_Callback(hObject, ~, handles) %% The duplicate data button from the Edit menu
handles = duplicatedataCallback(handles);

function ViewMenu_Callback(hObject, ~, handles) %% The View menu
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

function View_PlayRawMovie_Callback(hObject, eventdata, handles)
handles = createMovieObject(handles,'raw');

function View_PlayMovie_Callback(hObject, ~, handles) %% The play movie button from the View menu
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.data) % If no data is loaded, return
    set(handles.mboard,'String','No data loaded')
    return
end
filechoice = get(handles.FilesListbox,'Value');

% Check if raw movie has been deleted
[handles, hasRaw] = checkRawData(handles,filechoice);
if ~hasRaw
    return
end

% Play the movie
figh = figure;
updatelogo(figh)
set(figh,'WindowStyle','modal','name',sprintf('Movie: %s',handles.data(filechoice).name),'numbertitle','off')
for j = 1:size(handles.data(filechoice).imageData,3)
    axes(gca) % make rawimage current axis
    imagesc(handles.data(filechoice).imageData(:,:,j)');
    axis image
    set(gca,'YDir','normal')
end
try
    delete(figh)
end

function View_Rotate_Callback(hObject, ~, handles) %% The rotate button from the View menu rotates the image 90 deg.
handles = rotateviewCallback(handles);

function View_FlipVer_Callback(hObject, ~, handles) %% The flip vertical button from the View menu
handles = flipudCallback(handles);

function View_FlipHor_Callback(hObject, ~, handles) %% The flip horizontal from the View menu
handles = fliplrCallback(handles);

function View_ROIchannels_Callback(hObject, eventdata, handles)

function View_ROIchannel_Green_Callback(hObject, eventdata, handles)
handles = shownROIchannelCallback(handles,'ROIgreen');

function View_ROIchannel_Red_Callback(hObject, eventdata, handles)
handles = shownROIchannelCallback(handles,'ROIred');

function View_ROIimage_Callback(hObject, ~, handles) %% Shift emission channel in ROI plot
handles = shiftROIchannelCallback(handles);

function View_ROIsqrt_Callback(hObject, eventdata, handles)
% New settings
handles.settings.view.ROIsqrt = abs(handles.settings.view.ROIsqrt-1);

% Update mainhandles structure and GUI menus
updatemainhandles(handles)
updatemainGUImenus(handles)

% Update image
handles = updateROIimage(handles,0,0,0);

function View_Colorblind_Callback(hObject, eventdata, handles)
handles = colorblindCallback(handles);

function View_rawlogscale_Callback(hObject, eventdata, handles)
% New settings
handles.settings.view.rawlogscale = abs(handles.settings.view.rawlogscale-1);

% Update mainhandles structure and GUI menus
updatemainhandles(handles)
updatemainGUImenus(handles)

% Update image
handles = updaterawimage(handles);
handles = updateROIhandles(handles);

function View_RawColormap_Callback(hObject, eventdata, handles)

function View_RawColormap_Jet_Callback(hObject, eventdata, handles)
% Update setting
handles.settings.view.rawcolormap = 'jet';
updatemainhandles(handles)
updatemainGUImenus(handles)

% Update colormap
setrawColormap(handles)

function View_RawColormap_Gray_Callback(hObject, eventdata, handles)
% Update setting
handles.settings.view.rawcolormap = 'gray';
updatemainhandles(handles)
updatemainGUImenus(handles)

% Update colormap
setrawColormap(handles)

function View_ContrastSliders_Callback(hObject, eventdata, handles)
handles.settings.view.contrastsliders = abs(handles.settings.view.contrastsliders-1);
updatemainhandles(handles)
updatemainGUImenus(handles)
handles = updatecontrastSliders(handles);

function View_FrameSliders_Callback(hObject, eventdata, handles)
handles.settings.view.framesliders = abs(handles.settings.view.framesliders-1);
updatemainhandles(handles)
updatemainGUImenus(handles)
handles = updateframesliderHandle(handles);

function ExplorationMenu_Callback(hObject, eventdata, handles)
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

function Explore_ZoomRaw_Callback(hObject, eventdata, handles)
handles = zoomtoolCallback(handles,'raw');

function Explore_ZoomROI_Callback(hObject, eventdata, handles)
handles = zoomtoolCallback(handles,'ROI');

function Exploration_liveROI_Callback(hObject, eventdata, handles)
handles = liveintegrationROIcallback(handles);

function Explore_InspectRaw_Callback(hObject, eventdata, handles)
handles = inspectPixelValuesToolCallback(handles,'raw');

function Explore_InspectROI_Callback(hObject, eventdata, handles)
handles = inspectPixelValuesToolCallback(handles,'ROI');

function SettingsMenu_Callback(hObject, ~, handles) %% The settings menu
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

function Settings_CameraBackground_Callback(hObject, ~, handles) %% Camera background settings modal dialog from the settings menu
handles = camerabackgroundSettingsCallback(handles);

function Settings_IntensityWindow_Callback(hObject, eventdata, handles)
handles.integrationwindowHandle = integrationsettingsWindow; % Opens a modal dialog window
updatemainhandles(handles) % Updates the handle in the mainhandles structure

function Settings_Background_Callback(hObject, eventdata, handles)
handles = turnofftoggles(handles);
[handles, FRETpairwindowHandles] = backgroundSettings(handles.figure1);

function Settings_ExcScheme_Callback(hObject, eventdata, handles)

function Settings_ExcScheme_Single_Callback(hObject, eventdata, handles)
handles = excitationSchemeCallback(handles,0);

function Settings_ExcScheme_ALEX_Callback(hObject, eventdata, handles)
handles = excitationSchemeCallback(handles,1);

function Settings_ExcOrder_Callback(hObject, ~, handles) %% The excitation order from the Settings menu opens a dialog for defining the excitation sequence scheme
handles = excorderCallback(handles);

function Settings_PeakFinder_Callback(hObject, ~, handles) %% Opens a dialog for specyfing settings for the peak finder
handles = peakfinderSettingsCallback(handles);

function Settings_AvgImage_Callback(hObject, ~, handles) %% This button allows the user to define how the average images are made
handles = avgimageSettingsCallback(handles);

function Settings_Denoising_Callback(hObject, ~, handles) %% Set settings for calculating denoised images
handles = denoisingSettingsCallback(handles);

function Settings_Contrast_Callback(hObject, eventdata, handles)
handles = contrastsettingsCallback(handles);

function Settings_autorun_Callback(hObject, ~, handles) %% Opens a dialog for specifying settings for the autorun button
handles = autorunSettingsCallback(handles);

function Settings_AutoAlignROI_Callback(hObject, ~, handles) %% Opens a dialog for defining the settings used for aligning the ROIs automatically
handles = autoalignROIsSettingsCallback(handles);

function Settings_CorrectionFactors_Callback(hObject, ~, handles)
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

[handles,FRETpairwindowHandles] = correctionfactorSettingsDlg(handles.figure1);

function Settings_FilterPairs_Callback(hObject, ~, handles) %% Settings for FRET-pair criteria
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

[handles,FRETpairwindowHandles] = filterPairsDialog(handles);

function Settings_Drift_Callback(hObject, eventdata, handles)
handles = turnofftoggles(handles);
handles = driftSettings(handles.figure1);

function Settings_vbFRET_Callback(hObject, eventdata, handles)
handles = turnofftoggles(handles);
handles = vbFRETsettings(handles.figure1); % Opens a dialog and saves to mainhandles structure

function Settings_Bleachfinder_Callback(hObject, eventdata, handles)
handles = bleachfinderSettingsCallback(handles);

function Settings_LaserSpotProfiles_Callback(hObject, eventdata, handles)
handles = turnofftoggles(handles);
handles = laserspotprofilesSettings(handles);

function Settings_SaveOpenSessions_Callback(hObject, eventdata, handles)
handles = saveopenSettingsCallback(handles);

function Settings_AskDefault_Callback(hObject, eventdata, handles)
handles.settings.settings.askdefault = abs(handles.settings.settings.askdefault-1);
updatemainhandles(handles)
updatemainGUImenus(handles)

function ToolsMenu_Callback(hObject, ~, handles) %% The tools menu
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

function Tools_WindowMenu_Callback(hObject, eventdata, handles)

function Tools_Windows_FRETpair_Callback(hObject, eventdata, handles)
% Bring attention to existing instance
if ~isempty(handles.FRETpairwindowHandle) && ishandle(handles.FRETpairwindowHandle)
    figure(handles.FRETpairwindowHandle)
    return
end

% Open window
set(handles.Toolbar_FRETpairwindow,'State','on')

function Tools_Windows_Histogram_Callback(hObject, eventdata, handles)
% Bring attention to existing instance
if ~isempty(handles.histogramwindowHandle) && ishandle(handles.histogramwindowHandle)
    figure(handles.histogramwindowHandle)
    return
end

% Open window
set(handles.Toolbar_histogramwindow,'State','on')

function Tools_Windows_Correction_Callback(hObject, eventdata, handles)
% Bring attention to existing instance
if ~isempty(handles.correctionfactorwindowHandle) && ishandle(handles.correctionfactorwindowHandle)
    figure(handles.correctionfactorwindowHandle)
    return
end

% Open window
set(handles.Toolbar_correctionfactorWindow,'State','on')

function Tools_Windows_Dynamics_Callback(hObject, eventdata, handles)
% Bring attention to existing instance
if ~isempty(handles.dynamicswindowHandle) && ishandle(handles.dynamicswindowHandle)
    figure(handles.dynamicswindowHandle)
    return
end

% Open window
set(handles.Toolbar_dynamicswindow,'State','on')

function Tools_Windows_SpotProfiles_Callback(hObject, eventdata, handles)
% Bring attention to existing instance
if ~isempty(handles.profilewindowHandle) && ishandle(handles.profilewindowHandle)
    figure(handles.profilewindowHandle)
    return
end

% Open window
updatemainhandles(handles) % Sends the handles structure to appdata
handles.profilewindowHandle = profileWindow2; % Put the handle of the new window into the handles structure
updatemainhandles(handles) % Updates the handles structure

function Tools_Windows_Drift_Callback(hObject, eventdata, handles)
% Bring attention to existing instance
if ~isempty(handles.driftwindowHandle) && ishandle(handles.driftwindowHandle)
    figure(handles.driftwindowHandle)
    return
end

% Open window
handles = opendriftwindowCallback(handles);

function Tools_Windows_PhotonCounting_Callback(hObject, eventdata, handles)
% Bring attention to existing instance
if ~isempty(handles.integrationwindowHandle) && ishandle(handles.integrationwindowHandle)
    figure(handles.integrationwindowHandle)
    return
end

% Open window
handles.integrationwindowHandle = integrationsettingsWindow();
updatemainhandles(handles)

function Tools_Windows_TFM_Callback(hObject, eventdata, handles)
% Bring attention to existing instance
if ~isempty(handles.psfwindowHandle) && ishandle(handles.psfwindowHandle)
    figure(handles.psfwindowHandle)
    return
end

% Open window
handles.psfwindowHandle = psfWindow();
updatemainhandles(handles)

function Tools_Windows_Notebook_Callback(hObject, eventdata, handles)
% Bring attention to existing instance
if ~isempty(handles.notebookHandle) && ishandle(handles.notebookHandle)
    figure(handles.notebookHandle)
    return
end

% Open window
handles.notebookHandle = notebookwindow(handles.figure1);
updatemainhandles(handles)

function Tools_Autorun_Callback(hObject, ~, handles) %% Autorun analysis button
Toolbar_Run_ClickedCallback(handles.Toolbar_Run, [], handles)

function Tools_AlignROIs_Callback(hObject, ~, handles) %% This button attempts to automatically align the D and A ROI
handles = autoalignROIsCallback(handles);

function Tools_FineAdjustROIs_Callback(hObject, ~, handles)
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if (~isempty(handles.adjustROIswindowHandle)) && (ishandle(handles.adjustROIswindowHandle))
    figure(handles.adjustROIswindowHandle)
    return
end

updatemainhandles(handles) % Sends the mainhandle to appdata
handles.adjustROIswindowHandle = fineadjustROIsWindow;
updatemainhandles(handles)

function Tools_FindPeaks_Callback(hObject, ~, handles) %% The find peaks button from the Tools menu runs the peakfinder
% Sure? dialog
file = get(handles.FilesListbox,'Value');
if ~isempty(handles.data(file).FRETpairs)
    sure = mysuredlg('Peak finder', 'This will delete current FRET-pairs.');
    if ~sure
        return
    end
end

% Find peaks
handles = findpeaksCallback(handles);

function Tools_FindEpairs_Callback(hObject, ~, handles) %% Automatically detects potential donor-acceptor pairs on ROI image
% Sure? dialog
file = get(handles.FilesListbox,'Value');
if ~isempty(handles.data(file).FRETpairs)
    sure = mysuredlg('Peak finder', 'This will delete current FRET-pairs.');
    if ~sure
        return
    end
end

% Find pairs
handles = findEpairsCallback(handles, 0);

function Tools_ManualSelectionMenu_Callback(hObject, ~, handles) %% The manual selection menu from the Tools menu

function Tools_DeletePeaks_Callback(hObject, ~, handles) %% The Delete peaks button from the tools menu activates a lasso-selection tool and delete selected points
if strcmpi(get(handles.Toolbar_DeleteMultiplePeaksToggle,'State'),'on')
    return
end
if strcmp(get(handles.Toolbar_DeleteMultiplePeaksToggle,'State'),'off')
    set(handles.Toolbar_DeleteMultiplePeaksToggle,'State','on')
elseif strcmp(get(handles.Toolbar_DeleteMultiplePeaksToggle,'State'),'on')
    set(handles.Toolbar_DeleteMultiplePeaksToggle,'State','off')
end

function Tools_AddDPeaks_Callback(hObject, ~, handles) %% The 'Select donor peaks manually' button from the Tools menu activates a ginput marker tool
if strcmpi(get(handles.Toolbar_DeleteMultiplePeaksToggle,'State'),'on')
    return
end
if strcmp(get(handles.Toolbar_AddDPeaks,'State'),'off')
    set(handles.Toolbar_AddDPeaks,'State','on')
elseif strcmp(get(handles.Toolbar_AddDPeaks,'State'),'on')
    set(handles.Toolbar_AddDPeaks,'State','off')
end

function Tools_AddAPeaks_Callback(hObject, ~, handles) %% The 'Select acceptor peaks manually' button from the Tools menu activates a ginput marker tool
if strcmpi(get(handles.Toolbar_DeleteMultiplePeaksToggle,'State'),'on')
    return
end
if strcmp(get(handles.Toolbar_AddAPeaks,'State'),'off')
    set(handles.Toolbar_AddAPeaks,'State','on')
elseif strcmp(get(handles.Toolbar_AddAPeaks,'State'),'on')
    set(handles.Toolbar_AddAPeaks,'State','off')
end

function Tools_AddEPeaks_Callback(hObject, ~, handles) %% The 'Select acceptor peaks manually' button from the Tools menu activates a ginput marker tool
if strcmpi(get(handles.Toolbar_DeleteMultiplePeaksToggle,'State'),'on')
    return
end
if strcmp(get(handles.Toolbar_AddEPeaks,'State'),'off')
    set(handles.Toolbar_AddEPeaks,'State','on')
elseif strcmp(get(handles.Toolbar_AddEPeaks,'State'),'on')
    set(handles.Toolbar_AddEPeaks,'State','off')
end

function Tools_ResetFiles_Callback(hObject, eventdata, handles)
handles = resetfilesCallback(handles);

function Tools_DenoisingMenu_Callback(hObject, ~, handles) %% The denoising image menu from the tooles menu

function Tools_Denoising_Analyse_Callback(hObject, ~, handles) %% This uses a denoising algorithm to obtain cleaner images for finding peaks
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.data)
    return
end

% Run analysis
analyseDenoising(handles)

function Tools_Denoising_Calculate_Callback(hObject, ~, handles) %% The calculate denoised images button from the tools menu
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.data)
    set(handles.mboard,'String','No data loaded')
    return
end

filechoice = get(handles.FilesListbox,'Value'); % Selected movie file

% Check size
imsz = size(handles.data(filechoice).imageData);
if ~isequal(imsz(1:2),[512 512])
    mymsgbox('Sorry, image denoising is currently only available for 512x512 frames')
    return
end

% Turn on waitbar
hWaitbar = mywaitbar(0,'Denoising D+A frames. Please wait...','name','iSMS');
setFigOnTop % Sets the waitbar so that it is always in front

% Denoise images
handles = updateDenoisedImages(handles,filechoice,'global'); % Calculate denoised global images
waitbar(1/3,hWaitbar,'Denoising D frames. Please wait...') % Update waitbar
handles = updateDenoisedImages(handles,filechoice,'donor'); % Calculate denoised D-exc images
waitbar(2/3,hWaitbar,'Denoising A frames. Please wait...') % Update waitbar
handles = updateDenoisedImages(handles,filechoice,'acceptor'); % Calculate denoised A-exc images
waitbar(3/3) % Update waitbar

% Delete waitbar
try delete(hWaitbar), end

function Tools_DriftAnalysisWindow_Callback(hObject, ~, handles) %% Drift analysis button from the Tools menu opens the driftwindow
handles = opendriftwindowCallback(handles);

function Tools_PlotPeakStats_Callback(hObject, ~, handles) %% Plots statistics of found peaks as a function of time
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.data)
    return
end

% Check if peak statistics is available
if handles.settings.peakfinder.choice==1
    mymsgbox('To plot peak statistics, select the ''Scan movie'' choice in the peak-finder settings menu (under Settings).','iSMS');
    return
end

% Plot peak statistics
for i = 1:length(handles.data)
    DpeaksMovie = handles.data(i).DpeaksMovie;
    ApeaksMovie = handles.data(i).ApeaksMovie;
    if isempty(DpeaksMovie) && isempty(ApeaksMovie)
        continue
    end
    
    % Plot of # peaks as a function of time
    figure
    updatelogo(gcf)
    set(gcf,'name',sprintf('Number of peaks - %s',handles.data(i).name),'numbertitle','off')
    if ~isempty(DpeaksMovie)
        subplot(2,1,1)
        npeaks = zeros(1,length(DpeaksMovie));
        for j = 1:length(DpeaksMovie)
            npeaks(j) = size(DpeaksMovie{j},1);
        end
        plot(npeaks)
        ylabel('# Donor peaks')
    end
    if ~isempty(ApeaksMovie)
        subplot(2,1,2)
        npeaks = zeros(1,length(ApeaksMovie));
        for j = 1:length(ApeaksMovie)
            npeaks(j) = size(ApeaksMovie{j},1);
        end
        plot(npeaks)
        xlabel('Scan image (proportional to time)')
        ylabel('# Acceptor peaks')
    end
end

function Tools_SpotProfile_Callback(hObject, ~, handles) %% The spot-profile submenu from the Tools menu

function Tools_SpotProfile_LoadGreenProfile_Callback(hObject, ~, handles) %% Opens a dialog for loading a green laser spot-profile
handles = loadDataCallback(handles,1);

function Tools_SpotProfiles_LoadRedProfile_Callback(hObject, ~, handles) %% Opens a dialog for loading a red laser spot-profile
handles = loadDataCallback(handles,2);

function Tools_Spot_Plot_Callback(hObject, eventdata, handles)
if isempty(handles.data)
    set(handles.mboard,'String','No data loaded.')
    return
end

file = get(handles.FilesListbox,'Value');

Gspot = handles.data(file).GspotProfile; % Normalized image of the green laser spot profile of this movie
Rspot = handles.data(file).RspotProfile; % Normalized image of the red laser spot profile of this movie
imgSize = size(handles.data(file).avgimage);
if isempty(Gspot) || isempty(Rspot) ...
        || ~isequal(size(Gspot),size(Rspot)) ...
        || ~isequal(size(Gspot,1),imgSize(1)) || ~isequal(size(Rspot,1),imgSize(1)) ...
        || ~isequal(size(Gspot,2),imgSize(2)) || ~isequal(size(Rspot,2),imgSize(2))
    
    mymsgbox('Incorrect spot profile sizes of selected file')
    return
end

% Get and check ROI positions
[handles, Droi, Aroi] = getROI(handles,file);

% D and A data ranges
donx = Droi(1) :(Droi(1)+Droi(3))-1;
dony = Droi(2) :(Droi(2)+Droi(4))-1;
accx = Aroi(1) :(Aroi(1)+Aroi(3))-1;
accy = Aroi(2) :(Aroi(2)+Aroi(4))-1;

% Cut D ROIs from avgimage
Gimage = double(Gspot(donx , dony)');
Rimage = double(Rspot(accx , accy)');

GRratio = Gimage./Rimage;
GRratio(Gimage==0) = 1;
GRratio(Rimage==0) = 1;

fh = figure;
set(fh,'name','Green/Red ratio image','numbertitle','off')
updatelogo(fh)

subplot(2,2,1)
imagesc(Gimage)
title('Green')
axis xy
axis image

subplot(2,2,2)
imagesc(Rimage)
title('Red')
axis xy
axis image

subplot(2,2,3)
overlay = zeros(size(Gimage,1),size(Gimage,2),3);
overlay(:,:,1) = mat2gray(Rimage);
overlay(:,:,2) = mat2gray(Gimage);
image(overlay)
axis xy
axis image

subplot(2,2,4)
imagesc(GRratio)
axis xy
axis image

function Tools_SpotProfiles_FitTimeDependent_Callback(hObject, eventdata, handles)
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.data)
    return
end

function PerformanceMenu_Callback(hObject, eventdata, handles) %% The performance menu

function MemoryMenu_Callback(hObject, ~, handles) %% The memory menu
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

function Memory_Profile_Callback(hObject, ~, handles) %% The memory profile button displays a memory information message box
memoryprofileCallback(handles);

function Memory_DeleteRawMovieData_Callback(hObject, ~, handles) %% Open dialog for selecting which raw data to delete from which movies
handles = deleteRawDataCallback(handles);

function Memory_ReloadMovie_Callback(hObject, ~, handles) %% Reloads deleted movies
handles = reloadMovieCallback(handles);

function Memory_DeleteFile_Callback(hObject, ~, handles) %% Delete both movies and all other data associated with file
handles = deletefileCallback(handles, 1);

function Performance_Memory_Help_Callback(hObject, eventdata, handles)
myopenURL('http://isms.au.dk/documentation/memory-management/')

function Performance_ParallelMenu_Callback(hObject, eventdata, handles)
parallelMenuCallback(handles)

function Performance_Parallel_OpenPool_Callback(hObject, eventdata, handles)
openpool(handles)

function Performance_Parallel_ClosePool_Callback(hObject, eventdata, handles)
closepool(handles)

function Performance_Parallel_ClusterSize_Callback(hObject, eventdata, handles)
clustersize(handles)

function Performance_Parallel_Choice_Callback(hObject, eventdata, handles)
handles = parallelchoiceCallback(handles);

function Performance_Parallel_Help_Callback(hObject, eventdata, handles)
myopenURL('http://isms.au.dk/documentation/parallel-computing/')

function HelpMenu_Callback(hObject, ~, handles) %% The Help menu
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

function Help_About_Callback(hObject, ~, handles) %% The About from the Help menu
% Copyrights string
copyrights = sprintf([...
    'iSMS - Single-Molecule FRET Microscopy Software\n'...
    '     Copyright (C)  Aarhus University \n'...
    '                           @ V. Birkedal Lab\n'...
    '\n     Version: %s '...
    '\n\n     Contact: Søren Preus, preus@inano.au.dk\n\n'],handles.version);

% Version
if ~handles.ispublic
    copyrights = sprintf('\n%sOBS: This is an internal version and my contain undocumented functionalities.\n\n ',copyrights)
end

% Dialog
choice = myquestdlg(copyrights,...
    'About iSMS', ...
    ' Website ', ' Terms of use ', ' Close ', ' Website ');

% Open site
if strcmpi(choice,' Website ')
    myopenURL('http://isms.au.dk/')
    
elseif strcmpi(choice, ' Terms of use ')
    myopenURL('http://www.gnu.org/licenses/gpl.html')
end

function Help_GettingStarted_Callback(hObject, eventdata, handles)
myopenURL('http://isms.au.dk/getstarted/')

function Help_OnlineDocumentation_Callback(hObject, ~, handles) %% The online documentation callback
myopenURL('http://isms.au.dk/documentation/')

function Help_CheckForUpdates_Callback(hObject, eventdata, handles)
checkforUpdatesNow(handles, handles.checkversion); % Returns the latest version html as a string. 'Timeout',5 is only implemented from R2013

function Help_CheckForUpdatesStartup_Callback(hObject, eventdata, handles)
handles = checkforUpdatesOnStartup(handles);

function Help_BugReport_Callback(hObject, ~, handles) %% The Bug report callback
myopenURL('http://isms.au.dk/troubleshooting/bugreport/')

function Help_ResetCursor_Callback(hObject, eventdata, handles)
set(handles.figure1,'Pointer','arrow')

function Help_DevelopersMenu_Callback(hObject, ~, handles) %% The for developers menu
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

function Developers_Mainhandles_Callback(hObject, ~, handles) %% Callback for selecting send mainhandles structure
mainhandles = handles; % Rename

assignin('base', 'mainhandles', handles) % Send to workspace
% try fn_structdisp(mainhandles), end % Displays details about the structure in the command window
set(handles.mboard, 'String','mainhandles structure was sent to workspace.') % Display message

function DevelopersMenu_NeedToKnow_Callback(hObject, ~, handles) %% Opens the developers web page
myopenURL('http://isms.au.dk/community/developers/')

function Help_Developers_InternalSettings_Callback(hObject, ~, handles) %% Sends the internal settings structure to the matlab workspace
settings_internal = internalSettingsStructure(); % Internal defaults
fn_structdisp(settings_internal) % Displays details about the structure in the command window

assignin('base', 'settings_internal', settings_internal) % Send to workspace
set(handles.mboard, 'String','settings_internal structure was sent to workspace.') % Display message

function Help_Developers_DefaultSettings_Callback(hObject, ~, handles) %% Sends the default settings structure to the matlab workspace
settings_internal = internalSettingsStructure(); % Internal defaults
settings_default = loadDefaultSettings(handles, settings_internal); % Default settings
fn_structdisp(settings_default) % Displays details about the structure in the command window

assignin('base', 'settings_default', settings_default) % Send to workspace
set(handles.mboard, 'String','settings_default structure was sent to workspace.') % Display message

function Help_Developers_mfile_Callback(hObject, ~, handles) %% Opens this m-file
edit iSMS.m

function Help_Developers_figfile_Callback(hObject, ~, handles) %% Opens fig file in GUIDE
guide iSMS

function Help_Developers_flexgrids_Callback(hObject, eventdata, handles)
edit createGridFlex.m

function Help_Developers_OpenSettings_Callback(~, eventdata, handles)
edit internalSettingsStructure.m

function Help_Developers_OpenStoreMovie_Callback(hObject, eventdata, handles)
edit storeMovie

% --------------------------------------------------------------------
% ----------------------------- Toolbar ------------------------------
% --------------------------------------------------------------------

function Toolbar_NewSession_ClickedCallback(hObject, eventdata, handles)
newSessionCallback(handles)

function Toolbar_OpenSession_ClickedCallback(hObject, eventdata, handles)
handles = opensession(handles.figure1);

function Toolbar_SaveSession_ClickedCallback(hObject, eventdata, handles)
handles = savesession(handles.figure1);

function Toolbar_zoomtool_ClickedCallback(hObject, eventdata, handles)
handles = zoomtoolCallback(handles,'ROI');

function Toolbar_FRETpairwindow_OnCallback(hObject, ~, handles) %% Activates the FRET-pair window and assigns it the handle: FRETpairwindowHandle
handles = openFRETpairwindowCallback(handles);

function Toolbar_FRETpairwindow_OffCallback(hObject, ~, handles) %% Closes the FRET-pair window
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.FRETpairwindowHandle)
    return
end
try
    delete(handles.FRETpairwindowHandle)
end

% Close histogram window if its open
if strcmp(get(handles.Toolbar_histogramwindow,'State'),'on')
    set(handles.Toolbar_histogramwindow,'State','off')
end

% Turn of selected-FRETpair markers
% Remove previous markers
% VERSION DEPENDENT SYNTAX
if handles.matver>8.3
    h = findobj(handles.ROIimage,'MarkerFaceColor','flat');
    delete(h)
else
    h = findobj(handles.ROIimage,'MarkerFaceColor','green');
    delete(h)
    h = findobj(handles.ROIimage,'MarkerFaceColor','red');
    delete(h)
    h = findobj(handles.ROIimage,'MarkerFaceColor','yellow');
    delete(h)
end

function Toolbar_histogramwindow_OnCallback(hObject, ~, handles) %% Activates the E-S histogram plot window
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if (~isempty(handles.histogramwindowHandle)) && (ishandle(handles.histogramwindowHandle))
    return
end

% Open FRET-pair window, if its not already open
if strcmp(get(handles.Toolbar_FRETpairwindow,'State'),'off')
    set(handles.Toolbar_FRETpairwindow,'State','on')
    handles = guidata(handles.figure1);
end

% handles = updateROIimage(handles); % Also updates the ROImovies in the handles structure. Also exports the handle to the main window to appdata, via saveROImovies
% handles = updatepeakplot(handles,'all'); % This will also run updateFRETpairs, updateFRETpairlist, updatemainhandles and highlightFRETpair
updatemainhandles(handles) % Sends the handles structure to appdata
histogramwindowHandle = histogramwindow; % Opens the Histogram-GUI window and saves its handle in the mainhandles structure
handles = guidata(handles.figure1); % Get the new update main handles structure updated by the histogramwindow GUI
handles.histogramwindowHandle = histogramwindowHandle; % Put the handle of the histogramwindow into the handles structure
updatemainhandles(handles) % Updates the handles structure

function Toolbar_histogramwindow_OffCallback(hObject, ~, handles) %% Closes the E-S histogram plot window
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.histogramwindowHandle)
    return
end
try
    delete(handles.histogramwindowHandle)
end

function Toolbar_correctionfactorWindow_OnCallback(hObject, ~, handles) %% Opens the correction factor window
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if (~isempty(handles.correctionfactorwindowHandle)) && (ishandle(handles.correctionfactorwindowHandle))
    return
end

% Open FRET-pair window, if its not already open
if strcmp(get(handles.Toolbar_correctionfactorWindow,'State'),'off')
    set(handles.Toolbar_correctionfactorWindow,'State','on')
    handles = guidata(handles.figure1);
end

updatemainhandles(handles) % Sends the handles structure to appdata
correctionfactorwindowHandle = correctionfactorWindow; % Opens the Histogram-GUI window and saves its handle in the mainhandles structure
handles = guidata(handles.figure1); % Get the new update main handles structure updated by the histogramwindow GUI
handles.correctionfactorwindowHandle = correctionfactorwindowHandle; % Put the handle of the histogramwindow into the handles structure
updatemainhandles(handles) % Updates the handles structure

function Toolbar_correctionfactorWindow_OffCallback(hObject, ~, handles) %% Closes the correction factor window
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.correctionfactorwindowHandle)
    return
end
try
    delete(handles.correctionfactorwindowHandle)
end

function Toolbar_dynamicswindow_OnCallback(hObject, ~, handles) %% Opens the dynamics analysis window
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if (~isempty(handles.dynamicswindowHandle)) && (ishandle(handles.dynamicswindowHandle))
    return
end

% Open FRET-pair window, if its not already open
if strcmp(get(handles.Toolbar_FRETpairwindow,'State'),'off')
    set(handles.Toolbar_FRETpairwindow,'State','on')
    handles = guidata(handles.figure1);
end

updatemainhandles(handles) % Sends the handles structure to appdata
dynamicswindowHandle = dynamicsWindow2; % Opens the Histogram-GUI window and saves its handle in the mainhandles structure
handles = guidata(handles.figure1); % Get the new update main handles structure updated by the histogramwindow GUI
handles.dynamicswindowHandle = dynamicswindowHandle; % Put the handle of the histogramwindow into the handles structure
updatemainhandles(handles) % Updates the handles structure

function Toolbar_dynamicswindow_OffCallback(hObject, ~, handles) %% Closes the dynamics analysis window
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.dynamicswindowHandle)
    return
end
try
    delete(handles.dynamicswindowHandle)
end

function Toolbar_profileWindow_OnCallback(hObject, ~, handles) %% Opens the spot profile editor window
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if (~isempty(handles.profilewindowHandle)) && (ishandle(handles.profilewindowHandle))
    return
end

updatemainhandles(handles) % Sends the handles structure to appdata
handles.profilewindowHandle = profileWindow2; % Put the handle of the new window into the handles structure
updatemainhandles(handles) % Updates the handles structure

function Toolbar_profileWindow_OffCallback(hObject, ~, handles) %% Closes the spot profile editor window
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if isempty(handles.profilewindowHandle)
    return
end
try
    delete(handles.profilewindowHandle)
end

function Toolbar_ROIimage_ClickedCallback(hObject, ~, handles) %% Shift emission channel in ROI image plot
handles = shiftROIchannelCallback(handles);

function Toolbar_DPeaksToggle_ClickedCallback(hObject, ~, handles) %% If this green toggle-button in the Toolbar is turned on and no Don-peaks exist, run peakfinder
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if strcmpi(get(handles.Toolbar_DPeaksToggle,'State'),'on')
    handles = updatepeakplot(handles,'donor',0,0);
else
    handles = clearROIpeaks(handles,'donor');
end

function Toolbar_APeaksToggle_ClickedCallback(hObject, ~, handles) %% If this green toggle-button in the Toolbar is turned on and no Acc-peaks exist, run peakfinder
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if strcmpi(get(handles.Toolbar_APeaksToggle,'State'),'on')
    handles = updatepeakplot(handles,'acceptor',0,0);
else
    handles = clearROIpeaks(handles,'acceptor');
end

function Toolbar_EPeaksToggle_ClickedCallback(hObject, ~, handles) %% Chooses whether found FRET-pairs are plotted in the ROI window or not
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar

% Action
if strcmpi(get(handles.Toolbar_EPeaksToggle,'State'),'on')
    % Show peaks
    handles = updatepeakplot(handles,'FRET',0,0);
else
    handles = clearROIpeaks(handles,'fret');
end

function Toolbar_AddDPeaks_OnCallback(hObject, ~, handles) %% The 'Select donor peaks manually' button from the Toolbar allows the user to point at donors in the ROI image
handles = addDpeaksCallback(handles);

function Toolbar_AddDPeaks_OffCallback(hObject, ~, handles) %% Turns off the manual donor selection tool
myginputc(0);

function Toolbar_AddAPeaks_OnCallback(hObject, ~, handles) %% The 'Select acceptor peaks manually' button from the Toolbar allows the user to point at acceptors in the ROI image
handles = addApeaksCallback(handles);

function Toolbar_AddAPeaks_OffCallback(hObject, ~, handles) %% Turns off the manual acceptor selection tool
myginputc(0);

function Toolbar_AddEPeaks_OnCallback(hObject, ~, handles) %% Manually select new FRET-pairs from ROI image button
handles = addEpeaksCallback(handles);

function Toolbar_AddEPeaks_OffCallback(hObject, ~, handles) %% Turns off the manual FRET-pair selection tool
myginputc(0);

function Toolbar_DeleteDPeaks_OnCallback(hObject, ~, handles) %% Manually delete donor peaks one at a time in ROI image
handles = deleteDpeaksCallback(handles);

function Toolbar_DeleteDPeaks_OffCallback(hObject, ~, handles) %% Turn off manual donor deletion mode
myginputc(0);

function Toolbar_DeleteAPeaks_OnCallback(hObject, ~, handles) %% Manually delete acceptor peaks one at a time in ROI image
handles = deleteApeaksCallback(handles);

function Toolbar_DeleteAPeaks_OffCallback(hObject, ~, handles) %% Turn off manual deletion acceptor mode
myginputc(0);

function Toolbar_DeleteMultiplePeaksToggle_OnCallback(hObject, ~, handles) %% Turn on lasso selection for multiple peak deletion
handles = turnofftoggles(handles,'DeleteMultiple'); % Turn off all interactive toggle buttons in the toolbar
if isempty(handles.data) % If no data is loaded, return
    set(handles.mboard,'String','No data loaded')
    set(handles.Toolbar_DeleteMultiplePeaksToggle,'State','off')
    return
end
filechoice = get(handles.FilesListbox,'Value');
if (isempty(handles.data(filechoice).Dpeaks)) && (isempty(handles.data(filechoice).Apeaks)) % If no data is loaded, return
    set(handles.mboard,'String','There are no peaks on image')
    set(handles.Toolbar_DeleteMultiplePeaksToggle,'State','off')
    return
end

% Delete text labels, because selectdata cannot deal with those
if strcmp(get(handles.Toolbar_EPeaksToggle,'state'),'on')
    h = findobj(handles.ROIimage,'type','text');
    delete(h)
end

% Make user selection
handles = myguidebox(handles,'Remove peaks using lasso tool','Delete donor and acceptor peaks by dragging the lasso-selection tool across the ROI image.','lasso');

set(handles.mboard,'String','Delete donor and acceptor peaks by dragging the lasso-selection tool across the ROI image')
% axes(handles.ROIimage) % Set as current axes
% figure(handles.figure1)
setappdata(0,'stopselectdata',[])
[pind,xs,ys] = myselectdata('Axes',handles.ROIimage,...
    'Fig',handles.figure1,...
    'selectionmode','lasso',...
    'Ignore',[],...
    'Identify','on',...
    'FillTrans',1);

if isempty(xs)
    set(handles.mboard,'String','')
    set(handles.Toolbar_DeleteMultiplePeaksToggle,'State','off')
    return
end

% Delete selected peaks
if ~iscell(pind) % Make sure point-indices are specified as cell array
    pind = {pind};
end
if ~iscell(xs) % Make sure point-coordinates are specified as cell array
    xs = {xs};
    ys = {ys};
end

for i = 1:size(pind,1)
    if isempty(pind{i})
        continue
    end
    
    % Delete donor peaks
    idx = find(ismember(handles.data(filechoice).Dpeaks,[xs{i} ys{i}],'rows','legacy')); % Index of selected peaks in Dpeaks
    handles.data(filechoice).Dpeaks(idx,:) = [];
    handles.data(filechoice).DpeaksRaw(find(ismember(handles.data(filechoice).DpeaksRaw(:,2:3),[xs{i} ys{i}],'rows','legacy')),:) = [];
    
    % Delete acceptor peaks
    idx = find(ismember(handles.data(filechoice).Apeaks,[xs{i} ys{i}],'rows','legacy')); % Index of selected peaks in Apeaks
    handles.data(filechoice).Apeaks(idx,:) = [];
    handles.data(filechoice).ApeaksRaw(find(ismember(handles.data(filechoice).ApeaksRaw(:,2:3),[xs{i} ys{i}],'rows','legacy')),:) = [];
end

updatemainhandles(handles)
handles = updatepeakglobal(handles,'all');
Epairs_p = length(handles.data(filechoice).FRETpairs); % Number of FRET-pairs prior to deletion
handles = updatepeakplot(handles,'all'); % Updates the peaks on the ROI image, removes FRET-pairs of deleted peaks, via updateFRETpairs, and updates the FRETpairwindow
Epairs_n = length(handles.data(filechoice).FRETpairs); % Number of FRET-pairs post deletion

% If number of FRET-pairs has changed, update the
% histogramwindow if it's open
if (Epairs_p~=Epairs_n) && (strcmp(get(handles.Toolbar_histogramwindow,'State'),'on'))
    handles = updateSEplot(handles.figure1,handles.FRETpairwindowHandle,handles.histogramwindowHandle,'all');
end

set(handles.mboard,'String','')
set(handles.Toolbar_DeleteMultiplePeaksToggle,'State','off')

function Toolbar_DeleteMultiplePeaksToggle_OffCallback(hObject, ~, handles) %% Turn off the lasso selection tool
setappdata(0,'stopselectdata',1) % This will tell selectdata to cancel execution when mouse button press is emulated below
rightmouseclickMain(handles) % Emulate mouse button press

function Toolbar_FindEpairs_ClickedCallback(hObject, ~, handles,slidercall) %% Automatically detects potential donor-acceptor pairs on ROI image
handles = findEpairsCallback(handles, 0);

function Toolbar_AlignROIs_ClickedCallback(hObject, ~, handles) %% Align ROIs automatically
handles = autoalignROIsCallback(handles);

function Toolbar_Run_ClickedCallback(hObject, ~, handles) %% Runs a set of callbacks: 1) auto-ROI, 2) peakfinder, 3) opens FRETpair & histogramwindow

handles = autorunCallback(handles);

% --------------------------------------------------------------------
% ---------------------------- GUI objects ---------------------------
% --------------------------------------------------------------------

function DataUpPushbutton_Callback(hObject, ~, handles) %% The data up arrow button
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
filechoice = get(handles.FilesListbox,'Value');
if (filechoice<=1) || (isempty(handles.data))
    return
end

% Interchange selected file with the one above:
temp = handles.data(filechoice);
handles.data(filechoice) = handles.data(filechoice-1);
handles.data(filechoice-1) = temp;

% Update GUI
set(handles.FilesListbox,'Value',filechoice-1)
updatemainhandles(handles)
updatefileslist(handles.figure1,handles.histogramwindowHandle)
handles = updaterawimage(handles);
handles = updateROIhandles(handles);
handles = updateframesliderHandle(handles);
handles = updateROIimage(handles,0,0,0);

% Update FRET pair list
updateFRETpairlist(handles.figure1,handles.FRETpairwindowHandle)
function DataUpPushbutton_CreateFcn(hObject, ~, handles) %% Runs when the data up arrow button is created
set(hObject,'FontName','Symbol','String',char(173),'FontSize',12) % Sets the button string to an up arrow

function DataDownPushbutton_Callback(hObject, ~, handles)  %% The data up arrow button
handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
filechoice = get(handles.FilesListbox,'Value');
if (filechoice>=length(handles.data)) || (isempty(handles.data))
    return
end

% Interchange selected file with the one below:
temp = handles.data(filechoice);
handles.data(filechoice) = handles.data(filechoice+1);
handles.data(filechoice+1) = temp;

% Update GUI
set(handles.FilesListbox,'Value',filechoice+1)
updatemainhandles(handles)
updatefileslist(handles.figure1,handles.histogramwindowHandle)
handles = updaterawimage(handles);
handles = updateROIhandles(handles);
handles = updateframesliderHandle(handles);
handles = updateROIimage(handles,0,0,0);

% Update FRET pair list
updateFRETpairlist(handles.figure1,handles.FRETpairwindowHandle)
function DataDownPushbutton_CreateFcn(hObject, ~, handles) %% Runs when the data down arrow button is created
set(hObject,'FontName','Symbol','String',char(175),'FontSize',12) % Sets the button string to a down arrow

function AddMoviePushbutton_Callback(hObject, ~, handles) %% This '...' button runs the File -> LoadData function
handles = loadDataCallback(handles,0);

function DeleteMoviePushbutton_Callback(hObject, ~, handles) %% This 'X' button deletes selected data set
handles = deletefileCallback(handles);

function ReloadMoviePushbutton_Callback(hObject, eventdata, handles)
handles = reloadMovieCallback(handles);

function ClearRawPushbutton_Callback(hObject, eventdata, handles)
handles = deleteRawDataCallback(handles);
