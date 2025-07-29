function groupmembers = getgroupmembers(mainhandle,groupchoices)
% Returns the groupmembers (FRET-pairs) of groupchoice as
% [File FRETpair;...]
%
%    Input:
%     mainhandle   - handle to the main figure window (sms)
%     groupchoice  - number from 1:length(mainhandles.groups). If empty,
%                    the function returns all molecules with no associated
%                    group
%
%    Output:
%     groupmembers - [file pair;...]
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

groupmembers = []; % Group members of groupchoice

% If one of the windows is closed
if (isempty(mainhandle)) || (~ishandle(mainhandle))
    return
end

% Get handles
mainhandles = guidata(mainhandle);
if isempty(mainhandles.data) || isempty(mainhandles.groups)
    return
end

% If groupchoices has not been specified, return members of selected group
if nargin==1
    FRETpairwindowHandles = guidata(mainhandles.FRETpairwindowHandle);
    groupchoices = get(FRETpairwindowHandles.GroupsListbox,'Value');
    
elseif isempty(groupchoices)
    
    % Return molecules with no groups
    for i = 1:length(mainhandles.data)
        for j = 1:length(mainhandles.data(i).FRETpairs)
            if isempty(mainhandles.data(i).FRETpairs(j).group)
                groupmembers = [groupmembers; i j];
            end
        end
    end
    return
end

%% Get all FRET-pairs in selected group

for i = 1:length(mainhandles.data)
    for j = 1:length(mainhandles.data(i).FRETpairs)
        for k = 1:length(groupchoices)
            if ismember(groupchoices(k),mainhandles.data(i).FRETpairs(j).group)
                groupmembers = [groupmembers; i j];
            end
        end
    end
end