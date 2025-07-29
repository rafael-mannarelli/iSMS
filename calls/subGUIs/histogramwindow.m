function varargout = histogramwindow(varargin) %% Initializes the GUI
% HISTOGRAMWINDOW - GUI window associated with sms for plotting histograms
%
%  histogramwindow.m cannot be by called by itself as it relies on handles
%  sent by both the sms.m main figure window and the FRETpairwindow.m upon
%  opening.
%
%  The histogramwindow GUI is programmed using GUIDE. The callbacks of
%  the GUI is found in the histogramwindow.m file and is divided into
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

% Last Modified by GUIDE v2.5 16-Mar-2015 17:36:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @histogramwindow_OpeningFcn, ...
    'gui_OutputFcn',  @histogramwindow_OutputFcn, ...
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

function histogramwindow_OpeningFcn(hObject, eventdata, handles, varargin) %% Executes just before FRETpairwindow is made visible
% Set position, title and logo. Turn off visibility.
initGUI(handles.figure1, 'S-E Histogram Window', 'east');

% Handle to main figure window
handles.main = getappdata(0,'mainhandle');
mainhandles = guidata(handles.main);
guidata(handles.figure1,handles)

% Update GUI depending on excitation scheme
mainhandles = updateALEX(mainhandles,[],handles.figure1);

% Update visible functionalities
mainhandles = updatePublic(mainhandles,[],handles.figure1);

% Axes
xlabel(handles.SEplot,'Proximity Ratio (PR)')
ylabel(handles.SEplot,'Stoichiometry (S)')
linkaxes([handles.SEplot handles.Ehist],'x')
% % linkaxes([handles.SEplot handles.Shist],'y')
view(handles.Shist,90,-90)
set(zoom(handles.SEplot),'ActionPostCallback',@(x,y) PostZooming(handles.SEplot));

% Custom data cursor
hdt = datacursormode;
set(hdt,'DisplayStyle','window');
set(hdt,'UpdateFcn',@DataCursorCallback)
datacursormode('off')

% Update GUI with data
updatefileslist(handles.main,handles.figure1)
mainhandles = guidata(handles.main);
set(handles.FilesListbox,'Value', get(mainhandles.FilesListbox,'Value'))
set(handles.plotAllExceptPopupMenu,'Value',mainhandles.settings.SEplot.exceptchoice)
set(handles.GaussiansSlider,'Value',mainhandles.settings.SEplot.nGaussians)
set(handles.GaussiansEditbox,'String',mainhandles.settings.SEplot.nGaussians)
mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'all');

% Update GUI according to default settings
updateHistwindowGUImenus(mainhandles,handles)

% Turn off some things if its a deployed version
turnoffDeployed(mainhandles, [], handles.figure1);

% Open Gaussian components window
if mainhandles.settings.SEplot.GaussianComponentsTable
    set(handles.Toolbar_GaussianComponentsWindow,'State','on')
    mainhandles = guidata(handles.main);
end

% histogramwindowResizeFcn(handles)
set(handles.GaussTable,'data',[]) % Update the FRET-pairs listbox
set(handles.GaussTable,'RowName',{})

% Choose default command line output for histogramwindow
handles.output = hObject; % Return handle to GUI window

% Update handles structure
updatehistogramwindowHandles(handles)

% Set some GUI settings
setGUIappearance(handles.figure1,0)

function varargout = histogramwindow_OutputFcn(hObject, ~, handles) %% Outputs from this function are returned to the command line (not used here)
% Resize final time (this function is run at the end of startup)
histogramwindowResizeFcn(handles)

% Now show GUI
set(handles.figure1,'Visible','on')

varargout{1} = handles.output;

function figure1_ResizeFcn(hObject, eventdata, handles)
histogramwindowResizeFcn(handles)

function figure1_CloseRequestFcn(hObject, ~, handles) %% Runs when the GUI window is closed
% Turn off toggle button in main window
try
    mainhandles = guidata(handles.main);
    set(mainhandles.Toolbar_histogramwindow,'State','off')
    delete(mainhandles.GaussianComponentsWindowHandle)
end

% Aims to delete all data and handles used by the program before closing
try cla(handles.SEplot)
    cla(handles.Ehist)
    cla(handles.Shist)
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

function ExportMenu_Callback(hObject, ~, handles) %% The export menu

function Export_SaveSession_Callback(hObject, ~, handles) %% Saves iSMS session
mainhandles = savesession(handles.main);

function Export_Figure_Callback(hObject, ~, handles) %% Opens export figure dialog
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

% Open a dialog for specifying export properties
settings = export_fig_dlg;
if isempty(settings)
    return
end

% Handles of objects to hide when exporting figure
h = [handles.plotchoicePanel,...
    handles.plotSelectedPairRadiobutton,...
    handles.plotSelectedGroupRadiobutton,...
    handles.plotAllPairsRadiobutton,...
    handles.plotAllWithBleachRadiobutton,...
    handles.plotAllExceptRadiobutton...
    handles.plotAllExceptPopupMenu...
    handles.MergeFilesTextbox,...
    handles.FilesListbox,...
    handles.GaussiansPanel,...
    handles.GaussiansTextbox,...
    handles.GaussiansEditbox,...
    handles.GaussiansSlider,...
    handles.GaussTable,...
    handles.FitPushbutton...
    handles.backgroundPanel...
    handles.EbinsizeSlider,...
    handles.SbinsizeSlider,...
    handles.moleculeCounterTextbox,...
    handles.moleculeCounter,...
    handles.frameCounterTextbox,...
    handles.frameCounter,...
    handles.EbinsTextbox...
    handles.SbinsTextbox];

