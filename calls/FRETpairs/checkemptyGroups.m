function mainhandles = checkemptyGroups(mainhandle)
% Checks if any groups are empty and prompt for their deletion
%
%    Input:
%     mainhandle   - handle to the main window
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

% Get mainhandles structure
if isempty(mainhandle) || ~ishandle(mainhandle)
    mainhandles = guidata(getappdata(0,'mainhandle'));
else
    mainhandles = guidata(mainhandle);
end

% Return if not meant to check
if ~mainhandles.settings.grouping.checkforemptyGroups
    return
end

%% Check

idx = ones(length(mainhandles.groups),1);
for i = 1:length(mainhandles.groups)
    
    for j = 1:length(mainhandles.data) % Loop over all files
        for k = 1:length(mainhandles.data(j).FRETpairs) % Loop over all FRETpairs in file j
            if ismember(i,mainhandles.data(j).FRETpairs(k).group)
                idx(i) = 0;
                break
            end
        end
    end
    
end

%% Prompt

% If there are empty groups, ask to delete them
idx = find(idx); % Indices of all empty groups
if ~isempty(idx)
    
    % Dialog message
    if length(idx)>1
        message = sprintf('The following groups are now empty:\n');
    else
        message = sprintf('The following group is now empty:\n');
    end
    
    for i = 1:length(idx)
        message = sprintf('%s\n- %s',message,mainhandles.groups(idx(i)).name);
    end
    
    if length(idx)>1
        message = sprintf('%s\n\nDo you wish to delete them?',message);
    else
        message = sprintf('%s\n\nDo you wish to delete it?',message);
    end
    
    % Open dialog
    choice = myquestdlg(message, ...
        'Delete groups', ...
        ' Yes ',' No ',' No, don''t ask again ',' Yes ');
    
    % Answer
    if strcmp(choice,' Yes ')
        for i = length(idx):-1:1
            
            % Set new, lower index number in FRET-pair group fields
            for j = 1:length(mainhandles.data)
                for k = 1:length(mainhandles.data(j).FRETpairs)
                    groups = mainhandles.data(j).FRETpairs(k).group;
                    mainhandles.data(j).FRETpairs(k).group(groups>idx(i)) = groups(groups>idx(i))-1;
                end
            end
            
            % Delete empty groups
            mainhandles.groups(idx(i)) = [];
        end
        
    elseif strcmpi(choice,' No, don''t ask again ')
        
        % Save setting
        mainhandles = savesettingasDefault(mainhandles,'grouping','checkforemptyGroups',0);
    end
end

%% Update

updatemainhandles(mainhandles)
