function varargout = spotprofileSettings(varargin)
% GUI for setting spot-profile settings
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

% Last Modified by GUIDE v2.5 18-Apr-2013 16:18:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @spotprofileSettings_OpeningFcn, ...
    'gui_OutputFcn',  @spotprofileSettings_OutputFcn, ...
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

function spotprofileSettings_OpeningFcn(hObject, eventdata, handles, varargin)
% Rename window
set(handles.figure1,'name','Spot profile settings','numbertitle','off')

updatelogo(handles.figure1) % Update logo

% Choose default command line output for spotprofileSettings
handles.output = [];

% Handle to main
handles.main = getappdata(0,'mainhandle');
if isempty(handles.main) || ~ishandle(handles.main)
    delete(hObject)
    return
end
mainhandles = guidata(handles.main);

% Default settings
if mainhandles.settings.spot.choice
    set(handles.ChoiceCheckbox,'Value',1)
else
    set(handles.ChoiceCheckbox,'Value',0)
end
ChoiceCheckbox_Callback(handles.ChoiceCheckbox, [], handles)

% Determine all files and spot-profiles
idx = [];
Gidx = []; % Indices of green profiles in mainhandles.data structure
Ridx = []; % Indices of red profiles in mainhandles.data structure
for i = 1:length(mainhandles.data)
    if mainhandles.data(i).spot==1
        Gidx = [Gidx i];
    elseif mainhandles.data(i).spot==2
        Ridx = [Ridx i];
    else
        idx = [idx i];
    end
end
handles.Gidx = Gidx; % Indices of green profiles in mainhandles.data structure
handles.Ridx = Ridx; % Indices of red profiles in mainhandles.data structure

% Determine previous associations
handles.files = struct(...
    'green',[],... % index of green profile associated with file
    'red',[]); % Index of red profile associcated with file
handles.files(1) = [];
for i = 1:length(idx)
    handles.files(end+1).idx = idx(i); % Index in mainhandles.data structure
    
    % Green profile associated with file i
    GspotProfile = mainhandles.data(idx(i)).GspotProfile; % Current spot profile image
    handles.files(end).green = 1; % Default
    if (~isempty(GspotProfile))
        for j = 1:length(Gidx)
            profile = mainhandles.data(Gidx(j)).avgimage; % Profile image of spot j
            if isequal(GspotProfile,profile)
                handles.files(end).green = j;
                break
            end
        end
    end
    
    % Red profile associated with file i
    RspotProfile = mainhandles.data(idx(i)).RspotProfile; % Current spot profile image
    handles.files(end).red = 1; % Default
    if (~isempty(RspotProfile))
        for j = 1:length(Ridx)
            profile = mainhandles.data(Ridx(j)).avgimage; % Profile image of spot j
            if isequal(RspotProfile,profile)
                handles.files(end).red = j;
                break
            end
        end
    end
    
    % gr intensity ratio
    if isempty(mainhandles.data(idx(i)).grRatio)
        handles.files(end).grRatio = mainhandles.settings.spot.grRatio;
    else
        handles.files(end).grRatio = mainhandles.data(idx(i)).grRatio;
    end
end

% Update listboxes
if ~isempty(mainhandles.data)
    set(handles.FilesListbox,'String',{mainhandles.data(idx).name})
    set(handles.greenListbox,'String',{mainhandles.data(Gidx).name})
    set(handles.redListbox,'String',{mainhandles.data(Ridx).name})
end

