function varargout = profileWindow2(varargin) %% Initializes the GUI
% PROFILEWINDOW2 - GUI window associated with iSMS for analysing laser
% profiles
%
%  profileWindow2.m cannot be by called by itself as it relies on handles
%  sent by the sms.m main figure window upon opening.
%
%  The profileWindow2 GUI is programmed using GUIDE. The callbacks of
%  the GUI is found in the profileWindow2.m file and is divided into
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

% Last Modified by GUIDE v2.5 20-May-2014 12:51:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @profileWindow2_OpeningFcn, ...
    'gui_OutputFcn',  @profileWindow2_OutputFcn, ...
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

function profileWindow2_OpeningFcn(hObject, eventdata, handles, varargin) %% Executes just before Profile Editor is made visible
% Set position, title and logo. Turn off visibility.
initGUI(handles.figure1, 'Laser-spot profile window', 'center');

% Handle to main figure window
handles.main = getappdata(0,'mainhandle');
mainhandles = guidata(handles.main);

% Settings
handles.settings.smooth.factor = 15;
handles.settings.fit.image = 'global'; % 1 if fitting is on ROI image, 2 if on global image
handles.settings.fit.MaxFunEvals = 700;
handles.settings.fit.MaxIter = 400;
handles.settings.fit.TolFun = 1e-6;
handles.settings.fit.TolX = 1e-6;
handles.settings.sides.green = 'left';

% Initialize profiles
handles.green = storeSpot();
handles.red = storeSpot();
handles.green(:) = [];
handles.red(:) = [];
% idx = [];
% for i = 1:length(mainhandles.data)
%     if mainhandles.data(i).spot
%         idx = [idx i];
%     end
% end
% if ~isempty(idx)
%     runbar = 0;
%     hWaitbar = mywaitbar(runbar,'Fitting Gaussians...','name','iSMS')
%     for i = idx
%         if mainhandles.data(i).spot==1
%             handles.green(end+1).name = mainhandles.data(i).name;
%             handles.green(end).image = mainhandles.data(i).avgimage;
%             handles.green(end).raw = mainhandles.data(i).avgimage;
%             handles.green(end).ROI = mainhandles.data(i).Droi;
%             handles.green(end).pars = fit2Dgauss(handles, handles.green(end).image,handles.green(end).ROI, 1,0); % Parameters of a fitted 2D gauss function
%             handles.green(end).existing = 1;
%             handles.green(end).measured = mainhandles.data(i).spotMeasured;
%         elseif mainhandles.data(i).spot==2
%             handles.red(end+1).name = mainhandles.data(i).name;
%             handles.red(end).image = mainhandles.data(i).avgimage;
%             handles.red(end).raw = mainhandles.data(i).avgimage;
%             handles.red(end).ROI = mainhandles.data(i).Aroi;
%             handles.red(end).pars = fit2Dgauss(handles, handles.red(end).image,handles.red(end).ROI, 2,0); % Parameters of a fitted 2D Gauss
%             handles.red(end).existing = 1;
%             handles.red(end).measured = mainhandles.data(i).spotMeasured;
%         end
%         runbar = runbar+1;
%         waitbar(runbar/length(idx))
%     end
%     try delete(hWaitbar),end
% end

% Turn off some things if its a deployed version
turnoffDeployed(mainhandles,[],[],[],[], handles.figure1);

% Axes
xlabel(handles.rawimage,'x /pixel')
ylabel(handles.rawimage,'y /pixel')
xlabel(handles.ROIimage,'x /pixel')
ylabel(handles.ROIimage,'y /pixel')
set([handles.rawimage handles.ROIimage], 'XTickLabel','', 'YTickLabel', '')
box(handles.rawimage,'on')
box(handles.ROIimage,'on')

% Update GUI
updateprofilesListbox(handles)
updatepartable(handles)
updateimages(handles)

% Choose default command line output for profileWindow2
handles.output = hObject; % Return handle to GUI window

% Update handles structure
guidata(hObject, handles);

% Set some GUI settings
setGUIappearance(handles.figure1)

function varargout = profileWindow2_OutputFcn(hObject, ~, handles) %% Outputs from this function are returned to the command line
% Show GUI
set(handles.figure1,'Visible','on')

varargout{1} = handles.output;

function figure1_CloseRequestFcn(hObject, ~, handles) %% Runs when the GUI (i.e. handles.figure1) is closed
% Turn off toggle button in main window
% try
try mainhandles = getmainhandles(handles);    
    set(mainhandles.Toolbar_profileWindow,'State','off')
end

% Aims to delete all data and handles used by the program before closing
try cla(handles.rawimage)
    cla(handles.ROIimage)
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

function FileMenu_Callback(hObject, ~, handles) %% The File menu

function File_LoadGreen_Callback(hObject, ~, handles) %% The load green profile from the File menu
loadmovie(handles,1)

function File_LoadRed_Callback(hObject, ~, handles) %% The load red profile from the File menu
loadmovie(handles,2)

function File_ImportGreenFRETmovie_Callback(hObject, ~, handles) %% Import the avg. of all green excitation frames
spot = 1;
importFRETmovie(handles,spot)

function File_ImportRedFRETmovie_Callback(hObject, ~, handles) %% Import avg. of all red excitation frames
spot = 2;
importFRETmovie(handles,spot)

function File_TimeDependentG_Callback(hObject, ~, handles) %% Fit profile time-dependently
return
mainhandles = getmainhandles(handles);
if isempty(mainhandles.data)
    mymsgbox('There are no data files loaded into the main iSMS window.');
    return
end
filechoice = get(mainhandles.FilesListbox,'Value');

% Steps
avgFrames = mainhandles.settings.peakfinder.avgFrames;
stepsize = mainhandles.settings.peakfinder.stepsize;
scanperc = mainhandles.settings.peakfinder.scanperc;
Dframes = find(mainhandles.data(filechoice).excorder=='D'); % Indices of all donor exc frames
interval = Dframes(1:ceil(end*scanperc));
steps = floor(length(interval)/(avgFrames+stepsize)); % #steps

idx1 = 1;
mainhandles.data(end+1) = mainhandles.data(filechoice);
mainhandles.data(end).imageData = zeros(size(mainhandles.data(filechoice).imageData,1),size(mainhandles.data(filechoice).imageData,2),size(mainhandles.data(filechoice).imageData,3)/2);
myprogressbar('Fitting Gaussian profiles')
for i = 1:steps
    % Get image of step i
    idx2 = idx1+avgFrames-1;
    image = single( mean(mainhandles.data(filechoice).imageData(:,:,interval(idx1:idx2)),3) ); % Avg. image
    
    % Fit
    pars = fit2Dgauss(handles, image, [], 1) % Parameters of a fitted 2D gauss function
    %     pars(1) = 1/(2*pi*pars(3)*pars(5)); % normalize area
    %     pars(7) = 0;
    
    % Make Gaussian global image
    fit = make2Dgauss([size(image,1) size(image,2)], pars);
    
    for j = idx1:idx2
        mainhandles.data(end).imageData(:,:,j) = fit;
    end
    idx1 = idx2+stepsize;
    progressbar(i/steps)
