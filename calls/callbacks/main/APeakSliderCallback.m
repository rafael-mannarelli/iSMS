function mainhandles = APeakSliderCallback(hObject, event, mainhandle)
% Callback for changing A peak slider value in the main window
%
%    Input:
%     hObject    - handle to the slider
%     event      - eventdata not used
%     mainhandle - handle to the main window
%
%    Output:
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

% Filechoice
file = get(mainhandles.FilesListbox,'Value'); % Selected movie file

% Check raw data
[mainhandles, ok] = peaksliderWarningDlg(mainhandles);
if ~ok
    return
end

%% Find peaks and update global coordinates

sliderVal = get(mainhandles.APeakSlider,'Value');
if sliderVal==0
    mainhandles = clearpeaksdata(mainhandles,file,'A');
    mainhandles = clearROIpeaks(mainhandles,'acceptor');
else
    mainhandles = peakfinder(mainhandles,'acceptor');
end
mainhandles = updatepeakglobal(mainhandles,'acceptor');

% Show peaks
if strcmp(get(mainhandles.Toolbar_APeaksToggle,'State'),'off')
    set(mainhandles.Toolbar_APeaksToggle,'State','on')
end

%% Update

mainhandles = updatepeakplot(mainhandles,'acceptor'); % Update peak plot
mainhandles.data(file).peakslider.Aslider = sliderVal;% Update slider value in handles structure
updatemainhandles(mainhandles)

% Update threshold according to slider value
nRaw = size(mainhandles.data(file).ApeaksRaw,1);
idx = round(nRaw*sliderVal);
if idx<nRaw
    idx(2) = idx(1)+1;
end
if idx(1)>0
    mainhandles.settings.peakfinder.ApeakIntensityThreshold = round(mean(mainhandles.data(file).ApeaksRaw(idx,1))*10)/10;
    updatemainhandles(mainhandles)
    mainhandles = updatePeakthresholdsEditbox(mainhandles,2);
end

% Put A's at D's if this setting is chosen
if mainhandles.settings.peakfinder.DatA
    mainhandles = updatepeakglobal(mainhandles,'donor');
    
    % Show peaks
    if strcmp(get(mainhandles.Toolbar_DPeaksToggle,'State'),'off')
        set(mainhandles.Toolbar_DPeaksToggle,'State','on')
    end
    
    % Update
    mainhandles = updatepeakplot(mainhandles,'donor'); % Update peak plot
    mainhandles.data(file).peakslider.Dslider = get(mainhandles.DPeakSlider,'Value'); % Update slider value in handles structure
    updatemainhandles(mainhandles)
end

% Find FRET pairs
if mainhandles.settings.peakfinder.liveupdateFRETpairs
    mainhandles = findEpairsCallback(mainhandles, 1);
end
