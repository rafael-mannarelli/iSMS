function mainhandles = resetPeakSliders(mainhandles,file)
% Resets peak sliders in main window
%
%    Input:
%     mainhandles  - handles structure of the main window
%     file         - movie file
%
%    Output:
%     mainhandles  - ..
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

if nargin<2
    file = get(mainhandles.FilesListbox,'Value');
end

%% Reset values

mainhandles.data(file).peakslider.Dslider = 0; % Update slider value in handles structure
mainhandles.data(file).peakslider.Aslider = 0; % Update slider value in handles structure
updatemainhandles(mainhandles)

%% Reset sliders

if isequal(get(mainhandles.FilesListbox,'Value'),file)
    set(mainhandles.DPeakSlider,'Value',0)
    set(mainhandles.APeakSlider,'Value',0)
    updatepeakcounter(mainhandles)
end