% Turn on waitbar
hWaitbar = mywaitbar(1,'Exporting figure. Please wait...','name','iSMS');
setFigOnTop % Sets the waitbar so that it is always in front

% Turn GUI into white empty background
if settings.transparent
    h2 = [handles.SEplot handles.Ehist handles.Shist];
    set(h2,'Color','none')
end
datacursor = 0; % Marker off whether data cursor is on or off
cursor = datacursormode(handles.figure1);
xlabl = get(handles.SEplot,'xlabel');
ylabl = get(handles.SEplot,'ylabel');
xlabel(handles.SEplot,'')
ylabel(handles.SEplot,'')
if strcmp(get(cursor,'Enable'),'on') % If data cursor mode is on, turn it off
    set(cursor,'Enable','off')
    datacursor = 1;
end
panel1string = get(handles.plotchoicePanel,'Title');
panel2string = get(handles.GaussiansPanel,'Title');
set(handles.plotchoicePanel,'Title','') % The panel titles are not hidden by just setting panel visibility to off
set(handles.GaussiansPanel,'Title','')
set(h,'Visible','off') % Turn of GUI object visibilities
set(handles.figure1,'Color','white') % Set GUI background to white

% Export figure
warning off
try
    figure(handles.figure1)
    eval(settings.command) % This will run export_fig with settings specified in export_fig_dlg
    
catch err
    %     err
    %     Error = err.message
    
    % Turn GUI back to original
    set(h,'Visible','on')
    set(handles.figure1,'Color', [0.94118  0.94118  0.94118])
    set(handles.plotchoicePanel,'Title',panel1string)
    set(handles.GaussiansPanel,'Title',panel2string)
    xlabel(handles.SEplot,xlabl)
    ylabel(handles.SEplot,ylabl)
    
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
warning on

% Turn GUI back to original
set(h,'Visible','on')
if ~get(handles.plotAllPairsRadiobutton,'Value')
    set([handles.MergeFilesTextbox, handles.FilesListbox], 'Enable','off')
end
if ~mainhandles.settings.SEplot.showbins
    set([handles.EbinsTextbox, handles.SbinsTextbox], 'visible','off')
end
if ~mainhandles.settings.excitation.alex
    set(handles.SbinsTextbox,'Visible','off')
end

% VERSION DEPENDENT SYNTAX
if mainhandles.matver>8.3
    xlabel(handles.SEplot,xlabl.String)
    ylabel(handles.SEplot,ylabl.String)
else
    xlabel(handles.SEplot,xlabl)
    ylabel(handles.SEplot,ylabl)
end
set(handles.figure1,'Color', [0.94118  0.94118  0.94118])
if settings.transparent
    set(h2,'Color','white')
end
set(handles.plotchoicePanel,'Title',panel1string)
set(handles.GaussiansPanel,'Title',panel2string)
if datacursor
    set(cursor,'Enable','on')
end

% Delete waitbar
try delete(hWaitbar), end

% If window has been deleted by export fig (for unknown reasons)
mainhandles = guidata(handles.main);
if strcmpi(get(mainhandles.Toolbar_histogramwindow,'State'),'off')
    set(mainhandles.Toolbar_histogramwindow,'State','on')
end

updateALEX(mainhandles);

function Export_SMD_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'smd','plotted');

function Export_ASCII_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'ascii','plotted');

function Export_vbFRET_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'vbFRET','molmovie');

function Export_HaMMy_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'hammy','molmovie');

function Export_boba_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'boba','plotted');

function Export_Workspace_Callback(hObject, eventdata, handles)
exportMoleculesCallback(handles.main,'workspace','molmovie');

function Export_Plot_Callback(hObject, ~, handles) %% The export figure from the export menu
mymsgbox('Right-click inside figure for export options.')

function EditMenu_Callback(hObject, ~, handles) %% The Edit menu

function Edit_Markers_Callback(hObject, ~, handles) %% The marker button from the Edit->Plot menu
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

% Prepare dialog box
prompt = {'Marker size:' 'markersize'};
name = 'Markers';

% Handles formats
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(2,1).type   = 'edit';
formats(2,1).format = 'float';
formats(2,1).size = 80;
% formats(3,1).type   = 'edit';
% formats(3,1).format = 'float';
% formats(3,1).size = 80;
% formats(4,1).type   = 'edit';
% formats(4,1).format = 'float';
% formats(4,1).size = 80;

% Default answers:
DefAns.markersize = mainhandles.settings.SEplot.markersize;
% DefAns.markertype = 1;
% DefAns.markercolor = 1;

% Open input dialogue and get answer
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns); % Open dialog box
if cancelled == 1
    return
end

markersize = abs(answer.markersize);
mainhandles.settings.SEplot.markersize = markersize;
updatemainhandles(mainhandles)
h = findobj(handles.SEplot,'markersize',DefAns.markersize);
set(h,'markersize',markersize)
mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'SEplot',[],[],1);

function Edit_Limits_Callback(hObject, ~, handles) %% Set plot x- and y-limits dialog
mainhandles = setHistLimitsCallback(handles);

function ViewMenu_Callback(hObject, ~, handles) %% The View menu

