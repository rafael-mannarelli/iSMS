function states = getStates(mainhandle)
% Returns all FRET states found by vbFRET. states = [file pair mu(E)
% state;...] sorted according to FRET value (high low). 'state' is the
% state in the trace (1,2,...)
%
%     Input:
%      mainhandle   - handle to the main window 
%
%     Output:
%      states       - [file pair mu(E) state;...]
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

states = []; % States found by vbFRET

if isempty(mainhandle) || (~ishandle(mainhandle))
    return
end

% Get handles structures
mainhandles = guidata(mainhandle);
selectedPairs = getPairs(mainhandle, 'Dynamics'); % Returns all pairs with dynamics analysed
if isempty(selectedPairs)
    return
end

%% Get states

states = zeros(size(selectedPairs,1),4);
idx1 = 1;
for i = 1:size(selectedPairs,1)
    file = selectedPairs(i,1);
    pair = selectedPairs(i,2);
    
    temp = unique(mainhandles.data(selectedPairs(i,1)).FRETpairs(selectedPairs(i,2)).vbfitE_fit,'rows'); % Unique states
    nstates = size(temp,1); % 
    idx2 = idx1+nstates-1;
    states(idx1:idx2,:) = [file*ones(nstates,1) pair*ones(nstates,1) temp];
    idx1 = idx2+1;
end

% Sort according to descending FRET
states = sortrows(states,-3); 