function [mainhandles cancelled] = initializeFirstrun(mainhandles)
% Asks for some basic settings the first time data is being loaded
%
%    Input:
%     mainhandles   - handles structure of the main window
%
%    Output:
%     mainhandles   - ..
%     cancelled     - the user chose to cancel
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

cancelled = 0;

if ~mainhandles.settings.startup.firstloaddata
    return
end

%% Ask for excitation scheme

% Prepare dialog
str = sprintf(['Since this is the first time data is loaded, please start by specifying some basic settings of your setup.'...
    '\n\nThese settings can be altered later from the settings menu in the main window.\n ']);

formats = prepareformats();
prompt = {str '';...
    'Select your excitation scheme: ' 'excscheme'};
name = 'Initializing iSMS...';

formats(2,1).type = 'text';
formats(4,1).type = 'list';
formats(4,1).style = 'popupmenu';
formats(4,1).items = {'Single-color excitation  '; 'Two-color alternating laser excitation (ALEX)  '};

DefAns.excscheme = mainhandles.settings.excitation.alex+1;

% Open dialog
[answer cancelled] = inputsdlg(prompt,name,formats,DefAns);
if cancelled
    return
end

% Update settings
[mainhandles ok] = savesettingasDefault(mainhandles,'excitation','alex',answer.excscheme-1);
if ~ok
    cancelled = 1;
    return
end

%% Ask for camera background

mainhandles = camerabackgroundSettingsCallback(mainhandles,1);

%% The next time it is no longer the first run

mainhandles = savesettingasDefault(mainhandles,'startup','firstloaddata',0);

%% Update GUI menus

updatemainGUImenus(mainhandles)