function View_PlotTypeMenu_Callback(hObject, eventdata, handles)

function View_Type_RegScatter_Callback(hObject, eventdata, handles)
mainhandles = plottypeCallback(handles,1);

function View_Type_DensScatter_Callback(hObject, eventdata, handles)
mainhandles = plottypeCallback(handles,2);

function View_Type_DensImg_Callback(hObject, eventdata, handles)
mainhandles = plottypeCallback(handles,3);

function mainhandles = plottypeCallback(handles,choice)
% Get mainhandles
mainhandles = getmainhandles(handles);

% New setting
mainhandles.settings.SEplot.SEplotType = choice; % scatplot

% Update
updatemainhandles(mainhandles)
updateHistwindowGUImenus(mainhandles,handles)
mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'SEplot',[],[],1);

function View_PlottedMenu_Callback(hObject, eventdata, handles)

function View_Plotted_All_Callback(hObject, eventdata, handles)
mainhandles = SEdataplottedCallback(handles,1);

function View_Plotted_Prior1st_Callback(hObject, eventdata, handles)
mainhandles = SEdataplottedCallback(handles,2);

function View_Plotted_Post1st_Callback(hObject, eventdata, handles)
mainhandles = SEdataplottedCallback(handles,3);

function View_Plotted_Prior2nd_Callback(hObject, eventdata, handles)
mainhandles = SEdataplottedCallback(handles,4);

function View_Plotted_Post2nd_Callback(hObject, eventdata, handles)
mainhandles = SEdataplottedCallback(handles,5);

function View_Plotted_Donly_Callback(hObject, eventdata, handles)
mainhandles = SEdataplottedCallback(handles,6);

function View_Plotted_Aonly_Callback(hObject, eventdata, handles)
mainhandles = SEdataplottedCallback(handles,7);

function View_Plotted_DAonly_Callback(hObject, eventdata, handles)
mainhandles = SEdataplottedCallback(handles,8);

function View_ValuesMenu_Callback(hObject, eventdata, handles)

function View_Values_All_Callback(hObject, eventdata, handles)
mainhandles = SEvaluesplottedCallback(handles,1);

function View_Values_Avg_Callback(hObject, eventdata, handles)
mainhandles = SEvaluesplottedCallback(handles,2);

function View_Values_Median_Callback(hObject, eventdata, handles)
mainhandles = SEvaluesplottedCallback(handles,3);

function View_ESplotType_Callback(hObject, ~, handles) %% The switch ES plot type from the View menu
if (isempty(handles.main)) || (~ishandle(handles.main))
    mymsgbox('For some reason the handle to the main window is lost. Please reload this window.');
    return
end

% Set new plot type in the mainhandles structure
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end
if mainhandles.settings.SEplot.SEplotType == 1
    mainhandles.settings.SEplot.SEplotType = 3; % scatplot
elseif mainhandles.settings.SEplot.SEplotType == 2
    mainhandles.settings.SEplot.SEplotType = 1; % smoothhist2D
elseif mainhandles.settings.SEplot.SEplotType == 3
    mainhandles.settings.SEplot.SEplotType = 2; % Regular single colored scatter plot
end
updatemainhandles(mainhandles)

% Update scatter plot
mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'SEplot',[],[],1);
updateHistwindowGUImenus(mainhandles,handles)

function View_Colormap_Callback(hObject, ~, handles) %% The switch colormap button from the View menu
if (isempty(handles.main)) || (~ishandle(handles.main))
    mymsgbox('For some reason the handle to the main window is lost. Please reload this window.');
    return
end

% Set new colormap in the mainhandles structure
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

% Old colormap needed for updating density scatter plot
colmap_prev = eval( lower(mainhandles.settings.SEplot.colormap) );
if mainhandles.settings.SEplot.colorinversion
    colmap_prev = flipud(colmap_prev);
end

if mainhandles.settings.SEplot.SEplotType == 1 % If regular single-colored scatter
    
    mainhandles.settings.SEplot.colorOrder = circshift(mainhandles.settings.SEplot.colorOrder(:),[-1 0])';
    
else % If density colored-plot
    
    if strcmpi(mainhandles.settings.SEplot.colormap,'jet')
        mainhandles.settings.SEplot.colormap = 'hsv';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'hsv')
        mainhandles.settings.SEplot.colormap = 'hot';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'hot')
        mainhandles.settings.SEplot.colormap = 'cool';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'cool')
        mainhandles.settings.SEplot.colormap = 'spring';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'spring')
        mainhandles.settings.SEplot.colormap = 'summer';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'summer')
        mainhandles.settings.SEplot.colormap = 'autumn';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'autumn')
        mainhandles.settings.SEplot.colormap = 'winter';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'winter')
        mainhandles.settings.SEplot.colormap = 'gray';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'gray')
        mainhandles.settings.SEplot.colormap = 'bone';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'bone')
        mainhandles.settings.SEplot.colormap = 'copper';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'copper')
        mainhandles.settings.SEplot.colormap = 'pink';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'pink')
        mainhandles.settings.SEplot.colormap = 'jet';
    end
    
end

% Update
updatemainhandles(mainhandles)
if mainhandles.settings.SEplot.SEplotType == 3
    % If plotting image
    
    colmap_new = eval( lower(mainhandles.settings.SEplot.colormap) );
    if mainhandles.settings.SEplot.colorinversion
        colmap_new = flipud(colmap_new);
    end
    colormap(handles.SEplot,colmap_new)
    
