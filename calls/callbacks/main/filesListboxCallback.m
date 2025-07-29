function [mainhandles,FRETpairwindowHandles,histogramwindowHandles] = filesListboxCallback(hObject, event, mainhandle)
% Callback for selection change in the files listbox
%
%    Input:
%     hObject    - handle to the listbox
%     event      - eventdata not used
%     mainhandle - handle to the main window
%
%     Output:
%      mainhandles   - ..
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
try
    % First try with input
    mainhandles = gogomainhandles(mainhandle);
catch err
    try
        % Then try with parent
        mainhandles = gogomainhandles( get(hObject,'Parent') );
    catch err
        % Then try with stored handle in appdata
        mainhandles = gogomainhandles( getappdata(0,'mainhandle') );
    end
end

% Get FRETpairwindow handles structure
try FRETpairwindowHandles = guidata(mainhandles.FRETpairwindowHandle);
catch err
    FRETpairwindowHandles = [];
end

% Get histogramwindow handles structure
try histogramwindowHandles = guidata(mainhandles.histogramwindowHandle);
catch err
    histogramwindowHandles = [];
end

file = get(mainhandles.FilesListbox,'Value'); % Selected movie file
framechoice = get(mainhandles.FramesListbox,'Value');
if (length(file)==1 && file>length(mainhandles.data)) ...
        || (length(framechoice)==1 && framechoice>2 && isempty(mainhandles.data(file).imageData))
    % If single frame is selected in empty movie
    set(mainhandles.FramesListbox,'Value',1)
end

%% Update peak sliders and contrast slider

if ~isempty(mainhandles.data)
    
    set(mainhandles.DPeakSlider,'Value',mainhandles.data(file).peakslider.Dslider);
    set(mainhandles.APeakSlider,'Value',mainhandles.data(file).peakslider.Aslider);
    
    mainhandles = updatecontrastSliders(mainhandles);
end

%% Update main GUI

updateframeslist(mainhandles)
if get(mainhandles.FramesListbox,'Value')>length(get(mainhandles.FramesListbox,'String'))
    % Check that frame selection does not exceed listbox string
    set(mainhandles.FramesListbox,'Value',1)
end

% Update images
mainhandles = updaterawimage(mainhandles,[],0);
mainhandles = updateframesliderHandle(mainhandles);
mainhandles = updateROIhandles(mainhandles);
mainhandles = updateROIimage(mainhandles,0,0,0);
mainhandles = updatepeakplot(mainhandles,'all',0,0); % Also updates DApeaks, FRETpairs, peak counters and FRETpairlist

% Clear message board
set(mainhandles.mboard,'String','')

% Update handles structure
updatemainhandles(mainhandles)

end

function mainhandles = gogomainhandles(mainhandle)
mainhandles = guidata(mainhandle);
mainhandles = turnofftoggles(mainhandles,'all');% Turn off all interactive toggle buttons in the toolbar
end