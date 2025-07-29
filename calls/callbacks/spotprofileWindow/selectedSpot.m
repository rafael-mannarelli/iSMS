function [spHandles, imageData, ROI, spotROI, spottype, spotchoice] = selectedSpot(spHandles)
% Returns the selected spot profile in the spot profile window
%
%   Input:
%    spHandles   - handles structure of the spot profile window
%
%   Output:
%    spHandles   - ..
%    imageData   - raw imageData
%    ROI         - ROI
%    spotROI     - ROI for spot fit
%    spottype    - 1 if green selection, 2 if red
%    spotchoice  - selected spot
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

imageData = [];
ROI = [];
spotROI = [];
spottype = [];
spotchoice = [];

%% Return selection

if get(spHandles.greenRadiobutton,'Value') && ~isempty(spHandles.green) 
    % Selection is on green radiobutton
    spottype = 1;
    spotchoice = get(spHandles.greenListbox,'Value');

    imageData = spHandles.green(spotchoice).image;
    ROI = round(spHandles.green(spotchoice).ROI);
    if isempty(spHandles.green(spotchoice).spotROI)
        spHandles.green(spotchoice).spotROI = ROI;
        guidata(spHandles.figure1,spHandles)
    end
    spotROI = round(spHandles.green(spotchoice).spotROI);

elseif ~isempty(spHandles.red)
    % Selection is on red profile radiobutton
    spottype = 2;
    spotchoice = get(spHandles.redListbox,'Value');
    
    set(spHandles.redRadiobutton,'Value',1)
    imageData = spHandles.red(spotchoice).image;
    ROI = round(spHandles.red(spotchoice).ROI);
    if isempty(spHandles.red(spotchoice).spotROI)
        spHandles.red(spotchoice).spotROI = ROI;
        guidata(spHandles.figure1,spHandles)
    end
    spotROI = round(spHandles.red(spotchoice).spotROI);

end