elseif mainhandles.settings.SEplot.SEplotType == 2
    
    % Plotting scatter density plot - change colors one by one
    colmap_new = eval( lower(mainhandles.settings.SEplot.colormap) ); % new colmap
    if mainhandles.settings.SEplot.colorinversion
        colmap_new = flipud(colmap_new);
    end
    
    h = findobj(handles.SEplot,'type','line'); % Get all plotted points
    if isempty(h)
        return
    end
    
    % Change the color of each "line" plot, one by one
    for i=1:length(h)
        [~,idx] = ismember(get(h(i),'Color'),colmap_prev,'rows');
        if idx>0
            set(h(i),'Color',colmap_new(idx,:))
        end
    end
    
else % If plotting regular scatter
    
    mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'SEplot');
end

function View_InverseColors_Callback(hObject, ~, handles) %% Inverse colors
if (isempty(handles.main)) || (~ishandle(handles.main))
    mymsgbox('For some reason the handle to the main window is lost. Please reload this window.');
    return
end

% Set new colormap in the mainhandles structure
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

% Old colormap needed for updating density scatter plot
colmap_prev = eval( lower(mainhandles.settings.SEplot.colormap) );
if mainhandles.settings.SEplot.colorinversion
    colmap_prev = flipud(colmap_prev);
end

% Update settings
if mainhandles.settings.SEplot.colorinversion
    mainhandles.settings.SEplot.colorinversion = 0;
else
    mainhandles.settings.SEplot.colorinversion = 1;
end

% Update
updatemainhandles(mainhandles)
if mainhandles.settings.SEplot.SEplotType == 3
    % If plotting image
    colmap_new = eval( lower(mainhandles.settings.SEplot.colormap) );
    if mainhandles.settings.SEplot.colorinversion
        colmap_new = flipud(colmap_new);
    end
    colormap(handles.SEplot,colmap_new)
    
elseif mainhandles.settings.SEplot.SEplotType == 2
    
    % Plotting scatter density plot - change colors one by one
    colmap_new = eval( lower(mainhandles.settings.SEplot.colormap) ); % new colmap
    if mainhandles.settings.SEplot.colorinversion
        colmap_new = flipud(colmap_new);
    end
    
    h = findobj(handles.SEplot,'type','line'); % Get all plotted points
    if isempty(h)
        return
    end
    
    % Change the color of each "line" plot, one by one
    for i=1:length(h)
        [~,idx] = ismember(get(h(i),'Color'),colmap_prev,'rows');
        if idx>0
            set(h(i),'Color',colmap_new(idx,:))
        end
    end
    
else % If plotting regular scatter
    
    mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'SEplot');
end

function View_binFaceColor_Callback(hObject, ~, handles) %% This button from the View menu
c = uisetcolor; % Open a dialog for selecting color
if isequal(c,0)
    return
end

% Update
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end
mainhandles.settings.SEplot.binFaceColor = c;
updatemainhandles(mainhandles)

% Update face colors
% E bar plots
children = findobj(handles.Ehist,'-property','FaceVertexCData');
if isempty(children)
    return
end
for i = 1:length(children)
    set(children(i),'FaceColor',c);
end

% S bar plots
children = findobj(handles.Shist,'-property','FaceVertexCData');
if isempty(children)
    return
end
for i = 1:length(children)
    set(children(i),'FaceColor',c);
end

function View_ExcludeBlinking_Callback(hObject, eventdata, handles)
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Update handles structure
if mainhandles.settings.SEplot.excludeBlinking==0
    mainhandles.settings.SEplot.excludeBlinking = 1;
elseif mainhandles.settings.SEplot.excludeBlinking==1
    mainhandles.settings.SEplot.excludeBlinking = 0;
end
updatemainhandles(mainhandles)
updateHistwindowGUImenus(mainhandles,handles)

% Update plot
blinkingPairs = getPairs(handles.main,'Blink');
plottedPairs = getPairs(handles.main,'Plotted',[],mainhandles.FRETpairwindowHandle,handles.figure1);
if ismember(1,ismember(plottedPairs,blinkingPairs,'rows','legacy'))
    handles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1);
end

function View_PlotInverseS_Callback(hObject, ~, handles) %% Make inverse plot
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Update handles structure
if mainhandles.settings.SEplot.inverseS==0
    mainhandles.settings.SEplot.inverseS = 1;
    set(handles.View_PlotInverseS,'Checked','on')
elseif mainhandles.settings.SEplot.inverseS==1
    mainhandles.settings.SEplot.inverseS = 0;
    set(handles.View_PlotInverseS,'Checked','off')
end
updatemainhandles(mainhandles)
handles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1);

function View_BinInfoType_Callback(hObject, ~, handles) %% Type of info showed in bin boxes
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

% Dialog
choice = mylistdlg('ListString',{'Total number of bins'; 'Bin size'},...
    'SelectionMode','Single',...
    'Name','Info type',...
    'InitialValue',mainhandles.settings.SEplot.showbinsType,...
    'ListSize', [160 80]);
if isempty(choice)
    return
end

% Update
mainhandles.settings.SEplot.showbinsType = choice;
updatemainhandles(mainhandles)

binonly = 1;
mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'Ehist',binonly);
mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'Shist',binonly);

