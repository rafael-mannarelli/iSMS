function mainhandles = updateDatA(mainhandles, filechoice)
% Puts donor positions at all A position or A positions at all D positions
% if this settings has been chosen
%
%    Input:
%     mainhandles   - handles structure of the main window
%     filechoice    - file to update
%
%    Ouytput:
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

% Default is selected file
if nargin<2
    filechoice = get(mainhandles.FilesListbox,'Value');
end

% Put D's at A's positions
if mainhandles.settings.peakfinder.DatA
    mainhandles.data(filechoice).Dpeaks = [mainhandles.data(filechoice).Dpeaks; mainhandles.data(filechoice).Apeaks+0.3];
    r = [zeros(size(mainhandles.data(filechoice).Apeaks,1),1) mainhandles.data(filechoice).Apeaks+0.3];
    mainhandles.data(filechoice).DpeaksRaw = [mainhandles.data(filechoice).DpeaksRaw; r];
end

% Put A's at D's positions
if mainhandles.settings.peakfinder.AatD
    mainhandles.data(filechoice).Apeaks = [mainhandles.data(filechoice).Apeaks; mainhandles.data(filechoice).Dpeaks+0.3];
    r = [zeros(size(mainhandles.data(filechoice).Dpeaks,1),1) mainhandles.data(filechoice).Dpeaks+0.3];
    mainhandles.data(filechoice).ApeaksRaw = [mainhandles.data(filechoice).ApeaksRaw; r];
end

% Update
if mainhandles.settings.peakfinder.DatA || mainhandles.settings.peakfinder.AatD
    mainhandles = updatepeakglobal(mainhandles,'both');
end