end

updatemainhandles(mainhandles)
updatefileslist(handles.main,mainhandles.histogramwindowHandle)
mainhandles = updateavgimages(mainhandles,'all',length(mainhandles.data));

function File_ExportFigure_Callback(hObject, ~, handles) %% Export figures
% Open a dialog for specifying export properties
settings = export_fig_dlg;
if isempty(settings)
    return
end

% Handles of objects to hide when exporting figure
h = [handles.GlobalImageTextbox...
    handles.ROIimageTextbox...
    handles.editorPanel...
    handles.greenTextbox...
    handles.redTextbox...
    handles.greenListbox...
    handles.redListbox...
    handles.SelectionPanel...
    handles.greenRadiobutton...
    handles.redRadiobutton...
    handles.partableTextbox...
    handles.parTable...
    handles.SmoothPushbutton...
    handles.fitGaussianPushbutton...
    handles.makeGaussianPushbutton...
    handles.CancelPushbutton...
    handles.ExportPushbutton];

% Turn on waitbar
hWaitbar = mywaitbar(1,'Exporting figure...','name','iSMS');
movegui(hWaitbar,'north')

% Turn GUI into white empty background
panel1string = get(handles.editorPanel,'Title');
panel2string = get(handles.SelectionPanel,'Title');
set(handles.editorPanel,'Title','') % The panel titles are not hidden by just setting panel visibility to off
set(handles.SelectionPanel,'Title','')
set(h,'Visible','off') % Turn of GUI object visibilities
set(handles.figure1,'Color','white') % Set GUI background to white

% Export figure
try
    figure(handles.figure1)
    eval(settings.command) % This will run export_fig with settings specified in export_fig_dlg
    
catch err
    err
    Error = err.message
    
    % Turn GUI back to original
    set(h,'Visible','on')
    set(handles.figure1,'Color', [0.94118  0.94118  0.94118])
    set(handles.editorPanel,'Title',panel1string)
    set(handles.SelectionPanel,'Title',panel2string)
    
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
set(handles.editorPanel,'Title',panel1string)
set(handles.SelectionPanel,'Title',panel2string)

% Delete waitbar
try delete(hWaitbar), end

function EditMenu_Callback(hObject, ~, handles) %% The Edit menu

function Edit_Reset_Callback(hObject, ~, handles) %% The Reset profile button from the Edit menu
if isempty(handles.green) && isempty(handles.red)
    return
end
if get(handles.greenRadiobutton,'Value')
    choice = get(handles.greenListbox,'Value');
    handles.green(choice).image = handles.green(choice).raw;
else
    choice = get(handles.redListbox,'Value');
    handles.red(choice).image = handles.red(choice).raw;
end
guidata(handles.figure1,handles)
updateimages(handles)
updatepartable(handles)

function Edit_Delete_Callback(hObject, ~, handles) %% The Delete profile button from the Edit menu
if isempty(handles.green) && isempty(handles.red)
    return
end

if get(handles.greenRadiobutton,'Value')
    choice = get(handles.greenListbox,'Value');
    handles.green(choice) = [];
else
    choice = get(handles.redListbox,'Value');
    handles.red(choice) = [];
end
guidata(handles.figure1,handles)

% Update
guidata(handles.figure1,handles)
updateprofilesListbox(handles)
updateimages(handles)
updatepartable(handles)

function SettingsMenu_Callback(hObject, ~, handles) %% The Settings menu

function Settings_Fit_Callback(hObject, ~, handles) %% Fit settings dialog
%--------------------- Prepare dialog box --------------------%
% Prompt & name
prompt = {'Fit Gaussian to:' 'image';...
    'Maximum number of function evaluations allowed (MaxFunEvals):' 'MaxFunEvals';...
    'Maximum number of iterations allowed (MaxIter):' 'MaxIter';...
    'Termination tolerance on the function value (TolFun):' 'TolFun';...
    'Termination tolerance on x:' 'TolX'};
name = 'Fit settings';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

formats(2,1).type = 'list';
formats(2,1).style = 'radiobutton';
formats(2,1).items = {'ROI image' 'Global image'};
formats(4,1).type = 'edit';
formats(4,1).size = 50;
formats(4,1).format = 'integer';
formats(5,1).type = 'edit';
formats(5,1).size = 50;
formats(5,1).format = 'integer';
formats(6,1).type = 'edit';
formats(6,1).size = 50;
formats(6,1).format = 'float';
formats(7,1).type = 'edit';
formats(7,1).size = 50;
formats(7,1).format = 'float';

% Default answer
if strcmpi(handles.settings.fit.image,'ROI')
    DefAns.image = 1;
else
    DefAns.image = 2;
end
DefAns.MaxFunEvals = handles.settings.fit.MaxFunEvals;
DefAns.MaxIter = handles.settings.fit.MaxIter;
DefAns.TolFun = handles.settings.fit.TolFun;
DefAns.TolX = handles.settings.fit.TolX;

% Options
options.CancelButton = 'on';

%------------------------- Open dialog box ----------------------%
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1)
    return
end

% Interpret answer and update handles structure
if answer.image==1
    handles.settings.fit.image = 'ROI';
else
    handles.settings.fit.image = 'global';
end
if answer.MaxFunEvals<1
    handles.settings.fit.MaxFunEvals = 1;
else
    handles.settings.fit.MaxFunEvals = answer.MaxFunEvals;
end
if answer.MaxIter<1
    handles.settings.fit.MaxIter = 1;
else
    handles.settings.fit.MaxIter = answer.MaxIter;
end
if answer.TolFun<0
    handles.settings.fit.TolFun = 1e-6;
else
    handles.settings.fit.TolFun = answer.TolFun;
end
if answer.TolX<0
    handles.settings.fit.TolX = 1e-6;
else
    handles.settings.fit.TolX = answer.TolX;
end
guidata(handles.figure1,handles)

function Settings_Smooth_Callback(hObject, ~, handles) %% The Smooth settings from the Settings menu
%--------------------- Prepare dialog box --------------------%
% Prompt & name
prompt = {'Smooth uses a mean filter based on neighbouring pixels.' '';...
    'Kernel size (pixels):' 'Ksize'};
name = 'Smooth settings';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

formats(2,1).type = 'text';
formats(4,1).type = 'edit';
formats(4,1).size = 50;
formats(4,1).format = 'integer';

DefAns.Ksize = handles.settings.smooth.factor;
options.CancelButton = 'on';

%------------------------- Open dialog box ----------------------%
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1)
    return
end
if answer.Ksize<3
    handles.settings.smooth.factor = 3;
else
    handles.settings.smooth.factor = answer.Ksize;
end
guidata(handles.figure1,handles)

function Settings_DefineRegions_Callback(hObject, ~, handles) %% Define the green and red regions on image
%--------------------- Prepare dialog box --------------------%
% Prompt & name
prompt = {'Side of green channel in global image:' 'side';...
    '(red is defined as the opposite)' ''};
name = 'Define image';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

formats(2,1).type = 'list';
formats(2,1).style = 'radiobutton';
formats(2,1).items = {'Left' 'Right' 'Bottom' 'Top'};
formats(3,1).type = 'text';

