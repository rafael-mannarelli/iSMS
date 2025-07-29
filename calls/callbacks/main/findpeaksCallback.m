function mainhandles = findpeaksCallback(mainhandles,file,autodetect)
% Callback for finding peaks in main window
%
%    Input:
%     mainhandles   - handles structure of the main window
%     file          - movie file
%     autodetect    - 0/1 whether to force rerunning FastPeakFind
%
%    Output:
%     mainhandles   - ..
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
if nargin<2 || isempty(file)
    file = get(mainhandles.FilesListbox,'Value');
end
if nargin<3 || isempty(autodetect)
    autodetect = 0;
end

% Turn off all interactive toggle buttons in the toolbar
mainhandles = turnofftoggles(mainhandles,'all');

% If no data is loaded, return
if isempty(mainhandles.data) 
    set(mainhandles.mboard,'String','No data loaded')
    return
end

% If peaks toggle buttons are off, put them on
if strcmp(get(mainhandles.Toolbar_DPeaksToggle,'State'),'off')
    set(mainhandles.Toolbar_DPeaksToggle,'State','on')
end
if strcmp(get(mainhandles.Toolbar_APeaksToggle,'State'),'off')
    set(mainhandles.Toolbar_APeaksToggle,'State','on')
end

% Set value of peak-sliders different from 0
if autodetect
    autodetectD = 1;
    autodetectA = 1;
else
    autodetectD = 0;
    autodetectA = 0;
    if get(mainhandles.DPeakSlider,'Value')==0
        autodetectD = 1;
    end
    if get(mainhandles.APeakSlider,'Value')==0
        autodetectA = 1;
    end
end

%% Run peakfinder and update plot

mainhandles = peakfinder(mainhandles,'both',autodetectD,autodetectA,file);
mainhandles = updatepeakplot(mainhandles,'both'); % Also updates FRETpairs
