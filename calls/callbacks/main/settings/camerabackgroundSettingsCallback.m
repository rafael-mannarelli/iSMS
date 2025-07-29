function mainhandles = camerabackgroundSettingsCallback(mainhandles,saveasdef)
% Callback for the camera background settings dialog
%
%     Input:
%      mainhandles   - handles structure of the main window
%      saveasdef     - save as defaults
%
%     Output:
%      mainhandles   - ...
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

% Default
if nargin<2
    saveasdef = 0;
end

%% Open settings dialog

DefAns.choice = mainhandles.settings.background.cameraBackgroundChoice;
answer = cameraBackgroundSettingsDlg(mainhandles.figure1,DefAns);
if isempty(answer)
    return
end

% Defaults dialog
if ~saveasdef
    choice = myquestdlg('Save setting as new defaults?','Camera',' Yes ', ' No ', ' No ');
    if isempty(choice)
        choice = ' No ';
    end
else
    choice = ' Yes ';
end

%% Update handles structure with new settings

if strcmpi(choice,' Yes ')
    
    % Save as default
    mainhandles = savesettingasDefault(mainhandles,'background','cameraBackgroundChoice',answer.choice);
    if answer.choice==2
        mainhandles = savesettingasDefault(mainhandles,'background','smthKernel',answer.dynamic);
        mainhandles = savesettingasDefault(mainhandles,'background','checkOffset',answer.checkOffset);
    elseif answer.choice==4
        mainhandles = savesettingasDefault(mainhandles,'background','cameraOffset',answer.dynamic);
        mainhandles = savesettingasDefault(mainhandles,'background','checkOffset',answer.checkOffset);
    end
    
else
    
    % Save to current session only
    mainhandles.settings.background.cameraBackgroundChoice = answer.choice;
    if answer.choice==2
        mainhandles.settings.background.smthKernel = answer.dynamic;
        mainhandles.settings.background.checkOffset = answer.checkOffset;
    elseif answer.choice==4
        mainhandles.settings.background.cameraOffset = answer.dynamic;
        mainhandles.settings.background.checkOffset = answer.checkOffset;
    end
    updatemainhandles(mainhandles)
end
