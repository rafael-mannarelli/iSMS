function mainhandles = newgroupCallback(fpwHandles)
% Callback for add to new group in the FRETpairwindow
%
%     Input:
%      fpwHandles    - handles structure of the FRETpairwindow
%
%     Output:
%      mainhandles   - handles structure of the main window
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

fpwHandles = turnoffFRETpairwindowtoggles(fpwHandles); % Turn of integration ROIs
mainhandles = getmainhandles(fpwHandles); % Get handles structure of the main figure window (sms)
if isempty(mainhandles)
    return
end

% File and pair choice
allPairs = getPairs(fpwHandles.main, 'all');

%% Dialog box

prompt = {'New group name:  ' 'newName';...
    'Select molecules to group:  ' 'pairsListbox';...
    'Remove from previous group' 'removePrevious';...
    '(molecules may belong to more than one group)' ''};
name = 'Create new group';

formats = struct('type', {}, 'style', {}, 'items', {}, ...
    'format', {}, 'limits', {}, 'size', {});

% Molecules listbox
formats(2,1).type = 'edit';
formats(2,1).size   = 250;
formats(2,1).format = 'text';
formats(4,1).type = 'list';
formats(4,1).style = 'listbox';
formats(4,1).items = get(fpwHandles.PairListbox,'String');
formats(4,1).size = [200 200];
formats(4,1).limits = [0 2]; % multi-select
% Existing groups listbox
% formats(2,2).type = 'list';
% formats(2,2).style = 'listbox';
% formats(2,2).items = {mainhandles.groups(:).name};
% formats(2,2).size = [200 200];
% formats(2,2).limits = [0 1]; % multi-select
% New group editbox
% Remove from previous - checkbox
formats(5,1).type = 'check';
formats(6,1).type = 'text';

% Default answers
DefAns.pairsListbox = get(fpwHandles.PairListbox,'Value');
% DefAns.groupsListbox = 1;
DefAns.newName = '';
DefAns.removePrevious = 1;

options.CancelButton = 'on';

%-- Open dialog box
[answer, cancelled] = inputsdlg(prompt, name, formats, DefAns, options); % Open dialog box
if (cancelled==1)% || (isequal(DefAns,answer)) % Is actually allowed to be equal in this case
    return
end
% if isempty(answer.pairsListbox)
%     return
% end

% New group
newName = answer.newName;
if isempty(newName)
    return
end

% Selected molecules
pairs = answer.pairsListbox;
listedPairs = getPairs(fpwHandles.main,'listed');
selectedPairs = listedPairs(pairs,:);

%% Set new molecule groups

%     % Put selected molecules into existing group
%     
%     group = answer.groupsListbox;
%     for i = 1:length(pairs)
%         file = selectedPairs(i,1);
%         pair = selectedPairs(i,2);
%         
%         if answer.removePrevious % If removing previous group number from FRET pairs
%             
%             mainhandles.data(file).FRETpairs(pair).group = group;
%             
%         else
%             % Keep in previous group
%             prev = mainhandles.data(file).FRETpairs(pair).group;
%             mainhandles.data(file).FRETpairs(pair).group = [prev group];
%         end
%     end
%     
% else
    % Make new group
    mainhandles = createNewGroup(mainhandles,...
        selectedPairs,...
        newName,...
        round( rand(1,3)*255 ),...
        answer.removePrevious);

% end

%-- Check if a group is now empty
updatemainhandles(mainhandles)
mainhandles = checkemptyGroups(mainhandles.figure1);

%% Update GUI

% Update handles structure
updatemainhandles(mainhandles)

mainhandles = updateGUIafterNewGroup(mainhandles.figure1);
