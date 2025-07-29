function time = idxToTime(mainhandles,selectedPair,exc,idx)
% Converts trace index to time
%
%    Input:
%     mainhandles   - handle structure of the main window
%     selectedPair  - [file pair]
%     exc           - 'D', 'A'
%     idx           - trace indices
%
%    Output:
%     time          - time vector
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

% Initialize
time = [];

% Get time vector of selected pair
times = getTimeVector(mainhandles,selectedPair,exc);

% Convert idx to time
if ~isempty(times)
    time = times(idx);
end
