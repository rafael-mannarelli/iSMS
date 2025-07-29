function [mainhandles cancelled] = deleteGroup(mainhandles,group)
% Deletes a group
%
%    Input:
%     mainhandles  - handles structure of the main window
%     group        - group to be deleted
%     group2       - group to put molecules in to if the miss a group
%
%    Output:
%     mainhandles  - ..
%     cancelled    - 1 if user choose to cancel
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

% Default
% if nargin<3 || isempty(group2)
%     group2 = [];
% end

% Check number of current groups
% if length(mainhandles.groups)==1
%     mymsgbox('You can''t delete the only existing group.')
%     return
% end

% Pairs in group to be deleted
groupPairs = getPairs(mainhandles.figure1,'group',group);

%% Check if some pairs in group will be missing a new group

% ok = 0;
% for i = 1:size(groupPairs,1)
%     file = groupPairs(i,1);
%     pair = groupPairs(i,2);
%     if length(mainhandles.data(file).FRETpairs(pair).group)<=1
%         ok = 1;
%         break
%     end
% end
% 
% % Prompt dialog for new group
% if ok
%     group2 = mylistdlg('ListString',{mainhandles.groups(:).name}',...
%         'name','Select group',...
%         'PromptString','Select new group for pairs missing a group',...
%         'SelectionMode','single',...
%         'ListSize', [300 300]);
%     if isempty(group2)
%         cancelled = 1;
%         return
%     end
% end

%% Remove group

mainhandles.groups(group) = [];
updatemainhandles(mainhandles)

%% Remove pairs from group

for i = 1:size(groupPairs,1)
    file = groupPairs(i,1);
    pair = groupPairs(i,2);
    
    if length(mainhandles.data(file).FRETpairs(pair).group)<=1
        mainhandles.data(file).FRETpairs(pair).group = [];
    else
        g = mainhandles.data(file).FRETpairs(pair).group;
        mainhandles.data(file).FRETpairs(pair).group(find(g==group)) = [];
    end
end

%% Correct new group numbers

allPairs = getPairs(mainhandles.figure1,'all');
for i = 1:size(allPairs,1)
    file = allPairs(i,1);
    pair = allPairs(i,2);
    
    % Groups larger than group
    idx = find(mainhandles.data(file).FRETpairs(pair).group>group);
    if ~isempty(idx)
        mainhandles.data(file).FRETpairs(pair).group(idx) = mainhandles.data(file).FRETpairs(pair).group(idx)-1;
    end
end

%% Update

updatemainhandles(mainhandles)
mainhandles = updateGUIafterNewGroup(mainhandles.figure1);
