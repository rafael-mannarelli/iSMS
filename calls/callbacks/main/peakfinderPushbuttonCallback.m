function mainhandles = peakfinderPushbuttonCallback(hObejct, event, mainhandle)
% Callback for pushing the peak finder pushbutton in the main window
%
%     Input:
%      hObject      - handle to the button
%      event        - eventdata
%      mainhandle   - handle to the main window
%
%     Output:
%      mainhandles  - handles structure of the main window
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
try mainhandles = guidata(mainhandle);
catch err
    mainhandle = getappdata(0,'mainhandle');
    mainhandles = guidata(mainhandle);
end

% Turn off all interactive toggle buttons in the toolbar
mainhandles = turnofftoggles(mainhandles,'all');
if isempty(mainhandles.data)
    return
end
file = get(mainhandles.FilesListbox,'Value'); % Selected movie file

% Sure? dialog
if ~isempty(mainhandles.data(file).FRETpairs)
    sure = mysuredlg('Peak finder', 'This will delete current FRET-pairs.');
    if ~sure
        return
    end
end

% Show peaks
if strcmp(get(mainhandles.Toolbar_DPeaksToggle,'State'),'off')
    set(mainhandles.Toolbar_DPeaksToggle,'State','on')
end
if strcmp(get(mainhandles.Toolbar_APeaksToggle,'State'),'off')
    set(mainhandles.Toolbar_APeaksToggle,'State','on')
end

% Info box
str = sprintf(['Tip:\n\n'...
    'Use the sliders to find a proper set of thresholds for your data,\n'...
    'then save the new settings as the default using the button in the peak finder panel toolbar.\n']);
mainhandles = myguidebox(mainhandles,'Find FRET-pairs',str,'peakfinder',1,'http://isms.au.dk/documentation/find-fret-pairs/');

%% Find peaks and update global coordinates

mainhandles = clearpeaksdata(mainhandles,file,'all');
mainhandles = updatepeakglobal(mainhandles,'all');

% Reset peak sliders
mainhandles = resetPeakSliders(mainhandles);

%% Find FRET pairs

if mainhandles.settings.peakfinder.liveupdateFRETpairs
    
    mainhandles = findEpairsCallback(mainhandles, 0);
    
else
    % Update
    mainhandles = updatepeakplot(mainhandles,'all'); % Update peak plot    
end
