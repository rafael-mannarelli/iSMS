function mainhandles = createNewGroup(mainhandles, selectedPairs, newName, col, removePrevious)
% Creates a new molecule group
%
%    Input:
%     mainhandle   - handle to the main window
%     selectedPairs - pairs to put in new group
%     newName       - name of group
%     col           - group color
%     removePrevious  - remove the selectedPairs's from previous groups
%
%    Output:
%     mainhandles  - handles structure of the main window
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
if nargin<4 || isempty(col)
    col = round( rand(1,3)*255 );
end
if nargin<5 || isempty(removePrevious)
    removePrevious = 0;
end

%% Create new group

% Initialize first group
if nargin==1
    mainhandles.groups = [];
%     struct(...
%         'name', 'A',... % Default name of first group
%         'color', [255 0 0]);%,... % Default color of first group: red
    return
end

% Create new group
mainhandles.groups(end+1).name = newName; % New group name
mainhandles.groups(end).color = col; % Assign a random color to new group

%% Add selected molecules to new group

for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    if removePrevious 
        
        % Remove from previous group        
        mainhandles.data(file).FRETpairs(pair).group = length(mainhandles.groups);
        
    else
        % Keep in previous group
        prev = mainhandles.data(file).FRETpairs(pair).group;
        mainhandles.data(file).FRETpairs(pair).group = unique([prev length(mainhandles.groups)],'stable');
    end
    
end

%% Update

updatemainhandles(mainhandles)
