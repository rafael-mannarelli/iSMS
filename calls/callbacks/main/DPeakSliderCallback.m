function mainhandles = DPeakSliderCallback(hObject, event, mainhandle)
% Callback for settings the D peakslider value in the main window
%
%    Input:
%     hObject   - handle to the slider
%     event     - eventdata not used
%     mainhandle - handle to the main window
%
%    Ourput:
%     mainhandles - handles structure of the main window
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

% Check raw data
[mainhandles ok] = peaksliderWarningDlg(mainhandles);
if ~ok
    return
end

% Current slider position
sliderVal = get(mainhandles.DPeakSlider,'Value');

% Find peaks and update global coordinates
if sliderVal==0
    mainhandles = clearpeaksdata(mainhandles,file,'D');
    mainhandles = clearROIpeaks(mainhandles,'donor');
else
    mainhandles = peakfinder(mainhandles,'donor');
end
mainhandles = updatepeakglobal(mainhandles,'donor');

% Show peaks
if strcmp(get(mainhandles.Toolbar_DPeaksToggle,'State'),'off')
    set(mainhandles.Toolbar_DPeaksToggle,'State','on')
end

% Update
mainhandles = updatepeakplot(mainhandles,'donor'); % Update peak plot
mainhandles.data(file).peakslider.Dslider = sliderVal; % Update slider value in handles structure
updatemainhandles(mainhandles)

% Update threshold according to slider value
nRaw = size(mainhandles.data(file).DpeaksRaw,1);
idx = round(nRaw*sliderVal);
if idx<nRaw
    idx(2) = idx(1)+1;
end
if idx(1)>0
    mainhandles.settings.peakfinder.DpeakIntensityThreshold = round(mean(mainhandles.data(file).DpeaksRaw(idx,1))*10)/10;
    updatemainhandles(mainhandles)
    mainhandles = updatePeakthresholdsEditbox(mainhandles,2);
end

% Put A's at D's if this setting is chosen
if mainhandles.settings.peakfinder.AatD
    mainhandles = updatepeakglobal(mainhandles,'acceptor');
    
    % Show peaks
    if strcmp(get(mainhandles.Toolbar_APeaksToggle,'State'),'off')
        set(mainhandles.Toolbar_APeaksToggle,'State','on')
    end
    
    % Update
    mainhandles = updatepeakplot(mainhandles,'acceptor'); % Update peak plot
    mainhandles.data(file).peakslider.Aslider = get(mainhandles.APeakSlider,'Value'); % Update slider value in handles structure
    updatemainhandles(mainhandles)
end

% Find FRET pairs
if mainhandles.settings.peakfinder.liveupdateFRETpairs
    mainhandles = findEpairsCallback(mainhandles, 1);
end