if strcmpi(handles.settings.sides.green,'left')
    DefAns.side = 1;
elseif strcmpi(handles.settings.sides.green,'right')
    DefAns.side = 2;
elseif strcmpi(handles.settings.sides.green,'bottom')
    DefAns.side = 3;
elseif strcmpi(handles.settings.sides.green,'top')
    DefAns.side = 4;
end
options.CancelButton = 'on';

%------------------------- Open dialog box ----------------------%
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1)
    return
end
if answer.side==1
    handles.settings.sides.green = 'left';
elseif answer.side==2
    handles.settings.sides.green = 'right';
elseif answer.side==3
    handles.settings.sides.green = 'bottom';
elseif answer.side==4
    handles.settings.sides.green = 'top';
end
guidata(handles.figure1,handles)

function ToolsMenu_Callback(hObject, ~, handles) %% The tools menu

function Tools_RemovePeaks_Callback(hObject, ~, handles) %% Remove peaks from image
if isempty(handles.green) && (isempty(handles.red))
    return
end
mainhandles = getmainhandles(handles);
greenchoice = get(handles.greenListbox,'Value');
redchoice = get(handles.redListbox,'Value');

% Turn on waitbar
hWaitbar = mywaitbar(1,'Removing peaks...','name','iSMS');
setFigOnTop % Sets the waitbar so that it is always in front

%--- Image to analyse ---%
if get(handles.greenRadiobutton,'Value') && ~isempty(handles.green)
    image = handles.green(greenchoice).image;
    roi = round(handles.green(greenchoice).ROI);
    spot = 1;
elseif get(handles.redRadiobutton,'Value') && ~isempty(handles.red)
    image = handles.red(redchoice).image;
    roi = round(handles.red(redchoice).ROI);
    spot = 2;
else
    return
end

% Make ROI of entire channel side, if fitting to global image
if strcmpi(handles.settings.fit.image,'global')
    if (spot==1 && strcmpi(handles.settings.sides.green,'left')) || (spot==2 && strcmpi(handles.settings.sides.green,'right'))
        roi = [1 1 floor(size(image,1)/2) size(image,2)];
    elseif (spot==1 && strcmpi(handles.settings.sides.green,'right')) || (spot==2 && strcmpi(handles.settings.sides.green,'left'))
        roi = [ceil(size(image,1)/2) 1 floor(size(image,1)/2) size(image,2)];
    elseif (spot==1 && strcmpi(handles.settings.sides.green,'bottom')) || (spot==2 && strcmpi(handles.settings.sides.green,'top'))
        roi = [1 1 size(image,1) floor(size(image,2)/2)];
    elseif (spot==1 && strcmpi(handles.settings.sides.green,'top')) || (spot==2 && strcmpi(handles.settings.sides.green,'bottom'))
        roi = [1 ceil(size(image,2)/2) size(image,1) floor(size(image,2)/2)];
    end
end

% Cut ROI image
x = roi(1):(roi(1)+roi(3))-1;
y = roi(2):(roi(2)+roi(4))-1;
ROIimage = single(image(x,y));

%------ First find and remove all peaks ------%
width = 9;%mainhandles.settings.integration.wh(1);
height = 9;%mainhandles.settings.integration.wh(2);
backwidth = 2;%mainhandles.settings.background.backwidth;
backspace = 2;%mainhandles.settings.background.backspace;

% Find all peaks and sort them in order of brightness
threshold = 0.9; % Threshold for peakfinder is the mean of the x% least-bright pixels
temp = sort(ROIimage(:)); % Image pixels sorted according to brightness
threshold = mean(temp(1:round(end*threshold)));
peaks = FastPeakFind(ROIimage,threshold); % Peaks in [x; y; x; y]
peaks = [peaks(1:2:end-1) peaks(2:2:end)]; % Peaks in [x y; x y]
idx = sub2ind(size(ROIimage), peaks(:,1), peaks(:,2)); % Convert to linear indexing in order to evaluate Dint
Dint = ROIimage(idx); % Brightness of peak pixels
temp = sortrows([Dint peaks]); % Sort in ascending order
peaks = flipud(temp(:,2:3)); % Flip to descending order
%
%     % Threshold of peak fitting
%     Dslider = get(handles.DPeakSlider,'Value'); % Chosen threshold
%     Dpeaks = Dpeaks(1:round(end*Dslider),:);

%     handles.data(filechoice).Dpeaks = Dpeaks;

%     handles = updatepeakglobal(handles,'donor'); % Also updates handles structure

for i = 1:size(peaks,1)
    % Get masks for integration and background regions of peak i
    x0 = peaks(i,1);
    y0 = peaks(i,2);
    [intMask, backMask] = getMask(size(ROIimage), x0,y0,width,height, 'both',backwidth,backspace);
    
    % Convert to linear indices
    idxInt = find(intMask);
    idxBack = find(backMask);
    
    % Set pixel values within integration region equal to avg. of
    % background pixels
    back = mean(ROIimage(idxBack));
    ROIimage(idxInt) = back;
end

% Insert new ROI image into global image:
image(x,y) = ROIimage;

%---- Store result ----%
if spot==1
    handles.green(end+1).name = sprintf('Peaks removed: %s',handles.green(greenchoice).name);
    handles.green(end).image = image;
    handles.green(end).raw = image;
    handles.green(end).pars = handles.green(greenchoice).pars;
    handles.green(end).ROI = handles.green(greenchoice).ROI;
    handles.green(end).existing = handles.green(greenchoice).existing;
    handles.green(end).measured = handles.green(greenchoice).measured;
    
    updateprofilesListbox(handles)
    set(handles.greenListbox,'Value',length(handles.green))
elseif spot==2
    handles.red(end+1).name = sprintf('Peaks removed: %s',handles.red(redchoice).name);
    handles.red(end).image = image;
    handles.red(end).raw = image;
    handles.red(end).pars = handles.red(redchoice).pars;
    handles.red(end).ROI = handles.red(redchoice).ROI;
    handles.red(end).existing = handles.red(redchoice).existing;
    handles.red(end).measured = handles.red(redchoice).measured;
    
    updateprofilesListbox(handles)
    set(handles.redListbox,'Value',length(handles.red))
end

% Update
guidata(handles.figure1,handles)
updateimages(handles)
updatepartable(handles)

% Delete waitbar
try delete(hWaitbar), end

function HelpMenu_Callback(hObject, ~, handles) %% Help menu

function Help_mfile_Callback(hObject, ~, handles) %% Open this mfile
edit profileWindow2.m

function Help_figfile_Callback(hObject, ~, handles) %% Open fig file in GUIDE
guide profileWindow2

% --------------------------------------------------------------------
% ----------------------------- Toolbar ------------------------------
% --------------------------------------------------------------------

function Toolbar_DeleteSelected_ClickedCallback(hObject, ~, handles) %% Delete selected spot profile button
Edit_Delete_Callback(handles.Edit_Delete, [], handles)

function Toolbar_GaussCenter_ClickedCallback(hObject, ~, handles) %% Allows the user to select the Gaussian center using ginput
if isempty(handles.green) && isempty(handles.red)
    return
