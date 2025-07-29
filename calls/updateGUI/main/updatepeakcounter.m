function updatepeakcounter(mainhandles)
% Updates the D peak-, A peak- and pair-counters in the sms main window
%
%     Input:
%      mainhandles   - handles structure of the main window (sms)
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

file = get(mainhandles.FilesListbox,'Value'); % Selected movie file
mainhandles = updatepeaklocal(mainhandles,'both'); % Updates peaks from global image into ROI image frame

% If there is no data loaded
if isempty(mainhandles.data)
    set(mainhandles.DPeakCounter,'String',0)
    set(mainhandles.APeakCounter,'String',0)
    set(mainhandles.EPeakCounter,'String',0)
    set(mainhandles.DPeakSlider,'Value',0)
    set(mainhandles.APeakSlider,'Value',0)
    return
end

%% Count

% Count donors currently located within the ROI
Dpeaks = mainhandles.data(file).Dpeaks;
idx = any(mainhandles.data(file).Dpeaks <= 0,2); % Finds all peaks located outside the current ROI
Dpeaks(idx, :) = [];
Dpeaks = size(Dpeaks,1); % No. of donor peaks

% Count acceptors currently located within the ROI
Apeaks = mainhandles.data(file).Apeaks;
idx = any(mainhandles.data(file).Apeaks <= 0, 2); % Finds all peaks located outside the current ROI
Apeaks(idx, :) = [];
Apeaks = size(Apeaks,1); % No. of acceptor peaks

% Count FRET-pairs
Epeaks = length(mainhandles.data(file).FRETpairs);

%% Update counters

set(mainhandles.DPeakCounter,'String',Dpeaks)
set(mainhandles.APeakCounter,'String',Apeaks)
set(mainhandles.EPeakCounter,'String',Epeaks)

