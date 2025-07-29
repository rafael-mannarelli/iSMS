function mainhandles = myguidebox(mainhandles, name, textstr, id, mboardchoice, url)
% Creates a user guide info box with a checkbox for not showing box again
% in the future. 
%
%      Input:
%       mainhandles   - handles structure of the main window
%       name          - title of box
%       textstr       - info text string
%       id            - field name of relevant infobox in settings.infobox
%                       structure. Initialize this field in
%                       internalSettingsStructure.m
%       mboardchoice  - 0/1 whether to show message in message board
%       url           - URL to documentation page
%
%      Output:
%       mainhandles   - ...

% --- Copyrights (C) ---
%
% Copyright (C)  Søren Preus, FluorTools.com
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     The GNU General Public License is found at
%     <http://www.gnu.org/licenses/gpl.html>.

%% Initialize

if nargin<4
    return
end
if nargin<5 || isempty(mboardchoice)
    mboardchoice = 1;
end
if nargin<6 || isempty(url)
    url = [];
end

% Show message in message board no matter what
if mboardchoice
    set(mainhandles.mboard, 'String',textstr)
end

if ~isfield(mainhandles.settings.infobox, id) || ~mainhandles.settings.infobox.(id)
    return
end

%% Dialog

prompt = {textstr '';...
    'Don''t show this box again  ' 'choice'};
formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});
formats(2,1).type   = 'text';
formats(4,1).type   = 'check';

DefAns.choice = 0;
options.CancelButton = 'off';

% URL button
if ~isempty(url)
    options.ApplyButton = 'on';
    options.buttonNames = {'OK' 'Cancel' 'More info'};
    setappdata(0,'infoURL',url)
end

% Open dialog
[answer cancelled] = myinputsdlg(prompt, name, formats, DefAns, options);

% Remove appdata
if ~isempty(url)
    try rmappdata(0,'infoURL'), end
end

%% Store the choice of whether to show this message again

if answer.choice
    mainhandles = savesettingasDefault(mainhandles,'infobox',id,0);
end