end
[x,y,button,ax] = ginputc(1); % User input

% If user didn't press left mouse button, return
if button~=1
    return
end

% Make change
if get(handles.greenRadiobutton,'Value') && ~isempty(handles.green)
    choice = get(handles.greenListbox,'Value');
    
    % Gaussian parameters including new center
    pars = handles.green(choice).pars;
    if isequal(ax,handles.ROIimage)
        x = x+handles.green(choice).ROI(1);
        y = y+handles.green(choice).ROI(2);
    elseif isequal(ax,handles.rawimage)
        x = x;
        y = y;
    else % If selection was made outside axes
        return
    end
    pars(2) = x; % New x0
    pars(4) = y; % New y0
    
    % Make a new Gaussian with specified parameters
    imsize = size(handles.green(choice).image);
    gauss = make2Dgauss(imsize, pars);
    
    % If it's a measured profile, make a new pure Gaussian
    if handles.green(choice).measured
        handles.green(end+1).name = sprintf('Gaussian Fit: %s',handles.green(choice).name);
        handles.green(end).image = gauss;
        handles.green(end).raw = gauss;
        handles.green(end).pars = pars;
        handles.green(end).ROI = handles.green(choice).ROI;
        handles.green(end).existing = 0;
        handles.green(end).measured = 0;
        
        updateprofilesListbox(handles)
        set(handles.greenListbox,'Value',length(handles.green))
    else
        handles.green(choice).pars = pars;
        handles.green(choice).image = gauss;
    end
    
elseif get(handles.redRadiobutton,'Value') && ~isempty(handles.red)
    choice = get(handles.redListbox,'Value');
    
    % Gaussian parameters including new center
    pars = handles.red(choice).pars;
    if isequal(ax,handles.ROIimage)
        x = x+handles.red(choice).ROI(1);
        y = y+handles.red(choice).ROI(2);
    elseif isequal(ax,handles.rawimage)
        x = x;
        y = y;
    else % If selection was made outside axes
        return
    end
    pars(2) = x; % New x0
    pars(4) = y; % New y0
    
    % Make a new Gaussian with specified parameters
    imsize = size(handles.red(choice).image);
    gauss = make2Dgauss(imsize, pars);
    
    % If it's a measured profile, make a new pure Gaussian
    if handles.red(choice).measured
        handles.red(end+1).name = sprintf('Gaussian Fit: %s',handles.red(choice).name);
        handles.red(end).image = gauss;
        handles.red(end).raw = gauss;
        handles.red(end).pars = pars;
        handles.red(end).ROI = handles.red(choice).ROI;
        handles.red(end).existing = 0;
        handles.red(end).measured = 0;
        
        updateprofilesListbox(handles)
        set(handles.redListbox,'Value',length(handles.red))
    else
        handles.red(choice).pars = pars;
        handles.red(choice).image = gauss;
    end
end

% Update GUI
guidata(handles.figure1,handles)
updateimages(handles)
updatepartable(handles)

% --------------------------------------------------------------------
% ------------------------------- Misc -------------------------------
% --------------------------------------------------------------------

% function updateprofilesListbox(handles) %% Updates the listbox strings
% % Check if there are any green profiles
% if isempty(handles.green)
%     set(handles.greenListbox,'String','')
% else
%     % Set listbox strings
%     set(handles.greenListbox,'String',{handles.green(:).name})
% end
% % Check if there are any red profiles
% if isempty(handles.red)
%     set(handles.redListbox,'String','')
% else
%     set(handles.redListbox,'String',{handles.red(:).name})
% end
%
% % Check listbox value
% if (isempty(get(handles.greenListbox,'Value'))) || (isempty(handles.green))
%     set(handles.greenListbox,'Value',1)
% elseif (get(handles.greenListbox,'Value')>length(handles.green))
%     set(handles.greenListbox,'Value',length(handles.green))
% end
% if (isempty(get(handles.redListbox,'Value'))) || (isempty(handles.red))
%     set(handles.redListbox,'Value',1)
% elseif (get(handles.redListbox,'Value')>length(handles.red))
%     set(handles.redListbox,'Value',length(handles.red))
% end

function updatepartable(handles) %% Updates parameter values of the table
greenchoice = get(handles.greenListbox,'Value');
redchoice = get(handles.redListbox,'Value');

% Set partable data
partable = zeros(2,7);
if ~isempty(handles.green) && length(handles.green(greenchoice).pars)==7
    partable(1,:) = handles.green(greenchoice).pars;
end
if ~isempty(handles.red) && length(handles.red(redchoice).pars)==7
    partable(2,:) = handles.red(redchoice).pars;
end
set(handles.parTable,'Data',partable)