function View_lockEbinsize_Callback(hObject, ~, handles) %% Lock the bin size in the E histogram
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Update handles structure
if isempty(mainhandles.settings.SEplot.lockEbinsize)
    
    % Current binsizes
    binsize = get(handles.EbinsizeSlider,'UserData');
    if isempty(binsize)
        binsize = 0.03; % Default size
    end
    
    % Lock at these sizes
    mainhandles.settings.SEplot.lockEbinsize = binsize;
    set(handles.View_lockEbinsize,'Checked','on')
    
else
    mainhandles.settings.SEplot.lockEbinsize = [];
    set(handles.View_lockEbinsize,'Checked','off')
end
updatemainhandles(mainhandles)

function View_lockSbinsize_Callback(hObject, ~, handles) %% Lock the bin size in the S histogram
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Update handles structure
if isempty(mainhandles.settings.SEplot.lockSbinsize)
    
    % Current binsizes
    binsize = get(handles.SbinsizeSlider,'UserData');
    if isempty(binsize)
        binsize = 0.03; % Default size
    end
    
    % Lock at these sizes
    mainhandles.settings.SEplot.lockSbinsize = binsize;
    set(handles.View_lockSbinsize,'Checked','on')
    
else
    mainhandles.settings.SEplot.lockSbinsize = [];
    set(handles.View_lockSbinsize,'Checked','off')
end
updatemainhandles(mainhandles)

function View_PairCorrelationPlot_Callback(hObject, ~, handles) %% Open pair correlation plot
% handles = turnoffFRETpairwindowtoggles(handles); % Turn of integration ROIs
mainhandles = getmainhandles(handles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% Pairs plotted
selectedPairs = getPairs(handles.main, 'Plotted', [], mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle);
if isempty(selectedPairs)
    return
end

% Plotted data points
traces = mainhandles.settings.SEplot.traces;
if isempty(traces) || ~isequal(size(selectedPairs,1),length(traces))
    return
end

cc = zeros(length(traces),3);
length(traces)
for i = 1:length(traces)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    xy = (mainhandles.data(file).FRETpairs(pair).Dxy+mainhandles.data(file).FRETpairs(pair).Axy)/2;
    cc(i,:) = [xy(:)' mean(traces(i).S)];
end

fh = figure;
updatelogo(fh)
plot3k(cc,'MarkerSize',15)

xlim([0 size(mainhandles.data(1).avgDimage,1)]);
ylim([0 size(mainhandles.data(1).avgDimage,2)]);

function SettingsMenu_Callback(hObject, eventdata, handles)

function Settings_PlotOptions_Callback(hObject, ~, handles) %% The options button from the view menu
mainhandles = getmainhandles(handles);
if mainhandles.settings.excitation.alex
    mainhandles = SEplotSettingsCallback(handles);
else
    mainhandles = EplotSettingsCallback(handles);
end

function Settings_Gaussian_Callback(hObject, eventdata, handles)
mainhandles = GaussianSettingsCallback(handles);

function Settings_Lasso_Callback(hObject, eventdata, handles)
mainhandles = SElassoSettingsCallback(handles);

function HelpMenu_Callback(hObject, ~, handles) %% The help menu

function Help_mfile_Callback(hObject, ~, handles) %% Open this m-file
edit histogramwindow.m

function Help_figfile_Callback(hObject, ~, handles) %% Open fig file in GUIDE
guide histogramwindow

function Help_updateplotfcn_Callback(hObject, eventdata, handles)
edit updateSEplot.m

% --------------------------------------------------------------------
% ----------------------------- Toolbar ------------------------------
% --------------------------------------------------------------------

function Toolbar_EditPlot_OnCallback(hObject, ~, handles) %% The edit plot toggle button on from the toolbar
plotedit('on')

function Toolbar_EditPlot_OffCallback(hObject, ~, handles) %% The edit plot toggle button off from the toolbar
plotedit('off')

function Toolbar_LassoSelectionPlot_ClickedCallback(hObject, ~, handles) %% Use lasso-selection to select points and the plot histogram of their origins
mainhandles = histLassoselectionCallback(handles);

function Toolbar_PlotType_ClickedCallback(hObject, ~, handles) %% The switch ES plot type in the toolbar
% Set new plot type in the mainhandles structure
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end
if mainhandles.settings.SEplot.SEplotType == 1
    mainhandles.settings.SEplot.SEplotType = 3; % scatplot
elseif mainhandles.settings.SEplot.SEplotType == 2
    mainhandles.settings.SEplot.SEplotType = 1; % smoothhist2D
elseif mainhandles.settings.SEplot.SEplotType == 3
    mainhandles.settings.SEplot.SEplotType = 2; % Regular single colored scatter plot
end
updatemainhandles(mainhandles)

% Update scatter plot
mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'SEplot',[],[],1);

function Toolbar_Colormap_ClickedCallback(hObject, ~, handles) %% The switch colormap button in the toolbar
% Set new colormap in the mainhandles structure
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

% Old colormap needed for updating density scatter plot
colmap_prev = eval( lower(mainhandles.settings.SEplot.colormap) );
if mainhandles.settings.SEplot.colorinversion
    colmap_prev = flipud(colmap_prev);
end

if mainhandles.settings.SEplot.SEplotType == 1 % If regular single-colored scatter
    
    mainhandles.settings.SEplot.colorOrder = circshift(mainhandles.settings.SEplot.colorOrder(:),[-1 0])';
    
else % If density colored-plot
    
    if strcmpi(mainhandles.settings.SEplot.colormap,'jet')
        mainhandles.settings.SEplot.colormap = 'hsv';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'hsv')
        mainhandles.settings.SEplot.colormap = 'hot';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'hot')
        mainhandles.settings.SEplot.colormap = 'cool';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'cool')
        mainhandles.settings.SEplot.colormap = 'spring';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'spring')
        mainhandles.settings.SEplot.colormap = 'summer';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'summer')
        mainhandles.settings.SEplot.colormap = 'autumn';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'autumn')
        mainhandles.settings.SEplot.colormap = 'winter';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'winter')
        mainhandles.settings.SEplot.colormap = 'gray';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'gray')
        mainhandles.settings.SEplot.colormap = 'bone';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'bone')
        mainhandles.settings.SEplot.colormap = 'copper';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'copper')
        mainhandles.settings.SEplot.colormap = 'pink';
    elseif strcmpi(mainhandles.settings.SEplot.colormap,'pink')
        mainhandles.settings.SEplot.colormap = 'jet';
    end
    
