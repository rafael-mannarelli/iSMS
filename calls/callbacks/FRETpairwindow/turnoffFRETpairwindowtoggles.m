function FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles,choice) 
% Turns of all toggle buttons from the toolbar in the FRETpair window. This
% will be run automatically if the user has not done it manually.
%
%    Input:
%     FRETpairwindowHandles - handles structure of the FRETpairwindow
%     choice                - 'intROI', 'intPixels', 'backPixels',
%                             'frameSliders', 'ti', 'bi'
%
%    Output:
%     FRETpairwindowHandles - ..
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

zoom(FRETpairwindowHandles.figure1,'off')
datacursormode(FRETpairwindowHandles.figure1,'off')
if nargin<2
    choice = 'all';
end

%% Turn off

ok = 0;
if (~strcmpi(choice,'intROI')) && strcmp(get(FRETpairwindowHandles.Toolbar_IntegrationROI,'state'),'on')
    set(FRETpairwindowHandles.Toolbar_IntegrationROI,'state','off')
    ok = 1;
end
if (~strcmpi(choice,'backPixels')) && strcmp(get(FRETpairwindowHandles.Toolbar_SelectBackPixels,'state'),'on')
    set(FRETpairwindowHandles.Toolbar_SelectBackPixels,'state','off')
    ok = 1;
end
if (~strcmpi(choice,'frameSliders')) && strcmp(get(FRETpairwindowHandles.Toolbar_SelectBackPixels,'state'),'on')
    set(FRETpairwindowHandles.Toolbar_frameSliders,'state','off')
    ok = 1;
end
if (~strcmpi(choice,'ti')) && strcmpi(get(FRETpairwindowHandles.Toolbar_SetTimeIntervalToggle,'state'),'on')
    set(FRETpairwindowHandles.Toolbar_SetTimeIntervalToggle,'State','off')
end
if (~strcmpi(choice,'bi')) && strcmpi(get(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'state'),'on')
    set(FRETpairwindowHandles.Toolbar_SetBlinkingIntervalToggle,'State','off')
end
if (~strcmpi(choice,'bleachTime')) && strcmpi(get(FRETpairwindowHandles.Toolbar_SetBleachingTimes,'state'),'on')
    set(FRETpairwindowHandles.Toolbar_SetBleachingTimes,'State','off')
end

% Make sure pointer is not stuck in some alternative form
try set(FRETpairwindowHandles.figure1, 'Pointer', FRETpairwindowHandles.functionHandles.cursorPointer); end

%% Get updated FRETpairwindowHandles

if ok
    FRETpairwindowHandles = guidata(FRETpairwindowHandles.figure1); % Get updated handles structure
end
