function handles = openFRETpairwindowCallback(handles)
% Callback for opening the FRET pair window in the main toolbar
%
%    Input:
%     mainhandles   - handles structure of the main window
%
%    Output:
%     mainhandles   - ...
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

%% Initialize

% Check if this function is not supposed to be run
if ~isempty(getappdata(0,'callback'))
    return
end

handles = turnofftoggles(handles,'all');% Turn off all interactive toggle buttons in the toolbar
if (~isempty(handles.FRETpairwindowHandle)) && (ishandle(handles.FRETpairwindowHandle))
    return
end

% Show waitbar
hWaitbar = mywaitbar(0,'Initializing FRET-pair window...','name','iSMS');
setFigOnTop % Sets the waitbar so that it is always in front

% handles = updateROIimage(handles); % Also updates the ROImovies in the handles structure via saveROImovies. Also exports the handle to the main window to appdata
% handles = updatepeakplot(handles,'all');
handles = updateFRETpairs(handles,1:length(handles.data));
handles = saveROImovies(handles,'all');
waitbar(0.5,hWaitbar) % Update waitbar
updatemainhandles(handles) % Sends the handles structure to appdata

%% Open window

FRETpairwindowHandle = FRETpairwindow; % Opens the FRETpairwindow and saves its handle in the mainhandles structure

%% Update handles and GUI

handles = guidata(handles.figure1); % Get the new update main handles structure (now with intensity traces and integration ranges, updated by the FRETpairwindowGUI)
handles.FRETpairwindowHandle = FRETpairwindowHandle; % Put the handle of the FRETpairwindow into the handles structure
updatemainhandles(handles) % Updates the handles structure
highlightFRETpair(handles.figure1, FRETpairwindowHandle) % Highlight selected pair on ROI image

% Turn off waitbar
try waitbar(1,hWaitbar) % Update waitbar
    delete(hWaitbar)
end
