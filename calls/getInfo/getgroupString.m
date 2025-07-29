function namestr = getgroupString(mainhandles,FRETpairwindowHandle)
% Returns the group listbox string
%
%    Input:
%     mainhandles          - handles structure of the main window
%     FRETpairwindowHandle - handle to the FRETpairwindow
%
%    Output:
%     namestr              - cell string for listbox
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
if nargin<2 || isempty(FRETpairwindowHandle)
    FRETpairwindowHandle = mainhandles.FRETpairwindowHandle;
end

%% Create string

% Get group names
namestr = {mainhandles.groups(:).name}';
for i = 1:length(namestr)
    groupmembers = getPairs(mainhandles.figure1, 'Group', i, FRETpairwindowHandle);
    namestr{i} = sprintf('%s (%i)', namestr{i},size(groupmembers,1)); % Change listbox string
end

% Colorize listbox according to group
if mainhandles.settings.grouping.colorList
    
    for i = 1:size(namestr,1)
        color = mainhandles.groups(i).color;
        namestr{i} = sprintf('<HTML><BODY color="rgb(%i, %i, %i)">%s</HTML>', color, namestr{i}); % Change string to HTML code
    end
end