end

% Update
updatemainhandles(mainhandles)
if mainhandles.settings.SEplot.SEplotType == 3
    % If plotting image
    
    colmap_new = eval( lower(mainhandles.settings.SEplot.colormap) );
    if mainhandles.settings.SEplot.colorinversion
        colmap_new = flipud(colmap_new);
    end
    colormap(handles.SEplot,colmap_new)
    
elseif mainhandles.settings.SEplot.SEplotType == 2
    
    % Plotting scatter density plot - change colors one by one
    colmap_new = eval( lower(mainhandles.settings.SEplot.colormap) ); % new colmap
    if mainhandles.settings.SEplot.colorinversion
        colmap_new = flipud(colmap_new);
    end
    
    h = findobj(handles.SEplot,'type','line'); % Get all plotted points
    if isempty(h)
        return
    end
    
    % Change the color of each "line" plot, one by one
    for i=1:length(h)
        [~,idx] = ismember(get(h(i),'Color'),colmap_prev,'rows');
        if idx>0
            set(h(i),'Color',colmap_new(idx,:))
        end
    end
    
else % If plotting regular scatter
    
    mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'SEplot');
end

function Toolbar_InverseColors_ClickedCallback(hObject, ~, handles) %% Inverse colors
% Set new colormap in the mainhandles structure
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

% Old colormap needed for updating density scatter plot
colmap_prev = eval( lower(mainhandles.settings.SEplot.colormap) );
if mainhandles.settings.SEplot.colorinversion
    colmap_prev = flipud(colmap_prev);
end

% Update settings
if mainhandles.settings.SEplot.colorinversion
    mainhandles.settings.SEplot.colorinversion = 0;
else
    mainhandles.settings.SEplot.colorinversion = 1;
end

% Update
updatemainhandles(mainhandles)
if mainhandles.settings.SEplot.SEplotType == 3
    % If plotting image
    colmap_new = eval( lower(mainhandles.settings.SEplot.colormap) );
    if mainhandles.settings.SEplot.colorinversion
        colmap_new = flipud(colmap_new);
    end
    colormap(handles.SEplot,colmap_new)
    
elseif mainhandles.settings.SEplot.SEplotType == 2
    
    % Plotting scatter density plot - change colors one by one
    colmap_new = eval( lower(mainhandles.settings.SEplot.colormap) ); % new colmap
    if mainhandles.settings.SEplot.colorinversion
        colmap_new = flipud(colmap_new);
    end
    
    h = findobj(handles.SEplot,'type','line'); % Get all plotted points
    if isempty(h)
        return
    end
    
    % Change the color of each "line" plot, one by one
    for i=1:length(h)
        [~,idx] = ismember(get(h(i),'Color'),colmap_prev,'rows');
        if idx>0
            set(h(i),'Color',colmap_new(idx,:))
        end
    end
    
else % If plotting regular scatter
    
    mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'SEplot');
end

function Toolbar_plotFits_ClickedCallback(hObject, ~, handles) %% Pressing this button in the toolbar show/hides histogram fits
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

% Update settings structure
if mainhandles.settings.SEplot.plotEfit && mainhandles.settings.SEplot.plotSfit...
        && mainhandles.settings.SEplot.plotEfitTot && mainhandles.settings.SEplot.plotSfitTot
    mainhandles.settings.SEplot.plotEfit = 1;
    mainhandles.settings.SEplot.plotSfit = 0;
    mainhandles.settings.SEplot.plotEfitTot = 1;
    mainhandles.settings.SEplot.plotSfitTot = 0;
    
elseif mainhandles.settings.SEplot.plotEfit && ~mainhandles.settings.SEplot.plotSfit...
        && mainhandles.settings.SEplot.plotEfitTot && ~mainhandles.settings.SEplot.plotSfitTot
    mainhandles.settings.SEplot.plotEfit = 1;
    mainhandles.settings.SEplot.plotSfit = 0;
    mainhandles.settings.SEplot.plotEfitTot = 0;
    mainhandles.settings.SEplot.plotSfitTot = 0;
    
