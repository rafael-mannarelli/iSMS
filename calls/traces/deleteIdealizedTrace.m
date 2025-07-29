function mainhandles = deleteIdealizedTrace(mainhandles, selectedPairs)
% Deletes information on analysed idealized traces
%
%    Input:
%     mainhandles   - handles structure of the mai window
%     selectedPairs - [file1 pair1;...]
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

% Default
if nargin<2 || isempty(selectedPairs)
    selectedPairs = getPairs(mainhandles.figure1,'all');
end

% Delete
for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    mainhandles.data(file).FRETpairs(pair).vbfitE_fit = [];
end
