function varargout = GaussianComponentsWindow(varargin)
% Opens a window displaying nothing but a table of Gaussian parameter
% values
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

% Last Modified by GUIDE v2.5 15-Apr-2013 14:02:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GaussianComponentsWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @GaussianComponentsWindow_OutputFcn, ...
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

function GaussianComponentsWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% Move gui
% movegui(handles.figure1,'east')

% Rename window
set(handles.figure1,'name','Gaussians','numbertitle','off')

% Update window logo
updatelogo(handles.figure1)
 
% Handle to main figure window
handles.histogramwindowHandle = getappdata(0,'histogramwindowHandle');
handles.main = getappdata(0,'mainhandle');
% mainhandles = guidata(handles.main);

% Choose default command line output for GaussianComponentsWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = GaussianComponentsWindow_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function figure1_CloseRequestFcn(hObject, eventdata, handles)
try
    delete(hObject);
end

try % Turn off toggle button
    histogramwindowHandles = guidata(handles.histogramwindowHandle);
    set(histogramwindowHandles.Toolbar_GaussianComponentsWindow,'State','off')
end