elseif mainhandles.settings.SEplot.plotEfit && ~mainhandles.settings.SEplot.plotSfit...
        && ~mainhandles.settings.SEplot.plotEfitTot && ~mainhandles.settings.SEplot.plotSfitTot
    mainhandles.settings.SEplot.plotEfit = 0;
    mainhandles.settings.SEplot.plotSfit = 0;
    mainhandles.settings.SEplot.plotEfitTot = 0;
    mainhandles.settings.SEplot.plotSfitTot = 0;
    
else
    % Turn on all
    mainhandles.settings.SEplot.plotEfit = 1;
    mainhandles.settings.SEplot.plotSfit = 1;
    mainhandles.settings.SEplot.plotEfitTot = 1;
    mainhandles.settings.SEplot.plotSfitTot = 1;
end

% Update
updatemainhandles(mainhandles)
updateEhistGauss(handles.main,handles.figure1)
updateShistGauss(handles.main,handles.figure1)

function Toolbar_fit1DgaussE_ClickedCallback(hObject, eventdata, handles)
mainhandles = fit1DgaussHistCallback(handles,0,'E');

function Toolbar_predict1DgaussE_ClickedCallback(hObject, eventdata, handles)
mainhandles = fit1DgaussHistCallback(handles,1,'E');

function Toolbar_fit2Dgauss_ClickedCallback(hObject, ~, handles) %% Fits Gaussian mixture distribution to SE scatter plot
mainhandles = fit2DgaussSEcallback(handles,0);

function Toolbar_predict2Dgauss_ClickedCallback(hObject, ~, handles) %% This button in toolbar predicts the number of Gaussian components in the SEplot
mainhandles = fit2DgaussSEcallback(handles,1);

function Toolbar_fit1DgaussS_ClickedCallback(hObject, eventdata, handles)
mainhandles = fit1DgaussHistCallback(handles,0,'S');

function Toolbar_predict1DgaussS_ClickedCallback(hObject, eventdata, handles)
mainhandles = fit1DgaussHistCallback(handles,1,'S');

function Toolbar_GaussianComponentsWindow_OnCallback(hObject, ~, handles) %% Opens the external Gaussian components window with Gaussian data tables
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

% Open Gaussian components window and update its tables
setappdata(0,'histogramwindowHandle',handles.figure1)
setappdata(0,'mainhandle',handles.main)
mainhandles.GaussianComponentsWindowHandle = GaussianComponentsWindow;
updatemainhandles(mainhandles)
updateGaussianComponentsWindow(handles.main,handles.figure1,mainhandles.GaussianComponentsWindowHandle)

function Toolbar_GaussianComponentsWindow_OffCallback(hObject, ~, handles) %% Closes the Gaussian components window
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end
try
    delete(mainhandles.GaussianComponentsWindowHandle)
end

function Toolbar_PlotEhist_ClickedCallback(hObject, ~, handles) %% Plot a E-histogram of a data range subset
plotEhistCallback(handles)

% --------------------------------------------------------------------
% ------------------------------- Misc -------------------------------
% --------------------------------------------------------------------

function PostZooming(SEplot) %% Runs after zooming on SEplot axes: sets xlim(Shist) and updates histograms
handles = getappdata(0,'histogramwindowHandles'); % Get handles structure

% Set Shist xlim
ylimSE = get(SEplot,'ylim');
xlim(handles.Shist,ylimSE)

% Update histograms
mainhandles = guidata(handles.main);
mainhandles = updateSEplot(handles.main, mainhandles.FRETpairwindowHandle, handles.figure1,'Ehist');
mainhandles = updateSEplot(handles.main, mainhandles.FRETpairwindowHandle, handles.figure1,'Shist');

function CursorText = DataCursorCallback(~,event_obj) %% Callback for data cursor. The ~ is for an object that is not used. event_obj = handle to event object
% Get data cursor position
pos = get(event_obj,'Position');
x = pos(1);
y = pos(2);

% Start output message
CursorText = {['x: ',num2str(x,4) ...
    ';  y: ',num2str(y,4)]};

% Get handles structures
mainhandles = guidata(getappdata(0,'mainhandle'));
FRETpairwindowHandles = guidata(mainhandles.FRETpairwindowHandle);
histogramwindowHandles = guidata(mainhandles.histogramwindowHandle);

% Identify file, FRET-pair and frame of selected point
frame = [];
if get(histogramwindowHandles.plotSelectedPairRadiobutton,'Value') % If selected FRET-pairs are plotted, find the frame among the selected
    selectedPairs = getPairs(mainhandles.figure1, 'Selected', [], mainhandles.FRETpairwindowHandle); % Returns pair selection as [file pair;...]
elseif get(histogramwindowHandles.plotSelectedGroupRadiobutton,'Value') % If a group is plotted, find the filename, FRET-pair and frame
    selectedPairs = getPairs(mainhandles.figure1, 'Group', [], mainhandles.FRETpairwindowHandle);%getgroupmembers(mainhandles.figure1); % Returns group members of selected group as [file pair;...]
elseif get(histogramwindowHandles.plotAllPairsRadiobutton,'Value') % If a all FRET-pairs are plotted, find the filename, FRET-pair and frame
    selectedPairs = getPairs(mainhandles.figure1, 'All');
end

if isempty(selectedPairs)
    return
end

