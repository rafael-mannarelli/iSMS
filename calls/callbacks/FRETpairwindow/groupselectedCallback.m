function [mainhandles, FRETpairwindowHandles] = groupselected(FRETpairwindowHandles)
% Callback for grouping selected molecules in the FRETpairwindow
%
%    Input:
%     FRETpairwindowHandles  - handles structure of the FRETpairwindow
%
%    Output:
%     mainhandles            - handles structure of the main window
%     FRETpairwindowHandles  - ..
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

% Check groups
if isempty(mainhandles.groups)
    mymsgbox('There are no groups. Create a new group by going to ''Grouping->Create new group'' in the FRET-pair window.');
    return
end

% Selection
selectedPairs = getPairs(FRETpairwindowHandles.main, 'Selected', [], FRETpairwindowHandles.figure1);
selectedGroup = get(FRETpairwindowHandles.GroupsListbox,'Value');

%% Set new molecule group

for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    if mainhandles.settings.grouping.removefromPrevious
        mainhandles.data(file).FRETpairs(pair).group = selectedGroup;
    else
        mainhandles.data(file).FRETpairs(pair).group = unique([mainhandles.data(file).FRETpairs(pair).group selectedGroup]);
    end
end

% Check if there are empty groups now
updatemainhandles(mainhandles)
mainhandles = checkemptyGroups(mainhandles.figure1);

%% Update GUI

updateFRETpairlist(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)
updategrouplist(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1)

if mainhandles.settings.FRETpairplots.sortpairs == 2
    mainhandles = sortpairsCallback(FRETpairwindowHandles.figure1);
    
    % Keep selected FRETpairs (no effect from doing sortpairsCallback)
    listedPairs = getPairs(FRETpairwindowHandles.main,'listed',[],FRETpairwindowHandles.figure1);
    idx = find( ismember(listedPairs,selectedPairs,'rows','legacy') );
    set(FRETpairwindowHandles.PairListbox, 'Value',idx)
end

% If histogram is open update the histogram
if (strcmp(get(mainhandles.Toolbar_histogramwindow,'State'),'on')) ...
        && (~isempty(mainhandles.histogramwindowHandle)) ...
        && (ishandle(mainhandles.histogramwindowHandle))
    
    histogramwindowHandles = guidata(mainhandles.histogramwindowHandle);
    if get(histogramwindowHandles.plotSelectedGroupRadiobutton,'Value')
        % If plotting only data-points from the group selected in the FRETpairwindow GUI
        mainhandles = updateSEplot(FRETpairwindowHandles.main,FRETpairwindowHandles.figure1,mainhandles.histogramwindowHandle,'all');
        figure(FRETpairwindowHandles.figure1)
    end
end
