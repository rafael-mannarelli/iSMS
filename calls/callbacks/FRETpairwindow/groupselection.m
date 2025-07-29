function Gchoice = groupselection(FRETpairwindowHandles,title,text) 
% Opens a listbox with all groups and allows the user to select groups from
% the list (Gchoices) 
%
%    Input:
%     FRETpairwindowHandles   - handles structure of the FRETpair window
%     title                   - title of dialog
%     text                    - text to show in dialog
%
%    Output:
%     Gchoice                 - [groupchoice1 groupchoice2...]
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

%% Initialze

% Initialize
Gchoice = [];

% Get mainhandles structure
mainhandles = getmainhandles(FRETpairwindowHandles); % Get handles structure of the main figure window (sms)
if (isempty(mainhandles)) || (isempty(mainhandles.data)) || (isempty(mainhandles.groups))
    return
end

%% Prepare dialog box

prompt = {text 'selection'};
name = title;

formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

formats(2,1).type = 'list';
formats(2,1).style = 'listbox';
formats(2,1).items = {mainhandles.groups(:).name};
formats(2,1).size = [120 120];
formats(2,1).limits = [0 2]; % multi-select

options.CancelButton = 'on';

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, [], options); % Open dialog box
if (cancelled==1)
    return
end

%% Chosen groups

Gchoice = answer.selection;