% Update listbox selection values
updatelistboxes(handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spotprofileSettings wait for user response (see UIRESUME)
uiwait(handles.figure1);

function varargout = spotprofileSettings_OutputFcn(hObject, ~, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

function figure1_CloseRequestFcn(hObject, ~, handles)
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, use UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    try delete(hObject), end
end

% --------------------------------------------------------------------
% ----------------- Callback-functions start hereafter ---------------
% - Tip: Fold all code for an overview (Ctrl+= on american keyboard) -
% --------------------------------------------------------------------

function ChoiceCheckbox_Callback(hObject, ~, handles)
% % Don't implement yet
% if get(handles.ChoiceCheckbox,'Value')
%     mymsgbox('Not implemented yet, sorry')
%     set(handles.ChoiceCheckbox,'Value',0)
%     return
% end

h = [handles.FilesListbox handles.greenListbox handles.redListbox handles.grRatioEditbox];
if get(handles.ChoiceCheckbox,'Value')
    set(h,'Enable','on')
else
    set(h,'Enable','off')
end

function FilesListbox_Callback(hObject, ~, handles)
updatelistboxes(handles)
function FilesListbox_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function greenListbox_Callback(hObject, ~, handles)
if isempty(handles.files)
    return
end
filechoice = get(handles.FilesListbox,'Value');

handles.files(filechoice).green = get(handles.greenListbox,'Value');
guidata(handles.figure1,handles)
function greenListbox_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function redListbox_Callback(hObject, ~, handles)
if isempty(handles.files)
    return
end
filechoice = get(handles.FilesListbox,'Value');

handles.files(filechoice).red = get(handles.redListbox,'Value');
guidata(handles.figure1,handles)
function redListbox_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function grRatioEditbox_Callback(hObject, ~, handles)
value = str2num(get(handles.grRatioEditbox,'String'));
if value<=0
    value = 1;
    set(handles.grRatioEditbox,'String',1)
end
if isempty(handles.files)
    return
end

filechoice = get(handles.FilesListbox,'Value'); % Selected file
handles.files(filechoice).grRatio = value; % Entered value

% Check other values, if they equal default change them too
mainhandles = guidata(handles.main);
for i = 1:length(handles.files)
    if handles.files(i).grRatio==mainhandles.settings.spot.grRatio
        handles.files(i).grRatio = value;
    end
end

% Update handles structure
guidata(handles.figure1,handles)
function grRatioEditbox_CreateFcn(hObject, ~, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ---------------------- Misc ---------------------

function updatelistboxes(handles)
if isempty(handles.files)
    return
end
filechoice = get(handles.FilesListbox,'Value');

% Update GUI
set(handles.greenListbox,'Value',handles.files(filechoice).green)
set(handles.redListbox,'Value',handles.files(filechoice).red)
set(handles.grRatioEditbox,'String',handles.files(filechoice).grRatio)

% ---------------------- Export / Cancel buttons ---------------------

function OKpushbutton_Callback(hObject, ~, handles)
mainhandles = guidata(handles.main);

% Update mainhandles with new settings
mainhandles.settings.spot.choice = get(handles.ChoiceCheckbox,'Value');
if ~isempty(handles.files)
    for i = 1:length(handles.files)
        file = handles.files(i).idx;
        mainhandles.data(file).grRatio = handles.files(i).grRatio;
        if ~isempty(handles.Gidx)
            Gidx1 = handles.files(i).green;
            Gidx2 = handles.Gidx(Gidx1); % Index of green profile within the mainhandles.data structure
            GspotProfile = mainhandles.data(Gidx2).avgimage;
            mainhandles.data(file).GspotProfile = GspotProfile;
        end
        if ~isempty(handles.Ridx)
            Ridx1 = handles.files(i).red;
            Ridx2 = handles.Ridx(Ridx1); % Index of red profile within the mainhandles.data structure
            RspotProfile = mainhandles.data(Ridx2).avgimage;
            mainhandles.data(file).RspotProfile = RspotProfile;
        end
        
    end
end

% The output is the mainhandles structure
handles.output = mainhandles;
guidata(handles.main,mainhandles)

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
guidata(handles.figure1,handles)
uiresume(handles.figure1);

function CancelPushbutton_Callback(hObject, ~, handles)
% Set output as empty
handles.output = [];
guidata(handles.figure1,handles)

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);
