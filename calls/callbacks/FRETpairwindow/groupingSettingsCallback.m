function mainhandles = groupingSettingsCallback(FRETpairwindowHandles)
% Callback for settings grouping properties in the FRETpairwindow
%
%     Syntax:
%      mainhandles = groupingSettingsCallback(FRETpairwindowHandles)
%
%     Input:
%      FRETpairwindowHandles  - handles structure of the FRETpairwindow
%
%     Output:
%      mainhandles            - handles structure of the main window
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

FRETpairwindowHandles = turnoffFRETpairwindowtoggles(FRETpairwindowHandles); % Turn of integration ROIs
mainhandles = getmainhandles(FRETpairwindowHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

%% Prepare dialog box

prompt = {'Use color-coding to distinguish groups' 'colorList';...
    'Show group name in FRET-pair listbox' 'nameList';...
    'Boldface group members of selected groups' 'highlight';...
    'Show string ''(no group)'' for ungrouped molecules (alternative is no string)' 'showNoGroup';...
    'Remove molecules from old group when transferring to new group' 'removefromPrevious'};
name = 'Grouping settings';

% Formats structure:
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% Interpolation choices
formats(2,1).type = 'check';
formats(3,1).type = 'check';
formats(4,1).type = 'check';
formats(5,1).type = 'check';
formats(8,1).type = 'check';

% Default choices
DefAns.colorList = mainhandles.settings.grouping.colorList;
DefAns.nameList = mainhandles.settings.grouping.nameList;
DefAns.highlight = mainhandles.settings.grouping.highlight;
DefAns.removefromPrevious = mainhandles.settings.grouping.removefromPrevious;
DefAns.showNoGroup = mainhandles.settings.grouping.showNoGroup;

options.CancelButton = 'on';

%% Open dialog box

[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1) || (isequal(DefAns,answer))
    return
end

%% Set new settings

mainhandles.settings.grouping.colorList = answer.colorList;
mainhandles.settings.grouping.nameList = answer.nameList;
mainhandles.settings.grouping.highlight = answer.highlight;
mainhandles.settings.grouping.removefromPrevious = answer.removefromPrevious;
mainhandles.settings.grouping.showNoGroup = answer.showNoGroup;

%% Update GUI

updatemainhandles(mainhandles)

% Update pair list
if DefAns.colorList~=answer.colorList || DefAns.nameList~=answer.nameList...
        || DefAns.showNoGroup~=answer.showNoGroup
    
    % Update
    updateFRETpairlist(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)
    updategrouplist(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)
    
elseif (DefAns.highlight~=answer.highlight)
    
    updateFRETpairlist(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)
end