% function updateimages(handles) %% Updates spot profile images
% greenchoice = get(handles.greenListbox,'Value');
% redchoice = get(handles.redListbox,'Value');
% cla(handles.rawimage)
% cla(handles.ROIimage)
% 
% if isempty(handles.red) && isempty(handles.green)
%     return
% elseif isempty(handles.red)
%     set(handles.greenRadiobutton,'Value',1)
% elseif isempty(handles.green)
%     set(handles.redRadiobutton,'Value',1)
% end
% 
% %------- Update raw image ------%
% if get(handles.greenRadiobutton,'Value') && ~isempty(handles.green) % If selection is on green radiobutton
%     imagedata = handles.green(greenchoice).image;
%     roi = round(handles.green(greenchoice).ROI);
% elseif ~isempty(handles.red)% If selection is on red profile radiobutton
%     set(handles.redRadiobutton,'Value',1)
%     imagedata = handles.red(redchoice).image;
%     roi = round(handles.red(redchoice).ROI);
% end
% 
% % Plot raw image
% axes(handles.rawimage) % make rawimage current axis
% try imagesc(imagedata'.^0.1);
% catch err
%     imagesc(imagedata');
% end
% 
% % Plot ROI rectangle
% hold on
% rectangle('Position',roi,'Edgecolor','white','LineWidth',2)
% hold off
% 
% % Set axes properties
% caxis auto
% axis(handles.rawimage,'image')
% set(handles.rawimage,'YDir','normal')
% xlabel(handles.rawimage,'x /pixel')
% ylabel(handles.rawimage,'y /pixel')
% 
% %----- Update ROI image ------%
% % Cut D and A ROIs from avgimage
% x = roi(1):(roi(1)+roi(3))-1; % which unfurtunately is transposed compared to sif files.
% y = roi(2):(roi(2)+roi(4))-1;
% ROIimage = single(imagedata(x , y));
% 
% % Set contrast
% contrast = 1-get(handles.contrastSlider,'Value');
% ROIimage(ROIimage(:)-min(ROIimage(:))>(max(ROIimage(:))-min(ROIimage(:)))*contrast) = max(ROIimage(:))*contrast;
% 
% % Plot ROI image
% axes(handles.ROIimage) % make rawimage current axis
% try imagesc(ROIimage'.^0.1);
% catch err
%     imagesc(ROIimage');
% end
% 
% % Set axes properties
% caxis auto
% axis(handles.ROIimage,'image')
% set(handles.ROIimage,'YDir','normal')
% xlabel(handles.ROIimage,'x /pixel')
% ylabel(handles.ROIimage,'y /pixel')

function loadmovie(handles,spot) %% Loads a spot profile from file
mainhandles = getmainhandles(handles);

% Open a file selection dialog box
fileformats = supportedformatsImport();
if spot==1
    [filenames, dir, chose] = uigetfile3(mainhandles,'data',fileformats,'Load green profile','','on');
elseif spot==2
    [filenames, dir, chose] = uigetfile3(mainhandles,'data',fileformats,'Load red profile','','on');
end
if chose == 0 % If cancel button was pressed
    return
end

%---- Import data -----
if iscell(filenames) % If multiple files are selected
    nfiles = size(filenames,2);
else % If only one file is selected
    nfiles = 1;
    filenames = {filenames};
end

% Turn on waitbar
if nfiles==1
    hWaitbar = mywaitbar(0,'Loading movie. Please wait...','name','iSMS');
else
    hWaitbar = mywaitbar(0,'Loading movies. Please wait...','name','iSMS');
end
try setFigOnTop([]), end % Sets the waitbar so that it is always in front

for i = 1:nfiles
    filename = filenames{i};
    
    % Load data depending on filetype:
    if strcmpi(filename(end-2:end),'sif')
        temp = sifread(fullfile(dir,filename));
        data.imageData = temp.imageData;
        
    elseif strcmpi(filename(end-2:end),'spe')
        movObj = SpeReader(fullfile(dir,filename)); % User tag set to videofile
        temp = read(movObj); % Read in all video frames. 'Single' converts data type to class singles (saves memory compared to double)
        data.imageData = permute(temp,[2 1 4 3]); % Removes dimension 3 of data (only monochrome videos), and rotates by 90 degrees (only for spe files)
        
    elseif strcmpi(filename(end-3:end),'fits')
        data.imageData = fitsread(fullfile(dir,filename));
        
    else display('Data file type not currently supported')
        return
    end
    
    % If default setting is to rotate or flip the movie, do it now
    if mainhandles.settings.view.rotate % Rotate 90 deg.
        data.imageData = permute(data.imageData,[2 1 3]); % Raw images
    end
    if mainhandles.settings.view.flipud
        for j = 1:size(data.imageData,3)
            data.imageData(:,:,j) = fliplr(data.imageData(:,:,j)); % Raw images
        end
    end
    if mainhandles.settings.view.fliplr
        for j = 1:size(data.imageData,3)
            data.imageData(:,:,i) = flipud(data.imageData(:,:,j)); % Raw images
        end
    end
    
    % Load data into handles structure
    if spot==1
        handles.green(end+1).name = sprintf('%s (green profile)',filename);
        handles.green(end).image = single( mean(data.imageData(:,:,1:size(data.imageData,3)),3) ); % Avg. image
        handles.green(end).raw = handles.green(end).image;
        ROI = mainhandles.settings.ROIs.Droi;
        if (size(data.imageData,1)<sum(ROI([1 3]))) || (size(data.imageData,2)<sum(ROI([2 4])))
            ROI = floor([1, 1, size(data.imageData,1)/2, size(data.imageData,2)/2]);
        end
        handles.green(end).ROI = ROI;
        handles.green(end).pars = fit2Dgauss(handles, handles.green(end).image,handles.green(end).ROI, 1); % Parameters of a fitted 2D gauss function
        handles.green(end).existing = 0;
        handles.green(end).measured = 1;
    elseif spot==2
        handles.red(end+1).name = sprintf('%s (red profile)',filename);
        handles.red(end).image = single( mean(data.imageData(:,:,1:size(data.imageData,3)),3) ); % Avg. image
        handles.red(end).raw = handles.red(end).image;
        ROI = mainhandles.settings.ROIs.Aroi;
        if (size(data.imageData,1)<sum(ROI([1 3]))) || (size(data.imageData,2)<sum(ROI([2 4])))
            ROI = floor([size(data.imageData,1)/2+1, 1, size(data.imageData,1)/2, size(data.imageData,2)/2]);
        end
        handles.red(end).ROI = ROI;
        handles.red(end).pars = fit2Dgauss(handles, handles.red(end).image, handles.red(end).ROI, 2); % Parameters of a fitted 2D gauss function
        handles.red(end).existing = 0;
        handles.red(end).measured = 1;
    end
    
    data = []; % Delete loaded movie
    
    % Update waitbar
    waitbar(i/nfiles)
    
end

% Update
updateprofilesListbox(handles)
if spot==1
    set(handles.greenListbox,'Value',length(handles.green));
    set(handles.greenRadiobutton,'Value',1)
elseif spot==2
    set(handles.redListbox,'Value',length(handles.red));
    set(handles.redRadiobutton,'Value',1)
end
guidata(handles.figure1,handles)
updateimages(handles)
updatepartable(handles)

% Delete waitbar
try delete(hWaitbar), end

function importFRETmovie(handles,spot) %% Imports currently selected movie file from main window
mainhandles = getmainhandles(handles);
if isempty(mainhandles.data)
    mymsgbox('There are no data files loaded into the main iSMS window.');
    return
end
filechoice = get(mainhandles.FilesListbox,'Value');

% Check raw data
if isempty(mainhandles.data(filechoice).imageData)
    mymsgbox('Raw data is missing. Reload from Memory menu.')
    return
end
    
% Turn on waitbar
hWaitbar = mywaitbar(0,'Importing movie. Please wait...','name','iSMS');
% setFigOnTop % Sets the waitbar so that it is always in front

if spot==1 % Green profile
    % Make an average image of all D excitation frames
    frames = find(mainhandles.data(filechoice).excorder=='D'); % Indices of all donor exc frames
elseif spot==2 % Red Profile
    % Make an average image of all A excitation frames
    frames = find(mainhandles.data(filechoice).excorder=='A'); % Indices of all donor exc frames
    
end
% Import data file

% Frame dialog
name = 'Frames';
formats = prepareformats();
prompt = {'Select frames' '';...
    'From frame ' 'frame1';...
    'to ' 'frame2'};

formats(2,1).type = 'text';
formats(3,1).type = 'edit';
formats(3,1).format = 'integer';
formats(3,2).type = 'edit';
formats(3,2).format = 'integer';

DefAns.frame1 = round(length(frames)/1.2);
DefAns.frame2 = length(frames);

[answer, cancelled] = inputsdlg(prompt,name,formats,DefAns);
if cancelled
    try delete(hWaitbar), end
    return
end

frame1 = abs(answer.frame1);
if frame1>length(frames)
    frame1 = length(frames);
end
frame2 = abs(answer.frame2);
if frame2>length(frames)
    frame2 = length(frames);
end

% Avg. image
image = single( mean(mainhandles.data(filechoice).imageData(:,:,frames(frame1:frame2)),3) );

if spot==1 % Green profile
    % Put into handles structure
    handles.green(end+1).name = sprintf('%s (D-frames avg.)',mainhandles.data(filechoice).name);
    handles.green(end).image = image;
    handles.green(end).raw = image;
    handles.green(end).ROI = mainhandles.data(filechoice).Droi;
    waitbar(0.5,hWaitbar,'Fitting Gaussian. Please wait...');
    handles.green(end).pars = [];%fit2Dgauss(handles, handles.green(end).image,handles.green(end).ROI, 1, 0); % Parameters of a fitted 2D gauss function
    handles.green(end).existing = 1;
    handles.green(end).measured = 1;
    
elseif spot==2 % Red Profile
    %     % Make an average image of all A excitation frames
    %     frames = find(mainhandles.data(filechoice).excorder=='A'); % Indices of all donor exc frames
    %     image = single( mean(mainhandles.data(filechoice).imageData(:,:,frames),3) ); % Avg. image
    
    % Put into handles structure
    handles.red(end+1).name = sprintf('%s (A-frames avg.)',mainhandles.data(filechoice).name);
    handles.red(end).image = image;
    handles.red(end).raw = image;
    handles.red(end).ROI = mainhandles.data(filechoice).Aroi;
    waitbar(0.5,hWaitbar,'Fitting Gaussian. Please wait...')
    handles.red(end).pars = [];%fit2Dgauss(handles, handles.red(end).image, handles.red(end).ROI, 2, 0); % Parameters of a fitted 2D gauss function
    handles.red(end).existing = 1;
    handles.red(end).measured = 1;
end

% Update
updateprofilesListbox(handles)
if spot==1
    set(handles.greenListbox,'Value',length(handles.green));
    set(handles.greenRadiobutton,'Value',1)
elseif spot==2
    set(handles.redListbox,'Value',length(handles.red));
    set(handles.redRadiobutton,'Value',1)
end
guidata(handles.figure1,handles)
updateimages(handles)
updatepartable(handles)

% Delete waitbar
waitbar(1,hWaitbar,'Fitting Gaussian. Please wait...');
try delete(hWaitbar), end

function pars = fit2Dgauss(handles, image, roi, spot, showbar) %% Fits a 2D gauss image to the roi-region of image, and returns pars corresponding to image
% spot==1 if green profile. spot==2 if red profile

if nargin<5
    showbar = 1;
end

% Turn on waitbar
if showbar
    hWaitbar = mywaitbar(1,'Fitting Gauss. Please wait...','name','iSMS');
    setFigOnTop % Sets the waitbar so that it is always in front
end

% Fit settings
MaxFunEvals = round(handles.settings.fit.MaxFunEvals);
MaxIter = round(handles.settings.fit.MaxIter);
TolFun = handles.settings.fit.TolFun;
TolX = handles.settings.fit.TolX;
options = optimset('Display','off',...
    'MaxFunEvals',MaxFunEvals,...
    'MaxIter',MaxIter,...
    'TolFun',TolFun,...
    'TolX',TolX); % Don't display messages about iterations

% If fitting to entire side of global image, make new roi parameters
if strcmpi(handles.settings.fit.image,'global')
    if (spot==1 && strcmpi(handles.settings.sides.green,'left')) || (spot==2 && strcmpi(handles.settings.sides.green,'right'))
        roi = [1 1 floor(size(image,1)/2) size(image,2)];
    elseif (spot==1 && strcmpi(handles.settings.sides.green,'right')) || (spot==2 && strcmpi(handles.settings.sides.green,'left'))
        roi = [ceil(size(image,1)/2) 1 floor(size(image,1)/2) size(image,2)];
    elseif (spot==1 && strcmpi(handles.settings.sides.green,'bottom')) || (spot==2 && strcmpi(handles.settings.sides.green,'top'))
        roi = [1 1 size(image,1) floor(size(image,2)/2)];
    elseif (spot==1 && strcmpi(handles.settings.sides.green,'top')) || (spot==2 && strcmpi(handles.settings.sides.green,'bottom'))
        roi = [1 ceil(size(image,2)/2) size(image,1) floor(size(image,2)/2)];
    end
end

% Cut ROI from global image
x = roi(1):(roi(1)+roi(3))-1;
y = roi(2):(roi(2)+roi(4))-1;
image = double(image(x,y));

% xy-grid
xy = zeros(size(image,1),size(image,2),2);
[X,Y] = meshgrid(1:size(image,1),1:size(image,2));
xy(:,:,1) = X';
xy(:,:,2) = Y';

%--- Fit Gaussian ---%
[x0,y0] = find(image==max(image(:)));
p0 = [max(image(:))-min(image(:)),... % Amplitude
    x0(1),...                         % x0
    size(image,1)/2,...               % x-width
    y0(1),...                         % y0
    size(image,2)/2,...               % y-width
    0,...                             % angle
    min(image(:))];                   % background
lb = [0,... % Lower bounds
    1,...
    0,...
    1,...
    0,...
    -pi/4,...
    0];
ub = [65535,... % Upper bounds
    size(image,1),...
    size(image,1)^2,...
    size(image,2),...
    size(image,2)^2,...
    pi/4,...
    65535 ]; % 65535 is the max of uint16

pars = lsqcurvefit(@D2GaussFunctionRot, p0, xy, image, lb, ub, options); % Fit Gaussian
pars(2) = pars(2)+roi(1)-1; % Shift position so it matches global image
pars(4) = pars(4)+roi(2)-1; % Shift position so it matches global image

% Delete waitbar
if showbar
    try delete(hWaitbar), end
end

function gauss = make2Dgauss(imsize, pars) %% Returns a 2D gauss image of size imsize with parameters specified by pars
xy = zeros(imsize(1),imsize(2),2);
[X,Y] = meshgrid(1:imsize(2),1:imsize(1));
xy(:,:,1) = X';
xy(:,:,2) = Y';
gauss = D2GaussFunctionRot(pars,xy);

% --------------------------------------------------------------------
% ------------------------------ Objects -----------------------------
% --------------------------------------------------------------------

function greenListbox_Callback(hObject, ~, handles) %% Callback for changing the green listbox selection
set(handles.greenRadiobutton,'Value',1)
updateimages(handles)
updatepartable(handles)
function greenListbox_CreateFcn(hObject, ~, handles) %% Runs when the green listbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function redListbox_Callback(hObject, ~, handles) %% Callback for chaning the red listbox selection
set(handles.redRadiobutton,'Value',1)
updateimages(handles)
updatepartable(handles)
function redListbox_CreateFcn(hObject, ~, handles) %% Runs when the red listbox is created
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function makeGaussianPushbutton_Callback(hObject, ~, handles) %% Callback for pressing the Make Gaussian button
%--- First choose which profile to make:
prompt = {'Gaussian profile:' 'profile'};
name = 'New';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

formats(2,1).type = 'list';
formats(2,1).style = 'radiobutton';
formats(2,1).items = {'Green' 'Red'};

options.CancelButton = 'on';

DefAns.profile = 1;

[answer, cancelled] = inputsdlg(prompt, name, formats, [], options); % Open dialog box
if (cancelled==1)
    return
end

if answer.profile==1
    set(handles.greenRadiobutton,'Value',1)
else
    set(handles.redRadiobutton,'Value',1)
end
%-----------------------%
mainhandles = getmainhandles(handles);

% Get image
roi = [];
if get(handles.greenRadiobutton,'Value') && (~isempty(handles.green))
    choice = get(handles.greenListbox,'Value');
    imsize = size(handles.green(choice).image);
    roi = handles.green(choice).ROI;
elseif get(handles.greenRadiobutton,'Value') && (~isempty(handles.red))
    choice = get(handles.redListbox,'Value');
    imsize = size(handles.red(choice).image);
elseif get(handles.redRadiobutton,'Value') && (~isempty(handles.red))
    choice = get(handles.redListbox,'Value');
    imsize = size(handles.red(choice).image);
    roi = handles.red(choice).ROI;
elseif get(handles.redRadiobutton,'Value') && (~isempty(handles.green))
    choice = get(handles.greenListbox,'Value');
    imsize = size(handles.green(choice).image);
else
    try  % Try to find size from sms window
        filechoice = get(mainhandles.FilesListbox,'Value');
        imsize = [size(mainhandles.data(filechoice).imageData,1) size(mainhandles.data(filechoice).imageData,2)];
        if get(handles.greenRadiobutton,'Value')
            roi = mainhandles.data(filechoice).Droi;
        else
            roi = mainhandles.data(filechoice).Aroi;
        end
    catch err
        warningmessage = err.message;
        
        % If no default size could be found, make an input dialog
        prompt = {'Global image size (x-pixels):','Global image size (y-pixels):'};
        dlg_title = 'Image size';
        num_lines = 1;
        def = {'512','512'};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        if str2num(answer{1})<1
            answer{1} = '1';
        end
        if str2num(answer{2})<1
            answer{2} = '1';
        end
        imsize = [round(str2num(answer{1})) round(str2num(answer{2}))];
    end
end

% Make default roi if it hasn't been defined yet
if isempty(roi)
    if get(handles.greenRadiobutton,'Value')
        roi = mainhandles.settings.ROIs.Droi;
        if (imsize(1)<sum(roi([1 3]))) || (imsize(2)<sum(roi([2 4])))
            roi = floor([1, 1, imsize(1)/2, imsize(2)/2]);
        end
    else
        roi = mainhandles.settings.ROIs.Aroi;
        if (imsize(1)<sum(roi([1 3]))) || (imsize(2)<sum(roi([2 4])))
            roi = floor([imsize(1)/2+1, 1, imsize(1)/2, imsize(2)/2]);
        end
    end
end

%--- Gaussian parameters ---%
pars = [1,...              % Amplitude
    roi(1)+roi(3)/2,...    % x0
    roi(3)/10,...          % x-width
    roi(2)+roi(4)/2,...    % y0
    roi(4)/10,...          % y-width
    0,...               % angle
    0];                              % background

% pars(1) = 1/(2*pi*pars(3)*pars(5)); % normalize area

% Make Gaussian global image
gauss = make2Dgauss(imsize,pars);

% Store result
if get(handles.greenRadiobutton,'Value')
    handles.green(end+1).name = sprintf('Green profile %i',length(handles.green)+1);
    handles.green(end).image = gauss;
    handles.green(end).raw = gauss;
    handles.green(end).pars = pars;
    handles.green(end).ROI = roi;
    handles.green(end).existing = 0;
    handles.green(end).measured = 0;
    
    updateprofilesListbox(handles)
    set(handles.greenListbox,'Value',length(handles.green))
elseif get(handles.redRadiobutton,'Value')
    handles.red(end+1).name = sprintf('Red profile %i',length(handles.red)+1);
    handles.red(end).image = gauss;
    handles.red(end).raw = gauss;
    handles.red(end).pars = pars;
    handles.red(end).ROI = roi;
    handles.red(end).existing = 0;
    handles.red(end).measured = 0;
    
    updateprofilesListbox(handles)
    set(handles.redListbox,'Value',length(handles.red))
end

% Update
guidata(handles.figure1,handles)
updateimages(handles)
updatepartable(handles)

function fitGaussianPushbutton_Callback(hObject, ~, handles) %% Callback for pressing the Fit Gaussian button
if isempty(handles.green) && isempty(handles.red)
    return
end

% Get data
if get(handles.greenRadiobutton,'Value') && (~isempty(handles.green))
    choice = get(handles.greenListbox,'Value');
    img= double(handles.green(choice).image);
    roi = handles.green(choice).spotROI;
    spot = 1;
elseif get(handles.redRadiobutton,'Value') && (~isempty(handles.red))
    choice = get(handles.redListbox,'Value');
    img = double(handles.red(choice).image);
    roi = handles.red(choice).spotROI;
    spot = 2;
else return
end

% Get parameters of fitted 2D Gauss
pars = fit2Dgauss(handles, img, roi, spot);

% pars(1) = 1/(2*pi*pars(3)*pars(5)); % normalize area
% pars(7) = 0;

% Make Gaussian global image
fit = make2Dgauss([size(img,1) size(img,2)], pars);

% Store result
if get(handles.greenRadiobutton,'Value') && (~isempty(handles.green))
    handles.green = storeSpot(handles.green, ...
        sprintf('Fit: %s',handles.green(choice).name), ...
        fit, ...
        handles.green(choice).ROI, ...
        handles.green(choice).spotROI,...
        pars,...
        0,...
        0);
    
    updateprofilesListbox(handles)
    set(handles.greenListbox,'Value',length(handles.green));
elseif get(handles.redRadiobutton,'Value') && (~isempty(handles.red))
    handles.red = storeSpot(handles.red, ...
        sprintf('Fit: %s',handles.red(choice).name), ...
        fit, ...
        handles.red(choice).ROI, ...
        handles.red(choice).spotROI,...
        pars,...
        0,...
        0);
    
    updateprofilesListbox(handles)
    set(handles.redListbox,'Value',length(handles.red));
end

% Update
guidata(handles.figure1,handles)
updateimages(handles)
updatepartable(handles)

function SmoothPushbutton_Callback(hObject, ~, handles) %% Callback for pressing the Smooth button
if isempty(handles.green) && isempty(handles.red)
    return
end

% Turn on waitbar
hWaitbar = mywaitbar(1,'Smoothing image...','name','iSMS');
setFigOnTop % Sets the waitbar so that it is always in front

% Smooth
factor = handles.settings.smooth.factor;%get(handles.Settings_Smooth,'UserData');
factor = mainhandles.settings.spot.kernelsize;%get(handles.Settings_Smooth,'UserData');
if get(handles.greenRadiobutton,'Value') && ~isempty(handles.green) % Green profile
    choice = get(handles.greenListbox,'Value');
    image = handles.green(choice).image;
    %     h = fspecial('average',[factor factor]); % Or, for the mean filter of size [3 3] the kernel is just: h = 1/9*ones(3)
    %     smoothed = filter2(h, image,'valid'); % Type 'Valid' does not include boundaries
    smoothed = medfilt2(image,[factor factor]);
    handles.green(choice).image(ceil(factor/2):end-floor(factor/2),ceil(factor/2):end-floor(factor/2)) = smoothed; % Insert smoothed image into image array
    
elseif ~isempty(handles.red) % Red profile
    choice = get(handles.redListbox,'Value');
    image = handles.red(choice).image;
    %     h = fspecial('average',[factor factor]); % Or, for the mean filter the kernel is just: h = 1/9*ones(3)
    %     smoothed = filter2(h, image,'valid'); % Type 'Valid' does not include boundaries
    smoothed = medfilt2(image,[factor factor]);
    handles.red(choice).image(ceil(factor/2):end-floor(factor/2),ceil(factor/2):end-floor(factor/2)) = smoothed; % Insert smoothed image into image array
end

% Update
guidata(handles.figure1,handles)
updateimages(handles)
updatepartable(handles)

try delete(hWaitbar), end

function SelectionPanel_SelectionChangeFcn(hObject, ~, handles) %% Callback for changing the selection (green vs. red profile radiobuttons)
updateimages(handles)
updatepartable(handles)

function parTable_CellEditCallback(hObject, ~, handles) %% Callback for changing parameter table values
greenchoice = get(handles.greenListbox,'Value');
redchoice = get(handles.redListbox,'Value');

% Entered parameters
partable = get(handles.parTable,'data');
Gpars = partable(1,:);
Rpars = partable(2,:);

% Check if selection was made on wrong profile
ok = 0;
if get(handles.greenRadiobutton,'Value') && ~isempty(handles.red) && ~isequal(handles.red(redchoice).pars,Rpars)
    ok = 1;
elseif get(handles.redRadiobutton,'Value') && ~isempty(handles.green) && ~isequal(handles.green(greenchoice).pars,Gpars)
    ok = 1;
end
if ok
    mymsgbox('You are only allowed to changed the parameters of the selected profile.','iSMS');
    updatepartable(handles)
    return
end

% Check if change was made to intensity
ok = 0;
if ~isempty(handles.red) && ~isequal(handles.red(redchoice).pars,Rpars) && ~isequal(handles.red(redchoice).pars(1),Rpars(1))
    ok = 1;
elseif ~isempty(handles.green) && ~isequal(handles.green(greenchoice).pars,Gpars) && ~isequal(handles.green(greenchoice).pars(1),Gpars(1))
    ok = 1;
end
if ok
    mymsgbox('You are not allowed to changed the amplitude of the Gaussian (normalized by default).','iSMS');
    updatepartable(handles)
    return
end

% Make change
if get(handles.greenRadiobutton,'Value') && ~isempty(handles.green) && ~isequal(handles.green(greenchoice).pars,Gpars)
    % Make a new Gaussian with specified parameters
    imsize = size(handles.green(greenchoice).image);
    gauss = make2Dgauss(imsize, Gpars);
    
    % If it's a measured profile, make a new pure Gaussian
    if handles.green(greenchoice).measured
        handles.green(end+1).name = sprintf('Gaussian Fit: %s',handles.green(greenchoice).name);
        handles.green(end).image = gauss;
        handles.green(end).raw = gauss;
        handles.green(end).pars = Gpars;
        handles.green(end).ROI = handles.green(greenchoice).ROI;
        handles.green(end).existing = 0;
        handles.green(end).measured = 0;
        
        updateprofilesListbox(handles)
        set(handles.greenListbox,'Value',length(handles.green))
    else
        handles.green(greenchoice).pars = Gpars;
        handles.green(greenchoice).image = gauss;
    end
    
elseif get(handles.redRadiobutton,'Value') && ~isempty(handles.red) && ~isequal(handles.red(redchoice).pars,Rpars)
    % Make a new Gaussian with specified parameters
    imsize = size(handles.red(redchoice).image);
    gauss = make2Dgauss(imsize, Rpars);
    
    % If it's a measured profile, make a new pure Gaussian
    if handles.red(redchoice).measured
        handles.red(end+1).name = sprintf('Gaussian Fit: %s',handles.red(redchoice).name);
        handles.red(end).image = gauss;
        handles.red(end).raw = gauss;
        handles.red(end).pars = Rpars;
        handles.red(end).ROI = handles.red(redchoice).ROI;
        handles.red(end).existing = 0;
        handles.red(end).measured = 0;
        
        updateprofilesListbox(handles)
        set(handles.redListbox,'Value',length(handles.red))
    else
        handles.red(redchoice).pars = Rpars;
        handles.red(redchoice).image = gauss;
    end
end

% Update GUI
guidata(handles.figure1,handles)
updateimages(handles)
updatepartable(handles)

function contrastSlider_Callback(hObject, ~, handles) %% Callback for the contrast slider above the image
updateimages(handles)
function contrastSlider_CreateFcn(hObject, ~, handles) %% Runs when the contrast slider is created
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% ---------------------- Export / Cancel buttons ---------------------

function CancelPushbutton_Callback(hObject, ~, handles) %% Runs when pressing Cancel button
try delete(handles.figure1), end

function ExportPushbutton_Callback(hObject, ~, handles) %% Runs when pressing Export button
if isempty(handles.main) || ~ishandle(handles.main)
    return
end
mainhandles = getmainhandles(handles);
if isempty(handles.main)
    delete(handles.figure1)
    return
end
if isempty(mainhandles.data)
    mymsgbox(sprintf('%s%s',...
        'Before exporting manually created spot-profiles to iSMS you have to have at least one traditional movie data file loaded into iSMS.',...
        'This file will be used as a data structure template for the import.'),'No data files loaded');
    return
end

% Store
for i = 1:length(handles.green)
    
    img = handles.green(i).image;
    data.imageData = cat(3,img,img);
    
    mainhandles = storeMovie(mainhandles, data, handles.green(i).name, pwd, 1);
    
    mainhandles.data(end).Droi = handles.green(i).ROI;
    mainhandles.data(end).avgimage = img;
    mainhandles.data(end).avgDimage = img;
    mainhandles.data(end).avgAimage = img;
end
for i = 1:length(handles.red)
    img = handles.red(i).image;
    data.imageData = cat(3,img,img);
    
    mainhandles = storeMovie(mainhandles, data, handles.red(i).name, pwd, 2);
    
    mainhandles.data(end).Aroi = handles.red(i).ROI;
    mainhandles.data(end).avgimage = img;
    mainhandles.data(end).avgDimage = img;
    mainhandles.data(end).avgAimage = img;
end

% Update handles structure and imitate click in sms files listbox
updatemainhandles(mainhandles)
updatefileslist(handles.main,mainhandles.histogramwindowHandle)
set(mainhandles.FilesListbox,'Value',length(mainhandles.data))

[mainhandles,FRETpairwindowHandles,histogramwindowHandles] = filesListboxCallback(mainhandles.FilesListbox, [], mainhandles.figure1); % Imitate click in main files listbox

% Close profile editor
try 
    set(mainhandles.Toolbar_profileWindow,'State','off')
    delete(handles.figure1)
end

function Tools_ContrastAlgorithm_Callback(hObject, eventdata, handles)
handles = spotfitterCallback(handles);

function Edit_Rename_Callback(hObject, eventdata, handles)
handles = renameSpotDataCallback(handles);

function Tools_setspotROI_Callback(hObject, eventdata, handles)
handles = setspotROIcallback(handles);

function Help_handles_Callback(hObject, eventdata, handles)
assignin('base', 'spotWindowHandles', handles) % Send to workspace
