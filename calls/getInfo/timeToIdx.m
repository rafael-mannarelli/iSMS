function idx = timeToIdx(mainhandles,selectedPair,exc,t)
% Converts time point to trace data index
%
%    Input:
%     mainhandles   - handles structure of the main window
%     selectedPair  - [file pair]
%     exc           - 'D', 'A'
%     t             - time point
%
%    Output:
%     idx           - data index
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

% Get time vector
time = getTimeVector(mainhandles,selectedPair,exc);

% Convert time to index
idx = t;
for i = 1:length(t)
    [~, idx(i)] = min(abs(time-t(i)));
end