% Identify selected point
for i = 1:size(selectedPairs,1)
    filechoice = selectedPairs(i,1);
    pairchoice = selectedPairs(i,2);
    Etrace = mainhandles.data(filechoice).FRETpairs(pairchoice).Etrace(:);
    StraceCorr = mainhandles.data(filechoice).FRETpairs(pairchoice).StraceCorr(:);
    SEtrace = [Etrace  StraceCorr];
    
    frame = find(ismember(SEtrace,[x y],'rows','legacy'));
    if ~isempty(frame)
        filename = mainhandles.data(filechoice).name;
        break
    end
end

% Continue output message
if ~isempty(frame)
    CursorText{end+1} = ['File: ' filename];
    CursorText{end+1} = ['FRET-pair: ' num2str(pairchoice) ...
        '; Frame: ' num2str(frame)];
else
    CursorText{end+1} = 'Could not determine point origin';
end

% --------------------------------------------------------------------
% ------------------------------ Objects -----------------------------
% --------------------------------------------------------------------

function FilesListbox_Callback(hObject, ~, handles) %% Files listbox selection
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end
mainhandles.settings.SEplot.plotEfit = 0;
mainhandles.settings.SEplot.plotEfitTot = 0;
mainhandles.settings.SEplot.plotSfit = 0;
mainhandles.settings.SEplot.plotSfitTot = 0;
mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,mainhandles.histogramwindowHandle,'all');
function FilesListbox_CreateFcn(hObject, ~, handles) %% Runs when the files lisbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function plotchoicePanel_SelectionChangeFcn(hObject, eventdata, handles) %% The choice of plot selection panel (single vs. all pairs)
mainhandles = SEplotchoiceCallback(handles.figure1);

function SbinsizeSlider_Callback(hObject, ~, handles) %% The S-histogram bin size slider updates the S-histogram axes only
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

% Unlock temporarily if bin size is locked
ok = 0;
if length(mainhandles.settings.SEplot.lockSbinsize)==1
    mainhandles.settings.SEplot.lockSbinsize = [];
    updatemainhandles(mainhandles)
    ok = 1;
end

% Update histogram plot
binonly = 1;
mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'Shist',binonly);
if ok
    mainhandles.settings.SEplot.lockSbinsize = get(handles.SbinsizeSlider,'UserData');
    updatemainhandles(mainhandles)
end
function SbinsizeSlider_CreateFcn(hObject, ~, handles) %% Runs when the S-histogram bin size slider is created
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function EbinsizeSlider_Callback(hObject, ~, handles) %% The E-histogram bin size slider updates the E-histogram axes only
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

% Unlock temporarily if bin size is locked
ok = 0;
if length(mainhandles.settings.SEplot.lockEbinsize)==1
    mainhandles.settings.SEplot.lockEbinsize = [];
    updatemainhandles(mainhandles)
    ok = 1;
end

% Update histogram plot
binonly = 1;
mainhandles = updateSEplot(handles.main,mainhandles.FRETpairwindowHandle,handles.figure1,'Ehist',binonly);
if ok
    mainhandles.settings.SEplot.lockEbinsize = get(handles.EbinsizeSlider,'UserData');
    updatemainhandles(mainhandles)
end
function EbinsizeSlider_CreateFcn(hObject, ~, handles) %% Runs when E-histogram bin size slider is created
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function GaussiansSlider_Callback(hObject, ~, handles) %% Sets the number of Gaussian mixture components
value = get(handles.GaussiansSlider,'Value');
set(handles.GaussiansEditbox,'String',value)

% Update handles structure
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end

mainhandles.settings.SEplot.nGaussians = value;
updatemainhandles(mainhandles)

if ~mainhandles.settings.SEplot.plotEfit && ~mainhandles.settings.SEplot.plotEfitTot...
        && ~mainhandles.settings.SEplot.plotSfit && ~mainhandles.settings.SEplot.plotEfitTot
    return
end
function GaussiansSlider_CreateFcn(hObject, ~, handles) %% Runs when the GaussianSlider is created
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function GaussiansEditbox_Callback(hObject, ~, handles) %% Set the number of Gaussian mixture components
value = round(str2num(get(handles.GaussiansEditbox,'String')));
if value < 1
    mymsgbox('You must choose an integer in between 1 and 11');
    value = 1;
elseif value > 11
    mymsgbox('You must choose an integer in between 1 and 11');
    value = 11;
end
set(handles.GaussiansEditbox,'String',value)
set(handles.GaussiansSlider,'Value',value)

% Update handles structure
mainhandles = getmainhandles(handles); % Get handles structure of main window
if isempty(mainhandles)
    return
end
mainhandles.settings.SEplot.nGaussians = value;
updatemainhandles(mainhandles)
function GaussiansEditbox_CreateFcn(hObject, ~, handles) %% Runs when the GaussianEditbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function plotAllExceptPopupMenu_Callback(hObject, eventdata, handles)
mainhandles = getmainhandles(handles);
mainhandles.settings.SEplot.exceptchoice = get(handles.plotAllExceptPopupMenu,'Value');
updatemainhandles(mainhandles)
mainhandles = updateSEplot(handles.main, mainhandles.FRETpairwindowHandle, handles.figure1, 'all');
if get(handles.plotAllExceptPopupMenu,'Value')==2
    set([handles.FilesListbox handles.MergeFilesTextbox],'Enable','on')
else
    set([handles.FilesListbox handles.MergeFilesTextbox],'Enable','off')
end
function plotAllExceptPopupMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FitPushbutton_Callback(hObject, eventdata, handles)
mainhandles = fit1DgaussHistCallback(handles,0,'E');
