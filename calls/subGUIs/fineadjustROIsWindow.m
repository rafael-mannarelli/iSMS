function varargout = fineadjustROIsWindow(varargin)
% FINEADJUSTROISWINDOW
%    GUI window associated with fine-adjusting ROIs in the main window
%
%    Is run from the Tools menu in the main window
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

% Last Modified by GUIDE v2.5 19-Nov-2013 15:40:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fineadjustROIsWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @fineadjustROIsWindow_OutputFcn, ...
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

function fineadjustROIsWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% Set position, title and logo. Turn off visibility.
initGUI(handles.figure1, 'Fine adjust ROIs', 'center');

% Handle to main figure window
handles.main = getappdata(0,'mainhandle');
mainhandles = guidata(handles.main);

% Update ROI textbox
updateROItextbox(handles.figure1)

% Choose default command line output for FRETpairwindow
handles.output = hObject; % Return handle to GUI window

% Now show GUI and update plots
set(handles.figure1,'Visible','on')
guidata(handles.figure1,handles)

% Set some GUI settings
setGUIappearance(handles.figure1, 0)

function varargout = fineadjustROIsWindow_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
% ----------------- Callback-functions start hereafter ---------------
% - Tip: Fold all code for an overview (Ctrl+= on american keyboard) -
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% ------------------------------ Objects -----------------------------
% --------------------------------------------------------------------

function ROIupPushbutton_Callback(hObject, ~, handles) %% Runs when the ROI up button is pressed
fineadjustROI(handles,'up')
function ROIupPushbutton_CreateFcn(hObject, ~, handles) %% Runs when the ROI up button is created
set(hObject,'FontName','Symbol','String',char(173),'FontSize',12)

function ROIrightPushbutton_Callback(hObject, ~, handles) %% Runs when the ROI right button is pressed
fineadjustROI(handles,'right')
function ROIrightPushbutton_CreateFcn(hObject, ~, handles) %% Runs when the ROI right button is created
set(hObject,'FontName','Symbol','String',char(174),'FontSize',12)

function ROIdownPushbutton_Callback(hObject, ~, handles) %% Runs when the ROI down button is pressed
fineadjustROI(handles,'down')
function ROIdownPushbutton_CreateFcn(hObject, ~, handles) %% Runs when the ROI down button is created
set(hObject,'FontName','Symbol','String',char(175),'FontSize',12)

function ROIleftPushbutton_Callback(hObject, ~, handles) %% Runs when the ROI left button is pressed
fineadjustROI(handles,'left')
function ROIleftPushbutton_CreateFcn(hObject, ~, handles) %% Runs when the ROI left button is created
set(hObject,'FontName','Symbol','String',char(172),'FontSize',12)

function DroiRadiobutton_Callback(hObject, ~, handles)
set(handles.DroiRadiobutton,'Value',1)
set(handles.AroiRadiobutton,'Value',0)

function AroiRadiobutton_Callback(hObject, ~, handles)
set(handles.DroiRadiobutton,'Value',0)
set(handles.AroiRadiobutton,'Value',1)

% ----- General callback ----
function fineadjustROI(handles,direction) %% Callback when pressing one of the four fine-adjust ROI buttons
mainhandles = getmainhandles(handles);
if isempty(mainhandles)
    return
end

mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar
if (isempty(mainhandles.data)) || (isempty(mainhandles.AROIhandle)) || (isempty(mainhandles.DROIhandle)) % If no data is loaded, return
    set(mainhandles.mboard,'String','No data or ROIs loaded')
    return
end
filechoice = get(mainhandles.FilesListbox,'Value'); % Selected movie file

% Check if raw movie has been deleted
if isempty(mainhandles.data(filechoice).imageData)
    choice = myquestdlg(sprintf('The raw movie has been deleted for this file (%s). Do you want to reload the movie from file?',mainhandles.data(filechoice).name),...
        'Movie deleted',...
        'Yes','No','No');
    
    if strcmp(choice,'Yes')
        mainhandles = reloadMovieCallback(mainhandles);
    end
    return
end

% Get current ROI
if get(handles.DroiRadiobutton,'Value') % If moving donor ROI
    pos = mainhandles.data(filechoice).Droi; % The position of the donor ROI in the global image
    ROIhandle = mainhandles.DROIhandle; % Handle to donor ROI-rectangle in the global image
elseif get(handles.AroiRadiobutton,'Value') % If moving acceptor ROI
    pos = mainhandles.data(filechoice).Aroi; % The position of the acceptor ROI in the global image
    ROIhandle = mainhandles.AROIhandle; % Handle to acceptor ROI-rectangle in the global image
end

% Do operation only if ROI stays within rawimage frame
if strcmp(direction,'up')
    pos(2) = pos(2)+1;
elseif strcmp(direction,'right')
    pos(1) = pos(1)+1;
elseif strcmp(direction,'down')
    pos(2) = pos(2)-1;
elseif strcmp(direction,'left')
    pos(1) = pos(1)-1;
end

% Only do operation if ROI will not exceed limits
imwidth = size(mainhandles.data(filechoice).imageData,1);
imheight = size(mainhandles.data(filechoice).imageData,2);

% Set position
if pos(1)>=0.5 && pos(2)>=0.5 ...
        && sum(pos([1 3]))<imwidth+.5 && sum(pos([2 4]))<imwidth+.5
    
%     setappdata(0,'dontupdateROIpos',1) % Tells updateRoiPos not to run
    setPosition(ROIhandle,pos) % [x y widht height]
%     rmappdata(0,'dontupdateROIpos')

end
mainhandles = guidata(mainhandles.figure1); % Get new handles structure
